"""Guest half of update-vm.ps1. Invoked over the operator's SSH connection."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
import urllib.request

ROOT = Path("/opt/multica-local")
STATE = Path("/var/lib/multica-local")
PROVIDERS = ("codex", "claude", "agy")
COMPOSE = ["docker", "compose", "-p", "multica-vm", "-f", str(STATE / "compose.json")]


def output(*args):
    return subprocess.check_output(args, text=True).strip()


def save(path, data):
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as fp:
        json.dump(data, fp, indent=2)
        fp.flush()
        os.fsync(fp.fileno())
    os.replace(fp.name, path)


def current():
    pending = STATE / "update-pending.json"
    if pending.exists():
        backup = json.loads(pending.read_text())["backup"]
        raise RuntimeError(f"An upgrade was interrupted. Inspect the deployment or restore backup {backup}.")
    pins = STATE / "release-pins.json"
    if pins.exists():
        return json.loads(pins.read_text())
    cfg = json.loads((ROOT / "config/settings.json").read_text())
    return {"commit": cfg["upstream_commit"], **{k: cfg["images"][k] for k in ("backend", "frontend")}}


def idle():
    if output("docker", "ps", "-q", "--filter", "label=com.docker.compose.project=multica-owner-only"):
        raise RuntimeError("Close the owner-only admin stack with AdminStop first.")
    if subprocess.run(["systemctl", "is-active", "--quiet", "multica-vm-admin.service"]).returncode == 0:
        raise RuntimeError("The guest administrator is running.")
    sql = "select count(*) from agent_task_queue where status not in ('completed','failed','cancelled')"
    count = output(*COMPOSE, "exec", "-T", "postgres", "psql", "-v", "ON_ERROR_STOP=1",
                   "-U", "multica", "-d", "multica", "-Atc", sql)
    if count != "0":
        raise RuntimeError(f"Daily workspace has {count} unfinished jobs. Finish or cancel them before updating.")


def candidate(provider, commit):
    return f"multica-local/{provider}:update-{commit}"


def check_daemon_command(provider, image):
    command = ["multica", "daemon", "start", "--foreground", "--no-auto-update", "--no-auto-reload", "--help"]
    runner = ["docker", "run", "--rm", "--network", "none", "--entrypoint", "/usr/bin/timeout",
              image, "-k", "2", "15"]
    result = subprocess.run(runner + command, capture_output=True, text=True)
    if result.returncode:
        detail = (result.stderr or result.stdout).strip()[:1500]
        if result.returncode in (124, 137):
            detail = "help did not exit within 15 seconds"
        raise RuntimeError(f"Staging {provider}: {' '.join(command)} exited {result.returncode}: {detail}")
    # A parser that short-circuits on --help would also accept a made-up flag.
    control = subprocess.run(runner + command[:-1] + ["--multica-unsupported-probe", "--help"],
                             capture_output=True, text=True)
    if control.returncode == 0 or control.returncode in (124, 125, 126, 127, 137):
        detail = ("accepted an unknown flag" if control.returncode == 0
                  else f"probe container exited {control.returncode}")
        print(f"Warning: {provider} daemon argument check inconclusive: negative control {detail}.", file=sys.stderr)


def stage(target):
    idle()
    for key in ("backend", "frontend"):
        subprocess.run(["docker", "pull", target[key]], check=True)
    build = (ROOT / "hyperv/provider.Dockerfile").read_text().split("FROM node:", 1)[0]
    if " AS compiler" not in build or "go build" not in build:
        raise RuntimeError("Unsupported compiler stage in installed provider.Dockerfile.")
    with tempfile.TemporaryDirectory() as context:
        for provider in PROVIDERS:
            # Preserve the installed provider CLI and toolbox. Change only Multica.
            source = output("docker", "inspect", "-f", "{{.Image}}", f"multica-vm-{provider}-1")
            base = f"multica-local/{provider}:update-base"
            subprocess.run(["docker", "tag", source, base], check=True)
            dockerfile = build + f"\nFROM {base}\nCOPY --from=compiler /multica /usr/local/bin/multica\n"
            image = candidate(provider, target["commit"])
            subprocess.run(["docker", "build", "--build-arg", "MULTICA_REV=" + target["commit"],
                            "-t", image, "-f", "-", context], input=dockerfile, text=True, check=True)
            try:
                info = json.loads(output("docker", "run", "--rm", "--network", "none", "--entrypoint", "multica",
                                         image, "version", "--output", "json"))
                if not isinstance(info, dict):
                    raise ValueError("expected a JSON object")
            except (ValueError, subprocess.CalledProcessError) as error:
                raise RuntimeError(f"Staging {provider}: multica version --output json failed: {error}") from error
            short_commit = info.get("commit", "")
            if (not re.fullmatch(r"v?\d+\.\d+\.\d+", info.get("version", "")) or
                    not re.fullmatch(r"[a-f0-9]{7,40}", short_commit) or not target["commit"].startswith(short_commit)):
                raise RuntimeError(f"{provider} CLI does not identify the staged Multica release: "
                                   f"expected commit {target['commit']}, got {short_commit!r}, version {info.get('version')!r}.")
            check_daemon_command(provider, image)


def activate(target, backup):
    idle()
    pending = STATE / "update-pending.json"
    save(pending, {"backup": backup, "target": target})
    # Stop intake before the final idle check. If a task raced the first check,
    # resume the original containers without updating the database.
    subprocess.run([*COMPOSE, "stop", "frontend", "backend"], check=True)
    try:
        idle()
    except BaseException:
        subprocess.run([*COMPOSE, "start", "backend", "frontend"], check=True)
        pending.unlink()
        raise
    subprocess.run([*COMPOSE, "stop", *PROVIDERS], check=True)
    cfg_path = ROOT / "config/settings.json"
    cfg = json.loads(cfg_path.read_text())
    compose_path = STATE / "compose.json"
    compose = json.loads(compose_path.read_text())
    cfg["upstream_commit"] = target["commit"]
    for key in ("backend", "frontend"):
        cfg["images"][key] = compose["services"][key]["image"] = target[key]
    for provider in PROVIDERS:
        subprocess.run(["docker", "tag", candidate(provider, target["commit"]),
                        f"multica-local/{provider}:vm"], check=True)
    save(cfg_path, cfg)
    save(compose_path, compose)
    save(STATE / "release-pins.json", target)
    subprocess.run([*COMPOSE, "up", "-d"], check=True)
    workspace = (STATE / "workspace").read_text().strip()
    expected = set(json.loads((STATE / "team.json").read_text()).values())
    failure = "waiting for the daily dashboard"
    for _ in range(90):
        probe = "daily dashboard"
        try:
            with urllib.request.urlopen("http://127.0.0.1:43130", timeout=4) as resp:
                if resp.status != 200:
                    raise ValueError(f"Daily dashboard returned HTTP {resp.status}")
            cli = [*COMPOSE, "exec", "-T", "codex", "multica", "--workspace-id", workspace]
            probe = "daily agent list"
            agents = json.loads(output(*cli, "agent", "list", "--output", "json"))
            missing_agents = expected - {a["id"] for a in agents}
            probe = "daily runtime list"
            runtimes = json.loads(output(*cli, "runtime", "list", "--output", "json"))
            offline = {"codex", "claude", "antigravity"} - {r["provider"] for r in runtimes if r["status"] == "online"}
            if missing_agents or offline:
                raise ValueError(f"Missing saved agent IDs: {sorted(missing_agents)}; missing online providers: {sorted(offline)}")
            for provider in PROVIDERS:
                probe = f"{provider} workspace CLI access"
                output(*COMPOSE, "exec", "-T", provider, "multica", "--workspace-id", workspace,
                       "agent", "list", "--output", "json")
            pending.unlink()
            return
        except (OSError, ValueError, TypeError, KeyError, subprocess.CalledProcessError) as error:
            failure = f"{probe}: {error}"
        time.sleep(2)
    raise RuntimeError(f"Daily verification after activation failed: {failure}. Retained backup: {backup}.")


def main(args):
    if args == ["installed-pins"]:
        pins = current()
        for service in ("backend", "frontend"):
            container = f"multica-vm-{service}-1"
            image = output("docker", "inspect", "-f", "{{if .State.Running}}{{.Config.Image}}{{end}}", container)
            if image != pins[service]:
                raise RuntimeError(f"{container} is stopped or differs from the installed {service} pin.")
        # Older installations may lack a stamped or running worker. The commit
        # and digests are sufficient to promote those releases offline.
        version = {}
        try:
            info = json.loads(output("docker", "exec", "multica-vm-codex-1", "multica", "version", "--output", "json"))
            if isinstance(info, dict):
                tag, revision = str(info.get("version", "")), str(info.get("commit", ""))
                if (re.fullmatch(r"v?\d+\.\d+\.\d+", tag) and re.fullmatch(r"[0-9a-f]{7,40}", revision)
                        and pins["commit"].startswith(revision)):
                    version["version"] = "v" + tag.removeprefix("v")
        except (ValueError, subprocess.CalledProcessError):
            pass
        if current() != pins:
            raise RuntimeError("Installed pins changed during verification. Retry after the update completes.")
        print(json.dumps({**pins, **version}))
        return
    if args == ["status"]:
        print(json.dumps(current()))
        return
    if args == ["idle"]:
        idle()
        return
    action, commit, backend, frontend, *extra = args
    if not all(re.fullmatch(pattern, value) for pattern, value in (
        ("[0-9a-f]{40}", commit),
        ("ghcr\\.io/multica-ai/multica-backend@sha256:[0-9a-f]{64}", backend),
        ("ghcr\\.io/multica-ai/multica-web@sha256:[0-9a-f]{64}", frontend))):
        raise ValueError("Invalid Multica release references")
    target = {"commit": commit, "backend": backend, "frontend": frontend}
    current()  # fail closed if a previous operation stopped partway through
    if action == "stage" and not extra:
        stage(target)
    elif action == "activate" and len(extra) == 1 and re.fullmatch("[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}", extra[0]):
        activate(target, extra[0])
    else:
        raise ValueError("Invalid update operation")


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except Exception as error:
        sys.exit(f"Multica update: {error}")
