> Historical snapshot imported November 18, 2026 from `agent-orchestration-hands-on-2026-10-24.md`.
> Current setup/security instructions: [repository guide](../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

## Agy boundary and repository update: November 18, 2026

Agy native Windows containment did not pass under the selected stock Multica
adapter. Only Gemini 3.8 Flash Low was used; all five usage records matched that
model. With --sandbox, the actual Python process ran in a Windows AppContainer,
wrote inside the project, and failed on an outside write and inherited child
PowerShell write. Owner controls could write the same disposable canaries.

Corrected absolute-path project deny rules blocked the specified native file
writes, a denied in-project Python write, and a command marker. An explicitly
unsandboxed command still changed the outside escape canary. The supported
BypassSandbox execution path was available under stock Multica's forced bypass
mode; this was not an exploit of the AppContainer itself. A blanket unsandboxed(*)
deny produced an unsupported-rule warning and also blocked normal commands.
A relative file deny caused sandbox initialization failure; absolute paths fixed
normal execution but did not prevent the deliberate unsandboxed write.

No tested usable configuration established Codex-equivalent whole-agent write
containment for Agy. No Agy security policy was deployed to the daily team. Five
temporary test actors were archived and their dedicated Agy project policy files
removed, preserving test history/receipts. Global Agy permissions and Claude
configuration were unchanged; the six daily Codex agents remain unchanged/idle.

Claude's built-in command sandbox supports WSL2/Linux and does not run on native
Windows. A WSL2 deployment would require its own enforcement and Windows-interop
checks. This follow-up did not configure or test Claude again.

The operations repo now includes docs/security-posture.md and
docs/repository-guide.md, plus the tested small Agy filesystem probe and method.
It preserves the stock installer, supervisor, settings, coordination instructions
and summarized evidence. Live secrets/data/provider logins, detailed historical
framework trials, and the old machine-specific Office proof remain outside Git.
The base install can be recreated with prerequisites, network access and normal
provider sign-in; it is not an offline image or a database backup. The lost fork
capability is the custom human escalation queue; external supervisor/recovery
and coordination remain. Full details and the documentation map are in the repo.

Repository: C:/Users/brennan/Desktop/proj/tmp/scratch-projects/multica-local-ops
Commit: 871aed0414afec600de790d518dddf3188bb4a3f. No Multica source changes or Claude changes; nothing pushed.
Raw boundary evidence: tmp/scratch-projects/multica-agy-boundary-2026-11-18.
This update supersedes earlier suggestions that Agy --sandbox alone might give
the tested Codex boundary. Earlier workflow success remains valid.

<!-- END AGY BOUNDARY NOV18 UPDATE -->

## Stock Multica follow-up: November 18, 2026

The unmodified installed baseline passed a real Windows Restart. After sign-in,
the stock daemon and Docker services recovered, a fresh worker attempt validated
115 existing checkpoint records and appended 15 more, and the lead accepted root
LOCAL-8 and child LOCAL-9 Done. The complete 130-record hash chain and separately
saved 20-record byte prefix passed independent checks. No corrective operator
prompt or manual service restart was needed; final active runs/guards were zero.

This setup still needs Windows sign-in. Windows logged on about 159 seconds after
boot; observed containers and native daemon started afterward. The task is
Interactive/Limited and Docker Desktop autostart is enabled. Docker Desktop/engine
restarted again during startup for an undetermined reason; recovery still passed.
No pre-login operation or exactly-once external side effect is established.

Claude Code 2.1.322 with the existing Max login and explicit
claude-haiku-4-5-20251001, plus Agy 1.5.12 restricted to gemini-3.8-flash-low,
completed separate lead/builder/independent-reviewer projects on stock Multica.
Both then handled an explicit changed requirement from total 42.00/source revision 2
to total 43.00/source revision 3 using fresh implementation and review runs.
Final artifacts, project bindings, independent review, Done closure and drained
guards/runs passed independent checks. No model fallback or new provider login.
Claude initially omitted a worker dispatch; its timer corrected that without a
repair prompt. These were short synthetic pilots, not multi-hour or reboot
tests of these two providers.

Both providers recorded actual token/cache usage with the requested model IDs.
Inspected dollar-cost fields were null; aggregate cost 0 with uncosted tokens
does not establish free usage, correct dollar estimates or budget enforcement.
Stock Claude forces bypassPermissions; stock Agy skips permissions. Codex's
never/MXC settings do not constrain those adapters. Their tests did not establish
equivalent filesystem isolation. The six daily Codex agents are unchanged; the
eight disposable follow-up actors were archived with their history preserved.

The fixed Office MCP source still exists separately under
multica-minimal-2026-11-14/desktop/host. It was independent of the fork and passed
the earlier stock test. It is a one-operation hidden Office fixture, not a daily
general Office driver or a tool attached to the current six agents. Stock Multica
can accept per-agent MCP configuration; the inspected Agy adapter does not wire
that configuration into its invocation. The operations package includes a tool
configuration guide, not the old machine-specific fixture itself.

Operations repository: C:/Users/brennan/Desktop/proj/tmp/scratch-projects/multica-local-ops
Commit: e4900248b3102698709ee3aa990be3e631346627. No Multica source changes or new startup tasks were added.
Summarized findings and tool instructions are in that repository; raw synthetic
test artifacts remain under multica-stock-followup-2026-11-18, outside the package.
This update supersedes earlier reboot/provider coverage statements below.

<!-- END MULTICA NOV18 FOLLOWUP -->

## Multica reduction trial — November 14, 2026

**Current selection: stock Multica with a fresh local workspace, no Multica
source fork.** The user explicitly chose the clean-workspace option. Installed
source is unmodified dbdbb299164347586e2650bb67684a490726a798 (the tested 0.7.0
baseline), locally compiled as multica.exe; it reports dev. This pins the known
baseline rather than claiming a newer upstream release was tested.

[Open Local Work](http://localhost:43130/local-work/chat). Give Mika an outcome
and an authorized project folder. The existing local account/provider login is
reused. The default profile selects this new workspace and its work data resides
under C:/Users/brennan/.multica/workspaces-local. All 61 custom old trial agents
are archived, preserving issues and history. Stock built-in Mika cannot be
archived; it has a retirement instruction instead, not an enforced execution
block. Do not resume historical chats. The old fork, patch exports and private
rollback state remain, with old supervisor disabled and old approval broker stopped.

The active setup retains **settings, coordination instructions and a small external
Windows supervisor**, rather than the broker, credential separation or installed-
path source repair. Never-ask plus explicit native MXC yielded effective never +
workspace-write in fresh Codex sessions. Actual outside command/apply_patch writes
were denied, ordinary project/CLI operations worked, and narrow extra-folder/Git
grants worked. Native wakeup/resume retained this fresh context's policy and grants.
Dynamic permission requests are disabled. Stock auto-accept callbacks still exist:
do not change to an asking policy expecting a human queue. Unexpected required
writes now block for a deliberate narrow grant and fresh attempt. Reads extend
beyond the project, temporary writes/network remain enabled, and custom agent args
can override defaults. These checks cover Codex, not equivalent Claude/Agy policy.

**Important legacy-session finding:** new CLI defaults do not migrate an old
asking thread's approval policy. Explicit protocol overrides still did not revoke
old extra-directory grants. Permission narrowing or unrelated scope changes need
fresh contexts, not native wakeup/resume. A resume-policy prototype was archived
as undeployed; it did not solve retained directory grants and is not in the runtime.

The stock two-hour v5 mixed-project repeat **eventually closed all 17 issues**:
63 completed runs, zero failed, four redundant queued runs cancelled; zero active
runs and zero enabled wakeups at closure. Start 20:20:05 UTC, final supplied exercise
approval 22:20:05, observed closed 22:55:50: about 2h36m. Six fresh Luna/low actors;
no corrective operator prompts or runtime changes during the run. A false source-
date review claim caused extra work, repeated status and an unnecessary caveat in
the final plan before autonomous correction/re-review and closure. Treat this as
workflow completion with a model-quality/latency caveat, not flawless first-pass
reasoning. Numeric, capacity, agenda and exercise-only approval constraints passed.
Code passed 10 independent acceptance groups, 13 deliverable tests and actual 10,000-
row/full+filtered queries. Source inputs and final tested implementation hashes match.

Actual abrupt daemon termination at 26 checkpoints recovered through the external
minute-based scheduled supervisor using installed stock CLI. Saved 26-prefix survived
byte-for-byte; all 30 final hash-chain records verified. Lead and root closed without
operator correction. Counts preserve the injected failures: 3 completed, 2 failed,
2 cancelled. This is fresh-attempt recovery, not same-execution resume. A physical
Windows reboot has **not** been repeated on the reduced candidate; old physical-
reboot passes belong to the fork. Docker Desktop/user task still require sign-in;
pre-login recovery is unverified.

The detached-launch console path was corrected externally using a foreground
stock daemon in a hidden inherited console. Observed startup and 180-second crash/
recovery windows recorded zero visible console events; an off-screen nonactivating
positive control proved detection without changing foreground focus. The proposed
continuous long-run observer did not retain a result, so no full-duration zero-
console claim is made. The final readiness observer covered about 484 seconds, detected its off-screen
nonactivating control (PID50600) with unchanged foreground, and recorded zero
other visible console events.

Stock fixed Office MCP passed with hidden owned Word/Excel, independently verified
spreadsheet formula+cached42, document text and PDF header, without desktop takeover.
This is a no-argument bounded host capability, not arbitrary desktop control. Actual
worktree commit passed after adding the exact .git/worktrees/worktree admin root
alongside .git and starting a fresh attempt. The parent .git grant alone was
insufficient; original checkout/HEAD stayed unchanged. Operator accepted that
isolated smoke after verifying the worker's real commit; it was not autonomous
business-status closure. Prefer in_place for routine work unless a worktree is needed.

The daily contract adds v6 factual review adjudication/no-status-loop rules and
v7 explicit project binding on every lead/worker/reviewer issue. A new v6 readiness
attempt rejected the false finding correctly but omitted project metadata on child
issues; the resulting write denial was legitimate. It is preserved as a failed
configuration/prompt test. The new v7 check uses stronger gpt-6.1-sol/medium decision
roles and Luna/low workers. It passed autonomously in 8m41s: four issues Done,
14 completed runs, two redundant queued runs cancelled, zero failed/active runs
and enabled wakeups. Independent review rejected the false claim; literal quotes,
project bindings and unchanged source/brief hashes were independently checked.
No corrective operator prompt was sent.
Those changes occurred together, so a short pass cannot isolate prompt vs model.
The default eight-hour guard is an operating bound, not an eight-hour test claim.

This improves Multica's maintenance case: it keeps the preferred Windows project/
task GUI and lead-driven hierarchy without carrying an application fork. The
remaining coordination is model/prompt-driven; Swarm still has the stronger explicit
workflow engine. **Swarm's tested pause/recovery configuration still contains its
local fork; the suggested minimal-fork ablation has not been run.** Older sections
below describe earlier dated configurations; their claims that both tools require
forks are superseded for the selected Multica setup. This is not proof that stock
Swarm cannot work or that alternatives cannot improve with integration work.

Evidence: [final trial report](scratch-projects/multica-minimal-2026-11-14/RESULT.md).
Operations and rollback: [local operations README](../../README.md).


The setup is now packaged in the independent `multica-local-ops` repository:
pinned upstream Git fetch/build, local-only Docker Compose, normal local login,
team provisioning, the unchanged Go supervisor, management/backup and finite-goal
helpers, portable settings and summarized findings. Fresh install, repeat install,
disposable adoption preserving workspace/team/issues, backups and stop/start
passed. A real delegated install smoke closed two issues (three completed runs,
one redundant queued run cancelled), with effective never/workspace-write in
both models. The user then explicitly approved main-stack adoption, which is now
complete. Live Compose/private configuration, installed helpers, independent
upstream source and backups are under ~/.multica/local-ops, outside tmp. All six
current agent IDs, instructions, models and custom arguments matched their
pre-migration snapshot. Database counts were unchanged: one user, two workspaces,
129 issues, 68 total agents including archived history and 414 runs. Original
volumes and JWT signing secret were preserved. The local CLI login was renewed
as a normal user PAT; the stock binary matches its manifest and source remains
unchanged. The installed status/full-backup helpers and a fresh headless browser
login loading Local Work passed. The old Compose folder is no longer needed by
running Multica services; historical project files may still be referenced.

The main browser login was fixed to APP_ENV=development,
MULTICA_DEV_VERIFICATION_CODE=888888 and AUTH_TOKEN_TTL=87600h. Request a code for
orchestration-trial@example.test, then use 888888; no delivered email is needed.
Wrong-code rejection, HttpOnly cookie authentication and the server's ten-year
JWT lifetime were verified. Actual Edge browser login on the disposable install
loaded the workspace UI after normal onboarding completion, but Edge capped the
cookie at 400 days. The server TTL is not a ten-year browser-login guarantee.

A new direct browser capability test invoked Playwright-core 1.65.1 and headless
Edge with its own sandbox enabled. Under the native Codex worker Edge exited
before page interaction with TransactNamedPipe/0x6D. The identical fixture passed
outside the worker, including form fill, click, value 42 and screenshot. The
worker execution context is the unresolved difference. No sandbox was loosened;
no browser MCP service is installed. The custom fixed Office host proof is not a
general desktop capability. Other browser engines/Selenium remain untested.

Inspected Multica executions were all Codex; detected Claude/Agy runtimes do not
prove authenticated integration or equivalent permission/recovery support.
Token usage is recorded, but inspected Codex usage had no provider dollar prices.
Cost estimates were not reconciled with invoices and no hard spending cap is
configured or validated. The workshop budget was a planning arithmetic test.
The cleanup guide identifies the old generated home workdir (about 12.8 GiB), old
broker/fork rollback paths, Herdr remnants and 113 Swarm test volumes, while keeping
the active Multica profile, runtime, database and uploads. No old data was deleted.

<!-- END MULTICA REDUCTION UPDATE -->


## Latest Swarm evidence — November 14, 2026 (planned tests complete)

The corrected-role physical Windows reboot test PASSED end to end. Windows and
Linux boot identities changed; the same API/UI/Root/Worker containers started
automatically. The original worker task resumed under a fresh execution, preserved
all 105 pre-reboot checkpoints, appended exactly 12 after the new boot and stopped.
Every one of 117 checkpoint commit blobs/hash-chain prefixes, the saved 88-row
prefix and saved HEAD ancestry were independently verified. The lead respected
the active recovered worker, accepted only after its native dependency completed,
committed real final evidence in commit 419a5cd27568fa79f7b30d72de8feb3a21d09198, and cleaned
up all future fixture timers/redundant queued review. Zero unfinished work,
active sessions or approvals. No manual service restart/task nudge/dispatch after
reboot, new login, desktop takeover or protection change. Test actors stopped.
The earlier physical attempt remains partial; this fresh result closes that gap.

The same pinned v2.13.0 fork (source 68d2fc39/tree14d54794978a, four local commits,
no push) also passed the six-actor mixed-project V4 lasting 2 hours 45 minutes with no corrective
operator prompt/runtime change after intake, all 57 tasks gpt-6-luna/low/capacity1.
Independent Windows/Linux CLI checks (10/10 each), one-hour audit with 10,000 formula-checked unique rows
plus five actual queries on each platform, actual delayed two-hour native human
gate, preserved initial brief, separate revised brief/fresh review, owning-lead
acceptances and real Root Git closure all passed. Final totals were 54 completed and 3 failed tasks,
25 completed and 2 failed runs, zero unfinished/timers; recovered failures stay visible.

The fresh actual API application-process crash test also PASSED: signal after
seven committed checkpoints, automatic same-container restart/health in about
two seconds, unchanged worker execution, exactly 20 rows and 20 actual commits in one
boot/launch/pid, full saved-prefix/history verification, native dependency-gated
Root acceptance/commit 196c8c9ccdc7b5a73f9ad2544db9c6b6ac1f946a and cleanup.
The earlier injector exit127 caused NO SIGNAL and is preserved as an uninjected
control, not recovery evidence. Both actual fault tests used predeclared native
A→B mechanism fixtures; novel planning/delegation is evidenced by V4 separately.

Remaining caveats are substantive. V4 needed native recovery from a code defect,
wrong review-repository checks, missing revision and an owner returning
accepted:true while admitting incompletion. Root missed a completed replacement,
requested redundant reconciliation and only later closed: successful eventual
coordination, with latency/overhead. A Git EROFS was proved to be model commands
targeting the read-only parent control repository instead of its own writable
repo. Audit outputs landed under code/code; actual bytes passed without relocation.
Initial failed review remains untracked; accepted reports have real provenance.
Root-cited review hashes were verified in their actual global review repository.
Readiness observer UID/settings-name corrections did not alter Swarm inputs/tasks.

173 strict API scenarios passed; full unit suite retains reproduced baseline
failures. Source inspection found baseline async agent-task completion bypasses
outer node.outputSchema/node.validation; this separate limitation remains UNFIXED.
Working config.outputSchema enforces task JSON structure, not artifact truth.
Actual independent file/test/Git checks remain necessary. One controlled reboot
and one long fixture do not prove indefinite reliability. Unused V5 smarter-model/
instruction drafts were neither tested nor deployed. Current evidence makes
Swarm a materially stronger candidate than its earlier broken setup suggested;
it does not by itself establish superiority to the other options.

Current control/routing boundaries were rechecked in source68d2: generic
parentTaskId links do not make a cancellation tree (workflow-run subtree
cancellation is separate); confirmed GUI/REST pause/resume supports Linux Codex,
with no native lead MCP pause/resume tool; generic worker followups target the
global lead rather than automatically returning to their project lead. The tested
explicit workflows supply ownership. Older blanket claims that Pause is broken
or nested workflow cancellation is incomplete are superseded for this build.

Current fit judgment: Multica remains the narrow recommendation for the user's
daily project-centered workspace and native Windows worker execution. Swarm is
now a serious primary alternative and has stronger native dependency/recovery
mechanisms. Both passed their configured long/reboot pilots; recovery is no
longer an acceptance gap unique to Swarm. Multica's reboot used a persisted root
timer to start a fresh worker attempt; Swarm resumed the original task natively.
The successful runs share Luna/low but permission setups differ: Multica used
native Windows MXC and a custom owner approval broker; Swarm allowed broad
execution inside role-scoped Docker mounts. Business approval gates are not
command/file-access approval parity. Neither candidate has demonstrated general
background desktop automation; both fixed Office proofs use custom host tools.
At this historical checkpoint both used local forks, explicit coordination/
backstops and maintenance. The stock Multica selection above supersedes that
source-fork requirement for Multica.

Exact local repair diffs are exported in
the patch bundle (historical reference: `orchestration-patches-2026-11-14.zip`; artifact not bundled)
and [patch README](orchestration-patches-2026-11-14/README.md).
The export includes both current cumulative diffs, numbered commit series,
Multica's runtime-only subset, clearly superseded historical Swarm patches,
manifest/checksums and exact-baseline Git-tree reconstruction checks. Source
working trees and live runtimes were unchanged by export; nothing was pushed.

All planned pilot/recovery checks are complete; no further reboot or user action
is required for this test set. Only the local API/dashboard remain running.
Evidence: scratch-projects/swarm-current-pilot-2026-11-12/long-run-v4/RESULT.md,
api-final-2-run/RESULT.md and reboot-final-run/RESULT.md with independent receipts.

---

# Agent orchestration: hands-on results

Current testing update — November 13, 2026

Swarm is now running the local 2.13.0 fork at247acd8d5 (two local repair commits; no push). The full strict API suite passes171 scenarios. Real Luna/low authentication, Windows-mounted output, relative Git worktrees, and GUI Pause→queued correction→same-task Resume have passed. The successful live control repeat preserved32 checkpoint rows and finished at42 after verified process exit and a new execution. Two earlier failures remain recorded: a model target mistake, then a framework initial-correction acknowledgement mismatch that was repaired with strict ownership/generation checks.

The active Windows reboot test is now armed with a live Git checkpoint writer and a native ten-minute lead backstop registered before delegation. Host-reboot recovery, separate crash/approval cases and the clean two-hour mixed pilot are still pending; these results do not yet replace the earlier end-to-end comparison. Optional maintenance schedules and telemetry are disabled; heartbeat/scheduling remain on. No extra provider login or desktop takeover was needed. Native confirmed pause is Linux Codex in Docker; native Windows/other-provider pause remains unsupported. Lead-native steering/cancel and operator GUI pause/resume are separate capabilities.

Current receipts, deployment versions, caveats and continuation instructions: [Swarm pilot status](scratch-projects/swarm-current-pilot-2026-11-12/LIVE-RESUME.md).


## November10 final deep-pilot supplement

The historical October results below remain version-specific. The newer
[Swarm report](scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/RESULT.md)
and [Firstmate report](scratch-projects/orchestration-deep-pilots-2026-11-09/firstmate/RESULT.md)
supersede their interim November statements.

- **Swarm2.5.3:** six-actor code/planning run accepted after timing/Git
  interventions; root independent26-case CLI and12-case Git checks passed.
  Native DAG waits, approvals, restart, retry, crash recovery, steering and
  actual task Cancel passed. Three source fixes are committed, built, deployed
  and live-verified. Pause still runs the provider, parent cancel leaves a
  child, and natural offer rejection remains unresolved. Final independent
  inventory:125 terminal tasks, zero nonterminal tasks/schedules, six idle agents.
- **Windows/container boundary:** shared files and main Git repo work; existing
  Linux linked-worktree pointers fail Windows Git. Container Git2.43 lacks the
  relative-path capability required for the proposed bounded workaround proof.
  No pointers or existing repositories were rewritten.
- **Native Firstmate/Herdr/Claude:** accepted code, planning and hosted-source
  secondmate/scout report after real one-/two-hour gates; independent26-case
  landed-code harness passed. Checkpoint relaunch passed with operator release.
  Normal operational closure failed. A private literal-/exit conversion fix
  passed one supported owned-worker exit, but teardown's700 guard still fails
  on MSYS755. Bearings renders but listener cannot inspect native process
  groups. Optional host stays off after detached-child cleanup failed.
- **WSL Firstmate/Codex:** working reviewed code/planning and one-hour audits,
  but both lifecycle capability gates deliberately return unverified, preventing
  guarded local landing. Closed blocked; no second-hour approval or acceptance.
  No sandbox or lifecycle guard was bypassed.
- **New Herdr GUI:** Firstmate does contain a separate experimental HC adapter.
  It supports ship/scout but refuses secondmates and away daemon. The bounded
  component passed actual hello, labelled terminal and GUI API projection after
  a sixth local source fix. A supported marked lab registered trust-only and
  reached a real Haiku primary turn/home lock/digest. Corrected local-only prompt
  proceeded past informational startup output. After a private tool-PATH fix,
  actual isolated worktree entry succeeded but native core cwd stayed at parent
  shell/project; the required isolation guard failed. Zero scouts/full graphical
  workflow. Native slash-text and foreground PID issues also remain.
- Both candidates passed a custom one-shot background Excel/Word/PDF API with
  independent hidden-instance/file/process checks. This is not bundled general
  desktop control. No host reboot or Multica change occurred.

Full runtime Swarm testing used2.5.3, although2.10.0 was available just before
intake. The late [current-source audit](scratch-projects/orchestration-deep-pilots-2026-11-09/upstream-current/REPORT.md)
found the same defect boundaries with targeted diagnostic tests, not a full
2.10 runtime/suite pass. Its skipped-dependency semantics require adapting the
old SQL patch before porting. See the [intervention ledger](scratch-projects/orchestration-deep-pilots-2026-11-09/INTERVENTIONS.md).

At this earlier checkpoint the strongest tested fit was the configured Multica
fork, with its separate
active-reboot and clean v5 longer-run evidence. Swarm remains the strongest
durable-workflow alternative; Firstmate currently needs more platform work.

Test date: October 24, 2026. This supplements the [expanded research](agent-orchestration-expanded-review-2026-10-23.md). It records observed behavior on this Windows machine, including local workarounds. The bounded survey and targeted follow-up checks are complete; this is not a long-term reliability certification.

Multica has demonstrated the core requested workflow: a coordinator managed a main task with sequential subtasks while an unrelated project ran separately, then accepted a new requirement after the original task finished. Agent Swarm also completed implementation, dependent review, durable continuation, and a late change; its task completion and project separation semantics differ materially. Sudocode's project and relationship UI is useful, but its Windows execution path needed several workarounds and did not reach a verified completed execution state.

Firstmate also completed the staged workflow and late change after documented WSL recovery, including a working browser feedback loop. Cabinet's WSL follow-up demonstrated file execution and a UI-approved native child, but continuation history failed to persist. Stoneforge's UI and basic Codex adapter worked, but its coordinated trial did not complete. Orca produced a validated Beta plan, but sandbox restrictions blocked worker commits and completion reporting. Agent Swarm subsequently passed an abrupt API/worker restart test, including automatic dependency rewiring and review. Multica's corresponding test was blocked before interruption by a reproduced upstream Windows sandbox startup failure.

## Test results at a glance

| Capability | Multica v0.7.0 | Agent Swarm 2.5.3 | sudocode npm 1.2.0, internal packages 0.2.0 |
|---|---|---|---|
| Browser UI | Used live, authenticated workspace | Used live, device OAuth | Used live with two local projects |
| Unrelated projects | Two projects created and executed | Concurrent work tested; separate roots verified through New task | Project switching exercised; one execution attempted |
| Parent and subtasks | Parent with five completed children | Nested lineage including follow-up and approval continuations | Parent relationship displayed and CLI/API exercised |
| Dependencies | Ordered stages and wakeups worked; hard DAG not established | Native dependency held reviewer pending until implementation finished | Blocked-by displayed; scheduling enforcement not established |
| Real execution | Code implemented, tested, independently reviewed | Code implemented, tested, independently reviewed | Codex wrote and verified a file with adapter workaround |
| Completion lifecycle | All seven issues Done | Work finished; deferred/blocked coordinator records also say Completed | Execution remained pending despite final reply |
| Late change | Parent reopened, new children, parent closed | Linked follow-up children; parent stayed Completed; five tests passed | Not tested |
| Windows path | Original MXC run passed; follow-up blocked by upstream sandbox startup error | Linux Docker workers; startup env alias required | Launcher, worktree, and console-window problems |

| Candidate | Additional verified evidence | Remaining boundary |
|---|---|---|
| Firstmate | Two repositories, separate workers and reviewer, five final tests, retained-worker follow-up, browser feedback acknowledgement | WSL setup/recovery required; runtime probes remained unknown; no nested secondmate test |
| Cabinet 0.5.0 | Live onboarding, heartbeat control, WSL file execution, UI-approved native child with inherited Luna model | Docker sandbox blocked; WSL child needed absolute-path correction; successful continuation artifact was not persisted in conversation history |
| Stoneforge 1.25.0 | Dependency UI, saved plan progress, successful modified Codex adapter, actual attempted coordinator/workers | Coordinated trial incomplete; CLI/recovery issues and sandbox-local-network restriction |
| Orca 1.4.239 | Browser client on WSL, two Git projects, nested worktree, separate Runs, parent/dependency records, archived failed-worker recovery | Host/client setting distinction required API configuration; Alpha retry limit exhausted; Beta produced a valid plan but worker commit and completion reporting failed |

## Multica

The deployment uses the official v0.7.0 Docker services, bound to localhost, with a dedicated CLI profile and synthetic workspace. The Windows CLI is v0.7.0, commit `dbdbb2991`. The source inspection checkout is `3de79cbeaf181283765f850327e9d82a3b2af6b0`; source findings should be distinguished from release behavior. Existing Codex authentication was available. Other runtimes were detected, but detection does not establish successful authenticated execution with them.

### What actually ran

Mika created two projects: **Trial Alpha - CSV utility** and **Trial Beta - event planning**. Alpha had ORCH-1 as its parent, with ORCH-2 defining behavior, ORCH-3 implementing it, and ORCH-4 reviewing and testing it through a separate agent. Beta had ORCH-5 producing a four-person board-game evening checklist with a $40 food allocation. No purchases or external messages were part of the test.

ORCH-2 and ORCH-5 were observed working concurrently. The CSV implementation and review stayed in backlog until their predecessors completed. Stage-completion wakeups resumed Mika after its chat response ended. The original CSV suite passed four tests; all five original issues finished Done.

A second request added a meaningful regression test: ignore exactly one leading Unicode BOM, treat BOM-only input as empty, and preserve BOM characters elsewhere. Mika reopened the existing parent, created ORCH-6 for implementation and ORCH-7 for independent review, and retained the original project and history. Both children completed and ORCH-1 returned to Done. The supplied test failed before implementation and passed afterward. A separate local `npm test` confirmed **five passed, zero failed**. The original README, package manifest, and tests were preserved.

The synthetic repository contains the implementation and tests in commit `6f035ab` (`Complete staged CSV orchestration trial`). Its working tree was clean when checked after the run.

### UI and practical tradeoffs

The board/list views support grouping by project, status, and assignee, filtering, and showing subissues. Parent details show stage groups, subissue progress, properties, activity, wakeups, and execution history. Expandable tool traces make it possible to verify what a worker actually did. Agent forms expose instructions, runtime, model, skills, and access controls. The sidebar also exposes squads, autopilots, runtimes, and analytics; their presence is not a completed test of those features.

The strongest benefit is continuity: work continued after the coordinator's chat turn, and a later change was attached to the same deliverable. The distinction between project, task, and worker remained visible throughout the test. The completion report named actual commands and results, rather than merely reporting that an agent had stopped.

The main limitation is that this trial used agent-mediated sequencing. Mika reported no CLI-native dependency links and implemented the requested order through stages, backlog promotion, and persisted wakeups. That succeeded here, but does not establish arbitrary DAG enforcement. The trial also showed repeated coordinator wakeups that checked an already-satisfied handoff; they did not duplicate the implementation but added activity and overhead.

Coordination was substantial for a small coding task. The parent issue's final UI showed **8 runs, 4.8M reported tokens, 13m 15s agent time, and $6.46 estimated cost**. These are the application's counters for that parent, not a measured invoice, unique-context count, or total across all workers. Initial planning and interruption recovery affected the trial, so this is not a clean benchmark. It is nevertheless a reason to test a larger representative task and inspect context reuse before adopting it broadly.

The repository was attached in place. This did not test isolated worktrees, conflicting edits, PR creation/merging, reboot recovery, or nested coordinators beyond one parent level. A forced stop during the UAC investigation produced an in-flight failure and a queued retry after daemon restart; that observation is narrower than a general recovery guarantee.

### Repeated Windows UAC prompts

The inherited Codex configuration selected the elevated Windows sandbox. Multica creates separate task-local Codex homes, and those homes had separate sandbox setup markers. This explains the repeated setup prompts encountered during worker execution.

The fix used here was a **per-agent** argument, `-c windows.sandbox=mxc`, on Mika and both test workers. Global Codex settings were not changed. The installed Codex 0.164.0 passed the documented MXC probe, and subsequent worker process arguments contained the explicit override. The remaining implementation and follow-up tests completed with it.

OpenAI's [Windows sandbox documentation](https://learn.chatgpt.com/docs/windows/windows-sandbox) describes MXC and its administrator-free setup. This is a tested configuration on this machine, not a claim that every Windows installation supports MXC. Explicit `mxc` was used rather than a fallback setting that might return to elevated setup.

### Evidence

- Two projects working concurrently (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/multica-two-projects-running.jpg`; artifact not bundled)
- Board grouped by project (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/multica-board-by-project.jpg`; artifact not bundled)
- Staged subtasks (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/multica-staged-subtasks.jpg`; artifact not bundled)
- Final follow-up completion (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/multica-followup-complete.jpg`; artifact not bundled)
- Final issue records (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/multica-issues-final.json`; artifact not bundled)
- Parent completion record (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/multica-parent-completion.json`; artifact not bundled)
- Independent review record (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/multica-independent-review.json`; artifact not bundled)

Image reference: Multica follow-up completion and execution counters (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/multica-followup-complete.jpg`; artifact not bundled)

## sudocode

The browser UI successfully exposed local projects and issue relationships. A synthetic migration parent, schema task, and dependent API task established that parent and blocked-by links are represented in the UI and persisted through the CLI/API. See the dependency inspector screenshot (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/sudocode-dependency-inspector.jpg`; artifact not bundled).

Real execution was attempted on issue `i-15vv`, asking Codex to read the synthetic README, write `trial-result.txt`, and verify its exact contents. The requested content, `SUDOCODE_EXECUTION_OK`, was present on disk and the live trace showed the read, write, verification, and final response. However, the UI and execution database still reported **pending**, with no completion timestamp. The server was then stopped following the console-window complaint. This is a successful file-operation test with an unresolved lifecycle problem, not a successful end-to-end execution test.

### Windows failures and trial-only changes

1. **Adapter startup:** installed `acp-factory` 0.1.15 spawned `npx` directly. An equivalent Windows Node spawn probe failed with `ENOENT`. The trial wrapper registered a direct Node entry point for the maintained `@agentclientprotocol/codex-acp` 2.2.2 adapter, replacing the deprecated adapter path. This was a modified execution path, not stock sudocode behavior.
2. **Worktree startup:** the application reported `Target branch does not exist: main` even though Git confirmed the branch existed. Its Git helper used `--format='%(refname:short)'` in a shell command, a Windows quoting problem identified in source. Run Local bypassed this failure; worktree execution remains unvalidated.
3. **Visible console:** the adapter launcher spawned a detached process without `windowsHide`. The trial installation now adds `windowsHide: true`; the patched JavaScript passes `node --check`. The fix has **not** been rerun through the UI, so suppression of the popup is not yet established.
4. **Pending status:** changing adapters may affect lifecycle compatibility. The cause of the pending execution status remains unresolved and should be diagnosed before recommending this configuration.

The trial wrapper binds the server to loopback and supplies the MXC sandbox setting only to its adapter process. The original source checkout was not patched. The installed runtime package has a local hidden-window patch saved at acp-factory-windows-console.patch (historical reference: `scratch-projects/orchestration-trials-2026-10-24/acp-factory-windows-console.patch`; artifact not bundled). The wrapper is sudocode-loopback.mjs (historical reference: `scratch-projects/orchestration-trials-2026-10-24/sudocode-loopback.mjs`; artifact not bundled). All matching sudocode trial Node processes were verified stopped after the popup report.

The useful distinction from Multica is sudocode's explicit issue relationships and repository-local records. On this machine, that benefit is currently offset by several execution integration problems. A Linux/WSL test may behave differently, but it has not been performed and should not be presented as a confirmed solution.

## Agent Swarm

The authenticated trial runs official Agent Swarm **2.5.3** API, UI, and slim worker images in Docker, with the browser at `http://localhost:43150`. The source checkout is `77039db514cb98f8a8562a84084fb092a474544d`. A coordinator, coder, and independent reviewer use Codex 0.164.0 through the built-in provider integration. The user completed device OAuth in the setup UI; an OpenAI API key was not required. The dashboard identified the coordinator/reviewer model as GPT-5.6 Terra and the late-change coder as GPT-5.6 Luna. These differ from Multica's model, so costs and durations are not controlled comparisons.

All work was synthetic and local to the trial's shared Docker volume. Workers had no host project mounts or Docker socket. The Codex adapter selects `danger-full-access` and `approval_policy=never` inside those containers; this is relevant to deployment design, even though it avoided Windows sandbox setup prompts here. External integrations and recurring heartbeat work were disabled. The initial worker startup needed an `API_KEY` environment alias: the entrypoint checked that name even though the deployment supplied `AGENT_SWARM_API_KEY`. No application source patch was needed.

### Verified initial execution

The coordinator created an Alpha CSV definition task, an implementation task depending on definition, and a reviewer task depending on implementation. The reviewer remained pending while implementation ran. The workers produced `csv.mjs`; a separate command in the reviewer container confirmed **four tests passed, zero failed**. The independent review also checked hashes of the supplied README, package manifest, and tests.

An unrelated Beta board-game planning task ran alongside Alpha's definition work and produced a four-person checklist with a $40 food allocation. However, it inherited Alpha's parent despite the prompt asking for a separate top-level task. The coordinator noticed, cancelled the first Beta, and recreated it, but the replacement inherited the same parent. This is a real limitation of that dispatch path, not evidence that the whole application cannot hold multiple root tasks: [`send-task.ts`](https://github.com/desplega-ai/agent-swarm/blob/77039db514cb98f8a8562a84084fb092a474544d/src/tools/send-task.ts) computes `parentTaskId ?? sourceTaskId`. Omitting the parent while dispatching from a task therefore attaches the new work to the current task.

The practical workaround was verified afterward: creating Beta through the dashboard's New task form produced task `e06482a0-093c-4694-b0a9-352a926fb5d7` with `parentTaskId: null`. It completed independently with a correct $40 arithmetic total. Thus multiple unrelated root tasks work; the coordinator's default dispatch path did not create them from a single combined request. Tags supplied project labels in this trial rather than a dedicated project object.

Durable continuation worked. The coordinator deferred until review settled, the scheduler created a new continuation task automatically, and that task collected the review's PASS result. No manual follow-up was needed to trigger that initial continuation.

### Task completion semantics and late changes

Swarm's task status needs careful interpretation. [`defer-task.ts`](https://github.com/desplega-ai/agent-swarm/blob/77039db514cb98f8a8562a84084fb092a474544d/src/tools/defer-task.ts) calls `completeTask` before creating a future continuation. Consequently, Alpha's parent showed Completed while its review was still outstanding. The output explained the wait, and the continuation later succeeded, but a Completed badge alone did not establish completion of the whole deliverable.

A late BOM requirement was submitted through the completed parent's follow-up composer. This created a linked child task rather than reopening the parent. The supplied regression test failed first, with four passes and one failure. The coordinator then asked for coding guidelines for the unregistered local project and marked the follow-up Completed with a blocked explanation. I answered its approval form using the existing trial rules: `npm test`, independent review, supplied-file hash preservation, one implementation-file change, and no merge or external actions. Submitting that form automatically created a coordinator continuation. It dispatched a coder task and a reviewer with a native dependency. Both finished, and another automatic continuation collected the PASS result.

I independently reran `npm test` in the reviewer container after completion: **five passed, zero failed, exit code 0**. All four supplied-file SHA-256 hashes matched the preserved baseline. The implementation and late test were copied into the local trial evidence folder. The task tree retained the original parent, the follow-up, the approval continuation, worker children, and final coordinator continuation; it did not reopen the original parent as Multica did.

The ChatGPT restart did not remove the local dashboard session, worker authentication, or persisted tasks. Browser control was reconnected successfully. This does not constitute a Docker restart or machine reboot recovery test.

### UI observations and limits

The live UI offers task tables and a board, filters, priorities, tags, native dependency selection, model tier and reasoning controls, expandable tool traces, follow-up input, approval forms, and a task lineage graph. The lineage graph displayed actual parent-child records, agents, statuses, durations, costs, and dependency counts. It is useful for inspecting nested work. Long prompt text overflowed the breadcrumb at the tested window width, and the task heading was empty; task prompts remained available through a separate control.

The workflow screen displayed ten seeded, disabled workflows and a graph with Definition, Setup, Triggers, Runs, and Versions views. This establishes UI availability, not a successful run of the workflow engine. Memory, Pages, Apps, Sessions, integrations, schedules beyond the observed continuation, and custom workflow execution have not been fully exercised. The optional agent-fs/storage services were not deployed, so file-sharing and memory claims should not be inferred from this trial.

Compared with Multica, the native dependency records and lineage inspection are strong. The tested interface made project separation less explicit, and the Completed-versus-deferred behavior required more interpretation. Both initial and late-change coding pipelines succeeded. Before the final standalone-root check, the sidebar showed $1.81 estimated usage for the day; this is an application estimate, not an invoice or comparable benchmark.

Evidence:

- Initial completed lineage (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/agent-swarm-lineage-complete.jpg`; artifact not bundled)
- Task creation controls (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/agent-swarm-task-form.jpg`; artifact not bundled)
- Approved coding guidelines (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/agent-swarm-guidelines-approved.jpg`; artifact not bundled)
- Verified follow-up completion (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/agent-swarm-followup-complete.jpg`; artifact not bundled)
- Final continuation record (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/agent-swarm-followup-completion.json`; artifact not bundled)
- Separate root task record (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/agent-swarm-standalone-root.json`; artifact not bundled)
- Initial task records (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/agent-swarm-initial-tasks.json`; artifact not bundled)
- Latest task records (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/agent-swarm-current-tasks.json`; artifact not bundled)

## Firstmate

Firstmate's source checkout is `d22640f478e3392313e27b04fb41de12bd25d2e7`. The real trial uses the existing Ubuntu WSL distribution, an isolated `FM_HOME`, a separate tmux server, and two synthetic Git repositories with local bare origins. Supporting tools were installed in the trial directory. Treehouse placed its allocated worktrees in its default WSL location, `/home/brennan/.treehouse/`; those are synthetic trial worktrees, but they are outside `FM_HOME`.

The primary runs through `codex exec` with an event log, so this is not a fully inspected interactive primary TUI. The workers are actual interactive Codex sessions in tmux; their rendered terminal text was inspected through tmux capture. They used GPT-6.1-Sol, low effort for implementation/planning and medium for independent review. The user signed in once for this trial. GitHub authentication was unnecessary for local-only work.

### Initial workflow and recovery

Firstmate created persistent Alpha parent, implementation, and review records, plus an unrelated Beta task associated with its own repository. Alpha and Beta workers ran concurrently in separate worktrees. Alpha committed a CSV implementation; a different reviewer checked out that exact commit in a second worktree and independently tested it. Beta committed a four-person evening plan whose ten allocations correctly sum to $40. Commit identities matched the user's configured name and email with no co-author.

My independent `npm test` run reported **four passes, zero failures**, and all supplied-file hashes matched the baseline. Worker `npm test` output counted one passing file-level test in that execution environment; the reviewer separately ran the file and confirmed all four named tests, then checked twelve additional valid inputs and four rejection cases. This distinction was retained in the report rather than equating the file count with the number of assertions.

The successful result required setup recovery:

1. The primary's sandbox initially denied the tmux socket. Scoped automatic approval allowed the normal spawn operation.
2. New tmux windows did not inherit the isolated `CODEX_HOME`, so both workers stopped at a sign-in chooser even though the primary was authenticated. The trial-only Codex wrapper now supplies that directory when unset; the supervisor also set it in the trial tmux session.
3. Firstmate's guarded relaunch refused the sign-in screen because its composer state was unknown. After verifying clean worktrees and idle sign-in processes, I stopped only the two native Codex processes. The supervisor then successfully used normal `fm-control` relaunch in the same worktrees and handled the ordinary folder-trust prompts. No additional login was needed.

This is therefore a successful trial **after operator-assisted recovery**, not a stock unattended success. The original source checkout was not patched. The local configuration selected `approve-for-me`, retaining workspace sandboxing and automatic review; Firstmate's documented default is to bypass approvals and sandboxing. Shared Git metadata and report writes required reviewed escalations. No Windows UAC or visible Node console was needed for this WSL trial.

### Continuity and interface

The late BOM regression test was added to the retained implementation worktree and independently failed first: four passes, one failure. The supervisor reopened the same Alpha records and steered the retained implementation worker, which committed a one-line parser change plus the unchanged supplied test as `5872a02`. It then steered the retained independent reviewer to that exact commit. Beta was not rerun. The reviewer passed the supplied tests and fourteen explicit BOM assertions. My final independent `npm test` confirmed **five passes, zero failures**, with unchanged original supplied-file hashes and a clean implementation worktree.

In the observed records, the parent association was written in task bodies, while blocked-by relationships were explicitly recorded and cleared by the supervisor. This establishes persistent tracking and successful sequencing; it does not establish a native parent-child graph or scheduler-enforced arbitrary DAG. The underlying tasks-axi format supports additional relationship types, but those were not demonstrated in this run.

Firstmate is not limited to tmux presentation: its bundled Bearings skill generated a browser fleet and decision board through Lavish. I inspected the live page and its four sections: Captain's Call, Charted Next, Underway, and Recently Landed. It includes a dispatch-order control and a conversation/annotation sidebar. With no decisions or queued work in this trial, decision cards and dispatch ordering were not exercised. It did not present the same task-editing workflow as Multica or Swarm.

Two additional Windows/WSL fixes were needed for that board. The checked-out HTML template had CRLF endings, which broke the builder's exact placeholder match; a temporary LF-normalized copy was supplied through the builder's template override. Then feedback registration refused the NTFS-backed state directory because it appeared as mode 777 and `chmod 700` had no effect. I copied only the finished trial's state into `/home/brennan/.local/state/orchestration-firstmate-trial-20261024`, set private permissions, retained an exact NTFS backup, and left a symlink at the original state path. The normal builder then reported the session live, bound, and armed. No privacy guard was disabled. This supports putting operational state on WSL's native filesystem for this setup, rather than assuming a Windows-mounted directory behaves like Linux storage.

The browser feedback path was tested end to end: I submitted a read-only marker, resumed the supervisor to handle its durable feedback event, and verified its acknowledgement appeared in the board conversation. This proves capture and reply through the integration; it does **not** prove an ended headless primary automatically resumes. The bounded primary subsequently finished, and the UI correctly returned to a not-listening state. The board remains available at [the local trial URL](http://127.0.0.1:4387/session/cd23b01f22f54311).

The board still classified the three retained endpoints as Underway with `unknown codex-unverified`, despite the backlog's completed records and verified deliverables. The review also appeared in Recently Landed. Unmerged branches and retained endpoints were intentional trial constraints; nevertheless, the distinction between deliverable completion and runtime state was less immediately clear than in the project-oriented UI. The board faithfully exposed the probe's uncertainty instead of inventing a known idle state.

The source documents Codex's foreground supervision checkpoints, and the trial used 30-second checkpoints. The actual state probe returned `unknown/codex-unverified`; completion was established from terminal reports, task status events, tests, and Git refs. Repeated watcher-down messages appeared around checkpoint gaps. Away-mode supervision, remote secondmates, nested coordinators, and machine-restart recovery were not tested. Its [configuration documentation](https://github.com/kunchenguid/firstmate/blob/d22640f478e3392313e27b04fb41de12bd25d2e7/docs/configuration.md) also excludes local-only projects from secondmate routes, which matters if considering delegated project managers for entirely local repositories.

Evidence:

- [Supervisor's trial summary](scratch-projects/orchestration-trials-2026-10-24/firstmate/trial-summary.md)
- Independent initial review (historical reference: `scratch-projects/orchestration-trials-2026-10-24/firstmate/data/trial-alpha-review/initial-report.md`; artifact not bundled)
- Independent follow-up review (historical reference: `scratch-projects/orchestration-trials-2026-10-24/firstmate/data/trial-alpha-review/followup-report.md`; artifact not bundled)
- External verification of final tests (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/firstmate-followup-independent-tests.txt`; artifact not bundled)
- Beta completion report (historical reference: `scratch-projects/orchestration-trials-2026-10-24/firstmate/data/trial-beta-plan/report.md`; artifact not bundled)
- Trial launcher (historical reference: `scratch-projects/orchestration-trials-2026-10-24/firstmate/run-primary.sh`; artifact not bundled)
- Live board and verified feedback reply (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/firstmate-bearings-feedback.jpg`; artifact not bundled)
- Private-state migration and board setup (historical reference: `scratch-projects/orchestration-trials-2026-10-24/firstmate/prepare-native-state.sh`; artifact not bundled)

Image reference: Firstmate Bearings browser board and feedback acknowledgement (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/firstmate-bearings-feedback.jpg`; artifact not bundled)

## Cabinet preparation

Cabinet 0.5.0 is running in an isolated Docker container at `http://localhost:43160`, with its daemon on localhost port 43161. Newly created Docker volumes hold the synthetic files, app cache, and Codex credentials; no host projects or credential stores are mounted. The source inspection checkout declares 0.5.3, but npm's published `cabinetai` latest was 0.5.0, so release behavior must be distinguished from the newer source checkout. The initial attempt to install CLI 0.5.3 failed with npm `ETARGET`; the verified published version built successfully.

The user completed the isolated Codex device login. A direct sandboxed execution returned `CABINET_SANDBOX_AUTH_OK`, and login survived the subsequent container rebuild. The live onboarding recognized Codex as “Logged in using ChatGPT / Ready.” No Cabinet agent execution or orchestration result is claimed yet.

Cabinet's Verify button was rejected by automatic approval review because it launches Codex with `--dangerously-bypass-approvals-and-sandbox`. Source inspection found the same hardcoded flag in its provider and local adapter. Rather than retry that action, the trial image now supplies a launcher that removes that flag and runs Codex with `--sandbox workspace-write --ask-for-approval never`. A separate verification through that launcher returned `CABINET_WRAPPER_OK`; the CLI explicitly reported workspace-write sandboxing. This is a modified trial execution path, not stock Cabinet behavior. The app source is unchanged.

Onboarding includes a first cabinet, named agent, agent instructions, heartbeat switch, and optional initial task. I configured Alpha CSV trial and Trial Coordinator, disabled recurring heartbeat work, and left the first task empty pending fixture preparation. The wizard also includes GitHub, Discord, and cloud-waitlist promotions; none were joined. Reloading before completion restarted the wizard, requiring re-entry of its temporary configuration.

The final Launch Cabinet screen requires an unchecked “I have read and I accept” checkbox and states that continuing agrees to its Terms and Privacy policy. This needs the user's action-time confirmation under the computer-use confirmation rules. The user is away, so setup remains at that screen, with optional contact enrollment unchecked. Authentication is complete; acceptance and a real Cabinet workflow remain pending. The displayed example agent conversation is onboarding illustration, not execution evidence.

Evidence: final onboarding screen (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/cabinet-terms-handoff.jpg`; artifact not bundled), sandbox launcher (historical reference: `scratch-projects/orchestration-trials-2026-10-24/cabinet/codex-sandbox-wrapper.sh`; artifact not bundled).

## Stoneforge: UI and bounded execution

The installed 1.25.0 dashboard ran on Windows at `http://127.0.0.1:43170`, using the earlier synthetic CLI-test database. It loaded four default agents and explicitly reported its daemon disabled because the fixture was not a Git repository. No Windows agent process was launched.

The task list exposed list/kanban controls, filters, sorting/grouping, assignment, priorities, branches, and distinct awaiting-merge and closed states. The API subtask inspector displayed its completed schema prerequisite as “1/1 resolved.” I created a draft “Migration trial plan” containing those two existing tasks, and its detail panel correctly calculated 50% completion: one completed, one remaining, zero blocked. This was real persisted UI work, not sample content.

The Agents form distinguishes directors, ephemeral workers, persistent human-supervised workers, and stewards. The inspected steward form offered merge, documentation, recovery, and custom roles plus cron/event triggers. The worker settings exposed tags, Claude Code/OpenCode/Codex providers, model selection, and an optional executable path. Codex's model list contained only Default in this Windows runtime. No agent was created or started from that form.

“Workspaces” is explicitly a terminal multiplexer, with single-layout and add-pane controls. It is not evidence of a project switcher. Documentation initializes a `.stoneforge` database in each project root; a unified manager for multiple unrelated roots remains unproven.

A separate WSL runtime was installed in the trial directory to avoid Windows agent console behavior. Its `node-pty` dependency initially failed because `make` was absent; installing Ubuntu's standard make/g++ build tools resolved that installation failure. The installed Codex provider sends `sandbox: 'danger-full-access'` on both new and resumed app-server threads despite the earlier approve/restricted fixture configuration. The trial-only installed provider was patched to `workspace-write` in both places; a saved original and preparation script document the change. Stock source was not modified.

Using the already authenticated Firstmate trial Codex environment, a bounded execution through Stoneforge's actual `CodexHeadlessProvider` created and read `probe.txt`. The adapter emitted tool results, assistant output, and a successful completion event; an independent exact-content check passed. This confirms modified-adapter execution with Codex 0.164.0 in WSL. It does not establish scheduling, merging, interruption recovery, or a complete multi-agent workflow.

Evidence: dependency inspector (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/stoneforge-dependency-inspector.jpg`; artifact not bundled), worker form (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/stoneforge-worker-form.jpg`; artifact not bundled), saved plan (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/stoneforge-plan-created.jpg`; artifact not bundled), bounded execution probe (historical reference: `scratch-projects/orchestration-trials-2026-10-24/stoneforge/probe.mjs`; artifact not bundled), execution events (historical reference: `scratch-projects/orchestration-trials-2026-10-24/stoneforge/probe-events.log`; artifact not bundled).

The subsequent full WSL workflow trial did **not** complete. Its separate project at port 43171 contained Alpha/Beta directories inside one Git repository, with all agents configured for Codex and the merge steward disabled. The coordinator created an Alpha plan, three staged Alpha tasks, a separate Beta task, and blocked-by relationships. The server launched actual Codex workers in retained worktrees. Partial definition and evening-plan files appeared, but all worktree refs still pointed to the initial fixture commit when independently inspected; there is no successful implementation/review or late-change result.

Three observed problems explain the failed attempt. First, `sf agent start --provider codex` fell back to an unauthenticated provider: the inspected CLI handler defines provider/model options but omits them from its spawner call. Starting through the normal server endpoint correctly selected Codex from saved metadata. Second, orphan recovery launched the assigned review task before an implementation existed and later supplied a Stoneforge `session-...` ID where Codex requires its thread UUID; the server logged the rejection and fell back to fresh sessions. Third, the tightened workspace sandbox denied the coordinator's local HTTP socket. That last restriction is specific to the modified sandbox setup and must not be called a stock Stoneforge defect. The direct adapter probe's successful file write did not establish that the full orchestration control path would work under the same sandbox.

I supplied the coordinator with the server-start workaround, then stopped the dispatch daemon and remaining sessions to prevent repeated attempts. The final active-session query was empty, and retained files/branches were preserved. Director messages (historical reference: `scratch-projects/orchestration-trials-2026-10-24/stoneforge/director-messages.json`; artifact not bundled), server log (historical reference: `scratch-projects/orchestration-trials-2026-10-24/stoneforge/server.log`; artifact not bundled), and final tasks (historical reference: `scratch-projects/orchestration-trials-2026-10-24/stoneforge/final-tasks.json`; artifact not bundled) retain the evidence. This candidate currently has useful UI/task evidence and a successful basic adapter probe, but an unsuccessful coordinated trial.

## Orca browser trial preparation

The [official v1.4.239 release](https://github.com/stablyai/orca/releases/tag/v1.4.239) was downloaded as its Linux AppImage and extracted in the trial folder. This is newer than the source checkout used in the earlier review. Its CLI initially lacked `libnspr4`, `libnss3`, and ALSA libraries in WSL; installing those standard Ubuntu runtime packages resolved CLI startup. The app's own runtime selector prepared its pinned Node runtime and `orcad` build `0.1.0+d004f83ee8a3` in a separate private WSL profile.

The official headless server was launched directly with `--bind 127.0.0.1`, port 43180, and the shipped web-client directory. This preserves pairing authentication and avoids the CLI serve path's default all-interface bind. The browser successfully paired with the local trial and displayed Projects, workspaces, Tasks, Automations, Explorer, Agents, source control, and checks. No desktop-control permission was granted. The runtime reported a healthy PTY self-test; it also warned that systemd linger is off, so daemon survival across a service restart is not established. Native Windows UI control is therefore not required to inspect this Orca path, although this is a Linux/WSL browser trial, not proof of the native Windows desktop experience.

I added two unrelated synthetic Git repositories through the live browser's host filesystem picker. Both appeared in the sidebar with their own primary workspaces. The supervised worker-start command created a visibly nested Alpha child worktree at `/home/brennan/orca/workspaces/alpha/alpha-definition`, outside the trial folder according to Orca's default workspace location. The CLI also created separate Alpha and Beta Runs, an Alpha parent with three child tasks, and explicit definition → implementation → review dependency records. These records were driven by me as the test coordinator, not by an autonomous coordinator agent. After the definition startup failed, implementation and review remained pending, with null results.

The initial Agents settings screen defaulted to Full access. I selected Approve for me and a trial launcher in the browser. However, locally issued server CLI launches still used the host's original command/full-access setting and stopped at an unauthenticated chooser before receiving their task. Inspection of the actual process arguments and authenticated `settings.getAgentLaunch` RPC confirmed the mismatch. The browser's account page also described Windows accounts despite this being a paired Linux host. This establishes a distinction between these browser settings and the local server CLI path; it does not establish that all browser-initiated launches ignore the setting.

I used the normal authenticated local `settings.mutateAgentLaunch` API to set the host's Codex permission to `auto` and its command to a trial-only launcher that points to the existing authenticated Firstmate trial home and rejects full-access arguments. Readback confirmed `--approve-for-me`. Orca's stock source and binaries remain unchanged, but account routing now uses a custom launcher and host setup required API work. The next attempt passed authentication and stopped at ordinary folder trust for the synthetic Alpha repository. No additional user login was requested.

Orca's failure receipts identified `agent_readiness`, retained resource IDs, and a recovery command. I exercised `worker-release` on the two login-blocked attempts: it captured an archive and closed only the associated agent terminal. The current third attempt is marked failed and retains its terminal at the trust screen. A fresh screenshot showed “Trust and continue” selected, and the terminal textarea was empty, but automatic approval review rejected the Enter keypress twice because it could not establish the terminal state or scope of the persistent trust decision. I did not send the key through another tool or edit trust configuration. The user can complete this prompt after returning; the task will still need an explicit retry after trust is established.

The remaining UI has been preserved at `http://127.0.0.1:43180`. No Orca worker has executed the synthetic task, so completion, review, late-change continuity, and nested autonomous coordination remain untested. Orca's own embedded browser automation backend is also unavailable in this headless profile without a Chromium executable; that is separate from the successfully tested external browser client.

Evidence: trust handoff and nested workspace (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/orca-folder-trust-handoff.jpg`; artifact not bundled), creation receipts (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/task-receipts.json`; artifact not bundled), parent and dependency records (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/alpha-task-list.json`; artifact not bundled), host-setting verification script (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/configure-host.mjs`; artifact not bundled), authenticated startup receipt (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/alpha-definition-host-retry.json`; artifact not bundled).

## Post-handoff execution results

The user completed Cabinet onboarding and Orca Alpha folder trust. Cabinet's actual workspace appeared with Data/Team/Tasks drawers, agent configuration, routines, heartbeats, channels, a schedule, a task composer, and Chat/Artifacts/Diff/Logs views. The default Editor had a weekday heartbeat despite the custom coordinator's heartbeat being off. I paused the whole team through its switch; the toast confirmed that future scheduled work was paused, and the home control changed to Start All. The Next-up list still displayed scheduled entries. Manual task submission remained available.

Cabinet's first real CSV task failed immediately on `gpt-5.5`. Selecting `gpt-5.3-codex` in the UI also failed with the CLI's unsupported-model-for-ChatGPT-account error. The model picker did not offer the already verified `gpt-6.1-sol`. The normal conversation continuation API accepts a model string; supplying that override started actual model execution without changing app source. Conversation: `2026-10-24T22-21-31-164Z-a644dc72-trial-coordinator-manual`.

Every attempted shell command then failed with `bwrap: No permissions to create a new namespace`. The coordinator reported that delegated implementation and review attempts encountered the same failure, zero tests ran, and no Cabinet-native task API was available to it. These were reported Codex delegation paths and locally invented tracking IDs, not demonstrated Cabinet-native child tasks. Independently listing the fixture directory showed only the three supplied files; SHA-256 hashes matched the originals. No definition, implementation, or review artifact was produced. This limitation belongs to the modified sandboxed Docker trial; it is not proof of a stock Cabinet execution defect. A WSL trial or a compatible sandbox environment would be needed to continue fairly.

The final Cabinet UI showed Idle and offered Mark done despite the agent explicitly reporting a blocker; I did not mark it done. It correctly displayed the executed model as `gpt-6.1-sol` in the header, but the next-turn picker reset to GPT-5.5. Its context meter showed 213.6k / 200k and the response badge 408.6k tokens; these are UI readings, not independently validated token accounting. Execution screenshot (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/cabinet-execution-blocked.jpg`; artifact not bundled).

Orca's Alpha terminal reached the authenticated prompt after user trust. The failed dispatch remained failed. `worker-release` returned retained/user_takeover and did not close the now user-owned terminal. Retrying through the documented worker-start flow returned `task_not_startable`: three earlier startup failures exhausted the task retry limit, including failures before any task prompt ran. I did not reset internal state or create a replacement to evade this limit. Retry receipt (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/alpha-definition-trusted-retry.json`; artifact not bundled).

The previously created independent Beta task was attempted once and stopped at its own folder-trust prompt (`ctx_0c7969c8739d`). Alpha trust does not trust this unrelated repository. Beta receipt (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/beta-start.json`; artifact not bundled). Selecting its terminal through the browser was rejected by automatic approval review because the tab's accessible name includes its Close tab child and was interpreted as potentially closing an ambiguous terminal. No close action or trust bypass was performed. Both product pages remain available, with no completed Orca deliverable claimed.

### Beta approval and actual Orca execution

After the user approved Beta folder trust, retrying the existing task succeeded: dispatch `ctx_f6ae87b527a3` reached `input_accepted` with `turnStart: observed`. Codex read the synthetic README and wrote plan.md (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/projects/beta/plan.md`; artifact not bundled), including a timetable for four adults and a no-cost indoor fallback. Independent arithmetic confirmed the ten itemized allowances total $32, plus an $8 cushion equals the $40 maximum. Prices are explicitly planning estimates; no external services or purchases were required.

End-to-end orchestration still failed. The worker could not commit because `.git/index.lock` was read-only in its sandbox. Its Orca CLI also returned `runtime_unavailable`; supplying the correct isolated profile through a normal terminal follow-up did not resolve connectivity. The outer coordinator CLI remained functional. The exact cause of the worker's RPC failure was not established. The worker stopped and reported these limitations honestly. The authoritative task record remained `dispatched`, with `result: null` and no completion timestamp, despite the generated artifact. This is not a successful completion/reporting cycle.

After independent review, I committed only `plan.md` using the configured user identity as `3a4018c2608ea41c16713aea0d94c5b639540b66`. This was external manual intervention, not a successful worker commit. I then used Orca's normal worker-stop operation; it reported `stopped` and closed the supervised agent terminal while retaining the files. The browser opened the generated plan in its editor. This establishes real Orca task execution and an artifact, but not autonomous coordination, dependency progression, or reliable result reporting under this trial setup.

Evidence: accepted retry (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/beta-trusted-retry.json`; artifact not bundled), worker output (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/beta-progress.json`; artifact not bundled), pre-stop task record (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/beta-final-tasks.json`; artifact not bundled), stop receipt (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/beta-stop.json`; artifact not bundled), artifact UI (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/orca-beta-plan.jpg`; artifact not bundled).

## Targeted low-cost follow-up checks

These checks requested GPT-6-Luna or GPT-5.6-Luna with low reasoning for agent work. Swarm's automatic recovery retained Luna but did not populate resolvedEffort in its replacement record, so that particular reasoning setting is unverified. Shell, transport, source, and persistence probes used no model calls. No new authentication was needed. The earlier full scenario results remain separate from these much smaller checks.

### Agent Swarm: abrupt restart and dependent recovery passed

A preflight attempt failed because the worker could not create a directory under the root-owned shared volume. I created only the scoped test directory with worker ownership, retained the failed receipts, and ran the actual recovery scenario separately. The producer wrote its checkpoint, then entered a deliberate 90-second delay before creating its result. With the checkpoint present and the result absent, I abruptly killed the API and coder containers and restarted them with their volumes intact. The dependent reviewer remained pending.

Recovery was not immediate: the reboot sweep preserved the recent heartbeat, and the regular sweep waited for the default 15-minute stale-heartbeat threshold. At 22:53:21 UTC it superseded producer `21a5739a-f20e-4fee-8f72-28578a907f05` and created replacement `4f5ee3b8-ed96-460d-b01e-559f8689f8fa`, retaining the original as its parent and using GPT-5.6-Luna. It automatically changed reviewer `9eff4385-8d91-429e-ba51-1c63285ebc5c` to depend on the replacement. The replacement completed at 22:53:42; the reviewer then completed successfully.

Independent byte inspection confirmed `result.txt` was exactly `RECOVERY_OK\n`, without duplicated content, and `review.txt` was `PASS`. No manual retry, dependency repair, or result creation was needed after the interruption. This verifies one idempotent workflow across an abrupt API/worker restart; it does not prove exactly-once external side effects, a Windows host reboot, or recovery of arbitrary non-idempotent tasks. The approximately 15-minute detection delay is a practical tradeoff. Evidence: original producer (historical reference: `scratch-projects/orchestration-trials-2026-10-24/agent-swarm/recovery-21a5739a-f20e-4fee-8f72-28578a907f05.json`; artifact not bundled), replacement (historical reference: `scratch-projects/orchestration-trials-2026-10-24/agent-swarm/recovery-replacement.json`; artifact not bundled), rewired completed reviewer (historical reference: `scratch-projects/orchestration-trials-2026-10-24/agent-swarm/recovery-9eff4385-8d91-429e-ba51-1c63285ebc5c.json`; artifact not bundled).

### Multica: restart preflight exposed an upstream Windows failure

The existing Windows daemon was no longer running when this pass began. I restarted its isolated profile and configured the three synthetic agents for GPT-6-Luna/low, retaining their explicit MXC argument. ORCH-8 was a bounded producer with a checkpoint and delay; ORCH-9/10 added the staged parent and review records. The producer failed before its checkpoint, twice: shell startup returned `CreateProcessSecurityEnvironment` / `0x80070020`. Its agent runs were recorded as completed, but the issue remained Todo and no result file was created. No successful in-flight restart test can be claimed from these attempts.

A standalone Codex MXC command reproduced the same error without Multica. An isolated custom profile with minimal filesystem reads, workspace writes, and networking disabled then successfully printed `MXC_NARROW_OK`. This is a narrower diagnostic profile, not a deployed Multica fix. It shows that the failure depends on sandbox policy; it does not establish a particular locked file on this machine. [Upstream Codex issue 52547](https://github.com/openai/codex/issues/52547) contains a similar controlled comparison. I did not change global Codex configuration or use the legacy elevated sandbox that previously caused UAC prompts.

The Multica backend was restarted separately, and all three test issues retained their statuses, parent links, and stage numbers without duplication. That verifies record persistence only. I preserved the run evidence, cancelled the unfinished synthetic probes, and stopped the trial daemon. The earlier functional win remains valid, but native Windows unattended reliability is currently unresolved. Evidence: failed runs (historical reference: `scratch-projects/orchestration-trials-2026-10-24/multica/recovery-runs.json`; artifact not bundled), records after backend restart (historical reference: `scratch-projects/orchestration-trials-2026-10-24/multica/recovery-after-backend-restart.json`; artifact not bundled).

### Multica post-reboot addendum

After the user rebooted Windows, the exact standalone MXC/workspace-write probe returned `MXC_RECHECK_OK` with exit code 0; the previous `0x80070020` failure did not recur. No sandbox configuration or Codex version change was needed (CLI remained 0.164.0). The isolated Multica daemon then ran ORCH-11 on GPT-6-Luna/low with its existing MXC arguments. The worker successfully read the issue through shell commands, wrote and independently read back `MULTICA_REBOOT_OK\n`, posted its evidence, and marked the issue Done. The operator independently confirmed the exact bytes.

This smoke issue was created without a project binding, so its fixture path was outside the generated workspace's writable roots; the worker used a reviewed escalation for that file write. Its ordinary shell reads and status/comment commands succeeded. Therefore the original shell-startup failure is cleared for this pass, while this is not a clean project-bound write or interruption/recovery test. The temporary file was removed after verification and the isolated daemon stopped. The reboot is an observed workaround, not an established permanent fix or explanation of the underlying fault. Evidence: run messages (historical reference: `scratch-projects/orchestration-trials-2026-10-24/multica/reboot-probe-messages.json`; artifact not bundled), final issue (historical reference: `scratch-projects/orchestration-trials-2026-10-24/multica/reboot-probe-final.json`; artifact not bundled).

### Cabinet: WSL execution and a real native child

I copied the installed 0.5.0 app and synthetic workspace into a private WSL directory, reusing the authorized Firstmate Codex trial home. The same sandbox-preserving wrapper remained in place. A GPT-6-Luna parent wrote `wsl-probe.txt`; an independent byte check confirmed `CABINET_WSL_OK` followed by exactly one newline. This resolves the earlier basic Docker execution blocker: shell execution works in WSL under the same workspace sandbox.

The copied coordinator initially had no `canDispatch` setting, and pausing the team had made both personas inactive. For this bounded test I enabled native dispatch on the coordinator, activated the two synthetic personas, selected Codex/Luna for the Editor, and disabled both heartbeats. The coordinator emitted one native `LAUNCH_TASK` proposal. Cabinet placed it in Your turn, showed the exact action for approval, and launched an Editor child when I approved it through the real UI. Saved child metadata contained the correct `parentTaskId`, `triggeringAgent`, `spawnDepth: 1`, and inherited `gpt-6-luna`/low settings. These are Cabinet child records, unlike the earlier Codex subagent attempt.

The child initially could not find the parent's relative file. After a normal continuation supplied the absolute path, it produced `wsl-review.txt` containing exactly `PASS` plus one newline. Independent validation passed for both files. However, the daemon logged that it could not finalize the continuation's `::t2::` session because `meta.json` was missing/unreadable, and the conversation API still showed the earlier failed read. Thus the artifact succeeded with intervention, while continuation persistence did not. Native delegation is demonstrated; unattended joins and dependable continuation status are not. The UI also continued to offer GPT-5.5 for the next message despite executing Luna.

The temporary WSL app and daemon were stopped after testing; ports 43190/43191 were verified closed. The original Docker trial and private WSL evidence remain. Temporary archive copies were removed. The first attempted Docker-to-WSL archive pipe failed; the successful preparation used Docker-side tar files, `docker cp`, and WSL extraction instead.

Evidence: parent probe receipt (historical reference: `scratch-projects/orchestration-trials-2026-10-24/cabinet/wsl-probe-receipt.json`; artifact not bundled), native child metadata (historical reference: `scratch-projects/orchestration-trials-2026-10-24/cabinet/wsl-conversations.json`; artifact not bundled), independent byte checks (historical reference: `scratch-projects/orchestration-trials-2026-10-24/cabinet/wsl-independent-check.txt`; artifact not bundled), server log (historical reference: `scratch-projects/orchestration-trials-2026-10-24/cabinet/wsl-server.log`; artifact not bundled), approval and dispatch UI (historical reference: `scratch-projects/orchestration-trials-2026-10-24/evidence/cabinet-wsl-native-delegation.jpg`; artifact not bundled).

### Orca: sandbox incompatibility isolated without model calls

The same Orca status command reached the running server outside Codex's workspace sandbox and reported stale/unreachable bootstrap inside it. A smaller direct Unix-socket probe then established the precise transport difference: metadata and the socket path were readable in both environments; connection succeeded outside and returned `EPERM` inside. A separate filesystem probe wrote an ordinary workspace file but found `.git` unwritable. No credential values were printed, no RPC authentication was bypassed, and no permission policy was weakened.

These reproduce the Beta worker's two limitations independently of the model: local RPC and Git metadata writes conflict with this sandbox setup. The server was not simply down. A supported scoped permission/approval path or a separately isolated execution environment is needed for a fair end-to-end retest. It would be inaccurate to call these results proof that stock full-access Orca cannot orchestrate. Evidence: sandbox comparison (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/sandbox-probe.log`; artifact not bundled), direct transport comparison (historical reference: `scratch-projects/orchestration-trials-2026-10-24/orca/transport-probe.log`; artifact not bundled).

### Focused upstream follow-up

Stoneforge's [open PR list](https://github.com/stoneforge-ai/stoneforge/pulls) includes #118, “preserve Codex interactive resume IDs,” #113, “spawn honors workspace defaultModels at session start,” and Codex CLI flag fixes. These are relevant leads, not evidence that our headless recovery bug or CLI-provider omission is fixed in an available release. The individual PR pages could not be retrieved in this pass, so their exact changes and applicability were not verified. No upgrade or unreviewed patch was installed.

Sudocode still has an open [Windows absolute-path issue](https://github.com/sudocode-ai/sudocode/issues/159). That is a different failure from our `npx` launch and console problems, so it must not be presented as their confirmed cause. Its [open PR list](https://github.com/sudocode-ai/sudocode/pulls) did not provide a verified fix for those observed failures. A user also raised [a maintenance-status question](https://github.com/sudocode-ai/sudocode/issues/167); that question alone does not establish abandonment. This focused search did not justify another installation/retest.

## Remaining evaluation

### Native computer-use diagnostic update

During a later diagnostic pass, a fresh `@oai/sky` initialization successfully listed Windows applications. Calculator was launched through the supported API; native screenshots and coordinate clicks returned visible state changes. The earlier missing-pipe failure no longer reproduced in that pass. No binary patch, rebuild, or helper replacement was made. The exact reason for recovery was not established, so it should not be attributed conclusively to a particular restart or setting.

The user reported having to approve every request, and UI testing was stopped to avoid further interruptions. Calculator accessibility text was also null, so the test used screenshots. Keyboard input and a complete arithmetic sequence were not conclusively validated. Native control is therefore partially demonstrated, but unattended usability remains unresolved. The standard local Codex configuration had no saved `computer_use.windows.always_allowed_app_ids` entry when inspected. Official documentation describes per-app Always allow; the next distinction is whether the repeated prompts are app-access approvals or tool-execution approvals. No approval settings were changed during diagnosis.

A subsequent native probe again failed with a missing native pipe (`os error 2`), while browser extension control continued to work. The setting for Calculator later appeared in configuration. These observations show intermittent native availability; they do not identify the root cause or prove that the linked Codex issue is the same bug. The current browser-based Swarm evaluation proceeded successfully after reconnecting following the user's unrelated ChatGPT restart.

All seven shortlisted candidates received live UI and execution checks. Multica, Agent Swarm, and Firstmate completed the main scenario. Cabinet's WSL follow-up demonstrated native child dispatch and file execution with intervention. Orca and Stoneforge did not complete coordinated workflows, and sudocode did not reach a verified completed execution state. These boundaries remain despite the additional diagnostics.

Firstmate's dependency preparation has now completed: Node 22.23.4, Codex 0.164.0, tmux 3.6, gh 2.103.0, treehouse 3.1.5, no-mistakes 1.84.0, gh-axi 0.1.43, chrome-devtools-axi 0.1.44, tasks-axi 0.2.6, quota-axi 0.1.67, and lavish-axi 0.1.92. All newly added tools live in the trial folder. The user completed isolated Codex device authentication. Global hooks and the no-mistakes daemon were not installed or started.

Further investment should focus on a selected finalist and a representative real project. Multica offers the strongest tested project/task interface, but its current native Windows sandbox blocker needs a supported resolution. Swarm has stronger demonstrated dependency and recovery behavior through Docker. Firstmate remains a functional WSL/tmux alternative with less polished status visibility. Cabinet, Orca, Stoneforge, and sudocode have enough observed limitations that more generic smoke tests are unlikely to change the adoption decision; they need specific fixes and focused retests. Nested Firstmate secondmates, conflicting concurrent edits, and long-duration reliability remain outside this survey.

## November 6 follow-up: Firstmate Windows integration

This follow-up tests the retained Firstmate revision `d22640f478e3392313e27b04fb41de12bd25d2e7`, not a newly upgraded Firstmate release. Evidence is in orchestration-followup-2026-11-06 (historical reference: `scratch-projects/orchestration-followup-2026-11-06`; artifact not bundled). The earlier October conclusions remain historical results.

### Native Windows: real adapter and agent execution passed

The official Herdr stable manifest supplied **0.9.5, protocol 22**, with a Windows x64 archive. The archive was verified against its published SHA-256 before extracting it into the trial folder. The official Treehouse **3.1.8** Windows archive was likewise checksum-verified. Neither tool was installed globally or added to the user's permanent PATH.

Verified in an explicitly named, hidden test session:

- Herdr server startup, workspace/pane creation, PowerShell command submission and captured output, and foreground process information.
- Firstmate's actual Herdr adapter running under native Git Bash: version gate, client compatibility, workspace creation, task-pane creation, text delivery, capture, and agent-presence classification.
- Native Treehouse allocation of a leased worktree from a synthetic repository, followed by successful lease return.
- Firstmate's Windows-specific Pi shell-invocation regression using native Node 24.16.0. This is a shell integration test, not a live Pi agent test.
- An authenticated native Codex **0.167.0** worker receiving a read-only audit through Firstmate's adapter with **MXC and approve-for-me**. It ran Git/file-list commands, returned `NATIVE_AGENT_AUDIT_OK`, and correctly identified commit `f52d1136b4469b1db7e49e8afc518f6a327d7e79` and the three fixture files. Independent checks matched and the repository remained clean.
- A same-conversation follow-up through Herdr returned the same commit/files and `NATIVE_CONTINUITY_OK`.

This does **not** establish a full native Firstmate coordinator -> secondmate -> worker workflow. The worker was launched through Herdr, with work delivered through Firstmate's real adapter. Native coordinator startup, full `fm-spawn` worktree/agent coupling, merge handling and unattended recovery remain outside this successful slice.

**UI boundary:** This was a hidden Herdr server/CLI trial, not a visible desktop UI evaluation. The complete successful hierarchy used WSL/tmux. The earlier Bearings browser-board test is a separate oversight/feedback surface and does not validate Herdr's UI. Firstmate + Herdr remains a credible native Windows candidate; the next end-to-end native trial should explicitly include the visible UI, coordinator/secondmate/worker launches, steering, completion reporting and recovery.

Setup qualifications: the initial native launch pointed at the older WSL profile and refused its database migration checks; a separately authenticated native profile resolved that cross-version/profile mistake. No database was deleted or migrated manually. Default first-run sandbox setup remained on its setup screen until cancelled after about 90 seconds. Herdr had briefly classified the process as ready before setup completed, so adapter-send success alone was insufficient proof of delivery. Explicit `windows.sandbox="mxc"` then launched and executed successfully. This is a supported configuration, not proof that the default setup cannot eventually finish. See the official [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference) for the sandbox selector.

The native session was stopped after verification and status independently showed `running: false`; its evidence and conversation records were retained. The synthetic worktree lease was returned. Key receipts: `native-adapter.log`, `native-control.log`, `treehouse-native-lease.json`, `native-windows-shell-test.log`, `native-mxc-adapter.log`, `native-mxc-result.txt`, `native-continuity.txt`, and `native-final-status.json`.

### WSL regression results and setup boundaries

Using the retained Linux toolchain (Codex 0.164.0, tmux 3.6):

| Suite | Observed result |
|---|---|
| Secondmate lifecycle | 6 passing assertions |
| Persist/restart | 23 passing assertions; cleanup emitted permission-denied warnings |
| Secondmate liveness | 22 passing assertions |
| Secondmate harness | 26 passing assertions, one unavailable-Cursor skip, then failure: `crew-unaffected: expected an ordinary ship task` |
| Pi Windows shell test under WSL | Skipped as expected; subsequently passed under native Windows Node |

These secondmate suites model session-provider behavior with test doubles. They are not evidence that real agents nested or recovered successfully. The harness failure was not introduced by a source change and its underlying cause was not established.

The retained OAuth login was revoked despite `login status` saying logged in; actual inference exposed the problem. The user renewed it through device authentication and a shell smoke test passed. Later launches could not open the NTFS-backed trial SQLite database. A read-only probe and `codex doctor` reproduced the access/integrity-check failure; neither alone proves data corruption. A trial-only wrapper override using the documented `sqlite_home` setting placed new runtime state on the Linux filesystem while preserving the original database and credential files. Doctor then reported zero failures. See the official [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference) and [doctor command](https://learn.chatgpt.com/docs/developer-commands?surface=cli).

Several initial live attempts were invalid setup experiments, not product acceptance failures: missing writable access to the old session-lock directory; a `local-only` fixture ineligible for secondmate delegation; a symlinked state directory rejected by home reconciliation; a secondmate placed inside its primary home; and temporary paths that were not visible as expected across sandbox sessions. The final setup used real, separate, persistent Linux homes under `/home/brennan/.local/state/firstmate-acceptance-20261106/`, with the secondmate pre-cloned from the tested source and a synthetic local bare project origin. Hook trust was not bypassed; the new-hook prompt was skipped through its displayed action.

### Live WSL nested delegation: completed with intervention

The primary launched persistent secondmate `stable-audit-20261106` through `fm-spawn.sh --secondmate`. That secondmate created and launched scout `nested-csv-audit` in `/home/brennan/.treehouse/nested-audit-b9bd7e/1/nested-audit`. The scout wrote its native report and completion record; the secondmate acknowledged it and returned correlated completion records to the primary. Independent inspection confirmed commit `f52d1136b4469b1db7e49e8afc518f6a327d7e79`, the expected three tracked files, and a clean worktree. The full primary -> secondmate -> scout -> secondmate -> primary chain therefore executed.

The audit correctly reported an intentionally unfinished fixture: `csv.mjs` is absent, and `npm test` fails at module loading before any parser assertions run. That fixture failure is an audit finding, not an orchestration failure or a regression introduced by this test. No implementation was requested or silently added. Saved copies: `nested-scout-report.md`, `nested-setup-diagnosis.md`, and `nested-parent-status.txt` in the follow-up evidence directory.

This required intervention. Tmux access needed scoped approval. A generic Treehouse contention message actually arose while acquiring a lock in the primary home's state directory, outside the secondmate's ordinary sandbox write roots; no lock directory or PID file existed, and one approved invocation of the same supported spawn succeeded. No lock was deleted and no guard was disabled. One follow-up request was saved durably but its doorbell remained in the secondmate's composer until the primary sent Enter through `fm-send.sh --key Enter`. The delayed request then proceeded. These are material constraints on unattended use, even though the eventual hierarchy worked.

After the nested audit, the normal `fm-secondmate-restart.sh stable-audit-20261106` persist gate and restart helper returned `restarted: stable-audit-20261106 (codex)` and `1 of 1 restarted, 0 nudged, 0 unreached`. This is a supported operator-driven restart, not abrupt process-kill, host-reboot, or unattended crash recovery. The primary's detailed run is recorded in `stable-final-report.md` and `stable-resumed-events.jsonl`.

The post-restart check also passed: native correlation `c7c997818236afc4` returned the exact token `STABLE-PING-20261106-2144-b71c`, the same persistent secondmate home and identity, and a finding from the retained scout report. The final durable receipts are copied to `nested-parent-status-final.txt`. This verifies useful continuation after the supported restart, rather than just a new process starting.

Cleanup used the supported `fm-control.sh <id> exit` for the scout and secondmate, preserving their homes, records, worktree and shell endpoints. The secondmate exit initially refused because another doorbell tail remained in its composer. That text was captured in `cleanup-pending-composer.txt`, cleared with the native `C-u` key path, and the supported exit then succeeded. The prior October trial wrapper was restored byte-for-byte; the Linux-local state configuration is retained separately in `orchestration-followup-2026-11-06/tools/codex` for follow-up use. No global authentication files, hooks, PATH or application settings were changed. A separate native Windows test profile remains authenticated from the user's normal device sign-in. Automatic approval review rejected an attempted credential-file copy; that operation was not performed and the separate sign-in was used instead.

**Assessment:** Firstmate now has stronger evidence than the October report: native Windows components can execute real work, and WSL nested delegation plus supported restart/continuation have passed. It still required significant setup and supervision. Repeated composer leftovers, permission-boundary handling and generic lock diagnostics remain concrete concerns for unattended use. This trial does not establish a fully native hierarchy, automatic crash recovery, host-reboot recovery, simultaneous nested supervisors across unrelated projects, or long-duration reliability. Multica/Swarm were not retested in this follow-up.

## November 6: local Multica pilot

The fresh pilot used Multica 0.7.0, a native Windows daemon, four GPT-6-Luna/low agents, and two new local-directory projects. The lead created coding, independent-review and writing issues. A late requirement for explicit per-project zero counts reached implementation and review. Root verification independently ran `node --test summarize.test.mjs`: four passed, zero failed. Writing produced a two-hour workshop plan with a 58 USD budget and explicitly pending venue confirmation.

A controlled force-stop of the isolated daemon process tree occurred after checkpoint creation. The operator manually restarted the daemon. Multica marked the interrupted builder attempt `runtime_recovery`, automatically started attempt 2, and resumed the persisted session/checkpoint to complete implementation. This closes the earlier project-bound in-flight worker-recovery gap; it does not prove automatic service startup, reboot recovery, or prolonged unattended reliability.

Independent review identified missing restart-cause documentation. The lead changed the builder's description and status, but no fresh worker run was created. It then waited roughly an hour for the builder to reach review. A dashboard comment from the operator was required to identify the stall. The lead subsequently used the supported rerun mechanism, and the builder corrected the checkpoint. Review and writing were accepted as Done. Final acceptance is recorded in the pilot evidence.

The worker had no supported desktop-control tool and did not simulate Notepad via shell. Desktop completion is therefore a capability gap in this tested configuration. The builder also prematurely attributed its own tests to independent review; the lead caught that mistake and later obtained a real independent review.

Local login was verified through the ordinary browser form and the documented backend-log verification code, using the existing `orchestration-trial@example.test` account. No email service, Multica cloud account, fixed verification code, or authentication bypass was introduced. The running backend has `DO_NOT_TRACK=true`; orchestration services remain on loopback. Model inference still uses existing Codex authentication. The earlier browser-tool connection failure cleared when the conversation moved into the desktop app.

Live UI verification covered the board, linked parent/children, worker run histories, wakeup indicators, and a comment that queued a new lead run. A Stop control was visible, but pause/resume was not exercised. These are real pilot records, not the landing page's demonstration content.

**Assessment:** Multica's organization and recovery are useful, but this pilot does not satisfy the user's low-intervention unattended requirement: follow-up dispatch stalled without an operator nudge, and desktop tooling remains unintegrated. Keep it a conditional candidate rather than a settled recommendation. Evidence and artifacts: `scratch-projects/multica-pilot-2026-11-06/`, including `PLAN.md`, `evidence/`, `code/`, and `planning/plan.md`.

A second intervention was needed after the correction worker finished: it left the issue in_progress while the lead's wakeup required in_review. The operator asked the lead to verify and reconcile the completed result. This demonstrates a status/continuation mismatch in the tested Luna/low setup; it does not isolate the framework from model judgment.

Final reconciliation: lead closed all three children and disabled the obsolete wakeup; operator accepted ORCH-12 from review to Done. Two corrective operator nudges plus final acceptance were needed after the controlled restart. Local browser login required no user action. See evidence/pilot-complete.png and ORCH-12-final.json in the November pilot directory.

## November 6 follow-up: stall diagnosis and local desktop integration

The two original stalls were coordination-contract failures under the tested
Luna/low configuration, with a framework design that allows them to persist:

1. The lead updated the correction description with `--no-start`, then changed
   `in_review` to `in_progress`. Neither operation queued a worker. A live
   isolated probe reproduced zero runs before and after that status change.
   Multica's `IssueService.WillEnqueueRun` treats assignment and promotion out
   of backlog as dispatch triggers; ordinary review/progress changes are not.
2. After an explicit rerun succeeded, the worker left its issue `in_progress`.
   The lead's status-only wakeup required `in_review` and had no expiry. The
   platform correctly waited on a condition that never became true. Bundled
   issue guidance explicitly says statuses are agent-managed, not automatic
   run-start/run-finish effects.

This is evidence against a queue/scheduler malfunction in those two stalls.
It cannot separate inherent model reliability from prompt quality in general.
The product still exposes a robustness gap: ordinary agent mistakes can leave
work indefinitely idle unless the coordinator checks actual run lifecycle.

Applied pilot-only fixes (no model change, no Multica source fork):

- Explicit rerun for corrections, followed by a recorded run ID.
- Exact terminal-task wakeup, five-minute expiry, and timeout wake.
- Evidence-based reconciliation of run outcome against business status.
- Explicit final status updates in Builder, Reviewer and Planner instructions.
- Maximum one concurrent lead run, and an instruction to exit after arranging
  a durable continuation rather than poll alongside that continuation.

ORCH-16/17 passed the first controlled regression without a corrective operator
nudge. A fixture worker changed result.json to revision 2 / message corrected,
intentionally left its status stale, and sent no comment. The completion-event
wakeup fired once; the lead read the artifact, closed child and parent, and
confirmed the wakeup was disabled. Model stayed gpt-6-luna, thinking low.
The first regression permitted overlapping initial/reconciliation runs, which
motivated the serialized-lead change and a repeat (ORCH-19/20).

Desktop integration used Windows-MCP 0.8.8, source commit
b69ec872623b403f647fb3777685d4cf2678d3a2, with locked dependencies and a
pilot-local Python 3.14 environment. No new account, API key, cloud desktop,
HTTP listener, scheduled startup task or global PATH change was added.
The pilot agent's stdio MCP configuration explicitly allows App, Snapshot,
Click, Type, Shortcut and Wait; the bridge additionally exposes ControlStatus.
ANONYMIZED_TELEMETRY=false, POSTHOG_API_KEY empty, watchdog off, and balanced
user-control protection are configured. The App tool remains powerful;
the allowlist is not an app-level security sandbox. Its task was restricted
to a new Notepad document. Original pilot agents did not receive desktop access.

ORCH-18 proved MCP startup and tool invocation, but not successful desktop
work. Start Menu launch reported no usable window; Snapshot showed none and
switching to Notepad failed. A retry with the supported exact-executable
launcher returned CONTROL_PREEMPTED with zero executed steps. The worker
stopped honestly; desktop-proof.txt was not created by any means. The second
result indicates a bridge control/preemption boundary, not a Multica enqueue
failure. It does not prove that the user physically intervened: the bridge has
several internal causes for that code. Read-only process metadata showed the
daemon and observed bridge threads on a desktop named Default, so the earlier
private-desktop hypothesis was not established. No isolation or user-control
protection was disabled. A brief idle-window retry was offered; otherwise
leave desktop testing paused.

Evidence and reproducible configuration are in followup/: status-dispatch-probe.json,
lead-contract.txt, apply-contracts.ps1, applied-contracts.json, setup.json,
ORCH-16/17 run and wakeup records, first-result.json, desktop-mcp.json,
desktop-setup.json, desktop-messages.json, desktop-retry-messages.json,
desktop-process-metadata.json and desktop/desktop-result.md.

Source references: Multica's bundled multica-platform/references/issues.md
and internal/service/issue_trigger.go in the inspected October source checkout;
https://github.com/CursorTouch/Windows-MCP ;
https://learn.chatgpt.com/docs/extend/mcp ;
https://learn.chatgpt.com/docs/windows/windows-sandbox .
The inspected Multica checkout and installed release are separate revisions;
the live status probe corroborates the relevant behavior on the running release.

Repeat result: ORCH-19/20 also passed without a corrective operator nudge.
The serialized initial lead finished at 23:44:36 UTC; its continuation started
at 23:44:54 UTC. Independent checks confirmed no overlap, exact artifact
contents, both issues Done, and one wakeup fire followed by automatic disable.
Both controlled regressions retained gpt-6-luna/low. The timeout recovery branch,
hours-long workloads and autonomous daemon startup were not exercised here.
Configuration scripts passed PowerShell parsing; the upstream Windows-MCP
checkout has no tracked modifications. The notes/pilot parent directory is
not a Git repository, so no commit was created and nothing was pushed.
Desktop testing remains paused after preemption; the local bridge configuration
is retained only on Pilot Desktop Bridge, with no active desktop run. No new
provider login was required; model inference still uses existing Codex auth.

## Desktop idle-window retry: passed (November 6, 23:46–23:50 UTC)

The user explicitly authorized a fresh retry and left the desktop idle. Run
01a1b342-2303-7b30-8d88-b2a85712a9cd on ORCH-18 completed successfully.
Using the existing pilot_windows stdio bridge, the native worker launched
C:\Windows\System32\notepad.exe, observed and focused its window, created a
fresh document with Ctrl+N, typed the supplied pilot text, opened Save As,
and saved desktop-proof.txt through the UI. No shell write created the file.
Read-only verification by both the worker and the operator confirmed exact
text: `Multica local desktop pilot - 2026-11-06` (40 bytes including UTF-8 BOM).
SHA-256: 495D044E9D22C8F868AE892F1FA264A0DA87A2254029640B8B493B09684059FB.

A filename entry using label 1799 failed with “Label 1799 out of range.” The
worker recovered using the observed field coordinates. There were 13 bridge
calls including the read-only ControlStatus call (12 other desktop calls),
one more than the literal 12-call instruction if ControlStatus is counted.
No operator correction or change to protection settings was needed during
this run. The worker set in_review; after independent verification the
operator accepted it as Done. The saved pilot document was left open.

Balanced user-control protection, the tool allowlist, telemetry-off environment,
and sandbox configuration stayed unchanged. This supersedes earlier statements
that no UI proof exists. It supports successful bounded native desktop control
from Multica with no added provider login. Earlier preemption is compatible
with a desktop-control/interference issue, but its precise internal cause was
not isolated. It does not prove all Windows apps work or that desktop actions
can run reliably while the user is using the same desktop.

Evidence: followup/desktop-idle-retry.json, desktop-idle-messages.json,
desktop-verification.json, ORCH-18-runs.json, ORCH-18-final.json and
followup/desktop/desktop-proof.txt. The previous desktop-result.md is retained
as historical failure evidence, not the latest result.

### User-observed desktop limitation (supersedes intervention assessment)

After the successful Notepad test, the user reported that the bridge displayed
an AI-taking-full-control message requiring manual approval, and that they
could not use the machine for the duration. The earlier statement that no
operator intervention was needed describes only absence of corrective task
steering; it must not be interpreted as zero human interaction. The test
required manual desktop takeover approval plus exclusive use of the desktop.

Classify this as a supervised desktop capability proof with substantial UX
limitations, not a successful low-intervention background desktop workflow.
It does not meet the user's frequent need to continue using Windows while
agents work. A separate interactive Windows session/machine or an application
API may offer a different interaction model, but neither was tested here.
No protection settings were changed in response to this feedback.

## Longer local pilot results — November 6 evening

Main pilot: 16:57–19:14 America/Denver, with real scheduled work at one and two
hours and idle dependency waits between them. This was not two hours of
continuous useful model computation. Local Multica 0.7.0, native Windows
workers, existing Codex authentication, gpt-6-luna/low, and unchanged sandbox
settings; no new provider login or user action was required in this run.

| Check | Observed result |
|---|---|
| Layered delegation | ORCH-21 supervisor -> ORCH-23 planning / ORCH-24 coding leads -> workers and independent reviewers, in separate project directories |
| Correct coding output and late steering | Browser correction flowed through the lead; independent root acceptance passed 10/10 tests; final source/test/docs hashes unchanged |
| Delayed substantive work | One-hour wakeup fired ~13 seconds late; delegated 10,000-row audit and independent review completed without a corrective nudge; root separately passed all five queries |
| Blocked decision and unrelated progress | Venue decision stayed blocked while coding and planning preparation completed; two-hour wakeup fired ~13 seconds late, released the synthetic decision and triggered a reviewed brief revision |
| Planning artifact | Eight attendees; stale source figures reconciled; 120-minute agenda including 10-minute break and 15-minute close; $75 budget, $15 remaining; exercise-only approval, no booking |
| Cancel / UI Retry | Cancelled checkpoint worker stopped after one in-flight write; browser Retry resumed persisted state to 60 unique ordered checkpoints in the same saved Codex session; not OS-process pause/resume |
| Read-only screenshot | 80×80 Snapshot succeeded, ControlStatus stayed user/balanced before and after, no input tools exposed; narrow background-observation proof |
| UI drill-down | Navigated supervisor -> project lead -> reviewer, opened discussion and completed execution transcript with commands/search; screenshot saved |
| Daemon crash recovery | Added bounded helper restarted the isolated daemon in ~7 seconds; Multica created recovery attempts for interrupted runs |
| Backend recovery | Application exit inside Docker restarted automatically; records and scheduled wakeups persisted. An earlier explicit docker kill required manual start because it took the operator-stop path |
| Final autonomous closure | **Failed initially:** all artifacts/reviews finished, but root remained in_progress with no active runs or enabled explicit wakeups. Corrective v3 contract update and one operator rerun closed all 11 main-tree issues |

Two coordination fixes were required during the pilot: v2 counts directory-wait
runs as active, avoids duplicate correction dispatch, and parks dependent reviews
in backlog; v3 preserves the owning/root completion obligation across child-bound
continuations and requires explicit upward propagation/acceptance. These are
pilot-agent instructions, not upstream scheduler patches. Built-in children-done
wakeups also ran during final acceptance; the stall was before children were
accepted out of in_review. Same-model behavior supports a coordination-contract
explanation, while the reliance on agent judgment remains a product robustness
limitation. Do not call this an unattended end-to-end pass.

Main supervisor corrective run 01a1b3c6-974e-7b74-beb1-38e36e5528a9 completed at
19:14:51 Mountain. All 11 issues were Done and no main-tree runs were active.
The monitor exited; the bounded daemon helper stopped at 19:15:09. The daemon
and local application were left running; autostart was restored to its original
disabled state, and backend DO_NOT_TRACK=true remained set. No service or
scheduled task was installed.

Remaining material gaps: the installed Codex adapter auto-accepts its received
execution/file/permission approvals, so no human tool-approval inbox is verified;
a business-decision blocker is not such a gate. Separate sandbox/policy controls
may still apply. Actual host reboot/login, Docker Desktop startup, merge/conflict
handling, arbitrary desktop apps and routine long-term reliability are untested.
Interactive desktop control still has the previously observed manual takeover
and exclusive-use limitation. The tiny screenshot does not remove that limit.

Detailed evidence and the v3 closure regression result are maintained in
`scratch-projects/multica-pilot-2026-11-06/long-pilot/PLAN.md`. See
`final-main-snapshot.json`, `closure-stall-snapshot.json`, `contracts-v2.json`,
`contracts-v3.json`, `two-hour-wakeups.json`, `final-code-hash-check.json`,
`final-planning-check.json`, `acceptance-initial.txt`, and
`large-input-root-verification.txt` in that folder. Browser evidence includes
`retry-ui.png`, `late-steering-ui.png`, and `reviewer-drilldown-ui.png`.

### V3 closure regression — completed 19:21:42 Mountain

A fresh, bounded read-only regression ORCH-34 -> ORCH-35 -> ORCH-36 used the
same supervisor, code lead, reviewer, model and permissions after the v3 fix.
The leaf inspected the existing usage/audit documentation and initially left
its evidence in_review. The lead accepted it, propagated completion upward,
and the supervisor verified closure. All three issues reached Done; no runs
or enabled wakeups remained. No corrective root nudge was sent after creation.
A redundant built-in children-done continuation was cancelled by an agent,
not the test operator. This passed small completion-propagation regression
supports the instruction fix; it is not a repeat of the entire two-hour test.
The earlier main pilot still required intervention and must not be called an
autonomous pass, even where a worker's own final wording suggests otherwise.

Evidence: regression-snapshot.json, regression-final-check.json,
regression-final-wakeups.json and closure-regression-setup.json in long-pilot.
The final dashboard screenshot is final-main-ui.png. All temporary monitoring
helpers are stopped; the local app and its original daemon remain available.
The notes and helper files are outside a Git repository, so no commit was made.

## Local approval/recovery fix and two-hour repeat — November 6, late evening

Local fork 9bd735f7c on branch local/approval-recovery adds a separate owner review
page for Codex approvals and a persistent non-elevated Windows recovery task.
It is committed locally, not pushed. Existing Codex authentication is reused.
The review credential/state stays in .multica/local-reliability; executables are
separate under .multica/local-runtime/bin. open-review.ps1 in the review state
directory opens an authenticated page without a new provider/account login.

Live tests verified one-time approval, denial preventing a write, worker credential
read denial, and absence of host approval environment variables. Missing broker
or credentials and stale/restarted requests deny. A denied command cancels its
turn and is currently recorded as a failed run. The separate review page is not
a native Multica inbox and is scoped to the patched Codex adapter. Other tools
and providers retain their own permission behavior.

The installed scheduled task restores daemon/broker crashes every minute and at
login. During the final run, a force-stopped daemon recovered in about 28 seconds
without an operator start; worker retries and both delayed wakeups persisted.
Backend application-exit recovery also passed. The user reported foreground
console flashes; root replaced the polling launches with CreateNoWindow and the
PowerShell scheduled action with a GUI-subsystem Go supervisor whose children
also use CREATE_NO_WINDOW. Its broker restart passed, the task returned Ready,
and launch-flag/PE checks passed. Subjective absence of every flash was not
confirmed by the user. No desktop takeover or machine reboot was performed.

ORCH-48 ran from 19:46:28 through final reconciliation at about 22:05 Mountain,
including deliberate idle waits rather than continuous productive computation.
It delegated coding and planning through project leads to workers/reviewers.
The one-hour audit and two-hour final wakeups fired about 11 seconds late.
All 10 issues finished Done; final independent inspection found zero active runs
and zero enabled wakeups. Unlike the prior long pilot, no closure nudge was needed.
The supervisor autonomously routed an identified CLI test-coverage gap back for
correction and re-review, accepted the final planning amendment, and closed the
hierarchy with v3 coordination instructions.

One real corrective intervention was required: an early private installation put
the CLI inside the denied credential directory, so the one-hour continuation
could not launch it. Root relocated executables, retained credential denial,
and explicitly resumed that failed continuation. This was a packaging defect,
not a lost wakeup or model refusal. Do not describe the entire repeat as a clean
unattended pass. The initial configuration-development run ORCH-37 was cancelled
and excluded from this acceptance result.

Validation: 10/10 independent CLI acceptance checks, all 10,000 generated audit
rows and 5/5 real CLI query comparisons, and the final artifact's 8/8 tests passed.
Implementation/docs hashes stayed unchanged while the agent strengthened tests.
The reviewed final planning brief has eight attendees, a 120-minute agenda ending
16:00, a $75 budget with $15 remaining, and exercise-only approval/no booking.
New Go approval/profile and hidden-launch tests plus broker authentication,
replay, restart and generated-page checks passed. The broader existing agent
suite failed Windows fixture/executable tests; it was not a clean suite pass.
Small residual automated-test coverage limits are recorded in the review.

Remaining limits: actual logoff/reboot and Docker Desktop startup, merge/conflict
handling, general desktop applications, long-term reliability and maintenance of
this local fork remain unverified. Interactive desktop control still has its
previous takeover limitation. The persistent supervisor/review service stay
installed and running; temporary monitors are stopped. No new user action or
provider login was needed. Future framework tests may use the user-authorized
existing Claude/agy logins and smaller Codex models; this repeat stayed Luna/low.

Primary evidence: scratch-projects/multica-pilot-2026-11-06/reliability-pilot/PLAN.md,
final-snapshot.json, final-check.json, final-wakeups.json, recovery-events.jsonl,
recovery-timing.json, approval-audit.json, final-artifact-tests.txt,
independent-acceptance.txt, independent-large-verification.txt, and
final-planning-brief.md. The canonical amended brief was posted on ORCH-52;
planning/brief-comment.md is the historical draft, not the final amendment.


## Post-reboot startup and path regression — November 8

The user rebooted before this test. Windows reports boot at 10:29 Mountain.
The installed broker was created at 10:40:58 and the installed patched daemon
at 10:43:25. The scheduled supervisor is Ready, returns result 0, and runs its
windowless executable from .multica/local-runtime/bin. Logs show failed daemon
starts while the backend was unavailable, followed by successful automatic
startup when it became available. All three Docker services and the review
broker were already up before this test; root did not start them. Docker Desktop
has autoStart=true. Prior ORCH-48 records remain present and Done.

A fresh Luna/low native-mxc test ORCH-60 -> ORCH-61 ran from about 17:20 to
17:26 Mountain. The lead resolved and invoked multica, ended its initial run,
then resumed via a two-minute one-shot wakeup. It invoked the CLI again and
delegated one worker. The worker resolved the executable outside the protected
credential directory, successfully read its issue, hashed a supplied sentinel,
received DENIED on an ordinary read of the identically protected nonsecret
canary, and saw no MULTICA_LOCAL_APPROVAL_ environment variables. Root separately
verified all fields and the SHA256. The lead accepted the worker and closed both
issues without a nudge. Final state: two Done issues, zero active runs, zero
enabled wakeups. No provider/login changes, desktop control or user action was
needed. No code or installation changes were required.

This directly passes the post-installation path regression for fresh execution,
a scheduled resumed lead, delegated worker execution and credential isolation
after the reboot. It also supplies observed startup-after-reboot evidence.
It does not demonstrate active work surviving a reboot: the earlier pilot had
already completed before the user rebooted. To test that remaining case, start
a bounded checkpointed job and register a delayed continuation, verify persisted
progress, have the user reboot, then inspect retry/session, checkpoint, output,
closure and absence of duplicated work after login. Do not reboot automatically.
A second reboot is unnecessary for verifying the path fix itself.

Remaining broader acceptance: active-work reboot recovery; longer unattended
runs after the final layout fix; general desktop applications and merge/conflict
workflows; upkeep of the local fork. Clean short delayed execution is now passed.

Evidence: startup.json, setup.json, latest.json, final.json and project/result.json
in scratch-projects/multica-post-reboot-2026-11-08. Source/installed runtime remains
local fork 9bd735f7c. This folder and the consolidated notes are outside Git.

# Active-work reboot result — November 8

PASS for the configured workflow: all saved work recovered, with agent-driven
recovery through an independently persisted time backstop. This is not a pass
for platform automatic worker retry alone.

Windows restart request: 18:20:01 Mountain (event 1074). Last worker checkpoint:
18:19:58, index 36. The original worker failed at 18:20:03 during shutdown. Its
terminal-event lead continuation started at 18:20:05 and failed initialization
while Windows was still shutting down. That was a lead run, not a worker retry.
Windows event log stopped at 18:21:28; new boot was 18:22:48.5, event log started
18:23:03. Supervisor retries restored the daemon at 18:25:42 after the backend.

The pre-registered 12-minute root time wakeup fired at 18:29:16. The lead saw no
active worker retry, explicitly started one new worker attempt at 18:30:31, and
registered a new exact-run terminal wakeup. The worker preserved all 36 committed
pre-reboot steps, resumed in a second process, detected the changed boot estimate
and finished 12 post-reboot steps at 18:31:34. The lead reconciled and closed
ORCH-62/63 at about 18:32:45. No operator rerun or prompt correction was sent after
reboot. The operator independently verified boot times, all eight handoff-captured
checkpoints, the complete hash chain, 48 unique sequential indices, two launches,
and exactly 12 post-reboot steps. Both issues Done, zero active runs/wakeups.

The warning about an ignored computer_use.windows.always_allowed_app_ids setting
was incidental stderr from startup, not evidence that it caused the shutdown.
Preserve separate actor IDs when interpreting run history: lead continuations can
be recorded on a worker issue.

Important operational lesson: a completion-event wakeup can be consumed by a
lead launch during OS shutdown, then fail. Its original event rule is already
disabled. An independent durable root timer/condition is needed to recover that
case. The tested setup included such a timer before the reboot; do not generalize
this to every Multica task without equivalent recovery instructions/backstop.

Evidence: pre-reboot.json, post-boot.json, reboot-events.json, recovery-events.jsonl,
verified-reboot.json, final.json and project/checkpoint.json. Run node verify.mjs
for the independent chain/prefix checks. Remaining suite work is in RESUME.md.


## November 8 remaining acceptance tests, through 19:19 Mountain

Active-work reboot passed the configured timer-backed recovery workflow; the
preceding reboot addendum records the shutdown-time failed continuation and
independent timer recovery precisely. No operator nudge was sent after reboot.

Additional completed tests:

- [Parallel Git worktrees/conflict](scratch-projects/multica-final-suite-2026-11-08/git/RESULT.md): two workers committed independently; the lead preserved real merge-conflict evidence, resolved to the latest requirement and obtained independent review. Exact linked-index grants fixed sandbox writes. Final closure exposed a stale reviewer reverting Done to in_review. Operator repair plus v4 guard passed one queued-after-acceptance regression. All four issues now Done, no active runs/wakeups. Main repo clean; worker handoff notes remain untracked.
- [Background Office API MCP](scratch-projects/multica-final-suite-2026-11-08/desktop/RESULT.md): actual Multica model tool call created hidden XLSX/DOCX/PDF fixtures; Excel calculated 42 and reopened, Word saved/exported; both test instances closed and reported no foreground ownership at the checks. Independent file/process and tool-guard checks passed. Fixed host adapter only, not arbitrary desktop control; sandbox remained enabled.
- [Narrow permission approval/denial](scratch-projects/multica-final-suite-2026-11-08/permissions/RESULT.md): dedicated experimental request_permissions_tool requested exactly one fixture folder each time; approved write succeeded while review canary stayed denied, denied target sentinel stayed unchanged. Both model runs completed and were independently accepted. Broad command expansion still failed at MXC environment creation with HRESULT 0x80070020 in three distinct approved attempts. Approval routing and successful execution after every approval are different claims.

The fresh two-hour ORCH-64 suite remains in progress on its original v3 contract,
with planned 19:28 audit and 20:28 final milestone. Independent initial CLI
acceptance passed 10/10; documented-directory worker tests passed 8/8. One owner
review approved optional temporary-file cleanup; the command returned no output
and no reported error, and its four target files are absent. Handoff proceeded. No corrective prompt or rerun has been sent to that
tree so far. The suite is real elapsed-time durability with idle dependency waits,
not two hours of continuous useful compute. Final result will follow below.

Local source documentation commits: 24d3294d0 and 3d0b5174d, no push. Runtime code
remains installed build 9bd735f7c; these new commits only document operating limits.



## Longer-run acceptance correction and v5 regression — November 8

The original ORCH-64 two-hour case completed its implementation, late correction,
10,000-row audit and final planning revision/review. Final business acceptance
then stalled: ORCH-69 stayed in_review, its lead/root stayed in_progress, and
there were zero active runs or enabled wakeups. All 43 recorded model runs
ultimately completed; model-run completion did not establish business closure.
Two precisely reviewed optional cleanup commands succeeded. They were not among
the three approved commands that failed at MXC environment creation.

The operator added v5 acceptance authority and an independent bounded root guard.
Its first scheduled check closed all ten issues; later callbacks preserved Done.
This was a corrective intervention, so the original longer case is not an
unattended pass. V5 clarifies that leads accept satisfactory children and close
their own deliverables, root can accept verified descendants, handoffs must
recompute current obligations, and terminal events need an independent bounded
root backstop. Native event rules exclude the registering run's own terminal
state; such a subscription cannot replace the root backstop.

A fresh three-level ORCH-82/83/84 v5 regression subsequently closed all three
issues without any corrective action after dispatch. Its agents created the
bounded guard themselves and cancelled two redundant queued continuations. The
sentinel stayed unchanged, with zero active runs or enabled wakeups at settlement.
A separate clean full v5 two-hour repeat, ORCH-85, started at 21:23:29. Its one-hour
large-input audit passed independent checks and agent acceptance; the final
23:23:29 venue milestone fired automatically. The run finished at 23:38 with all
thirteen issues Done, zero active runs or enabled wakeups, and no corrective
operator prompt, approval, login or runtime change after dispatch. All supplied
inputs and reviewed artifacts retained their verified hashes. This is one clean
elapsed-time pass, including idle waits; the reboot and permission faults were
separate tests.

See [original longer result](scratch-projects/multica-final-suite-2026-11-08/long-run/RESULT.md),
[fresh v5 regression](scratch-projects/multica-final-suite-2026-11-08/closure-v5/RESULT.md)
and [clean v5 repeat](scratch-projects/multica-final-suite-2026-11-08/long-run-v5/RESULT.md).
Contracts v4/v5 and acceptance documentation are committed through 16834eaa1;
the installed runtime remains 9bd735f7c. No push or new provider login occurred.



## November 9 direct Codex launch comparison

Seven direct Codex approval flows retained the original resolved permission
profiles and completed launch without the historical sharing violation. They
included actual alternate-index writes after an ordinary denial, held execution/
session/temp locks, a delayed approval and paired approval flows. A matching
current Multica control ORCH-98 also passed and is closed. The original Office
script limited to Excel launched but reproduced COM E_ACCESSDENIED. No sandbox
protection was removed. Original Git history/indices and Office outputs were
preserved; helper processes and files were cleaned up. No runtime fix was
established or installed. These controlled equivalents do not reproduce the
complete historical environment or destructively replay original Git commits.

See [direct reproduction result](scratch-projects/multica-final-suite-2026-11-08/direct-codex-repro-2026-11-09/RESULT.md).
