# Testing and evidence guide

The [findings](findings.md) and [security posture](security-posture.md) describe
the selected deployment. [Historical notes](history/README.md) preserve 29 setup,
comparison, test and intervention reports. Their dates/configurations matter;
older claims about forks, unrepeated reboot tests or missing provider tests are
superseded by the current findings.

## Local source checks

```powershell
go test ./...
go vet ./...
pwsh -NoProfile -File ./tests/installer.tests.ps1
node --test ./tests/office-fixture.test.mjs
```

The optional installer `-Docker` check renders its own disposable Compose fixture.
It does not replace the live stack. The Office live test is opt-in and requires
desktop Office; its [README](../tools/office-fixture/README.md) explains it. CI runs
the ordinary Go/PowerShell/protocol checks and does not claim Office availability.

## What is preserved for integration testing

| Area | Source/method and acceptance |
| --- | --- |
| Installation, repeat install and adoption | Installer source/tests plus current setup docs. Use separate ports, profile, task and volumes for a disposable stack. Verify identity/data preservation rather than only a successful process exit. Back up before live adoption. |
| Codex boundary | Fresh actors under the documented never/MXC settings; allowed inside writes, denied command/patch outside-canary writes, narrow grant/continuation tests. Use owner-created disposable canaries, never personal files. Do not resume an older asking context. |
| Crash and reboot recovery | [Checkpoint source and method](../examples/recovery/README.md). Save independent prefixes, verify actual processes/runs and distinguish a fresh recovery attempt from identical execution resume. An operator controls physical restart. |
| Multi-hour coordination | The stock reduction plan/results and historical v5 reports preserve the 17-issue mixed-project conditions, scheduled late correction, review, independent checks and supplied decision milestone. Current contract includes review adjudication and explicit project binding. Do not present the eight-hour default timer as an eight-hour test. |
| Claude and Agy workflows | Each used fresh lead/builder/reviewer actors, isolated CSV/spec/source fixtures, total 42.00 then an explicit changed requirement for 43.00. Check Decimal output, Unicode names, input hash, current source revision, fresh review after implementation, actual Done closure and no remaining runs/guards. Only Flash was authorized for Agy. Claude's native Windows sandbox was not established. |
| Agy native boundary | [Probe/method](../examples/agy-boundary.md) plus current findings. Positive owner controls, separate fresh policy arms, actual AppContainer flag and canary bytes. The unsandboxed outside write succeeded: do not relabel that result a pass. |
| Office host tool | [Bundled source/setup](../tools/office-fixture/README.md), protocol tests and independent artifact checker. Earlier stock-Codex integration and relocated direct-MCP testing are distinct checks. |
| Browser | [Diagnostic source](../examples/browser-proof.mjs) and operating notes. Owner-context headless Edge passed; the tested Codex worker failed before interaction. No general browser service is installed. |

## Evidence limits and exclusions

The archive preserves narrative reports and plans, including failures and operator
interventions. It excludes raw model/session logs, provider homes, databases,
binary patch exports, downloaded upstream trees, generated work products and
proof documents. Historical links to those artifacts are labeled unbundled.

Fresh application IDs and run receipts must be generated on a new installation.
Old hardcoded trial IDs are provenance, not portable setup values. Current
installer/team helpers create/select appropriate IDs; test actors should stay
separate from the daily team and be archived when finished. Retain independent
owner verification and record manual repairs honestly.

No full disaster restore, monetary hard cap, eight-hour completed pilot,
pre-login recovery, generic desktop service, Claude WSL2 isolation or safe Agy
whole-agent native boundary is claimed. See findings for the exact distinctions.
