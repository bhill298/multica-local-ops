import importlib.util
import io
import json
import subprocess
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

    def test_promote_requires_matching_running_images_and_finished_update(self):
        (release.STATE / "release-pins.json").write_text(json.dumps(self.target))
        for revision, version in (("bbbbbbb", {"version": "v1.2.3"}), ("aaaaaaa", {})):
            cli = json.dumps({"version": "1.2.3", "commit": revision})
            with patch.object(release, "output", side_effect=["new-api", "new-web", cli]), patch("sys.stdout", new_callable=io.StringIO) as out:
                release.main(["installed-pins"])
                self.assertEqual(json.loads(out.getvalue()), {**self.target, **version})
        with patch.object(release, "output", side_effect=["new-api", "other-web"]):
            with self.assertRaisesRegex(RuntimeError, "frontend.*differs"):
                release.main(["installed-pins"])
        (release.STATE / "update-pending.json").write_text('{"backup":"fixture"}')
        with patch.object(release, "output") as inspect:
            with self.assertRaisesRegex(RuntimeError, "interrupted"):
                release.main(["installed-pins"])
            inspect.assert_not_called()

    def test_busy_before_shutdown(self):
        with patch.object(release, "idle", side_effect=RuntimeError("busy")), patch.object(release.subprocess, "run") as cmd:
            with self.assertRaisesRegex(RuntimeError, "busy"):
                release.activate(self.target, "backup")
            cmd.assert_not_called()
        self.assertEqual(release.current()["backend"], "old-api")

    def test_named_extra_worker_blocks_before_an_upgrade(self):
        with patch.object(release, "output", return_value="multica-extra-gateway-worker-1") as inspect:
            with self.assertRaisesRegex(RuntimeError, "WorkerAction Stop.*multica-extra-gateway-worker-1"):
                release.idle()
        self.assertIn("label=local.multica.extra-worker", inspect.call_args.args)

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

    def test_stage_requires_release_version_and_matching_commit(self):
        (release.ROOT / "hyperv").mkdir()
        dockerfile = Path(__file__).resolve().parents[1] / "hyperv/provider.Dockerfile"
        (release.ROOT / "hyperv/provider.Dockerfile").write_text(dockerfile.read_text())
        for version, commit, ok in (("dev", "bbbbbbb", False), ("0.11.1", "", False),
                                    ("0.11.1", "ccccccc", False), ("0.11.1", "bbbbbbb", True),
                                    ("v0.11.1", "bbbbbbb", True)):
            with self.subTest(version=version, commit=commit), patch.object(release, "idle"), \
                    patch.object(release.subprocess, "run"), patch.object(release, "check_daemon_command") as parser, patch.object(release, "output", side_effect=lambda *args:
                        "image" if "inspect" in args else json.dumps({"version": version, "commit": commit})):
                if ok:
                    release.stage(self.target)
                    self.assertEqual([call.args[0] for call in parser.call_args_list], list(release.PROVIDERS))
                else:
                    with self.assertRaisesRegex(RuntimeError, "does not identify"):
                        release.stage(self.target)

    def test_daemon_probe_uses_deployed_flags_without_parsing_help_text(self):
        flags = ["multica", "daemon", "start", "--foreground", "--no-auto-update", "--no-auto-reload"]
        repo = Path(__file__).resolve().parents[1]
        for path in ("hyperv/guest.py", "hyperv/multica-vm-admin.service"):
            self.assertIn(" ".join(flags), (repo / path).read_text())
        ok = subprocess.CompletedProcess([], 0, "arbitrary help wording", "")
        bad = subprocess.CompletedProcess([], 1, "", "unknown flag: --no-auto-reload")
        with patch.object(release.subprocess, "run", side_effect=[ok, bad]) as invoke:
            release.check_daemon_command("claude", "test-image")
            cmd = invoke.call_args_list[0].args[0]
            self.assertEqual(cmd[-len(flags)-1:], flags + ["--help"])
            self.assertIn("--network", cmd)
        with patch.object(release.subprocess, "run", return_value=bad):
            with self.assertRaisesRegex(RuntimeError, "Staging claude: .*unknown flag: --no-auto-reload"):
                release.check_daemon_command("claude", "test-image")
        with patch.object(release.subprocess, "run", return_value=ok), patch("sys.stderr") as err:
            release.check_daemon_command("claude", "test-image")
            self.assertIn("inconclusive", str(err.write.call_args_list))


if __name__ == "__main__":
    unittest.main()
