# Ubuntu guest release

`release.json` selects the Ubuntu Server amd64 installation image for new VMs.
Use the SHA-256 before attaching the ISO. To update a point release, update the
image URL and digest together from Canonical's signed release checksums.
Existing guests receive point-release package changes through normal apt updates.

During guest setup run `sudo bash setup-packages.sh --install`. It reads the
package list for the installed Ubuntu codename, refreshes apt, and checks that
the whole transaction resolves before installing. Use `--check` for validation.
These files supply guest prerequisites for the planned VM installer. The Docker
worker image and its separate package choices are under [linux-worker](../linux-worker/README.md).

For a newer Ubuntu series, add its codename list beside the existing one and
validate it in a clean guest. Update only the renamed or replaced packages.
Build a replacement VM using the new release profile. Restore a copy of the
database, uploads and persistent worker data there. Check the worker logins,
guest integration, project mounts and checkpoint recovery before switching over.
Keep the old VM stopped and available until the new deployment is accepted.
Run only one copy against the live job queue. Existing snapshots do not
replace an independent backup for this migration.

## Agent-assisted upgrade

1. Read Canonical's LTS release listing. Verify its signed SHA256SUMS with a
   trusted Ubuntu image signing key. Prepare a candidate release JSON and
   codename package list in a branch.
2. From Windows with a Linux Docker engine available, run
   `./Test-Release.ps1 -ReleaseFile ./candidate.json -IsoPath <downloaded-iso>`
   from this directory. Omit the ISO path for a package-only preflight.
   Investigate apt failures using the new release's package index. After a
   rename, check that the replacement still supplies the command the setup uses.
3. Boot the candidate in a disposable Hyper-V VM. Confirm Docker and Compose
   run, automatic updates are active, and the guest can create and restore a
   production checkpoint. Exercise both shares with fixture files and run a
   worker task that renders a document and uses the browser.
4. Report the tested release, changed packages, restore result and remaining
   failures before switching the active VM. Keep live credentials out of test
   output. A guest or Docker preflight alone does not exercise a Hyper-V boot.
