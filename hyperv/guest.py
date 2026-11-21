"""Install the private Multica control plane and provider-specific daemons in Ubuntu."""
import json
import argparse
import os
from pathlib import Path
import re
import secrets
import subprocess
import sys
import tempfile
import time
import urllib.request
import urllib.error
from share import configure as configure_share
from dashboard_ports import PORTS

ROOT = Path(__file__).resolve().parents[1]
STATE = Path("/var/lib/multica-local")
PROVIDERS = ("codex", "claude", "agy")
PORT = 43130


def load_settings(state):
    settings = json.loads((ROOT / "config/settings.json").read_text())
    pins_path = state / "release-pins.json"
    if not pins_path.exists():
        if (state / "compose.json").exists():
            return settings  # Existing installation from before the release updater.
        pins_path = ROOT / "hyperv/initial-release.json"
    pins = json.loads(pins_path.read_text())
    settings["upstream_commit"] = pins["commit"]
    settings["images"].update({key: pins[key] for key in ("backend", "frontend")})
    return settings


SETTINGS = load_settings(STATE)


def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)


def dc(*args, **kwargs):
    return run("docker", "compose", "-p", "multica-vm", "-f", str(STATE / "compose.json"), *args, **kwargs)


def api(path, token=None, body=None, base="http://127.0.0.1:43131"):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(base + path,
                                data=None if body is None else json.dumps(body).encode(), headers=headers)
    with urllib.request.urlopen(req, timeout=20) as response:
        return json.loads(response.read() or b"null")


def credentials(*, initial_email=None, initial_code=None):
    path = STATE / "credentials.json"
    code = SETTINGS["vm_default_login_code"] if initial_code is None else initial_code
    if not re.fullmatch(r"[0-9]{6}", code):
        raise ValueError("The dashboard verification code must be six digits.")
    if not path.exists():
        temp = path.with_suffix(".new")
        new = {"password": secrets.token_hex(32), "jwt": secrets.token_hex(48),
               "code": code}
        if initial_email is not None:
            new["email"] = initial_email
        temp.write_text(json.dumps(new))
        temp.replace(path)
    saved = json.loads(path.read_text())
    if initial_code is not None and saved["code"] != initial_code:
        raise ValueError("This VM already has a dashboard code. Omit the initial-code option to keep it.")
    return saved


def kvm_group():
    import fcntl

    # The device group on the Ubuntu guest can differ from Debian's kvm group.
    cpu = Path("/proc/cpuinfo").read_text()
    driver = "kvm_amd" if "AuthenticAMD" in cpu else "kvm_intel"
    run("modprobe", driver)
    run("udevadm", "settle", "--timeout=15")
    device = Path("/dev/kvm")
    if not device.is_char_device():
        raise RuntimeError("Hyper-V nesting was requested but Ubuntu has no /dev/kvm. Check the host settings.")
    with device.open("rb+", buffering=0) as fd:
        if fcntl.ioctl(fd, 0xAE00) != 12:  # KVM_GET_API_VERSION
            raise RuntimeError("Unexpected KVM API version")
    Path("/etc/modules-load.d/multica-kvm.conf").write_text(driver + "\n")
    return str(device.stat().st_gid)


def render(creds, kvm_gid=None):
    images = SETTINGS["images"]
    database = {"image": images["postgres"], "environment": {"POSTGRES_DB": "multica",
                "POSTGRES_USER": "multica", "POSTGRES_PASSWORD": creds["password"]},
                "volumes": ["database:/var/lib/postgresql/data"], "networks": ["database"],
                "healthcheck": {"test": ["CMD", "pg_isready", "-U", "multica"], "interval": "5s", "timeout": "5s", "retries": 30}}
    ui = f"http://localhost:{PORTS['daily']}"
    backend = {"image": images["backend"], "depends_on": {"postgres": {"condition": "service_healthy"}},
               "ports": ["127.0.0.1:43131:8080"], "networks": ["database","web",*PROVIDERS],
               "volumes": ["uploads:/app/data/uploads"], "environment": {
               "DATABASE_URL": "postgres://multica:" + creds["password"] + "@postgres:5432/multica?sslmode=disable",
               "JWT_SECRET": creds["jwt"], "PORT":"8080","APP_ENV":"development",
               "AUTH_TOKEN_TTL":SETTINGS["auth"]["token_ttl"],"MULTICA_DEV_VERIFICATION_CODE":creds["code"],
               "ALLOWED_EMAILS":creds.get("email", SETTINGS["email"]),"ALLOW_SIGNUP":"true","DO_NOT_TRACK":"1",
               "ANALYTICS_DISABLED":"true",
               "MULTICA_APP_URL":ui,"FRONTEND_ORIGIN":ui,"CORS_ALLOWED_ORIGINS":ui}}
    frontend = {"image":images["frontend"], "networks":["web"], "ports":[f"127.0.0.1:{PORT}:3000"],
                "environment":{"REMOTE_API_URL":"http://backend:8080","HOSTNAME":"0.0.0.0","NEXT_PUBLIC_API_URL":"","NEXT_PUBLIC_WS_URL":""}}
    services={"postgres":database,"backend":backend,"frontend":frontend}
    volumes={"database":{},"uploads":{}}
    for provider in PROVIDERS:
        home = f"{provider}-home"
        volumes[home]={}
        mounts=[f"{home}:/home/worker"]
        for name, readonly in (("input",True),("exchange",False)):
            mounts.append({"type":"bind","source":f"/srv/multica/project/{name}","target":f"/project/{name}",
                           "read_only":readonly,"bind":{"create_host_path":False}})
        services[provider]={"image":f"multica-local/{provider}:vm","init":True,"hostname":"multica-"+provider,
            "shm_size":"512m","security_opt":["seccomp="+str(ROOT/"linux-worker/browser-seccomp.json")],
            "networks":[provider],"volumes":mounts,"environment":{"MULTICA_SERVER_URL":"http://backend:8080",
            "MULTICA_DAEMON_AUTO_RELOAD":"0","MULTICA_DAEMON_AUTO_UPDATE":"0",
            "MULTICA_CODEX_ARGS":'-c approval_policy="never" -c sandbox_mode="danger-full-access"',
            "MULTICA_ANTIGRAVITY_MODEL":"gemini-3.8-flash-low"},
            "entrypoint":["/bin/sh","-ec","while [ ! -e /home/worker/.multica/enrolled ]; do sleep 2; done; exec multica daemon start --foreground --no-auto-update --no-auto-reload"]}
        if kvm_gid is not None:
            services[provider]["devices"] = ["/dev/kvm:/dev/kvm:rw"]
            services[provider]["group_add"] = [kvm_gid]
    for service in services.values():
        service["restart"]="unless-stopped"
    networks={key:{} for key in ["web",*PROVIDERS]}
    networks["database"]={"internal":True}
    return {"services":services,"volumes":volumes,"networks":networks}


def cli(provider, *args, **kwargs):
    return dc("exec","-T",provider,"multica",*args,**kwargs)


def set_owner_prompt_defaults(project, state, email):
    sql = (ROOT / "hyperv/owner-prompt-defaults.sql").read_text()
    run("docker", "compose", "-p", project, "-f", str(state / "compose.json"),
        "exec", "-T", "postgres", "psql", "-Xq", "-U", "multica", "-d", "multica",
        "-v", "ON_ERROR_STOP=1", "-v", "owner_email=" + email, "-f", "-", input=sql, text=True)


def enroll(creds):
    email=creds.get("email", SETTINGS["email"])
    for i in range(90):
        try:
            api("/auth/send-code",body={"email":email})
            break
        except (OSError,TimeoutError):
            if i == 89: raise
            time.sleep(2)
    token=api("/auth/verify-code",body={"email":email,"code":creds["code"]})["token"]
    slug=SETTINGS["workspace"]["slug"]
    workspace=next((w for w in api("/api/workspaces",token) if w["slug"]==slug),None)
    if workspace is None:
        workspace=api("/api/workspaces",token,{"name":"Local Work","slug":slug,"issue_prefix":"LOCAL",
                                              "context":"Delegate work across Linux project workers and verify artifacts."})
    if not api("/api/me",token).get("onboarded_at"):
        api("/api/me/onboarding/complete",token,{"completion_path":"skip_existing","workspace_id":workspace["id"]})
    set_owner_prompt_defaults("multica-vm", STATE, email)
    for provider in PROVIDERS:
        if dc_probe(provider): continue
        pat=api("/api/tokens/",token,{"name":f"VM {provider} daemon","expires_in_days":90})["token"]
        cli(provider,"config","set","server_url","http://backend:8080")
        cli(provider,"login","--token",input=pat+"\n",text=True,stdout=subprocess.DEVNULL)
        cli(provider,"workspace","switch",workspace["id"])
        dc("exec","-T",provider,"touch","/home/worker/.multica/enrolled")
    return workspace["id"]


def dc_probe(provider):
    return subprocess.run(["docker","compose","-p","multica-vm","-f",str(STATE/"compose.json"),
                           "exec","-T",provider,"sh","-ec","test -e ~/.multica/enrolled && multica workspace list >/dev/null"],
                          stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0


def create_team(workspace):
    def command(*args):
        return json.loads(cli("codex","--workspace-id",workspace,*args,"--output","json",capture_output=True,text=True).stdout)
    roles=json.loads((ROOT/"config/roles.json").read_text())
    contract=(ROOT/"coordination-local.txt").read_text()
    services={"codex":"codex", "claude":"claude", "antigravity":"agy"}
    for _ in range(90):
        # Multiple machines can advertise Codex. Bind a new default role to its intended daemon.
        machines={}
        for provider, service in services.items():
            try:
                machines[provider]=json.loads(cli(service,"daemon","status","--output","json",
                                                  capture_output=True,text=True).stdout).get("daemon_id")
            except subprocess.CalledProcessError:
                pass  # The freshly enrolled daemon may still be starting.
        runtimes={r["provider"]:r["id"] for r in command("runtime","list") if r["status"]=="online"
                  and r["daemon_id"] and r["daemon_id"]==machines.get(r["provider"]) and not r.get("profile_id")}
        if services.keys() <= runtimes.keys(): break
        time.sleep(2)
    missing=services.keys()-runtimes.keys()
    if missing: raise RuntimeError("Missing online runtimes: "+", ".join(sorted(missing)))
    agents={a["name"]:a for a in command("agent","list")}
    team={}
    for name in [*roles,"Claude Worker","Agy Flash Worker"]:
        provider={"Claude Worker":"claude","Agy Flash Worker":"antigravity"}.get(name,"codex")
        model={"claude":"claude-haiku-4-5","antigravity":"gemini-3.8-flash-low"}.get(provider,
               SETTINGS["worker_model"] if name in ("Builder","Researcher") else SETTINGS["lead_model"])
        if name not in agents:
            opts=["--name",name,"--runtime-id",runtimes[provider],"--model",model,"--max-concurrent-tasks","1",
                  "--visibility","private","--instructions",contract+"\n"+roles.get(name,"Complete and verify the assigned project task.")]
            if provider=="codex":
                opts+=["--thinking-level",SETTINGS["worker_effort"] if name in ("Builder","Researcher") else SETTINGS["lead_effort"]]
            agents[name]=command("agent","create",*opts)
        team[name]=agents[name]["id"]
    directory="\nTeam directory: "+", ".join(f"{name}: {uid}" for name,uid in team.items())
    for name in ("Mika","Code Lead","Research Lead"):
        current=command("agent","get",team[name]).get("instructions","")
        if directory not in current:
            command("agent","update",team[name],"--instructions",current+directory)
    (STATE/"team.json").write_text(json.dumps(team))


def provision(kvm=False, initial_code=None):
    os.umask(0o077)
    STATE.mkdir(mode=0o700,exist_ok=True)
    pins_path = STATE / "release-pins.json"
    if not pins_path.exists():
        pins = {"commit": SETTINGS["upstream_commit"],
                **{key: SETTINGS["images"][key] for key in ("backend", "frontend")}}
        with tempfile.NamedTemporaryFile(mode="w", dir=STATE, delete=False) as fp:
            json.dump(pins, fp)
        os.replace(fp.name, pins_path)
    creds=credentials(initial_email=SETTINGS["vm_login_email"], initial_code=initial_code)
    Path("/etc/apt/apt.conf.d/52multica-local-updates").write_text(
        'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";\n'
        'Unattended-Upgrade::Automatic-Reboot "true";\nUnattended-Upgrade::Automatic-Reboot-Time "04:00";\n')
    run("systemctl","enable","--now","apt-daily.timer","apt-daily-upgrade.timer")
    paths=Path("/srv/multica/project")
    paths.mkdir(parents=True,exist_ok=True)
    for parent in [paths.parent,paths]:
        parent.chmod(0o755)
    for name in ("input","exchange"):
        folder=paths/name
        if not folder.exists():
            folder.mkdir()
            os.chown(folder,1000,1000)
            folder.chmod(0o755 if name=="input" else 0o775)
    configure_share(STATE)
    gid = kvm_group() if kvm else None
    if not kvm:
        Path("/etc/modules-load.d/multica-kvm.conf").unlink(missing_ok=True)
    (STATE/"compose.json").write_text(json.dumps(render(creds, gid)))
    dc("up","-d","postgres","backend","frontend")
    run("docker","build","-t","multica-local/worker-tools:bookworm",str(ROOT/"linux-worker"))
    for provider in PROVIDERS:
        run("docker","build","-f",str(ROOT/"hyperv/provider.Dockerfile"),"--target",provider,
            "--build-arg","MULTICA_REV="+SETTINGS["upstream_commit"],"-t",f"multica-local/{provider}:vm",str(ROOT/"hyperv"))
    dc("up","-d")
    workspace=enroll(creds)
    (STATE/"workspace").write_text(workspace)
    create_team(workspace)


if __name__=="__main__":
    if os.geteuid()!=0: sys.exit("Run the guest provisioner with sudo.")
    parser = argparse.ArgumentParser()
    parser.add_argument("--kvm", choices=("on","off"), default="off")
    parser.add_argument("--initial-code-stdin", action="store_true")
    args = parser.parse_args()
    provision(kvm=args.kvm == "on", initial_code=sys.stdin.readline().rstrip("\r\n") if args.initial_code_stdin else None)
