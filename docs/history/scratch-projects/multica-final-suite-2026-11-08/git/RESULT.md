> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-final-suite-2026-11-08/git/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Parallel Git worktree and conflict acceptance

**Execution and independent review passed after scoped setup repair. Final
business-state closure needed a further operator repair and instruction guard.**
This is agent-managed work on operator-provisioned linked worktrees, not proof of
native Multica worktree provisioning or an unattended stock workflow.

Two native Windows Luna/low workers committed in separate linked worktrees:

| Branch | Commit | Result |
|---|---|---|
| clean-a | 3b4e3899fac37a53453ddfd27068d667de39a705 | a.txt = alpha |
| clean-b | 3ff5d4fa7d8396558035ebb85374ddfe3548a73e | b.txt = beta |
| policy-a | 11d050abfac62c08de3e6fadc0aa2ee1c46883aa | base -> timeout 45 |
| policy-b | 5a22893ebacf96874a841417c0ace9c41c8635de | base -> timeout 60 |

Both policy branches have the exact required base as their single parent. The
lead merged both clean branches, then policy-a, then attempted policy-b. The
last merge actually exited 1 with UU policy.txt and the expected 45/60 conflict
markers. It saved the command/output/status/diff/markers before resolving to 60.
Final main merge 40b6bfafa991462596d76ba39686f898e072cee5 has two parents,
2cd2652f0561023ad108c74197211da68e376053 and policy-b. All four branches are
ancestors; both marker files are preserved. Configured author identity was used;
the fixture has no remotes or pushes.

Independent reviewer ORCH-76 checked history, parents, actual conflict evidence,
final contents and absence of unresolved entries/markers. Root verification
verify.ps1 independently repeated those checks. The main repository was clean
after runtime sidecars were removed; temporary worker handoff notes remain
untracked in worker worktrees and were not committed. Do not claim every
worktree contains no untracked files.

## Interventions and closure regression

See INTERVENTIONS.md for initial CLI configuration failures, denied linked-index
writes, failed approved MXC launches, exact metadata permission repair, and two
explicit worker retries. Neither worker needed a new model or provider login.

After review passed, the lead accepted all children and closed ORCH-72. A late
self-reconciliation by the reviewer then moved ORCH-76 from Done back to in_review
while the root stayed Done. This was an actual stale-continuation state bug,
not a failed merge or failed artifact test. No active continuation remained to
repair it automatically.

The operator added v4 rules to these dedicated Git agents: preserve accepted Done
on late/duplicate continuations without new requirements, inspect/drain active
descendant continuations before final closure, disable obsolete wakeups, and do
not block directory release for optional temporary-file cleanup. The operator
restored ORCH-76 Done and ran one targeted stale-delivery regression: enqueue the
original reviewer task, then accept it before its first model action. Run
01a1be15-588f-7acb-b18a-e8b37c596bf4 read the accepted child/root states and exited
without mutations. The current API refuses creating a fresh wakeup on an already
closed issue; that rejected setup made no timer and is not a scheduler failure.

Final independent snapshot: ORCH-72/74/75/76 all Done, zero active runs and zero
enabled explicit wakeups. The guard passed this focused case; it remains an
agent-instruction mitigation, not a server-enforced monotonic-state invariant.
The separate two-hour ORCH-64 suite retained v3 throughout for comparability.

Evidence: setup.json, corrected-custom-args.json, original run-message JSON,
repo/merge-evidence.md, independent-verification.json, final-status.json,
closure-regression-before.json, stale-delivery-setup.json,
stale-delivery-result.json and v4-addendum.txt. setup.ps1 now uses the corrected
metadata entries and v4 for future fixture creation; it was not rerun to recreate
the already-finished repository.

November 9 follow-up: command-rule investigation found no matching rules for the
three approved MXC launch failures. Original turn contexts used the user reviewer;
approval audit timestamps precede each launcher result. Current isolated config
reads report no managed requirements; the forbidden-rule control worked.
Initial file/COM denials remain separate permission-boundary observations. No
settings were weakened. The MXC sharing-violation cause remains unresolved.
See ../policy-investigation-2026-11-09/RESULT.md for scope and evidence.

November 9 direct reproduction follow-up: seven direct Codex approval flows used
the original resolved permission profiles without Multica's adapter/broker. All
requested programs launched without 0x80070020, including real alternate-index
writes, Multica-style held locks, delayed approval and paired approval flows.
A current Multica/broker control also passed. The Excel-only original Office
probe launched and reproduced COM E_ACCESSDENIED, a separate restriction.
No root cause or runtime fix was established; historical sharing failures remain
unresolved. Original evidence was preserved and temporary helpers cleaned up.
See ../direct-codex-repro-2026-11-09/RESULT.md for scope, differences and records.
