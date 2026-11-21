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
tags, distro packages and Agy's installer can change. New VMs use the
[pinned Multica release](initial-release.json). Use `./update-vm.ps1` to
check for a newer release and `./update-vm.ps1 -PromoteInstalled` to make
an accepted VM update the default for new installs. Promotion automatically
commits a clean baseline file locally. You decide when to push.
A new install
creates local keys and an empty workspace. At the end of an interactive
install, pick any combination of `codex`, `claude`, and `agy`, type `all`,
or press Enter to skip sign-in. Use `./install.ps1 -HyperV -SkipProviderLogin`
for unattended setup. Providers can be connected later. The default lead
and VM admin use Codex. The [admin provider](#vm-administrator) can be
selected independently. Back up live work separately.
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

### Blank-disk test, November 20, 2026

We started with pushed commit `89e9168` and kept the existing VM running.
The test used its own operator key, verified Ubuntu 26.04.1 ISO, new 64 GiB
disks, Windows ports and project drive. Two issues showed up before the final
clean pass:

* On first boot, the admin daemon briefly reported its status without a daemon
  ID. Setup now waits for the ID and an online runtime before binding the agent.
* Windows had reserved the first set of test ports. They had no listeners,
  but OpenSSH still could not bind them. Setup now checks each port before
  preparing the media and checks both redirects through the scheduled relay
  before printing the quick start.

With those changes, the installer ran unattended from a new blank disk through
the Windows quick start. Both daemons reported Multica 0.11.1. The daily
workspace had its eight default agents and three online provider runtimes.
The separate admin workspace had its Codex worker. In a fresh Edge profile,
both default PIN logins worked at the same time and each account saw only its
own workspace. The test drive used Y: alongside the existing Z: drive.

Each queue completed a job through its real Codex daemon, using a loopback
test server in place of a paid model. On the preceding run we also switched
the admin worker to Claude, Agy (Gemini 3.8 Flash Low), and back to Codex.
Its agent ID stayed the same. These installs used `-SkipProviderLogin`.
The browser sign-ins above were for Multica itself. The tests of real
provider accounts are documented under [VM administrator](#vm-administrator).

We wrote a file from Windows and read it in all three containers, then read
a worker's reply from Windows. Even container root received a read-only
filesystem error on the input mount. Each worker could open `/dev/kvm`
and query its API. The three daily control-plane containers had no KVM
device. The Codex worker could reach neither of two test listeners on the
Windows host (the virtual gateway and the host's LAN address). Both listeners
worked with a temporary allow rule, then became unreachable when we removed it.

Restoring a Hyper-V production checkpoint brought back the earlier file
contents and one database row. The later file edit and second row disappeared.
Ubuntu had a new boot ID. The Windows relay reconnected automatically, both
browser logins worked, and each queue completed another job. The project
drive still worked in both directions. This run rebooted the guest only.

Afterward we removed the test VMs, disks, checkpoints, scheduled tasks,
drive mapping, media builder, ISOs and private operator files. The original
VM kept its ID, all three original web endpoints returned HTTP 200 and its
Z: project drive was accessible.

### Run a second installation on the same Windows host

Use a separate checkout. In that checkout, set three free Windows loopback
ports in `hyperv/dashboard-ports.json`, for example
`{"home":41130,"daily":41133,"admin":41230}`. Windows can reserve a port
even when no process is listening. Setup checks that it can bind each port,
or that this VM's existing SSH relay already owns it. Give the VM its own name
and operator directory:

```powershell
./install-vm.ps1 -Name Multica-Test -Directory "$env:LOCALAPPDATA/Multica-Test/media"
```

Keep the entire parent of `media` separate. It holds the SSH key, known
hosts, dashboard relay and drive mapping for one VM. Use the same name and
directory with `Connect-Guest.ps1`. Setup prints the URLs for this copy
and picks an available drive letter. Use a separate browser profile when
signing in to a second installation. A browser shares cookies between ports
on the same hostname.

## Daily use

Open **http://multica.localhost** from Windows. The old bookmark at
http://localhost:43130 also works. At Windows sign-in a limited-user task
starts the portal and a second task opens the two SSH forwards to Ubuntu.
The VM has its own SYSTEM task for boot, before Windows sign-in. Ubuntu
starts Docker, both Multica instances and their workers.

The portal listens on Windows IPv4 loopback. It routes requests by hostname
and keeps the two app logins on separate origins. Setup adds one marked block
to the Windows hosts file. It uses neither IP Helper nor netsh portproxy.
By default the main installation needs ports 80, 43130, 43133 and 43230.
If port 80 is taken, use `./install-vm.ps1 -WebPort 8080` or run
`./hyperv/Install-Portal.ps1 -WebPort 8080` on an existing VM. Setup prints
the resulting URL. Secondary installations use their VM name and their
configured home port by default. The portal builds with local Go or with
a Linux Docker Desktop build container. It runs directly on Windows afterward.

### Windows management

Choose **Manage installation** on the landing page. The same Windows portal
serves both `/` and `/manage`, including while Ubuntu is shut down.

On a fresh install the management key is empty. Bookmark
http://multica.localhost/manage or click through from the landing page.
Setup skips the Start shortcut. This default assumes you trust the Windows
users and programs on the PC. Any local process that can reach the portal
can request management operations. Windows still handles elevation, and
Multica still uses the six-digit PIN for workspace sign-in.

To require a randomly generated management key on a fresh install, run
`./install.ps1 -HyperV -RequireManagementKey`. You can also change an
installed portal without reprovisioning Ubuntu:

```powershell
./hyperv/Install-Portal.ps1 -RequireManagementKey         # Enable pairing
./hyperv/Install-Portal.ps1 -RequireManagementKey:$false  # Return to direct access
```

Reinstalling without the switch keeps the existing access mode, including
on older keyed installations. In keyed mode, open **Multica-Ubuntu Management**
in Windows Start once per browser profile. The shortcut opens a private
pairing file. The page saves the key in the browser and removes it from the
address bar. You can then use the plain bookmark. Switching back to direct
access clears the key and removes the pairing file and owned Start shortcut.
Enabling pairing again generates a new key.

We tested direct access from a fresh Edge profile on the installed VM. The
landing-page link loaded status and refreshed it without an authorization
header. A separate keyed portal rejected the unpaired browser, accepted
the pairing link and reopened the plain bookmark. The disposable installer
test also checked that a repair retained the generated key and uninstall
removed the shortcut.

The management page shows Hyper-V power state, boot autostart, individual
worker registrations and running or stopped Compose containers with their
images. The host refresh task samples power state at two-minute intervals.
Portal power actions also refresh it immediately. While the page is open it
refreshes guest data every minute. An offline runtime for a previously used
admin provider can remain in Multica's runtime history.

Shut down and Restart check both queues for unfinished work, then ask Hyper-V
for a graceful guest shutdown. Docker stops with Ubuntu. The Windows portal
stays available and Start brings the VM back. Changing boot autostart leaves
the current power state alone. Windows can show UAC when you request a
privileged operation. Ordinary dashboard use, status and update checks run
as the signed-in user.

Check for updates compares the installed pins with upstream's stable release
and registry images while Ubuntu is running. Install checks again, pauses the
idle admin workspace, and uses the same checkpoint, export and migration as
`update-vm.ps1`. It restores the admin workspace after a successful upgrade.
Staging tests the daemon flags against each candidate CLI. After a web
upgrade the portal checks both Windows login links against their pre-update
results. A new outage is reported with its URL and last error. The upgrade
backup remains available. An interrupted migration requires inspection of the update receipt before
restarting the admin plane. Allow a maintenance window for an actual upgrade.
[Update backups and recovery](../docs/update-multica.md)

The portal binary and `operator.key` live under
`%LOCALAPPDATA%\MulticaVM\portal`. Keyed installs also keep the private
pairing file there. Privileged scripts and the installation
record live under `%ProgramFiles%\MulticaVM\Multica-Ubuntu\portal`. The
optional Start shortcut opens the private pairing file. Keep that file and
any nonempty key with your other operator credentials.

**November 21 verification.** After a physical Windows reboot we verified
the original dashboard endpoints, containers and project drive. After
installing the portal we signed into both named dashboards in the same Edge
profile, paired the management page and checked the upstream release.
We disabled and re-enabled boot autostart, shut down the guest, started it
again and tested Restart. With the VM off, launching the registered Windows
logon task brought up the management page. Running the registered SYSTEM boot
task then restored four online runtimes, nine containers, both named dashboards
and the Z: drive. That last check exercised the actual tasks without a second
Windows reboot. The installed release was already current, so the portal
exercised its no-update path. The earlier migration test covers the updater.

### Uninstall the Hyper-V deployment

From your normal PowerShell 7 session, run `./uninstall-vm.ps1` for a
preview. Run **one** of these commands to apply it:

```powershell
./uninstall-vm.ps1 -Apply -KeepDisk
./uninstall-vm.ps1 -Apply
```

Both commands remove the VM registration, checkpoints, update exports,
scheduled tasks, owned hosts block, portal, shortcut, drive mapping and
generated media. Copy out any exports or project files you need first.
**KeepDisk** merges the checkpoints into the standalone system VHDX in
the configured Hyper-V disk directory. It also keeps the operator SSH key
and known-hosts file. The VHDX contains the guest's databases, files,
containers and provider logins. To recover it, attach the disk to a
Generation 2 VM and restore its network policy before connecting it.
Without **KeepDisk**, uninstall deletes that data and the operator key.

Use the installation's `-Name` and `-Directory` for a secondary VM.
The last installation removes its unused media-builder image if the local
Docker engine is available. Other Docker workloads and shared base images
are left alone.

`hyperv/Test-Uninstall.ps1` exercises both disk choices with disposable
empty VMs and real checkpoints. It checks that an unrelated operator file
survives. The retained-disk case also installs a second Windows portal and
verifies removal of its shortcut, tasks, hosts entry and portal directory.

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
| Daily | http://multica-user.localhost | `user@localhost` | `111111` | Assign work to agents in the three worker containers. |
| VM admin | http://multica-admin.localhost | `admin@localhost` | `111111` | Run maintenance directly on Ubuntu. The admin worker can use sudo. |

The previous direct addresses `http://localhost:43133` and
`http://127.0.0.1:43230` still work. Sign in once at the new hostnames
to establish separate daily and admin cookies there. The proxy translates
browser origins and HTTP redirects to and from those direct addresses.
Multica still has the direct addresses in its guest configuration, so an
absolute URL generated inside application content can use the older bookmark.

Open the URL, enter the email, request a verification code, then enter the PIN.
No email is sent. Setup also requests a code when it enrolls each workspace.
If the first browser request says to wait, retry after a minute. Both accounts
own their respective Multica workspaces. The
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

We tested a custom owner email and six-digit PIN against a fresh v0.11.1
database and empty worker homes. The installer enrolled all three runtimes
and created the eight daily agents before any model-provider login. A second
user accepted an invitation and joined the test workspace. The test used
local verification codes and did not exercise SMTP delivery.

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

**VM Admin — Full root access to Ubuntu** is a private, single-task
agent. It can administer the VM and Docker. Its instructions ask it to inspect
current state, perform requested changes, verify results and preserve the two
workspaces. Setup adds no recurring maintenance jobs. Its daemon runs under
`multica-vm-admin.service` with passwordless sudo, starts at Ubuntu boot, and
restarts after a crash. A queued job can execute unattended.

For maintenance, `./hyperv/Connect-Guest.ps1 -Action AdminStop` stops the
admin containers and disables the admin worker. Use `-Action Admin` afterward
to bring them back and restore automatic startup. Daily work stays online.

The installer reads `admin_provider` and the per-provider `admin_models` in
[settings.json](../config/settings.json). The shipped pairs are Codex /
`gpt-6-luna`, Claude / `claude-haiku-4-5`, and Agy / `gemini-3.8-flash-low`.
Codex is the default. For example, to choose Claude during installation:

```powershell
./install.ps1 -HyperV -AdminProvider claude -AdminModel claude-haiku-4-5
```

To switch an existing VM, finish pending admin jobs, then run:

```powershell
./hyperv/Connect-Guest.ps1 -Action Auth -Provider agy
./hyperv/Connect-Guest.ps1 -Action SetAdminProvider -Provider agy -Model gemini-3.8-flash-low
./hyperv/Connect-Guest.ps1 -Action QuickStart
```

If Agy was connected during setup, you can omit the first command. The
selected providers are already available to both workers.

The switch binds the existing admin agent to the selected runtime on its
own daemon and updates its model. The agent ID and issue history stay in the
admin workspace. The local choice in `/var/lib/multica-owner-only/admin-provider.json`
survives reboot and reprovision. Omit `-Model` to use that provider's
configured default. To discard the override and follow the install defaults:

```powershell
./hyperv/Connect-Guest.ps1 -Action SetAdminProvider -UseInstallDefaults
```

### Sign in or renew a provider from Windows

Use `./hyperv/Connect-Guest.ps1 -Action Auth -Provider claude`, substituting
`agy` or `codex` as needed. Setup calls this same command for each provider
you select. Complete the provider's browser sign-in once in the Ubuntu admin
profile. For Agy, exit the interactive CLI normally after signing in so the
helper can finish. The helper replaces that provider's OAuth login in its
daily container. You can do this while a different admin provider is active.

If the admin login is already current, use `-Action SyncProviderAuth -Provider
claude` (or `agy` or `codex`) to copy it without another browser sign-in.
`-Action SyncCodexAuth` is still available. Each worker has a private copy.
If refresh tokens diverge or the provider asks you to authenticate again,
rerun `-Action Auth -Provider <name>` to renew both. For intentionally
separate accounts, use `-Action AdminAuth -Provider <name>` for admin only,
or `-Action Auth -Provider <name> -DailyOnly`.

The transfer runs inside Ubuntu as the two provider users. It copies only
login fields, never a whole home directory or a Multica workspace token.
Claude uses its Linux credential file. Agy 1.5.13 uses a dedicated OAuth
file in this headless installation. A keyring-only Agy installation would
need a separate login method. [Claude authentication](https://code.claude.com/docs/en/authentication)
· [Agy authentication](https://antigravity.google/docs/install?tab=cli)
· [Codex authentication](https://developers.openai.com/codex/auth)

The live shared-login test copied the actual admin Codex credential with
`-Action SyncCodexAuth`, then submitted jobs to the daily Builder and VM
Admin simultaneously. Both made successful model calls and posted their
measured execution times. Their 30-second shell checks overlapped by 26
seconds. Claude Haiku and Agy Gemini 3.8 Flash Low each returned independently
verified model responses from overlapping admin and daily CLI processes after
sync. Fresh containers for both also completed model calls with only the
copied credential in a new worker home. Long-term token refresh was not tested.

### Other model endpoints and API keys

An agent's settings in the web UI include **Environment variables** and
**Custom arguments**. Configure the model and credentials for the provider CLI
that runs that agent. Multica stores custom environment values in plaintext
in its database. Use a limited key and keep it out of custom arguments and
Git. [Multica agent configuration](https://multica.ai/docs/agents-create)

For Codex, define a provider in the worker's `~/.codex/config.toml` with
its `base_url`, `wire_api = "responses"`, and `env_key = "WORKER_MODEL_KEY"`.
Select that provider with `model_provider`, set the agent's model to one the
endpoint serves, and supply `WORKER_MODEL_KEY` in the agent's environment.
The installed CLI completed a test against a local Responses API fixture
using a synthetic key. For Claude Code, a compatible gateway can use
`ANTHROPIC_BASE_URL` and the gateway's supported authentication variable.
Custom endpoints for Agy have not been verified. The existing VM network
rules still apply, and localhost in a worker refers to that worker.
[Codex configuration](https://developers.openai.com/codex/config-reference)
· [Claude Code gateways](https://code.claude.com/docs/en/llm-gateway)

The installer has no global worker endpoint or API-key prompt. The backend's
`MULTICA_LLM_BASE_URL` and `MULTICA_LLM_API_KEY` configure server features
such as chat titles and follow-up suggestions. Worker runs use the provider
CLI's configuration. [Server settings](https://multica.ai/docs/environment-variables)

The same controls are available on the **admin dashboard**. Open the managed
agent's **Settings → Environment** for the key and **Settings → Custom Args**
for provider options. For example, Codex accepts `-c` followed by
`model_providers.gateway.base_url="https://your-gateway.example/v1"` as two
arguments. Define the provider name, `env_key` and Responses protocol there
as well, select it with `model_provider="gateway"`, and choose a model the
gateway serves. This agent runs on Ubuntu, so its loopback address reaches
services on the VM. Switching providers preserves these per-agent settings;
review provider-specific arguments when changing CLIs. A later installer
reconciliation reapplies the configured admin model.

In the live tests, the same private admin agent ran a maintenance issue under
Claude Haiku (`ADMIN-3`) and Agy Gemini 3.8 Flash Low (`ADMIN-4`), each after
an Ubuntu reboot. Both returned the independently checked boot ID, UID 0
from `sudo -n id -u`, and an active admin service. After returning to Codex,
a temporary private admin agent completed `ADMIN-5` through a loopback
Responses endpoint. The endpoint verified the synthetic bearer key supplied
in the agent's environment. The temporary agent was archived.

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
