# Cleanup outside the temporary workspace

## After moving to the Hyper-V VM

The native retirement described below was completed on November 20, 2026.
The maintained checkout was moved out of the temporary directory. The native
database dump, uploads, earlier backups, profile, workspace files, and retained
trial evidence were consolidated in a private directory outside the repository.
The native supervisor task, host daemon, Docker Desktop deployment and its
data volumes were removed. The VM dashboard and Windows project drive passed
their post-cleanup checks. The inventory and sequence below record what was
retired and how to reproduce that transition on another installation.

The November 20 post-reboot inventory found **two independent deployments**.
The VM serves the dashboard landing page on Windows loopback port 43130
through SSH. The same relay forwards the daily and admin dashboards on
ports 43133 and 43230.
Docker Desktop still served the old native API on 43131. The old Windows
daemon was running with zero active tasks. Its default workspace had six idle
agents; the old database also contained one unarchived lab agent and 61
archived agents. The VM uses its own database and provider homes.

**Keep the current installation:** the `Multica-Ubuntu` VM, its virtual disks
and checkpoints, its unattended boot/checkpoint/dashboard relay/project drive
tasks, `%ProgramFiles%\MulticaVM\Multica-Ubuntu` and the operator keys,
known_hosts, drive record and relay under `%LOCALAPPDATA%\MulticaVM`.
The guest's six running `multica-vm-*` containers and three stopped
`multica-owner-only-*` containers belong to the current design. The five
completed VM pilot issues are history in the new database. Treat the project
drive as live guest data. Keep shared provider tools and Windows logins.

**Retire the native installation in this order:**

1. From this repo in PowerShell 7, with Docker on the `desktop-linux` context,
   run `./manage.ps1 -Action Status`. Confirm the native runtime root and no
   active work. Its printed dashboard URL is configured metadata; the SSH
   relay now owns that port. Use `./manage.ps1 -Action Backup` if keeping
   the native database/history and uploads. Save that backup privately outside
   the directories being retired, and preserve any local-only project files.
2. Run `./manage.ps1 -Action Stop`. This disables **Multica Local Supervisor**,
   stops the native daemon, and stops only the native Compose project. Leave
   the stopped containers and volumes in place for an initial rollback window.
   Verify the VM dashboard, project drive and `-Action Status` through
   `hyperv/Connect-Guest.ps1` still work.
3. Once rollback is unnecessary, remove the disabled native task, the three
   Docker Desktop containers and network for project `orchestration-trial-multica`.
   Its external volumes `orchestration-trial-multica_pgdata` and
   `orchestration-trial-multica_backend_uploads` require separate removal.
   That discards the old database and uploaded files. There is no need to
   archive or delete old agent records individually.
4. Retire `~/.multica/stock-runtime`, `~/.multica/local-ops` (including its
   private backups and .env), `~/.multica/profiles/orchestration-trial-20261024`,
   `~/.multica/workspaces-local` and `~/.multica/daemon.id` after checking
   for any other native Multica use. The old fork directories
   `local-runtime` and `local-reliability` were already absent at this check.

**Disposable test files:** after saving this Git repo outside `tmp` or pushing
it, retire individually reviewed Multica trial folders, worker-smoke fixtures
and the VM pilot download/prefix directory. Check projects for local-only
results first. The two `installer.iso` files in `%LOCALAPPDATA%\MulticaVM\media`
and `media-v2` are rebuildable after installation and account for about
5.45 GiB together. The adjacent operator keys are needed for ongoing access.
Host Docker images tagged `multica-local/iso-builder:26.04`,
`multica-local/worker-tools:bookworm` and `multica-local/codex:vm` are
rebuildable host caches. The guest has separate images. Preserve unrelated
Docker volumes, images and WSL distributions.

## Historical native-install inventory

The remaining inventory describes the native trials. References below to
“active” or “keep” refer to preserving that earlier installation for rollback.

The current Docker inventory and approved live restoration are recorded in
[the November 20 recovery report](docker-recovery-2026-11-20.md). Only three
Multica containers, its two named data volumes and two unrelated model-cache
volumes remain. Nine empty anonymous volumes, two unused trial networks and an
obsolete Agent Swarm image were removed after individual checks.
The subsequent requested cleanup removed two obsolete Bun images, Cabinet's
Node base, the temporary Alpine audit helper and 139 attributed build-cache
records (20.01 GB reported by Docker). Model images/caches were preserved.

The original filesystem inventory below concerns the machine used for the
trials. Approximate filesystem sizes are from November 14, 2026;
compressed/physical disk usage can differ. The November 20 cleanup did not
delete Windows project files or provider logins.

## Keep for the active Multica setup

| Location | Why to keep it |
| --- | --- |
| `~/.multica/stock-runtime` | The active stock CLI and supervisor |
| `~/.multica/local-ops` | Live Compose/private configuration, installed helpers, supervisor logs, upstream checkout and private backups |
| `~/.multica/profiles/orchestration-trial-20261024` | The active local account/profile, authentication and daemon configuration; its historical name does not make it disposable |
| `~/.multica/workspaces-local` | The selected workspace's current native execution/session files |
| `~/.multica/daemon.id` | Current machine identity |
| `orchestration-trial-multica_pgdata` Docker volume | The actual database, including local account/workspace/history |
| `orchestration-trial-multica_backend_uploads` Docker volume | Uploaded files referenced by the application |
| `Multica Local Supervisor` scheduled task | Active recovery task |

Do not delete `.codex`, `.claude`, their general configuration files or provider
authentication. Those are shared tools/logins, not disposable framework artifacts.
Keep Docker Desktop and WSL distributions; no distribution removal is needed.

The approved main migration is complete. Multica's Compose file and private
`.env` now live in `~/.multica/local-ops`; its services no longer depend on the
original Compose directory under `tmp`. Both data volumes and the existing
account/workspaces were preserved. Private backups are under the runtime root.
Historical projects can still reference old files under `tmp`, so retain wanted
project outputs/history before deleting trial directories. Keep the source repo
or its ZIP somewhere durable before clearing the temporary workspace.

## Previous artifacts that can be retired

| Location/item | Size or extent | Condition |
| --- | --- | --- |
| `~/multica_workspaces_orchestration-trial-20261024` | About 13,124 MiB (12.8 GiB), 17,305 files | Old generated run directories. The active root is now `~/.multica/workspaces-local`. Deletion loses old provider continuations and any local-only outputs/links there; retain anything wanted from those trials first. |
| `~/Multica/Readiness-20261114` | 14 small fixture files | Completed synthetic readiness project, not real work. Removing it leaves that historical project's local resource path unavailable. |
| `~/.multica/local-reliability` | About 36.9 MiB | Old broker/supervisor/private rollback state. Keep only if rollback to the old fork is wanted. It may contain credentials; do not publish it. |
| `~/.multica/local-runtime` | About 36.8 MiB | Old fork executable. Remove only after discarding that rollback route and checking no command/PATH entry still points to it. |
| `Multica Local Pilot Supervisor` scheduled task | Disabled | Old fork's task. Can be removed when its rollback is no longer wanted. Keep the newer similarly named task. |
| `%LOCALAPPDATA%/herdr`, `%LOCALAPPDATA%/herdr-core`, `~/.config/herdr` | Small residual directories in this inventory | Optional if Herdr is no longer used. No matching running Herdr process was observed. Keep any wanted project registrations/session settings; use its uninstaller for installed software. |

The old `.multica/local-reliability` and `local-runtime` paths are different from
the selected `local-ops` and `stock-runtime` paths. Do not remove the entire
`.multica` directory. Provider homes inside old run directories can contain
isolated login material; treat retained archives as private.

## Historical Docker trial inventory (superseded November 20)

The following describes the earlier inventory, not resources still present.
The user removed these trial containers and named volumes. That cleanup also
removed the live Multica data volumes, which were restored from the approved
November 14 backup. Later database changes are absent from the restored snapshot.

The inventory found 113 volumes beginning `orchestration-trial-agent-swarm_`,
plus `orchestration-swarm213-dev`. If Swarm testing is finished, stop/remove only
its named test containers before retiring those volumes. They include test
databases, logs, shared files and isolated authenticated provider homes. Deleting
them loses the ability to resume those tests. The source/configuration under
`tmp` can be retained separately for later reconstruction.

Three Cabinet trial volumes were also present:
`orchestration-trial-cabinet_cache`, `orchestration-trial-cabinet_codex` and
`orchestration-trial-cabinet_data`. They can be retired if Cabinet is abandoned.
Inspect dependencies and preserve any wanted data before removal.

Do not run a blanket `docker system prune --volumes`. Unrelated Qwen/vLLM model
caches are present. The earlier inventory did not classify anonymous volumes;
the November 20 check found nine empty ones and removed them after rechecking.

The package's own disposable test stack is separate from the main deployment.
Its `multica-package-smoke_*` resources and temporary CLI profile are removed
after validation; its raw results remain under `tmp`, outside this repo. No
previous Swarm/Cabinet/Herdr or historical Multica data was removed.

The November 18 reboot and provider follow-up added synthetic projects and
execution history to the active database and generated run directories under
the active workspace root. Its eight disposable agents were archived afterward;
the six daily agents were unchanged. No additional startup task or provider
account was added. Its raw checkpoint/provider files are under
`tmp/scratch-projects/multica-stock-followup-2026-11-18`, outside this package.
Those test projects retain local directory references there. Retiring those
files makes the historical resource paths unavailable; it does not require
deleting current application data or provider logins.

## Verify before removing anything

The current repository now includes the Office tool source, its setup/tests,
the durable checkpoint source and 29 relevant historical setup/testing reports.
Those source/notes no longer require the old `desktop/host` or report directories.
Generated Office documents, raw receipts, provider sessions, retired fork exports
and live database/backups remain excluded. Push or save the repository somewhere
durable before clearing `tmp`; the source repository itself is currently there.
Do not confuse preserving source/notes with backing up live application data.

The later Agy boundary tests used five additional disposable actors and five
dedicated Agy project policy files. After verification, the actors were archived
and only those dedicated policy files were removed. Global Agy permissions,
Claude settings and the six daily agents were unchanged. Private raw receipts
and canaries remain under `tmp/scratch-projects/multica-agy-boundary-2026-11-18`;
the small diagnostic source/method are included in this repository's examples.

Check that no active project/resource or process uses the target path. Keep a
private backup if rollback or historical local outputs matter. Remove named
items individually after checking their resolved paths, rather than deleting
whole parent directories or using broad wildcard cleanup commands.
