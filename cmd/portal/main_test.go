package main

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestLANRoutes(t *testing.T) {
	p := portal{cfg: config{Prefix: "multica", Port: 8080, Home: 43130, Daily: 43133, Admin: 43230}}
	h := p.lanHandler(netip.MustParsePrefix("192.168.4.27/24"))
	for _, tc := range []struct {
		path, host, peer, location string
		want                       int
	}{
		{"/", "multica.lan:8080", "192.168.4.91:45200", "", 200},
		{"/user", "multica.lan:8080", "192.168.4.91:45200", "http://multica-user.lan:8080/login", 302},
		{"/admin", "multica.lan:8080", "192.168.4.91:45200", "http://multica-admin.lan:8080/login", 302},
		{"/api/job", "multica.lan:8080", "192.168.4.91:45200", "", 200},
		{"/manage", "multica.localhost:8080", "192.168.4.91:45200", "", 421},
		{"/admin", "multica.home.arpa:8080", "192.168.4.91:45200", "http://admin.multica.home.arpa:8080/login", 302},
		{"/admin", "localhost:43130", "192.168.4.91:45200", "", 421},
		{"/api/job", "multica.lan:8080", "192.168.5.91:45200", "", 403},
	} {
		r := httptest.NewRequest("GET", "http://"+tc.host+tc.path, nil)
		r.RemoteAddr = tc.peer
		r.Header.Set("X-Forwarded-For", "192.168.4.91")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		if w.Code != tc.want || w.Header().Get("Location") != tc.location {
			t.Errorf("%s %s%s: got %d %q", tc.peer, tc.host, tc.path, w.Code, w.Header().Get("Location"))
		}
	}
	for _, origin := range []string{"http://multica.localhost:8080", "http://multica.lan:8080"} {
		r := httptest.NewRequest("POST", "http://multica.lan:8080/api/action", strings.NewReader(`{"action":"unknown"}`))
		r.RemoteAddr = "192.168.4.91:1000"
		r.Header.Set("Origin", origin)
		r.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		want := 403
		if origin == "http://multica.lan:8080" {
			want = 400 // Accepted origin, rejected action.
		}
		if w.Code != want {
			t.Errorf("management origin %s: got %d, want %d", origin, w.Code, want)
		}
	}
}

func TestManagementBoundary(t *testing.T) {
	p := portal{cfg: config{Prefix: "multica", Port: 80, Home: 43130, Daily: 43133, Admin: 43230}, key: strings.Repeat("a", 64)}
	h := p.handler()
	for _, tc := range []struct {
		host, method, path, auth, origin, body string
		want                                   int
	}{
		{"multica.lan", "GET", "/", "", "", "", 200},
		{"multica.localhost", "GET", "/", "", "", "", 200},
		{"localhost:43130", "GET", "/manage", "", "", "", 302},
		{"unrelated.test", "GET", "/", "", "", "", 421},
		{"multica.lan", "GET", "/api/job", "", "", "", 403},
		{"localhost:43130", "GET", "/api/job", p.key, "", "", 403},
		{"multica.lan", "GET", "/api/job", p.key, "", "", 200},
		{"multica.lan", "POST", "/api/action", p.key, "http://unrelated.test", `{"action":"stop"}`, 403},
		{"multica.lan", "POST", "/api/action", p.key, "http://multica.lan", `{"action":"arbitrary"}`, 400},
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
		if w.Header().Get("Location") != "http://multica-"+role+".lan/login" {
			t.Fatalf("wrong %s redirect (tunnel port %d)", role, port)
		}
	}
}
func TestLocalManagementAccess(t *testing.T) {
	p := portal{cfg: config{Prefix: "multica", Port: 80, Home: 43130}}
	h := p.handler()
	for _, tc := range []struct {
		method, host, path, origin, content string
		want                                int
	}{
		{"GET", "multica.lan", "/api/job", "", "", 200},
		{"GET", "localhost:43130", "/api/job", "", "", 403},
		{"GET", "unrelated.test", "/api/job", "", "", 421},
		{"POST", "multica.lan", "/api/action", "http://unrelated.test", "application/json", 403},
		{"POST", "multica.lan", "/api/action", "", "application/json", 403},
		{"POST", "multica.lan", "/api/action", "http://multica.lan", "text/plain", 403},
	} {
		r := httptest.NewRequest(tc.method, "http://"+tc.host+tc.path, strings.NewReader(`{"action":"status"}`))
		r.Header.Set("Origin", tc.origin)
		r.Header.Set("Content-Type", tc.content)
		w := httptest.NewRecorder()
		h.ServeHTTP(w, r)
		if w.Code != tc.want {
			t.Errorf("%s %s: got %d, want %d", tc.host, tc.origin, w.Code, tc.want)
		}
	}
}
func TestOperatorKeyModes(t *testing.T) {
	path := filepath.Join(t.TempDir(), "operator.key")
	if k, err := operatorKey("local", path); err != nil || k != "" {
		t.Fatal("local mode should require no key")
	}
	for _, mode := range []string{"", "key", "typo"} {
		if _, err := operatorKey(mode, path); err == nil {
			t.Fatalf("accepted missing key for mode %q", mode)
		}
	}
	for _, value := range []string{"", strings.Repeat("z", 64), strings.Repeat("a", 64)} {
		if err := os.WriteFile(path, []byte(value), 0600); err != nil {
			t.Fatal(err)
		}
		for _, mode := range []string{"", "key"} {
			k, err := operatorKey(mode, path)
			if value == strings.Repeat("a", 64) {
				if err != nil || k != value {
					t.Fatal("valid key rejected")
				}
			} else if err == nil {
				t.Fatal("invalid key accepted")
			}
		}
	}
}
func TestProxyTranslatesOnlyItsOwnOrigin(t *testing.T) {
	const public = "http://multica-user.lan"
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
