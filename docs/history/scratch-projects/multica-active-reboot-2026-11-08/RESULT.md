> Historical snapshot imported November 18, 2026 from `scratch-projects/multica-active-reboot-2026-11-08/RESULT.md`.
> Current setup/security instructions: [repository guide](../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Active-work reboot result — November 8

PASS for the configured workflow: all saved work recovered, with agent-driven
recovery through an independently persisted time backstop. This is not a pass
for platform automatic worker retry alone.

Windows restart request: 18:20:01 Mountain (event 1074). Last worker checkpoint:
18:19:58, index 36. The original worker failed at 18:20:03 during shutdown. Its
terminal-event lead continuation started at 18:20:05 and failed initialization
while Windows was still shutting down. That was a lead run, not a worker retry.
Windows event log stopped at 18:21:28; new boot was 18:22:48.5, event log started
18:23:03. Supervisor retries restored the daemon at 18:25:42 after the backend.

The pre-registered 12-minute root time wakeup fired at 18:29:16. The lead saw no
active worker retry, explicitly started one new worker attempt at 18:30:31, and
registered a new exact-run terminal wakeup. The worker preserved all 36 committed
pre-reboot steps, resumed in a second process, detected the changed boot estimate
and finished 12 post-reboot steps at 18:31:34. The lead reconciled and closed
ORCH-62/63 at about 18:32:45. No operator rerun or prompt correction was sent after
reboot. The operator independently verified boot times, all eight handoff-captured
checkpoints, the complete hash chain, 48 unique sequential indices, two launches,
and exactly 12 post-reboot steps. Both issues Done, zero active runs/wakeups.

The warning about an ignored computer_use.windows.always_allowed_app_ids setting
was incidental stderr from startup, not evidence that it caused the shutdown.
Preserve separate actor IDs when interpreting run history: lead continuations can
be recorded on a worker issue.

Important operational lesson: a completion-event wakeup can be consumed by a
lead launch during OS shutdown, then fail. Its original event rule is already
disabled. An independent durable root timer/condition is needed to recover that
case. The tested setup included such a timer before the reboot; do not generalize
this to every Multica task without equivalent recovery instructions/backstop.

Evidence: pre-reboot.json, post-boot.json, reboot-events.json, recovery-events.jsonl,
verified-reboot.json, final.json and project/checkpoint.json. Run node verify.mjs
for the independent chain/prefix checks. Remaining suite work is in RESUME.md.
