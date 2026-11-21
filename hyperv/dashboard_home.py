"""Loopback-only bookmarks for the two independent Multica web applications."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit
from dashboard_ports import PORTS


class DashboardHome(BaseHTTPRequestHandler):
    destinations = {"/user": f"http://localhost:{PORTS['daily']}/login",
                    "/admin": f"http://127.0.0.1:{PORTS['admin']}/login"}
    page = Path(__file__).with_name("dashboard_home.html").read_bytes()

    def log_request(self, code="-", size="-"):
        # An old dashboard bookmark can contain a query string. Keep it out of journald.
        pass

    def do_HEAD(self):
        path = urlsplit(self.path).path.rstrip("/")
        if path in self.destinations:
            self.send_response(302)
            self.send_header("Location", self.destinations[path])
            self.send_header("Content-Length", "0")
        elif path == "":
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(self.page)))
        else:
            self.send_error(404)
            return
        self.send_header("Cache-Control", "no-store")
        self.send_header("Referrer-Policy", "no-referrer")
        self.end_headers()
        if path == "" and self.command == "GET":
            self.wfile.write(self.page)

    do_GET = do_HEAD


if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", 43132), DashboardHome).serve_forever()
