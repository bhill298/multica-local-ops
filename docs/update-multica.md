# Update Multica in the Ubuntu VM

From the repo root, run `./update-vm.ps1` to see the installed commit and the
latest stable upstream release. This also checks whether GitHub Container
Registry has published both images. To review an exact release, use
`./update-vm.ps1 -Version v0.11.1`.

Close the owner-only admin stack and finish queued or running jobs. Pick a
maintenance window when nobody will submit work or edit the project drive.
Open PowerShell 7 as administrator under the same Windows account you used
for setup. Run the exact command printed by the plan, for example:

```powershell
./update-vm.ps1 -Apply -Version v0.11.1
```

The script pulls the backend and web images by digest and builds the matching
Multica binary into copies of your three installed worker images. This keeps
their Codex, Claude and Agy versions intact. It leaves PostgreSQL pinned.
Before changing the running application it takes a production checkpoint and
exports that checkpoint to a private Windows directory. Both contain the VM's
database, uploads, worker homes, logins and project files. The export can be
large. Its default location is on the Windows system drive, so copy it to
separate storage if you also need protection against drive failure.

After export, the script stops incoming requests, checks the queue again,
stops the workers and brings up the selected release. The backend performs
its database migrations. The final checks open the dashboard, look up the
existing team by ID, and check the three online runtimes and their CLI access.
The admin plane stays offline and picks up the release on its next manual start.
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
and survives reprovisioning from this version of the repo. A fresh VM starts
on the repo baseline. Use the recorded release tag to reproduce an upgrade.
Depending on the release, a change to upstream configuration or to an adapter
can still require changes here.

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
