> Historical snapshot imported November 18, 2026 from `scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/windows-git-interop/REPORT.md`.
> Current setup/security instructions: [repository guide](../../../../../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Windows/container Git interoperability — bounded read-only check

The shared feature-worktree **files are accessible on Windows**, but this
existing Linux-created worktree is **not usable with Windows Git** as stored.
The main repository remains readable by Windows Git. This is an expected Git
metadata path mismatch across filesystem namespaces, not evidence of a Swarm
framework defect.

Existing fixture, unchanged:
`swarm/projects/git-isolation-feature-a`

| Check | Observed result |
| --- | --- |
| Windows Git | `git version 2.54.0.windows.1` |
| Windows feature-worktree status | exit128, `fatal: not a git repository: (NULL)` |
| Container Git | `git version 2.43.0` |
| Container same feature-worktree status | exit0, clean `## feature-a` |
| Windows main-repository status | exit0, `## main`, existing `?? review-final-correction.md` |
| Windows worktree-add help | includes `--[no-]relative-paths` |
| Container worktree-add help | does not include relative-paths |

The worktree's `.git` contains:

```text
gitdir: /workspace/host-projects/git-isolation/.git/worktrees/git-isolation-feature-a
```

Its Git metadata's `gitdir` backpointer is likewise absolute:
`/workspace/host-projects/git-isolation-feature-a/.git`.
Its `commondir` is `../..`. The absolute `/workspace/...` paths resolve inside
the Linux container, whereas the host fixture lives under
`C:/Users/brennan/Desktop/proj/tmp/scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/projects/`.
Reading the same tracked files from Windows and the container produced identical
SHA256 values:

| File | SHA256 in both namespaces |
| --- | --- |
| README.md | `a04119df3d1d76f1ccf65b125df97cbab1309c5c8d90eda28b069f11cfe43451` |
| record.json | `226ac8c36b46b7e34fac61e9530e6ce72d92f94265ed1c2f4e4540c8c68c3561` |

All status reads used `--no-optional-locks`. Container checks ran only in the
owned idle `orchestration-trial-agent-swarm-coder-1`; its process inventory showed
`tini`, `agent-swarm`, and this diagnostic shell, with no provider child.
No repository, ref, configuration, worktree or Git pointer was modified.

The requested relative-worktree proof requires support in **both** installed
Git versions. Container 2.43 lacks that help capability, so the check stopped
at the required gate. No new probe repository was created. No pointer rewrite,
Git upgrade, dependency installation, model call, auth access or deployment
change occurred. Relative-path operation across these namespaces is **unproven
in this environment**, even though the host version supports the option.

Windows-priority assessment should therefore distinguish access to shared
project files and the main Git repository from host Git operations on these
particular Linux-created linked worktrees. The former passed; the latter failed.
`results.json` preserves the exact versions, statuses, pointers and hashes.
