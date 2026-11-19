> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-final-suite-2026-11-08/desktop/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Background Office API acceptance, November 8

**Pass through a fixed local MCP tool (ORCH-77); direct Codex/MXC shell
escalation remains blocked (ORCH-73).** No user input or desktop takeover was
needed. This demonstrates a narrow application-API integration, not arbitrary
Office or general GUI automation.

At 18:56:49 Mountain, native Multica 0.7.0-local-approval / Codex 0.167.0 /
gpt-6-luna low invoked office_fixture.run_hidden_office_fixture with no arguments.
The host MCP launched the reviewed PowerShell probe with CreateNoWindow, outside
the agent sandbox. The agent retained MXC and credential-directory deny rules.

- Excel: new hidden process, disposable workbook, 19+23 formula evaluated to 42,
  XLSX saved, closed, reopened read-only and values checked.
- Word: new hidden process/document, proof text written, DOCX saved, PDF exported.
- Both records report visible=false and test_was_foreground=false. Only test-owned
  instances were closed; independent checking found neither process still alive.
- Independent ZIP/XML checks confirmed the XLSX cached value 42 and Word text;
  the PDF header was valid. Fresh output timestamps match the MCP invocation.
- No SendInput, mouse, keyboard, desktop session ownership, login or email flow.

The MCP exposes one fixed operation, with no command/path/document arguments. Its
installed code and hash-pinned script reside under the directory denied to pilot
agents. A separate guard check rejected extra command arguments and a modified
script without performing additional Office operations. This trusted host tool
is outside the sandbox boundary; its narrow implementation is part of the trust
model. Expanding it to real workflows would require explicit app-specific tools,
scoped document handling and appropriate approval policy. It is a test adapter,
not a production Office integration.

## Direct-shell failures and operator changes

Normal sandboxed COM activation returned E_ACCESSDENIED. The reviewed exact
script was approved once through the local owner review broker, but MXC failed
before starting it with CreateProcessSecurityEnvironment HRESULT 0x80070020
(sharing violation). Two approved Git commands independently hit the same error.
Thus owner decision routing worked, but successful execution after approval is
not reliable for every current MXC permission expansion.

A later Office retry proposed Windows PowerShell with ExecutionPolicy Bypass.
The operator denied that request; Codex aborted the turn, as expected. No policy
was weakened. The successful alternative was the fixed host MCP tool, rather
than granting the agent unrestricted command execution.

The first direct host control passed Excel; the Word harness initially attempted
an unavailable application Hwnd. The operator corrected it to the hidden document
window handle, specifically identified/closed the empty test-owned leftover Word
process, and reran the host control successfully. Host control results are kept
separate from fresh mcp-output evidence. These setup changes and the custom MCP
installation are operator interventions, not autonomous framework discoveries.

## Evidence

- mcp-setup.json: ORCH-77 and dedicated agent; run
  01a1be05-7645-7353-9f1f-4b1c220cd9c3 completed, issue independently accepted Done.
- mcp-install.json: installed paths and reviewed script SHA256.
- mcp-output/result.json and mcp-proof.xlsx/docx/pdf: fresh app outputs.
- independent-mcp-verification.json and mcp-guard-verification.json: root checks.
- Protected office-fixture/calls.jsonl: host receipt c6d63677-f82a-41bd-881a-a617e22f047e.
- sandbox-denied.json / approval.json: original failed shell integration.
- host-result-v1.json, host-result-v2.json, host-word-v3.json: separate controls.

The test MCP starts on demand with its dedicated agent and exits with that run;
it is not a new always-running service. Existing read-only Windows-MCP screenshot
evidence remains separate. A separate interactive Windows session is untested.

November 9 follow-up: command-rule investigation found no matching rules for the
three approved MXC launch failures. Original turn contexts used the user reviewer;
approval audit timestamps precede each launcher result. Current isolated config
reads report no managed requirements; the forbidden-rule control worked.
Initial file/COM denials remain separate permission-boundary observations. No
settings were weakened. The MXC sharing-violation cause remains unresolved.
See ../policy-investigation-2026-11-09/RESULT.md for scope and evidence.

November 9 direct reproduction follow-up: seven direct Codex approval flows used
the original resolved permission profiles without Multica's adapter/broker. All
requested programs launched without 0x80070020, including real alternate-index
writes, Multica-style held locks, delayed approval and paired approval flows.
A current Multica/broker control also passed. The Excel-only original Office
probe launched and reproduced COM E_ACCESSDENIED, a separate restriction.
No root cause or runtime fix was established; historical sharing failures remain
unresolved. Original evidence was preserved and temporary helpers cleaned up.
See ../direct-codex-repro-2026-11-09/RESULT.md for scope, differences and records.
