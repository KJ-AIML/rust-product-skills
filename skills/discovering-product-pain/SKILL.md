---
name: discovering-product-pain
description: >-
  Use before writing a design doc or scaffolding code when a user proposes a new product, states
  the problem as a technical solution ("a proxy", "a dashboard", "a sync engine"), or needs help
  narrowing scope into a lean v1 core with explicit anti-goals.
---

# Discovering Product Pain

## Overview

A durable product is defined by the concrete friction a real person hits on a real day, not by its crate graph. Your job is to uncover that moment, play it back clearly, establish what would make the product a failure (anti-goals), and agree on a lean v1 core.

## Conversation Discipline

- **Plain words first.** Use short sentences and the user's vocabulary. Avoid architectural jargon (`port`, `outbox`, `RLS`, `DAG`) until the problem is clear.
- **One focused question at a time.** Ask a single crisp question per turn when clarifying open-ended intent. Only offer a short menu of concrete options when the user asks for suggestions or seems stuck.
- **Mark your guesses explicitly.** Build on the user's exact words and clearly flag anything you inferred as a proposal open to veto.
- **Skip cleanly when delegated.** If the user already supplied a clear specification, reference repo, or explicit autonomous mandate, summarize your understanding briefly and move straight into design.

## Discovery Loop

Cover these checkpoints naturally (not as a rigid questionnaire):

1. **Find a real moment.** Ask what breaks today, who waits on whom, or what currently gets done manually or copy-pasted.
2. **Play it back.** Summarize in ~150–200 words: what the user stated vs. what you guessed. Ask *"What is wrong or missing?"*
3. **Size the product with anchors.** Place the target between two concrete examples (e.g., *"simpler than enterprise suite X, more structured than one-off script Y"*) and let the user adjust the boundary.
4. **Capture the top anti-goal.** Ask *"What would make you immediately distrust or abandon this tool even if the happy path worked?"* Turn every answer into an engine-enforced rule in the design doc.
5. **Mine existing context (if any).** If replacing or extending an older repo/script, inspect it and list: `concept | what it does | keep / adapt / drop`.
6. **Propose a lean v1 core.** Present 4–8 numbered capabilities (`F1`–`F8`), each with **Covers** and **Does not cover (v1)**, plus explicit **Non-goals**.
7. **Choose the runtime profile.** Confirm whether the product fits:
   - **Profile A — Backend Service** (HTTP/MCP API + Postgres/SQLite)
   - **Profile B — Desktop & CLI (Tauri v2)** (Tauri v2 + React + local atomic store / SQLite)
   - **Profile C — Native GPUI Desktop & CLI** (Pure Rust GPUI + Menu Bar / Tray + local atomic store / SQLite)
   - **Hybrid** (shared Rust core powering multiple shells)

## Done When

All five are confirmed:
- The concrete pain and primary user
- The lean v1 feature list (`F1`–`Fn`)
- Explicit non-goals
- The top anti-goal(s)
- The target runtime profile (Service / Desktop / CLI)

Then proceed to `writing-rust-design-docs`.

## Common Mistakes

| Mistake | Fix |
| :--- | :--- |
| Opening with crate layouts and database engines | Understand the workflow and failure modes first |
| Asking 4 multi-part questions in one wall of text | Ask one sharp question, or use a compact 2–3 choice decision prompt |
| Treating a feature name as the problem | Ask what breaks without it today |
| Over-scoping v1 into an enterprise platform | Size to the leanest end-to-end vertical slice; push extras to v2 |
