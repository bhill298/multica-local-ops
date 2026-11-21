import json
import sys
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "hyperv"))
import admin
import admin_provider as providers


class AdminProviderTests(unittest.TestCase):
    def test_failed_registration_restores_previous_provider(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(admin, "STATE", Path(directory)):
            envfile = admin.STATE / "admin-runtime.env"
            override = admin.STATE / "admin-provider.json"
            old_env = "PATH=/opt/multica-owner-bin:/usr/bin:/bin\n"
            old_choice = '{"provider":"codex","model":"gpt-6-luna"}'
            envfile.write_text(old_env)
            override.write_text(old_choice)
            with patch.object(admin.guest, "run"), patch.object(admin.subprocess, "run", return_value=SimpleNamespace(returncode=3)), \
                    patch.object(admin.subprocess, "check_output", return_value="0"), patch.object(admin, "require_idle"), \
                    patch.object(providers, "install_tool"), patch.object(admin, "bind_admin", side_effect=RuntimeError("offline")):
                with self.assertRaisesRegex(RuntimeError, "offline"):
                    admin.configure_runtime("workspace", "claude", "claude-haiku-4-5", True, False)
            self.assertEqual(envfile.read_text(), old_env)
            self.assertEqual(override.read_text(), old_choice)

    def test_defaults_and_persistent_selection(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(providers, "STATE", Path(directory)):
            self.assertEqual(providers.selection(), ("codex", "gpt-6-luna"))
            self.assertEqual(providers.selection("agy"), ("agy", "gemini-3.8-flash-low"))
            self.assertEqual(providers.selection("Claude"), ("claude", "claude-haiku-4-5"))
            (providers.STATE / "admin-provider.json").write_text(json.dumps({"provider": "claude", "model": "custom"}))
            self.assertEqual(providers.selection(), ("claude", "custom"))
            self.assertEqual(providers.selection(model="other"), ("claude", "other"))
            self.assertEqual(providers.selection("codex"), ("codex", "gpt-6-luna"))
            for provider, model in (("bad", None), ("codex", ""), ("claude", "x\ny")):
                with self.assertRaises(ValueError):
                    providers.selection(provider, model)

    def test_switch_rebinds_existing_agent_only_on_its_host(self):
        with tempfile.TemporaryDirectory() as directory, patch.object(admin, "STATE", Path(directory)):
            (admin.STATE / "admin-agent-id").write_text("managed")
            updates = []
            status_reports = iter([{"status": "stopped"}, {"daemon_id": "admin-host"}])

            def cli(*args, **kwargs):
                cmd = args[3:-2]
                if cmd == ("daemon", "status"):
                    value = next(status_reports, {"daemon_id": "admin-host"})
                elif cmd == ("runtime", "list"):
                    value = [{"id": host, "daemon_id": host, "provider": "antigravity", "status": "online"}
                             for host in ("different-host", "admin-host")]
                elif cmd == ("agent", "get", "managed"):
                    value = {"id": "managed", "name": "Operator's name", "runtime_id": "old", "model": "old"}
                elif cmd[:2] == ("agent", "update"):
                    updates.append(cmd)
                    value = {}
                else:
                    self.fail(cmd)
                return SimpleNamespace(stdout=json.dumps(value))

            with patch.object(admin, "as_agent", side_effect=cli), patch.object(admin, "require_idle") as idle, \
                    patch.object(admin.time, "sleep") as wait:
                admin.bind_admin("workspace", "agy", "gemini-3.8-flash-low")
                wait.assert_called_once_with(2)
                idle.assert_called_once()
                self.assertEqual(updates, [("agent", "update", "managed", "--runtime-id", "admin-host",
                                            "--model", "gemini-3.8-flash-low")])
                updates.clear()
                idle.side_effect = RuntimeError("pending")
                with self.assertRaisesRegex(RuntimeError, "pending"):
                    admin.bind_admin("workspace", "agy", "gemini-3.8-flash-low")
                self.assertFalse(updates)
