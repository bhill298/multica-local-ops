"""Summarize the installed dashboard logins without starting either service."""
import json
from pathlib import Path

from guest import SETTINGS, STATE
from admin_provider import selection


def describe(state, initial_email):
    path = state / "credentials.json"
    default_pin = SETTINGS["vm_default_login_code"]
    if not path.exists():
        return {"email": initial_email, "pin": default_pin}
    saved = json.loads(path.read_text())
    return {"email": saved.get("email", SETTINGS["email"]),
            "pin": default_pin if saved["code"] == default_pin else None}


if __name__ == "__main__":
    provider, model = selection()
    print(json.dumps({
        "daily": describe(STATE, SETTINGS["vm_login_email"]),
        "admin": {**describe(Path("/var/lib/multica-owner-only"), SETTINGS["vm_admin_login_email"]),
                  "provider": provider, "model": model},
    }))
