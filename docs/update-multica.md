# Update Multica in the Ubuntu VM

From the Windows landing page, choose **Manage installation**, then
**Check for updates** or **Install latest stable release**. The default
opens directly. If you enabled a management key, pair that browser once.
[Portal access settings](../hyperv/README.md#windows-management)

The portal checks
both queues, pauses the admin plane for an upgrade, runs the updater below
and brings the admin plane back. The command-line procedure covers explicit
release selection, restore and backup cleanup.

From the repo root, run `./update-vm.ps1` to see the installed commit and the
latest stable upstream release. This also checks whether GitHub Container
Registry has published both images. To review an exact release, use
`./update-vm.ps1 -Version v0.11.1`.

Finish queued or running jobs in both workspaces. Run
`./hyperv/Connect-Guest.ps1 -Action AdminStop` to pause the admin plane. Pick a
maintenance window when nobody will submit work or edit the project drive.
Open PowerShell 7 as administrator under the same Windows account you used
for setup. Run the exact command printed by the plan, for example:

```powershell
./update-vm.ps1 -Apply -Version v0.11.1
```

The script pulls the backend and web images by digest and builds the matching
Multica binary into copies of your three installed worker images. This keeps
their Codex, Claude and Agy versions intact. It leaves PostgreSQL pinned.
The compiler stamps the CLI with the release tag matching its pinned source
commit. Update staging checks the reported version and commit before activation.
The web app uses the daemon's registered CLI version to enable **Create with
agent**. On v0.11.1 the previous unstamped build reported `dev` and blocked
that flow. After reconnecting all four daemons, both dashboards enabled it
and a daily browser submission created a completed issue.
Staging also invokes `multica daemon start --foreground --no-auto-update --no-auto-reload --help`
in each candidate worker image. The temporary containers have no network
or mounted worker homes. A rejection stops staging before migration and
reports the provider, command, exit code and CLI diagnostic. Changes to
help wording and additional flags are harmless. A second invocation uses a
made-up flag. If help mode accepts it or the control cannot run, the updater
warns that the check was inconclusive. Runtime registration is still checked
after migration.

Before changing the running application it takes a production checkpoint and
exports that checkpoint to a private Windows directory. Both contain the VM's
database, uploads, worker homes, logins and project files. The export can be
large. Its default location is on the Windows system drive, so copy it to
separate storage if you also need protection against drive failure.

After export, the script stops incoming requests, checks the queue again,
stops the workers and brings up the selected release. The backend performs
its database migrations. The final checks open the dashboard, look up the
existing team by ID, and check the three online runtimes and their CLI access.
After the upgrade, run `./hyperv/Connect-Guest.ps1 -Action Admin` to update
the admin plane and re-enable its automatic startup. Do the same after
restoring an update checkpoint taken while the admin plane was paused.
Try a small real task with the providers you rely on after an upgrade.

**Windows dashboard check.** For a web update, the portal tests both configured
Windows `/login` addresses before it pauses the admin workspace and again
after it restarts that workspace. The checks make unauthenticated GET requests
with no system HTTP proxy. They accept a 2xx response and follow up to five
same-origin redirects. Page text, layout and model-provider availability
do not affect the result.

The portal retries startup failures for about 45 seconds after the update.
If a previously reachable URL stays down, the result says the upgrade was
applied and Windows dashboard verification failed. It gives the URL, last
HTTP or connection error, and backup location. The upgrade and backup stay
in place. A URL down both times is reported as a pre-existing outage. A
recovered URL passes. These checks run only for an actual web update.
The standalone terminal updater finishes with the admin workspace paused;
check its Windows login link after you bring that workspace back.

**Keep the backup ID printed by the script.** Under
`%ProgramFiles%\MulticaVM\<VM name>\updates\<backup ID>` you'll find
`receipt.json` with the previous pins, target pins, checkpoint ID and phase,
plus the VM export if that step finished. Update checkpoints have a separate
name from the four rotating weekly checkpoints. The script prints the restore
and cleanup commands before migration and again when it finishes.

* To go back, run `./update-vm.ps1 -Restore -BackupId <ID>` from elevated
  PowerShell. **This rewinds the entire guest.** Copy out any newer work you
  need first, including files on the Windows project drive. If the original
  VM or checkpoint is gone, use Hyper-V Manager's **Import Virtual Machine**
  on the saved export. Keep a recovery copy disconnected until you're ready
  to use it, so two copies can't pick up the same work.
* After accepting the update, run `./update-vm.ps1 -Clear -BackupId <ID>`.
  This removes that update checkpoint, export and receipt. Weekly checkpoints
  and separately copied backups remain. Specify `-Name` for a nondefault VM.

The installed release is saved under `/var/lib/multica-local/release-pins.json`
and survives reprovisioning. A fresh VM starts on v0.11.1. The installer
uses the commit and image digests in [initial-release.json](../hyperv/initial-release.json).
Use the updater for later releases or to move an older VM to that baseline.
Depending on the release, a change to upstream configuration or to an adapter
can still require changes here.

## SQL compatibility before an update

When the target commit or image digests differ, both Plan and Apply read
source files from the exact target commit on GitHub. The portal runs Plan
before it pauses the admin workspace. A failed required source read or an unrecognized
required name stops the update before staging images or changing services.
An already-current install skips this check. Restore and Clear work without it.

The check looks at current sqlc models and queries for the queue and user
tables and columns, the handler's terminal status labels, the questionnaire
fields and version, and the star-prompt limit. Older releases without either
star-prompt column get a warning; our SQL already skips that optional feature.
A partial rename fails the check. Missing required database columns or
changes to the terminal status set block an upgrade. An unrecognized queue
classifier also needs review, since it controls the decision to stop active
workers. JSON tag options, reordered cases and equivalent literal equality
lists are tolerated. For the cosmetic prompt checks, an identified field
rename or changed numeric threshold is reported by name. A moved optional
handler or an indirect prompt constant produces a warning to check prompt
behavior. Old migrations can retain names that the
current application no longer uses, so searching the migration history for
a matching word would give false reassurance.

If the check stops an update, inspect the reported name and candidate source.
A moved source file or rewritten handler can need a checker adjustment even
if the database still works. Conversely, the names can stay the same while
their meaning changes. The check does not run candidate migrations. Keep
the checkpoint/export and verify the upgraded instance as usual. To inspect
a checkout offline, run `./hyperv/Test-UpstreamSql.ps1 -SourceRoot <checkout>`.

On November 21 the daemon argument probe passed against all three real
v0.11.1 worker images. Both installed Windows login URLs responded. We
tested a startup retry, a pre-existing outage and a new outage separately.
An isolated Edge portal displayed the failing URL, HTTP 503 and backup
location for a simulated applied upgrade. A terminal test preserved the
guest's rejected-flag diagnostic. These tests did not migrate the live VM.

We also checked the real v0.7.0 and v0.11.1 sources. The installed
portal updater also planned a v0.11.1 update with a simulated older installed
version and rejected a simulated candidate missing the queue status column.
These were read-only checks; the running VM was already on v0.11.1.

### Why these two operations still use SQL

* **Idle check.** Maintenance needs to know whether *any* row in this
  instance is outside `completed`, `failed` or `cancelled`. The stock
  `GET /api/agent-task-snapshot` covers one workspace, filters by agent
  access, and includes deferred tasks only when they carry a wakeup ID.
  The updater also rechecks after stopping the backend to close intake.
  An equivalent replacement would need an instance-wide drain operation
  that closes intake and confirms quiescence, or an authoritative check
  that remains usable with the backend offline.
  [Snapshot handler](https://github.com/multica-ai/multica/blob/e1fe10d6694848e35dd1aa00e08cd11d93e545ac/server/internal/handler/agent.go#L3379)
  · [Snapshot query](https://github.com/multica-ai/multica/blob/e1fe10d6694848e35dd1aa00e08cd11d93e545ac/server/pkg/db/queries/agent.sql#L2588)
* **Onboarding questionnaire.** `GET /api/me` exposes the answers and
  `PATCH /api/me/onboarding` accepts a replacement questionnaire. An
  installer could submit skip flags for a new account that it controls
  exclusively. On reprovision, a read/merge/write can overwrite an answer
  saved in another tab between requests. Upstream would need an atomic
  “skip unanswered fields” operation or a conditional write that rejects
  stale answers. The existing transaction locks just the owner row.
  [PATCH handler](https://github.com/multica-ai/multica/blob/e1fe10d6694848e35dd1aa00e08cd11d93e545ac/server/internal/handler/onboarding.go#L214)
  · [Upstream update query](https://github.com/multica-ai/multica/blob/e1fe10d6694848e35dd1aa00e08cd11d93e545ac/server/pkg/db/queries/user.sql#L55)
* **GitHub star prompt.** The claim endpoint counts a showing when it is due
  (minimum account age three days, thirty days between showings). The starred
  endpoint records a click through to GitHub. There is no separate “don't
  ask again” preference in this release. The installer caps the showing
  count at the suppression threshold and preserves the user's click history.
  [Star-prompt endpoints](https://github.com/multica-ai/multica/blob/e1fe10d6694848e35dd1aa00e08cd11d93e545ac/server/internal/handler/star_prompt.go)

## Live upgrade test, November 20, 2026

We also checked the v0.11.1 fresh-install pins in a separate Compose project
on the installed VM. With an empty database, fresh worker homes and the
installed images, the setup created the workspace, enrolled all three runtimes
and created the eight agents. The dashboard returned HTTP 200. This exercised
application setup independently of the Ubuntu ISO install and provider sign-in.

The updater took an installed v0.7.0 VM to v0.11.1 (commit
`e1fe10d6694848e35dd1aa00e08cd11d93e545ac`). The existing workspace, team IDs
and issue history survived. The three worker binaries contained the release
commit. Claude Haiku and Gemini 3.8 Flash completed file-writing tasks, and
the Codex lead delegated a writer and independent review. The worker also
passed the browser, document, read-only input and writable exchange checks.
Both Windows network canaries passed. The separate admin database migrated
in prepare mode while the privileged daemon stayed stopped.

A guest reboot interrupted the writer. The team recovered and closed the goal
with 52 verified records, ten written after reboot. The first twelve matched
the prefix saved on Windows. The reboot also changed the guest IP while
Windows stayed signed in. A second guest reboot tested the host address
refresh fix: Windows picked up another new address, reopened the dashboard,
and read the worker output from the original Explorer drive letter without
manual reconnection. The earlier v0.7.0 pilot covers a physical Windows reboot.

The pre-upgrade export passed virtual disk validation and its Ubuntu disk
booted through a disposable differencing disk with no network adapter. After
a new managed checkpoint succeeded, the updater cleared the upgrade
checkpoint and export. Four managed checkpoints remained. Verification also
checked that the probe VM, superseded image references and synthetic project
files were gone. Test issues remained in Multica as history.

## Changes worth trying after v0.7.0

* **Unattended recovery.** v0.8.0 adds retries for tasks interrupted during
  daemon shutdown. v0.10.0 fixes a stall where a woken runtime thought the
  queue was empty. These are good reasons to rerun the delegated reboot pilot,
  especially with our existing lead wakeup timer. [Shutdown retry](https://github.com/multica-ai/multica/pull/9778)
  and [queue recheck](https://github.com/multica-ai/multica/pull/7824).
* **Seeing what a lead delegated.** v0.8.2 includes sub-issue runs in execution
  logs and timelines, making it easier to follow a child worker from the
  parent issue. The release also adds private project membership. Workers
  still have access to whatever folders you mount inside their containers.
  [Execution timeline](https://github.com/multica-ai/multica/pull/9283)
  and [private projects](https://github.com/multica-ai/multica/pull/9868).
* **GUI controls for project environments.** v0.9.0 puts start, stop, restart
  and logs in the issue sidebar for configured environments.
  [Environment controls](https://github.com/multica-ai/multica/pull/10330).
* **Steering work from the GUI or CLI.** v0.10.0 lets you see whose turn it is
  in the inbox and snooze issues. v0.11.1 adds CLI inbox management with
  owner-gated writes. [Inbox views](https://github.com/multica-ai/multica/pull/10573)
  and [CLI commands](https://github.com/multica-ai/multica/pull/10861).
* **Claude and Agy reliability.** v0.7.2 handles Claude Code session and
  weekly limits. v0.9.0 fixes Antigravity turns being treated as failed when
  an earlier step error had already been resolved. [Claude limits](https://github.com/multica-ai/multica/pull/9652)
  and [Antigravity recovery](https://github.com/multica-ai/multica/pull/10274).
* **Delegating to leaders.** v0.11.0 routes a mention of an assigned squad's
  leader to a leader task. This applies if you use Multica squads with your
  team. [Squad routing](https://github.com/multica-ai/multica/pull/8918).
