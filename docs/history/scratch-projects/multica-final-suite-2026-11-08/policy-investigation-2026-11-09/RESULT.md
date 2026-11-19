> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-final-suite-2026-11-08/policy-investigation-2026-11-09/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Codex command rules versus the observed launch failures

Investigated November 9 Mountain using Codex CLI 0.167.0, the same version used
in the pilot. The installed and standalone executables have identical SHA256
EDFDD48F8B458AF0906E507B4CB05217B326C3D6E515E9F024E05E3B8D650F70.

The evidence supports two separate classifications: initial filesystem/COM
permission denials, and later approved commands failing in the MXC launcher.
The three latter failures are not supported as command-prefix rule denials.
The underlying cause of the MXC setup failure remains unresolved.

## Checks and evidence

1. Read the official [Rules](https://learn.chatgpt.com/docs/agent-configuration/rules)
   documentation. Rules select allow, prompt or forbidden for command prefixes;
   the strictest match wins. Forbidden blocks without prompting. A missing match
   is not an explicit allow decision; normal approval/sandbox policy still applies.
2. Read the original broker audit and match each request to its actual tool result.
   All three requests were approved. Office failed 1.22 seconds after approval;
   Git A failed 0.43 seconds afterward and Git B failed 0.51 seconds afterward.
   Every result reports CreateProcessSecurityEnvironment / HRESULT 0x80070020.
   Windows' local Win32Exception(32) message identifies a file in use by another
   process. This decodes the error; it does not identify which file or process.
3. Inspect the original Codex rollout turn contexts. All three had on-request
   approval_policy and user approvals_reviewer. The auto_review default still
   visible in copied config.toml was overridden at thread creation by the fork.
   It is not evidence that an automatic reviewer rejected these original calls.
4. Start configuration-only app servers with the original isolated CODEX_HOME
   paths and read config/read plus configRequirements/read. No model turn or
   command execution was requested. All three reported no configured requirements.
   Active file layers were each task's config and the system config location;
   none contained a rules directory with rule files. The original homes contain
   no rules files; the daemon copies config but does not copy the user's rules.
5. Run execpolicy check against all three original command vectors. Active-layer
   checks returned matchedRules=[] with no decision. As an additional check,
   evaluating the real user's default.rules also returned no matches for all
   three. That file currently has 58 allow rules and no prompt/forbidden rules.
   It was not an active user layer of these isolated app servers. A diagnostic
   forbidden rule correctly returned decision=forbidden for a dummy command;
   the dummy command was never executed. This verifies the checker and makes
   clear that an empty match result is distinct from a forbidden decision.
6. The standard Windows system requirements and legacy managed-config files
   were absent; configRequirements/read also returned no requirements. Current
   config inspection is not an immutable historical policy snapshot. The original
   turn contexts, broker decisions and immediate launcher results supply the
   historical evidence. The local logging databases yielded no additional
   matching diagnostic records and are not proof of an absent denial.

## Classification

| Observation | Supported diagnosis |
|---|---|
| Git process ran but could not create linked-worktree index.lock | Filesystem permission boundary; exact worktree metadata grants subsequently passed |
| Office probe ran but COM activation returned E_ACCESSDENIED | Access denied under the sandboxed execution context; separate from prefix matching |
| Three reviewed retries returned CreateProcessSecurityEnvironment 0x80070020 | MXC environment creation failed after approval, before the requested program ran |
| Later ExecutionPolicy Bypass proposal was cancelled | Explicit operator denial, intentionally separate from the three approved failures |
| Credential-directory reads were denied | Intended protection, retained throughout |

Changing allow-prefix rules is not indicated by these results. Keep the narrow
working permissions and fixed application tool. Any further root-cause work
should isolate the MXC launch/permission-expansion failure, rather than assume a
missing allow rule. This investigation does not resolve that failure or prove
whether it comes from Windows, Codex or the surrounding integration.

## Scope and artifacts

No global rules, permission profiles, approvals or installed runtime settings
were changed. No original Git commits, Office commands or model turns were
replayed. App servers needed their ordinary task-local startup caches; the
initial sandboxed inspection could not initialize those caches and was repeated
with a reviewed host invocation. Its failed initialization is separately saved
and is not classified as recurrence of the original MXC error.

- policy-check-results.json: vectors, candidate/active rules and control results.
- effective-policy-results.json: filtered config layers and requirements results.
- approval-and-error-evidence.json: original approvals, errors and turn contexts.
- office-messages.json: preserved original Office execution messages.
- config-read-sandbox-limitation.json: inspection sandbox/cache limitation.
- historical-runtime-logs.json: read-only SQLite inspection, no additional matches.
- check_policy.py, inspect_config.mjs, audit_evidence.py and inspect_logs.py:
  repeatable diagnostics. The original commands are data for evaluation only.

November 9 direct reproduction follow-up: seven direct Codex approval flows used
the original resolved permission profiles without Multica's adapter/broker. All
requested programs launched without 0x80070020, including real alternate-index
writes, Multica-style held locks, delayed approval and paired approval flows.
A current Multica/broker control also passed. The Excel-only original Office
probe launched and reproduced COM E_ACCESSDENIED, a separate restriction.
No root cause or runtime fix was established; historical sharing failures remain
unresolved. Original evidence was preserved and temporary helpers cleaned up.
See ../direct-codex-repro-2026-11-09/RESULT.md for scope, differences and records.
