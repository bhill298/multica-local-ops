import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "hyperv"))
import guest
from dashboard_logins import describe


class DashboardLoginTests(unittest.TestCase):
    def test_quick_start_matches_both_fresh_logins_before_and_after_creation(self):
        for email in ("user@localhost", "admin@localhost"):
            with self.subTest(email=email), tempfile.TemporaryDirectory() as directory:
                state = Path(directory)
                with patch.object(guest, "STATE", state):
                    summary = describe(state, email)
                    self.assertEqual(summary, {"email": email, "pin": "111111"})
                    self.assertFalse((state / "credentials.json").exists())
                    env = guest.render(guest.credentials(initial_email=email))["services"]["backend"]["environment"]
                    self.assertEqual(env["ALLOWED_EMAILS"], summary["email"])
                    self.assertEqual(env["MULTICA_DEV_VERIFICATION_CODE"], summary["pin"])
                    self.assertEqual(env["AUTH_TOKEN_TTL"], "87600h")
                    self.assertEqual(describe(state, email), summary)

    def test_initial_code_is_private_persistent_state(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(guest, "STATE", Path(directory)):
            with self.assertRaises(ValueError):
                guest.credentials(initial_code="invalid")
            saved = guest.credentials(initial_email="daily@example.test", initial_code="012345")
            self.assertEqual(guest.credentials(), saved)
            self.assertEqual(saved["code"], "012345")
            self.assertEqual(describe(guest.STATE, "unused@example.test"), {"email": "daily@example.test", "pin": None})
            with self.assertRaises(ValueError):
                guest.credentials(initial_code="654321")
            env = guest.render(saved)["services"]["backend"]["environment"]
            self.assertEqual(env["ALLOWED_EMAILS"], "daily@example.test")
            self.assertEqual(env["AUTH_TOKEN_TTL"], "87600h")
            self.assertEqual(env["MULTICA_DEV_VERIFICATION_CODE"], "012345")

    def test_legacy_owner_and_manual_admin(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(guest, "STATE", Path(directory)):
            existing = dict(password="fixture", jwt="fixture", code="654321")
            (guest.STATE / "credentials.json").write_text(json.dumps(existing))
            self.assertEqual(guest.credentials(initial_email="daily@example.test"), existing)
            self.assertEqual(describe(guest.STATE, "unused@example.test")["email"], guest.SETTINGS["email"])
            env = guest.render(existing)["services"]["backend"]["environment"]
            self.assertEqual(env["ALLOWED_EMAILS"], guest.SETTINGS["email"])
            self.assertEqual(env["AUTH_TOKEN_TTL"], "87600h")
            self.assertEqual(env["MULTICA_DEV_VERIFICATION_CODE"], "654321")
