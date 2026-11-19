> Historical snapshot imported November 18, 2026 from `agent-orchestration-summary.md`.
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

# Agent orchestration: summary and recommendations

Historical testing update — November 13, 2026

Swarm is now running the local 2.13.0 fork at247acd8d5 (two local repair commits; no push). The full strict API suite passes171 scenarios. Real Luna/low authentication, Windows-mounted output, relative Git worktrees, and GUI Pause→queued correction→same-task Resume have passed. The successful live control repeat preserved32 checkpoint rows and finished at42 after verified process exit and a new execution. Two earlier failures remain recorded: a model target mistake, then a framework initial-correction acknowledgement mismatch that was repaired with strict ownership/generation checks.

The active Windows reboot test is now armed with a live Git checkpoint writer and a native ten-minute lead backstop registered before delegation. Host-reboot recovery, separate crash/approval cases and the clean two-hour mixed pilot are still pending; these results do not yet replace the earlier end-to-end comparison. Optional maintenance schedules and telemetry are disabled; heartbeat/scheduling remain on. No extra provider login or desktop takeover was needed. Native confirmed pause is Linux Codex in Docker; native Windows/other-provider pause remains unsupported. Lead-native steering/cancel and operator GUI pause/resume are separate capabilities.

Current receipts, deployment versions, caveats and continuation instructions: [Swarm pilot status](scratch-projects/swarm-current-pilot-2026-11-12/LIVE-RESUME.md).


This report consolidates the October research, November6–8 Multica follow-ups, and November9–10 Agent Swarm/Firstmate deep pilots. Conclusions apply to tested versions and configurations; they are not long-term reliability guarantees.

## November10 deep-pilot update (historical)

**Multica remains the strongest tested fit for your combination of a GUI,
unrelated projects, nested delegation, Windows work and hours-away execution.**
Its separate active-reboot and clean v5 longer-run results remain unchanged.
Swarm is a credible background-workflow alternative with stronger native DAG
machinery, but its longer run required corrections and Pause still fails to
stop execution. Firstmate's conversational model remains attractive, but the
tested Windows/backend combinations required substantially more maintenance.

| New evidence | Outcome | Consequence |
| --- | --- | --- |
| Swarm2.5.3 private fork, six actors, two-hour mixed run | Assisted acceptance; independent26-case CLI and12-case Git checks passed; durable waits/approvals/retry/crash/steering/Cancel passed | Useful durable alternative, not a clean unattended pass |
| Swarm defects | Three local fixes built, deployed and genuinely exercised; Pause and nested cancellation remain incomplete | Do not treat Pause as stopping execution; child cancellation needs explicit handling |
| Swarm Windows files/Git | Shared files and main repo usable; Linux-created linked worktree fails Windows Git because pointers are container-absolute | Container Git2.43 lacks relative-worktree support; cross-namespace worktree use remains unresolved |
| Native Firstmate + legacy Herdr + Claude | Code/planning accepted after two-hour gate; actual one-hour audit, hosted-source secondmate/scout, assisted checkpoint recovery and fixed Office passed | Business success with intervention; local-only projects still lack persistent secondmate routing |
| Native Firstmate operations/UI | One supported exit fixed privately and passed; teardown700/mode755 guard, board listener and native host child cleanup remain blocked | No clean lifecycle closure or reliable away-supervision claim |
| WSL Firstmate + Codex | Working reviewed code/planning and actual one-hour audits | Deliberate unverified-lifecycle gates prevent guarded delivery; closed blocked, no two-hour acceptance |
| Newer Herdr GUI/core | Experimental `hc` hello/terminal/GUI API, real Haiku primary and actual isolated-worktree entry after setup fixes | Native core reports parent cwd, blocking guarded dispatch; zero scouts/full GUI pass; secondmates/away unsupported |

The full Swarm runtime used2.5.3. Official2.10.0 was already available just
before intake; that check happened late. A separate current-source diagnostic
audit found the same three defect groups and pause gaps, with24 positive
controls passing/70 desired invariants failing. This was not a complete2.10
deployment or upstream-suite run. Current skipped-dependency policy requires
adapting the old SQL fix before porting. The installed private build remains
2.5.3-based. See the [current-source audit](scratch-projects/orchestration-deep-pilots-2026-11-09/upstream-current/REPORT.md).

Both candidates passed a **custom fixed background Office operation**, not a
bundled arbitrary desktop controller. No new provider account, full desktop
takeover, host reboot, upstream push or Multica change occurred. No fair cost
ranking is supported by the different models and permission environments.

Final evidence and limitations: [Swarm result](scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/RESULT.md),
[Firstmate result](scratch-projects/orchestration-deep-pilots-2026-11-09/firstmate/RESULT.md),
[interventions](scratch-projects/orchestration-deep-pilots-2026-11-09/INTERVENTIONS.md).
These supersede provisional November9 statements below.

## Recommendation — November 14, 2026

**Multica remains my narrow recommendation for your primary daily workspace.
Agent Swarm is now a credible peer and the stronger native dependency/workflow
engine.** The earlier recommendation based on Swarm lacking a clean long run,
working Pause or real reboot recovery is superseded for the tested2.13.0 fork.

Your priorities favor recognizable unrelated projects, a GUI for finding the
right worker, lead-driven delegation and frequent Windows files/programs.
Multica supplies that project/task organization more directly. Its workers run
natively on Windows; its application backend still uses Docker. Swarm's tested
workers run in Linux containers, with deliberate Windows mounts and host bridges.
Both completed multi-project hierarchy, delayed requirements and review, long
waits and final closure on Luna/low. Neither successful run is a lifetime guarantee.

Swarm has the better mechanical recovery result: native original-task resumption
after Windows reboot, dependency-gated owning acceptance, and a separately passed
real API crash. Multica also passed active-work reboot, but its durable root timer
had to start a new worker attempt after a shutdown-time continuation consumed its
event and failed. Both completed without an operator post-reboot nudge.

Remaining Swarm caveats include model-authored handoff errors, missed replacement
state and redundant checks; baseline async outer-node validation bypass; global
followup routing; generic parent-task cancellation not cascading; Linux/Codex-
only confirmed pause; and Docker/fork/mount administration. Explicit workflow
ownership and independent verification made the tested configuration work.

Remaining Multica caveats include coordination/backstop dependence, a separate
Codex-specific custom approval UI, Windows supervisor/fork upkeep and historical
approved-command MXC launch failures. Seven later direct launches and a matching
Multica control succeeded; no reproducible cause or launcher fix was established.
The Windows packaging/PATH regression itself passed its installed-path retest.

This comparison is not permission-equivalent: Swarm used broad command execution
inside constrained container mounts; Multica used native Windows MXC/on-request
review. Swarm's human-decision workflow gate does not demonstrate equivalent
per-command/file-access approval handling. No valid cost or statistical reliability
ranking follows from the different run/task counts.

Both fixed background Office tests passed via custom host tools; neither proves
arbitrary desktop operation. Both use local orchestration and existing model
authentication. Model inference remains remote. A stock install has not passed
this same matrix without the recorded local repairs/configuration.

Choose Multica for the first real ongoing project if these daily-work priorities
remain unchanged. Choose Swarm if explicit dependency control and durable workflow
execution outweigh first-class project organization/native Windows execution for
you. Its technical foundation is now strong enough to justify that choice.


## Comparison at a glance

| Option | Main appeal | Verified evidence | Main reservation |
|---|---|---|---|
| **Multica 0.7.0 + local fork (historical; superseded above)** | Projects, parent tasks, subtasks, assignments and review | Fresh v5 two-hour mixed workflow closed all 13 without correction; separate reboot, Git, scoped approval and fixed Office tests passed | Earlier closure failures needed instruction/guard fixes; broad MXC escalation, latency and custom maintenance remain concerns |
| **Agent Swarm2.13.0 + four local commits** | Native DAGs, dependencies, continuation and recovery | Unassisted2h45m mixed pilot; actual API crash and full Windows reboot/lead closure; Linux Codex GUI pause/resume, relative worktrees and fixed Office passed | Model handoff/state errors, async validation bypass, generic parent cancellation/global followup routing, Docker/fork upkeep; pause scope limited |
| **Firstmate + legacy Herdr0.9.5; experimental HC separate** | Conversational supervisor | Native longer business acceptance, nested read-only audit, assisted recovery, Office passed | Native closure/UI listener fail; WSL Codex guarded delivery blocked; experimental GUI scope reduced |
| **Orca 1.4.239** | Rich interface for inspecting and steering agents | Separate repositories, task structures and real artifact production | Complete orchestration failed under our sandbox configuration |
| **Cabinet 0.5.0** | General work, documents, agent teams and routines | WSL execution and native child dispatch | Successful continuation failed to persist in history |
| **sudocode 1.2.0** | Repository-local specs, issues and relationships | UI relationships and actual file execution | Windows integration problems; execution remained Pending |
| **Stoneforge 1.25.0** | Director/worker coordination within a project | UI, task structures and basic adapter execution | Coordinated trial failed; unrelated-project management less established |

Exact source revisions, runtime versions, receipts and screenshots are recorded in the [hands-on report](agent-orchestration-hands-on-2026-10-24.md) and [expanded research](agent-orchestration-expanded-review-2026-10-23.md).

## Multica

### What using it looks like

Use a browser project/task interface. Create separate projects for unrelated work, attach their resources, and assign a main issue to an agent or squad. The coordinator can create staged subissues for implementation and review. Inspect the board or list, open an issue for discussion and execution traces, and add follow-up requirements to the same deliverable.

Assignment to an agent starts a run; assignment to a squad starts its leader, which decides how to delegate. Projects, deliverables and individual executions remain distinct. See the [official issue documentation](https://multica.ai/docs/issues).

### Verified

- Coding and unrelated planning projects ran concurrently.
- Definition, implementation and independent review proceeded in sequence.
- A late requirement reopened the original parent, added children and completed successfully.
- Original independent verification passed five final tests; the clean v5 repeat passed 11/11 boundary checks and 5/5 large-input queries.
- Backend records survived restart.
- After reboot, the previous Windows sandbox startup error disappeared, and a Luna worker completed ORCH-11.

The post-reboot smoke issue lacked a project binding, so its fixture-file write required a reviewed escalation. Ordinary shell reads and status/comment commands worked. It establishes recovery from the immediate startup blocker, not a clean project-bound restart test.

### Advantages

The clearest tested interface for managing multiple bodies of work. Ownership, discussion, status and execution evidence stay attached to recognizable tasks. Late changes preserve continuity with the original deliverable.

### Limitations and unknowns

Stages wake a parent agent to decide what happens next; these trials do not establish arbitrary scheduler-enforced dependency graphs. Assignment, business status and actual run creation are distinct. Earlier stalls came from treating a status update as dispatch and waiting indefinitely for an agent-maintained status. Corrected instructions on the same Luna/low model verified run receipts, used terminal watches with bounded waits, included waiting_local_directory as active, gated reviews in backlog and preserved the owning/root completion obligation. This supports a coordination-contract diagnosis; no different model was required to correct those cases. The platform still relies heavily on agent judgment.

The fresh November 8 longer run exposed another final-acceptance failure after all artifacts and reviews passed: ORCH-69 stayed in_review, its lead/root stayed in_progress, and there were no active runs or enabled wakeups. V5 clarified acceptance authority, removed circular waiting for root pre-acceptance, required an independent bounded root backstop and made handoffs conditional on current evidence. Its first scheduled corrective check closed all ten issues. A later continuation preserved their accepted states. The main run used two normal owner cleanup approvals and one explicit coordination/backstop repair; all 43 runs ended completed despite the earlier unfinished business state. It is not an unattended pass. See the [longer-run result](scratch-projects/multica-final-suite-2026-11-08/long-run/RESULT.md).

A fresh short v5 supervisor → project lead → inspector regression closed all three issues with zero corrective intervention, no pending runs/wakeups and an unchanged sentinel. See the [fresh regression](scratch-projects/multica-final-suite-2026-11-08/closure-v5/RESULT.md). A separate clean full v5 repeat (ORCH-85) then ran from 21:23 to 23:38 Mountain. Its agents created the root guard before delegation, corrected a defect found by their reviewer, accepted the delayed 10,000-row audit, waited for the two-hour decision, revised the planning brief, obtained fresh review and closed all thirteen issues. Final independent verification found zero active runs, enabled wakeups or approval requests after dispatch; all input and reviewed-artifact hashes were preserved. Forty-seven runs completed and five redundant queued continuations were cancelled before starting. No corrective operator prompt, approval, login or runtime change was needed after dispatch. See the [clean longer result](scratch-projects/multica-final-suite-2026-11-08/long-run-v5/RESULT.md). Multiple serialized coordinator turns add latency: final acceptance took about fifteen minutes after the last milestone. This is one successful elapsed-time test, including idle waits, rather than two hours of continuous useful compute.

The disposable Git trial completed parallel worktree commits, clean merges, a real 45/60 same-line conflict, recorded pre-resolution evidence and independent review. It required exact linked-index permission grants. A late reviewer then reopened an accepted child; operator repair and the v4 accepted-state guard passed a targeted regression. Native Multica worktree provisioning was not tested. See [Git evidence](scratch-projects/multica-final-suite-2026-11-08/git/RESULT.md).

The current local installation uses a persistent non-elevated scheduled supervisor with a Windows GUI launcher and no-window child processes. Executables live outside the denied review-credential directory, fixing the earlier packaging problem. Daemon and broker crash recovery passed, as did the installed-path lead/worker regression. Active-work reboot testing preserved all 36 pre-reboot checkpoints and added 12 after reboot. Its terminal-event continuation failed during shutdown after consuming the event; an independently registered root timer later resumed the worker and closed both issues without a post-reboot operator nudge. This verifies configured timer-backed recovery, not recovery of arbitrary tasks without a backstop. See the [reboot result](scratch-projects/multica-active-reboot-2026-11-08/RESULT.md).

Windows-MCP 0.8.8 previously passed a narrow 80×80 read-only screenshot test in user/balanced mode. Its interactive Notepad proof required manual takeover approval and exclusive desktop use. November 8 instead passed a fixed local application-API MCP tool: hidden Excel and Word instances created XLSX/DOCX/PDF fixtures, Excel calculated 42 and reopened, both foreground checks stayed false, and the owned processes closed. Independent file/process and tool-guard checks passed. This is a custom hash-pinned no-argument host tool outside the agent sandbox, not arbitrary Office or GUI control. Direct sandboxed COM was denied, and its reviewed command escalation failed before launch. A separate interactive Windows session remains untested. See [Office evidence](scratch-projects/multica-final-suite-2026-11-08/desktop/RESULT.md).

Upstream 0.7.0 automatically accepts the approval requests it receives; see its [adapter source](https://raw.githubusercontent.com/multica-ai/multica/dbdbb2991/server/pkg/agent/codex.go). The installed local runtime remains build 9bd735f7c. Its fork routes requests to a separate authenticated local review page, denies unavailable/stale requests, strips review credentials from child environments and denies worker reads of the private review directory. This is not a native Multica approval inbox or a policy engine for every provider/tool. Denying a command cancels the turn and appears as a failed run; denying a narrow permissions request returned an empty grant and let the test report the expected denial.

Three specifically approved Office/Git escalations failed before launch with MXC CreateProcessSecurityEnvironment HRESULT 0x80070020. Approval routing alone does not guarantee execution. Narrow linked-worktree grants, ordinary reviewed fixture cleanup and the fixed Office MCP tool passed separately. The experimental request_permissions_tool also passed exact-folder approve/deny with turn-scoped grants and continued credential isolation. It remains enabled only on its dedicated test agent. See [permission evidence](scratch-projects/multica-final-suite-2026-11-08/permissions/RESULT.md) and [local setup and contracts](scratch-projects/multica-local-reliability/local-reliability/README.md).

The application is locally hosted at localhost:43130, with no email provider or Multica cloud login required. The local verification-code flow opened the pilot account; DO_NOT_TRACK=true remains set. Inference uses existing Codex authentication, so local orchestration does not mean offline models. No new provider login or desktop takeover was needed for these follow-ups.

**Windows:** Native workers and attached Windows files worked with the Docker-backed application. The approved-command MXC failures are separate from the older startup blocker that cleared after reboot. Their general cause remains unresolved; the tested alternatives are narrow permissions and explicitly scoped host application tools.

November 9 command-rule investigation distinguished these failures from prefix-rule denials. All three original turn contexts used the user reviewer, broker approvals preceded the launcher errors, current isolated config reads reported no managed requirements or active rule files, and execpolicy checks found no matching rules. A forbidden-rule diagnostic control correctly returned forbidden. Initial Git/COM access denials were real permission boundaries; the later approved retries failed in MXC environment creation with Windows error 32 (sharing violation). No settings were weakened, and the underlying launcher cause is still unresolved. See the [policy investigation](scratch-projects/multica-final-suite-2026-11-08/policy-investigation-2026-11-09/RESULT.md).

A subsequent [direct Codex reproduction](scratch-projects/multica-final-suite-2026-11-08/direct-codex-repro-2026-11-09/RESULT.md) retained the original resolved permission profiles and user approval flow without Multica's adapter or broker. All seven approved programs launched, including actual alternate Git-index writes, held Multica-style locks, a 107-second approval wait and paired approval flows. A current Multica/broker control also passed. The original Office script limited to Excel launched and reproduced COM E_ACCESSDENIED, a separate restriction. Original indices/history and Office evidence were preserved. No runtime fix was installed; the historical sharing violation is not currently reproduced, and neither a specific Windows locking defect nor Multica ownership has been established.

## Agent Swarm

### What using it looks like

Use a web dashboard with task tables/boards, agent assignments, dependencies, approval forms, execution traces and a lineage graph. Create unrelated work as separate root tasks, then let a lead delegate and collect results. Follow-ups create linked continuation tasks.

A separate workflow interface represents reusable pipelines. The documented engine supports parallel branches, waits, approvals and child workflows. We inspected that UI and ran engine tests, but did not execute a complete custom nested workflow through the UI. See the [workflow documentation](https://docs.agent-swarm.dev/docs/concepts/workflows).

### Verified

- Implementation and independent review completed with native dependencies.
- The reviewer stayed pending until its prerequisite finished.
- Coordinator continuation happened automatically.
- A late requirement passed all five final tests.
- Separate root tasks could be created through the dashboard.
- After abruptly stopping and restarting the API and coder containers, Swarm replaced the interrupted task, rewired the reviewer dependency and completed both correctly.
- Independent byte checks confirmed the expected recovery output without duplication.

### Advantages

The strongest demonstrated recovery behavior. Explicit dependencies and task ancestry make execution relationships inspectable. Well suited to work intended to continue while the user is away.

### Limitations and unknowns

Project separation in our trial used roots and tags rather than Multica-like project organization. A coordinator dispatching unrelated work from inside an existing task attached it to that task; creating a separate root through the UI worked.

“Completed” can mean that a task deferred to a future continuation, rather than that the overall deliverable finished. Users need to inspect the result and lineage. Recovery took approximately 15 minutes under the default stale-heartbeat threshold.

The restart test covered an idempotent local task. It does not establish exactly-once external side effects, host-reboot recovery or arbitrary nested workflow reliability. Optional storage, memory and external integrations were not fully tested.

**Windows:** Execution is through Docker/Linux workers. October's isolated trial had no host-project mounts or Docker socket. The November deep pilot mounted only Windows fixture projects and verified shared-file access plus a custom fixed Office API; no Docker socket was exposed. Windows Git can inspect the main repo, but the existing Linux-created linked worktrees have absolute container pointers and fail host Git. Adopting real files still needs deliberate mount and Git-isolation configuration.

## Firstmate

### What using it looks like

Talk to a primary supervisor about outcomes and priorities. It launches workers, organizes worktrees, checks progress and steers follow-ups. The successful full orchestration and nested-delegation trials ran in WSL tmux sessions. Herdr is an alternative backend; the November native Windows component trial used Herdr instead of tmux.

The Bearings browser board provides fleet status and a feedback conversation. It is useful for oversight, but does not offer the same project/task editing workflow as Multica. See the [Firstmate repository](https://github.com/kunchenguid/firstmate).

The native Herdr trial ran a hidden server controlled through its CLI and Firstmate's adapter. We did not inspect or validate the visible Herdr desktop UI. Bearings browser feedback, native Herdr backend execution, and the full WSL/tmux hierarchy are three separate pieces of evidence; none establishes the others.

### Verified

- Two unrelated repositories had concurrent workers.
- An independent reviewer checked the implementation's exact commit.
- A late requirement reused the retained worker and reviewer without rerunning unrelated work.
- All five final tests passed independently.
- Browser feedback reached the supervisor and its acknowledgement appeared on the board.
- November 6: a persistent WSL secondmate launched its own scout, received the report, and acknowledged completion to the primary through native correlated records. Scoped approvals and manual correction of one unsubmitted doorbell were needed.

### Advantages

A natural interaction model for delegating multiple kinds of work without managing every task manually. Demonstrated continuity across late revisions, separate worktrees and independent review.

### Limitations and unknowns

Setup needed authentication-environment, launch, line-ending and WSL filesystem fixes. Completed workers sometimes remained classified as `unknown/codex-unverified`, making artifacts and task records more trustworthy than runtime labels.

Secondmates now have a successful bounded live test, plus a supported persist/restart and unique ping reply from the same persistent home with retained findings. This does not establish machine-restart recovery or reliable away-mode supervision. The earlier browser feedback test required resuming the stopped primary; it did not demonstrate an always-listening supervisor. The November secondmate test used native parent-channel correlations; parent relationships in the earlier ordinary task trial were recorded in task bodies. Unsubmitted inbox doorbells and scoped permission handling required intervention.

**Windows (November 6 follow-up):** Native Git Bash + Firstmate's Herdr adapter + Herdr 0.9.5 + Codex 0.167.0/MXC completed a real read-only agent task, and a retained-conversation follow-up passed. Native Treehouse 3.1.8 worktree allocation also passed. These are verified integration components, not a full native coordinator/secondmate/worker acceptance test. Separate native and WSL runtime state was needed; initial sandbox setup and readiness reporting also required care. WSL remains viable after setup work. See the November 6 section of the [hands-on report](agent-orchestration-hands-on-2026-10-24.md) for the boundaries and additional nested-delegation results.

**Native Windows assessment after the November10 deep trial:** Legacy Herdr/Claude delivered accepted code/planning, a separate hosted-source secondmate/scout audit and assisted recovery. Normal closure, board control and native host cleanup remain unresolved; final supervisors needed manual cleanup. Local-only projects cannot use persistent secondmates. Experimental HC passed protocol/terminal/GUI API and a real Haiku primary. Corrected setup let Treehouse enter an isolated worktree, but the native core still reported parent cwd and Firstmate correctly refused guarded dispatch. Startup's120s banner was informational; the first pause was model/prompt behavior. A complete native graphical hierarchy and dependable unattended operation remain unverified.

## Orca

### What using it looks like

An interface centered on projects, workspaces/worktrees, agent terminals, files, source control and tasks. Open multiple projects, inspect workers, steer terminals and review artifacts. Structured orchestration adds Runs, parent tasks, dependencies and worker attempts. See the [Orca repository](https://github.com/stablyai/orca).

### Verified

Two repositories in the sidebar, a nested worktree, parent/dependency records, worker startup and failure handling, and a real planning artifact with independently checked arithmetic.

### Advantages

Rich visibility into actual working environments. Particularly appealing for inspecting and steering agents throughout the day.

### Limitations and unknowns

The test operator created much of the orchestration structure through the CLI; this was not a successful autonomous coordinator loop. A worker produced its artifact but could not commit or report completion. Independent probes traced those failures to sandbox restrictions on Git metadata and Orca's local socket.

Those restrictions came from our trial configuration. They do not prove stock Orca cannot work, but we lack a successful end-to-end result that would justify recommending it over Multica or Swarm. Host/client launch settings also required API configuration, and early startup failures exhausted one task's retry allowance.

**Windows:** Our execution trial used WSL and the browser client. Native Windows desktop operation was not fully validated.

## Cabinet

### What using it looks like

A browser workspace with files/data, a team of agents, tasks, routines and schedules. Task views offer Chat, Artifacts, Diff and Logs. A coordinator proposes delegation; an approval card lets the user review the action before a child launches.

### Verified

Onboarding, heartbeat controls, WSL file execution, and a UI-approved native child with the correct parent and inherited Luna model. After a path correction, the child produced the correct review artifact.

### Advantages

An approachable model for documents, research and recurring work. Delegation approval is explicit and reviewable.

### Limitations and unknowns

The child needed an absolute-path correction. Its successful continuation then failed to persist in conversation history, leaving the UI/API showing the earlier failure. The model picker also offered defaults incompatible with the trial account.

Parallel child joins, restart recovery and a full mixed-project workflow remain unverified. Task history is not yet trustworthy as the sole record of unattended execution in this tested configuration.

**Windows:** Sandboxed Docker execution failed on namespace creation; WSL execution worked. Neither result establishes the stock native Windows desktop experience.

## sudocode

### What using it looks like

Open a local project in the browser, manage specs/issues, connect parent and dependency relationships, and launch an agent against an issue. Project switching and repository-local records support keeping work organized near its files.

### Verified

Two-project UI/API operation, relationship display, and an agent writing and verifying a file.

### Advantages

A relatively lightweight task/spec model with explicit relationships and versionable project records.

### Limitations and unknowns

Windows adapter launching and worktree quoting needed workarounds. A visible console problem required a local patch whose UI behavior was not subsequently verified. Execution remained Pending after the agent finished. The adapter change may have affected lifecycle compatibility; the cause remains unresolved.

**Windows:** Multiple observed integration problems. Neither a complete execution lifecycle nor a WSL solution has been verified.

## Stoneforge

### What using it looks like

A browser dashboard with plans, tasks, dependencies, a director and worker sessions. Give the director work, inspect its breakdown, and follow workers through execution and review. Its “Workspaces” view arranges terminals; it does not establish unified management across unrelated project roots. See the [Stoneforge repository](https://github.com/stoneforge-ai/stoneforge).

### Verified

Task/dependency operations, UI inspection, plan creation, basic Codex adapter execution, and actual attempted coordinator/worker launches.

### Advantages

Substantial structure for coordinated development within a project.

### Limitations and unknowns

The full coordinated trial failed. Provider-selection and session-resumption problems were observed, alongside a local-network restriction introduced by our tightened sandbox. Stock provider permission behavior also differed from what project approval settings suggested. Relevant upstream proposals were found, but no applicable released fix was verified.

No full implementation/review or late-change success was established. Unified management of unrelated project roots remains less clear than in the leading options.

**Windows:** Native task CLI operations worked; the coordinated execution attempt used WSL and did not complete.

## Earlier contenders and research-only alternatives

**Paperclip remains worth considering.** Its organizational model includes goals, projects, agent roles, assignments, budgets and recurring work. It could suit a standing agent team. However, its earlier installation and basic execution test were substantially shallower than the recent Multica, Swarm and Firstmate trials. The original report's “definitive winner” wording was not justified. Paperclip is an under-tested alternative, not a defeated candidate. See the [repository](https://github.com/paperclipai/paperclip).

**Agent Orchestrator** remains interesting for native session execution; **Maestro** for desktop supervision. Neither has equivalent evidence from the latest acceptance scenario. Earlier claims of “bulletproof” recovery should be read as specific architectural strengths, not comprehensive reliability guarantees.

Raven, Crewly, Mission Control and the other discovery candidates remain research leads. Their documented capabilities should not be ranked as if they had passed the same authenticated workflow tests. The [expanded research](agent-orchestration-expanded-review-2026-10-23.md) records why they were not prioritized.

## Cross-cutting conclusions and next steps

- **File creation is not end-to-end completion.** Cabinet, Orca and sudocode produced artifacts without reliably recording the corresponding successful lifecycle. This matters for unattended orchestration.
- **The trials used different execution boundaries.** Swarm ran full-access agents inside isolated containers; several other trials retained workspace sandboxing and required wrappers or reviewed escalations. Failures introduced by those configurations are identified above and should not be called stock product defects.
- **Recovery depends on the tested configuration.** Swarm passed an abrupt API/worker restart. Multica passed worker retries, daemon/broker crash recovery and active-work host reboot with a persistent scheduled supervisor and an independent root timer. Its shutdown-time event continuation failed after consuming the event; the separate timer recovered the checkpointed work. This is a locally maintained addition and configured workflow, not stock automatic recovery for arbitrary tasks.
- **Costs remain unranked.** Models, configurations and workloads differed; application counters were not comparable invoices. Luna worked for bounded follow-up tests, which does not establish the cheapest reliable configuration for large projects. The user has also authorized existing authenticated Claude/agy models and smaller Codex models for future framework tests.
- **The next investment should target practical use and the remaining failures.** Multica now has separate positive path, active-reboot, scoped-approval, fixed Office and clean v5 longer-run evidence. Broad approved MXC launch failures remain unresolved; arbitrary desktop automation, repeated long-term reliability, multi-user operation and upstream upgrade maintenance remain unverified. Git worktree provisioning was operator-assisted. Firstmate still needs unattended delivery/recovery and a complete native Windows hierarchy test.

## Evidence and report precedence

1. [Hands-on results, including post-reboot addendum](agent-orchestration-hands-on-2026-10-24.md): primary source for observed behavior and screenshots.
2. [Expanded alternatives research](agent-orchestration-expanded-review-2026-10-23.md): discovery trails, architecture, documentation/source findings and test revisions.
3. [Original landscape](agent-orchestration-landscape-2026-10-03.md) and [earlier AO/Paperclip evaluation](agent-orchestration-eval-report.md): historical context; their rankings and stronger reliability claims are superseded by this summary where they conflict.

Some earlier sections describe blockers at the time they occurred. The November results supersede statements that Multica is currently unable to execute or that active-work host-reboot recovery and a clean longer workflow have never passed. Broad sandbox escalation failures and general long-term unattended reliability remain unresolved.




## November 9 deep comparison in progress

Agent Swarm and Firstmate with legacy Herdr are undergoing longer local pilots. Preliminary results, fixes, operator interventions and outstanding acceptance gates are recorded in the [live checkpoint](scratch-projects/orchestration-deep-pilots-2026-11-09/STATUS.md). Earlier statements about untested Firstmate delivery or Swarm controls are historical where that checkpoint contains newer evidence. Neither new pilot has final end-to-end acceptance yet; the existing Multica results are unchanged.

## November 8 post-reboot verification

Startup after reboot was observed, including supervisor retries until the local backend became available. A fresh two-minute delayed lead and delegated worker passed installed CLI access, native execution, sentinel verification and credential isolation; both issues closed with no corrective nudge or dangling work. This directly verifies the final path layout, but no active task crossed that reboot. See [post-reboot results](scratch-projects/multica-post-reboot-2026-11-08/RESULT.md).
