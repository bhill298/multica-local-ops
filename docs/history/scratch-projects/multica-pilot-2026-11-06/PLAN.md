> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-pilot-2026-11-06/PLAN.md`.
> Current setup/security instructions: [repository guide](../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Multica pilot, 2026-11-06

## Observed results

- Local pilot login succeeded using the generated backend-log code and ordinary browser form; no email provider, cloud Multica account, fixed code or authentication bypass was added. Backend DO_NOT_TRACK=true was verified.
- Browser connection became available after moving this conversation into the desktop app. Board, nested issue links, full-log controls, wakeup labels and running-agent Stop control are visible. A dashboard comment successfully queued a lead run. Stop/resume itself has not been exercised.
- Lead delegated ORCH-15 code, ORCH-14 writing, and ORCH-13 independent review. The late zero-count requirement reached implementation and review. Root verification ran the generated tests: four passed, zero failed.
- Operator force-terminated only the isolated daemon process tree after checkpoint creation, then manually restarted that daemon. Builder attempt 1 failed with runtime_recovery; automatic attempt 2 resumed the persisted session/checkpoint and delivered code. This proves worker retry after service restart, not autonomous service startup or machine reboot recovery.
- Writing completed with a two-hour schedule and 58 USD budget; venue confirmation remained explicitly pending. The worker reported no supported desktop tool and did not fake a Notepad operation.
- Independent review ran after implementation and identified incomplete checkpoint documentation. The lead changed the builder description/status but created no new run, then waited on a condition that could not become true without more work. The stall persisted about an hour. Operator sent a dashboard correction on ORCH-12 at 23:23 UTC, triggering a new lead run; completion after this intervention is tracked separately.
- Builder initially misattributed its tests to independent review before review occurred; the lead noticed and corrected that claim. Lead initially said no manual daemon intervention occurred; operator corrected the distinction between manual daemon restart and automatic worker retries.

Evidence: evidence/interruption.json, evidence/ORCH-15-after-restart.json, evidence/lead-stalled-messages.json, evidence/dashboard-steering.png, generated code and planning/plan.md. Root directory is not a Git repository.

User authorized a pilot with minimal intervention. Reuse isolated local v0.7.0 deployment and authenticated runtime; create fresh agents/projects. No personal data, external publication, purchases, or messages.

Evaluate autonomous lead delegation, independent review, two project isolation, blocked decision handling, live correction, project-bound in-flight daemon interruption/recovery, visible UI and real worker desktop-control availability. Operator actions must be recorded distinctly from autonomous worker actions. A short synthetic pilot does not establish hours-long reliability.

Setup intervention: existing isolated daemon was stopped; restarted using supported daemon start with auto-update disabled. All old issues were done/cancelled before restart. No new authentication needed at setup.

Browser diagnostic follow-up: Chrome, Edge and IAB fail before browser discovery with `The browser access host is unavailable`. Read-only inspection of the installed browser-service implementation identifies this exact error as missing BROWSER_USE_ACCESS_PIPE_PATH or BROWSER_USE_ACCESS_VERIFYING_IDENTITY while browser-access verification is required. The bundled plugin explicitly forwards these variables; they must be supplied by its launching host. App logs on November 6 at 22:46:24Z report IAB backend ready and browser availability true. Resetting cua_repl and retrying IAB did not fix the error. This points to authorization-host provisioning for the tool session, not a demonstrated Multica or browser rendering defect. No authorization checks, plugin files, registry entries, or browser permissions were modified. Next supported recovery: fresh chat in the desktop app with @Browser, then application restart if needed; verify through normal browser tools.

Second handoff failure: the correction worker completed and posted evidence but left ORCH-15 in_progress. The lead's in_review wakeup remained unsatisfied. Operator sent a second corrective comment at 23:26 UTC asking the lead to verify and reconcile statuses rather than dispatch redundant work. These findings apply to the tested Luna/low configuration; they do not isolate framework behavior from agent/model judgment.

Final: lead verified the correction, marked ORCH-15 done, and disabled its obsolete wakeup. ORCH-13/14 were already done. Lead submitted ORCH-12 for review; operator accepted the evaluation and marked ORCH-12 done. This acceptance covers the pilot results, not successful desktop execution or unattended reliability. Browser screenshot evidence/pilot-complete.png shows all three children completed. No user auth or manual login action was needed in this continuation.

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

## November 8 remaining acceptance tests, through 19:19 Mountain

Active-work reboot passed the configured timer-backed recovery workflow; the
preceding reboot addendum records the shutdown-time failed continuation and
independent timer recovery precisely. No operator nudge was sent after reboot.

Additional completed tests:

- [Parallel Git worktrees/conflict](../multica-final-suite-2026-11-08/git/RESULT.md): two workers committed independently; the lead preserved real merge-conflict evidence, resolved to the latest requirement and obtained independent review. Exact linked-index grants fixed sandbox writes. Final closure exposed a stale reviewer reverting Done to in_review. Operator repair plus v4 guard passed one queued-after-acceptance regression. All four issues now Done, no active runs/wakeups. Main repo clean; worker handoff notes remain untracked.
- [Background Office API MCP](../multica-final-suite-2026-11-08/desktop/RESULT.md): actual Multica model tool call created hidden XLSX/DOCX/PDF fixtures; Excel calculated 42 and reopened, Word saved/exported; both test instances closed and never owned foreground. Independent file/process and tool-guard checks passed. Fixed host adapter only, not arbitrary desktop control; sandbox remained enabled.
- [Narrow permission approval/denial](../multica-final-suite-2026-11-08/permissions/RESULT.md): dedicated experimental request_permissions_tool requested exactly one fixture folder each time; approved write succeeded while review canary stayed denied, denied target sentinel stayed unchanged. Both model runs completed and were independently accepted. Broad command expansion still failed at MXC environment creation with HRESULT 0x80070020 in three distinct approved attempts. Approval routing and successful execution after every approval are different claims.

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

See [original longer result](../multica-final-suite-2026-11-08/long-run/RESULT.md),
[fresh v5 regression](../multica-final-suite-2026-11-08/closure-v5/RESULT.md)
and [clean v5 repeat](../multica-final-suite-2026-11-08/long-run-v5/RESULT.md).
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

See [direct reproduction result](../multica-final-suite-2026-11-08/direct-codex-repro-2026-11-09/RESULT.md).
