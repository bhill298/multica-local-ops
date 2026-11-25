# Repository Guidelines

## Project layout

This repository installs stock Multica in an Ubuntu Hyper-V VM. Windows hosts the portal and startup tasks. Both Multica instances and their workers run in the guest. Keep deployment changes here so upstream Multica can be upgraded independently.

- `cmd/portal/` contains the Go portal and its embedded HTML, JavaScript, and favicon.
- `hyperv/` contains host provisioning scripts, guest helpers, systemd units, and the initial release pins. `linux-guest/` defines Ubuntu packages. `linux-worker/` defines the worker container image.
- `config/` holds team defaults and roles. The root also contains the earlier native Windows supervisor (`main_windows.go`).
- `tests/` holds cross-component checks. Go tests live beside their source. Start with [the VM guide](hyperv/README.md) for current behavior and [the testing guide](docs/testing-guide.md) for prior results.

## Build and run

Run commands from the repository root in PowerShell 7.3 or newer on Windows.

- `go build ./cmd/portal` builds the Windows portal for local development.
- `./install.ps1 -HyperV` provisions a deployment. Use a disposable VM for installer or recovery tests.
- `./hyperv/Connect-Guest.ps1 -Action QuickStart` prints dashboard URLs and login instructions for an existing installation.

## Style and tests

Use `gofmt` for Go, four-space indentation for Python and PowerShell, and LF line endings. Follow the existing `Verb-Noun.ps1` names for Hyper-V commands. Name tests `*_test.go`, `test_*.py`, `*.tests.ps1`, or `*.test.mjs` so they match the relevant runner.

To reproduce the [Windows CI workflow](.github/workflows/check.yml), run the following checks.

```powershell
go test ./...
go vet ./...
python -B -m unittest discover -s tests -p "test_*.py"
node --test ./tests/office-fixture.test.mjs
./tests/installer.tests.ps1
./tests/disk-maintenance.tests.ps1
```

CI has no numeric coverage threshold. For changes to VM isolation, startup, or recovery, record which checks you ran on a real VM.

## Commits and pull requests

Keep commits focused. Use a short imperative subject such as `Add opt-in LAN access to the Windows portal`. Run `git diff --cached --check` before committing. In a pull request, describe the operator-visible change, list the checks you ran, and link a related issue if one exists. Keep credentials, machine-specific network details, VM disks, and generated test artifacts out of Git.
