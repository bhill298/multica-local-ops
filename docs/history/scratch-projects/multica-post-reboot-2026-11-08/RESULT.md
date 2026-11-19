> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-post-reboot-2026-11-08/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

## Post-reboot startup and path regression — November 8

The user rebooted before this test. Windows reports boot at 10:29 Mountain.
The installed broker was created at 10:40:58 and the installed patched daemon
at 10:43:25. The scheduled supervisor is Ready, returns result 0, and runs its
windowless executable from .multica/local-runtime/bin. Logs show failed daemon
starts while the backend was unavailable, followed by successful automatic
startup when it became available. All three Docker services and the review
broker were already up before this test; root did not start them. Docker Desktop
has autoStart=true. Prior ORCH-48 records remain present and Done.

A fresh Luna/low native-mxc test ORCH-60 -> ORCH-61 ran from about 17:20 to
17:26 Mountain. The lead resolved and invoked multica, ended its initial run,
then resumed via a two-minute one-shot wakeup. It invoked the CLI again and
delegated one worker. The worker resolved the executable outside the protected
credential directory, successfully read its issue, hashed a supplied sentinel,
received DENIED on an ordinary read of the identically protected nonsecret
canary, and saw no MULTICA_LOCAL_APPROVAL_ environment variables. Root separately
verified all fields and the SHA256. The lead accepted the worker and closed both
issues without a nudge. Final state: two Done issues, zero active runs, zero
enabled wakeups. No provider/login changes, desktop control or user action was
needed. No code or installation changes were required.

This directly passes the post-installation path regression for fresh execution,
a scheduled resumed lead, delegated worker execution and credential isolation
after the reboot. It also supplies observed startup-after-reboot evidence.
It does not demonstrate active work surviving a reboot: the earlier pilot had
already completed before the user rebooted. To test that remaining case, start
a bounded checkpointed job and register a delayed continuation, verify persisted
progress, have the user reboot, then inspect retry/session, checkpoint, output,
closure and absence of duplicated work after login. Do not reboot automatically.
A second reboot is unnecessary for verifying the path fix itself.

Remaining broader acceptance: active-work reboot recovery; longer unattended
runs after the final layout fix; general desktop applications and merge/conflict
workflows; upkeep of the local fork. Clean short delayed execution is now passed.

Evidence: startup.json, setup.json, latest.json, final.json and project/result.json
in scratch-projects/multica-post-reboot-2026-11-08. Source/installed runtime remains
local fork 9bd735f7c. This folder and the consolidated notes are outside Git.
