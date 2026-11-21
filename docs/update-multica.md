# Update Multica in the Ubuntu VM

For the Windows UI, open **Multica-Ubuntu Management** in Start and choose
**Check for updates** or **Install latest stable release**. The portal checks
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
