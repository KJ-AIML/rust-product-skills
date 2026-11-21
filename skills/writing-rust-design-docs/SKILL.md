---
name: writing-rust-design-docs
description: >-
  Use once product pain and core features are agreed and an ADR / design document is needed before
  planning or coding. Produces a decision-labeled design doc with engine-enforced rules (R1..Rn)
  and runs a cold-reader builder check before handoff.
---

# Writing Rust Design Docs

## Overview

A strong design doc lets an engineer (or fresh agent) plan and build without guessing at high-stakes trade-offs. It does three essential jobs:
1. Explicitly labels **who decided what** (`[user]` vs. `[call]`).
2. Turns every **anti-goal** into a testable **Engine Rule (`R1..Rn`)**, never a vague UI convention.
3. Fixes a concrete **first end-to-end demo** with pass criteria.

Use the template in [references/design-doc-template.md](./references/design-doc-template.md).

## Location

Save as `docs/decisions/ADR-001-<product>-design.md` inside the repository (or `docs/<product>/YYYY-MM-DD-<product>-design.md` before repo creation, then copy into `docs/decisions/ADR-001-<product>-design.md` in Task 1).

## Decision Labels

- **`[user]`** — Explicitly stated by the user and traceable to the conversation.
- **`[call]`** — Chosen by the author/agent as a sensible default; explicitly open to veto.
- **Unlabelled** — Factual explanation or consequence.
- Never promote a `[call]` to `[user]` just because nobody objected yet.

## Required Sections (in Order)

1. **Intent** — Concrete problem statement, who uses it, what it is and is not.
2. **Goals, Non-Goals, and Anti-Goals** — Lead anti-goals with the worst trust-breaking failure.
3. **Core Features (`F1..Fn`)** — Table with `# | Feature | Covers | Does not cover (v1)`, followed by concise behavior notes organized by feature (not by technical layer).
4. **Rules Protecting Anti-Goals (`R1..Rn`)** — Every anti-goal maps to a domain/engine check AND an automated test. Never rely solely on disabling a button in the UI.
5. **Architecture & Baseline Profile** — Declare the runtime profile (`Backend Service` vs. `Desktop / CLI`), crate tree (`L0`–`L5`), surfaces, and any baseline deviations recorded as an ADR section.
6. **Build Order & First Demo** — 2–3 phases with `Builds` and `Done when`. Phase 2 at latest ends with a runnable end-to-end demo.
7. **Carry-Over & Prior Art** — If porting from an existing tool, map `Concept -> New location -> Left behind`.
8. **Extension & Integration Boundaries** — External dependencies isolated as L4 traits implemented in L5.
9. **Left to the Builder** — Low-stakes choices intentionally left unconstrained.
10. **Open Questions** — Only blockers where a wrong guess causes rework.

## Cold-Reader Builder Check (Before Handoff)

Before presenting the design doc for approval, review it from the perspective of a fresh senior Rust engineer (or spawn a read-only review subagent):

> *"Read this design doc as an engineer tasked with creating a build plan from it without asking follow-up questions. List only ambiguities where guessing wrong would cause significant rework, ranked by impact."*

Triage findings into three buckets:
- **Already answered implicitly** → Make it explicit in the doc.
- **Low-risk detail** → Decide it now and tag it `[call]`.
- **Genuine product trade-off** → Surface concisely to the user with the trade-off explained.

Present the updated doc alongside a short numbered summary of the most important `[call]` decisions. Do not attach the implementation plan until the design is approved (unless the user asked for full autonomous execution).
