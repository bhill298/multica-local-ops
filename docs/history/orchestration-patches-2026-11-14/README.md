> Historical snapshot imported November 18, 2026 from `orchestration-patches-2026-11-14/README.md`.
> Current setup/security instructions: [repository guide](../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Multica and Agent Swarm: exact local patch exports

These are reviewable exports of the local changes used in our trials. They have
not been pushed upstream. The live deployments and source working trees were not
changed by this export. Baseline, target and per-commit hashes are in manifest.json.

## Files and application

- multica/multica.patch: cumulative upstream-to-current-fork diff, including
  runtime repairs and the later coordination/operating documentation.
- multica/multica-runtime-only.patch: only the installed binary's repair commit.
- agent-swarm/agent-swarm.patch: cumulative current v2.13.0 repair diff.
- Each project's series/ contains numbered git-format-patch commits, preserving
  original author and commit messages, suitable for git am in order.
- agent-swarm/historical-2.5.3/ is reference only, superseded by the current series.
- agent-swarm/deployment/ records additional deployment work outside source diffs.

Use either the cumulative patch OR the corresponding commit series, not both.
In a clean checkout at the exact recorded baseline, first run
`git apply --check /path/to/project.patch`, then `git apply /path/to/project.patch`.
Alternatively apply that project's numbered series using git am in filename order.
Do not apply the complete Multica diff after the runtime-only diff: they overlap.
These patches are baseline-specific; newer upstream releases need a rebase.

Every current aggregate patch and every current series commit was applied to a
disposable Git index starting at its proper baseline/parent. Each reconstructed
Git tree matched the original target tree exactly. verification.json records
this; source checkout status remained unchanged. Product tests were not rerun for
an export of unchanged commits. Prior live tests are summarized below.

## Multica: what changed

Baseline dbdbb299164347586e2650bb67684a490726a798 (0.7.0 preparation).
Tested runtime 9bd735f7cea08517aae766a970c50abfd3f6cb8e.
Exported source/docs head 33febf0f58d3c9ba3557b92b271a46e6889d4631.

The runtime repair is one commit: 12 files, +519/-0 lines. The complete range
is eight commits: 14 files, +627/-0. The seven later commits change documentation
and the v4/v5 coordination contracts, not the installed runtime binary.

1. Opt-in owner approval: route Codex command/file/permissions/elicitation requests
   through an authenticated local review page. Preserve the user/on-request
   policy on new/resumed sessions; deny missing, stale, expired or unavailable
   decisions instead of falling back to automatic acceptance when enabled.
2. Keep owner credentials on the host: remove broker environment variables from
   child runtimes and configure an isolated workspace permission profile denying
   reads of the review-state directory. Existing scope/network roots are carried
   into that profile. The patch does not change global user Codex configuration.
3. Windows process recovery: install a non-elevated login/periodic supervisor that
   restarts the daemon and approval broker. Build it as a Windows GUI executable
   and hide child processes to eliminate routine console-window flashes.
4. Installed path repair: executable files go in .multica/local-runtime/bin,
   separately from denied credential state in .multica/local-reliability, so
   workers can resolve/run the CLI after installation and reboot.
5. Coordination documentation: preserve accepted work on late callbacks, make
   project/root acceptance authority explicit and retain a bounded independent
   root timer through delayed work and closure. These are agent instructions,
   not new server-enforced workflow invariants.

Prior live checks passed owner approve/deny and credential isolation, installed
path regression, daemon/broker recovery, configured active-work reboot, and the
clean v5 mixed-project pilot. The historical approved-command MXC sharing
violation was not fixed: later reproductions launched successfully but its cause
remains unresolved. Approval support is Codex-specific and the review page is
custom, not a generic upstream tool-policy engine.

The installer contains pilot-specific profile/port choices. This is the exact
local patch, not a generalized upstream-ready PR; those assumptions need review
and parameterization before proposing a broadly enabled upstream feature.

## Agent Swarm: what changed

Baseline 9871da51bbb18d90c9185e2319b39c9b25d22208 (v2.13.0).
Tested/exported head 68d2fc39aca425f1dfb1f22d1354d4c66e734b59.
Four commits: 89 files, +4,174/-1,167 lines. This includes substantial meaningful
tests, updated legacy fixtures, generated API artifacts, UI wiring and runbooks.

1. 61bc6631e — Fence task dispatch and execution recovery.
   Enforce dependency readiness and explicit offer acceptance during acquisition;
   retain offer review instead of implicitly accepting through progress updates.
   Fence callbacks by current task execution/runtime/generation so stale workers
   cannot complete work or remove a replacement's session. Add Linux Codex
   confirmed process-tree stop, durable private stop receipts, same-task resume,
   paused correction queuing and dashboard stopping/resume states. Includes
   migration340, credential redaction and API/process regression coverage.
2. 247acd8d5 — Acknowledge steering supplied in initial input.
   A correction already delivered in the resumed model's initial context can be
   acknowledged by that exact registered execution, rather than being rejected
   as still pending. Preserve steering IDs/lineage and prioritize corrections
   ahead of the older brief when initial context is truncated.
3. 02549c1d5 — Expose native workflow approval guidance.
   Document the existing human-in-the-loop executor with a valid example and
   discoverable config schemas; unknown executor errors list supported types.
   This adds guidance/tests, not a new approval capability or self-approval right.
4. 68d2fc39a — Cover heartbeat dependency continuation.
   Test-only real-API regression: stale A produces resume R, B is rewired A->R,
   remains blocked until R completes, and then dispatches.

Prior validation: 173 strict API scenarios; real pause/queued-correction/resume;
2h45m mixed-project pilot; actual API-process crash; actual Windows reboot with
105 old plus12 new checkpoints,117 historical commit prefixes and native lead
acceptance/cleanup. The full unit suite retains reproduced baseline failures.

Still NOT fixed by this range: async agent-step completion bypasses outer node
outputSchema/validation (task config.outputSchema does work); generic parent-task
cancellation does not cascade; generic followups default to a global lead;
confirmed pause is Linux Codex scoped. JSON shape never establishes artifact
truth. Neither patch set adds a general desktop controller or promises automatic
recovery for arbitrary external side effects. Migration340 may need renumbering
when rebasing on a newer upstream migration sequence.

## Provenance and checksums

The export contains committed source/docs and the explicitly labeled Git image
recipe, not .env files, private runtime state, credentials or compiled binaries.
SHA256SUMS covers all other exported files. The zip is a convenience copy of this
directory. Historical patches are not included in current applicability checks.
