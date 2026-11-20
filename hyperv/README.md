# Ubuntu Hyper-V installation

Run `./install.ps1 -HyperV` from this repository's root in PowerShell 7.3 or
later. Windows needs Hyper-V, virtualization enabled in firmware, Windows
OpenSSH client, curl, tar, and a running Linux Docker Desktop engine for
building the install media. Allow the Windows elevation prompt. The VM uses
Ubuntu Server 26.04.1 amd64, Generation 2, Secure Boot, and Dynamic Memory.
Git preserves the setup and test procedures. A fresh install needs internet
access to download the Ubuntu ISO, apt packages, Docker images, upstream
Multica source and provider tools. The Ubuntu ISO checksum, Multica commit,
service image digests and Codex/Claude CLI versions are pinned. Base image
tags, distro packages and Agy's installer can change. A new install creates
new accounts within the local deployment, local keys and an empty workspace;
provider subscription sign-ins are interactive. Back up live work separately.
Use `install-vm.ps1 -SourceIso <file>` to reuse verified installation media.
Pass `-Processors`, `-MaximumGiB`, `-DiskGiB`, `-Keep` or `-SkipProjectDrive`
to override the host-size defaults, growable disk, checkpoint retention, or
Windows drive mapping. Defaults require approximately 16 GiB total RAM, 5 GiB
currently free and 40 GiB free on the VM disk drive. New guests get 4 GiB at
startup, 2 GiB minimum, and up to 65% of host memory (capped at 64 GiB).

The installer creates a dedicated SSH key and ISO under
`%LOCALAPPDATA%\MulticaVM`. Its elevated portion creates the VM disk under the
host's configured Hyper-V disk path and stores protected scripts, VM ID, and
state under `%ProgramFiles%\MulticaVM\Multica-Ubuntu`. Re-running reconciles
the owned deployment and keeps provider homes, project data and the database.
Installation can download several gigabytes. First-time provider logins are
interactive. Never commit private keys, generated media, runtime credentials,
database dumps, or checkpoints.

## Daily use

Open **http://localhost:43130** in Windows. The limited Windows logon task
forwards the UI over SSH. The VM, Docker, services and workers start at host
boot via a separate SYSTEM task. Docker Desktop is used for media preparation
only. Set aside port 43130 for this dashboard when running other installations.

Run these commands from the repository root:

```powershell
./hyperv/Connect-Guest.ps1 -Action LoginCode
./hyperv/Connect-Guest.ps1 -Action Auth -Provider codex
./hyperv/Connect-Guest.ps1 -Action Auth -Provider claude
./hyperv/Connect-Guest.ps1 -Action Auth -Provider agy
./hyperv/Connect-Guest.ps1 -Action Status
./new-goal.ps1 -HyperV -Title 'Project goal' -OutcomeFile ./outcome.txt
```

Use the email in `config/settings.json` and the generated guest login code.
Each provider has its own persistent home. Codex powers the six-person team.
Claude and Agy have their own worker agents. Agy is configured for Gemini
3.8 Flash Low. The owner dashboard code, JWT and database password live in
`/var/lib/multica-local` on the guest. Stock daemons use owner PATs for this
ordinary workspace. Root inside that worker could use its PAT and provider
credential. It has no mount of the guest root, Docker socket, admin workspace
or other provider homes. Separate projects with different confidentiality needs
require separate mounts and worker deployments. A project label alone does
not separate files in the shared exchange.

The Windows project drive contains `input` and `exchange`. Put files in either
from Explorer. All three daily workers see the input as read-only and exchange
as read/write, including deletions. The data lives under `/srv/multica/project`
on the VM disk. Keep originals and backups on Windows elsewhere. Windows uses
an encrypted Samba share with a files-only credential. No Windows password or
Windows drive is mounted in the workers. A user logon task reconnects the
drive using the current guest address and the SSH-verified share credential.
It remembers the drive letter and previous share and preserves unrelated
mappings. Use `-Action MapProjects` to reconnect immediately. SSH alternatives
are `-Action Put -Path <input>`,
`PutExchange` and `Get -Path <destination-directory>`.

## VM administrator

Use `-Action AdminAuth` for its separate provider login, then `-Action Admin`
to start **VM ADMIN — FULL ROOT ACCESS TO UBUNTU VM — MANUAL START**.
Open the owner-only dashboard via `-Action AdminUI` and localhost:43230.
Use `-Action AdminCode` for its separate login. The administrator runs directly
on Ubuntu with passwordless sudo. A separate database, API and queue keep
ordinary agents from assigning it work. It starts manually through operator
SSH. The transient service has a one-hour maximum runtime. `-Action AdminStop`
stops the daemon and the admin API/UI/database containers. They do not start
at boot. Root work can change anything in the guest, including future boot
behavior. Stop an admin session before making routine recovery checkpoints.

## Boot, isolation and recovery

Host Task Scheduler contains **Multica-Ubuntu unattended boot** and **Multica-Ubuntu
managed checkpoints**. The boot script refreshes guest adapter rules before
starting the VM. It blocks private IPv4 ranges, host directly connected
networks and IPv6, allows needed DHCP/DNS and host-initiated SSH/SMB, and lets
workers use the public IPv4 internet. Add destination CIDRs to
`additionalBlockedNetworks` in the protected host `network.json`, then run the
boot task to apply (this can briefly interrupt networking). Inspect the VM in
Hyper-V Manager. Services in the guest apply Ubuntu security updates and permit
required guest restarts at 04:00 guest time. Refresh app and provider images
separately. See [Ubuntu upgrades](../linux-guest/README.md).

Weekly production checkpoints default to Sunday 03:00 host time with four
retained. The task checks free space and prunes only after successfully creating
a replacement. Manual checkpoints are preserved. Use Hyper-V Manager to restore.
A restore rewinds job state, provider sessions and all project files on the VM
disk, including the exchange visible in Explorer. Keep independent backups.

The test commands in this directory include a network positive control,
a **destructive rollback** test for an empty pilot VM, and a rotation test.
Never run restore tests against live work. Local pilot tests verified HTTP 200,
all three provider runtimes, project write boundaries, browser and document
operations, encrypted share access, two host canary ports, manual admin
separation, production restore of filesystem and PostgreSQL state, and five
scheduled checkpoints with four retained. The canaries covered the Windows
gateway and Windows LAN interface. Other LAN devices were covered by policy,
not individually probed.

## Physical Windows reboot test, November 20, 2026

The host booted at 12:29:47 Mountain time. Ubuntu booted at 12:30:28, the
Codex container started at 12:30:33, and the Windows console sign-in event
was at 12:47:16. Stock Multica marked the interrupted Builder execution
failed. A new execution on the same child issue picked up the durable
checkpoint, appended ten records between 12:31:46 and 12:32:05, and
completed. Reviewer finished independently. Mika closed the root at
12:34:49 and the root timer was disabled. All this happened before sign-in
without operator intervention.

The independent verification checked all 926 linked records (916 from the
first guest boot and 10 from the next). The first ten records still matched
the bytes saved on Windows before restart. This test covers a graceful
Windows restart and a checkpoint-aware workload. It does not establish
exactly-once external side effects or recovery from a power cut.

The dashboard returned HTTP 200 and the admin daemon and admin containers
stayed offline. Hyper-V changed the guest subnet. The refreshed network
policy passed both host canaries again. The old persistent Explorer mapping
was unavailable after sign-in. The new logon task was exercised against
that actual stale mapping and restored the same drive letter. A worker-created
file and the checkpoint prefix were both read through the repaired drive.
The drive fix was tested by invoking the registered logon task after this boot.
