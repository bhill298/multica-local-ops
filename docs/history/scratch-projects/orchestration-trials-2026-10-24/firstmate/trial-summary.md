> Historical snapshot imported November 18, 2026 from `scratch-projects/orchestration-trials-2026-10-24/firstmate/trial-summary.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Bounded Firstmate orchestration trial

Outcome: completed after operator-assisted launcher recovery. Alpha was one main deliverable (`trial-alpha`) with implementation and independent-review subtasks. Beta remained a separate project. Exactly three worker tasks were launched through fm-spawn; recovery reused the original two task identities and worktrees.

| Task | Project | Retained worktree | Result |
|---|---|---|---|
| trial-alpha-impl | alpha-csv | /home/brennan/.treehouse/alpha-csv-b9bd7e/1/alpha-csv | Added only csv.mjs; branch fm/trial-alpha-impl, commit 5e974ef33d00aeb1d861b441032eb6236a94ee0a. |
| trial-alpha-review | alpha-csv | /home/brennan/.treehouse/alpha-csv-b9bd7e/2/alpha-csv | Different Codex worker independently reviewed that exact commit in detached checkout; no findings. |
| trial-beta-plan | beta-evening | /home/brennan/.treehouse/beta-evening-f00c59/1/beta-evening | Added only plan.md; branch fm/trial-beta-plan, commit ea3fd3e646f9fb4fda6afd92aa4ccbf3dec8d3bf. |

## Real validation

- Alpha implementation: npm test exit 0; runner reported 1 file-level test, 1 pass, 0 failures.
- Independent Alpha review: npm test exit 0; 1 file-level test passed, 0 failures. Direct execution of supplied csv.test.mjs passed all 4 named tests. Supplemental assertions passed 12 valid-input cases and 4 rejection cases. Full npm output and exit status are in data/trial-alpha-review/review-npm-test.log and review-npm-test.exit-status.
- Beta: practical 6–10 p.m. schedule for four; ten allocations sum to exactly $40: 3 + 4 + 3 + 4 + 3 + 4 + 4 + 4 + 4 + 7. Worker arithmetic verification passed using python3 after python was unavailable.
- Supplied files preserved. Git diffs show only additions csv.mjs and plan.md; both implementation and Beta worktrees verified clean. The review worktree retains three untracked reviewer-created artifacts (review-npm-test.log, review-npm-test.exit-status, review-report.md); they were preserved rather than removed. Its tracked files remain unchanged. Both commits have author and committer bhill <bhill298@gmail.com>, with no co-author.
- Detailed evidence: data/trial-alpha-impl/report.md, data/trial-alpha-review/report.md, data/trial-beta-plan/report.md. All workers appended terminal done status. Independent-review captain-call completion gate passed with no unresolved choices.
- fm-crew-state returned unknown/codex-unverified for pane state in this environment. Completion was therefore verified from explicit terminal status, self-contained reports, exact shared local refs/commits, test logs, and clean Git state; no stronger semantic pane-state claim is made.

## Recovery and limitations

Initial workers reached the Codex sign-in chooser because tmux windows did not inherit the primary CODEX_HOME, although the primary's codex login status reported authenticated. Early guarded relaunches refused unknown composer state. The operator verified the idle native Codex processes and sent SIGTERM only to PIDs 6878 and 9109, preserving tmux windows and worktrees. The operator also fixed trial-only tools/codex to default missing CODEX_HOME to the existing authenticated FM_HOME/codex-home. The supervisor set CODEX_HOME only in the trial tmux session. No new login occurred.

After that manual workaround, normal fm-control relaunch succeeded for both original tasks in their original worktrees. The documented folder-trust prompts were accepted via fm-send --key Enter, and actual brief processing was observed. This trial is not evidence that initial unattended recovery worked without operator help.

An earlier shell-expanded Beta backlog body incorrectly said food exactly 0. It was corrected; the original brief, README, current backlog, relaunch note, and final plan preserve literal $40. No fixture files were edited to conceal this error.

Scoped codex-approval-mode stayed approve-for-me. Workers retained workspace sandboxing and automatic approval review; approved escalations handled shared Git metadata and task-report writes. Initial supervisor tmux socket denial was resolved with scoped automatic approval. No unresolved approvals or task blockers remain. Startup's GitHub-auth diagnostic was irrelevant to this local-only trial; no GitHub login was requested.

No installs, global settings changes, external integrations, purchases, bookings, pushes, PRs, merges, or teardown. Branches, worktrees, and persistent task records remain for review. Supervision used documented foreground checkpoints with FM_CODEX_WATCH_CHECKPOINT=30. The bounded trial is finished; no recurring work was created.

## Late Alpha BOM follow-up

Same parent trial-alpha and same subtasks/worktrees reused; zero additional workers. Beta stayed Done and was not rerun.

New retained implementation head: 5872a022f4e03629dd8f699b6417933b619ff852, following initial 5e974ef33d00aeb1d861b441032eb6236a94ee0a. Only csv.mjs was changed (one leading U+FEFF is removed before empty-input handling); operator-supplied late-followup.test.mjs was added unchanged to the commit. SHA-256 of that supplied test: 032775cbd7b70a96700963e1a087f25462a331519b9504083b62cb84d4db4f16. Prior supplied files remain unchanged. Author/committer remain bhill <bhill298@gmail.com>, no co-author. Implementation worktree is clean.

Initial outcomes above remain valid for the initial commit. Follow-up implementation: npm test exit 0, 2 file-level tests passed, 0 failed; 5 additional BOM assertions passed. Independent retained reviewer checked out the exact new commit detached in its separate original worktree without force or discard: npm test exit 0, 2 file-level tests passed; direct runs passed all 5 named tests; 14 explicit BOM cases passed, including BOM-only -> [], preserving second/third leading BOMs and BOMs inside fields, later records, and input end. No findings or unresolved blockers. Completion gate verified again.

Persistent state transitions via tasks-axi:
- Parent trial-alpha: initial Done -> Queued (reopen) -> In flight (start) -> Done after follow-up review.
- trial-alpha-impl: initial Done -> Queued -> In flight -> Done after new commit/report verification.
- trial-alpha-review: initial Done -> Queued, blocked by trial-alpha-impl -> blocker removed once new implementation commit existed -> In flight -> Done after independent review.
- trial-beta-plan: stayed Done throughout. No task or project identity was replaced.

Both retained workers were steered through normal fm-send durable inbox records 001.msg, with the late requirement appended to their existing briefs. No relaunch, native SIGTERM, new login, trust workaround, or additional worker was needed for this follow-up. Automatic approval review remained enabled; sandboxed Git/report writes used approved escalation as needed.

Recordkeeping: initial report.md files were copied byte-for-byte to initial-report.md before follow-up. Workers wrote followup-report.md and uniquely named follow-up logs; initial logs and all untracked review artifacts remain intact. tasks-axi refused followup-report.md links because its report schema requires data/<id>/report.md; supervisor therefore mirrored each follow-up report into canonical report.md only after verifying its old contents were preserved in initial-report.md. Failed link attempts changed no states. Task titles were normalized after reopening; all initial/follow-up report paths are retained here despite canonical-link replacement.

Evidence: data/trial-alpha-impl/{initial-report,followup-report,report}.md; data/trial-alpha-review/{initial-report,followup-report,report}.md and followup-5872a02-* logs/exit-status files. No supplied tests changed, no artifacts discarded, no merge/push/publish/teardown. Initial launcher workaround and operator SIGTERM steps documented above still apply only to initial recovery.

## Requested Bearings lavish board

Built from bin/fm-bearings-snapshot.sh --json, captured 2026-10-24T16:42:36Z, with no --include-prs and no GitHub enrichment. Snapshot reported no captain decisions, one recent completed independent review, no gates, and three retained endpoints with unknown/codex-unverified state. Board preserves those actual projected states; local-only implementation branches were not presented as landed merges.

Board: .lavish/bearings-board.html
Live local review URL: http://127.0.0.1:4387/session/cd23b01f22f54311

Board rendering workaround: initial shipped builder refused its exact data-slot check because checkout template had 749 CRLF endings. A temporary /tmp/trial-board-template-lf.html normalized only CRLF to LF; its bytes were verified identical to the tracked shipped template blob. FM_BEARINGS_BOARD_TEMPLATE selected that copy for this synthetic trial. Source template, board UI and shared scripts were not edited. Initial local Lavish establishment failed; direct documented lavish-axi opening then succeeded, and retry proved session live and served.

Unresolved board-only blocker: after serving and binding, build could not arm its feedback source: “process-event state root is not a private directory”. FM_HOME/state reports mode 777. A scoped chmod 700 attempt exited successfully but stat remained 777 on this filesystem. No privacy guard, sandbox, or approval mechanism was bypassed; no alternate fake state root or improvised listener was created. Board remains available for viewing; feedback listening is NOT verified or claimed. Alpha implementation/review validations are complete despite this presentation-listener limitation.

No new worker tasks or recurring work were created for the follow-up. All supplied files, old artifacts, retained branches and worktrees remain preserved.

## Read-only Bearings browser feedback test

Operator recovery superseded the earlier listener blocker: copied finished state to /home/brennan/.local/state/orchestration-firstmate-trial-20261024 (mode 700), retained original NTFS state as FM_HOME/state-ntfs-backup, and made FM_HOME/state a symlink to the native directory. Supervisor verified symlink target, mode 700, and retained backup. Operator reported the normal builder with FM_BEARINGS_BOARD_TEMPLATE=FM_HOME/board-template-lf.html succeeded with live session and armed source lavish-cd23b01f22f54311.

Browser feedback-to-reply path WORKED:
1. Normal fm-wake-drain presented check procevent lavish lavish-cd23b01f22f54311 1.
2. Canonical board source-id matched. fm-procevent classify returned feedback; fm-procevent-lavish read reported declared_items=1, presented_items=1, malformed_items=0, complete=yes, captain_message_count=1, and the exact BOARD_FEEDBACK_TRIAL_20261024 message requesting read-only acknowledgement and final CSV results.
3. Normal lavish-axi reply to the existing board acknowledged the exact marker and confirmed commit 5872a02 independently passed both supplied test files, all five named tests, and all 14 explicit BOM cases.
4. Reply command exited 0 with reply status sent; Lavish explicitly confirmed acceptance and removal of its Working indication. This verifies server acceptance through the board reply path; no separate visual observation of browser rendering is claimed.
5. fm-procevent handled lavish-cd23b01f22f54311 1 succeeded, followed by generation-bound wake acknowledgement through sequence 2.

No tasks/projects were changed, created, dispatched, merged, deleted, or rebuilt during this read-only feedback test. No board rebuild or invented snapshot was used. Only normal feedback acknowledgement records and this summary were written. The existing board remains available at http://127.0.0.1:4387/session/cd23b01f22f54311. The bounded primary test now ends; continuous monitoring after primary termination is not promised.
