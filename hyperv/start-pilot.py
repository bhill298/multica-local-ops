"""Dispatch one real delegated reboot pilot in the dedicated VM."""
import json
import os
from pathlib import Path
import shutil
import uuid

import guest

state=guest.STATE/"active-pilot.json"
if state.exists(): raise SystemExit("An existing pilot is recorded. Inspect active-pilot.json before starting another.")
wid=(guest.STATE/"workspace").read_text().strip()
team=json.loads((guest.STATE/"team.json").read_text())
tag="reboot-"+uuid.uuid4().hex[:12]
project=Path("/srv/multica/project")
folder=project/"exchange"/tag
folder.mkdir()
os.chown(folder,1000,1000)
(folder/"initial-boot").write_text(Path("/proc/sys/kernel/random/boot_id").read_text())
script=tag+".py"
shutil.copyfile(Path(__file__).with_name("checkpoint-writer.py"),project/"input"/script)
command=f"python3 /project/input/{script} /project/exchange/{tag}"
description=(f"Prove recovery across a physical reboot. Delegate a child issue to Builder to run exactly: {command} . "
    "The program intentionally keeps writing every two seconds until an operator reboots Windows. Allow it to keep running. "
    "A new attempt must run the same program after interruption. Do not fabricate records, modify the fixture, or replace the boot. "
    "Check actual runs before retrying. A live writer or a file lock means leave it alone. "
    "Delegate independent verification to Reviewer with the same command followed by --verify. Only accept when it returns exit 0 and complete true. "
    "Then close this root and its obsolete wakeups. A finite independent root timer is already registered.")


def cli(*args):
    return json.loads(guest.cli("codex","--workspace-id",wid,*args,"--output","json",capture_output=True,text=True).stdout)


issue=cli("issue","create","--assignee-id",team["Mika"],"--status","backlog","--title","Verify unattended VM reboot recovery "+tag,"--description",description)
record={"issue":issue["id"],"identifier":issue["identifier"],"tag":tag}
state.write_text(json.dumps(record))
guard=cli("issue","wakeup","create",issue["id"],"--kind","every","--every","2m","--max-fires","90","--expires-in","3h",
          "--agent-id",team["Mika"],"--instruction","Reconcile this root and its child executions. Resume the interrupted writer once after reboot. Require successful independent verification; close when done.")
guest.cli("codex","--workspace-id",wid,"issue","update",issue["id"],"--status","todo","--no-start")
run=cli("issue","rerun",issue["id"])
record.update({"guard":guard["id"],"run":run["id"]})
state.write_text(json.dumps(record))
print(json.dumps(record))
