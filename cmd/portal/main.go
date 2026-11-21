// The Windows operator's loopback-only landing page and dashboard proxy.
package main

import (
	"bytes"
	"context"
	"crypto/subtle"
	_ "embed"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

//go:embed index.html
var page []byte

//go:embed favicon.ico
var favicon []byte

type config struct {
	ManagementAuth                              string
	Name, Prefix, Directory, Script, PowerShell string
	Home, Daily, Admin, Port                    int
}
type job struct {
	Action  string `json:"action"`
	Running bool   `json:"running"`
	OK      bool   `json:"ok"`
	Message string `json:"message"`
}
type portal struct {
	cfg  config
	key  string
	mu   sync.Mutex
	last job
}

func (p *portal) host(suffix string) string {
	h := p.cfg.Prefix + suffix + ".localhost"
	if p.cfg.Port != 80 {
		h += fmt.Sprintf(":%d", p.cfg.Port)
	}
	return h
}
func send(w http.ResponseWriter, value any) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(value)
}
func (p *portal) run(ctx context.Context, action string) ([]byte, error) {
	pwsh := p.cfg.PowerShell
	if _, err := os.Stat(pwsh); errors.Is(err, os.ErrNotExist) {
		pwsh, err = exec.LookPath("pwsh.exe")
		if err != nil {
			return []byte("Install PowerShell 7.3 or later and rerun Install-Portal.ps1."), err
		}
	}
	cmd := exec.CommandContext(ctx, pwsh, "-NoLogo", "-NoProfile", "-NonInteractive", "-File", p.cfg.Script, "-Name", p.cfg.Name, "-Action", action)
	hide(cmd)
	return cmd.CombinedOutput()
}
func proxy(target, public string) http.Handler {
	u, _ := url.Parse(target)
	authority := u.Host
	if u.Hostname() == "localhost" {
		u.Host = net.JoinHostPort("127.0.0.1", u.Port())
	}
	rp := &httputil.ReverseProxy{Rewrite: func(r *httputil.ProxyRequest) {
		r.SetURL(u)
		r.Out.Host = authority
		r.Out.Header.Del("Forwarded")
		r.Out.Header.Set("X-Forwarded-Proto", "http")
		r.Out.Header.Set("X-Forwarded-Host", authority)
		if r.In.Header.Get("Origin") == public {
			r.Out.Header.Set("Origin", target)
		}
		if v := r.In.Header.Get("Referer"); strings.HasPrefix(v, public+"/") {
			r.Out.Header.Set("Referer", target+strings.TrimPrefix(v, public))
		}
	}, ModifyResponse: func(r *http.Response) error {
		if v := r.Header.Get("Location"); strings.HasPrefix(v, target+"/") {
			r.Header.Set("Location", public+strings.TrimPrefix(v, target))
		}
		if r.Header.Get("Access-Control-Allow-Origin") == target {
			r.Header.Set("Access-Control-Allow-Origin", public)
		}
		return nil
	}, ErrorHandler: func(w http.ResponseWriter, r *http.Request, e error) {
		http.Error(w, "This Multica dashboard is offline. Check the VM on the management page.", 503)
	}}
	return rp
}
func (p *portal) handler() http.Handler {
	html := page
	if p.key != "" {
		html = bytes.Replace(page, []byte("<html "), []byte("<html data-key-required "), 1)
	}
	daily, admin := p.host("-user"), p.host("-admin")
	links := map[string]string{"/user": "http://" + daily + "/login", "/admin": "http://" + admin + "/login"}
	dashboards := map[string]http.Handler{daily: proxy(fmt.Sprintf("http://localhost:%d", p.cfg.Daily), "http://"+daily), admin: proxy(fmt.Sprintf("http://127.0.0.1:%d", p.cfg.Admin), "http://"+admin)}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		host := strings.ToLower(r.Host)
		if d := dashboards[host]; d != nil {
			d.ServeHTTP(w, r)
			return
		}
		home := p.host("")
		legacy := host == fmt.Sprintf("localhost:%d", p.cfg.Home) || host == fmt.Sprintf("127.0.0.1:%d", p.cfg.Home)
		if host != home && !legacy {
			http.Error(w, "Unknown dashboard hostname", 421)
			return
		}
		w.Header().Set("Cache-Control", "no-store")
		w.Header().Set("Referrer-Policy", "no-referrer")
		w.Header().Set("X-Frame-Options", "DENY")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		if r.Method == "GET" || r.Method == "HEAD" {
			if dest, ok := links[r.URL.Path]; ok {
				http.Redirect(w, r, dest, 302)
				return
			}
			if r.URL.Path == "/" || r.URL.Path == "/manage" {
				if legacy && r.URL.Path == "/manage" {
					http.Redirect(w, r, "http://"+home+"/manage", 302)
					return
				}
				w.Header().Set("Content-Security-Policy", "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'")
				w.Header().Set("Content-Type", "text/html; charset=utf-8")
				w.Write(html)
				return
			}
			if r.URL.Path == "/portal.js" {
				w.Header().Set("Content-Type", "text/javascript")
				w.Write(js)
				return
			}
			if r.URL.Path == "/favicon.ico" {
				w.Header().Set("Content-Type", "image/x-icon")
				w.Write(favicon)
				return
			}
		}
		if !strings.HasPrefix(r.URL.Path, "/api/") {
			http.NotFound(w, r)
			return
		}
		if host != home {
			http.Error(w, "Use the management hostname.", 403)
			return
		}
		if p.key != "" && subtle.ConstantTimeCompare([]byte(r.Header.Get("Authorization")), []byte("Bearer "+p.key)) != 1 {
			http.Error(w, "Open the operator management shortcut to pair this browser.", 403)
			return
		}
		switch {
		case r.Method == "GET" && r.URL.Path == "/api/job":
			p.mu.Lock()
			j := p.last
			p.mu.Unlock()
			send(w, j)
		case r.Method == "POST" && r.URL.Path == "/api/action":
			if r.Header.Get("Origin") != "http://"+home || r.Header.Get("Content-Type") != "application/json" {
				http.Error(w, "Invalid origin or content type", 403)
				return
			}
			var body struct{ Action string }
			if json.NewDecoder(http.MaxBytesReader(w, r.Body, 256)).Decode(&body) != nil {
				http.Error(w, "Invalid action", 400)
				return
			}
			switch body.Action {
			case "status", "check", "install", "start", "stop", "restart", "boot-on", "boot-off":
			default:
				http.Error(w, "Unknown action", 400)
				return
			}
			p.mu.Lock()
			if p.last.Running {
				p.mu.Unlock()
				http.Error(w, "An operation is running.", 409)
				return
			}
			p.last = job{Action: body.Action, Running: true}
			p.mu.Unlock()
			go func(a string) {
				ctx, cancel := context.WithTimeout(context.Background(), 3*time.Hour)
				defer cancel()
				b, e := p.run(ctx, a)
				msg := strings.TrimSpace(string(b))
				if e != nil && msg == "" {
					msg = e.Error()
				}
				if len(msg) > 16000 {
					msg = msg[len(msg)-16000:]
				}
				p.mu.Lock()
				p.last = job{Action: a, OK: e == nil, Message: msg}
				p.mu.Unlock()
			}(body.Action)
			w.WriteHeader(http.StatusAccepted)
		default:
			http.Error(w, "Unsupported request", 405)
		}
	})
}

//go:embed portal.js
var js []byte

func operatorKey(mode, path string) (string, error) {
	switch mode {
	case "local":
		return "", nil
	case "", "key": // Older portal configurations always required a key.
		b, err := os.ReadFile(path)
		if err != nil {
			return "", err
		}
		key := strings.TrimSpace(string(b))
		if decoded, err := hex.DecodeString(key); err == nil && len(decoded) == 32 {
			return key, nil
		}
		return "", errors.New("invalid operator key")
	default:
		return "", errors.New("unknown management authentication mode")
	}
}

func main() {
	if len(os.Args) != 2 {
		log.Fatal("Expected portal configuration path")
	}
	var c config
	b, e := os.ReadFile(os.Args[1])
	if e != nil {
		log.Fatal(e)
	}
	if e = json.Unmarshal(b, &c); e != nil {
		log.Fatal(e)
	}
	key, e := operatorKey(c.ManagementAuth, filepath.Join(filepath.Dir(os.Args[1]), "operator.key"))
	if e != nil {
		log.Fatal(e)
	}
	p := portal{cfg: c, key: key}
	handler := p.handler()
	ports := []int{c.Home}
	if c.Port != c.Home {
		ports = append(ports, c.Port)
	}
	var listeners []net.Listener
	for _, port := range ports {
		l, e := net.Listen("tcp4", fmt.Sprintf("127.0.0.1:%d", port))
		if e != nil {
			log.Fatal(e)
		}
		listeners = append(listeners, l)
	}
	for _, l := range listeners {
		go func(l net.Listener) {
			srv := http.Server{Handler: handler, ReadHeaderTimeout: 10 * time.Second, IdleTimeout: 90 * time.Second}
			if e := srv.Serve(l); !errors.Is(e, http.ErrServerClosed) {
				log.Fatal(e)
			}
		}(l)
	}
	select {}
}
