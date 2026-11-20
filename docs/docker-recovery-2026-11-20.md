# Docker cleanup and recovery: November 20, 2026

The user's Docker cleanup removed every container, including the live Multica
stack, and both live Multica data volumes. The retained images, Windows runtime,
private configuration, provider logins, supervisor task and private backups
survived. Removing an image is usually reversible by downloading it again;
removing the database volume removes the actual application history.

With the user's explicit approval, the November 14 backup was restored on the
same localhost ports. Changes made after that snapshot are **not** in the
restored database. The later test findings and source remain in this repository;
their raw files remain separately on Windows where they were retained.

## What the running installation needs

Docker Desktop groups these services under `orchestration-trial-multica`.
Despite its historical name, this is the current installation, not an old trial.
The names were retained to preserve the installed configuration and references.

| Resource | Purpose | Keep? |
| --- | --- | --- |
| `orchestration-trial-multica-postgres-1` | PostgreSQL database process | Yes |
| `orchestration-trial-multica-backend-1` | Multica API, coordination and uploads | Yes |
| `orchestration-trial-multica-frontend-1` | Browser UI and API proxy | Yes |
| `orchestration-trial-multica_pgdata` | Account, workspaces, issues, agents and history | **Yes: live data** |
| `orchestration-trial-multica_backend_uploads` | Uploaded files | **Yes: live data** |
| `orchestration-trial-multica_default` | Private service network | Yes |
| Multica web/backend and pgvector images | Executable software for the three containers | Yes, for normal startup |

The two restored data volumes have labels `local.owner=multica-local-ops`,
`local.retention=keep-live-data`, and a `local.purpose` of `database` or `uploads`.
These labels describe ownership; they do not prevent deletion.
PostgreSQL has no published host port. Only web port 43130 and API port 43131
are published, both bound to 127.0.0.1.

Multica needs **three persistent containers and two named volumes**. It does not
need a separate container or volume for each agent or run. The native daemon,
supervisor and provider CLIs run on Windows. No persistent test stack is needed.

## Identified leftovers and unrelated resources

| Item found | Identification / action |
| --- | --- |
| Nine 64-character anonymous volumes | Each was empty, with no container reference. Rechecked individually and removed. Their originating containers had already been deleted, so original ownership could not be established. |
| `ghcr.io/desplega-ai/agent-swarm:2.5.3` | Obsolete orchestration trial image; removed without force. |
| `orchestration-trial-agent-swarm_default`, `orchestration-trial-cabinet_default` | Unused old trial networks; removed. |
| Deleted `orchestration-swarm213-dev-bunonly` container | Recorded disposable Bun-only Swarm test environment. The trial notes say it was stopped and replaced; it was not needed by Multica. This identifies the recorded Bun container, not any differently named container whose deletion was not recorded. |
| `oven/bun:1.4.4` | Obsolete Swarm build/development runtime; removed in the follow-up cleanup. |
| `oven/bun` image ID `371d30538b69` | Older Bun runtime pulled by digest; removed in the follow-up cleanup. A hash-only image reference is different from a data volume. |
| `node:22-bookworm-slim` | The Cabinet trial Dockerfile pins this exact base image; removed in the follow-up cleanup. |
| `alpine:latest` | Temporary inspection/restoration helper image; removed after the audit helpers finished. |
| `nvidia/cuda` image ID `e711c99333fd` | Exact CUDA base pinned by the separate `text2img/Dockerfile`; retained for image generation. |
| `qwen_model_cache` | About 51.35 GiB of downloaded model cache; retained. |
| `vllm_compiler_cache` | About 0.57 GiB of compiler cache; retained. |
| Flux/Z-image images containing `swarm-appliance` | Image-generation appliances, unrelated to the Agent Swarm orchestration trial; retained. |
| vLLM/Qwen, Bash and CUDA sample images | Unrelated GPU tooling or a generic utility whose ownership was not established; retained. |
| Docker build cache | The follow-up removed 139 attributed Swarm/Cabinet cache records; Docker reported 20.01 GB reclaimed. Other cache was retained, including GPU build layers and unattributed records. Shared layers mean cache and image sizes cannot simply be added together. |

Docker's normal image IDs are content hashes. Digest-pinned images are useful
for reproducibility, and hash-looking build-cache entries are normal. Anonymous
volumes are different: they hold data and should be inspected before removal.
"Unused" or "reclaimable" alone does not establish that a cache is unwanted.

## Follow-up cleanup and other workloads

The user then explicitly requested removal of remaining test images, containers
and volumes while preserving vLLM, Flux and other non-trial work. At that point
there were no old trial containers or volumes left. The four images listed
above were removed without force; the running Multica containers were unchanged.

Cache selection used distinctive Swarm/Cabinet build paths and their connected
cache records, corroborated against the retained trial Dockerfiles. Before
deletion, every selected record was checked as private and reclaimable, and the
remote preview had to match an exact ID allowlist. No blanket cache or system
prune was used. This installed Docker returned no matches for the boolean
`private=true`/`shared=false` filters, so those initial calls removed no cache;
the successful cleanup selected private records locally and used the verified
ID filter. See [Docker's filter reference](https://docs.docker.com/reference/cli/docker/buildx/prune/#provide-filter-values---filter).
Afterward, all 139 selected records were absent and every non-target image ID
was unchanged. The three container IDs and all four volume names were unchanged.

The remaining 159 cache records include 61 undescribed records from the trial
period whose ownership was not established; they were retained rather than
deleted solely because of their dates or hash-like IDs. Build cache is separate
from images, containers and persistent application/model volumes.

All retained vLLM/Qwen and Flux/Z-image image IDs survived this cleanup. The
Qwen model and vLLM compiler volumes remain. The separate Windows `text2img`
project also still contained 19 model files (68,211,200,986 bytes) and 623 output
files (1,139,818,851 bytes). Those are presence/size checks, not a new model
checksum verification or GPU generation test. Its documented launch scripts bind
host model/output directories, which are outside Docker container storage.

No model containers were present when the audit began: only the three restored
Multica containers now exist. If persistent model containers existed before the
user's cleanup, they need to be recreated from their launch scripts. Containers
normally launched with `--rm` may also simply disappear after ordinary use.
Available deletion records do not establish which model containers previously
existed or whether any had wanted files only in their writable layer. No specific
missing model asset was identified, but loss of such container-only files cannot
be ruled out. No GPU workload was launched or reconfigured during cleanup.

## Restoration checks

- Fully restored the retained custom-format database dump in an isolated,
  networkless, RAM-backed PostgreSQL check before asking to restore it live.
- Verified the dump hash, then restored into two newly created named volumes.
  The retained private `.env` matched the backup; no secrets were rotated.
- Restored **2 workspaces, 129 issues and 68 agents**, including the existing
  six daily agents and their IDs. The installed stock CLI still matched its
  recorded binary hash.
- Compared every restored upload with the archive: **all 50 regular files
  matched by SHA-256**. The archive also contains four directory entries.
- Inspected old work before starting the backend/daemon: no queued, dispatched
  or running tasks. The 35 enabled wakeups were built-in `child_done` event
  listeners, not overdue scheduled jobs. They were preserved.
- Verified HTTP 200 from the browser UI and backend health endpoint, successful
  authenticated workspace access using the existing CLI profile, and an online
  native Codex runtime. The supervisor was reenabled and the daemon ran with
  zero active tasks.
- Verified exactly three live containers, two application volumes, two retained
  model-cache volumes and no remaining anonymous volumes or audit containers.

This was a backup-restoration and service-connectivity check, not another model
pilot or reboot test. No provider login was copied or changed. The restored
November 14 snapshot cannot recover later application changes that were never
backed up. The verified original private backup was left intact.

## Avoiding clutter in future work

Use one current Compose stack. Give any temporary test resource a clear name
and purpose label, use `--rm` for disposable helper containers, and clean up only
resources created by that test. Avoid anonymous persistent volumes and additional
long-lived provider-test stacks. A failed test should report its exact remaining
resources rather than leaving unexplained containers behind.

Use `manage.ps1 Stop` to stop the app while preserving data. Use
`manage.ps1 Backup` before destructive cleanup; keep its private backup outside
Git. External volumes survive Compose teardown, including `down -v`, but can
still be deleted explicitly in Docker Desktop. Do not use blanket volume prune:
the model caches can appear unused when their model containers are stopped.
