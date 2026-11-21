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
result = {"workers": [], "containers": [], "errors": []}
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
    lines = output("docker", "ps", "-a", "--filter", "label=com.docker.compose.project=" + project,
                   "--format", "{{json .}}")
    for row in map(json.loads, lines.splitlines()):
        result["containers"].append(dict(name=row["Names"], image=row["Image"], status=row["Status"]))
    try:
        rows = json.loads(output(*cli, "runtime", "list", "--output", "json"))
        for item in rows:
            result["workers"].append(dict(workspace=workspace, provider=item["provider"], status=item["status"]))
    except (subprocess.SubprocessError, ValueError, KeyError):
        result["errors"].append(f"{workspace} runtime registration is unavailable.")
if sys.argv[1:] != ["idle"]:
    print(json.dumps(result))
