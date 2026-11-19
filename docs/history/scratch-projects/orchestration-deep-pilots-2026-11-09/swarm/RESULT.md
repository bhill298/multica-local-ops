> Historical snapshot imported November 18, 2026 from `scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Agent Swarm deep pilot

Completed November 10, 2026. The longer run, three local fixes and live integration checks are complete.

**Version scope:** the full runtime pilot used the existing 2.5.3 deployment. Official 2.10.0 was already available just before intake; the release check should have happened earlier. A subsequent [current-source audit](../upstream-current/REPORT.md) reproduced the same defect boundaries with isolated tests, but did not validate a full 2.10 deployment. The installed private fork remains based on 2.5.3.

## Outcome and configuration

**Assisted pass for the longer mixed-project workflow.** Both business deliverables were accepted and the root native workflow completed at 2026-11-10T05:46:59.699Z. This was not a clean unattended pass. Timing-evidence delivery and Git coordination needed operator corrections; the original invalid credential slot also required repair after normal login renewal.

Local Docker Swarm 2.5.3 used a root, two project leads, code/planning workers and an independent reviewer. The isolated Windows fixture directory was mounted into Linux workers; no Docker socket or general host filesystem was exposed. Existing Codex authentication was renewed through the normal device flow. Hosting stayed local; model inference used existing authenticated providers. The user connected the browser dashboard directly with its existing key. Keys were never put in URLs or reports.

## Measured results

| Test | Observed result |
| --- | --- |
| Parallel code and planning projects | Both accepted; root and child native workflows completed |
| Late requirement with retained context | Exact project filter and boundary behavior passed fresh reviews |
| Delayed one-hour audit | Actual 10,000-row CLI queries and fresh independent reviews passed |
| Two-hour decision | Native wait fired after two hours from intake, but slightly before two hours from workflow startup; reviewers held acceptance until timing evidence and a later explicit reaffirmation were delivered |
| Independent CLI verification | 26/26 real CLI cases, including 10,000 rows, passed; implementation unchanged by verifier |
| Native waits across API restart | Time/event waits survived, event deduplication produced one join |
| Owner approval, denial, expiry | Passed; agent self-approval returned 403 |
| Retry | Failed checkpoint ran twice; successful sibling ran once; joined successfully |
| Worker crash | Automatic resume child after approximately 15-minute stale-heartbeat threshold; same nonce, one action, accepted final output |
| Live steering | Codex app-server steering passed via API and actual dashboard Interrupt control |
| Dashboard Pause | **Failed:** database became paused, but provider continued and completed the task |
| Task Cancel | Passed on a dedicated Codex task: cancelled row stayed terminal, owned provider and tool child exited, and no final side effect appeared after the original deadline |
| Parent workflow cancellation | **Failed to cascade:** child workflow remained waiting; explicitly cleaned up |
| Parallel Git worktrees and conflict | Initial coordination failed; corrected single-writer/DAG run accepted; 12 independent ancestry/content/index checks passed |
| Fixed Windows Office operation | Actual worker call and independent Excel/Word/PDF/process checks passed without desktop takeover |
| Host reboot | Not tested or authorized in this run |

The longer run started from intake at 03:31:49.924Z; native workflow startup was 03:33:50.512Z. Planning's wait fired at 05:32:40.073Z. Explicit operator reaffirmation was recorded at 05:39:16.7800609Z, after two hours from both anchors. An earlier operator message mistakenly typed a future 05:43Z; it was immediately corrected and is not used as evidence. The run includes elapsed idle waits, rather than two hours of continuous compute.

## Defects and coordination failures

The ordinary task pool could acquire tasks before their dependencies completed. The native workflow DAG correctly held its own dependent steps; these are distinct paths. Codex child MCP tools also lost the registered runtime identity, causing a real offer-accept rejection despite a live worker. Both defects have focused, separately committed local fixes.

The natural offer path exposed a third defect: polling set the task to reviewing, automatic progress changed it to in_progress before assignment, and the native accept handler recognized only offered. The third fix preserves review states and requires the exact recipient/null-or-same assignee again in the atomic acceptance write. The natural poll → reviewing → progress → genuine MCP accept → nonce receipt → completion path subsequently passed without a manual pre-poll workaround.

Pause needs a broader stop-acknowledgement and execution-attempt contract. Nine regression invariants expose missing abort, stale completion/failure/start writes, premature/non-dispatchable resume, late registration and stale cleanup. A partial abort-only patch was deliberately not installed. A successful button/API response does not establish that execution stopped.

The initial Git lead and integrator both edited shared integration evidence, a review depended on feature tasks rather than the actual integrator, and an artifact tried to reference its own commit. The corrected run used one writer, an explicit native DAG dependency, an immutable code commit followed by a separate evidence commit, and a final receipt outside Git. A later reviewer initially compared a Git blob ID to a raw-file SHA-256; a corrected fresh review distinguished the two. Existing README line-ending differences were preserved. Windows Git sees the tracked checkout clean; Linux repository-wide checks can still report the preserved CRLF difference.

## Local fork and deployment

Source branch `fix/pool-dependency-guard-20261109` is isolated from the original checkout. Commits:

- `f847b0d`: atomically guard task acquisition on completed dependencies.
- `15a11c0`: retain the actual Codex subprocess runtime identity in the existing narrow environment allowlist.
- `0743b87`: preserve offer review until genuine native acceptance, including atomic recipient/assignee checks.

Combined difference from original `77039db`: twelve files, 631 insertions and 14 deletions, mostly regression tests/documentation. The final patch reproduced 16 baseline failures, then passed 263 focused cases and 427 surrounding cases, plus lint, type checks and boundary gates. These overlapping counts are not summed. Details are in the validation JSON/logs. No push occurred.

Local images replace only the compiled API/worker binaries on digest-pinned official 2.5.3 bases. Codex 0.164.0, Claude 2.1.309, Bun 1.4.3 and Node 22.23.4 remain unchanged. Each deployment drained active work and backed up the cleanly stopped database with restricted ACLs. Existing auth, volumes, UUIDs, mounts and UI were preserved; earlier images/backups remain available. Final immutable tags are `orchestration-pilot-swarm-api:0743b87` and `orchestration-pilot-swarm-worker:0743b87`. Build, rollback and live evidence are in the final integration report (historical reference: `scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/build/0743b87/README.md`; artifact not bundled).

Actual negative/positive pool dependency tests, genuine active-session runtime-affinity acceptance and the natural offer path passed. Task Cancel passed with independent provider/child-exit checks. Six private agent defaults were pinned through the supported API to Luna/low; a fresh task without explicit model metadata verified the default. One earlier test model mistyped a recipient UUID and stopped; its failed task is preserved, followed by a fresh test instructed to confirm the registered ID. No larger model was silently substituted to make that check pass.

Final independent inventory found **125 terminal tasks, zero nonterminal tasks, zero enabled schedules and six idle agents**. The natural-offer artifact hash matches its live receipt. The native runtime inventory also showed zero active sessions. See `final-independent-inventory.json`. Pause and natural offer rejection remain unresolved.

A fresh closing API snapshot at09:12:41Z reconfirmed125 terminal records,
zero nonterminal tasks/schedules and six idle agents. Those records include
95 completed,23 failed,5 cancelled and2 superseded test tasks;125 is not a count
of successful business deliverables. See `closing-independent-inventory.json`.

### Current-release applicability

Official 2.10.0 (`b3ba784f`) still contains the three defect groups and DB-only pause/resume behavior. Isolated source-bound regressions used temporary databases and a synthetic subprocess, with 24 positive controls passing and 70 desired invariants failing. These are targeted diagnostic assertions, not a claim that the upstream test suite fails. The complete current MCP handler could not load from cached dependencies, so some handler conclusions remain source-only. No current-release model or deployment was tested.

Current dependencies may be completed **or skipped**. All five skipped-dependency compatibility controls passed; the old completed-only SQL patch must be adapted before a current-release port. Source compatibility and upstream readiness require review against that policy. Do not apply the old patch unchanged or treat the private 2.5.3 build as official 2.10. See the [audited source and limits](../upstream-current/REPORT.md).

## What using it feels like

### Windows Git interoperability

Windows and the container read identical shared-file hashes, and Windows Git
can inspect the main repository. However, the existing Linux-created linked
worktree fails Windows Git with exit128: its `.git` and metadata backpointer
contain absolute `/workspace/...` paths. Container Git reports that same
worktree clean. This is a cross-namespace Git path limitation, not a demonstrated
Swarm defect. Windows Git2.54 supports relative worktrees; installed container
Git2.43 lacks the option. The bounded workaround proof stopped at that
capability gate without creating a probe, upgrading Git or rewriting pointers.
See [the interoperability report](windows-git-interop/REPORT.md). File access
does not establish interchangeable host/container linked-worktree operations.

The browser dashboard exposes agents, task conversations/tool activity, workflow DAGs and runs, approval requests and steering controls. These were exercised against real work. Project organization still relies more on roots, task lineage, tags and directories than on a conventional multi-project workspace. A task marked completed can have deferred its business outcome to a later continuation, so users must follow the lineage and explicit acceptance record.

The Office result is a custom, fixed, one-shot loopback integration to Windows application APIs. It is not a bundled arbitrary desktop controller, screenshot service or general host-command bridge. Crash recovery covers an idempotent checkpoint; it does not prove exactly-once external effects.

## Evidence

- `projects/evidence/final-acceptance.json`: actual root business acceptance.
- `long-final-run.json`: terminal native workflow evidence.
- `independent-final-verification.json`: six cited receipt hashes, native completion and decision timing.
- `independent-ledger-results.json` and `independent-git-results.json`: independent checks.
- `projects/evidence/git-final-acceptance.json`: corrected Git business acceptance.
- `../desktop/independent-verification.json`: Office file/process verification.
- `ui-approval-approved.jpg`: real dashboard approval screenshot.
- Control, restart, retry, crash, steering and cancellation JSON receipts in this directory.

Remaining product gaps: safe Pause/resume, natural offer rejection after polling, nested cancellation policy, host-reboot verification, and production/long-term reliability. The reviewed local fixes and current-release audit do not establish exactly-once external effects or a maintenance-free installation.
