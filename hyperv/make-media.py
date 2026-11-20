"""Remaster verified Ubuntu media with Subiquity autoinstall and an SSH public key."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

work = Path("/media-out")
source = "/source/ubuntu.iso"
arguments = ["xorriso", "-osirrox", "on", "-indev", source]
changes = []
for name in ("boot/grub/grub.cfg", "boot/grub/loopback.cfg"):
    dest = Path("/tmp") / Path(name).name
    subprocess.run([*arguments, "-extract", "/" + name, str(dest)], check=True)
    original = dest.read_text()
    modified, count = re.subn(r"(?m)^(\s*linux\s+[^\n]*?/casper/vmlinuz[^\n]*?)\s+---", r"\1 autoinstall ---", original)
    if not count:
        sys.exit("Unexpected Ubuntu boot menu: " + name)
    dest.write_text(re.sub(r"(?m)^set timeout=\d+", "set timeout=1", modified))
    changes.append((dest, name))

key = (work / "operator.pub").read_text().strip()
if not key.startswith("ssh-ed25519 ") or "\n" in key:
    sys.exit("Expected one SSH public key")
config = {"autoinstall": {"version": 1, "locale": "en_US.UTF-8",
    "identity": {"hostname": "multica-guest", "username": "multicaops",
                 "realname": "Multica operator", "password": "!"},
    "ssh": {"install-server": True, "allow-pw": False, "authorized-keys": [key]},
    "packages": ["linux-cloud-tools-virtual"],
    "storage": {"layout": {"name": "direct"}},
    "late-commands": ["echo 'multicaops ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/90-multica-operator",
                      "chmod 0440 /target/etc/sudoers.d/90-multica-operator"],
    "shutdown": "poweroff"}}
autofile = Path("/tmp/autoinstall.yaml")
autofile.write_text(json.dumps(config))
changes.append((autofile, "autoinstall.yaml"))
md5 = Path("/tmp/md5sum.txt")
subprocess.run([*arguments, "-extract", "/md5sum.txt", str(md5)], check=True)
lines = md5.read_text().splitlines()
for file, name in changes:
    lines = [line for line in lines if not line.endswith(" ./" + name)]
    lines.append(hashlib.md5(file.read_bytes()).hexdigest() + "  ./" + name)
md5.write_text("\n".join(lines) + "\n")
changes.append((md5, "md5sum.txt"))
cmd = ["xorriso", "-indev", source, "-outdev", str(work / "installer.partial.iso"),
       "-boot_image", "any", "replay"]
for file, name in changes:
    cmd.extend(["-map", str(file), "/" + name])
subprocess.run(cmd, check=True)
(work / "installer.partial.iso").rename(work / "installer.iso")
