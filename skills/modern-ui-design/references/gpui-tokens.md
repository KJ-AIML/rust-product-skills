# Brand-Neutral GPUI Design Tokens & Popover Patterns (Dark-First + Light Mode)

Use this reference alongside [`design-tokens.md`](./design-tokens.md) and [`component-patterns.md`](./component-patterns.md) when building a **Profile C (Native GPUI Desktop)** interface. It maps the exact same semantic obsidian dark / crisp light tokens into pure Rust (`gpui::Hsla`) with zero `as` casts and zero `unsafe`.

## 1. Semantic `Palette` Struct (`apps/<prefix>-desktop/src/theme.rs`)

Customize only the accent/status slots per product while preserving the neutral surface ladder and ≥ 10:1 primary contrast:

```rust
use gpui::{Hsla, rgba};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ThemeMode {
    Dark,
    Light,
}

#[derive(Debug, Clone, Copy)]
pub struct Palette {
    pub canvas: Hsla,
    pub elevated: Hsla,
    pub subtle: Hsla,
    pub dock: Hsla,
    pub active_card: Hsla,
    pub text_primary: Hsla,
    pub text_secondary: Hsla,
    pub text_muted: Hsla,
    pub border_hairline: Hsla,
    pub border_strong: Hsla,
    pub accent_primary: Hsla,
    pub accent_primary_fg: Hsla,
    pub status_ok: Hsla,
    pub status_info: Hsla,
    pub status_warn: Hsla,
    pub status_danger: Hsla,
    pub track_bg: Hsla,
    pub scrim: Hsla,
}

impl Palette {
    pub fn for_mode(mode: ThemeMode) -> Self {
        match mode {
            ThemeMode::Dark => Self::dark(),
            ThemeMode::Light => Self::light(),
        }
    }

    /// Dark-first neutral obsidian (`#0F0F0F` canvas, `#151518` cards).
    pub fn dark() -> Self {
        Self {
            canvas: hex_rgba(0x0F0F_0FFF),
            elevated: hex_rgba(0x1515_18FF),
            subtle: hex_rgba(0xFFFF_FF0A),
            dock: hex_rgba(0x1A1A_1EFF),
            active_card: hex_rgba(0x1E1F_25FF),
            text_primary: hex_rgba(0xFFFF_FFFF),
            text_secondary: hex_rgba(0xFFFF_FFB8),
            text_muted: hex_rgba(0xFFFF_FF75),
            border_hairline: hex_rgba(0xFFFF_FF16),
            border_strong: hex_rgba(0xFFFF_FF29),
            accent_primary: hex_rgba(0xFFFF_FFFF),
            accent_primary_fg: hex_rgba(0x0F0F_0FFF),
            status_ok: hex_rgba(0x6FD8_EEFF),
            status_info: hex_rgba(0x9FC8_FFFF),
            status_warn: hex_rgba(0xFFC4_8AFF),
            status_danger: hex_rgba(0xFF9F_88FF),
            track_bg: hex_rgba(0xFFFF_FF14),
            scrim: hex_rgba(0x0000_00A8),
        }
    }

    /// Crisp Light Mode (`#FAFAFB` canvas, `#FFFFFF` cards).
    pub fn light() -> Self {
        Self {
            canvas: hex_rgba(0xFAFA_FBFF),
            elevated: hex_rgba(0xFFFF_FFFF),
            subtle: hex_rgba(0x0F0F_120A),
            dock: hex_rgba(0xF3F4_F6FF),
            active_card: hex_rgba(0xF1F5_F9FF),
            text_primary: hex_rgba(0x1111_14FF),
            text_secondary: hex_rgba(0x1111_14AD),
            text_muted: hex_rgba(0x1111_147A),
            border_hairline: hex_rgba(0x1111_1417),
            border_strong: hex_rgba(0x1111_1429),
            accent_primary: hex_rgba(0x1111_14FF),
            accent_primary_fg: hex_rgba(0xFFFF_FFFF),
            status_ok: hex_rgba(0x0D94_88FF),
            status_info: hex_rgba(0x2563_EBFF),
            status_warn: hex_rgba(0xD977_06FF),
            status_danger: hex_rgba(0xDC26_26FF),
            track_bg: hex_rgba(0x1111_1414),
            scrim: hex_rgba(0x0F11_1666),
        }
    }
}

fn hex_rgba(val: u32) -> Hsla {
    rgba(val).into()
}
```

> **Clippy note:** Call `rgba(val).into()` directly—do not wrap it in `Rgba::from(rgba(val))`, which trips `clippy::useless_conversion` under `-D warnings`.

## 2. Compact Menu-Bar / Top-Navbar Popover Anatomy

When building a menu-bar or system-tray utility (`~460–500px` wide × `620–680px` tall):

1. **Top Nav Bar (`44–46px`):** Product mark + title on the left (add `~58px` left padding on macOS when `appears_transparent: true` to clear traffic lights), a compact 3-segment tab pill in the center (**Primary** | **Activity** | **Rules**), and lightweight **Theme** + **Sync** pill controls on the right.
2. **Hero Command Card:** Live session status dot + active entity name + one-click primary pill CTA (`bg(p.accent_primary)`, `text_color(p.accent_primary_fg)`), separated by a `1px` hairline from a 3-column compact telemetry strip.
3. **Scrollable Item List (`overflow_y_scroll`):** Focused cards with `1px` hairlines (`border_strong` on active items), compact inline progress bars, and clear non-cluttered action pills.
4. **Status Footer (`34px`):** Live phase/status text on the left; recovery/utility links (`Restore`, `Open folder ↗`) on the right.
5. **In-Panel Overlay Modals (`absolute().inset_0().bg(p.scrim)`):** Render Add/Edit forms and Destructive Confirmations inside the GPUI root so they stay anchored to the popover and support `Escape` to dismiss.

## 3. Safe Percentage Helper (`clippy::as_conversions = "deny"`)

Convert `f64` domain percentages (`0.0..=100.0`) into GPUI `relative(...)` `f32` fractions (`0.0..=1.0`) without `as` casts:

```rust
pub fn pct_to_relative(pct: f64) -> f32 {
    let clamped = pct.clamp(0.0, 100.0);
    let mut tenths: u16 = 0;
    for step in 0..=1000_u16 {
        if f64::from(step) <= clamped * 10.0 {
            tenths = step;
        } else {
            break;
        }
    }
    f32::from(tenths) / 1000.0
}
```

## 4. Pre-Release GPUI Checklist

- [ ] Both `ThemeMode::Dark` and `ThemeMode::Light` toggled and visually checked for contrast.
- [ ] All six mandatory UI states (`Loading`, `In-Flight`, `Missing Dep`, `Policy Blocked`, `Destructive Confirm`, `Empty`) implemented and wired to typed `L1`/`L4` states.
- [ ] `Escape` dismisses modals; keyboard shortcuts/typing never mutate unrelated views when a modal is closed.
- [ ] Zero `unsafe`, zero `.unwrap()`/`.expect()`/`panic!`, and zero `as` casts verified by `cargo run -p xtask -- verify`.
- [ ] Native binary builds cleanly on both macOS (`runtime_shaders`) and Windows (`windows_subsystem = "windows"`).
