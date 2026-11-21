"""Provider selection and host CLI installation for the VM administrator."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile

import guest

STATE = Path("/var/lib/multica-owner-only")
BIN = Path("/opt/multica-owner-bin")
USER = "multica-vm-admin"
PROVIDERS = {"codex": "codex", "claude": "claude", "agy": "antigravity"}


def selection(provider=None, model=None):
    if provider is None:
        override = STATE / "admin-provider.json"
        if override.exists():
            saved = json.loads(override.read_text())
            provider = saved["provider"]
            if model is None:
                model = saved["model"]
        else:
            provider = guest.SETTINGS["admin_provider"]
    if isinstance(provider, str):
        provider = provider.lower()
    if provider not in PROVIDERS:
        raise ValueError("Choose codex, claude or agy for the VM administrator.")
    if model is None:
        model = guest.SETTINGS["admin_models"][provider]
    if not isinstance(model, str) or not model.strip() or any(ord(c) < 32 for c in model):
        raise ValueError("Enter a nonempty model identifier without control characters.")
    return provider, model


def tool_dir(provider):
    return BIN if provider == "codex" else BIN / "providers" / provider


def install_tool(provider):
    if provider == "codex":
        return  # admin.py installs Codex along with Multica and its command host.
    directory = tool_dir(provider)
    directory.parent.mkdir(mode=0o755, exist_ok=True)
    directory.parent.chmod(0o755)
    directory.mkdir(mode=0o755, exist_ok=True)
    directory.chmod(0o755)
    image = f"multica-local/{provider}:vm"
    cid = subprocess.check_output(["docker", "create", "--network", "none", image, "true"], text=True).strip()
    try:
        with tempfile.TemporaryDirectory(dir=directory) as stage:
            binary = Path(stage) / provider
            guest.run("docker", "cp", "-L", f"{cid}:/usr/local/bin/{provider}", str(binary))
            binary.chmod(0o755)
            binary.replace(directory / provider)
    finally:
        guest.run("docker", "rm", cid, stdout=subprocess.DEVNULL)
    link = directory / "multica"
    if not link.is_symlink():
        link.symlink_to(BIN / "multica")


def login(provider, model):
    binary = tool_dir(provider) / provider
    if not binary.exists():
        install_tool(provider)
    args = {"codex": ["login", "--device-auth"], "claude": ["auth", "login", "--claudeai"],
            "agy": ["--model", model]}[provider]
    os.chdir(Path("/home") / USER)
    guest.run("runuser", "-u", USER, "--", str(binary), *args)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["auth"])
    parser.add_argument("--provider", type=str.lower, choices=PROVIDERS)
    args = parser.parse_args()
    login(*selection(args.provider))
