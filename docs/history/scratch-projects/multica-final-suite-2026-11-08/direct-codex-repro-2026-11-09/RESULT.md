> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-final-suite-2026-11-08/direct-codex-repro-2026-11-09/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Direct Codex approval/MXC reproduction — November 9

**The historical sharing violation was not reproduced.** Seven direct Codex
approval flows and one contemporaneous Multica control all launched the requested
program. Six direct probe operations succeeded. The seventh, using the original
Office script limited to Excel, started normally and then hit the independently
known COM E_ACCESSDENIED boundary. No Windows runtime fix was established or
installed. The earlier failures remain valid historical evidence, with their
underlying cause unresolved.

## Controlled setup

Used the same standalone Codex CLI 0.167.0 binary as the earlier trials, existing
isolated pilot CODEX_HOME paths and authentication, the original working
directories, windows.sandbox=mxc, on-request approvals and the user reviewer.
No credentials were copied and no new login was requested. Direct app servers
were launched by the diagnostic client, without Multica's adapter or approval
broker. MULTICA_* environment variables were removed from their inherited env.

These were real model-generated exec_command escalation requests. The client
saved each item/commandExecution/requestApproval, waited for the operator to
inspect its exact command and CWD, and responded with decision=accept for that
request only. It did not grant a session allowance or write a prefix rule.
Luna/low ran one scoped command per case, with no retry or fallback.

The actual rollout turn contexts were independently compared with the original
Office/Git turn contexts. All seven direct cases retained the same resolved
filesystem entries and network permission, after normalizing path separators and
duplicate entries. The protected review directory remained denied. The copied
task configuration files' security fields were unchanged. The Git cases included
the original common-.git grant, without the later narrow worktree-index fix.

Used the documented sandboxed command/exec endpoint for ordinary baselines and
thread/start plus turn/start for the actual approval flow. Unrestricted
process/spawn and thread shell-command endpoints were not substituted for it.
See [App Server](https://learn.chatgpt.com/docs/app-server) and
[Windows sandbox](https://learn.chatgpt.com/docs/windows/windows-sandbox).

## Results

| Case | Result after one-time approval |
|---|---|
| office-initial | Marker launched; credential canary remained unreadable |
| git-a-index | A real denied metadata write succeeded after approval using a disposable alternate index; original index and HEAD unchanged |
| office-held-env-lock | Marker launched while holding the inactive task's execution lock with Multica's Windows access/share/byte-lock settings |
| office-original-excel | Original probe.ps1 with -TargetApp Excel launched, then COM activation returned 0x80070005; no sharing violation |
| office-runtime-fidelity | Marker launched with execution, session-writer and private-temp locks held; Windows temp layout restored to Multica's pattern; approval delayed about 107 seconds |
| git-a-concurrent | Disposable alternate-index operation succeeded; paired approval flows released together |
| git-b-concurrent | Paired worker-B index operation also succeeded; original index and HEAD unchanged |
| Multica ORCH-98 | Matching marker requested through the installed fork and existing broker; one exact approval succeeded, canary unreadable, issue accepted Done |

All seven ordinary marker baselines succeeded. An additional ordinary Git index
baseline failed with index.lock Permission denied before approval, which is the
expected original permission boundary. The corresponding approved operation
created and removed its separate index successfully. This establishes an actual
access expansion, rather than only approving a command already allowed to write.

No current command result contained CreateProcessSecurityEnvironment or
0x80070020. Every direct case's approval was accepted once. The paired Multica
control used the same resolved permission entries, completed successfully and
ended Done with zero active runs or enabled wakeups.

## What this isolates, and what it does not

The evidence does not justify blaming a consistently broken Multica approval
adapter or a consistently broken native Codex/MXC launch path. Both paths worked
now. Simulated Multica coordination handles, a private TMPDIR, a long approval
wait and paired approval flows were insufficient to recreate the old failure.
This does not eliminate a timing/state-dependent Windows or integration defect.

The COM access denial does reproduce without Multica. It occurs after PowerShell
starts, distinct from the historical MXC environment-creation failure. Explicit
approval retains the profile's restrictions; it does not establish unrestricted
Office automation. The previously tested fixed trusted host MCP remains the
working app-API route. No sandbox protection was removed to make COM work.

The original destructive Git commit sequences were not replayed. The test used
real Git read-tree with a disposable alternate index in the same protected
metadata location, preserving all accepted history and original indices. The
full Both-app Office call was not repeated because its original Word harness had
a separately known window-handle/cleanup defect; the existing Excel selector was
used. Thus these are controlled equivalents of the approval/launch path, not a
bit-for-bit replay of every original workload or complete historical environment.

No speculative locking patch or automatic command retry was installed. Repeating
a write based only on a textual failure message could duplicate effects. A future
recurrence should preserve the request, exact command/CWD, effective profile,
safe temp/environment metadata, approval timing, concurrent activity and sandbox
logs while the failure is live. This harness captures a bounded direct comparison;
it cannot identify the resource that was locked during the older failures.

## Preservation and cleanup

Both original Git indices match the independent hashes captured before the
concurrent test. The main and worker heads remain 40b6bfaf, 11d050ab and 5a22893e.
The disposable indices and their locks are absent. Original Office result and
XLSX/DOCX/PDF files were backed up before the Excel test, the new result was saved
separately, and all four original files were restored and hash-verified.

The original probe script was not edited. The five owned marker/index helper
copies were removed only after verifying their hashes; canonical sources remain
here. All diagnostic app servers and lock-holder processes exited. The single
owned temporary directory was verified and removed without recursive deletion.
Permanent Multica services were left running: broker health OK and frontend 200.
No global rules, permission profiles, provider configuration or installed runtime
was changed. Multica control ORCH-98 is closed with no outstanding work.

## Artifacts and repeat use

- final-verification.json: seven profile comparisons and paired control checks.
- verification.json: direct-case results and resolved permission entries.
- preservation-and-health.json, temp-cleanup.json: independent preservation,
  process, temporary-file and service checks.
- Per-case report.json, events.jsonl, approval-1.json and decision-1.json: actual
  protocol records. These include no broker secret.
- multica-control-*.json: setup, request, decision, actual messages and settlement.
- run-codex.mjs, hold_locks.py and fixed PowerShell probes: local reproducer.

To repeat, use prepare-fixtures.ps1 to install the hash-checked helper copies,
then run run-codex.mjs with a new unused label and the appropriate saved options.
It needs the existing isolated login/home and a host invocation permitted to
write Codex's task-local startup caches. Inspect the emitted approval file before
writing its request-specific decision file. The saved temp/lock options describe
this host's inactive pilot and require recreating its owned temp directory; do
not hold locks belonging to active work. Afterward run prepare-fixtures.ps1 -Clean.
Do not rerun an old label containing a decision file.
