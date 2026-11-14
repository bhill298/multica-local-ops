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
  "workspaces_root": "C:/absolute/path/to/test/workspaces",
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
`workspace-write`, network enabled. Reading is not confined to the project.
This is a write boundary, not isolation from all user-readable data.

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
The workspaces path is deliberately explicit; keep that directory while using
the selected pilot. This installer does not stop active work or disable other
supervisors; do that as a deliberate transition after checking the daemon is idle.
Do not run competing supervisors with different policies on the same profile.

## Coordination and recovery scope

`coordination-v5-never.txt` retains v5's explicit dispatch receipts, actual-run
watches, acceptance ownership, monotonic Done, backlog reviews, directory-lock
handoff and finite independent root backstop. Its permission guidance now matches
never-ask operation. Apply these instructions and project-specific boundaries to
fresh leads; worker prompts need their corresponding narrow responsibilities.

Recovery creates a fresh attempt using saved outputs and native wakeups. It does
not promise the original execution resumes. Business decision issues are distinct
from command/file permissions. A finite pilot backstop is not an indefinite
service-level guarantee. Docker Desktop's local backend and this interactive-user
supervisor require Windows sign-in; pre-login recovery has not been established.
No auto-login or machine security changes are part of this setup.

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
