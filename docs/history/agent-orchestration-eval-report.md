> Historical snapshot imported November 18, 2026 from `agent-orchestration-eval-report.md`.
> Current setup/security instructions: [repository guide](../repository-guide.md).
> Older claims may be superseded. Raw evidence and generated outputs are not bundled.

# Orchestrator Evaluation Summary: Agent Orchestrator vs. Paperclip

Based on deep architectural research and our hands-on testing with Codex on Windows, here is the complete breakdown of the two top candidates.

---

## 1. Agent Orchestrator (AO)
*The Lightweight Execution Engine*

Agent Orchestrator is a Go-based daemon with an Electron/React UI. It focuses strictly on robust, session-level task execution.

### Setup
*   **Requirements:** Go 1.27.1, Node.js >= 20.19.0.
*   **Experience:** The Go backend compiles cleanly on Windows. However, building the Electron frontend from source on Windows hit hurdles due to pathing issues with the downloaded `electron.exe` binary.
*   **Infrastructure:** Very lightweight. Uses a pure-Go SQLite driver (no CGO required) and stores state locally in `~/.ao/data/ao.db`.

### Usage
*   Runs isolated git worktrees per session.
*   The UI provides a dual view: a Chat interface and an interactive TUI (using `xterm.js` and Windows ConPTY).

### The Good
*   **Best-in-class Codex Integration:** Connects directly to the native `codex app-server` via JSON-RPC, perfectly handling the Windows `.cmd` shims.
*   **Bulletproof Recovery:** Spawns `codex` as a detached, persistent host process. If the AO daemon or UI crashes, Codex keeps running. When AO restarts, it reconnects to the live session seamlessly.
*   **Strict State Management:** Uses SQLite generation-checks to prevent "split-brain" issues where old processes corrupt new sessions.
*   **100% Native:** Zero reliance on WSL or Docker.

### The Bad
*   **Scope:** It is only a task runner/coordinator. It lacks higher-level abstractions like organizational charts, budgets, goals, and recurring tasks.
*   **Windows Source Build:** The Electron build process requires manual path wrangling to get running.

---

## 2. Paperclip
*The Virtual Company*

Paperclip is a massive Node.js/PostgreSQL application that models an entire company's workflow, complete with agent roles, reporting lines, and budgets.

### Setup
*   **Requirements:** Node.js 24, pnpm.
*   **Experience:** Building from source on Windows is hostile—it requires a Rust toolchain (Cargo) for its native runner and Windows Developer Mode to allow symlinking.
*   **The Save:** The officially supported `npx paperclipai@latest onboard` path works perfectly. It downloads the pre-built application and provisions an embedded PostgreSQL database automatically, bypassing all build headaches.

### Usage
*   Everything is managed via a polished web UI (port 3100).
*   Tasks are tracked as Kanban issues and assigned to agents (like `agent-kun`).
*   Agents have roles (`engineer`, `ceo`), budgets (with hard stops), and can be triggered by recurring cron routines or webhooks.

### The Good
*   **The Complete Package:** Solves the exact problem of "an agent managing priorities across projects." It handles goal cascading, cross-project assignments, and human-in-the-loop approvals out of the box.
*   **Zero-Config Infrastructure:** The `npx` command sets up embedded Postgres, meaning no Docker or external database is required.
*   **Extensibility:** Features an out-of-process plugin architecture allowing you to write extensions as standard npm packages without forking the core codebase.

### The Bad
*   **Heavyweight:** It is a large application with substantial coordination overhead compared to AO.
*   **Codex via ACP:** Defaults to using the Agent Client Protocol rather than direct app-server execution. This historically caused token-explosion issues with large tool catalogs, though Paperclip mitigates this with custom patches and dynamic search tools.
*   **Windows Limitations:** Local filesystem/network sandboxing relies on Linux `bwrap` (Bubblewrap), which isn't supported on Windows.

---

## Final Conclusion

**Paperclip** is the definitive winner for your use case.

While Agent Orchestrator is a masterclass in process durability and native Codex execution, it leaves you to build the entire organizational/management layer yourself.

Paperclip gives you the polished, multi-project "virtual company" you want immediately. The fact that the `npx` setup worked flawlessly, connected to Codex, and successfully executed the Node.js test task confirms it is the right tool for the job.
