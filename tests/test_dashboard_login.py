import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "hyperv"))
import guest


class DashboardLoginTests(unittest.TestCase):
    def test_initial_code_is_private_persistent_state(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(guest, "STATE", Path(directory)):
            with self.assertRaises(ValueError):
                guest.credentials(initial_code="invalid")
            saved = guest.credentials(initial_email="daily@example.test", initial_code="012345")
            self.assertEqual(guest.credentials(), saved)
            self.assertEqual(saved["code"], "012345")
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
            env = guest.render(existing, session_ttl="168h")["services"]["backend"]["environment"]
            self.assertEqual(env["ALLOWED_EMAILS"], guest.SETTINGS["email"])
            self.assertEqual(env["AUTH_TOKEN_TTL"], "168h")
            self.assertEqual(env["MULTICA_DEV_VERIFICATION_CODE"], "654321")
