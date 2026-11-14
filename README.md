# Local Multica operations

Small, separately versioned Windows operations for an **unmodified** Multica CLI.
This repository imports no Multica packages and contains no approval broker.
The selected application source is pinned at
`dbdbb299164347586e2650bb67684a490726a798` (0.7.0 baseline).
The current locally compiled executable reports `dev`; provenance records its
source commit and binary SHA-256. It uses the normal console subsystem, as does
upstream's release build recipe. It is not a patched Multica executable.

## Configuration

The supervisor accepts one JSON configuration file:

```json
{
  "cli": "C:/absolute/path/to/multica.exe",
  "profile": "orchestration-trial-20261024",
  "workspaces_root": "C:/Users/brennan/.multica/workspaces-local",
  "codex_args": "-c approval_policy=\"never\" -c windows.sandbox=\"mxc\" -c features.exec_permission_approvals=false -c features.request_permissions_tool=false",
  "log_dir": "C:/absolute/path/to/logs"
}
```

Multica forwards `MULTICA_CODEX_ARGS` to the Codex app-server. Agent custom
arguments come later and can override machine defaults: trusted operator
configuration must not add conflicting approval/sandbox flags. `never` prevents
approval requests; it is not a filesystem permission grant. Native Windows MXC
must remain explicit because this Multica version otherwise defaults to full
access on Windows. The tested effective session policy is `never` with
`workspace-write`, network enabled, with the standard temporary-directory writes
permitted. Reading is not confined to the project.
This is a write boundary, not isolation from all user-readable data. These policy
checks cover Codex workers; they do not establish equivalent Claude/Agy settings.

Known extra writes should be scoped in the agent's custom arguments. Example:

```json
["-c", "sandbox_workspace_write.writable_roots=[\"C:/exact/extra/folder\",\"C:/exact/repository/.git\"]"]
```

Preconfigured extra-folder and Git writes and outside-folder denials were tested.
Dynamic permission requests are disabled. An unexpected required write stays
blocked for an owner to configure, while independent work should continue.
Stock Multica's approval callback still auto-accepts requests if one reaches it;
do not change to an asking policy while assuming there is an owner review queue.
The configuration is not a replacement for the separate permissions of host MCP
tools. Only separately authorized, bounded capabilities should be exposed there.

## Windows process behavior

The scheduled supervisor runs once per minute and at the current user's sign-in.
It checks structured `daemon status --output json`. A healthy daemon is untouched.
On absence it starts `daemon start --foreground` in a new **hidden** console.
It does not forcibly kill a live daemon whose health endpoint is unresponsive.
Children can inherit that console. Background detached launches and
`CREATE_NO_WINDOW` alone can leave console-less helpers which create visible
consoles for grandchildren. The supervisor's own build uses `-H=windowsgui`.
No focus changes, input injection or desktop takeover are needed.

The launcher attempts to escape the scheduler's Job Object, with the same
access-denied fallback pattern as upstream. If a host forbids breakaway, the
daemon can depend on the parent Job Object's lifetime. Actual scheduled restart
and checkpoint recovery passed on this machine; a restrictive different host
needs its own check. Multica's profile lock prevents concurrent daemon ownership.

Supervisor events append rather than truncate; a file exceeding 4 MiB is
archived on its next open. Multica manages its own daemon log separately.
The console sink is normally empty on the tested build. Existing archives are
not silently deleted. The supervisor removes legacy broker environment entries
from its child; it does not read or copy provider credentials.

```powershell
go test ./...
go vet ./...
go build -ldflags=-H=windowsgui -o supervisor.exe .
```

`install.ps1 -CandidateRoot <absolute-test-root>` copies reviewed binaries to
`~/.multica/stock-runtime/bin`, stores nonsecret configuration under
`~/.multica/local-ops`, and registers `Multica Local Supervisor` without elevation.
The selected workspaces path is `~/.multica/workspaces-local`, outside the
disposable trial. Keep that directory while using the workspace. This installer
does not stop active work or disable other supervisors; do that as a deliberate transition after checking the daemon is idle.
Do not run competing supervisors with different policies on the same profile.

## Coordination and recovery scope

`coordination-local.txt` is the current daily contract. It adds source-grounded
review adjudication, a bounded no-progress rule, and explicit project metadata
binding for every lead/worker/reviewer issue. A folder named in a description is
not an attached execution directory. Create children in backlog, verify their
returned `project_id`, then dispatch.

`coordination-v5-never.txt` preserves the two-hour test contract. It retains v5's
explicit dispatch receipts, actual-run watches, acceptance ownership, monotonic Done, backlog reviews, directory-lock
handoff and finite independent root backstop. Its permission guidance now matches
never-ask operation. Apply these instructions and project-specific boundaries to
fresh leads; worker prompts need their corresponding narrow responsibilities.

Recovery creates a fresh attempt using saved outputs and native wakeups. It does
not promise the original execution resumes. Business decision issues are distinct
from command/file permissions. A finite pilot backstop is not an indefinite
service-level guarantee. Docker Desktop's local backend and this interactive-user
supervisor require Windows sign-in; pre-login recovery has not been established.
No auto-login or machine security changes are part of this setup.

## Selected workspace and session lifecycle

Open [Local Work](http://localhost:43130/local-work/chat). This is a fresh
workspace on the existing local account, using existing provider authentication.
Mika, the two project leads and Reviewer use `gpt-6.1-sol` with medium effort;
Builder and Researcher use `gpt-6-luna` with low effort, capacity one per actor.
The long test used six Luna/low actors. The newer mixed-model readiness check
closed all four issues in 8m41s without a corrective prompt, rejected a false
review finding and preserved the source/brief hashes. It is not another two-hour mixed-model benchmark.

**Defaults are not retroactive.** A native wakeup resumes the provider session
and can retain its previous approval policy and additional directory grants.
Normal CLI defaults alone did not migrate an old asking session to never.
Even explicit protocol sandbox overrides did not revoke old extra-directory
grants. This is why the selected setup uses fresh contexts rather than a resume
patch. For permission narrowing or unrelated project changes, use a fresh chat
or agent; an explicit issue rerun also created a fresh provider thread in the
tested version. Do not rely on a wakeup to reset permissions.

The old workspace is retained as history. Its 61 custom agents are archived;
stock Multica refuses to archive its built-in Mika, which instead has a retirement
instruction directing new work here. That instruction is not a hard technical
execution block. Do not resume old chats or dispatch in the historical workspace.
The default profile selects Local Work; old files, issues and rollback credentials
were not deleted or copied.

Start real work by giving Mika an outcome and the authorized project folder.
Attach that folder to a project before worker dispatch. Use `in_place` by default.
The worktree smoke required both the repository `.git` and the exact
`.git/worktrees/worktree` administration directory as pregranted writable roots;
the parent `.git` grant alone was insufficient on this machine. After changing
grants, start a fresh attempt. Do not pregrant an entire drive to avoid this setup.

No owner approval broker is running. Unexpected command/file permission needs
remain blocked under never-ask; configure narrow permissions deliberately and
retry with a fresh context. Business decisions remain ordinary tracked issues.
Known reviewed host tools have separate permissions: the tested no-argument
Office capability could create and verify its own hidden Word/Excel/PDF outputs
without input injection. It does not establish arbitrary desktop application
control, and no host MCP tool is globally exposed to all daily agents by default.

## Evidence and rollback

The trial evidence is in the sibling `multica-minimal-2026-11-14` directory.
Read its final `RESULT.md` for the actual long-pilot outcome and limitations.
The original fork, approval broker files/private state and historical patch ZIP
are retained for rollback. Never delete or print their credentials.
The original task is `Multica Local Pilot Supervisor`; the replacement is
`Multica Local Supervisor`. The original installed CLI is under
`~/.multica/local-runtime/bin`, separate from the stock CLI.

To roll back, stop active test work safely, disable the new scheduled task, stop
its daemon using the selected profile, enable the original scheduled task and
start it. The original supervisor supplies the broker environment and restarts
the fork. Do not run the fork manually without its original policy environment.
Nothing in this repository pushes or removes the preserved application source.
