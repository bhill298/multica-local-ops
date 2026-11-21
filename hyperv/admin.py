"""Provision the guest administrator and its independent Multica queue."""
import json
from getpass import getpass
import os
from pathlib import Path
import pwd
import subprocess
import sys
import tempfile
import time

import guest

STATE=Path("/var/lib/multica-owner-only")
BASE="http://127.0.0.1:43231"
USER="multica-vm-admin"
NAME="VM Admin — Full root access to Ubuntu"
OLD_NAME="VM ADMIN — FULL ROOT ACCESS TO UBUNTU VM — MANUAL START"
INSTRUCTIONS=("Handle VM administration requested in this workspace. Inspect the current state first. "
              "Limit changes to the requested scope, preserve the daily and admin isolation, and verify the result. "
              "Report findings and actions without printing credentials. Leave unrelated running jobs alone.")
BIN=Path("/opt/multica-owner-bin")


def as_agent(*cmd, **kwargs):
    return guest.run("runuser","-u",USER,"--","env",f"PATH={BIN}:/usr/bin:/bin",
                     "MULTICA_SERVER_URL="+BASE,*cmd,**kwargs)


def main():
    os.umask(0o077)
    STATE.mkdir(mode=0o700,exist_ok=True)
    guest.STATE=STATE
    initial_code = getpass("Initial admin dashboard code (six digits): ") if "--prompt-for-login-code" in sys.argv else None
    if "--initial-code-stdin" in sys.argv:
        initial_code=sys.stdin.readline().rstrip("\r\n")
    creds=guest.credentials(initial_email=guest.SETTINGS["vm_admin_login_email"], initial_code=initial_code)
    data=guest.render(creds)
    for provider in guest.PROVIDERS:
        del data["services"][provider],data["networks"][provider],data["volumes"][provider+"-home"]
    backend=data["services"]["backend"]
    backend["networks"]=["database","web"]
    backend["ports"]=["127.0.0.1:43231:8080"]
    for name in ["MULTICA_APP_URL","FRONTEND_ORIGIN","CORS_ALLOWED_ORIGINS"]:
        backend["environment"][name]="http://127.0.0.1:43230"
    data["services"]["frontend"]["ports"]=["127.0.0.1:43230:3000"]
    cfg=STATE/"compose.json"
    cfg.write_text(json.dumps(data))
    guest.run("docker","compose","-p","multica-owner-only","-f",str(cfg),"up","-d")
    try: pwd.getpwnam(USER)
    except KeyError: guest.run("useradd","-m","-s","/bin/bash",USER)
    sudoers=Path("/etc/sudoers.d/multica-vm-admin")
    sudoers.write_text(USER+" ALL=(ALL) NOPASSWD:ALL\n")
    sudoers.chmod(0o440)
    guest.run("visudo","-cf",str(sudoers))
    BIN.mkdir(mode=0o755,exist_ok=True)
    BIN.chmod(0o755)
    # Read immutable image contents, never tools from a running untrusted worker.
    image="multica-local/codex:vm"
    source=guest.run("docker","run","--rm","--network","none","--entrypoint","find",image,
                     "/usr/local/lib/node_modules/@openai","-type","f","-name","codex","-path","*/vendor/*",
                     capture_output=True,text=True).stdout.strip().splitlines()
    if len(source)!=1: raise RuntimeError("Cannot identify the Codex native binary in the worker image.")
    container=guest.run("docker","create","--network","none",image,"true",capture_output=True,text=True).stdout.strip()
    try:
        with tempfile.TemporaryDirectory(dir=BIN) as staging:
            companion=str(Path(source[0]).with_name("codex-code-mode-host"))
            for name,src in (("codex",source[0]),("codex-code-mode-host",companion),("multica","/usr/local/bin/multica")):
                binary=Path(staging)/name
                guest.run("docker","cp",container+":"+src,str(binary))
                binary.chmod(0o755)
                binary.replace(BIN/name)
    finally: guest.run("docker","rm",container,stdout=subprocess.DEVNULL)
    email=creds.get("email", guest.SETTINGS["email"])
    for i in range(60):
        try:
            guest.api("/auth/send-code",body={"email":email},base=BASE)
            break
        except OSError:
            if i==59: raise
            time.sleep(2)
    token=guest.api("/auth/verify-code",body={"email":email,"code":creds["code"]},base=BASE)["token"]
    spaces=guest.api("/api/workspaces",token,base=BASE)
    ws=next((w for w in spaces if w["slug"]=="vm-administration"),None)
    if not ws: ws=guest.api("/api/workspaces",token,{"name":"VM administration","slug":"vm-administration","issue_prefix":"ADMIN"},base=BASE)
    if not guest.api("/api/me",token,base=BASE).get("onboarded_at"):
        guest.api("/api/me/onboarding/complete",token,{"completion_path":"skip_existing","workspace_id":ws["id"]},base=BASE)
    guest.set_owner_prompt_defaults("multica-owner-only", STATE, email)
    if not (Path(pwd.getpwnam(USER).pw_dir)/".multica/config.json").exists():
        pat=guest.api("/api/tokens/",token,{"name":"Owner-only VM administrator","expires_in_days":90},base=BASE)["token"]
        as_agent("multica","config","set","server_url",BASE)
        as_agent("multica","login","--token",input=pat+"\n",text=True)
    if "--prepare" in sys.argv: return
    if "--auth" in sys.argv:
        as_agent("codex","login","--device-auth")
        return
    if subprocess.run(["systemctl","is-active","--quiet","multica-manual-admin.service"]).returncode == 0:
        guest.run("systemctl","stop","multica-manual-admin.service")
    for unit in ("multica-vm-admin.service","multica-dashboard-home.service"):
        guest.run("install","-m","0644",str(guest.ROOT/"hyperv"/unit),"/etc/systemd/system/"+unit)
    guest.run("systemctl","daemon-reload")
    guest.run("systemctl","enable","--now","multica-vm-admin.service","multica-dashboard-home.service")
    for _ in range(60):
        runtimes=json.loads(as_agent("multica","--workspace-id",ws["id"],"runtime","list","--output","json",capture_output=True,text=True).stdout)
        rt=next((r for r in runtimes if r["provider"]=="codex" and r["status"]=="online"),None)
        if rt: break
        time.sleep(2)
    else: raise RuntimeError("Guest administrator runtime did not register.")
    common=["multica","--workspace-id",ws["id"]]
    agents=json.loads(as_agent(*common,"agent","list","--output","json",capture_output=True,text=True).stdout)
    legacy=next((a for a in agents if a["name"]==OLD_NAME),None)
    if legacy and not any(a["name"]==NAME for a in agents):
        as_agent(*common,"agent","update",legacy["id"],"--name",NAME,"--instructions",INSTRUCTIONS)
    elif not any(a["name"]==NAME for a in agents):
        as_agent(*common,"agent","create","--name",NAME,"--runtime-id",rt["id"],"--model",guest.SETTINGS["worker_model"],
                 "--max-concurrent-tasks","1","--visibility","private","--instructions",INSTRUCTIONS)
    print("VM administrator online. Open http://localhost:43130/admin on Windows.")


if __name__=="__main__": main()
