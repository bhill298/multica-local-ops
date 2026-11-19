> Historical snapshot imported November 18, 2026 from `agent-orchestration-landscape-2026-10-03.md`.
> Current setup/security instructions: [repository guide](../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Local agent orchestration landscape

Research snapshot: **October 3, 2026**.

## Purpose and scope

Evaluate existing applications and frameworks for locally running autonomous development across multiple projects, with a useful interface for monitoring and steering work. The target environment is Windows with installed Codex CLI/native app-server, durable state, and reporting to the user when needed.

The research screened more than 35 repositories and examined documentation, releases, GitHub issues, Hacker News discussions, Reddit reports, and independent commentary. GitHub popularity figures are rounded snapshots, not active-user counts or reliability measurements. The assessment is based on research, not runtime compatibility tests against the user's Codex 0.160.0 installation. Features documented on current `main` may be ahead of packaged releases.

The strongest shortlist is:

1. **Agent Orchestrator:** strongest fit for managing Codex development sessions.
2. **Paperclip:** strongest fit for an agent managing priorities and work across projects.
3. **Maestro:** promising integrated desktop experience with substantial automation.
4. **OpenHands Agent Canvas:** strongest additional browser-based candidate.

There are enough existing capabilities to favor extending an application over starting with a generic agent framework and building the entire interface. A permanent fork is not necessarily required.

## Application comparison

“Value” is a judgment of fit for this use case, rather than a general quality score.

| Project | GitHub stars / forks | Relevant capabilities | Maturity and limitations | Value for this use case |
|---|---:|---|---|---|
| [Agent Orchestrator](https://github.com/Untrivial-ai/agent-orchestrator) | **12.7k / 1.8k** | Local daemon, dashboard, project coordinators, isolated worktrees, Codex native app-server integration, PR/CI feedback | Active, but young: repository began February 2026. Current architecture explicitly addresses session ownership and recovery. Windows support. | **Very high** |
| [Paperclip](https://github.com/paperclipai/paperclip) | **96.7k / 16.4k** | Browser interface, goals, projects, agent assignments, recurring wakeups, budgets, approvals, audit history, plugins | Very active and popular, but only dates to March 2026. Broad orchestration introduces configuration and coordination overhead. | **Very high** |
| [Maestro — RunMaestro](https://github.com/RunMaestro/Maestro) | **3.4k / 365** | Windows desktop app, browser/mobile control, playbooks, autonomous runs, cross-project agent group chats, headless CLI | Smaller community; substantial functionality. Recovery has important boundaries described below. AGPL-3.0. | **High** |
| [OpenHands / Agent Canvas](https://github.com/OpenHands/OpenHands) | **89.9k / 11.9k** | Self-hosted browser dashboard, multiple execution backends, Codex support, scheduled/event-driven automations | Established parent project, but **Canvas itself remains beta**. Historical OpenHands popularity overstates the maturity of this newer interface. | **High** |
| [Emdash](https://github.com/generalaction/emdash) | **5.9k / 622** | Cross-platform interface, native coding CLIs, worktrees, SSH execution, review workflows, scheduled automations | Active development since August 2025. Stronger evidence for improving hands-on development than replacing the project manager. | **High for supervision; medium for autonomy** |
| [Scion](https://github.com/GoogleCloudPlatform/scion) | **1.7k / 271** | Containerized agents, local web interface, agent communication, remote runners and shared infrastructure | Experimental; explicitly not an officially supported Google product. Docker makes it relevant to Windows. | **Medium–high infrastructure candidate** |
| [Gas Town](https://github.com/gastownhall/gastown) / [Gas City](https://github.com/gastownhall/gascity) | **18.2k / 1.7k**; **1.3k / 438** | Persistent tasks and roles, supervisors, work queues, multiple projects; Gas City extracts reusable orchestration machinery | Ambitious, operationally complex, Unix/tmux-oriented. WSL is the practical Windows route. | **High learning value; medium adoption value** |
| [Superset](https://github.com/superset-sh/superset) | **14.9k / 1.3k** | Strong workspace interface, persistent terminals, worktrees, orchestration skills and automation interfaces | Active, but Windows is unavailable; Linux experimental. Current license is Elastic License 2.0. | **Low immediate fit on Windows** |
| [AWS CLI Agent Orchestrator](https://github.com/awslabs/cli-agent-orchestrator) | **1.4k / 285** | Supervisor/worker delegation around existing CLIs | tmux-oriented. Codex integration has terminal-interaction limitations. | **Useful reference; weaker foundation for this setup** |
| [OpenAI Symphony](https://github.com/openai/symphony) | **27.5k / 2.9k** | Issue-driven scheduling, workspace management, Codex execution loop | Engineering preview/reference implementation. Does not provide the complete durable management application described here. | **Excellent reference; incomplete product** |
| [Vibe Kanban](https://github.com/BloopAI/vibe-kanban) | **28.3k / 3.0k** | Task board, worktrees, multiple coding agents, review interface | Company shut down in April; community development continued, including September activity. | **Useful UI reference; higher maintenance uncertainty** |

Vibe Kanban is neither an unchanged commercially maintained product nor simply an abandoned repository. Its [shutdown announcement](https://www.vibekanban.com/blog/shutdown) explains the transition.

## Agent Orchestrator

**The strongest technical match to the existing Codex work.**

Its current architecture documents a local Go daemon with SQLite state, durable conversation identity, controller-generation checks, and detached per-session provider hosts. For Codex, it uses the **installed Codex native app-server**. It explicitly addresses keeping sessions alive across desktop shutdown and reconnecting without launching a second provider process. Those details are particularly relevant to this repo's emphasis on proving ownership before resuming work.

Coordinator continuity is project-scoped, so a higher-level coordinator spanning projects may still require additional work. See the [current implementation status](https://github.com/Untrivial-ai/agent-orchestrator/blob/main/docs/STATUS.md).

The public evidence is less extensive than the feature list: the repository supplied more useful technical evidence than independent accounts of sustained use. A July issue documented lifecycle and ownership failures; it is now closed, so it should inform testing rather than be presented as a current defect. See the [lifecycle issue](https://github.com/Untrivial-ai/agent-orchestrator/issues/3087).

**Assessment:** best first technical evaluation, especially if preserving Codex session behavior matters more than adopting a ready-made organizational model.

## Paperclip

**The closest match to “an agent keeps several projects moving and reports to me.”**

Paperclip supplies much of the product that would otherwise need to be built: goals, assignments, agent roles, work ownership, budgets, history, and a browser interface. Its plugin system supports additional functionality and UI contributions, making a permanent fork potentially unnecessary. See its [repository and extension model](https://github.com/paperclipai/paperclip).

Its current Codex adapter defaults to **ACP**, with a separate classic CLI execution option. That is a different integration contract from directly controlling Codex's native app-server. Neither should be assumed to adopt arbitrary sessions already running outside Paperclip. See the [Codex adapter documentation](https://docs.paperclip.ing/reference/adapters/codex/).

Feedback is mixed in useful ways:

- Users appreciate the task board, responsibilities, and automatic handoffs.
- Others report that agent handoffs and repeated context setup consume enough tokens to undermine the benefit. An October discussion includes a user who got it working on a personal project but was looking for alternatives for that reason. See the [recent user discussion](https://www.reddit.com/r/AiAutomations/comments/1wv1gea/has_anyone_here_actually_used_paperclip_in/).
- Historical hanging-run reports exist, but current releases contain runner, session-continuity, and recovery fixes. An April hang report is not proof that October's release has the same defect. See the [historical report](https://github.com/paperclipai/paperclip/issues/3173) and [current release notes](https://github.com/paperclipai/paperclip/releases/tag/v2026.1001.0).

Some search results confuse the open-source project with third-party hosted Paperclip services. Claims about a hosted service shutting down do not establish that the underlying project is shutting down.

**Assessment:** strongest starting point for the broader management product. Begin with a small, deliberate agent organization rather than numerous managerial roles.

## Maestro

**Deserves more attention than its star count suggests.**

Maestro combines cross-platform operation, autonomous playbooks, group conversations moderated across agents/projects, remote control, and a headless CLI. This covers a substantial portion of the desired experience in one application. See the [Maestro repository](https://github.com/RunMaestro/Maestro).

Its documented quota recovery is materially different from this repo's approach: it resends the original prompt, probes periodically, and **does not preserve pending retries after quitting Maestro**. It also declines to retry certain failures, including agent crashes. Consequently, it is not an established replacement for durable, ownership-proven quota recovery. See the [agent resilience documentation](https://docs.runmaestro.ai/agent-resilience).

Its issue history includes a reported autonomous-run stall after the agent completed work but failed to write its completion signal. That issue is closed; it illustrates why “process alive,” “work completed,” and “completion acknowledged” need separate handling. See the [reported stall](https://github.com/RunMaestro/Maestro/issues/801).

**Assessment:** potentially the best convenient daily interface, but weaker evidence for unattended recovery across shutdowns. Independent long-term reports were comparatively sparse.

## OpenHands Agent Canvas

**Evaluate its current form, separately from the older OpenHands interface.**

Agent Canvas can run external coding agents, including Codex through ACP. It offers local/self-hosted backends and automations for issue implementation, PR review, repository monitoring, and schedules. Some automation bundles use deterministic scripts for polling and deduplication, invoking an agent only where judgment is needed. This is a useful architectural choice. See [Codex/ACP integration](https://docs.openhands.dev/openhands/usage/agent-canvas/acp-agents) and [automation capabilities](https://docs.openhands.dev/openhands/usage/agent-canvas/prebuilt-automations).

The qualification is maturity: feedback about older OpenHands interfaces and coding benchmarks does not validate the new Canvas management experience. Its maintainers describe a transition informed by community interviews and feedback. See the [Canvas transition FAQ](https://github.com/OpenHands/docs/issues/657).

**Assessment:** a serious browser-first contender, particularly if containerized execution is desirable. It deserves a trial alongside Paperclip rather than being dismissed as merely another coding agent.

## Independent feedback and evidence quality

Emdash has some of the clearest firsthand positive reports found in the research: a Hacker News user described productive use over several weeks and rapid fixes to rough edges. The same discussion contains practical concerns about setup, task specification, review, and performance with many tasks. These are anecdotes, but more informative than generic endorsements. See the [Emdash discussion](https://news.ycombinator.com/item?id=47140322).

Gas Town has substantial discussion, but strongly divided opinions. Maggie Appleton's analysis identifies valuable patterns—persistent roles and tasks, disposable sessions, continuous work queues, and merge coordination—while criticizing complexity and the shift of bottlenecks into planning and review. She explicitly says she had not used it seriously, so this is architectural criticism, not a production reliability study. See her [independent analysis](https://maggieappleton.com/gastown).

For building on those ideas, **Gas City is more directly relevant than forking the entire Gas Town application**: it is the reusable orchestration SDK extracted from that work. Its smaller community and tmux assumptions remain tradeoffs. See [Gas City](https://github.com/gastownhall/gascity).

The reviewed sources did **not** supply convincing comparative evidence that a larger hierarchy of agents consistently delivers better completed work per dollar or per hour of human review. That remains something to measure locally.

Evidence should be interpreted carefully:

- Stars and forks measure attention and reuse signals, not reliable unattended execution.
- Founder demonstrations and promotional posts are weaker adoption evidence than detailed firsthand reports.
- Closed historical bugs are useful test cases, not proof of current defects.
- Current documentation establishes intended capabilities, not independently verified behavior.
- Large repositories may inherit popularity from earlier products or architectures.

## Frameworks for a custom component

These supply building blocks rather than a complete development-management application.

| Foundation | GitHub stars | Contribution | Work still required |
|---|---:|---|---|
| [Temporal](https://github.com/temporalio/temporal) | **23.4k** | Mature durable workflows, timers, retries, signals, recovery | Codex process/session integration and development-management UI. More infrastructure to operate. |
| [DBOS TypeScript](https://github.com/dbos-inc/dbos-transact-ts) | **1.4k** | Durable execution inside a TypeScript application | Codex adapter and UI; TypeScript deployment requires PostgreSQL. |
| [Restate](https://github.com/restatedev/restate) | **4.5k** | Durable execution and stateful services | Coding workflow, process supervision, and interface integration. |
| [LangGraph](https://github.com/langchain-ai/langgraph) | **42.7k** | Explicit agent workflow graphs, checkpoints, interrupts | Reliable external Codex lifecycle management and project dashboard. |
| [Mastra](https://github.com/mastra-ai/mastra) / [PydanticAI](https://github.com/pydantic/pydantic-ai) | **28.5k / 20.4k** | Application frameworks for implementing agents and workflows | Much of the actual orchestration product. |
| [CrewAI](https://github.com/crewAIInc/crewAI) / [OpenAI Agents SDK](https://github.com/openai/openai-agents-python) | **59.3k / 29.8k** | Agent roles, tools, delegation and execution primitives | Persistent project scheduling, Codex session ownership, workspaces and management interface. |

**Temporal has the strongest maturity case for durable execution; DBOS is particularly interesting for a smaller TypeScript implementation.** Neither automatically makes an external action execute exactly once: a worker can perform an action and crash before recording its result. The Codex adapter still needs identifiers and reconciliation to avoid duplicate submissions. See [Temporal activity semantics](https://docs.temporal.io/activity-definition) and the [DBOS TypeScript guide](https://docs.dbos.dev/typescript/programming-guide).

Use these as dependencies where needed, rather than fork their engines.

## Other relevant categories

- **OpenClaw and Hermes:** approximately **391k and 251k stars**. Candidates for a persistent personal coordinator and messaging interface. OpenClaw documents a local gateway, dashboard, and interchangeable harness plugins including Codex. Their breadth is attractive for a general assistant, but does not establish a complete coding-project workflow. Sources: [OpenClaw](https://github.com/openclaw/openclaw), [Hermes](https://github.com/NousResearch/hermes-agent).
- **n8n and Windmill:** useful for schedules, webhooks, scripts, notifications, and operational interfaces. They could surround a Codex worker service; the coding-session controller would still need implementation. Sources: [n8n](https://github.com/n8n-io/n8n), [Windmill](https://github.com/windmill-labs/windmill).
- **GSD, BMAD, Spec Kit, and Task Master:** useful sources of planning, decomposition, and validation methodology. They are not substitutes for the persistent service and dashboard. The original GSD repository's archival needs context: development moved to [Open GSD](https://github.com/open-gsd/gsd-core).
- **AutoGen:** despite roughly **61k stars**, it is in maintenance mode and directs new users toward Microsoft Agent Framework. It is not a recommended foundation for a new fork. Source: [maintainer guidance](https://github.com/microsoft/autogen).
- **Conductor:** worth studying for interaction design, but its current offering prominently emphasizes cloud execution, with macOS/iOS clients. It is a weaker match for local Windows operation. Source: [current product](https://www.conductor.build/).
- **Ruflo:** roughly **74k stars**, but the research did not find enough persuasive independent operational evidence to put it ahead of the shortlist. Popularity alone does not justify selecting it as the foundation. Source: [repository](https://github.com/ruvnet/ruflo).

## Recommendation and evaluation criteria

Evaluate **Agent Orchestrator and Paperclip first**, with **Maestro and Canvas** as alternatives. Do not begin a broad fork before checking whether existing configuration, plugins, and adapters can satisfy the requirements.
