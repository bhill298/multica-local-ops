> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-minimal-2026-11-14/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Multica stock deployment — November 14, 2026

The selected setup is **unmodified Multica source, a clean local workspace,
never-ask Codex settings and a separate small Windows supervisor**. No Multica
source patch is deployed. The old fork and its private state remain for rollback;
its supervisor is disabled and its approval broker has been stopped.

Open [Local Work](http://localhost:43130/local-work/chat) and give Mika an outcome
and the authorized project folder. The default profile now selects this workspace.
Existing local account/provider authentication was reused through normal tools;
no additional account or login was needed for the transition.

## What is installed

- Source: unmodified `dbdbb299164347586e2650bb67684a490726a798`, the tested
  Multica 0.7.0 baseline. The locally built binary reports `dev`; it is not being
  represented as a downloaded release or as the latest upstream version.
- CLI: `C:/Users/brennan/.multica/stock-runtime/bin/multica.exe`, SHA-256
  `4c434b2ad5e894d2fe77b9c48e101c84def4319ded69755e222119715e60dc21`.
- Data: `C:/Users/brennan/.multica/workspaces-local`, outside the disposable trial.
- External supervisor: `Multica Local Supervisor`, once per minute and at the
  current user's logon. It uses JSON health status and a foreground daemon in a
  hidden inherited console. Its source is the sibling `multica-local-ops` repo.
- Codex defaults: `approval_policy="never"`, explicit `windows.sandbox="mxc"`,
  `features.exec_permission_approvals=false`,
  `features.request_permissions_tool=false` via `MULTICA_CODEX_ARGS`.
- Current coordination contract: `multica-local-ops/coordination-local.txt`.
  v5 dispatch/acceptance/root-backstop rules plus v6 factual review adjudication
  and v7 explicit project binding on every lead/worker/reviewer issue.
- Fresh team: Mika, Code Lead, Research Lead and Reviewer use gpt-6.1-sol/medium;
  Builder and Researcher use gpt-6-luna/low. Capacity one per actor. No host MCP
  capability is globally exposed to all six by default.

The old workspace and issues were not deleted. Its 61 custom agents are archived.
Stock refuses to archive built-in Mika; that actor instead has a retirement
instruction directing new work here. This instruction is not a hard execution
block: do not resume historical chats or dispatch new work in the old workspace.

## Tests and actual outcomes

| Check | Result and limit |
| --- | --- |
| Fresh Codex security policy | Effective never + workspace-write under native Windows MXC. Project writes and Multica API/CLI use worked. Outside command write and actual apply_patch write were denied; protected canary unchanged. Explicit escalation was not invoked because active never instructions prohibit it. |
| Narrow pregrants | Extra-folder and in-place `.git` writes worked, including a real Git commit. A native wakeup resumed that fresh provider session and retained never, its grant and outside-write denial. |
| Actual worktree | Initial `.git` grant alone failed on the worktree administration directory. Pregranting exact `.git/worktrees/worktree` as well, followed by a fresh rerun, produced commit `93d6a0e6204dd676616907031da141645698982f`, only result-retry.txt. Original checkout/HEAD/seed unchanged. Worker omitted final business closure; operator independently verified and accepted this isolated smoke. |
| Abrupt daemon crash | Terminated the actual daemon at 26 append-only hash-chain checkpoints. Real scheduled supervisor restarted the installed stock CLI; all 26 saved records survived byte-for-byte and all 30 final records verified. Lead and root closed without a corrective prompt. Fault-test counts: 3 completed, 2 intentionally interrupted failed, 2 cancelled runs. |
| Two-hour mixed-project v5 pilot | Eventual workflow pass: all 17 issues Done, 63 completed runs, zero failed runs, four redundant queued runs cancelled, no active runs or enabled wakeups at final closure. Started 20:20:05 UTC, final supplied decision 22:20:05 UTC, observed closed 22:55:50 UTC: about 2h36m. Six fresh Luna/low actors; no corrective operator prompts or runtime changes during this run. |
| Code deliverable | Ten independent acceptance groups and 13 deliverable tests passed. Actual 10,000-row fixture checked independently: unique/formula-correct rows, all five full/filtered/absent CLI queries, aggregate 79,974 minutes. Final implementation hash still matches those receipts. |
| Planning deliverable | Source inputs preserved. Eight attendees, capacity, $75 budget within $90, 120-minute agenda with 10-minute break/15-minute close, exercise-only Venue A decision and no booking/payment all verified. See quality caveat below. |
| Bounded Office host tool | Stock worker called the reviewed no-argument capability. Hidden owned Excel and Word instances created/reopened outputs; independently checked spreadsheet formula/cached42, Word text and PDF header. No foreground takeover or injected input. This is a fixed host API, not unrestricted desktop automation. |
| New v6 readiness attempt | Correctly rejected the false review's date claim, but lead omitted project metadata on children. Requested output folder was outside their execution scope, and write was correctly denied. Preserved as a failed configuration/prompt test rather than widening permissions. |
| Fresh v7 readiness | Passed autonomously in 8m41s: all four issues Done, 14 completed runs, two redundant queued runs cancelled, zero failed/active runs and enabled wakeups. Actual project bindings verified; independent review rejected the false claim, literal source quotes verified, source/brief hashes unchanged. Zero corrective operator prompts. Stronger decision roles, cheaper worker; explicit project binding and independent review. This is a focused configuration test, not a repeat two-hour mixed-model reliability claim. |

The long pilot was not a flawless first pass. A Luna reviewer wrongly challenged
an explicit dated update in a source body because the heading was older. Leads
repeated the finding before autonomously dispatching correction and fresh review.
The final plan carries an unnecessary caveat about that date. Numerical and
business constraints passed, but this factual judgment/coordination detour added
work and delay. v6 addresses unsupported review claims and status-only loops;
v7 addresses the separate omitted-project mistake. Stronger decision models and
these instructions were changed together, so the short test cannot isolate their
individual effects.

The acceptance harness originally assumed flags could precede the input filename;
the actual deliverable documents input first. Adapting that harness resolved two
failures without changing implementation. An operator test initially run from the
parent directory failed module resolution; rerunning from the project directory
passed 13/13. Those failed receipts remain preserved. They are not runtime fixes.

## Why fresh contexts, rather than a small source fork

`MULTICA_CODEX_ARGS` is honored for new contexts. It is not a retroactive session
migration. Normal app-server tests showed an old asking thread remained asking
on resume despite new CLI defaults. Explicit protocol overrides changed asking
policy but did not revoke prior extra-directory grants; old grants remained
additive. A legacy full-access context also needed special care when overriding
only approval settings. The user selected a fresh workspace to avoid this risk
without maintaining source changes.

For permission narrowing or unrelated scope changes, use a new chat/agent or an
explicit issue rerun that starts a fresh provider thread in this tested version.
A native wakeup resumes an existing context and is not a permission reset.

The broad upstream agent package was not green on Windows: the clean baseline
reported 209 failures, largely from Unix executable fixtures. Focused Codex checks
and the real integration tests above are the relevant positive evidence, not a
claim that the full upstream suite passes. The experimental tree had one extra
Pi shim failure; that case passed in isolation on both trees. Logs are preserved.

The optional resume-policy prototype was never built into or installed as the
selected runtime. Its clean extra checkout was removed; a labeled undeployed
patch/commit remains under `undeployed-resume-experiment` for investigation
history. It did not solve revocation of old session directory grants. Original
fork exports and private rollback state are also retained, not deployed.

## Remaining caveats

- Never-ask removes the owner approval queue: an unexpected required write stays
  blocked until an owner deliberately grants narrow access and starts a fresh
  attempt. Stock approval auto-accept callbacks still exist; do not switch to an
  asking policy while assuming those requests receive human review.
- Defaults/custom args are trusted operator configuration; per-agent custom args
  can override defaults. This verified Codex policy does not prove equivalent
  Claude/Agy behavior. Network remains enabled, standard temp writes allowed,
  and reads extend beyond project files: this is not a full data-isolation boundary.
- Coordination is still model/prompt-driven with durable wakeups, not a formally
  enforced dependency/acceptance engine. The eight-hour root guard is an operating
  default, not an eight-hour completed reliability test. New project-folder
  binding and permission changes require care.
- Recovery creates a fresh attempt from saved artifacts, not the same execution.
  The stock candidate passed real daemon-crash recovery. A new physical Windows
  reboot has **not** been tested on this reduced setup; earlier reboot passes
  belong to the old fork. Docker Desktop and the user-level task require sign-in;
  pre-login recovery remains unverified.
- The launcher fixed the observed detached-console path without Multica source
  changes. Startup and 180-second crash/recovery observers recorded zero visible
  console events; a separate off-screen, nonactivating positive control proved
  observer detection. A proposed full-long-run observer did not retain an output,
  so there is no continuous two-hour console-observation claim. Final readiness
  observer covered about 484 seconds, detected its off-screen positive control
  (PID50600, foreground unchanged), and recorded zero other visible console
  events. It was stopped before its configured 600-second limit; the receipt
  distinguishes actual observation from that limit.
- The Office tool is an intentionally fixed host capability with its own permission
  boundary. It is not generic safe automation of arbitrary Windows applications.
- Local orchestration uses a local server/UI, but authenticated hosted models
  still use their provider service. This is not offline inference.

## Evidence

`evidence/migration-complete.json`, `clean-workspace.json`,
`retired-trial-agents.json`, `effective-session-policies.json`,
`policy-migration*.json`, `current-sandbox-control.json`,
`recovery-independent.json`, `recovery-snapshot.json`, `crash.json`,
`long-snapshot.json`, `acceptance-documented-cli.*`, `deliverable-tests.*`,
`large-input-independent.json`, `final-independent.json`,
`worktree-independent.json`, `office-independent.json`,
`readiness-snapshot.json`, `readiness-v7-setup.json`, and
`readiness-v7-snapshot.json`, `readiness-v7-independent.json`,
`daily-effective-policies.json`, `deployment-verified.json` and
`final-window-summary.json`. Inputs and failed setup/control receipts remain in
this trial directory. No provider credentials or model reasoning are needed in
these result records.
