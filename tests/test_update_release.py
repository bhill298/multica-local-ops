import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location("release", Path(__file__).resolve().parents[1] / "hyperv/update-release.py")
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)


class UpdateTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        root = Path(tmp.name)
        for key in ("ROOT", "STATE"):
            p = patch.object(release, key, root)
            p.start()
            self.addCleanup(p.stop)
        (root / "config").mkdir()
        self.old = {"upstream_commit": "a"*40, "images": {"postgres": "keep", "frontend": "old-web", "backend": "old-api"}}
        (root / "config/settings.json").write_text(json.dumps(self.old))
        cfg = {"services": {"backend": {"environment": {"example": "keep"}}, "frontend": {}, "postgres": {"image": "keep"}}}
        (root / "compose.json").write_text(json.dumps(cfg))
        (root / "team.json").write_text('{"lead":"agent-id"}')
        (root / "workspace").write_text("workspace")
        self.target = {"commit":"b"*40,"backend":"new-api","frontend":"new-web"}

    def test_busy_before_shutdown(self):
        with patch.object(release, "idle", side_effect=RuntimeError("busy")), patch.object(release.subprocess, "run") as cmd:
            with self.assertRaisesRegex(RuntimeError, "busy"):
                release.activate(self.target, "backup")
            cmd.assert_not_called()
        self.assertEqual(release.current()["backend"], "old-api")

    def test_task_racing_shutdown_reopens_old_intake(self):
        with patch.object(release, "idle", side_effect=[None, RuntimeError("busy")]), patch.object(release.subprocess, "run") as cmd:
            with self.assertRaisesRegex(RuntimeError, "busy"):
                release.activate(self.target, "backup")
            self.assertEqual(cmd.call_args.args[0][-3:], ["start","backend","frontend"])
        self.assertEqual(release.current()["backend"], "old-api")

    def test_failed_migration_preserves_recovery_id(self):
        def fail_up(args, **kwargs):
            if "up" in args:
                raise RuntimeError("migration failed")
        with patch.object(release, "idle"), patch.object(release.subprocess,"run",side_effect=fail_up):
            with self.assertRaisesRegex(RuntimeError, "migration failed"):
                release.activate(self.target, "test-backup-id")
        with self.assertRaisesRegex(RuntimeError, "test-backup-id"):
            release.main(["status"])

    def test_healthy_update_preserves_topology_and_reprovision_pins(self):
        runtimes = json.dumps([{"provider":p,"status":"online"} for p in ("codex","claude","antigravity")])
        def output(*args):
            return runtimes if "runtime" in args else '[{"id":"agent-id"}]'
        with patch.object(release, "idle"), patch.object(release.subprocess, "run"), patch.object(release, "output", side_effect=output), patch.object(release.urllib.request, "urlopen") as ui:
            ui.return_value.__enter__.return_value.status = 200
            release.activate(self.target, "backup")
        compose = json.loads((release.STATE / "compose.json").read_text())
        self.assertEqual(compose["services"]["backend"]["environment"], {"example":"keep"})
        self.assertEqual(compose["services"]["postgres"]["image"], "keep")
        (release.ROOT / "config/settings.json").write_text(json.dumps(self.old))
        self.assertEqual(release.current(), self.target)

    def test_invalid_pin_never_builds(self):
        with patch.object(release, "stage") as build:
            with self.assertRaises(ValueError):
                release.main(["stage","latest","bad","bad"])
            build.assert_not_called()


if __name__ == "__main__":
    unittest.main()
