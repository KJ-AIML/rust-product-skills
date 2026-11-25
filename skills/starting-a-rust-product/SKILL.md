---
name: starting-a-rust-product
description: >-
  Use when a user proposes a new Rust product, backend service, CLI tool, Tauri v2, or native GPUI
  desktop application ("new product", "new service", "build a Rust version", "let's start") and
  needs a structured path from problem discovery to a verified, layered implementation.
---

# Starting a Rust Product

## Overview

Products share a proven Rust architectural baseline and quality gates, not a feature set. Every product starts from its own concrete user pain and makes its own product-level calls.

## Lifecycle Map

| Stage | Goal | Skill | Output | Gate |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Discover the real pain | `discovering-product-pain` | Plain-language playback, lean core, top anti-goal | User confirms playback |
| 2 | Write the design doc | `writing-rust-design-docs` | `docs/decisions/ADR-001-<product>-design.md` | User approves design & rules `R1..Rn` |
| 3 | Plan the first build slice | `planning-rust-builds` | `docs/plans/YYYY-MM-DD-<product>-p1-plan.md` | User approves plan & execution mode |
| 4 | Scaffold & build core | `rust-architecture-baseline` | Layered Cargo workspace (`L0`–`L5`), `xtask verify`, first vertical slice | `cargo run -p xtask -- verify` passes |
| 5 | Craft the UI (if applicable) | `modern-ui-design` | React + Vite + Tailwind v4 UI (`ts-rs`) **or** Native GPUI desktop view (`gpui-tokens.md`) | Visual check & build/typecheck pass |

## Gate Rules

- **One gate at a time.** Do not send the design doc and implementation plan in the same message; scope corrections during design review invalidate a premature plan.
- **No premature scaffolding.** Do not initialize crates or install dependencies before the design and plan are agreed—unless the user explicitly grants autonomous execution ("build it end to end, make the calls yourself").
- **Autonomous fast-track.** When the user explicitly delegates all decisions, still follow the same internal order (record assumptions & rules `R1..Rn` in an ADR, scaffold `L0`–`L5` + `xtask verify`, implement vertical slice, verify visually and mechanically) and summarize every key call at the end.
- **Baseline vs. product decisions.** Carry over architectural invariants (layering, purity, deny lints, panic boundaries, engine-owned audit). Never copy another product's domain assumptions.

## Red Flags

| Thought | Reality |
| :--- | :--- |
| "Same Rust stack, so I can scaffold immediately" | The stack is shared; the problem, anti-goals, and storage profile are not. Clarify the pain first. |
| "Sending ADR + plan together saves time" | Scope shifts during ADR review waste the entire plan. Keep gates separate unless explicitly told to run end to end. |
| "It's a small local utility, skip architecture gates" | Layer drift and `.unwrap()` panics creep in fastest on small tools. `L0`–`L5` + `xtask` takes minutes to set up and pays off immediately. |
| "User said 'go write the doc', so the design is approved" | That approves drafting the document, not its contents. Wait for review before planning. |
