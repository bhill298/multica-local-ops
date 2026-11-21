import http.client
import sys
import threading
import unittest
from http.server import ThreadingHTTPServer
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "hyperv"))
from dashboard_home import DashboardHome


class DashboardHomeTests(unittest.TestCase):
    def test_links_redirect_to_separate_login_origins(self):
        with ThreadingHTTPServer(("127.0.0.1", 0), DashboardHome) as server:
            thread = threading.Thread(target=server.serve_forever)
            thread.start()
            try:
                conn = http.client.HTTPConnection(*server.server_address, timeout=3)
                conn.request("GET", "/")
                response = conn.getresponse()
                self.assertEqual(response.status, 200)
                page = response.read().decode()
                for path, url in {"/user":"http://localhost:43133/login", "/admin":"http://127.0.0.1:43230/login"}.items():
                    self.assertIn(f'href="{path}"', page)
                    conn.request("GET", path + "?next=https://example.test")
                    response = conn.getresponse()
                    self.assertEqual(response.status, 302)
                    self.assertEqual(response.getheader("Location"), url)
                    self.assertEqual(response.read(), b"")
                conn.close()
            finally:
                server.shutdown()
                thread.join()
