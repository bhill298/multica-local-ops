# Local Multica on Windows

Install the tested stock Multica setup with a local browser interface, native
Windows Codex workers and a small supervisor that restarts the daemon. Multica's
source stays unchanged. The configuration supports a lead, project leads and
workers across separate coding, research, writing and planning projects.

This repository contains the installer, supervisor source, team settings and
coordination instructions. It includes summarized test findings and limitations.
It contains no provider credentials, database, session transcripts or old test
artifacts. It does not include the old approval broker or its source patches.

## Install

For the Hyper-V deployment under development, see the [Ubuntu guest release and
upgrade workflow](linux-guest/README.md) and [Linux worker tools and project
mounts](linux-worker/README.md). The installer below is for native Windows workers.

Start with these installed:

- Windows, PowerShell 7.2 or later, Git and Go 1.24 or later. Go's toolchain
  support downloads the upstream-required Go 1.26.9 when needed.
- Docker Desktop running Linux containers, with Docker Compose available.
- Native Codex CLI on PATH, signed in normally. If needed, run `codex login`.
  Provider sign-in is separate from signing in to the local Multica website.

Clone this repository or extract its ZIP, review
[config/settings.json](config/settings.json), then run:

```powershell
pwsh -NoProfile -File .\install.ps1
```

The shipped settings reproduce the selected models and local login address.
The address uses the reserved `.test` domain; no real mailbox is needed.
Use a different settings file with `-SettingsFile <path>` if necessary. Do not
put credentials in that file. The installer checks prerequisites; it does not
install Docker Desktop, change its startup preferences or reboot Windows.

The installer fetches upstream commit
`dbdbb299164347586e2650bb67684a490726a798`, builds the unchanged CLI and this
supervisor, and uses the tested v0.7.0 backend/web images pinned by digest.
It creates persistent Docker volumes, generates server secrets outside Git,
signs in through the normal local verification/PAT endpoints, creates the
workspace and six agents, and registers a task at sign-in and every minute.
No Multica source edits are applied. The locally compiled CLI reports `dev`;
the installation manifest records its source commit and binary hash.

The first fetch/build can take several minutes. Repeat installs keep the same
database, uploads, workspace, team IDs and secrets. They leave existing agent
instructions and custom arguments alone. The installer refuses to interrupt
active work or silently replace an existing installation. Interrupted fresh
workspace creation is recorded so setup can continue with the same settings.

## Browser login

Open [Local Work](http://localhost:43130/local-work/chat). On the login screen:

1. Enter `orchestration-trial@example.test` and request a code.
2. Enter `888888`. You do not need to receive an email.

The backend uses:

```dotenv
APP_ENV=development
MULTICA_DEV_VERIFICATION_CODE=888888
AUTH_TOKEN_TTL=87600h
```

The token lifetime is ten years on the server. The actual Edge browser test
capped its stored cookie at 400 days, so this does not promise ten years without
signing in again. Existing cookies also retain their earlier expiry until a
new login or renewal. See [Multica's auth documentation](https://multica.ai/docs/auth-setup)
and [Chrome's cookie limit](https://developer.chrome.com/blog/cookie-max-age-expires).

Both published ports bind only to `127.0.0.1`; PostgreSQL has no published port.
Anyone who can reach this instance and knows the address/code can sign in.
Do not expose this fixed-code configuration through a public port or tunnel.
The local CLI uses a separate, revocable 90-day PAT with Multica's normal
renewal support. Neither token is committed to this repository.

## Use and manage it

In Chat, use + to start a conversation with Mika. Give it an outcome and an
authorized project folder. Attach
the folder as a project resource. Project leads delegate to Builder or Researcher,
with Reviewer available for independent review. Decision roles use
`gpt-6.1-sol`/medium; workers use `gpt-6-luna`/low, one run per actor.

For an unattended goal with a backstop registered before its first dispatch:

```powershell
.\new-goal.ps1 -Title 'My outcome' -OutcomeFile .\outcome.txt -ProjectId '<project UUID>'
```

This creates the root in backlog, registers its finite timer and dispatches it.
The default is every ten minutes, up to 48 firings, expiring after eight hours.
This is a reconciliation schedule, not a spending limit or a guarantee of eight
hours of successful work. The chat instructions also tell Mika to create a
backstop; the helper makes registration explicit. Detailed test runs used
precreated backstops. See [operating notes](docs/operating-notes.md).

```powershell
.\manage.ps1 -Action Status
.\manage.ps1 -Action Backup
.\manage.ps1 -Action Stop
.\manage.ps1 -Action Start
```

Stop refuses active work. Backup writes a PostgreSQL archive, uploads archive and
private configuration copies; avoid editing uploads during the backup. A full
disaster restore has not been tested. Keep backups private.

The default installed locations are:

| Location | Contents |
| --- | --- |
| `~/.multica/local-ops` | Private `.env`, setup manifest, helpers, assets, source checkout, build cache, logs and backups |
| `~/.multica/stock-runtime/bin` | Stock CLI and GUI-subsystem supervisor executable |
| `~/.multica/workspaces-local` | Native agent work directories and session data |
| `~/.multica/profiles/orchestration-trial-20261024` | Normal Multica CLI profile and authentication |
| Docker volumes | PostgreSQL data and uploaded files; names recorded in the setup manifest |

The helpers are also copied into the runtime folder. Once installed, normal
operation does not depend on keeping this Git checkout in its original location.
Docker Desktop must be running. Physical reboot recovery after Windows sign-in
passed on the stock setup; this installation did not recover work before sign-in.
Automatic Multica CLI updates/reloads are disabled to keep the
tested version; upgrades require changing the pins and retesting. Codex can
update separately, so inspect effective policy after provider CLI upgrades.

## Existing installations

Do not run a second stack on the same ports. The migration command for the
existing trial is:

```powershell
pwsh -NoProfile -File .\install.ps1 -AdoptExisting -AdoptComposeProject orchestration-trial-multica -RenewLocalAuth
```

Adoption backs up the database, preserves the existing named data volumes and
JWT signing secret, recreates containers from this repo's configuration,
preserves team IDs/instructions, and replaces the idle native daemon. The renewal
switch uses a new ordinary local login and PAT; it does not copy provider
credentials. Review this mode before using it on a live install.

Adoption passed on a disposable stack and was then applied to the main deployment
with explicit approval on November 14, 2026. Its database, original data volumes,
six current agents and their settings were preserved. Browser login and the
workspace UI were verified afterward. The live Compose configuration and helpers
now live under `~/.multica/local-ops`, outside the original trial directory.
Keep any wanted historical project files before retiring the old trial folder.

## What remains custom

The Go supervisor is custom code. The PowerShell installer, management/goal
helpers and the role/coordination settings are also custom. They call stock
Multica's CLI/API and do not patch it. The separate fixed
[Office MCP tool](tools/office-fixture/README.md) is now bundled with portable
setup and tests. It is optional and is not enabled on the daily agents. No generic desktop or browser-control service is
installed. [The browser example](examples/browser-proof.mjs) is a diagnostic:
it passed outside a worker but failed during Edge startup inside the tested
native Codex sandbox. Do not treat it as a working in-worker browser integration.

## Findings, cleanup and development

- [Repository guide](docs/repository-guide.md): documentation map, what Git preserves,
  live paths and the tradeoffs from removing the fork.
- [Security posture](docs/security-posture.md): the distinct Codex, Agy and Claude
  boundaries; Claude's command sandbox requires WSL2/Linux on this Windows host.
- [Test summary](docs/findings.md): successes, failed attempts and coverage gaps.
- [Operating notes](docs/operating-notes.md): permissions, recovery, cost reporting,
  worktrees, browser automation and provider coverage in plain English.
- [Cleanup guide](docs/cleanup.md): what to keep and what previous tests left outside `tmp`.
- [Docker recovery and inventory](docs/docker-recovery-2026-11-20.md): the current
  three-container setup, identified leftovers and November 20 backup restoration.
- [Docker disk maintenance](docs/disk-maintenance.md): checked trim/compaction,
  failure recovery and automatic operation with or without Multica.
- [Adding tools](docs/tools.md): per-agent MCP configuration and the existing Office fixture.
- [Testing guide](docs/testing-guide.md): repeatable checks, fixtures and evidence limits.
- [Historical notes](docs/history/README.md): 29 preserved comparison, setup and test reports.

```powershell
go test ./...
go vet ./...
node --test ./tests/office-fixture.test.mjs
pwsh -NoProfile -File .\tests\installer.tests.ps1 -Docker
pwsh -NoProfile -File .\tests\disk-maintenance.tests.ps1
```

CI checks this repository's code on Windows. It does not certify the full upstream
Multica test suite, which has recorded Windows failures. Fresh-install testing
used an existing Windows machine with prerequisites already installed, not a
new Windows VM. Nothing in this project pushes changes upstream automatically.
