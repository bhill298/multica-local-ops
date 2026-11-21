"""Owner-launched guest administrator with an independent Multica queue and login."""
import json
import os
from pathlib import Path
import pwd
import subprocess
import sys
import time

import guest

STATE=Path("/var/lib/multica-owner-only")
BASE="http://127.0.0.1:43231"
USER="multica-vm-admin"
NAME="VM ADMIN — FULL ROOT ACCESS TO UBUNTU VM — MANUAL START"
BIN=Path("/opt/multica-owner-bin")


def as_agent(*cmd, **kwargs):
    return guest.run("runuser","-u",USER,"--","env",f"PATH={BIN}:/usr/bin:/bin",
                     "MULTICA_SERVER_URL="+BASE,*cmd,**kwargs)


def main():
    os.umask(0o077)
    STATE.mkdir(mode=0o700,exist_ok=True)
    guest.STATE=STATE
    creds=guest.credentials()
    data=guest.render(creds, session_ttl="168h")
    for provider in guest.PROVIDERS:
        del data["services"][provider],data["networks"][provider],data["volumes"][provider+"-home"]
    backend=data["services"]["backend"]
    backend["networks"]=["database","web"]
    backend["ports"]=["127.0.0.1:43231:8080"]
    for name in ["MULTICA_APP_URL","FRONTEND_ORIGIN","CORS_ALLOWED_ORIGINS"]:
        backend["environment"][name]="http://localhost:43230"
    data["services"]["frontend"]["ports"]=["127.0.0.1:43230:3000"]
    for service in data["services"].values(): service["restart"]="no"
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
        for name,src in (("codex",source[0]),("multica","/usr/local/bin/multica")):
            guest.run("docker","cp",container+":"+src,str(BIN/name))
            (BIN/name).chmod(0o755)
    finally: guest.run("docker","rm",container,stdout=subprocess.DEVNULL)
    email=guest.SETTINGS["email"]
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
    if not (Path(pwd.getpwnam(USER).pw_dir)/".multica/config.json").exists():
        pat=guest.api("/api/tokens/",token,{"name":"Owner-only VM administrator","expires_in_days":90},base=BASE)["token"]
        as_agent("multica","config","set","server_url",BASE)
        as_agent("multica","login","--token",input=pat+"\n",text=True)
    if "--prepare" in sys.argv: return
    if "--auth" in sys.argv:
        as_agent("codex","login","--device-auth")
        return
    if subprocess.run(["systemctl","is-active","--quiet","multica-manual-admin.service"]).returncode:
        guest.run("systemd-run","--unit=multica-manual-admin","--collect","--uid="+USER,
                  "--property=RuntimeMaxSec=1h","--property=KillMode=control-group",
                  "--setenv=HOME="+pwd.getpwnam(USER).pw_dir,"--setenv=PATH="+str(BIN)+":/usr/bin:/bin",
                  "--setenv=MULTICA_SERVER_URL="+BASE,'--setenv=MULTICA_CODEX_ARGS=-c approval_policy="never" -c sandbox_mode="danger-full-access"',
                  str(BIN/"multica"),"daemon","start","--foreground","--no-auto-update","--no-auto-reload")
    for _ in range(60):
        runtimes=json.loads(as_agent("multica","--workspace-id",ws["id"],"runtime","list","--output","json",capture_output=True,text=True).stdout)
        rt=next((r for r in runtimes if r["provider"]=="codex" and r["status"]=="online"),None)
        if rt: break
        time.sleep(2)
    else: raise RuntimeError("Guest administrator runtime did not register.")
    common=["multica","--workspace-id",ws["id"]]
    agents=json.loads(as_agent(*common,"agent","list","--output","json",capture_output=True,text=True).stdout)
    if not any(a["name"]==NAME for a in agents):
        as_agent(*common,"agent","create","--name",NAME,"--runtime-id",rt["id"],"--model",guest.SETTINGS["worker_model"],
                 "--max-concurrent-tasks","1","--visibility","private","--instructions","Perform only the VM administration work explicitly assigned by the operator.")
    print("Administrator runtime is online for at most one hour. Use the owner-only UI on port 43230.")


if __name__=="__main__": main()
