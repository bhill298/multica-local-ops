# Cleanup outside the temporary workspace

This inventory concerns the machine used for the trials. No old user files were
deleted as part of preparing this package. Approximate sizes are logical file
sizes from November 14, 2026; compressed/physical disk usage can differ.

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

## Docker trial data

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

Do not run a blanket `docker system prune --volumes`. Unrelated model caches,
including Qwen/vLLM volumes, are present. Anonymous volumes were not classified
by this inventory and are not being recommended for deletion.

The package's own disposable test stack is separate from the main deployment.
Its `multica-package-smoke_*` resources and temporary CLI profile are removed
after validation; its raw results remain under `tmp`, outside this repo. No
previous Swarm/Cabinet/Herdr or historical Multica data was removed.

## Verify before removing anything

Check that no active project/resource or process uses the target path. Keep a
private backup if rollback or historical local outputs matter. Remove named
items individually after checking their resolved paths, rather than deleting
whole parent directories or using broad wildcard cleanup commands.
