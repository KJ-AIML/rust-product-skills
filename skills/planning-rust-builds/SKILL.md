---
name: planning-rust-builds
description: >-
  Use when a Rust product design doc is approved and an implementation plan is needed, or when
  scaffolding a layered Rust workspace, CI, xtask verification gates, and first vertical slice.
---

# Planning Rust Builds

## Overview

Turn an approved design doc (`ADR-001`) into a concrete, verifiable task sequence where each task names its exact files, interfaces, verification command, and failure modes. Use the template in [references/plan-template.md](./references/plan-template.md).

## Planning Scope

- Cover **Phase 1 and Phase 2** only—never write a sprawling 80-task roadmap upfront.
- Phase 2 must end with an automated end-to-end test and a runnable vertical slice demo.

## Required Plan Header

Every build plan begins with four short blocks:
1. **Global Constraints:** Pinned Rust toolchain, edition 2024, workspace deny lints, storage profile (`Postgres + RLS` vs. `SQLite / Atomic JSON`), and engine rules `R1..Rn`.
2. **Plan-Level Decisions (`[call]`):** Concrete naming choices (repo name, crate prefix, env var prefix, dev ports, bundle ID) surfaced so the user can veto early.
3. **Review Focus (Top 5 Failure Modes):** The five real-world bugs most likely to bite this product, each paired with the exact task & test that guards it.
4. **Verification Command:** The single command (`cargo run -p xtask -- verify` + frontend typecheck/build) that defines green.

## Standard Task Order

Follow the dependency DAG bottom-up so every task compiles and passes tests immediately:

1. **Workspace Scaffold:** Root `Cargo.toml`, `rust-toolchain.toml`, `clippy.toml`, `.gitattributes`, `.gitignore`, `ADR-001` copied to `docs/decisions/`.
2. **`xtask verify` Harness:** Implement `layers`, `purity`, `codegen`, `lints`, and `tests` gates before writing feature code.
3. **`L0 primitives` + `L1 spec`:** Value types, `CommandId`, `AccessPolicy`, DTOs, `ts-rs` export annotations.
4. **`L2 domain`:** Pure parsers, validators, rule enforcement (`R1..Rn`), and deterministic unit tests.
5. **`L3 store`:** Persistence trait + concrete adapter (`Postgres`/`SQLite`/`JsonFileStore`) + `MemoryStore` + round-trip tests (plus `rls` gate for multi-tenant Postgres).
6. **`L4 engine`:** Port traits, `CommandRegistry`, `Engine::execute` (`CatchUnwind` + centralized audit log), and scripted mock-rig tests covering happy paths, retries, panics, and every anti-goal rule.
7. **`L5 integrations`:** Concrete external adapters (HTTP/SOCKS, subprocesses, OS APIs) with timeouts and output size caps.
8. **App Shell(s):** Thin HTTP/MCP server, CLI binary, and/or Tauri v2 desktop app wiring L0–L5.
9. **Frontend UI (if applicable):** React + Vite + Tailwind v4 consuming `src/generated/` (`ts-rs`) + browser preview bridge + visual verification.
10. **CI & Release Verification:** End-to-end smoke check, release bundle check, and final `cargo run -p xtask -- verify`.

## Common Cross-Platform & Rust 2024 Gotchas

| Symptom | Root Cause & Fix |
| :--- | :--- |
| `expected identifier, found reserved keyword 'gen'` | `gen` is a reserved keyword in Rust Edition 2024. Use `epoch`, `generation`, or `rev`. |
| `clippy::collapsible-if` fails under `-D warnings` | Edition 2024 enables `let`-chains. Collapse nested `if` + `if let` blocks cleanly. |
| `clippy::unreachable` on `#[tauri::command]` | Isolate thin Tauri IPC wrappers inside `mod ipc { #![allow(clippy::unreachable)] ... }`. |
| Console window flashes on Windows GUI app | Set `.creation_flags(0x0800_0000)` (`CREATE_NO_WINDOW`) on `tokio::process::Command` under `#[cfg(windows)]`. |
| `dlltool` / `getrandom` or `aws-lc-rs` / `nasm` link error on Windows | Use `x86_64-pc-windows-msvc` target and prefer `reqwest` `native-tls` (Schannel) on Windows when C/ASM toolchains aren't guaranteed. |
| `xtask` gate passes on Linux, fails on Windows | Normalize all paths with `.replace('\\', "/")` inside `xtask`. |
| Shell/SQL scripts break after Git checkout | Enforce `*.sh`, `*.sql`, `*.rs`, `*.toml` as `text eol=lf` in `.gitattributes`. |
| `ts-rs` exports `u64`/`i64` as `bigint` in TS | Annotate JSON-number fields with `#[ts(type = "number")]` and patch fields with `#[ts(optional)]`. |
