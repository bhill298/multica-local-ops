> Historical snapshot imported November 18, 2026 from `agent-orchestration-expanded-review-2026-10-23.md`.
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

# Agent orchestration alternatives for multiple projects

Current testing update — November 13, 2026

Swarm is now running the local 2.13.0 fork at247acd8d5 (two local repair commits; no push). The full strict API suite passes171 scenarios. Real Luna/low authentication, Windows-mounted output, relative Git worktrees, and GUI Pause→queued correction→same-task Resume have passed. The successful live control repeat preserved32 checkpoint rows and finished at42 after verified process exit and a new execution. Two earlier failures remain recorded: a model target mistake, then a framework initial-correction acknowledgement mismatch that was repaired with strict ownership/generation checks.

The active Windows reboot test is now armed with a live Git checkpoint writer and a native ten-minute lead backstop registered before delegation. Host-reboot recovery, separate crash/approval cases and the clean two-hour mixed pilot are still pending; these results do not yet replace the earlier end-to-end comparison. Optional maintenance schedules and telemetry are disabled; heartbeat/scheduling remain on. No extra provider login or desktop takeover was needed. Native confirmed pause is Linux Codex in Docker; native Windows/other-provider pause remains unsupported. Lead-native steering/cancel and operator GUI pause/resume are separate capabilities.

Current receipts, deployment versions, caveats and continuation instructions: [Swarm pilot status](scratch-projects/swarm-current-pilot-2026-11-12/LIVE-RESUME.md).


## November10 evidence update

The subsequent deep pilots change the practical ordering: **Multica remains the
best tested fit; Agent Swarm is the strongest tested background-workflow
alternative; Firstmate is a higher-maintenance conversational option on this
Windows setup.** Orca's visual appeal remains based on earlier, less successful
execution evidence; it did not receive a new deep pilot here.

Swarm's2.5.3 private deployment completed the two-hour mixed scenario with
intervention, and three committed dependency/runtime/offer fixes now pass real
integration tests. Durable DAG waits, approvals, worker/API recovery, steering,
Cancel and a fixed Office bridge worked. Pause does not stop the provider,
parent cancellation leaves children, and Linux linked worktrees fail Windows
Git. Final independent inventory found no unfinished Swarm tasks/schedules.
Official2.10 was available before intake; a late current-source audit confirmed
the same targeted defects, but no full2.10 deployment was tested. Its skipped
dependency policy means the old SQL patch cannot be ported unchanged.

Native Firstmate/legacy Herdr/Claude delivered independently verified code and
planning after real delayed gates, plus a hosted-source secondmate/scout audit
and assisted checkpoint recovery. Normal cleanup failed; a private /exit fix
passed one supported exit, but mode700 guard, native board listener and host
child cleanup remain unresolved. WSL/Codex produced good files but cannot
complete guarded delivery because inspected lifecycle gates intentionally
return unverified; its pilot closed blocked without second-hour acceptance.

**The newer graphical Herdr does have a separate experimental Firstmate `hc`
adapter.** Legacy adapter exclusions do not apply to every backend. HC supports
ship/scout but refuses secondmates and away daemon. Its bounded native
component passed hello/labelled terminal/GUI API projection and a genuine Haiku
primary turn/home lock/digest after supported trust-only lab setup. After prompt
and isolated tool-PATH corrections, Treehouse really entered a worktree but the
native core still reported parent cwd, blocking guarded dispatch. Zero scouts;
slash-text/liveness issues remain. No complete
native GUI hierarchy is established. Six local source commits and private wrappers
were needed during this investigation. No new provider account, host reboot,
public push or Multica change occurred. Custom Office API success is not a
bundled general desktop controller.

See [Swarm results](scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/RESULT.md),
[Firstmate results](scratch-projects/orchestration-deep-pilots-2026-11-09/firstmate/RESULT.md),
[interventions](scratch-projects/orchestration-deep-pilots-2026-11-09/INTERVENTIONS.md)
and [current-source scope](scratch-projects/orchestration-deep-pilots-2026-11-09/upstream-current/REPORT.md).
Historical research/recommendations below retain their original dates and are
superseded where this update gives stronger measured evidence.

Research date: October 23, 2026, America/Denver. Some test timestamps are October 24 UTC. This supplements `agent-orchestration-landscape-2026-10-03.md` and `agent-orchestration-eval-report.md`.

**Multica is the first product I would trial for your stated workflow. Orca is the strongest alternative when you want to supervise the agents directly. Agent Swarm deserves a separate trial if nested, restartable workflows matter enough to accept a container-based deployment.** Firstmate remains attractive as a conversational supervisor, but its Windows and backend combinations need more qualification than its headline promises suggest.

The original report's “definitive winner” for Paperclip and “bulletproof recovery” for Agent Orchestrator are too strong. The earlier tests establish useful capabilities, not an end-to-end guarantee across projects, nested delegation, quota failures, restarts, and late changes to completed work.

## What the system needs to represent

Your requirement includes three separate relationships:

- **Projects:** several unrelated bodies of work, each with its own context, files, priorities, and possibly different agents.
- **Task hierarchy:** a main task can delegate to subtasks or another coordinator, then collect their results.
- **Execution dependencies:** some work must wait for prerequisites, while independent branches can proceed together.

A project sidebar alone does not establish orchestration across projects. A parent task field does not establish dependency enforcement. Keeping terminal processes alive when a window closes does not establish recovery after reboot. These distinctions drive the comparison below.

## Shortlist

| Candidate | Fit for your work | Interface and Windows position | Main tradeoff |
|---|---|---|---|
| **Multica** | Strongest project/issue/subissue product fit; project leads, squads, staged handoffs | Web and desktop; documented native Windows runtime and installer | More infrastructure; staged progression still depends on an agent's decisions; custom source-available license |
| **Orca by stablyai** | Strong visual supervision with tasks, dependencies, coordinator inboxes and nested coordination | Native Windows desktop and remote execution support | Structured orchestration is experimental; the coordinator supplies scheduling judgment |
| **Agent Swarm by desplega-ai** | Strongest new candidate for executable nested workflows, dependencies, joins and recovery | Web dashboard; container-oriented deployment; core workflow tests passed natively on Windows | More operational setup and configuration than a desktop app |
| **Firstmate** | Particularly good conceptual fit for “talk to one supervisor across projects,” including secondmates | Terminal/backend interface; Windows work is emerging | Supported behavior depends on the exact harness/backend/host combination |
| **sudocode** | Lightweight specs, tasks, hierarchy and dependency graph across projects | Local web UI; native Windows CLI and multi-project API smoke tests passed | Global coordination across projects is less established than per-project workflows |
| **Cabinet** | Promising for unrelated research, writing, knowledge and recurring tasks | Web UI and Windows desktop packaging documented | Child-task lineage exists, but durable dependency joins are not established |
| **Stoneforge** | Rich director/worker workflow within a project | Web dashboard; native Windows task CLI passed | Project scope and a verified Codex permission mismatch make it a secondary choice |

These are fit judgments, not measured rankings of output quality or cost.

## Where the additional candidates came from

The outward search included actual comparisons, migration reports, discussions inside competing projects, and product directories. Several useful trails also exposed reasons not to trust an old recommendation:

- A user comparing Vibe Kanban, Maestro and Auto-Claude later preferred **AutoMaker**. The same discussion introduced **sudocode**. This was a useful discovery trail, but AutoMaker's current repository now states that it is no longer actively maintained. [Comparison discussion](https://www.reddit.com/r/ClaudeCode/comments/1q9dmxd/multiagent_orchestration_for_parallel_work_tools/), [current AutoMaker status](https://github.com/AutoMaker-Org/automaker/blob/main/LICENSE).
- A developer at Crescentic described using Paperclip for product operations and adopting **Multica** for parallel development tracks and reusable skills. This is a firsthand workflow report. Its table characterizes Paperclip too narrowly, so it is evidence of that person's preference, not proof Paperclip lacks agent orchestration. [Experience report](https://crescentic.com/blog/stop-juggling-workflows).
- An **Orca** user asks for Multica as a task source because they already use Multica for intake and want Orca for execution. The integration request remains open. A separate Multica proposal describes the missing execution-provider contract. This supports treating them as distinct alternatives initially rather than assuming they form a ready-made stack. [Orca issue 6978](https://github.com/stablyai/orca/issues/6978), [Multica issue 6229](https://github.com/multica-ai/multica/issues/6229).
- Firstmate reports include successful use with Herdr and a specific macOS/Pi complaint about stalled work and missed revisions after a PR exists. The latter supplies a valuable acceptance test: send a substantial follow-up after completion and verify that the same work resumes. It does not establish that the current release still has that failure. [User discussion](https://www.reddit.com/r/ClaudeCode/comments/1vtfawm/how_are_you_running_multiple_coding_agents_at_the/).
- Orca users report both successful Windows/Linux adoption and preferences for Conductor or T3Code because of chat-view or account-management problems. Maintainer replies describe subsequent changes. These are dated test leads, not current defect confirmations. [Orca discussion](https://www.reddit.com/r/ClaudeCode/comments/1vwjgyv/orca_ade_is_incredible/).
- A developer retired their own Bosun supervisor in favor of a customized Firstmate setup with a second machine. That is stronger evidence of sustained adoption than a launch announcement, but it describes a customized macOS environment. [Bosun to Firstmate](https://davidtandoh.com/writing/from-bosun-to-firstmate/).

Directories and vendor comparison pages helped locate Agent Swarm, Stoneforge, Raven, Crewly, Cabinet, Agor and TeamHero. Their technical assessment below comes from current project documentation and source, rather than the directory's feature checkboxes.

## Multica

Multica most directly expresses your desired hierarchy: a workspace contains projects; a project contains issues; issues have subissues; agents or humans can lead projects. Project descriptions become execution context, and a project can reference multiple repositories. Work can therefore be organized around an outcome rather than one repository. [Projects](https://multica.ai/docs/projects), [project resources](https://multica.ai/docs/project-resources).

The important detail is how orchestration happens. Subissues can be assigned numbered stages. When the earliest unfinished stage has finished, the parent receives a notification; an agent assigned to the parent wakes and decides what to do next. This is a useful orchestration mechanism, but not equivalent to a generic dependency graph that deterministically starts every ready node. Parent and child statuses remain independent. Cancelled work counts as closed for progression, so a parent agent still needs to judge whether the goal was actually achieved. [Issues](https://multica.ai/docs/issues).

Project workflows define who takes over at a status transition. For example, implementation can go to a coding agent, review to another agent, and acceptance to you. The default workflow does not create those handoffs automatically. A squad assignment wakes the squad leader, which can delegate; it does not automatically run every member. Configure an explicit delivery workflow and responsible lead before evaluating autonomy. [Workflows](https://multica.ai/docs/workflows), [squads](https://multica.ai/docs/squads).

Windows support is more concrete than a generic cross-platform claim: there are Windows desktop/runtime paths and a PowerShell self-host installation mode. Self-hosting nevertheless means a Go server, PostgreSQL and the web application, plus the execution daemon. A passing workflow package test does not validate that complete deployment. [Repository and installation](https://github.com/multica-ai/multica).

Isolation is configurable. A local directory in Direct mode is modified in place and serialized. Parallel mode uses worktrees when the directory is a Git repository and the runtime declares support; unsupported isolation requests fail rather than silently falling back. New desktop resources can preselect Parallel. Existing resources retain their saved mode. The worktree can include a snapshot of uncommitted changes; it is not necessarily a clean checkout of HEAD. Non-Git directories remain serial. [Project resources](https://multica.ai/docs/project-resources).

Run completion and issue completion are different. Runs have bounded retries for certain infrastructure failures, while expired authentication, quota and model problems may need intervention. I would not infer unattended quota recovery from the presence of retries. The original Paperclip report also needs that distinction. [Runs](https://multica.ai/docs/tasks).

The repository uses the **Multica License**, which combines Apache 2.0 text with additional conditions. It explicitly permits internal use without a commercial license but adds restrictions concerning third-party hosting/distribution and branding. Calling it plain Apache-2.0 would omit material terms. [License](https://github.com/multica-ai/multica/blob/main/LICENSE).

**Verdict:** first trial. Use one workspace, separate projects for unrelated work, an explicit lead for each, and staged subissues for work that must proceed in order. Start with two projects and modest concurrency. The unresolved question is how reliably the lead handles ambiguous completion, a failed stage and late revisions with your selected harness.

## Orca

This is **stablyai/orca**, not one of the unrelated Orca frameworks. Current Orca has a substantial experimental orchestration layer: durable Runs, Tasks with dependencies, Dispatches representing attempts, supervised workers, messages and decision gates. A Run is a namespace and coordinator inbox; it does not itself schedule or place workers. A coordinator must choose and launch the work. Attempt identities make it possible to reject stale completion messages from an older retry. [Orchestration contract](https://github.com/stablyai/orca/blob/main/docs/site/content/docs/cli/orchestration.mdx).

Nested coordination is explicitly represented in its messaging rules: a worker that coordinates its own child Run receives mail in that Run's inbox and addresses its own workers rather than its siblings. Durable delivery and acknowledgement help avoid losing coordinator mail. A successful send proves enqueueing, not that the recipient read or acted on it. [Messaging and gates](https://github.com/stablyai/orca/blob/main/skill-guides/orchestration/references/messaging-and-gates.md).

This makes Orca a more serious Firstmate alternative than the “many terminals” description suggests. Its desktop supports repositories, worktrees, terminal splits, review and navigation between task and worker. Folder workspaces also cover work outside Git. Native Windows builds and Windows-specific runtime tests exist in the repository; tmux is not a prerequisite. [Repository](https://github.com/stablyai/orca), [Windows CI](https://github.com/stablyai/orca/tree/main/.github/workflows).

Recovery has a clear boundary. A background daemon owns terminal processes, so quitting or crashing the UI can leave agents running. Reopening can reattach to them. A host reboot or loss of that daemon ends those processes; restored layout and scrollback are not the resumed execution itself. [Session restore](https://github.com/stablyai/orca/blob/main/docs/site/content/docs/model/session-restore.mdx).

**Verdict:** second trial, particularly if you want to inspect and steer work throughout the day. Enable structured orchestration deliberately and use its coordinator instructions. Test parent/child Runs across two unrelated projects, not just several terminals in one worktree. Its chief uncertainty is the stability of the complete experimental coordinator loop and chat experience on your Windows setup; I did not run that authenticated loop.

Do not assume Firstmate's Orca adapter inherits all of Orca's platform support. That adapter currently documents macOS and refuses secondmate spawning, even though Orca itself supports Windows.

## Agent Swarm

**desplega-ai/agent-swarm** combines a lead agent, specialized workers, shared services and a web dashboard with an executable workflow engine. Its documented self-hosted deployment uses containers for workers. It supports coding and general operational work and multiple harnesses, including Codex. Compared with a desktop manager, it is closer to operating a persistent service. [Repository](https://github.com/desplega-ai/agent-swarm).

The workflow engine supports parallel branches, convergence, human approval, event/time waits and child workflows. A sub-workflow waits for its child to settle and passes outputs onward; a failed or cancelled child fails that node. These are meaningful execution semantics for tasks composed of other tasks. [Workflow documentation](https://docs.agent-swarm.dev/docs/concepts/workflows).

Source inspection resolved two details that older descriptions obscure:

- `parentTaskId` in ordinary tasks primarily carries continuation context and normally routes to the same worker. It is not the same as a workflow dependency or nested workflow.
- The current engine supports `foreach` concurrency limits and child workflow runs; older local prose describing narrower foreach behavior is stale. Child workflows reject recursive ancestry and enforce a nesting limit of 16. [Orchestration patterns](https://github.com/desplega-ai/agent-swarm/blob/main/docs/orchestration-patterns.md), [sub-workflow executor](https://github.com/desplega-ai/agent-swarm/blob/main/src/workflows/executors/sub-workflow.ts).

The relevant tests provide the strongest new no-auth evidence in this review: **50 passed, zero failed** across child workflows, foreach concurrency and wait recovery. Cases include recovery reconnecting to an existing child, cancellation/failure propagation, cycle/depth refusal and idempotent recovery of persisted waits. This verifies engine behavior under test; it does not promise exactly-once effects in an external API or successful model execution. [Child workflow tests](https://github.com/desplega-ai/agent-swarm/blob/main/src/tests/workflow-sub-workflow.test.ts), [concurrency tests](https://github.com/desplega-ai/agent-swarm/blob/main/src/tests/workflow-foreach-concurrency.test.ts), [recovery tests](https://github.com/desplega-ai/agent-swarm/blob/main/src/tests/workflow-wait-recovery.test.ts).

**Verdict:** serious third finalist. Prefer it if you expect reusable research → implementation → review workflows, nested processes and background operations. Expect more setup around workers, credentials, repositories and integrations. Passing the core on native Windows does not establish a supported native deployment of every worker and shell feature; the container route remains the more appropriate deployment to evaluate.

## Firstmate and Windows

Firstmate is an instruction-and-script distribution that runs inside an agent harness. It manages visible workers and isolated worktrees across projects, with optional persistent secondmates for delegated domains. It is a close conceptual match for “one main agent manages several unrelated projects.” Current primary recommendations are Claude Code, Grok and Pi; Codex is supported with bounded foreground supervision checkpoints. [README](https://github.com/kunchenguid/firstmate), [architecture](https://github.com/kunchenguid/firstmate/blob/main/docs/architecture.md).

The concern is broader than tmux pane splitting. Firstmate relies on shell scripts, path handling, process-state interpretation, hooks and backend-specific control. Changing the multiplexer does not by itself validate those layers.

The current situation is more nuanced than “no Windows support”:

- tmux remains the reference backend. Herdr is another documented path; there are also experimental backend adapters.
- A manually triggered **Windows Herdr automation spike** now exists, and configuration includes Git Bash/MSYS-specific watcher timeouts. This is concrete Windows development work, but a measurement workflow's existence is not a passing full Windows acceptance test. [Windows spike](https://github.com/kunchenguid/firstmate/blob/main/.github/workflows/windows-herdr-spike.yml), [configuration](https://github.com/kunchenguid/firstmate/blob/main/docs/configuration.md).
- Firstmate's **Orca adapter** still describes a macOS setup and no secondmate spawns. Using Orca therefore does not currently establish a documented native Windows Firstmate solution. [Adapter boundary](https://github.com/kunchenguid/firstmate/blob/main/docs/orca-backend.md).
- **psmux** supplies a native Windows multiplexer and tmux-compatible commands. It is worth knowing about, but Firstmate + psmux was not validated here. Compatibility must include the commands, formatting, process evidence and shell behavior Firstmate actually uses. [psmux](https://github.com/psmux/psmux).
- The Codex **App** backend is still described as unavailable; support for Codex CLI does not imply the desktop app can serve as a Firstmate session backend. [Codex App boundary](https://github.com/kunchenguid/firstmate/blob/main/docs/codex-app-backend.md).

**Verdict:** retain it if a conversational chief of staff is more important than an issue-board interface. For a near-term Windows trial, Orca or Multica has a clearer native product path. Firstmate on a Linux environment or a validated Herdr setup is a separate option. The native Firstmate/Herdr combination should earn trust with actual lifecycle and late-follow-up tests before becoming the unattended supervisor.

## sudocode

sudocode keeps specs and issues in versionable files, with a local database and browser interface. It has parent/child issues and explicit dependency relationships. Its server has a multi-project manager with separate databases/services for open projects. These are useful foundations for keeping unrelated work organized without a separate organizational platform. [Repository](https://github.com/sudocode-ai/sudocode), [project manager](https://github.com/sudocode-ai/sudocode/blob/main/server/src/services/project-manager.ts).

Current source includes both workflow execution and an agent-driven orchestrator. Despite Claude-oriented comments, the orchestrator's agent type is configurable with Claude Code as the default. A Codex adapter exists. That establishes implementation support, not authenticated compatibility with the particular Codex version you will use. [Orchestrator engine](https://github.com/sudocode-ai/sudocode/blob/main/server/src/workflow/engines/orchestrator-engine.ts), [Codex adapter](https://github.com/sudocode-ai/sudocode/blob/main/server/src/execution/adapters/codex-adapter.ts).

The Windows smoke test created a parent task and two children, blocked the API child on the schema child, and verified that closing the schema task made the API task ready. A separate unrelated project retained its own issue. A local server then opened both projects simultaneously and returned isolated issue lists through project-scoped API requests; frontend HTML was served successfully.

The practical installation issue was native SQLite: on this machine's Node 24.16.0, `better-sqlite3` 11.10.0 had no matching prebuilt binary and compiled using the existing Visual Studio/Python tools. An initial missing-binding failure came from my deliberate `--ignore-scripts` install and was resolved by rebuilding; it is not evidence of a broken ordinary installer.

**Verdict:** good lightweight fourth option, especially if task/spec portability matters. Multiple projects in one UI is verified. One persistent coordinator dynamically managing dependencies across those project boundaries remains unverified. Parent status also does not automatically imply that its unfinished children block it.

## Cabinet

Cabinet is more relevant if “unrelated projects” includes research, writing, planning and recurring reports. It offers a knowledge workspace, agents, missions/tasks, schedules, persisted conversations and a browser interface. Current documentation supports Windows source use and desktop packaging, with local Claude and Codex adapters. [Repository](https://github.com/cabinetai/cabinet).

Its source does create delegated tasks and records `parentTaskId`, with provider/model inheritance and explicit overrides. That is real delegation, but the examined dispatcher does not establish a durable dependency graph that waits for all children and resumes a parent exactly once. Recording lineage is best-effort in that path. Nested cabinets also have distinct conversation identities. [Action dispatcher](https://github.com/cabinetai/cabinet/blob/main/src/lib/agents/action-dispatcher.ts), [conversation store](https://github.com/cabinetai/cabinet/blob/main/src/lib/agents/conversation-store.ts).

**Verdict:** worth considering for knowledge-centered work, behind Multica for the full mixed-project requirement. Before choosing it, test parent completion after parallel children, interruption during delegation and recovery after daemon restart. No local runtime test was performed.

## Stoneforge

Stoneforge has a director, worker pools, task/dependency records, workflows and merge coordination. Its quarry/smithy separation and local database make it a substantial orchestration product rather than a prompt collection. It is still described as early/experimental, and its workspace model centers on a Stoneforge project root. A single unified manager for unrelated project roots was not established in the examined material. [Repository](https://github.com/stoneforge-ai/stoneforge).

Its native Windows CLI successfully initialized an `approve` project, stored tasks/dependencies and handled prerequisite completion. The published package needed the same native SQLite rebuild on Node 24. Launching that package through Bun also failed to resolve its `@stoneforge/quarry/cli` export; the Node entry point worked.

The more material finding is a configuration mismatch. The generated configuration says `agents.permissionModel: restricted`, `merge.requireApproval: true` and `workflow.preset: approve`. Yet the Codex headless provider hardcodes `approvalPolicy: 'never'` and `sandbox: 'danger-full-access'` for both new and resumed threads. This appears in the inspected source and installed 1.25.0 package. Merge approval and tool-execution approval are different controls. No real Codex process was launched to test the resulting behavior. [Codex provider](https://github.com/stoneforge-ai/stoneforge/blob/main/packages/smithy/src/providers/codex/headless.ts).

**Verdict:** technically interesting, particularly within one repository, but not the first choice for your requirement. Resolve the Codex permission behavior and multi-project operating model before relying on it.

## Other alternatives and existing contenders

| Candidate | What makes it interesting | Why it is not ahead of the shortlist |
|---|---|---|
| [Raven](https://github.com/EverMind-AI/Raven) | General-purpose host with specialized agents, CLI/ACP integrations, DAG execution, web UI and a native PowerShell installation path | Declares alpha status. Its DAG “resume” reader reconstructs persisted/live state and marks abandoned nodes interrupted; that alone is not automatic execution recovery. Strong watchlist for mixed noncoding work. [State reconciliation](https://github.com/EverMind-AI/Raven/blob/main/raven/agent/subagent/dag_resume.py) |
| [Crewly](https://github.com/stevehuang0115/crewly) | Local dashboard, teams, tasks and mixed Claude/Codex/Gemini/OpenCode workers; tmux is explicitly unnecessary | Documented setup centers on macOS/Linux and shell/native dependencies. Native Windows operation was not established. Its documented Codex launch also uses full-access/no-approval flags. |
| [AutoMaker](https://github.com/AutoMaker-Org/automaker) | Windows desktop/web, feature board, dependency graph, worktrees, auto mode and interruption recovery source | The current LICENSE begins with a no-longer-maintained notice. Its documented Node range is 22.x. Old enthusiastic comparisons should not outweigh current maintenance status. [Status](https://github.com/AutoMaker-Org/automaker/blob/main/LICENSE) |
| [Mission Control](https://github.com/builderz-labs/mission-control) | Self-hosted dashboard for ownership, dispatch, reviews, schedules, costs and multiple runtimes | Explicitly alpha; adapter depth varies. Its documented autonomous dispatch/review path uses a gateway, while gateway-free agents can poll queues. Stronger as an operations layer than a turnkey planner for nested work. [Orchestration](https://github.com/builderz-labs/mission-control/blob/main/docs/orchestration.md) |
| [TeamHero](https://github.com/sagiyaacoby/TeamHero) | Small self-hosted dashboard with plans, roles and a Windows launcher | Current prerequisites are Claude CLI. Mixed-harness orchestration and recovery remain much less established. |
| [Agor](https://github.com/preset-io/agor) | Spatial, collaborative agent interface | Attractive interaction model, but native Windows deployment and your nested execution requirements need substantially more validation. Not rejected as incapable; lower-confidence fit. |
| [Paperclip](https://github.com/paperclipai/paperclip) | Existing strong option for goals, projects, delegation, budgets, recurring work and organizational oversight | Still a finalist if its organizational model appeals. Multica now warrants a direct comparison on project/subissue workflow. Earlier successful setup does not settle unattended orchestration reliability. |
| [Agent Orchestrator](https://github.com/Untrivial-ai/agent-orchestrator) | Earlier local investigation found a particularly strong native Codex execution and recovery design | More compelling as an execution foundation than as the complete project/task/subtask product. “Bulletproof” should be replaced by the specific failures its detached-host design addresses. |
| [Maestro](https://github.com/RunMaestro/Maestro) | Integrated Windows desktop, playbooks, autonomous runs and cross-project group conversations | Still relevant for an interactive desktop preference. Revalidate the earlier documented quota-retry limitations before choosing it for unattended recovery. |

The other infrastructure/framework candidates in the original landscape, including Scion, OpenHands Canvas, Temporal, DBOS, Restate and LangGraph, remain relevant when you want containers or are willing to construct a product around an engine. The new candidates above reduce the reason to start by building your own interface.

## Local validation and its limits

Tests used isolated scratch directories and no model authentication. No actual agent task, GitHub PR, external message or paid model run was initiated.

| Product | Executed here | Result and boundary |
|---|---|---|
| Multica | `go test ./internal/issueworkflow -count=1` | Passed on Windows. Workflow definition/validation logic only; no PostgreSQL deployment or real agent |
| Agent Swarm | `bun test src/tests/workflow-sub-workflow.test.ts src/tests/workflow-foreach-concurrency.test.ts src/tests/workflow-wait-recovery.test.ts` | 50 passed, 0 failed, 237 assertions. Engine tests using test executors; no container fleet |
| sudocode | Published `sudocode` 1.2.0 package, internal packages 0.2.0; CLI hierarchy/dependency operations; two-project server/API smoke test | Passed after native SQLite rebuild. Frontend HTML served; visual UI and model execution not validated |
| Stoneforge | Published smithy/quarry 1.25.0; initialize approve preset, task/dependency operations and config inspection | Node CLI passed after SQLite rebuild. Bun package-export issue encountered; no provider execution |
| Orca, Firstmate, Cabinet, Raven, Crewly, AutoMaker | Documentation and selected source review | No authenticated runtime acceptance test |

Environment: Windows, Node 24.16.0, Bun 1.3.8, Python 3.13.3 and an existing Visual Studio build toolchain. Agent Swarm declares a newer Bun package-manager version; the selected tests passed with the installed version. Docker/WSL probes were denied in this tool sandbox, which does **not** establish that either is unavailable on your computer. Cache/temp permission problems were handled with workspace-local directories.

Local evidence is under `scratch-projects/orchestration-review-2026-10-23/`. In particular:

- `runtime/server-smoke.mjs` and `runtime/server-smoke-result.json` reproduce/document the sudocode loopback API check. It starts and stops its own server.
- `runtime/fixtures/` and `stoneforge-runtime/fixtures/` contain the task fixtures.
- `agent-swarm-tests.log` records the 50 passing engine tests.
- Fresh upstream clones preserve the source reviewed. Original reports and original AO/Paperclip checkouts were not edited.

| Source checkout | Commit |
|---|---|
| Multica | `3de79cbeaf181283765f850327e9d82a3b2af6b0` |
| Orca | `5dc197e5ec11528afee6bdfb289f44fdba2b8872` |
| Agent Swarm | `77039db514cb98f8a8562a84084fb092a474544d` |
| Firstmate | `d22640f478e3392313e27b04fb41de12bd25d2e7` |
| sudocode | `632de1910bc4e272f99db7a33dad8f22feb743d9` |
| Cabinet | `92ed8a666a3241fcd23678cdf4eb384afda513e2` |
| Stoneforge | `0a7052a9ffa1fb42fafbff9d9b6b83fa48cdad95` |
| AutoMaker | `5888d2e6f3618e06762803687ea7b181c10edcbd` |
| Raven | `538a19b307a661a0f16ed16ec5e6b45fd8779a3a` |
| Crewly | `de0b6fa0aeb525b263ebcad277cd3487652de23f` |

Repository URLs in this report point to current upstream pages; the commit table identifies the inspected snapshots. Published packages used for the smoke tests are identified separately because source main and a package release need not match.

## The remaining acceptance test

The deciding pilot should use the same small workload in Multica and Orca, then Agent Swarm if the deployment tradeoff is acceptable:

1. **Project A:** a code change with two independent subtasks, one dependent subtask and a separate reviewer.
2. **Project B:** unrelated research or documentation with different context and a deliverable outside Project A's repository.
3. **Nested delegation:** one worker delegates again and reports through its parent. Verify that a parent cannot report success merely because a child process exited.
4. **Steering:** change a requirement while workers are active, then request another change after a task is marked complete. Verify the correct task, branch and conversation continue.
5. **Recovery:** separately close the UI, stop the orchestrator, interrupt a worker and simulate unavailable credentials/quota. Observe whether the result is reattachment, explicit retry, safe waiting or manual intervention. These are distinct outcomes.
6. **Acceptance:** require actual artifacts and test/review evidence; ensure unrelated work continues when one project is blocked. Record time spent supervising, duplicated work, abandoned subtasks and model usage.

No candidate's cost advantage is established without this authenticated run. More supervisors and review loops can add model work, while a cheap scheduler cannot correct an ambiguous task by itself. Begin with one clear owner per task and explicit handoffs. Avoid stacking Multica, Orca and Firstmate as independent supervisors of the same work until the authority and retry boundaries are deliberately integrated.

For the next trial, choose **Multica** if you primarily want an organized place to assign work and return for decisions; choose **Orca** if you primarily want a native desktop where you can inspect and steer several agents; choose **Agent Swarm** if you primarily want durable, reusable processes composed of other processes.
