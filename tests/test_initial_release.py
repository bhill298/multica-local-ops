import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "hyperv"))
import guest


class InitialReleaseTests(unittest.TestCase):
    def test_new_legacy_and_upgraded_vm(self):
        defaults = json.loads((guest.ROOT / "config/settings.json").read_text())
        baseline = json.loads((guest.ROOT / "hyperv/initial-release.json").read_text())
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory)
            fresh = guest.load_settings(state)
            self.assertEqual(fresh["upstream_commit"], baseline["commit"])
            for key in ("backend", "frontend"):
                self.assertEqual(fresh["images"][key], baseline[key])
            self.assertEqual(fresh["images"]["postgres"], defaults["images"]["postgres"])

            (state / "compose.json").write_text("{}")
            self.assertEqual(guest.load_settings(state), defaults)
            upgraded = dict(commit="a" * 40, backend="updated-backend", frontend="updated-ui")
            (state / "release-pins.json").write_text(json.dumps(upgraded))
            current = guest.load_settings(state)
            self.assertEqual(current["upstream_commit"], upgraded["commit"])
            for key in ("backend", "frontend"):
                self.assertEqual(current["images"][key], upgraded[key])
