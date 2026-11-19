> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-local-reliability/local-reliability/README.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Local Windows pilot reliability

This opt-in local fork adds a review queue for Codex app-server approvals and a
non-elevated scheduled supervisor for the isolated Multica pilot profile.
It uses existing Codex authentication. Model inference still uses Codex's service.

Build `server/cmd/multica` to `local-bin/multica-protected.exe` and
`server/cmd/local-supervisor` to `local-bin/supervisor.exe` with
`-ldflags=-H=windowsgui`, then run
`local-reliability/install.ps1` as the signed-in user. The scheduled task
`Multica Local Pilot Supervisor` checks the daemon and approval broker every
minute and at login. The supervisor uses the Windows GUI subsystem and launches
all child commands with `CREATE_NO_WINDOW`; it never launches PowerShell for
routine checks. It does not start Docker Desktop or reboot Windows.
The existing Docker services retain their restart policies.

Host state is under `%USERPROFILE%/.multica/local-reliability`, outside agent
projects. Executables live separately in `%USERPROFILE%/.multica/local-runtime/bin`
so workers can read/execute the CLI while the credential directory stays denied.
The installer copies the executable and service scripts into these locations, so
recovery does not depend on keeping this source checkout. Run its installed
`open-review.ps1` to open an authenticated review page without another login.
The task sets `MULTICA_LOCAL_APPROVAL_TOKEN_FILE` only on the host
daemon. The adapter strips all `MULTICA_LOCAL_APPROVAL_` variables before
launching Codex, replaces the isolated task home's legacy sandbox block with
a `:workspace` permission profile denying reads to the host review directory,
and sets approval routing to `user` / `on-request` for new and resumed threads.
The shared Codex configuration is not edited. Native Windows mxc remains enabled.

The review page is at `http://127.0.0.1:43132/`. To authenticate it, open it with
the host token as a URL fragment; the page moves the token to session storage
and removes the fragment. Do not share this token or pass it to workers.
Only the owner/trusted operator should review requests. Approval grants one
request, without saving command-prefix or session-wide approval rules.
No account or external provider is used for this review service.

Pending requests time out after 30 minutes. Broker restart denies old pending
requests; lost daemon polling makes a request stale after 15 seconds. A denied
command cancels the Codex turn, which Multica currently records as a failed run
(`turn was aborted`); leads must inspect that failure before deciding how to
continue. This is a separate local review UI, not a native Multica inbox.

This queue gates requests emitted by Codex. Operations already permitted in the
workspace continue normally. It is not a general policy engine for every tool
or protection against another unrestricted process running as the Windows user.
Keep the review service on loopback and its state outside agent-readable roots.

An accepted owner decision does not guarantee that the runtime can start the
command. In particular, an MXC access expansion can fail before process launch
with `CreateProcessSecurityEnvironment` / `0x80070020`. Preserve that error in
the run receipt; do not report the operation as completed or disable isolation.
For a known project requirement, prefer a narrowly scoped permission profile
and verify its effective boundary. Linked Git worktrees may have a separate
read-only metadata directory under the common `.git/worktrees/<name>`; granting
the common `.git` path alone does not necessarily make that narrower path
writable. Limit exceptions to the attached repository's actual metadata paths.

Inspect command-rule decisions separately from launcher errors. In the pilot's
three approved 0x80070020 failures, original Codex turn contexts selected the
user reviewer and broker decisions were approved before the launcher failed.
Subsequent execpolicy checks found no matching command rules; isolated config
reads reported no managed requirements. This supports a post-approval MXC setup
failure, rather than a forbidden prefix rule. Its underlying cause remains
unresolved; adding an allow rule is not an established fix.

Later direct Codex tests using the same resolved permission profiles completed
seven approved launches without that sharing violation, including real alternate
Git-index writes, held coordination locks, delayed approval and paired approval
flows. A contemporaneous Multica/broker marker control also passed. The original
Office script limited to Excel started but retained its separate COM access
denial. These results leave the historical launcher failure intermittent and
unresolved; they do not establish a locking fix or justify disabling isolation.

For a temporary file-access decision, a dedicated agent can opt into Codex's
experimental `features.request_permissions_tool=true` custom argument. The
`request_permissions` tool routes a requested filesystem/network subset through
this same review queue; this adapter grants approved permissions for the current
turn only. Exact-folder approval and denial have been tested while the review
directory remained unreadable. This feature is under development and is not
enabled globally by the installer. Do not substitute an unrestricted command
request when a narrow request is denied. See the official
[permission request protocol](https://learn.chatgpt.com/docs/app-server#permission-requests).

Recovery supervision restores the daemon and broker processes, not every
business workflow. A terminal-event continuation can start during shutdown and
fail after its one-shot event has been consumed. Long-running leads should also
persist an independent bounded root timer or condition, inspect actual active
attempts before retrying, and reconcile the owning/root issues after acceptance.
Keep recovery instructions and checkpoints durable before an interruption.
Late continuations must reread current business state and preserve an accepted
Done issue unless a new requirement or failed evidence explicitly reopens it.
Drain or guard queued descendant continuations before final acceptance; an old
reviewer instruction to mark in_review must not undo a later lead acceptance.
The versioned pilot coordination contract (historical reference: `scratch-projects/multica-local-reliability/local-reliability/pilot-coordination-v5.txt`; artifact not bundled) preserves
these instructions alongside the reliability code. It adds explicit lead/root
acceptance authority and a bounded root time backstop through final closure.
Do not make a lead wait for root acceptance before finishing its own reviewed
deliverable, or encode an old pending status as a permanent handoff instruction.
Task-event rules exclude the registering run's own events; use an independent
time backstop rather than a self-terminal subscription for that case.
The v4 contract (historical reference: `scratch-projects/multica-local-reliability/local-reliability/pilot-coordination-v4.txt`; artifact not bundled) retains the earlier late-acceptance
guard. These contracts retain the pilot's scope restriction and remain agent
instructions rather than a server-enforced status invariant.

A fresh November 8 local v5 pilot exercised two unrelated projects, nested
delegation, a late code requirement, a one-hour 10,000-row audit, a two-hour
synthetic business decision and fresh independent reviews. All thirteen issues
closed without corrective operator intervention or approval after dispatch;
final verification found zero active runs or enabled wakeups. The agents created
the root guard before delegation. This is one elapsed-time acceptance run with
idle waits; reboot and permission faults were tested separately. It does not
establish long-term unattended reliability or resolve the MXC launch limitation
described above. The prior longer run required a v5/backstop correction and
remains an intervention-assisted result.

Desktop application APIs require a separate trusted integration. A narrowly
implemented host MCP tool can perform a fixed application operation while the
agent remains sandboxed. Such a tool runs outside that sandbox and must enforce
its own operation, document and argument boundaries; an approval queue for
Codex shell requests does not automatically govern every MCP tool.

Tests: `node --test local-reliability/broker.test.mjs` and, from `server`,
`go test ./pkg/agent -run 'TestLocalApproval' -count=1`.
On this host, loopback subprocess tests require an unsandboxed test shell.

To uninstall: unregister the named scheduled task, stop only the named profile's
daemon, stop the broker process with this script path, and restart the original
Multica binary without `MULTICA_LOCAL_APPROVAL_TOKEN_FILE`. Keep private state
and audit history until no longer needed. This restores upstream automatic
approval behavior; it does not retain the review gate.
