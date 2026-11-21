# rust-product-skills

Modular agent skills for taking a new **Rust** product—backend service, CLI, or Tauri v2 desktop app—from problem discovery to a strictly layered, lint-gated implementation with a modern React + TypeScript UI.

Built in the open [agentskills.io](https://agentskills.io) `SKILL.md` format so the same repository works across **Antigravity**, **Claude Code**, **Codex**, **Gemini CLI**, **Cursor**, and **Copilot CLI**.

## Skill Catalog

| Skill | Purpose |
| :--- | :--- |
| [`starting-a-rust-product`](skills/starting-a-rust-product/SKILL.md) | End-to-end lifecycle map and approval gates from raw idea to verified slice |
| [`discovering-product-pain`](skills/discovering-product-pain/SKILL.md) | Concrete problem discovery, scope sizing, anti-goals, and lean core features |
| [`writing-rust-design-docs`](skills/writing-rust-design-docs/SKILL.md) | Decision-labeled design docs (`[user]` vs `[call]`), engine rules `R1..Rn`, and cold-reader builder check |
| [`rust-architecture-baseline`](skills/rust-architecture-baseline/SKILL.md) | Layered Rust edition 2024 workspace (`L0`–`L5`), strict deny lints, `Engine::execute`, `xtask verify`, and Service / Desktop-CLI profiles |
| [`planning-rust-builds`](skills/planning-rust-builds/SKILL.md) | Phased implementation plans, standard first tasks, review focus, and cross-platform / Windows gotchas |
| [`modern-ui-design`](skills/modern-ui-design/SKILL.md) | Brand-neutral modern UI system (Dark-First + Light Mode tokens, hairline glass surfaces, crisp typography, React + Vite + Tailwind v4 + `ts-rs`) |

## Core Engineering Principles

1. **Product pain before scaffolding** — Every product starts from concrete friction and defines anti-goals turned into engine-enforced rules (`R1..Rn`), not UI conventions.
2. **Strict layered Rust workspace (`L0`–`L5`)** — Pure primitives, specs, and domain logic (`L0`–`L2`) never import I/O, async runtimes, or HTTP clients. Persistence lives only in `L3 store`; external network/OS calls live only in `L5 integrations`; orchestration, policy checks, panic isolation, and audit logs live in `L4 engine`.
3. **Mechanically enforced quality (`cargo xtask verify`)** — Automated gates enforce crate layer DAGs, source purity, `ts-rs` TypeScript codegen, strict Clippy lints (`unwrap`, `expect`, `panic`, `as` denied; `unsafe` forbidden), and unit/integration tests.
4. **One core, two app profiles** — The same `L0`–`L5` architecture powers both **Backend Services** (Axum / MCP + Postgres RLS or SQLite) and **Desktop / CLI Apps** (Tauri v2 + local atomic store + native tray).
5. **Brand-neutral modern UI** — Clean dark-first and light-mode token foundations with hairline surfaces, tabular numeric precision, accessible motion, and type-safe contracts generated directly from Rust via `ts-rs`.

## Install

Clone the repository, then link `skills/*` into your agent's skill directory so updates arrive with `git pull`.

### Windows (PowerShell)

```powershell
# Antigravity / Gemini CLI global skills (~/.gemini/config/skills)
.\scripts\install.ps1 -Target antigravity

# Claude Code (~/.claude/skills)
.\scripts\install.ps1 -Target claude

# Codex / cross-agent (~/.agents/skills)
.\scripts\install.ps1 -Target agents

# Project-local workspace (.agents/skills in a target repo)
.\scripts\install.ps1 -Target workspace -WorkspacePath D:\path\to\your-project
```

### macOS / Linux

```bash
# Default: ~/.agents/skills (or pass --target antigravity | claude | agents | workspace)
./scripts/install.sh --target agents
```

### Manual Paths

| Tool | Target Directory |
| :--- | :--- |
| Antigravity / Gemini CLI (global) | `~/.gemini/config/skills/` |
| Antigravity (project workspace) | `<repo>/.agents/skills/` |
| Claude Code (personal) | `~/.claude/skills/` |
| Claude Code (project) | `<repo>/.claude/skills/` |
| Codex / Copilot CLI / multi-tool | `~/.agents/skills/` |

## License

[MIT](LICENSE)
