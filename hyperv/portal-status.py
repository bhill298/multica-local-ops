"""Report only operational fields from the two guest workspaces."""
import json
import subprocess
import sys


def output(*args):
    return subprocess.check_output(args, text=True, timeout=12).strip()


admin_cli = ["runuser", "-u", "multica-vm-admin", "--", "env",
             "MULTICA_SERVER_URL=http://127.0.0.1:43231", "/opt/multica-owner-bin/multica"]
projects = [("Daily", "multica-vm", ["docker", "exec", "multica-vm-codex-1", "multica"]),
            ("Admin", "multica-owner-only", admin_cli)]
result = {"agents": [], "workers": [], "containers": [], "services": [], "errors": []}


def report_containers(label):
    try:
        lines = output("docker", "ps", "-a", "--filter", "label=" + label, "--format", "{{json .}}")
        for row in map(json.loads, lines.splitlines()):
            result["containers"].append(dict(name=row["Names"], image=row["Image"], status=row["Status"]))
    except (subprocess.SubprocessError, ValueError, KeyError):
        result["errors"].append(f"Container status unavailable for {label}.")


for workspace, project, cli in projects:
    if sys.argv[1:] == ["idle"]:
        try:
            count = output("docker", "exec", project + "-postgres-1", "psql", "-U", "multica", "-d", "multica",
                           "-Atc", "SELECT count(*) FROM agent_task_queue WHERE status NOT IN ('completed','failed','cancelled')")
        except subprocess.SubprocessError as error:
            sys.exit(f"{workspace} idle check failed: could not query {project}-postgres-1 ({error}).")
        if count != "0":
            sys.exit(f"{workspace} has {count} unfinished jobs.")
        continue
    report_containers("com.docker.compose.project=" + project)
    runtimes = {}
    try:
        rows = json.loads(output(*cli, "runtime", "list", "--output", "json"))
        for item in rows:
            name = item.get("custom_name") or item.get("name") or item["provider"]
            runtimes[item["id"]] = name
            result["workers"].append(dict(workspace=workspace, name=name, provider=item["provider"], status=item["status"]))
    except (subprocess.SubprocessError, ValueError, KeyError):
        result["errors"].append(f"{workspace} runtime registration is unavailable.")
    try:
        for agent in json.loads(output(*cli, "agent", "list", "--output", "json")):
            if not agent.get("archived_at"):
                result["agents"].append(dict(workspace=workspace, name=agent["name"], status=agent["status"],
                                             runtime=runtimes.get(agent.get("runtime_id"), "Unresolved")))
    except (subprocess.SubprocessError, ValueError, KeyError):
        result["errors"].append(f"{workspace} agent list is unavailable.")
if sys.argv[1:] != ["idle"]:
    report_containers("local.multica.extra-worker")
    unit = "multica-vm-admin.service"
    try:
        lines = output("systemctl", "show", unit, "-p", "ActiveState", "-p", "SubState", "-p", "UnitFileState")
        state = dict(line.split("=", 1) for line in lines.splitlines())
        result["services"].append(dict(unit=unit, state=state["ActiveState"], substate=state["SubState"],
                                       startup=state["UnitFileState"]))
    except (subprocess.SubprocessError, ValueError, KeyError):
        result["errors"].append(f"Systemd status unavailable for {unit}.")
    print(json.dumps(result))
