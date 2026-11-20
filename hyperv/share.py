"""Expose only the VM's exchange dirs to the Windows operator on the private link."""
import os
from pathlib import Path
import secrets
import subprocess


def configure(state):
    marker=Path("/etc/samba/multica-original.conf")
    conf=Path("/etc/samba/smb.conf")
    if not marker.exists():
        marker.write_bytes(conf.read_bytes())
    route=subprocess.check_output(["ip","-4","route","show","default"],text=True).splitlines()[0].split()
    interface=route[route.index("dev")+1]
    import re
    if not re.fullmatch(r"[A-Za-z0-9_.-]+",interface): raise ValueError("Unexpected guest uplink")
    # smbpasswd is a separate, revocable password. The GUI credential holds no guest shell key.
    user="multicafiles"
    if subprocess.run(["id",user],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode:
        subprocess.run(["useradd","--system","--no-create-home","--shell","/usr/sbin/nologin",user],check=True)
    path=state/"share-password"
    if not path.exists():
        with open(path,"x",opener=lambda p,f: os.open(p,f,0o600)) as out:
            out.write(secrets.token_urlsafe(32))
    password=path.read_text()
    subprocess.run(["smbpasswd","-s","-a",user],input=password+"\n"+password+"\n",text=True,check=True,stdout=subprocess.DEVNULL)
    conf.write_text(f"""[global]
server role = standalone server
interfaces = {interface} lo
bind interfaces only = yes
disable netbios = yes
smb ports = 445
server min protocol = SMB3_00
server signing = mandatory
smb encrypt = required
map to guest = Never
load printers = no
[MulticaProjects]
path = /srv/multica/project
valid users = multicafiles
force user = multicaops
guest ok = no
read only = no
follow symlinks = no
wide links = no
""")
    subprocess.run(["testparm","-s"],check=True,stdout=subprocess.DEVNULL)
    subprocess.run(["systemctl","enable","--now","smbd"],check=True)
    subprocess.run(["systemctl","reload","smbd"],check=True)
