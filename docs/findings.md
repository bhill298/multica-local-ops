# Test findings

These are the results relevant to the stock configuration selected on November
14, 2026, with follow-up testing on November 18. Detailed transcripts, generated
documents and old patch exports are deliberately excluded from this repository.
This summary preserves failures and coverage limits along with the successful
outcomes.

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
| Physical Windows reboot, stock deployment | November 18: Windows Restart interrupted a real writer. After sign-in the installed supervisor and Docker stack recovered without a manual restart. A fresh worker attempt validated the existing 115-record prefix, appended 15 records and produced a verified 130-record hash chain. The separately saved 20-record prefix remained byte-for-byte unchanged. Lead accepted both issues Done; no active runs or enabled guards remained. No corrective operator prompts. |
| Startup before sign-in | Boot was 04:28:01 UTC November 19; Windows recorded actual logon at 04:30:40, about 159 seconds later. Container and native daemon startup timestamps were after logon. The supervisor uses Interactive/Limited logon and Docker Desktop autostart is enabled. This installation did not recover work before sign-in. Docker Desktop/engine restarted again during startup; the cause was not established. |
| Long mixed-project workflow | All 17 issues eventually Done in about 2h36m; 63 completed runs, zero failed, four redundant queued runs cancelled. No corrective operator prompts or runtime changes during the run. Late correction, one-hour audit and two-hour exercise-only decision were predeclared. Six Luna/low actors. |
| Long-run deliverables | Code passed ten independent acceptance groups, 13 deliverable tests and actual 10,000-row/full+filtered queries. Inputs and final tested implementation hashes matched. Planning constraints, $75/$90 arithmetic and exercise-only approval/no booking passed. |
| Model-quality detour | A false review claim about a source date led to repeated status and unnecessary wording work before autonomous correction/re-review. The final plan still carried an unnecessary date caveat. Eventual workflow completion was not flawless reasoning. |
| v6 readiness | Correctly rejected the false review claim but omitted project metadata on children; the requested write was denied because execution started elsewhere. Preserved as a failed configuration/prompt test. |
| v7 mixed-model readiness | Four issues Done in 8m41s; 14 completed, two redundant queued runs cancelled, zero failed/active runs and enabled wakeups. Correct project bindings, independent review, rejected false claim and unchanged source/brief hashes verified. No corrective operator prompt. Stronger decision roles and prompt changes happened together; their individual effects were not isolated. |
| Actual linked worktree | Initial `.git` grant did not permit its worktree administration-directory write. Adding that exact root and using a fresh attempt allowed a real commit. Original checkout/HEAD unchanged. Operator independently verified and accepted this isolated smoke; its worker had omitted final status closure. |
| Fixed Office host capability | Hidden owned Excel/Word instances created and verified outputs. Spreadsheet formula/cached 42, Word text and PDF header independently checked. No foreground takeover or input injection. General Office/desktop automation not established. |
| Console visibility | Hidden inherited-console launcher corrected the observed detached-launch path. Startup, 180-second crash/recovery and roughly 484-second final windows had no unexpected visible console events. A nonactivating off-screen positive control was detected. No continuous two-hour observer output was retained. |
| Local auth | Requested development/fixed-code/87600h settings applied. Browser-facing HTTP routes accepted the fixed code, rejected a wrong code, issued an HttpOnly cookie and authenticated `/api/me`; server JWT TTL was 315,360,000 seconds. A real headless Edge login against the disposable install reached authenticated chat and retained a 400-day cookie, confirming the browser cap. |
| Fresh package install | Fetched the actual upstream Git commit, built CLI/supervisor, created a separate Docker stack, signed in locally, provisioned six agents and registered the native supervisor. A real delegated project task wrote 42 and reached accepted closure without operator steering. |
| Repeat package install | Preserved workspace ID, all team IDs and the private server environment. Rebuilt/restarted successfully without creating a replacement team. |
| Disposable adoption | Backed up and adopted the separate test stack into another runtime folder. Workspace, team and issue IDs survived. Normal local CLI reauthentication worked. |
| Approved main adoption | Completed November 14, 2026. All six current agent IDs, instructions, models and custom arguments matched their pre-migration snapshot. Database counts stayed at one user, two workspaces, 129 issues, 68 total agents including archived history, and 414 runs. Original data volumes and JWT signing secret were preserved. The stock source checkout is clean and independent of tmp. Installed status/backup helpers and a fresh headless browser login/workspace UI passed. Local CLI login was renewed as a normal user PAT. Pre-migration database and post-migration database/uploads/configuration backups were created privately. |
| Backup helper | Produced a binary PostgreSQL archive, uploads tar and protected configuration copies. Binary streaming and file permissions were checked. Full disaster restore has not been exercised. |
| In-worker Playwright | Playwright-core 1.65.1 invoked headless Edge with the browser sandbox enabled. Edge exited before page interaction with a named-pipe error. No sandbox settings were loosened. |
| Browser control outside worker | Identical fixture succeeded with isolated headless Edge 157.0.4341.46 and its sandbox enabled: inputs, click, value42 and PNG screenshot. The worker context remains the unresolved difference. |
| Usage reporting | Token rows and UI estimates observed. No provider-supplied dollar prices in inspected Codex usage rows. No invoice reconciliation or hard-spend-cap test; planning budgets were unrelated. |
| Claude authenticated workflow | November 18: Claude Code 2.1.322 with the existing Max login and explicit `claude-haiku-4-5-20251001` ran a lead/builder/independent-reviewer workflow. Correct Python output, Decimal total 42.00, Unicode names, input hash and source-summary content independently verified. All three issues accepted Done, no failed runs or active work/guards at acceptance. The lead initially omitted worker dispatch; its scheduled backstop corrected this without an operator prompt. |
| Agy authenticated workflow | November 18: Agy 1.5.12, restricted to `gemini-3.8-flash-low`, completed the equivalent three-actor workflow. Actual usage rows named only that model. Correct files, independent review and accepted closure passed, with no failed runs or active work/guards at acceptance. No fallback to another model. |
| Changed requirement with both providers | Explicitly reopened the accepted roots after changing an input and specification: total 42.00/source revision 2 became total 43.00/source revision 3. Both leads reused their existing children, dispatched fresh implementation and independent review runs, and accepted the corrected hierarchy Done. Fresh review started after implementation completion; current artifacts/hash/Unicode/source content passed independent checks. No repair prompts, new login or runtime changes. Final totals across both stages: Claude 15 runs, Agy 17, zero failed, zero active and no enabled guards. |
| Provider token versus dollar tracking | Both new providers produced token/cache usage rows. Their inspected dollar-cost fields were null; the aggregate returned zero cost with nonzero uncosted tokens. This verifies token ingestion, not accurate dollar totals, free usage or a hard spending stop. |

## Agy native Windows boundary tests

The follow-up used unchanged stock Multica, Agy 1.5.12 on Windows 25H2 build
26200.9974, and only `gemini-3.8-flash-low`. Actual usage rows from all five runs
named that model. Each arm had a fresh actor and dedicated Agy project. Global
Agy permission settings and Claude configuration were unchanged. All five actors
were archived afterward and their temporary project policy files removed.

| Check | Observed result |
| --- | --- |
| Owner positive control | AppContainer=false. The same inside/outside writes and child PowerShell write succeeded. Canaries were reset before each arm. |
| Sandbox alone | Python AppContainer=true. Inside write passed; outside write and child PowerShell outside write failed. Native file-tool outside write and explicitly unsandboxed command still changed canaries. |
| Scoped denies with a relative path | Native file/command marker denies worked, but `write_file(deny-zone/)` caused sandbox initialization failure before normal commands ran. This was not a successful containment policy. |
| Corrected absolute-path denies | Three project deny grants loaded. Normal commands remained usable. Inside write passed; outside and denied-inside Python writes, native file-tool writes to those paths, and the command marker were blocked. The unsandboxed command still changed the outside escape canary. |
| Blanket unsandboxed deny | `unsandboxed(*)` produced an unsupported-rule warning on this account/runtime and blocked ordinary commands as well. No usable policy retaining normal commands while preventing all escapes was established. |

Canary bytes and actual tool outcomes were checked independently. The final
escape command exited 0 and wrote `AGY_ESCAPE_PROBE` outside the project. The
normalized Multica command trace does not retain every Agy control field, but
the process result and changed canary independently establish the outside write.

This was Agy's supported unsandboxed execution option, not an exploit that broke
the AppContainer boundary. The candidate failed whole-agent containment and was
not deployed to the daily team. The initial harness had a Windows ctypes pointer
declaration error; it was corrected and the owner control rerun before completed
probe arms. A Completed run was not treated as proof the security policy passed.
The reusable [probe and method](../examples/agy-boundary.md) are included without
raw authenticated session artifacts.

## Package validation and failures

The Office source was subsequently relocated into this repository. Old absolute
trial paths were removed, outputs now use fresh ignored directories, and the
owner selects an absolute PowerShell 7 executable through generated local MCP
configuration. The live direct-MCP check passed with Node 24.16.0/PowerShell 7.6.3
in about six seconds: hidden owned instances, saved Excel formula/cached 42,
Word XML and PDF header. All four protocol/guard/live groups passed. It was not
attached to or retested through a new daily agent. An initial Windows
PowerShell 5.1/STA attempt timed out while starting Word; its verified new hidden
Word process was cleaned up by exact identity. Version and apartment launch
options changed together, so the cause was not isolated. PowerShell 5.1 is not a
supported fallback. The tool timeout can leave a newly created Office process
if COM blocks; see its README. Generated outputs and receipts are not committed.

The repository also preserves 29 historical reports/plans and the unchanged
small Windows checkpoint fixture used in the physical reboot test. Historical
files carry precedence/provenance banners; links to excluded artifacts are
labeled. See [testing guide](testing-guide.md) for current methods and exclusions.

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

The additional provider pilots each took about eight minutes per stage, including
lead backstops and continuation runs. Successful final closure does not mean
every model action was correct: Claude initially omitted dispatch and tried an
unsupported wakeup flag before consulting help. The backstop recovered the
workflow without operator repair. These small tests also used substantial cached
context; they are not an efficiency or cost benchmark. All eight disposable
follow-up actors were archived after verification, preserving the issues and
history. The six daily Codex agents were not reconfigured.

## Coverage limits

Physical reboot recovery after Windows sign-in passed on the reduced stock
deployment. No pre-login recovery, eight-hour completed run, hard model-spending
stop, general desktop control, configured browser MCP service or equivalent
Claude/Agy sandbox/reboot pilot is claimed. Fresh installation was tested on
this existing Windows machine with prerequisites already present, not a clean
Windows VM. Adoption of the main
working deployment was completed with explicit approval; a full disaster restore
remains untested.
