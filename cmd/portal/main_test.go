package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestManagementBoundary(t *testing.T) {
	p := portal{cfg: config{Prefix: "multica", Port: 80, Home: 43130, Daily: 43133, Admin: 43230}, key: strings.Repeat("a", 64)}
	h := p.handler()
	for _, tc := range []struct {
		host, method, path, auth, origin, body string
		want                                   int
	}{
		{"multica.localhost", "GET", "/", "", "", "", 200},
		{"localhost:43130", "GET", "/manage", "", "", "", 302},
		{"unrelated.test", "GET", "/", "", "", "", 421},
		{"multica.localhost", "GET", "/api/job", "", "", "", 403},
		{"localhost:43130", "GET", "/api/job", p.key, "", "", 403},
		{"multica.localhost", "GET", "/api/job", p.key, "", "", 200},
		{"multica.localhost", "POST", "/api/action", p.key, "http://unrelated.test", `{"action":"stop"}`, 403},
		{"multica.localhost", "POST", "/api/action", p.key, "http://multica.localhost", `{"action":"arbitrary"}`, 400},
	} {
		r := httptest.NewRequest(tc.method, "http://"+tc.host+tc.path, strings.NewReader(tc.body))
		r.Header.Set("Authorization", "Bearer "+tc.auth)
		r.Header.Set("Origin", tc.origin)
		r.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		if w.Code != tc.want {
			t.Errorf("%s %s%s: got %d, want %d", tc.method, tc.host, tc.path, w.Code, tc.want)
		}
	}
	for role, port := range map[string]int{"user": 43133, "admin": 43230} {
		w := httptest.NewRecorder()
		h.ServeHTTP(w, httptest.NewRequest("GET", "http://localhost:43130/"+role, nil))
		if w.Header().Get("Location") != "http://multica-"+role+".localhost/login" {
			t.Fatalf("wrong %s redirect (tunnel port %d)", role, port)
		}
	}
}
func TestProxyTranslatesOnlyItsOwnOrigin(t *testing.T) {
	const public = "http://multica-user.localhost"
	var target string
	upstream := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Location", target+"/login")
		w.Header().Set("Access-Control-Allow-Origin", target)
		fmt.Fprint(w, r.Header.Get("Origin")+" "+r.Header.Get("Referer")+" "+r.URL.RequestURI())
	}))
	defer upstream.Close()
	target = upstream.URL
	h := proxy(target, public)
	for _, origin := range []string{public, "https://unrelated.test"} {
		r := httptest.NewRequest("GET", public+"/auth/test?q=1", nil)
		r.Header.Set("Origin", origin)
		r.Header.Set("Referer", origin+"/a")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		want := origin
		if origin == public {
			want = target
		}
		if w.Body.String() != want+" "+want+"/a /auth/test?q=1" || w.Header().Get("Location") != public+"/login" || w.Header().Get("Access-Control-Allow-Origin") != public {
			t.Fatalf("unexpected proxy response %d %s", w.Code, w.Body)
		}
	}
}
