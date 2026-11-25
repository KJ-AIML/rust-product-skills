---
name: modern-ui-design
description: >-
  Use when designing or building a modern React + Vite + Tailwind v4 frontend (Tauri v2 / web)
  or a native GPUI desktop interface for a Rust product. Provides a brand-neutral Dark-First +
  Light Mode token system, hairline glass surface hierarchy, crisp typography, accessible motion,
  and Rust contract integration (ts-rs or direct L0/L1 GPUI types).
---

# Modern UI Design System (Brand-Neutral Base)

## Overview

A clean, modern interface earns trust through restraint: crisp contrast, clear visual hierarchy, predictable interactive states, and zero visual clutter. This skill defines a **brand-neutral** design foundation—adapt the accent palette and emblem to each product's own identity rather than locking in any fixed brand.

Read the detailed references before styling components:
- **Color, Surface & Typography Tokens (Web / Tauri — Dark + Light):** [references/design-tokens.md](./references/design-tokens.md)
- **Native GPUI Rust Tokens & Popover Patterns (Profile C — Dark + Light):** [references/gpui-tokens.md](./references/gpui-tokens.md)
- **Layout, Component States & Verification Checklist:** [references/component-patterns.md](./references/component-patterns.md)

## Visual Philosophy

1. **Dark-First, Dual-Theme Ready:** Default to a deep, neutral obsidian canvas (`#0F0F0F` / `oklch` neutral dark) rather than muddy navy-grey, with a first-class crisp Light Mode token set (`#FAFAFB` canvas, `#FFFFFF` elevated cards) toggled cleanly via `.dark` / `prefers-color-scheme`.
2. **Surface Hierarchy via Hairlines & Luminance:** Separate layers with `1px` low-opacity hairline borders (`rgba(255,255,255,0.08)` in dark; `rgba(15,15,18,0.08)` in light) and subtle top inner highlights (`inset 0 1px 0`)—not heavy drop shadows or cluttered card borders.
3. **Restrained Glass & Ambient Accents:** Use `backdrop-filter: blur(...)` selectively on floating command docks, status pills, and modals so typography always stays crisp. If adding an ambient background texture (subtle radial glow or low-opacity dot-matrix wave), anchor it away from primary text and react calmly to active state.
4. **Crisp Typography & Tabular Figures:**
   - Pair a geometric sans (`Geist` / `Inter` / `Outfit`) for UI headings and body with a sharp monospace (`IBM Plex Mono` / `JetBrains Mono`) using `tabular-nums` for IPs, IDs, ports, latencies, quotas, and timestamps.
   - Tighten display headings (`tracking-tight`), keep body text readable (`leading-relaxed`), and reserve uppercase micro-labels (`text-[11px] tracking-[0.18em]`) strictly for section kickers.
5. **Motion with Restraint:** Prefer crisp `150ms` hover/press feedback and meaningful progress indicators (multi-stage phase steppers) over decorative bounce animations. Always honor `@media (prefers-reduced-motion: reduce)`.

## Architecture & Rust Contract Rules

- **Web / Tauri v2 Stack (Profiles A & B):** React 19 + TypeScript (`strict: true`) + Vite + Tailwind CSS v4 (`@tailwindcss/vite`) + accessible primitives (`radix-ui`) + `lucide-react` icons.
  - **Single Source of Truth (`ts-rs`):** Never hand-duplicate backend structs in TypeScript. Import generated types directly from `src/generated/` produced by `cargo run -p xtask -- codegen`.
  - **Thin Bridge + Preview Fallback:** Abstract backend communication behind a tiny `Bridge` interface (`createTauriBridge` / `createHttpBridge` + `createPreviewBridge`). When opened in a standard browser without the native shell or backend, render an explicit **Preview Mode** banner with scenario links (`ready`, `empty`, `missing-dep`, `blocked`, `error`) so every visual state can be verified cleanly.
- **Native GPUI Stack (Profile C):** Pure Rust `gpui` + `tray-icon` consuming `L0`/`L1` Rust structs directly at compile time (zero `ts-rs` step) and dispatching all mutations through `L4 Engine::execute` off the UI thread. Follow [`references/gpui-tokens.md`](./references/gpui-tokens.md) for the matching Dark-First Obsidian + Light Mode `Palette` and compact menu-bar popover anatomy.
- **Safety UX Matches Engine Rules:** Destructive actions require an explicit confirmation dialog; blocked states explain *which* rule blocked them and why—never silently swallow clicks.

## Visual Verification Gate

Before marking any UI task done:
- **Web / Tauri (Profiles A & B):**
  1. Run `tsc --noEmit` and `vite build` with zero errors.
  2. Inspect the live rendered app in a browser (desktop width ~`1280x900` AND narrow/compact width ~`768px`) checking zero console errors, no wrapping collisions on long values, clear contrast on all states, and interactive transitions.
- **Native GPUI (Profile C):**
  1. Run `cargo run -p xtask -- verify` and `cargo build -p <prefix>-desktop` with zero warnings (`unsafe_code = "forbid"`, deny `as_conversions`/`unwrap_used`).
  2. Verify Dark & Light theme toggle, all six mandatory UI states (`Loading`, `In-Flight`, `Missing Dep`, `Policy Blocked`, `Destructive Confirm`, `Empty`), keyboard modal input (`Tab`/`Enter`/`Esc`), and menu bar / tray toggle on target OS.
