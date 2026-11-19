> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-final-suite-2026-11-08/closure-v5/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Fresh v5 completion regression

**Passed without corrective operator intervention after dispatch.** This is a
short three-level completion/backstop regression, not another two-hour mixed-work
trial or a production reliability guarantee.

Started at 21:06:28 Mountain with new dedicated Luna/low agents and v5 instructions
from the outset. The supervisor created ORCH-83 for its project lead; that lead
created inspector ORCH-84. The inspector read the supplied sentinel and reported
its actual text and SHA256. The lead independently reread it, accepted the leaf
Done and closed its own issue, then propagated completion. Root ORCH-82 accepted
the evidence and closed. It did not wait for root pre-acceptance before allowing
the project lead to finish.

The supervisor itself registered a three-minute native root backstop, capped at
four fires and twenty minutes, before dispatching the lead. The rule fired twice;
one periodic check executed and another queued check was cancelled after
completion. The root also used its ordinary child-closed continuation. All three
issues were Done with zero active runs and zero enabled wakeups at 21:16:06.

Six runs completed. Two redundant queued continuations were cancelled before
starting: one lead continuation delivered on the inspector issue and one root
backstop continuation. These were not duplicate inspector executions. Interpret
actor IDs separately from the issue on which a continuation appears.

The original sentinel remained byte-for-byte unchanged, SHA256
4829CE7DEAEC107DBD32E95F713D27827C75992FDC22C5268BFF218C49261BC9.
The lead added a temporary orch83-result.md receipt; this test does not claim the
whole directory remained unchanged. No cleanup, owner approval, new login,
runtime change or artifact correction was required after dispatch.

This supports the v5 acceptance/backstop protocol in a fresh small hierarchy.
The preceding two-hour ORCH-64 run still required an explicit v5 correction after
its original v3 closure stalled. A separate fresh v5 two-hour no-correction repeat
subsequently passed; see ../long-run-v5/RESULT.md. That later evidence does not
change the intervention accounting for the original longer case.

Evidence: setup.json, task.txt, final.json, final-wakeups.json,
independent-verification.json and project/sentinel.txt. The native root backstop
is 01a1be7d-8131-7900-8d96-3b6f58539c7b; it is disabled with fire_count=2.
