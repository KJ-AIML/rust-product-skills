---
name: rust-architecture-baseline
description: >-
  Use when designing, scaffolding, planning, or coding any Rust product backend, CLI, Tauri v2,
  or native GPUI desktop app: defines the layered L0-L5 Cargo workspace, strict deny lints,
  Engine::execute command pipeline, xtask verification gates, and Backend Service, Tauri v2
  Desktop-CLI, and Native GPUI Desktop profiles.
---

# Rust Architecture Baseline

## Overview

Every Rust product built with this baseline shares one strictly layered workspace, one set of crash-prevention lints, and one automated verification gate (`cargo run -p xtask -- verify`). **Baseline invariants carry across every product; domain features and storage engines are chosen per product.**

Break a baseline rule only with an explicit ADR documenting what the rule protects and how the product preserves that guarantee.

## Default Stack

| Area | Baseline Choice |
| :--- | :--- |
| Language | Rust **Edition 2024**, pinned in `rust-toolchain.toml` (`clippy` + `rustfmt` included) |
| Workspace | Strict layered DAG: `L0 primitives` → `L1 spec` → `L2 domain` → `L3 store` → `L4 engine` → `L5 integrations` → `apps/*` + `xtask` |
| API / Dispatch | Single `CommandRegistry` + `Engine::execute` running in a fixed pipeline (policy check → panic boundary → handler → store/audit) |
| Persistence | Profile-dependent, isolated solely in `L3 store`: **Postgres + forced RLS** (multi-tenant services) OR **SQLite / atomic JSON** (single-user desktop/local tools) |
| External I/O | Isolated solely in `L5 integrations` implementing `L4 engine` port traits (`reqwest`, subprocesses, OS APIs) |
| UI Contract | **Profiles A/B:** React + Vite + Tailwind v4 consuming `ts-rs` bindings from `L0`/`L1` · **Profile C:** Native GPUI (`apps/<prefix>-desktop`) consuming `L0`/`L1` Rust types directly at compile time |
| Quality Gates | Workspace lints deny `unwrap`, `expect`, `panic`, `todo`, `unimplemented`, `unreachable`, `dbg`, `as`; forbid `unsafe`. Enforced by `cargo run -p xtask -- verify`. |

## Layered Crate Rules (The DAG)

| Layer | Crate Role | Allowed Internal Deps | Strictly Forbidden |
| :--- | :--- | :--- | :--- |
| **L0** | `<prefix>-primitives` | None | Any async runtime, `std::fs`, `std::process`, `std::net`, `sqlx`, `reqwest`, `tauri`, `gpui`, `tray-icon` |
| **L1** | `<prefix>-spec` | L0 | Same as L0 (pure contracts, DTOs, `CommandId`, `AccessPolicy`, optional `ts-rs` exports) |
| **L2** | `<prefix>-domain` | L0, L1 | Same as L0 (pure parsers, validators, state transitions, policy checks) |
| **L3** | `<prefix>-store` | L0, L1, L2 | `L4`, `L5`, `reqwest`, `std::process`, `tauri`, `gpui`, `tray-icon` (persistence only) |
| **L4** | `<prefix>-engine` | L0, L1, L2, L3 | `L5`, `reqwest`, `std::fs`, `std::process`, `tauri`, `gpui`, `tray-icon` (defines port traits; never imports adapters) |
| **L5** | `<prefix>-integrations` | L0, L4 | `L3`, `tauri`, `gpui`, `tray-icon` (implements L4 port traits using HTTP, OS APIs, or subprocesses) |
| **App** | `apps/server`, `apps/cli`, `apps/<prefix>-desktop`, `desktop/src-tauri` | L0–L5 | Putting business logic or raw SQL directly in route/IPC/UI handlers |

## Core Baseline Invariants

| Rule | What It Protects |
| :--- | :--- |
| **Pure `L0`–`L2` core** | Parsers, business rules, and domain policies stay 100% deterministic and testable in milliseconds with zero mocks or I/O |
| **Persistence only in `L3 store`** | Queries, migrations, and atomic file writes are audited in one crate; no stray connection pool or ad-hoc `fs::write` bypasses invariants |
| **External I/O only in `L5 integrations`** | Network calls, subprocesses, and OS APIs sit behind L4 traits so the entire engine runs under deterministic fake rigs in tests |
| **Fixed `Engine::execute` pipeline** | Every command declares an `AccessPolicy` in `CommandRegistry`; access is default-deny and checked before execution |
| **Engine owns the audit trail** | Individual commands never write their own audit rows; `Engine::execute` records redacted outcomes centrally |
| **Never crash** | Workspace deny lints (`unwrap_used`, `expect_used`, `panic`, `as_conversions`, `unsafe_code = "forbid"`) + `catch_unwind` future boundary inside `Engine::execute` |
| **No I/O inside an open DB transaction** | In database-backed services, commands emit outbox events or split into `begin` (tx 1) → L5 port call (no tx) → `finish` (tx 2) |
| **Automated `xtask verify` gates** | Layer violations, purity leaks, stale TypeScript types, and lint regressions fail fast locally and in CI |

## Choosing a Runtime Profile

Read the reference guide matching your product before scaffolding:
- **Workspace & `xtask verify` setup (required for all projects):** [references/workspace-scaffold.md](./references/workspace-scaffold.md)
- **Profile A — Multi-tenant / API Backend Service (Axum + MCP + Postgres RLS / SQLite):** [references/backend-service-profile.md](./references/backend-service-profile.md)
- **Profile B — Local Desktop & CLI App (Tauri v2 + Atomic Local Store / SQLite + Tray):** [references/desktop-cli-profile.md](./references/desktop-cli-profile.md)
- **Profile C — Native GPUI Desktop & CLI App (GPUI + Menu Bar / Tray + Atomic Local Store):** [references/gpui-desktop-profile.md](./references/gpui-desktop-profile.md)

## Breaking a Baseline Rule (ADR Pattern)

When a product genuinely cannot satisfy a rule verbatim (for example, an AI proxy whose core operation *is* a live upstream HTTP request rather than an async outbox event), write a short ADR that preserves the underlying safety property:

1. **Begin** (short tx 1): authenticate, validate quota/policy, insert a `pending` record.
2. **Call external port** (L5, no transaction open): invoke upstream provider with strict timeout and byte cap.
3. **Finish** (short tx 2): record usage/outcome on success, failure, and timeout alike.
4. **Reconcile**: run a periodic sweep for rows stuck in `pending`.
