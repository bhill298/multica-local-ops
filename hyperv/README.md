# Ubuntu Hyper-V installation

Run `./install.ps1 -HyperV` from this repository's root in PowerShell 7.3 or
later. Windows needs Hyper-V, virtualization enabled in firmware, Windows
OpenSSH client, curl, tar, and a running Linux Docker Desktop engine for
building the install media. Allow the Windows elevation prompt. The VM uses
Ubuntu Server 26.04.1 amd64, Generation 2, Secure Boot, and Dynamic Memory.
New VMs expose the CPU's virtualization extensions to Ubuntu. The three
provider workers get QEMU and access to Ubuntu's KVM device. For a host
without nested virtualization support, or to omit device access, run
`./install-vm.ps1 -NestedVirtualization Off`. An existing VM keeps its CPU
setting when you omit this option. To change it, finish active jobs, shut
down the VM and rerun the installer with `-NestedVirtualization On` or
`Off`. Provisioning rebuilds the workers and reconciles their device mappings.
Git preserves the setup and test procedures. A fresh install needs internet
access to download the Ubuntu ISO, apt packages, Docker images, upstream
Multica source and provider tools. The Ubuntu ISO checksum, Multica commit,
service image digests and Codex/Claude CLI versions are pinned. Base image
tags, distro packages and Agy's installer can change. New VMs start on Multica
v0.11.1. Use `./update-vm.ps1` to check for a newer release. A new install
creates local keys and an empty workspace. Sign in to each provider once
for its new worker home. Back up live work separately.
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

Open **http://localhost:43130** in Windows and choose a dashboard. The Windows
logon task forwards three loopback ports over one SSH connection. The VM starts
at host boot via a separate SYSTEM task. Ubuntu starts Docker, both Multica
instances, their workers, and the small landing page. Docker Desktop is used
for media preparation only. Reserve Windows ports 43130, 43133 and 43230.

Run these commands from the repository root:

```powershell
./hyperv/Connect-Guest.ps1 -Action LoginCode
./hyperv/Connect-Guest.ps1 -Action Auth -Provider codex
./hyperv/Connect-Guest.ps1 -Action Auth -Provider claude
./hyperv/Connect-Guest.ps1 -Action Auth -Provider agy
./hyperv/Connect-Guest.ps1 -Action Status
./new-goal.ps1 -HyperV -Title 'Project goal' -OutcomeFile ./outcome.txt
```

## Dashboard accounts

| Dashboard | Windows URL | Default email | Default PIN | When to use it |
| --- | --- | --- | --- | --- |
| Daily | http://localhost:43130/user | `user@localhost` | `111111` | Assign work to agents in the three worker containers. |
| VM admin | http://localhost:43130/admin | `admin@localhost` | `111111` | Run maintenance directly on Ubuntu. The admin worker can use sudo. |

The two links redirect to `http://localhost:43133` and
`http://127.0.0.1:43230`. The different hostnames keep the two browser
sessions separate. The landing page serves only links and redirects.

Open the URL, enter the email, request a verification code, then enter the PIN.
No email is sent. Both accounts own their respective Multica workspaces. The
admin worker has passwordless sudo on Ubuntu, including control over Docker and
the daily workers. It has a separate API, database and queue so a daily
worker's owner token cannot submit a root-level job in the admin workspace.
Both URLs use loopback SSH tunnels. The PIN is public
and anyone with access to an open admin tunnel can use it.

The installer prints a quick start with the installed login addresses.
Run `./hyperv/Connect-Guest.ps1 -Action QuickStart` to print it again,
including while the admin services are stopped. Both servers issue sessions
for `auth.token_ttl` (87,600 hours, or 3,650 days). In Edge the auth cookie
lasted up to 400 days and the web app's login marker up to 365 days. A browser
that clears or expires its cookies can ask you to sign in sooner.

Setup marks unanswered role, use-case and referral questions as skipped for
the daily and admin owners. Existing answers stay in place. On releases with
the GitHub-star prompt, setup sets its display counter to the v0.11.1 limit
of two. It leaves the star-click timestamp alone. Both backends set
`DO_NOT_TRACK=1` and `ANALYTICS_DISABLED=true`. The web containers ship
without a Google Analytics measurement ID. [Upstream analytics settings](https://multica.ai/docs/environment-variables#observability-and-analytics)

**Choose different credentials on a fresh install.** Edit `vm_login_email` and
`vm_admin_login_email` in [settings.json](../config/settings.json). The shared
development default is `vm_default_login_code`. For private, per-account PINs,
run `./install-vm.ps1 -PromptForLoginCode` on first setup. It prompts for
both six-digit PINs. Reprovisioning preserves saved
credentials, including the original `email` on older VMs. For a saved PIN,
run the helper with `-Action LoginCode` or `-Action AdminCode`.

**For a multi-user deployment**, give each person their own sign-in. Use
Multica's production auth configuration, remove the fixed development code
and configure email delivery (SMTP or Resend) or Google sign-in. This VM
installer uses its development code to enroll daemons automatically, so a
production setup also needs its own enrollment flow. In the dashboard, open
**Settings → Members** to invite people and assign workspace roles. Configure
who can run each agent in its Access settings. [Sign-in and signup](https://multica.ai/docs/auth-setup)
· [Members and roles](https://multica.ai/docs/members-roles) · [Agent access](https://multica.ai/docs/agents)

## Workers and project files

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

**VM Admin — Full root access to Ubuntu** is a private, single-task Codex
agent. It can administer the VM and Docker. Its instructions ask it to inspect
current state, perform requested changes, verify results and preserve the two
workspaces. Setup adds no recurring maintenance jobs. Its daemon runs under
`multica-vm-admin.service` with passwordless sudo, starts at Ubuntu boot, and
restarts after a crash. A queued job can execute unattended.

For maintenance, `./hyperv/Connect-Guest.ps1 -Action AdminStop` stops the
admin containers and disables the admin worker. Use `-Action Admin` afterward
to bring them back and restore automatic startup. Daily work stays online.

### Sign in or renew a provider from Windows

Run `./hyperv/Connect-Guest.ps1 -Action Auth -Provider codex` to sign in
once with ChatGPT in the admin profile. The helper copies only that provider's
login to the daily Codex container over an in-guest pipe. It replaces the
daily provider login. Windows never handles the token. The two Multica tokens,
home directories, instructions and conversation histories stay separate.
With an already valid admin login, `-Action SyncCodexAuth` copies it without
another browser sign-in. Codex can refresh its local cache independently in
each profile, so a one-time copy can diverge. If renewal fails, repeat the
sign-in command. For independent logins use `-Action AdminAuth` and
`-Action Auth -Provider codex -DailyOnly`. [Codex authentication](https://developers.openai.com/codex/auth)

For Claude or Agy use `-Action Auth -Provider claude` or
`-Action Auth -Provider agy` from Windows. Each opens that provider's own
login in its daily worker. These commands also work after a session expires.

### Automatic startup test, November 20, 2026

Two Ubuntu reboots changed the guest address. Windows found the new address
and restored all three forwards without operator intervention. Both databases
and dashboards returned, the daily instance listed its three provider runtimes,
and the admin instance listed only its own Codex runtime. In one fresh Edge
profile, both dashboard links signed in and showed their respective workspace.
The daily containers could not connect to the admin web or API ports on the
guest interface or their Docker gateways.

The first real admin job exposed a missing `codex-code-mode-host` executable.
Setup now installs it alongside Codex from the same pinned image. After the
second reboot, the admin agent reported the correct new Linux boot ID,
confirmed the worker and landing services were active, and obtained UID 0
from `sudo -n id -u`. This test restarted Ubuntu; the physical Windows reboot
test below was on an older setup.

## Boot, isolation and recovery

Host Task Scheduler contains **Multica-Ubuntu unattended boot**, **Multica-Ubuntu
address refresh** and **Multica-Ubuntu managed checkpoints**. Every two minutes
the refresh task checks the address of the running guest. If DHCP assigns a
new lease while Windows is still signed in, it updates the host's VM record
and triggers the existing project-drive task. It also restarts a disconnected
dashboard relay. A stopped or saved VM stays in that state.
The boot script refreshes guest adapter rules before
starting the VM. It blocks private IPv4 ranges, host directly connected
networks and IPv6, allows needed DHCP/DNS and host-initiated SSH/SMB, and lets
workers use the public IPv4 internet. Add destination CIDRs to
`additionalBlockedNetworks` in the protected host `network.json`, then run the
boot task to apply (this can briefly interrupt networking). Inspect the VM in
Hyper-V Manager. Services in the guest apply Ubuntu security updates and permit
required guest restarts at 04:00 guest time. Refresh app and provider images
separately. See [Multica updates and rollback](../docs/update-multica.md) and
[Ubuntu upgrades](../linux-guest/README.md).

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

## KVM and Dynamic Memory

On the tested Ryzen 9 9950X3D host, Hyper-V accepted nesting with 4 GiB
startup, 2 GiB minimum and 62 GiB maximum RAM. We touched 3 GiB in a worker
in each run and measured physical RAM assigned to the Ubuntu VM on Windows.

| Test | Before load | Highest observed |
|---|---:|---:|
| Extensions off | 3,233 MiB | 7,182 MiB |
| Inner Linux VM running with KVM | 4,096 MiB | 7,756 MiB |

After releasing the second allocation, Hyper-V reduced assigned RAM to
4,374 MiB while the inner guest continued sending heartbeats. QEMU reported
KVM enabled. The inner guest had 512 MiB, one vCPU and no network adapter.
These measurements demonstrate growth and reclamation on this host. Other
processors, kernels or Hyper-V versions need their own check. Microsoft
describes Linux hypervisors nested inside Hyper-V as unsupported.
[Hyper-V nested virtualization](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/nested-virtualization)

Hyper-V created a production checkpoint while the inner guest was running.
We removed the test checkpoint without restoring it. After restarting Ubuntu,
each of the three installed workers booted the same small Linux guest as UID
1000. In each case QEMU reported active KVM acceleration and the inner guest
sent a heartbeat from userspace. All three Multica runtimes came back online,
Windows could reach the dashboard, and the project drive was accessible.
This run restarted Ubuntu only. The Windows reboot test above predates KVM.

The installer maps only `/dev/kvm:rw` into Codex, Claude and Agy and adds the
device's Ubuntu group ID as a supplementary group. They can start QEMU as the
ordinary worker user. KVM access adds an interface to the Ubuntu kernel and
allows workers to exercise nested CPU virtualization. A vulnerability there
could compromise the guest, including other workers' secrets. The Windows
hypervisor also has more guest-controlled CPU state to handle. File mounts,
network rules, container privilege settings and Docker engine access remain
independent controls. The database, API and dashboard receive no KVM mapping.
