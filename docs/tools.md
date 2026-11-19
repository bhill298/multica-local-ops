# Adding tools

Stock Multica accepts an MCP configuration on an agent. A tool server can expose
a bounded application API, a browser library, or another local operation without
changing Multica source. This does not automatically grant every agent the tool.

For a reviewed local stdio server, an owner-supplied JSON file has this shape:

```json
{
  "mcpServers": {
    "my-local-tool": {
      "command": "C:/path/to/node.exe",
      "args": ["C:/path/to/reviewed-server.mjs"]
    }
  }
}
```

Attach it to a dedicated fresh agent using the installed CLI and your workspace:

```powershell
& "$env:USERPROFILE/.multica/stock-runtime/bin/multica.exe" --profile orchestration-trial-20261024 --workspace-id WORKSPACE_ID agent update AGENT_ID --mcp-config-file C:/path/to/tool.json
```

Treat this as replacement configuration: include any other servers that agent
still needs. Start a fresh issue attempt after changing tools. Do not use an old
provider session as evidence that a changed configuration was applied. Keep files
containing tokens private and out of Git; the CLI also supports stdin input.

The tested Codex path accepts per-agent MCP configuration. The inspected Claude
adapter writes supplied MCP configuration to a temporary file and passes it to
Claude Code. The inspected Antigravity adapter does not wire `ExecOptions.McpConfig`
into its command. Its advertised runtime capabilities are not proof that this
particular per-agent tool configuration works. Do not assume the same JSON
attachment works with Agy without testing it.
Its command tools remain available for local scripts; this particular MCP
configuration route needs separate integration and verification.

## Existing Office fixture

The original fixed Office MCP source remains at:

```text
C:/Users/brennan/Desktop/proj/tmp/scratch-projects/multica-minimal-2026-11-14/desktop/host/server.mjs
```

It exposes one no-argument operation, `run_hidden_office_fixture`. It pins the
PowerShell probe's hash, permits one call per server process and uses a fixed
output directory. It creates owned hidden Excel/Word instances, checks a formula
result of 42, saves/reopens the spreadsheet, and exports a Word document and PDF.
It refuses to share an existing Word process. It does not operate on arbitrary
documents or provide a general command runner. Its PowerShell and output paths
are specific to this machine. Those files were never part of the Multica fork.

The fixture passed with stock Multica in earlier testing. It is preserved as a
test artifact, not installed as a daily tool or bundled into this package. Keep
the old `desktop/host` and `desktop/output` directories together if reusing it;
moving or adapting it requires updating the fixed paths and rechecking its hash
and behavior. The six daily agents currently have no per-agent MCP configuration.

More useful Office operations can be written as separate tools with explicit
document/path scopes. That is additional tool development and testing, not a
Multica patch. Host MCP tools run with the host process's authority outside the
Codex command sandbox. A tool that accepts arbitrary commands would discard the
boundary that made this fixed fixture small and reviewable.
