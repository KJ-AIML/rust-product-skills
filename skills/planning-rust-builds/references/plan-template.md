# Implementation Plan: <Product Name> (Phase 1–2)

- **Design Doc:** `docs/decisions/ADR-001-<product>-design.md`
- **Profile:** Backend Service | Desktop & CLI (Tauri v2) | Native GPUI Desktop & CLI

## Global Constraints
- Rust Edition 2024, toolchain pinned in `rust-toolchain.toml`
- Workspace lints: deny `unwrap_used`, `expect_used`, `panic`, `todo`, `unimplemented`, `unreachable`, `dbg_macro`, `as_conversions`; forbid `unsafe_code`
- Verification gate: `cargo run -p xtask -- verify`

## Plan-Level Calls (`[call]`)
- Repo / package name: `<name>`
- Crate prefix: `<prefix>-*`
- Env var prefix: `<PREFIX>_*`
- Local dev port(s): `<port>`

## Review Focus (Top 5 Failure Modes)

| # | Real-World Failure Mode | Owning Task | Guard / Test |
| :--- | :--- | :--- | :--- |
| 1 | ... | Task N | `test_name` |
| 2 | ... | Task N | `test_name` |
| 3 | ... | Task N | `test_name` |
| 4 | ... | Task N | `test_name` |
| 5 | ... | Task N | `test_name` |

## Tasks

### Task 1: Workspace Scaffold & `xtask verify`
- **Files:** `Cargo.toml`, `rust-toolchain.toml`, `clippy.toml`, `xtask/src/main.rs`
- **Produces:** Working `layers`, `purity`, `codegen`, `lints`, and `tests` gates
- **Verify:** `cargo run -p xtask -- verify`

### Task 2: `L0 primitives`, `L1 spec`, and `L2 domain`
- **Files:** `crates/<prefix>-primitives/`, `crates/<prefix>-spec/`, `crates/<prefix>-domain/`
- **Produces:** Pure types, `ts-rs` bindings, domain parsers, and policy checks (`R1..Rn`)
- **Verify:** `cargo test -p <prefix>-domain` + `cargo run -p xtask -- codegen`

### Task 3: `L3 store`
- **Files:** `crates/<prefix>-store/`
- **Produces:** Persistence trait, concrete store, `MemoryStore`, round-trip tests
- **Verify:** `cargo test -p <prefix>-store`

### Task 4: `L4 engine`
- **Files:** `crates/<prefix>-engine/`
- **Produces:** Port traits, `CommandRegistry`, `Engine::execute` (`CatchUnwind` + audit log), scripted mock tests
- **Verify:** `cargo test -p <prefix>-engine`

### Task 5: `L5 integrations` & App Shell
- **Files:** `crates/<prefix>-integrations/`, `apps/...` or `desktop-tauri/src-tauri/`
- **Produces:** Concrete OS/HTTP adapters and thin transport/IPC wiring
- **Verify:** `cargo run -p xtask -- verify`

### Task 6: Frontend or Native GPUI UI & End-to-End Verification (if applicable)
- **Files:** `desktop-tauri/src/` (or `web/src/`) **or** `apps/<prefix>-desktop/src/` (GPUI)
- **Produces:** React + Vite + Tailwind v4 UI + preview bridge, **or** Native GPUI views + Menu Bar / Tray controller
- **Verify:** `npm run typecheck && npm run build` + browser inspection **or** `cargo run -p xtask -- verify` + `cargo build -p <prefix>-desktop` + CLI smoke run
