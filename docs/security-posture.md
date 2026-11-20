# Security posture

This describes the selected local stock installation, not every possible Multica
deployment. "Stock" means unchanged Multica source and pinned server images.
"Native Windows" means a provider runs on Windows rather than in WSL2 or a
container. Provider permissions differ even when they share the same Multica UI.

## What protects against destructive or hostile agents?

Multica is an orchestrator, not the machine's security boundary. The model asks
for actions; the local provider process performs them. By default that process
has the daemon user's authority. Our daily Codex configuration narrows writes,
but it does not establish confidential-file isolation or an outbound-data policy.
An agent can still damage files inside its writable project, and readable
secrets could be sent over the network or included in model context.

The backend and browser running in Docker do not contain the native Windows
workers. Likewise, delegation rules, review agents, budgets, logs and the
restart supervisor do not prevent a hostile worker from exercising permissions
it already has. Model compliance and reliable workflow behavior are different
from protection against a malicious or compromised run.

For a stronger boundary, run the **daemon and workers** under a restricted
account, in a carefully mounted container, or in a VM. Give that environment
only the project files and narrowly scoped credentials it needs; constrain
network access separately. WSL2 by itself is not isolation from Windows files
and programs. Host mounts, interoperability and privileged helper tools need
their own restrictions. None of those stronger deployments was configured or
validated here. Desktop/Office integration would need a deliberately limited
host service rather than exposing arbitrary host commands.

This matches upstream's [security model](https://github.com/multica-ai/multica/blob/dbdbb299164347586e2650bb67684a490726a798/apps/docs/content/docs/security-model.mdx).
The tested provider-specific differences follow below.

## Can plugins supply the missing boundary?

Stock Multica has plugins: actions, callable hooks, event/schedule hooks,
resources and UI contributions. The [plugin contract](https://github.com/multica-ai/multica/blob/dbdbb299164347586e2650bb67684a490726a798/packages/core/types/plugin.ts)
does not expose a universal gate intercepting every provider shell command,
file operation or network request. That conclusion follows from the reviewed
contract and the provider execution model; no security plugin was installed or
tested in this setup.

A plugin or MCP service can enforce rules on operations it owns. Upstream's
[Deploy Sentinel example](https://github.com/multica-ai/multica/blob/dbdbb299164347586e2650bb67684a490726a798/examples/plugins/deploy-sentinel/README.md)
refuses certain rollback requests and requires administrator approval of
external MCP tool schemas. Those controls do not constrain an unrelated command
the worker can already execute. Event notifications also cannot undo a deletion
or data transfer that has happened.

Such services become useful security boundaries when the worker lacks the
underlying privilege: keep a deployment credential in a separate bounded
service, expose only approved deployment actions, and prevent the worker from
reading that credential or reaching an alternative privileged path. Adding a
plugin while leaving the same credential and unrestricted host access available
to the worker does not accomplish that. This would be additional integration
and boundary testing, not a protection already supplied by this installation.

## Codex: the daily team

The six installed daily agents use Codex. The configured defaults are:

```text
-c approval_policy="never"
-c windows.sandbox="mxc"
-c features.exec_permission_approvals=false
-c features.request_permissions_tool=false
```

Fresh sessions were observed using workspace-write and native Windows MXC.
Project writes worked; command and patch writes to an outside disposable canary
failed. Narrow additional writable directories and Git metadata grants worked.
A native continuation retained the fresh policy and grants. The installed stock
build also passed daemon-crash and physical Windows-restart recovery tests.

Never-ask means a needed permission is denied instead of queued for owner review.
Known extra folders must be granted in advance to a suitably scoped agent. Stock
Multica still has automatic approval callbacks. Changing to an asking policy
does not create a human review queue and could let Multica approve the request.

This is not full account isolation. Reads extend to files the account can read,
networking is enabled, and standard temporary directories are writable. Extra
grants and owner-supplied custom arguments widen the boundary. Old sessions can
retain earlier policies and grants; use a fresh agent/context after narrowing
scope. Do not reuse the archived trials to test current permissions.

## Agy: tested runtime, separate permission system

The authenticated workflow pilot used Agy 1.5.12 and only
`gemini-3.8-flash-low`. It completed delegation, independent review, a changed
requirement and accepted closure. The six daily agents remain on Codex.

Stock Multica adds `--dangerously-skip-permissions` and filters attempts to replace
that flag. It does permit `--sandbox` through custom arguments. The installed Agy
supports session `--settings`, but this Multica baseline filters that argument
as unsupported, so a per-agent settings-file argument is not available through
the ordinary adapter. Dedicated Agy project permission configuration can supply
deny rules without editing global settings or Multica source.

The boundary test and its conclusions are recorded in [findings](findings.md).
Its normal Python process really ran in a Windows AppContainer: project writes
worked, outside writes and its child PowerShell outside write were blocked.
Absolute file deny rules also blocked native file tools and the denied in-project
write. However, a deliberate unsandboxed command changed an outside canary even
with those file rules. The attempted blanket `unsandboxed(*)` deny produced an
unsupported-rule warning and also prevented ordinary commands from working.
That arm was not accepted as a usable containment policy.

The tested configuration therefore failed whole-agent containment. The OS
sandbox held for commands running inside it; the agent could choose a supported
unsandboxed execution path. These results do not establish an OS sandbox exploit.
No Agy policy was deployed to the daily team. The reusable
[probe and method](../examples/agy-boundary.md) are included as diagnostics.

Do not infer that the Codex never/MXC settings apply to Agy, or that requesting
`--sandbox` blocks every route outside the project. Native file tools and a
command's explicit outside-sandbox execution are separate paths to test.

Google documents an OS sandbox on supported native Windows versions and deny
rules that remain effective in always-proceed mode. Those are useful controls,
but a policy must also prevent unsandboxed execution if the intended boundary is
"only inside these folders." See [Agy sandbox documentation](https://antigravity.google/docs/sandbox/)
and [permission settings](https://antigravity.google/docs/settings?tab=cli).

## Claude: working integration, no native Windows command sandbox

The short workflow pilot used Claude Code 2.1.322, its existing Max login and
`claude-haiku-4-5-20251001`. Delegation, independent review and a changed
requirement passed. This does not establish sandbox isolation or active-worker
recovery across a reboot for Claude.

Stock Multica forces `--permission-mode bypassPermissions`, filters a competing
permission-mode argument and automatically allows permission control requests.
The Codex settings above do not constrain Claude.

Claude's built-in command sandbox runs on macOS, Linux and **WSL2**, and does
**not run on native Windows**. On this Windows host, using that built-in sandbox
would require running Claude in WSL2, or using a suitable Linux container. A
plain native Windows Claude process has no equivalent built-in command sandbox.
See [Anthropic's sandbox documentation](https://code.claude.com/docs/en/sandboxing).

Claude also has tool deny rules and settings that restrict its own file tools
outside working directories, including in bypass mode. Those do not constrain
arbitrary Python/PowerShell subprocess file access. WSL2 sandboxing would need
unsandboxed retries disabled, availability checks and checks of Windows interop
and host-tool access. None of that was configured or tested in this follow-up.
Claude's configuration was left unchanged as requested. See
[Claude file-tool restrictions](https://code.claude.com/docs/en/permissions#block-file-tool-reads-and-writes-outside-the-working-directories).

## Host tools and application authentication

A host MCP server has the authority of its own process. It can perform actions
outside a provider's command sandbox, so scope the server's actual operations.
The Office proof exposed one fixed operation and owned only its hidden test
documents. It was not a general command runner or an installed desktop-control
service. See [adding tools](tools.md).

Web and API ports bind to loopback; PostgreSQL is not published. The application
uses development authentication with a fixed code and a long token lifetime.
This avoids a new hosted account but is not an authentication boundary against
other people or processes with access to the local machine. The setup is for
local use, not direct internet exposure.

The private `.env`, JWT signing secret, application profile/PAT and provider
logins stay outside Git. A fresh machine needs its own normal provider logins.
Do not publish runtime folders, private backups or raw authenticated session
artifacts. The installer copies no provider credentials.
