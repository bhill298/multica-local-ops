# Linux worker tools and project folders

This is the tools layer for the proposed Ubuntu Hyper-V deployment. It can also
run as a standalone toolbox on a Linux Docker engine. The Debian userspace in
the container works on an Ubuntu guest. The Windows installer does not yet
provision the VM, host shares, or Linux Multica daemon and provider CLIs.

The image includes C/C++, CMake, Ninja, Git, Python (including venv), distro
Node.js/npm, SQLite, jq and ripgrep. For binary inspection use file, strings,
readelf, objdump and ExifTool. For document work use LibreOffice (Writer, Calc,
Impress), Pandoc, Poppler, python-docx, openpyxl and Pillow. For browser and GUI
automation use Chromium, the matching ChromeDriver, Python Selenium, Xvfb,
xterm and xdotool. Xvfb provides a private display. No Windows desktop or
display socket is needed. The packaged Windows Office COM tool is separate.

The worker uses the [Playwright v1.59.1 Docker seccomp profile](https://github.com/microsoft/playwright/blob/v1.59.1/utils/docker/seccomp_profile.json)
([license](LICENSE-playwright)) so Chromium can create its own sandbox as the
worker user. The stock Docker Desktop profile failed to launch Chromium in
the local test. This profile grants additional Linux namespace operations to
processes in this container. Recheck it when refreshing the browser toolchain.

The default user can use sudo inside the container. Install additional packages
there for an individual run, or extend the image for repeatable installations.
Use a provider-supported language runtime when adding the provider CLI layer.

## Project mounts

For host-backed folders, give the VM's exchange identity Windows share **and**
filesystem permissions for just the selected directories. Grant read access to
the input and modify access to the disposable exchange. Mount them separately in
the guest with matching read-only and read/write options. Keep share credentials
in the guest administrator's storage. An alternative is to export a guest-owned
exchange to Windows and push copies of inputs from Windows.

Set `PROJECT_INPUT` and `PROJECT_EXCHANGE` to distinct absolute Linux paths
for one project. Use separate directory trees with no nested mounts. The VM
startup service must verify that the expected filesystems are mounted before
launching a worker. Compose rejects missing directories but cannot distinguish
an empty mountpoint from a connected share. Pass only these project paths to
the container. Exclude the parent folder, credentials and Docker socket.
Configure ownership so the worker can read the input and write to the exchange.

From this directory with the two variables set, run:

```sh
docker compose build --pull
docker compose run --rm worker bash
```

Files appear at `/project/input` and `/project/exchange`. Changes in the exchange
are visible on both sides, including deletions. Keep the primary project copy
and backups outside the exchange. Give each project's workers only its own pair.
