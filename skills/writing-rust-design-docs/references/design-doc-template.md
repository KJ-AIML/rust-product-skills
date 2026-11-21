# ADR-001: <Product Name> Design

- **Status:** Draft | Accepted
- **Date:** YYYY-MM-DD
- **Runtime Profile:** `[call]` Backend Service (Axum + Postgres/SQLite) | Desktop & CLI (Tauri v2 + Local Store)

## 1. Intent

Describe the real-world friction this product removes, who experiences it, and why a dedicated Rust product fits better than a shell script or existing tool.

## 2. Goals, Non-Goals, and Anti-Goals

### Goals
- `[user]` ...
- `[call]` ...

### Non-Goals (v1)
- ...

### Anti-Goals (Failure Conditions)
- **AG1:** `[user]` ... *(e.g., never silently destroy user credentials or managed enterprise config)*
- **AG2:** `[call]` ... *(e.g., never crash the desktop shell or API server on malformed external output)*

## 3. Core Features

| # | Feature | Covers (v1) | Does not cover (v1) |
| :--- | :--- | :--- | :--- |
| F1 | ... | ... | ... |
| F2 | ... | ... | ... |

### Feature Behavior
- **F1:** ...
- **F2:** ...

## 4. Engine-Enforced Rules (`R1..Rn`)

| Rule | Protects | Enforcement Layer | Verification Test |
| :--- | :--- | :--- | :--- |
| `R1` | AG1 | `L2 domain` + `L4 engine` pre-execution check | `engine_tests::r1_blocks_...` |
| `R2` | AG2 | Workspace deny lints + `CatchUnwind` in `Engine::execute` | `engine_tests::r2_isolates_panic` |

## 5. Architecture & Stack

Follows `rust-architecture-baseline`:

```text
L0  crates/<prefix>-primitives    Pure value types & enums
L1  crates/<prefix>-spec          CommandId, AccessPolicy, DTOs, ts-rs bindings
L2  crates/<prefix>-domain        Pure parsers, validators, state transitions, policy checks
L3  crates/<prefix>-store         Persistence boundary only (Postgres/SQLite/atomic JSON)
L4  crates/<prefix>-engine        Port traits, CommandRegistry, Engine::execute, audit trail
L5  crates/<prefix>-integrations  External HTTP, subprocesses, OS APIs
App apps/...                      HTTP/MCP server, CLI binary, and/or Tauri v2 desktop app
QA  xtask/                        Automated gates: layers, purity, codegen, lints, tests
```

### Baseline Deviations (if any)
- State any relaxed rule, what the rule originally protected, and how the product preserves that guarantee.

## 6. Build Order & First End-to-End Demo

- **Phase 1 — Foundation & Gates:** Workspace scaffold, `xtask verify`, L0–L2 domain tests, L3 store.
  - *Done when:* `cargo run -p xtask -- verify` passes green.
- **Phase 2 — Vertical Slice Demo:** L4 engine (`Engine::execute` + `R1..Rn`), L5 adapters, runnable CLI/API/Desktop slice.
  - *Done when:* Automated end-to-end test and manual smoke run complete cleanly.

## 7. Carry-Over & Prior Art (Optional)

| Concept | Destination in New Repo | Notes / Left Behind |
| :--- | :--- | :--- |
| ... | ... | ... |

## 8. Integration Ports

- `PortA` (L4 trait) → `AdapterA` (L5 implementation)

## 9. Left to the Builder

- Internal helper naming, CSS micro-spacing, non-breaking test fixture formatting.

## 10. Open Questions

- *(None, or list only blocking trade-offs.)*
