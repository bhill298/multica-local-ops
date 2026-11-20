# Compacting Docker's WSL disk

The standalone [compact-docker-disk.ps1](../compact-docker-disk.ps1) returns unused
virtual-disk space to Windows. It does not prune Docker objects, delete model
caches, unregister distributions, resize the filesystem or reset Docker Desktop.
It works without this repository's other files on a machine without Multica.
Installation also copies it to `~/.multica/local-ops` for later use.

Requirements: Windows, PowerShell 7.2+, running Docker Desktop using the local
WSL2/Linux engine, the Docker Desktop CLI, and the Hyper-V PowerShell commands
`Get-VHD`, `Mount-VHD`, `Optimize-VHD` and `Dismount-VHD`. The Docker data mount
must support `fstrim`. This is not a general Linux/macOS or Hyper-V-backend script.

## Run checks first

From the repository, run:

```powershell
pwsh -NoProfile -File .\compact-docker-disk.ps1
```

The default is a read-only preflight. It reports the disk and whether Multica
was detected. It does not stop services, create a backup, trim or compact.

To perform maintenance, open **PowerShell 7 as Administrator**, save your work,
and run:

```powershell
pwsh -NoProfile -File .\compact-docker-disk.ps1 -Apply
```

On the installed machine, the equivalent command is:

```powershell
pwsh -NoProfile -File "$env:USERPROFILE\.multica\local-ops\compact-docker-disk.ps1" -Apply
```

Applying stops the running Docker workloads and restarts them afterward. The
script refuses to proceed if other WSL distributions, such as Ubuntu, are running;
save and stop that work yourself first. No Windows reboot is required.

## With or without Multica

- If `~/.multica/local-ops` is absent, use generic Docker maintenance. No Multica
  executable, profile, task, source files or credentials are required.
- If the installation exists, verify its required files, executable, supervisor
  task and daemon state. Refuse active Multica work. Run its private backup helper
  before stopping it, then restore the prior task-enabled and daemon-running
  states afterward. A partial/broken installation is an error, not an excuse to
  silently bypass its shutdown handling. Backup must succeed to proceed.
- `-MulticaRoot` selects a nondefault installation directory. It is a runtime
  path, not the source repository. Do not point it at an absent directory to
  bypass a real installation that needs coordinated shutdown.

Modern default disk detection uses
`%LOCALAPPDATA%\Docker\wsl\disk\docker_data.vhdx`. A legacy default data file is
also considered, but multiple candidates are rejected. For relocated storage,
pass the actual Docker data disk explicitly:

```powershell
pwsh -NoProfile -File .\compact-docker-disk.ps1 -VhdPath 'D:\Docker\docker_data.vhdx'
```

Verify that this is Docker's configured **data disk**, not another distribution
or the small Docker boot disk. The modern trim mount defaults to
`/mnt/docker-desktop-disk`; `-TrimMount` supports a different verified layout.
An unsupported/missing mount fails before maintenance. The read-only preflight
does not establish that every arbitrary supplied VHD path belongs to that mount;
the person supplying a custom path must verify that correspondence.

## Failure behavior

Every native command's exit code is checked explicitly; PowerShell's
`$ErrorActionPreference` alone does not accomplish this. Errors from cmdlets are
terminating. The script reports the failed stage and exits with status 1.

After preflight, the order is backup when applicable, graceful workload stop,
trim, Docker Desktop stop, WSL shutdown, then compaction. Failed prerequisites
prevent later maintenance steps. Generic containers receive `docker stop` with
no forced-kill deadline; a stalled stop times out maintenance instead of silently
moving on. A timed-out CLI request can leave its server-side operation finishing.

Compaction only begins after shutdown and a detached, dynamic VHD check. The disk
is attached read-only for full optimization and detached in `finally`. Service
restoration is also attempted in `finally`, including after a partially successful
stop. Independent restoration failures are collected rather than hiding the
original maintenance error. A failed disk detach is retried only for the disk
attached by this invocation; Docker is not restarted while that owned attachment
cannot be released.

Originally running containers are restarted, and originally stopped containers
are returned to stopped state if Docker's restart policy starts them. An `always`
policy can cause a brief startup during Docker restart before that correction.
The script checks final running/stopped states, not every application's readiness
or internal transaction state. No volumes or container definitions are recreated.

Recovery is an attempt, not a guarantee: power loss, force-killing PowerShell,
hardware faults or a failed Docker restart can leave services stopped. The error
reports restoration trouble and returns failure instead of claiming success.
The script cannot restore interactive WSL jobs or unsaved application work.
Keep private backups; the Multica backup covers Multica, not all GPU/model data.
As with any filesystem maintenance, unchanged live files are the intended result,
not a guarantee against hardware failure. Space savings can be zero.

## Checks performed for this implementation

The default preflight passed against the live November 20 installation without
stopping it. The source tests inject failures in backup, workload stop, trim,
Docker stop, WSL shutdown, mount, optimization, detach and recovery. They cover
generic mode, Multica mode, a missing/partial installation, native exit-code and
timeout handling, preserving a disabled supervisor and final container states.
All disk-management/service operations are simulated in these tests. No actual
trim, disk compaction or service interruption was performed to validate this
new script, and another physical Windows machine was not tested.

References: [Linux fstrim](https://man7.org/linux/man-pages/man8/fstrim.8.html),
[Microsoft Optimize-VHD](https://learn.microsoft.com/en-us/powershell/module/hyper-v/optimize-vhd).
