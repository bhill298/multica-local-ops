# Fixed Office MCP tool

This preserves the separate Office proof used with stock Multica. It exposes
one operation, `run_hidden_office_fixture`, with no arguments. It creates its
own hidden Excel workbook and Word document, checks 19+23=42, saves/reopens the
spreadsheet and exports a PDF. It provides no general shell command, input
injection, arbitrary document/path access or control of existing user documents.

Requirements: Windows with initialized desktop Excel and Word, Node.js and
PowerShell 7.2 or later. The packaged operation passed with Node 24.16.0 and
PowerShell 7.6.3. It is optional; the base installer does not enable it on agents.
Claude configuration and the daily team are unchanged.

## Configure after cloning to a durable location

From PowerShell 7 in the repository:

```powershell
pwsh -NoProfile -File ./tools/office-fixture/configure.ps1
```

This writes an ignored `tools/office-fixture/mcp.local.json` containing absolute
Node, server and PowerShell paths. It defaults to the PowerShell 7 process running
the helper. Use `-NodePath` or `-PowerShellPath` to choose another existing
absolute executable. The server requires this explicit PowerShell setting and
does not fall back to Windows PowerShell 5.1.

Attach that file to a dedicated fresh Codex agent, using the installed CLI:

```powershell
& "$env:USERPROFILE/.multica/stock-runtime/bin/multica.exe" --profile orchestration-trial-20261024 --workspace-id WORKSPACE_ID agent update AGENT_ID --mcp-config-file ./tools/office-fixture/mcp.local.json
```

This replaces that agent's MCP configuration; include any other required servers
before applying it. Run from the repository so the file is inside the CLI's
working directory. Start a fresh issue attempt. Merely generating the JSON does
not enable a tool or change any agent. Regenerate it after moving the repository
or changing executable paths. The inspected Agy adapter does not forward the
per-agent MCP configuration; do not assume this attachment works with Agy.

## Boundaries and outputs

The server accepts only the fixed operation, verifies the PowerShell source's
SHA256 after normalizing CRLF to LF, and permits one attempt per server process.
An edit to the probe requires review and updating the pinned hash. PowerShell
receives a small standard Windows environment rather than provider/application
token variables. Executable/configuration paths remain trusted owner settings.

Outputs use a new `output/run-<id>` directory per attempt; receipts go under
`output`. The output root cannot be a symlink/junction. The probe refuses an
existing Word process and checks that COM did not return a pre-existing Excel
instance. It quits only the instances it created and verifies they were hidden
at the recorded checks. This is not continuous foreground monitoring.

Host MCP operations run outside the coding command sandbox with the host user's
authority. This fixture is deliberately narrow. It is not a general security
boundary against another process able to edit the server itself. A 90-second
timeout stops PowerShell; a blocked COM call may leave its new hidden Office
instance behind. Inspect that specific instance rather than killing all Office
processes. The timed-out packaging experiment was cleaned up by exact process
identity; no user Office instance was closed.

All generated Office files, receipts and local MCP configuration are ignored
by Git. They are not needed to preserve or recreate the tool.

## Verification and provenance

```powershell
node --test ./tests/office-fixture.test.mjs
# Optional live test: leave Word closed; creates only disposable proof files.
$env:MULTICA_TEST_OFFICE='1'
$env:MULTICA_OFFICE_PWSH=(Get-Process -Id $PID).Path
node --test ./tests/office-fixture.test.mjs
Remove-Item Env:MULTICA_TEST_OFFICE
Remove-Item Env:MULTICA_OFFICE_PWSH
```

The ordinary suite checks protocol/tool shape, invalid input rejection, script
tampering, one-attempt enforcement and executable path validation without opening
Office. CI runs it. The opt-in live suite also calls the real MCP operation and
independently inspects saved Excel formula/cached 42, Word XML and PDF header.

The original probe hash was
`bd679ffcc87d510fe937edfed2185f3aa3e9c1710c30498813b45bf735a2168e`.
This package replaces the old machine-specific output and PowerShell paths,
creates fresh output directories and adds portable setup/tests. Core Office
operations and owned-instance checks are retained. The relocated host MCP passed
on November 18, 2026. Earlier stock-Codex integration is documented in the archived
reports; this packaging check called MCP directly, not through a newly configured
daily agent. An initial Windows PowerShell 5.1/STA experiment timed out in Word;
the verified PowerShell 7 launch without `-STA` passed in about six seconds. Those
changes happened together, so no single cause is claimed. Windows PowerShell 5.1
is unsupported here. See [current findings](../../docs/findings.md).
