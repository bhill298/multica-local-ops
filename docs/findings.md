# Test findings

These are the results relevant to the stock configuration selected on November
14, 2026. Detailed transcripts, generated documents and old patch exports are
deliberately excluded from this repository. This summary preserves failures and
coverage limits along with the successful outcomes.

## Selected components

Multica CLI source is unchanged at
`dbdbb299164347586e2650bb67684a490726a798`, the tested v0.7.0 baseline.
The matching backend and web images and PostgreSQL image are pinned by digest
in `config/settings.json`. The Windows operations tool imports no Multica Go
packages. The provider CLI observed in the packaging test was Codex 0.167.0.
Other CLI versions/model combinations need their own policy check.

## Tests

| Check | Observed result |
| --- | --- |
| Fresh-session permissions | Effective never + workspace-write/native MXC. Ordinary project writes and Multica CLI/API worked. Outside command and patch writes were denied; disposable canary unchanged. |
| Explicit escalation | Not invoked: active never policy forbade that request. Do not describe this as an observed tool-level escalation rejection. |
| Static grants and native continuation | Narrow extra-folder and in-place Git metadata grants worked, including a real commit. A native wakeup retained the fresh session's grant, never policy and outside denial. |
| Legacy-session migration | New CLI defaults did not replace an old asking policy on resume. Explicit protocol sandbox overrides also did not revoke old extra-directory grants. Fresh contexts were selected; an experimental resume patch was not deployed. |
| Real daemon crash | Killed at 26 checkpoints. Scheduled supervisor restarted installed stock CLI; saved prefix unchanged and all 30 final hash-chain records verified. Lead/root accepted closure without corrective prompts. The injected fault produced two failed runs; recovery totals were three completed and two cancelled. |
| Long mixed-project workflow | All 17 issues eventually Done in about 2h36m; 63 completed runs, zero failed, four redundant queued runs cancelled. No corrective operator prompts or runtime changes during the run. Late correction, one-hour audit and two-hour exercise-only decision were predeclared. Six Luna/low actors. |
| Long-run deliverables | Code passed ten independent acceptance groups, 13 deliverable tests and actual 10,000-row/full+filtered queries. Inputs and final tested implementation hashes matched. Planning constraints, $75/$90 arithmetic and exercise-only approval/no booking passed. |
| Model-quality detour | A false review claim about a source date led to repeated status and unnecessary wording work before autonomous correction/re-review. The final plan still carried an unnecessary date caveat. Eventual workflow completion was not flawless reasoning. |
| v6 readiness | Correctly rejected the false review claim but omitted project metadata on children; the requested write was denied because execution started elsewhere. Preserved as a failed configuration/prompt test. |
| v7 mixed-model readiness | Four issues Done in 8m41s; 14 completed, two redundant queued runs cancelled, zero failed/active runs and enabled wakeups. Correct project bindings, independent review, rejected false claim and unchanged source/brief hashes verified. No corrective operator prompt. Stronger decision roles and prompt changes happened together; their individual effects were not isolated. |
| Actual linked worktree | Initial `.git` grant did not permit its worktree administration-directory write. Adding that exact root and using a fresh attempt allowed a real commit. Original checkout/HEAD unchanged. Operator independently verified and accepted this isolated smoke; its worker had omitted final status closure. |
| Fixed Office host capability | Hidden owned Excel/Word instances created and verified outputs. Spreadsheet formula/cached42, Word text and PDF header independently checked. No foreground takeover or input injection. General Office/desktop automation not established. |
| Console visibility | Hidden inherited-console launcher corrected the observed detached-launch path. Startup, 180-second crash/recovery and roughly 484-second final windows had no unexpected visible console events. A nonactivating off-screen positive control was detected. No continuous two-hour observer output was retained. |
| Local auth | Requested development/fixed-code/87600h settings applied. Browser-facing HTTP routes accepted the fixed code, rejected a wrong code, issued an HttpOnly cookie and authenticated `/api/me`; server JWT TTL was 315,360,000 seconds. A real headless Edge login against the disposable install reached authenticated chat and retained a 400-day cookie, confirming the browser cap. |
| Fresh package install | Fetched the actual upstream Git commit, built CLI/supervisor, created a separate Docker stack, signed in locally, provisioned six agents and registered the native supervisor. A real delegated project task wrote 42 and reached accepted closure without operator steering. |
| Repeat package install | Preserved workspace ID, all team IDs and the private server environment. Rebuilt/restarted successfully without creating a replacement team. |
| Disposable adoption | Backed up and adopted the separate test stack into another runtime folder. Workspace, team and issue IDs survived. Normal local CLI reauthentication worked. No main-deployment migration was performed. |
| Backup helper | Produced a binary PostgreSQL archive, uploads tar and protected configuration copies. Binary streaming and file permissions were checked. Full disaster restore has not been exercised. |
| In-worker Playwright | Playwright-core 1.65.1 invoked headless Edge with the browser sandbox enabled. Edge exited before page interaction with a named-pipe error. No sandbox settings were loosened. |
| Browser control outside worker | Identical fixture succeeded with isolated headless Edge 157.0.4341.46 and its sandbox enabled: inputs, click, value42 and PNG screenshot. The worker context remains the unresolved difference. |
| Usage reporting | Token rows and UI estimates observed. No provider-supplied dollar prices in inspected Codex usage rows. No invoice reconciliation or hard-spend-cap test; planning budgets were unrelated. |
| Other providers | Stored Multica execution history inspected was entirely Codex. Claude/Agy runtime detection does not establish working authenticated Multica integration. Claude ran separate Firstmate/Herdr tests. |

## Package validation and failures

The supervisor's three Go tests passed and `go vet` passed. The installer suite
passed nine groups covering PowerShell parsing, invalid configuration rejection,
stdout/stderr handling, diagnostic redaction, stdin authentication input, binary
backup streaming, ordinary-user file permissions, process timeout and Compose
environment/loopback/volume behavior, including refusal to reuse an existing
database volume without its configuration. The Compose checks verify the TTL actually
reaches the backend; upstream's base Compose file did not forward it.

Integration testing found and fixed inherited empty environment overrides,
first-install retry handling, a Windows ACL privilege requirement, and CLI file
inputs outside its working directory. The installer now applies only file DACLs
without requesting audit privileges, and runs CLI file operations from its
runtime root. A first browser visit also exposed the normal onboarding page;
after provisioning, setup now completes that state through Multica's ordinary
API. A fresh browser login then loaded the actual workspace UI. Repeated login
tests encountered the normal auth rate limit; it was left enabled. A cold Git
fetch was slow; the installer bounds it and disables
interactive Git prompts. These are operations-code changes, not Multica patches.

The upstream full agent package was not green on the clean Windows baseline:
209 failing test entries were reported, many involving Unix executable fixtures.
Not every failure was independently classified. Focused Codex and real workflow
checks are the positive evidence; this repository's CI is not a full upstream
Windows certification. An undeployed prototype had one additional Pi shim failure
that passed in isolation on both trees.

Two acceptance-harness errors were corrected without editing deliverables:
the CLI required input before flags, and deliverable tests needed the project
working directory. Original failed receipts were retained in the trial history,
not included here.

## Coverage limits

No new physical reboot was run on the reduced stock deployment. No pre-login
recovery, eight-hour completed run, hard model-spending stop, general desktop
control, configured browser MCP service or equivalent Claude/Agy security/recovery
pilot is claimed. Fresh installation was tested on this existing Windows machine
with prerequisites already present, not a clean Windows VM. Adoption of the main
working deployment remains a separate reviewed operation.
