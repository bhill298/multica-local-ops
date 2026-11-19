> Historical snapshot imported November 18, 2026 from `scratch-projects/orchestration-deep-pilots-2026-11-09/upstream-current/REPORT.md`.
> Current setup/security instructions: [repository guide](../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Current upstream audit — 2026-11-10

The long run exercised Agent Swarm **2.5.3**, public baseline
`77039db514cb98f8a8562a84084fb092a474544d`, with documented assistance. It did
not exercise 2.10.0. The deployed follow-up uses private three-fix commit
`0743b87fd2cdad6b0fb37b6cb9b81e9d8ffd9b75`, still based on 2.5.3. Its natural
offer acceptance was live-verified before this audit; details are in
`../swarm/build/0743b87/README.md`. The earlier two-fix images and backups are
retained for rollback. No deployment state changed during this audit.

The version check should have happened before the long run. Official
[v2.10.0](https://github.com/desplega-ai/agent-swarm/releases/tag/v2.10.0)
was published **2026-11-10 03:10:24 UTC**, before the pilot's
03:31:49.924 UTC intake. This was an operational freshness-check oversight;
the earlier result must retain its tested-version label.

## Immutable public sources

| Source | Exact public commit | Date |
| --- | --- | --- |
| Swarm release v2.10.0 | `b3ba784f4a88098260699f41ba831200e751d501` | committed 2026-11-10 02:46:02Z; released 03:10:24Z |
| Firstmate official main | `913bb7a7b6e68a107c2d0ee755ee29c6f9e7b208` | committed 2026-11-09 23:57:21Z |

The adjacent clean public clones are `agent-swarm-v2.10.0` and
`firstmate-current`. GitHub unauthenticated metadata is preserved in
`swarm-release-metadata.json` and `firstmate-head-metadata.json`.
Both clones have empty `git status --short` after the audit. No live
volume, image, source home, running worker, authorization or deployment changed.

## Swarm findings against v2.10.0

| Finding / private fix | Current source and bounded evidence | Classification |
| --- | --- | --- |
| Dependency-ready acquisition / `f847b0d` | Atomic claim `src/be/db.ts:3204`, offer acceptance `:3306`, offered claim `:3614`; reservation `src/be/db/tasks/write.ts:252`, start `:293` still lack dependency-ready predicates. Acquisition suite: **8 pass, 51 expected invariant failures**, covering blocked/missing prerequisites, joins, acquisition-write race and discovery. | Persists and reproduced on current source. |
| Codex subprocess runtime identity / `15a11c0` | `src/providers/codex-adapter.ts:500-507` builds the MCP runtime header, but the explicit subprocess environment at `:2275-2295` omits its runtime identity. Actual synthetic child/header regression: **1 pass, 2 expected failures**; live and retired identities both arrive as null, missing identity stays fenced. | Persists and reproduced without a model. |
| Preserve offer review until acceptance / `0743b87` | Handler accepts only offered at `src/tools/task-action.ts:504`; progress rewrites reviewing/offered to in_progress at `src/be/db/tasks/write.ts:1329`; DB acceptance lacks foreign-assignee guard and repeated recipient ownership in atomic SQL at `src/be/db.ts:3306`. Progress suite: **10 pass, 4 expected failures**. Additional direct DB offer/status and foreign-assignee tests: **4 expected failures**. | Defect boundaries persist. DB/progress reproduced; current full MCP handler regression remains dependency-blocked. |
| Natural poll → reviewing → Reject | Poll claims the offer (`src/http/poll.ts:440-453`); `claimOfferedTask` changes it to reviewing (`src/be/db.ts:3613`). Reject still accepts only offered (`src/tools/task-action.ts:600`), although DB rejection permits reviewing (`src/be/db.ts:3342`). | Persists by source inspection; not dynamically retested on current release. It is separate from the private offer-accept fix. |
| Pause / resume control | HTTP pause only calls DB pause (`src/http/tasks.ts:2114`); runner reconciliation aborts cancellation/terminal states, not paused (`src/commands/runner.ts:5617-5689`). DB pause/resume changes the same row to paused/in_progress (`src/be/db/tasks/write.ts:1140,1179`), without attempt fencing or stop acknowledgement. **0 pass, 9 expected invariant failures** with disposable DB/fake provider. | Persists and bounded reproduction remains negative. No claim of safe provider stop or fresh resumed attempt. |

The nine pause failures cover absent abort, late completion/failure, ordinary
start reviving paused work, resume before stop acknowledgement, no pending
redispatch, old completion after resume, late active-session registration and
old task-ID cleanup removing a new session. These reproduce control boundaries;
they are not a new live provider Pause test.

Exact public source links:

- [DB acquisition and offer functions](https://github.com/desplega-ai/agent-swarm/blob/b3ba784f4a88098260699f41ba831200e751d501/src/be/db.ts#L3173)
- [Task writes, progress and pause/resume](https://github.com/desplega-ai/agent-swarm/blob/b3ba784f4a88098260699f41ba831200e751d501/src/be/db/tasks/write.ts#L1140)
- [Accept and Reject handlers](https://github.com/desplega-ai/agent-swarm/blob/b3ba784f4a88098260699f41ba831200e751d501/src/tools/task-action.ts#L491)
- [Codex subprocess environment](https://github.com/desplega-ai/agent-swarm/blob/b3ba784f4a88098260699f41ba831200e751d501/src/providers/codex-adapter.ts#L2269)
- [Active-session reconciliation](https://github.com/desplega-ai/agent-swarm/blob/b3ba784f4a88098260699f41ba831200e751d501/src/commands/runner.ts#L5617)

### Changed semantics: do not copy old patches unchanged

Current `checkDependencies` deliberately accepts **completed or skipped**
prerequisites (`src/be/db.ts:3730-3733`). All five explicit skipped-prerequisite
controls pass. The old completed-only SQL guard would block legitimate new work.
Any port must use the current dependency policy and preserve skipped terminal
semantics throughout progress and acquisition. The six relevant production
files have 2,439 insertions and 1,127 deletions between 2.5.3 and 2.10.0;
patch applicability is not proof of compatibility. No current-release fix port
or deployment is authorized or included here.

## Isolated validation scope and limits

Five final runs: **94 tests, 24 pass, 70 desired-invariant failures,
0 unhandled errors**. Exit 1 is expected because these tests express the
missing behaviors. Per-suite logs are `result-*.log`, with matching `.exit` files.
All database state was disposable and provider fixtures synthetic; the child
request used only a new ephemeral loopback server and synthetic identity/key.

The production source was copied to
`/tmp/agent-swarm-upstream-audit-20261110`. Only diagnostic tests, line endings
of its test launcher and test-copy package resolution were adjusted. Public
cached external dependencies were reused; no dependency installation occurred.
Workspace packages point to this 2.10 source, not the old cached workspace.
Bun is the available **1.4.3**; current packageManager requests **1.4.4**.
This is source-bound regression evidence with a cached dependency set, not a
fully locked 2.10 build, deployment, model run or runtime validation.

The initial attempt is retained in `isolated-regressions.log`: it failed before
assertions because the old cached model-catalog workspace lacked a new export,
and the copied shell launcher had CRLF. The corrected aggregate attempt is
`isolated-regressions-corrected.log`. Its full MCP handler suite could not load
because the public cached dependencies lack new `@json-render/chat`; that suite
is excluded from the 94 final tests. No mock or source substitution concealed
this gap. Handlers remain source-confirmed only.

`audit-fixtures/` preserves the five final test sources and synthetic child
fixture. The first four came from existing private regression material; the
current-boundaries fixture adds new offer and skipped-dependency controls.
`run-isolated-regressions.sh`, `rerun-isolated-regressions.sh` and
`run-final-regressions.sh` preserve the performed preparation/correction/run
sequence. A fresh reproduction uses the same public source commit and cached
external dependencies, with diagnostic fixtures copied under `src/tests/`.

## Firstmate current official source

Official main remains **exactly 913bb7a**, the original tested public baseline.
There is no newer official fix to silently substitute for this result.

- Codex worker BUSY observability remains explicitly gated off: both
  `fm_busy_codex_appserver_observable` (`bin/fm-busy-lib.sh:190`) and
  `fm_busy_codex_hooks_verified` (`:204`) return 1; the classifier returns
  `unknown codex-unverified` at `:1155`. This is a current Firstmate source
  capability gate, not proof that modern Codex can never expose lifecycle hooks.
  The same upstream documents a separate primary supervision park test on
  Codex 0.163 (`docs/verification/runtime-backends.md:3617`); it explicitly does
  not verify the worker busy classifier.
- **hc already exists in 913**, as an experimental herdr-core backend separate
  from classic Herdr. `docs/hc-backend.md:1-19` documents minimum hc0.1.14,
  protocol generation1, backend selection and prerequisites; `bin/backends/hc.sh`
  implements the adapter. `docs/verification/runtime-backends.md:3624` onward
  records macOS private-core tests and a separate real Herdr.app exercise.
  This audit does not establish native Windows hc operation. Our actual
  classic-Herdr0.9.5/protocol22 tests do not establish hc compatibility either.

Public references: [Codex gates](https://github.com/kunchenguid/firstmate/blob/913bb7a7b6e68a107c2d0ee755ee29c6f9e7b208/bin/fm-busy-lib.sh#L180),
[hc backend](https://github.com/kunchenguid/firstmate/blob/913bb7a7b6e68a107c2d0ee755ee29c6f9e7b208/docs/hc-backend.md),
[upstream verification scope](https://github.com/kunchenguid/firstmate/blob/913bb7a7b6e68a107c2d0ee755ee29c6f9e7b208/docs/verification/runtime-backends.md#hc).

Recommendation wording must distinguish the assisted 2.5.3 long run, private
follow-up fixes, and this limited current-source audit. Current upstream has not
resolved the reproduced gaps, but its complete runtime behavior remains untested.
