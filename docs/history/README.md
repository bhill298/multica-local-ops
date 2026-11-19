# Historical setup and testing notes

These 29 reports preserve the evaluation, setup decisions, failures and
interventions that led to the current stock installation. They are historical
records, not instructions to reinstall retired forks or approval brokers.
Use the [current repository guide](../repository-guide.md),
[findings](../findings.md) and [security posture](../security-posture.md)
for the selected configuration and the latest results. The Office source is
now bundled in [tools/office-fixture](../../tools/office-fixture/README.md);
older statements that it is excluded are superseded.

Original directory structure is retained for provenance. Links to preserved
notes and current package files are relative. References to excluded raw
evidence, binaries, credentials, source checkouts, patch exports and generated
deliverables are labeled as unbundled rather than presented as working links.
Credential-like literals are redacted; no runtime profile or private backup
has been copied.

| Preserved note | Original purpose |
| --- | --- |
| [agent-orchestration-eval-report.md](agent-orchestration-eval-report.md) | Orchestrator Evaluation Summary: Agent Orchestrator vs. Paperclip |
| [agent-orchestration-expanded-review-2026-10-23.md](agent-orchestration-expanded-review-2026-10-23.md) | Agy boundary and repository update: November 18, 2026 |
| [agent-orchestration-hands-on-2026-10-24.md](agent-orchestration-hands-on-2026-10-24.md) | Agy boundary and repository update: November 18, 2026 |
| [agent-orchestration-landscape-2026-10-03.md](agent-orchestration-landscape-2026-10-03.md) | Local agent orchestration landscape |
| [agent-orchestration-summary.md](agent-orchestration-summary.md) | Agy boundary and repository update: November 18, 2026 |
| [orchestration-patches-2026-11-14/README.md](orchestration-patches-2026-11-14/README.md) | Multica and Agent Swarm: exact local patch exports |
| [scratch-projects/multica-active-reboot-2026-11-08/RESULT.md](scratch-projects/multica-active-reboot-2026-11-08/RESULT.md) | Active-work reboot result — November 8 |
| [scratch-projects/multica-final-suite-2026-11-08/closure-v5/RESULT.md](scratch-projects/multica-final-suite-2026-11-08/closure-v5/RESULT.md) | Fresh v5 completion regression |
| [scratch-projects/multica-final-suite-2026-11-08/desktop/RESULT.md](scratch-projects/multica-final-suite-2026-11-08/desktop/RESULT.md) | Background Office API acceptance, November 8 |
| [scratch-projects/multica-final-suite-2026-11-08/direct-codex-repro-2026-11-09/RESULT.md](scratch-projects/multica-final-suite-2026-11-08/direct-codex-repro-2026-11-09/RESULT.md) | Direct Codex approval/MXC reproduction — November 9 |
| [scratch-projects/multica-final-suite-2026-11-08/git/RESULT.md](scratch-projects/multica-final-suite-2026-11-08/git/RESULT.md) | Parallel Git worktree and conflict acceptance |
| [scratch-projects/multica-final-suite-2026-11-08/long-run/RESULT.md](scratch-projects/multica-final-suite-2026-11-08/long-run/RESULT.md) | Fresh two-hour acceptance, November 8 |
| [scratch-projects/multica-final-suite-2026-11-08/long-run-v5/RESULT.md](scratch-projects/multica-final-suite-2026-11-08/long-run-v5/RESULT.md) | Clean v5 longer pilot |
| [scratch-projects/multica-final-suite-2026-11-08/permissions/RESULT.md](scratch-projects/multica-final-suite-2026-11-08/permissions/RESULT.md) | Narrow approval and denial acceptance |
| [scratch-projects/multica-final-suite-2026-11-08/policy-investigation-2026-11-09/RESULT.md](scratch-projects/multica-final-suite-2026-11-08/policy-investigation-2026-11-09/RESULT.md) | Codex command rules versus the observed launch failures |
| [scratch-projects/multica-local-reliability/local-reliability/README.md](scratch-projects/multica-local-reliability/local-reliability/README.md) | Local Windows pilot reliability |
| [scratch-projects/multica-minimal-2026-11-14/PLAN.md](scratch-projects/multica-minimal-2026-11-14/PLAN.md) | Multica minimal-maintenance candidate |
| [scratch-projects/multica-minimal-2026-11-14/RESULT.md](scratch-projects/multica-minimal-2026-11-14/RESULT.md) | Multica stock deployment — November 14, 2026 |
| [scratch-projects/multica-pilot-2026-11-06/PLAN.md](scratch-projects/multica-pilot-2026-11-06/PLAN.md) | Multica pilot, 2026-11-06 |
| [scratch-projects/multica-post-reboot-2026-11-08/RESULT.md](scratch-projects/multica-post-reboot-2026-11-08/RESULT.md) | Post-reboot startup and path regression — November 8 |
| [scratch-projects/orchestration-deep-pilots-2026-11-09/firstmate/hc-component-evidence/FINAL-SUMMARY.md](scratch-projects/orchestration-deep-pilots-2026-11-09/firstmate/hc-component-evidence/FINAL-SUMMARY.md) | Firstmate native hc component: final phase-separated result |
| [scratch-projects/orchestration-deep-pilots-2026-11-09/firstmate/RESULT.md](scratch-projects/orchestration-deep-pilots-2026-11-09/firstmate/RESULT.md) | Firstmate and Herdr deep pilot |
| [scratch-projects/orchestration-deep-pilots-2026-11-09/INTERVENTIONS.md](scratch-projects/orchestration-deep-pilots-2026-11-09/INTERVENTIONS.md) | Intervention ledger for the deep pilots |
| [scratch-projects/orchestration-deep-pilots-2026-11-09/STATUS.md](scratch-projects/orchestration-deep-pilots-2026-11-09/STATUS.md) | Deep orchestration pilots — final consolidation |
| [scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/RESULT.md](scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/RESULT.md) | Agent Swarm deep pilot |
| [scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/windows-git-interop/REPORT.md](scratch-projects/orchestration-deep-pilots-2026-11-09/swarm/windows-git-interop/REPORT.md) | Windows/container Git interoperability — bounded read-only check |
| [scratch-projects/orchestration-deep-pilots-2026-11-09/upstream-current/REPORT.md](scratch-projects/orchestration-deep-pilots-2026-11-09/upstream-current/REPORT.md) | Current upstream audit — 2026-11-10 |
| [scratch-projects/orchestration-trials-2026-10-24/firstmate/trial-summary.md](scratch-projects/orchestration-trials-2026-10-24/firstmate/trial-summary.md) | Bounded Firstmate orchestration trial |
| [scratch-projects/swarm-current-pilot-2026-11-12/LIVE-RESUME.md](scratch-projects/swarm-current-pilot-2026-11-12/LIVE-RESUME.md) | ALL PLANNED SWARM TESTS COMPLETE — 2026-11-14T16:03:19.407673+00:00 |

Raw results from the November 18 reboot/provider/Agy boundary tests remain
excluded. Their complete conclusions, conditions and coverage limits are
preserved in the current findings and security documents. The small Agy
probe source/method and Office source/protocol/artifact checks are included.
