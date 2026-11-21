# Repository and installation guide

This repository contains the source and summarized documentation needed to
recreate the selected stock Multica installation. It is an installer source
package, not an offline image or a backup of the live workspace database.

## Documentation map

Start with the [VM operating guide](../hyperv/README.md) for the current
deployment, including the physical reboot result and Explorer drive fix.
The native Windows supervisor, host permission tests and native adoption
instructions below document the earlier deployment.

| File | What it covers |
| --- | --- |
| [README](../README.md) | Prerequisites, installation, local browser login, starting goals, management and adoption |
| [Test findings](findings.md) | Successful and failed tests, known gaps and the distinction between tests and operating defaults |
| [Operating notes](operating-notes.md) | Everyday permissions, recovery, worktrees, costs, provider differences and project binding |
| [Security posture](security-posture.md) | Codex, Agy and Claude boundaries, local authentication and host MCP authority |
| [Adding tools](tools.md) | Per-agent MCP configuration, provider differences and the existing Office fixture |
| [Office source/setup](../tools/office-fixture/README.md) | Bundled no-argument host MCP, local configuration and optional live checks |
| [Testing guide](testing-guide.md) | Repeatable source/integration checks and preserved fixtures |
| [Historical reports](history/README.md) | 29 preserved evaluation, setup, test and intervention notes with current-report precedence |
| [Cleanup](cleanup.md) | Active files to keep and old test artifacts that can be retired after review |
| [Docker cleanup and recovery](docker-recovery-2026-11-20.md) | Current three-container/two-volume stack, identified hashes, removed leftovers and approved backup restoration |
| [Docker disk maintenance](disk-maintenance.md) | Standalone compaction helper, optional Multica handling, preflight and failure recovery |
| [Coordination contract](../coordination-local.txt) | Delegation, actual-run tracking, corrections, review, acceptance, root timers and project binding |
| [Settings](../config/settings.json) and [roles](../config/roles.json) | Version/image pins, local defaults, selected models and the six-agent team |

## What Git preserves

The tracked files include the upstream Git URL and exact commit, image digests,
PowerShell installer and management helpers, Go Windows supervisor and its
tests, settings/team templates, coordination instructions, CI and these
summarized findings, historical reports and the optional Office MCP source/tests.
Browser, Agy boundary and durable checkpoint diagnostics are included as examples.
Installation fetches and builds the pinned Multica source; this repository carries no Multica
source fork.

On another machine, install the documented prerequisites and sign the provider
CLIs in normally. Run the installer from the README. It generates machine-specific
IDs and private runtime configuration. Installation needs network access for
upstream source, images and dependencies; authenticated model calls use the
provider's service. "Local" describes the orchestration services and data, not
offline model inference.

Provider CLI versions are separate prerequisites and can update independently.
The tested versions are recorded in findings; the installer does not reproduce
every aspect of the original Windows machine or freeze provider subscriptions.
Repeat relevant boundary checks after a provider update.

## What Git deliberately excludes

| Excluded item | Where it lives / consequence |
| --- | --- |
| Secrets and provider logins | Private runtime/profile and provider home directories; authenticate normally on a fresh machine |
| Live account, issues, conversations and uploaded files | Docker database/uploads volumes; use private backups to preserve data rather than publishing it |
| Generated CLI/supervisor binaries and build caches | Rebuilt by installation under the runtime directories |
| Raw framework trials, patch exports and model/session transcripts | Relevant narrative reports/plans are preserved in `docs/history`; raw sessions, downloaded upstream trees, retired fork binaries/patch exports and generated deliverables are excluded |
| Generated Office proof documents/receipts and machine-local MCP config | Ignored under `tools/office-fixture`; source, setup and tests are included |

Consequently, pushing this repository preserves the supported installation work
and its documentation. It does not save all historical trial artifacts or clone
the live application state. Keep any wanted historical material and private
backups separately before deleting `tmp`. The Office source and relevant narrative
notes no longer depend on retaining the old trial directories. Its generated
configuration must be regenerated if the repository is moved.

## Historical native Windows layout

The table below records the retired native pilot. The current VM deployment
and its dashboard entry points are in the [VM operating guide](../hyperv/README.md).

| Location | Purpose |
| --- | --- |
| `C:/Users/brennan/Desktop/proj/tmp/scratch-projects/multica-local-ops` | This Git source repository; move/clone it somewhere durable before clearing `tmp` |
| `C:/Users/brennan/.multica/local-ops` | Live Compose file, private `.env`, install manifest, copied helpers/assets, clean upstream checkout, logs, builds and private backups |
| `C:/Users/brennan/.multica/stock-runtime/bin` | Active stock `multica.exe` and external `supervisor.exe` |
| `C:/Users/brennan/.multica/workspaces-local` | Native task working directories and session material |
| `C:/Users/brennan/.multica/profiles/orchestration-trial-20261024` | Active local Multica profile, PAT and daemon files; the historical profile name is still in use |
| Docker volumes `orchestration-trial-multica_pgdata` and `orchestration-trial-multica_backend_uploads` | Current database and uploaded files |
| Scheduled task `Multica Local Supervisor` | Hidden daemon recovery at user logon and on its repeating check |
| `http://localhost:43130/local-work/chat` | Current workspace UI; API is on port 43131 |

Normal operation no longer depends on keeping the source checkout in `tmp`.
Individual historical/test projects can still refer to folders there. The old
disabled supervisor and old fork/broker rollback files are different paths;
consult cleanup before removing anything.

## Stock setup compared with the old Multica fork

| Area | Current behavior |
| --- | --- |
| Owner escalation broker/review page | Removed. There is no human permission queue. Codex stays inside preconfigured access; a denied required write needs a narrow configuration change and a fresh attempt |
| Broker token separation and installed-path source repair | Removed with the broker. The special broker credential boundary and its path workaround are no longer part of the setup |
| Recovery supervisor | Retained as independent operations code. Stock daemon-crash and physical reboot recovery after sign-in passed |
| Coordination and reliable closure | Retained in the contract and goal helper. The long stock pilot and later shorter readiness/provider tests passed, with documented model mistakes and timer recovery |
| Office proof | Independent of the fork; source/setup/tests are bundled as an optional tool. It is not a general desktop feature or part of the selected daily team |
| Permission requests from stock adapters | Automatic approval code still exists. Never-ask avoids that route for Codex; changing to an asking policy does not add owner review |

The main deliberate capability loss is one-off human-reviewed runtime escalation.
That is the tradeoff for removing the broker fork. Known access needs are granted
ahead of time, and unavailable access fails inside the runtime instead of waiting
in a custom queue. The old broker also had observed launch failures and expiring
requests; it did not provide a proven reliable path for hours-away work.

No recovery or accepted-completion regression was observed in the tested stock
workflows. This is bounded test evidence, not proof every fork behavior is
identical. Sign-in dependence, hung-but-live daemon handling, worktree permission
setup, persistent old-session grants, model mistakes, incomplete Windows upstream
tests and unverified monetary caps remain documented limits. Swarm's custom
pause/resume/fencing work was a different fork and was never a Multica feature.
