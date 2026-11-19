# Operating notes

## Desktop and browser automation

Multica gives agents a workspace and access to their coding runtime's tools.
It has no general desktop-control system configured here. Agents can run commands
or call configured MCP tools. That lets them use libraries such as Selenium or
Playwright when the runtime's permissions allow the browser to run.

We tested Playwright-core 1.65.1 with a fresh headless Microsoft Edge instance.
The worker invoked the supplied script, but Edge exited before page interaction
with a named-pipe error (`TransactNamedPipe`, `0x6D`). The identical script ran
successfully outside the worker: it filled two inputs, clicked Calculate, checked
42 and saved a screenshot. Edge's own sandbox was enabled in both cases. This
points to the worker execution context as the limiting factor; it does not prove
which individual MXC/Windows restriction caused it.

Programmatic browser control is possible on this host, but direct headless Edge
inside this native Codex sandbox is not working in the tested configuration. A
separate browser MCP host/service is an option to investigate. It has not been
integrated into the selected setup. We did not weaken the sandbox or retry with
`--no-sandbox`. Selenium and other browser engines have not been tested here.

To reproduce the host control, use a separate project with Node.js and Edge
installed. Copy `examples/browser-proof.mjs` into it, install
`playwright-core@1.65.1` there with npm, and run `node browser-proof.mjs` from
that project. It writes only its local receipt/screenshot. This optional
diagnostic does not configure an MCP service or a general browser tool.

The Office proof used a separate host MCP tool with one reviewed, no-argument
operation. It created its own hidden Word/Excel documents, verified them and
closed its own application instances. That test did not establish general
automation of arbitrary Office documents or desktop programs. Host tools run
with their own permissions outside the command sandbox; exposing one needs a
separate review of what it permits.

The existing Office fixture is still available in the old local test directory;
it was independent of the source fork. It is not attached to the six daily agents
and is not a general Office driver. Preserve that directory if you want to reuse
it. See [adding tools](tools.md) for how stock Multica accepts per-agent MCP
configuration and which provider paths have been inspected.

## Cost reporting and spending limits

Multica recorded provider/model token usage, and its UI displayed estimated
costs. We did not reconcile those estimates with an invoice. At the inspection,
stored usage rows covered Codex Luna, Sol and Astra models; none contained a
provider-supplied dollar price. A dollar figure derived from a rate table can
differ from the amount paid on an authenticated subscription.

The November 18 Claude and Agy pilots also recorded nonzero token/cache counts.
Their inspected dollar-cost fields were null. The issue aggregate returned zero
cost while identifying the tokens as uncosted. That zero does not mean the work
was free or that Multica calculated the provider bill correctly.

No hard spending cap is configured or validated in this setup. The tests do not
show that Multica will stop at a dollar limit. Some adapters accept provider CLI
budget flags, but those are separate controls and were not exercised here.
The workshop's $75/$90 budget tests checked a planning document's arithmetic;
they were not tests of model spending limits. The eight-hour guard is also
unrelated to monetary budgets.

## Crash recovery

The stock daemon was killed while a worker was writing checkpoints. The external
scheduled supervisor restarted it. The lead used saved outputs to finish the
work without a corrective operator prompt. The saved 26-record prefix survived
unchanged, and all 30 final hash-chain records were independently checked.

This verifies recovery from the tested daemon crash. Interrupted runs were
recorded as failed and recovery used another attempt. An external action can
be repeated if the crash happens between doing it and recording completion, so
tasks should check existing results before repeating a write, booking or message.
Exactly-once external side effects were not established.

The reduced stock setup passed a physical Windows Restart on November 18.
An interrupted writer recovered in a fresh attempt, validated 115 preserved
records and appended 15 more. All 130 chained records and the separately saved
prefix passed independent checks. The lead closed its root and child and removed
obsolete guards without a corrective operator prompt. The user only restarted
Windows, waited at sign-in and signed in.

This setup needs Windows sign-in. Windows logon was recorded about 159 seconds
after boot; the observed container and daemon startups followed logon. Docker
Desktop autostart is enabled and the supervisor task requires an interactive
session. Docker Desktop/engine restarted again during that startup; the cause
was not established, and recovery still completed. This test does not establish
unattended recovery while the machine remains at the sign-in screen. A
hung-but-live daemon is not forcibly killed by the supervisor. The observed
sign-in dependency belongs to this Docker Desktop/user-task installation.

## Git worktrees

A linked worktree has its own checkout folder, but some of its bookkeeping lives
in the original repository's `.git/worktrees/<name>` directory. Git needs to
write an index lock there when making a commit.

In the real test, allowing the main `.git` folder was insufficient: the sandbox
still rejected the worktree administration-directory write. Explicitly allowing
that exact directory as well, then starting a fresh attempt, fixed the commit.
The main checkout and its original HEAD stayed unchanged.

This means worktrees need more initial permission setup in this configuration.
It does not mean Git lost work or corrupted the repository. The exact folder can
change with the worktree name. Prefer `in_place` for ordinary work until an
isolated worktree is needed. When extra writes are needed, configure narrow
roots on a dedicated project agent; do not grant an entire drive or add one
project's extra roots to a shared worker used by unrelated projects.

An example of the additional Codex arguments, with paths supplied by the owner:

```json
["-c", "sandbox_workspace_write.writable_roots=[\"C:/project/repo/.git\",\"C:/project/repo/.git/worktrees/worktree\"]"]
```

After narrowing permissions or changing scope, use a fresh chat/agent or a fresh
issue rerun. A wakeup resumes an older provider context and can retain its grants.

## Security settings and tested boundaries

The selected Codex settings are:

```text
-c approval_policy="never"
-c windows.sandbox="mxc"
-c features.exec_permission_approvals=false
-c features.request_permissions_tool=false
```

The observed session policy was `never` plus `workspace-write`. Ordinary project
writes and Multica CLI/API operations worked. Attempts to write a protected
outside canary through both a command and `apply_patch` were denied. The canary
remained unchanged. Narrow preconfigured extra-folder/Git grants worked. A fresh
session's native continuation retained its policy and grant.

`never` tells Codex not to ask for a more privileged command or broader file
access. The operation stays blocked when existing permissions are insufficient.
The owner can decide to grant a narrow path and start a fresh attempt. There is
no owner review page or permission-request queue running here.

Stock Multica still contains callbacks that automatically approve a request if
the provider emits one. Changing Codex back to an asking policy could therefore
let the application approve the request itself. Do not assume a new prompt will
wait for the owner. The tested configuration avoids that route by keeping asking
disabled. An explicit escalation probe was not invoked because the active policy
forbade it; the actual observed denials were the command and patch writes.

The sandbox limits writes. Reads extend beyond the project to files the account
can read, networking is enabled, and standard temporary directories are writable.
This does not isolate user secrets from a trusted local agent. A separate host
MCP tool has its own authority. Agent custom arguments can override machine
defaults, so those settings remain trusted owner configuration.

Older provider sessions retained their earlier asking policy despite new CLI
defaults. Explicit sandbox overrides also failed to revoke prior extra-directory
grants. That is why this setup uses a fresh workspace and agents. Do not resume
the old trial chats expecting current defaults to reset them. The old workspace's
custom agents are archived; its built-in Mika cannot be archived and has only
a retirement instruction, which is not a hard technical block.

## Windows test failures and other providers

The full upstream agent package reported 209 failing test entries on a clean
Windows baseline. Many tests create Unix shell executables that Windows cannot
run directly. This is a test-portability problem for those cases. We did not
classify every failure as harmless, and the full suite cannot be called green.
It reduces confidence in code paths outside the focused real tests. It does not
establish 209 separate failures in the workflow that was exercised successfully.

On November 18 both additional providers completed real authenticated Multica
workflows using their existing logins. Claude Code 2.1.322 used the Max login and
`claude-haiku-4-5-20251001`; Agy 1.5.12 used only `gemini-3.8-flash-low`. Each
provider ran its own lead, builder and independent reviewer. Both produced
correct files and reached accepted closure. Actual usage rows matched those
models. Claude's lead initially omitted worker dispatch and recovered on its
next scheduled check without operator correction. These were short synthetic
workflows, not repetitions of the multi-hour Codex or physical-reboot pilot.

Both also handled an explicit new requirement after acceptance. An input changed
the total from 42.00 to 43.00 and the current source revision changed from 2 to 3.
Each lead reopened the existing work, obtained a fresh implementation attempt and
a fresh independent review, and accepted the new results. Independent checks
verified the review followed implementation, all three issues were Done, and no
active runs or enabled guards remained. No repair prompt or runtime change was
needed. Both stages together used 15 Claude runs and 17 Agy runs with no failed
runs. A zero failed-run count does not mean every command or model decision was
correct. The backstop remains useful, and these were short synthetic projects.

The permission modes differ materially. The inspected stock Claude adapter
forces `--permission-mode bypassPermissions` and allows permission control
requests. The Agy adapter always adds `--dangerously-skip-permissions`. These
tests were limited by instructions to disposable synthetic project folders;
they did not establish the Codex MXC filesystem boundary for either provider.
Do not assume the machine-wide Codex never/MXC arguments constrain Claude or
Agy. The installer still provisions only the six Codex agents and copies no
provider credentials. The extra provider actors were isolated test agents.
All eight actors created for the reboot/provider follow-up were archived after
verification. Their project issues and history remain available.

The subsequent Agy Windows test established partial protection. With `--sandbox`,
commands really ran in an AppContainer and failed on outside writes, including
from a child process. Corrected absolute-path deny rules blocked specified native
file writes and a command marker. An explicitly unsandboxed command still wrote
an outside canary under stock Multica's forced bypass mode. The blanket escape
deny was not usable with normal commands. No policy was deployed to the daily
team. See [security posture](security-posture.md).

Claude's built-in command sandbox supports WSL2/Linux, not native Windows.
No Claude settings were changed in the Agy test. WSL2 would need its own boundary
and Windows-interop checks before making a containment claim.

## Root guards and project folders

The default guard asks the lead to recheck a goal every ten minutes, up to 48
times, with an eight-hour expiry. It helps recover missed handoffs or acceptance
steps. It is not an eight-hour successful test, an enforced deadline on every
worker, or a spending cap. The completed long stock pilot lasted about 2h36m.
The helper registers a guard before first dispatch; chat-only creation relies on
the lead following its instructions. Genuine external blockers still need a
decision. Independent projects should keep moving.

Naming a folder in an issue description does not attach it as the execution
directory. Attach the folder to a project and set the correct `project_id` on
each delegated lead/worker/review issue. One readiness test omitted that field;
the worker started elsewhere and correctly lacked write permission to the
requested folder. Explicit binding fixed the fresh repeat. Do not solve a
metadata mistake by granting access to all user files.
