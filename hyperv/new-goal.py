"""Create an operator goal with its recovery timer registered before dispatch."""
import json
import sys

import guest

request=json.load(sys.stdin)
wid=(guest.STATE/"workspace").read_text().strip()
team=json.loads((guest.STATE/"team.json").read_text())


def cli(*args):
    return json.loads(guest.cli("codex","--workspace-id",wid,*args,"--output","json",capture_output=True,text=True).stdout)


project=request.get("project")
args=["--project",project] if project else []
if project: cli("project","get",project)
body=request["outcome"]+"\nA finite root recovery timer is registered. Disable it after verified closure."
issue=cli("issue","create","--title",request["title"],"--assignee-id",team["Mika"],"--status","backlog",
          "--description",body,*args)
guard=guest.SETTINGS["root_guard"]
timer=cli("issue","wakeup","create",issue["id"],"--kind","every","--every",guard["every"],
          "--expires-in",guard["expires_in"],"--max-fires",str(guard["max_fires"]),"--agent-id",team["Mika"],
          "--instruction","Inspect real descendant runs, evidence and reviews. Recover interrupted work. Close the root after acceptance and disable obsolete guards.")
cli("issue","update",issue["id"],"--status","todo","--no-start")
job=cli("issue","rerun",issue["id"])
print(json.dumps({"issue":issue["identifier"],"id":issue["id"],"guard":timer["id"],"run":job["id"]}))
