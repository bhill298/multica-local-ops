"""Check the device boundary in the generated guest Compose configuration."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "hyperv"))
import guest


class WorkerDevices(unittest.TestCase):
    credentials = dict(password="test", jwt="test", code="test")

    def test_device_only_on_provider_workers(self):
        services = guest.render(self.credentials, "108")["services"]
        for name, service in services.items():
            with self.subTest(name=name):
                self.assertFalse(service.get("privileged", False))
                if name in ("codex", "claude", "agy"):
                    self.assertEqual(service["devices"], ["/dev/kvm:/dev/kvm:rw"])
                    self.assertEqual(service["group_add"], ["108"])
                else:
                    self.assertNotIn("devices", service)
                    self.assertNotIn("group_add", service)

    def test_disabled_configuration_needs_no_kvm(self):
        for service in guest.render(self.credentials)["services"].values():
            self.assertNotIn("devices", service)
            self.assertNotIn("group_add", service)
