"""Windows loopback ports. Internal guest service ports are fixed."""
import json
from pathlib import Path

PORTS = json.loads(Path(__file__).with_name("dashboard-ports.json").read_text())
if (set(PORTS) != {"home", "daily", "admin"} or
        any(type(v) is not int or not 1024 <= v <= 65535 for v in PORTS.values()) or
        len(set(PORTS.values())) != 3):
    raise ValueError("Choose three distinct Windows dashboard ports between 1024 and 65535.")
