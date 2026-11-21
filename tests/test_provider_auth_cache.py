import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "hyperv"))
from provider_auth_cache import FILES, install_login, login_fields


class ProviderAuthCacheTests(unittest.TestCase):
    def test_only_provider_login_reaches_fresh_cache(self):
        samples = {
            "codex": {"auth_mode": "chatgpt", "last_refresh": None,
                      "tokens": {"access_token": "a", "refresh_token": "r", "id_token": "id"}},
            "claude": {"claudeAiOauth": {"accessToken": "a", "refreshToken": "r", "expiresAt": 42,
                                        "scopes": ["example"], "subscriptionType": "fixture"}},
            "agy": {"auth_method": "fixture", "id_token_email": "sample@example.test",
                    "token": {"access_token": "a", "refresh_token": "r", "token_type": "Bearer",
                              "expiry": "2030-01-01T00:00:00Z"}},
        }
        for provider, expected in samples.items():
            with self.subTest(provider=provider), tempfile.TemporaryDirectory() as directory:
                home = Path(directory)
                source = json.loads(json.dumps(expected))
                source["other_service"] = "source-only"
                section = {"codex": "tokens", "claude": "claudeAiOauth", "agy": "token"}[provider]
                source[section]["unrelated"] = "source-only"
                payload = login_fields(provider, source)
                self.assertEqual(payload, expected)
                install_login(home, provider, payload)
                contents = home / FILES[provider]
                self.assertEqual(json.loads(contents.read_text()), expected)
                if os.name == "posix":
                    self.assertEqual(contents.stat().st_mode & 0o777, 0o600)
                with self.assertRaises(ValueError):
                    install_login(home, provider, {})
                self.assertEqual(json.loads(contents.read_text()), expected)

    def test_reauth_preserves_other_daily_claude_entries(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            dest = home / FILES["claude"]
            dest.parent.mkdir()
            dest.write_text('{"otherLocalLogin": "keep", "claudeAiOauth": {"refreshToken":"old"}}')
            fresh = {"claudeAiOauth": {"accessToken": "new", "refreshToken": "new-refresh"}}
            install_login(home, "claude", fresh)
            self.assertEqual(json.loads(dest.read_text()), dict(fresh, otherLocalLogin="keep"))

    @unittest.skipUnless(os.name == "posix", "worker filesystems are Linux")
    def test_refuses_redirected_worker_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            exchange = home / "exchange"
            exchange.mkdir()
            (home / ".claude").symlink_to(exchange, target_is_directory=True)
            with self.assertRaises(ValueError):
                install_login(home, "claude", {"claudeAiOauth":{"accessToken":"a","refreshToken":"r"}})
            self.assertEqual(list(exchange.iterdir()), [])

    @unittest.skipUnless(sys.platform.startswith("linux"), "guest login helper runs on Linux")
    def test_login_calls_provider_once_and_copies_only_on_success(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source_home = root / "admin"
            daily_home = root / "worker"
            bin_dir = root / "bin"
            for folder in (source_home, daily_home, bin_dir):
                folder.mkdir()
            for name in ("provider-auth.sh", "provider_auth_cache.py"):
                shutil.copyfile(Path(__file__).resolve().parents[1] / "hyperv" / name, root / name)
            (root / "admin_provider.py").write_text(
                'import os, sys\nfrom pathlib import Path\n'
                'assert sys.argv[1:] == ["auth","--provider","claude"]\n'
                'with open("attempts", "a") as f: f.write("login\\n")\n'
                'if os.environ.get("CANCEL"): sys.exit(1)\n'
                'p = Path(os.environ["SOURCE_HOME"]) / ".claude/.credentials.json"\n'
                'p.parent.mkdir(exist_ok=True)\n'
                '''p.write_text('{"claudeAiOauth":{"accessToken":"test","refreshToken":"test-refresh"}}')\n'''
            )
            shims = {
                "runuser": 'test "$1 $2 $3" = "-u multica-vm-admin --" || exit 1\nshift 3\nHOME="$SOURCE_HOME" exec "$@"',
                "docker": 'while [ "$#" -gt 0 ] && [ "$1" != claude ]; do shift; done\nshift\nHOME="$DAILY_HOME" exec "$@"',
            }
            for name, body in shims.items():
                executable = bin_dir / name
                executable.write_text("#!/bin/sh\n" + body + "\n")
                executable.chmod(0o700)
            env = dict(os.environ, SOURCE_HOME=str(source_home), DAILY_HOME=str(daily_home),
                       PATH=str(bin_dir) + ":" + os.environ["PATH"])
            cmd = ["bash", str(root / "provider-auth.sh")]
            result = subprocess.run([*cmd, "login", "claude"], env=env, capture_output=True, text=True, check=True)
            self.assertNotIn("test-refresh", result.stdout + result.stderr)
            cache = daily_home / FILES["claude"]
            self.assertEqual(json.loads(cache.read_text())["claudeAiOauth"]["accessToken"], "test")
            subprocess.run([*cmd, "copy", "claude"], env=env, capture_output=True, check=True)
            self.assertEqual((root / "attempts").read_text().splitlines(), ["login"])
            cache.write_text('{"otherLocalLogin":"preserved"}')
            result = subprocess.run([*cmd, "login", "claude"], env=dict(env, CANCEL="1"), capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(json.loads(cache.read_text()), {"otherLocalLogin": "preserved"})
