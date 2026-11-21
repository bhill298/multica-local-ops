"""Provision the guest administrator and its independent Multica queue."""
import filecmp
import json
from getpass import getpass
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

import guest
import admin_provider as provider_tools

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


def write_atomic(path, text):
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as f:
        f.write(text)
    os.replace(f.name, path)


def require_idle():
    sql="SELECT count(*) FROM agent_task_queue WHERE status NOT IN ('completed','failed','cancelled')"
    count=subprocess.check_output(["docker","compose","-p","multica-owner-only","-f",str(STATE/"compose.json"),
                                   "exec","-T","postgres","psql","-U","multica","-d","multica","-Atc",sql],text=True)
    if count.strip()!="0":
        raise RuntimeError("Finish pending VM admin work before switching providers.")


def bind_admin(workspace, provider, model):
    def cli(*args):
        return json.loads(as_agent("multica","--workspace-id",workspace,*args,"--output","json",
                                   capture_output=True,text=True).stdout)
    for _ in range(60):
        try:
            daemon_id=cli("daemon","status").get("daemon_id")
            if daemon_id:
                runtime=next((r for r in cli("runtime","list") if r["daemon_id"]==daemon_id
                              and r["provider"]==provider_tools.PROVIDERS[provider] and r["status"]=="online"),None)
                if runtime: break
        except subprocess.CalledProcessError:
            pass  # The local daemon is still starting.
        time.sleep(2)
    else: raise RuntimeError(f"The admin daemon did not register an online {provider} runtime.")
    marker=STATE/"admin-agent-id"
    if marker.exists():
        agent=cli("agent","get",marker.read_text().strip())
    else:
        agent=next((a for a in cli("agent","list") if a["name"] in (NAME,OLD_NAME)),None)
    target=["--runtime-id",runtime["id"],"--model",model]
    if agent is None:
        agent=cli("agent","create","--name",NAME,*target,"--max-concurrent-tasks","1",
                  "--visibility","private","--instructions",INSTRUCTIONS)
    else:
        changes=target if (agent["runtime_id"],agent["model"])!=(runtime["id"],model) else []
        if agent["name"]==OLD_NAME:
            changes+=["--name",NAME,"--instructions",INSTRUCTIONS]
        if changes:
            require_idle()
            cli("agent","update",agent["id"],*changes)
    if not marker.exists():
        write_atomic(marker,agent["id"]+"\n")


def main():
    import pwd
    os.umask(0o077)
    STATE.mkdir(mode=0o700,exist_ok=True)
    guest.STATE=STATE
    requested=json.load(sys.stdin) if any(flag in sys.argv for flag in ("--select-stdin","--setup-stdin")) else {}
    setup_code=requested.pop("initial_code",None)
    reset=requested.pop("use_install_defaults",False)
    if reset and requested:
        raise ValueError("Choose install defaults or an explicit provider/model.")
    explicit=bool(requested) or reset
    provider,model=(provider_tools.selection(guest.SETTINGS["admin_provider"]) if reset
                    else provider_tools.selection(**requested))
    if "--select-stdin" in sys.argv and (STATE/"admin-agent-id").exists() and subprocess.run(
            ["systemctl","is-active","--quiet","multica-vm-admin.service"]).returncode==0:
        require_idle()
        spaces=json.loads(as_agent("multica","workspace","list","--output","json",capture_output=True,text=True).stdout)
        workspace=next(w for w in spaces if w["slug"]=="vm-administration")
        configure_runtime(workspace["id"],provider,model,explicit,reset)
        return
    initial_code = getpass("Initial admin dashboard code (six digits): ") if "--prompt-for-login-code" in sys.argv else setup_code
    if "--initial-code-stdin" in sys.argv:
        initial_code=sys.stdin.readline().rstrip("\r\n")
    creds=guest.credentials(initial_email=guest.SETTINGS["vm_admin_login_email"], initial_code=initial_code)
    data=guest.render(creds)
    for daily_provider in guest.PROVIDERS:
        del data["services"][daily_provider],data["networks"][daily_provider],data["volumes"][daily_provider+"-home"]
    backend=data["services"]["backend"]
    backend["networks"]=["database","web"]
    backend["ports"]=["127.0.0.1:43231:8080"]
    for name in ["MULTICA_APP_URL","FRONTEND_ORIGIN","CORS_ALLOWED_ORIGINS"]:
        backend["environment"][name]=f"http://127.0.0.1:{guest.PORTS['admin']}"
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
        provider_tools.login(provider,model)
        return
    configure_runtime(ws["id"],provider,model,explicit,reset)
    # Reload the link destinations when an existing installation changes ports.
    guest.run("systemctl","restart","multica-dashboard-home.service")


def configure_runtime(workspace, provider, model, explicit, reset):
    if subprocess.run(["systemctl","is-active","--quiet","multica-manual-admin.service"]).returncode == 0:
        guest.run("systemctl","stop","multica-manual-admin.service")
    for unit in ("multica-vm-admin.service","multica-dashboard-home.service"):
        guest.run("install","-m","0644",str(guest.ROOT/"hyperv"/unit),"/etc/systemd/system/"+unit)
    guest.run("systemctl","daemon-reload")
    unit="multica-vm-admin.service"
    pid=subprocess.check_output(["systemctl","show",unit,"--property=MainPID","--value"],text=True).strip()
    try:
        reconnect = pid.isdigit() and int(pid) != 0 and not filecmp.cmp(f"/proc/{pid}/exe",BIN/"multica",shallow=False)
    except FileNotFoundError:
        # The old process exited during inspection. The service will start the installed binary.
        reconnect = False
    provider_tools.install_tool(provider)
    envfile=STATE/"admin-runtime.env"
    previous=envfile.read_text() if envfile.exists() else None
    desired=f"PATH={provider_tools.tool_dir(provider)}:/usr/bin:/bin\n"
    if previous!=desired or reconnect or explicit:
        require_idle()
    override=STATE/"admin-provider.json"
    old_override=override.read_text() if override.exists() else None
    try:
        if reset:
            override.unlink(missing_ok=True)
        elif explicit:
            write_atomic(override,json.dumps({"provider":provider,"model":model}))
        if previous!=desired:
            write_atomic(envfile,desired)
        if int(pid or 0) and (previous!=desired or reconnect):
            guest.run("systemctl","restart",unit)
        guest.run("systemctl","enable","--now",unit,"multica-dashboard-home.service")
        bind_admin(workspace,provider,model)
    except BaseException:
        if explicit:
            if old_override is None: override.unlink(missing_ok=True)
            else: write_atomic(override,old_override)
        if previous!=desired:
            if previous is None: envfile.unlink(missing_ok=True)
            else: write_atomic(envfile,previous)
            if int(pid or 0): guest.run("systemctl","restart",unit)
        raise
    print(f"VM administrator online using {provider} / {model}. Open http://localhost:{guest.PORTS['home']}/admin on Windows.")


if __name__=="__main__":
    import fcntl
    STATE.mkdir(mode=0o700,exist_ok=True)
    with (STATE/"provision.lock").open("a") as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        main()
