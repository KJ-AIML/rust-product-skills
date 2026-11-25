# Profile C: Native GPUI Desktop & CLI App (macOS + Windows)

Use this profile for native, GPU-accelerated (Metal on macOS, DirectX on Windows) Rust desktop utilities, menu-bar / system-tray command panels, and paired Rust CLIs where zero-WebView startup latency, low memory footprint, and 100% pure-Rust compile-time UI contracts matter.

## Recommended Stack Additions

- **Native Desktop Shell (`apps/<prefix>-desktop`):**
  - `gpui` (with `features = ["runtime_shaders"]`) for GPU-accelerated rendering, layout, focus, and keyboard/pointer events.
  - `tray-icon` (`default-features = false`) for cross-platform **macOS Menu Bar (`NSStatusItem`)** and **Windows System Tray** icons + native context menus (re-exports `tray_icon::menu` without pulling Linux GTK3).
  - Embedded multi-thread `tokio` runtime (`worker_threads(2)`) bridged off the GPUI UI thread so async `Engine::execute` calls never block rendering.
- **CLI Companion (`apps/<prefix>-cli`):** Shares the exact same `L4 engine` + `L5 integrations` crates and supports `--json` output for scripting, CI checks, and live smoke testing.
- **Local Persistence (`crates/<prefix>-store`):**
  - `StateStore` trait with `JsonFileStore` (atomic `.tmp` + `sync_all` + `fs::rename` with corrupt-file recovery) or embedded SQLite, plus `MemoryStore` for isolated unit tests.
  - Inject the platform app-data directory (`dirs::data_local_dir()` + `<PREFIX>_DATA_DIR` override) from the app shell so `L3 store` never imports `gpui` or `dirs`.
- **Cross-Platform OS Adapters (`crates/<prefix>-integrations`):**
  - Prefer zero-`unsafe` cross-platform crates (`sysinfo` with `default-features = false, features = ["system"]`, `std::os::unix::fs::symlink` on Unix, `cmd.exe /c mklink /J` on Windows) so `unsafe_code = "forbid"` holds across **all** layers including `L5` and `apps/*`.
  - On Windows, set `#![cfg_attr(target_os = "windows", windows_subsystem = "windows")]` on the desktop binary entrypoint and `.creation_flags(0x0800_0000)` (`CREATE_NO_WINDOW`) on every background helper `Command` (`cmd.exe`, `taskkill.exe`, `powershell.exe`).
  - Enforce explicit timeouts and byte caps on every file reader, subprocess output, and HTTP body.

## Architectural Contract (Zero `ts-rs` Drift)

Unlike Profiles A and B (which cross a Rust ↔ TypeScript boundary via `ts-rs`), Profile C consumes `L0 primitives` and `L1 spec` Rust types **directly at compile time**:

- **Zero hand-duplicated DTOs:** Views render directly from `L1` snapshot structs and dispatch exclusively through `L4 Engine::execute(CommandRequest, CallerContext)`.
- **`xtask verify` gates:** Run `layers`, `purity`, `lints`, and `tests` (skip `ts-rs` codegen when no TypeScript frontend exists).
- **Extended purity rules:** Forbid `gpui`, `tray-icon`, `sysinfo`, and `dirs` across `L0`–`L4`, and forbid `gpui` / `tray-icon` inside `L5 integrations` so OS adapters remain reusable by `apps/<prefix>-cli`.

## GPUI + Menu Bar / Tray Best Practices

1. **Enable `gpui` `runtime_shaders` for frictionless macOS builds:**
   Newer Xcode installations separate the offline Metal compiler into an optional downloadable component (`xcodebuild -downloadComponent MetalToolchain`). Adding `features = ["runtime_shaders"]` on `gpui` compiles Metal shaders via Apple's built-in Metal framework at runtime so `cargo build` and CI succeed out of the box on macOS (and acts as a no-op on Windows):
   ```toml
   gpui = { version = "0.2.2", features = ["runtime_shaders"] }
   ```
2. **Initialize `TrayIcon` strictly on the main UI thread inside `Application::new().run`:**
   On macOS, Cocoa requires `NSStatusItem` creation *after* `NSApplication` is initialized on the main thread. Create `TrayController` inside `Application::new().run(|cx| { ... })` before opening the root window, and keep ownership inside the root view entity so the icon stays alive for the app lifetime.
3. **Embed or procedurally generate tray icons in memory:**
   Generate crisp RGBA bytes in memory (or `include_bytes!`) so portable binaries never break from missing relative asset paths. On macOS, use `.with_icon_templated(icon)` (avoiding deprecated `.with_icon_as_template(true)`) so the icon adapts automatically to light/dark menu bars. `with_icon_templated` only exists under `#[cfg(target_os = "macos")]`, so gate that call and use `.with_icon(icon)` on Windows, or the Windows build fails.
4. **Poll tray events asynchronously without blocking the render loop:**
   Use `cx.spawn_in(window, async move |this, cx| ...)` with a lightweight timer (`~80–100ms`) draining `TrayIconEvent::receiver().try_recv()` and `MenuEvent::receiver().try_recv()`. Only rebuild the native tray menu when the state signature actually changes.
5. **Bridge `tokio` work off the GPUI UI thread:**
   Never call blocking I/O or `rt.block_on(...)` inside `Render::render`, click listeners, or GPUI executor tasks (a `block_on` in `cx.background_executor().spawn(...)` holds a GPUI worker thread for the whole command). Spawn the command on the `tokio` runtime and await its `JoinHandle` from a GPUI task, then update view state and call `cx.notify()`:
   ```rust
   let job = rt.spawn(async move { engine.execute(request, caller).await });
   cx.spawn(async move |this, cx| {
       let outcome = job.await; // Result<_, tokio::task::JoinError>
       this.update(cx, |view, cx| {
           view.apply(outcome);
           cx.notify();
       })
   })
   .detach();
   ```
6. **Top Menu Bar Popover & Keyboard Input Reliability:**
   For interactive panels with text inputs (Add/Edit sheets, search bars) across both macOS and Windows, prefer `WindowKind::Normal` with `TitlebarOptions { appears_transparent: true, .. }` and compact popover bounds (e.g., `480 × 640`), reserving left padding (`~58px`) on macOS for traffic lights. This avoids `WindowKind::PopUp` focus quirks on macOS while keeping a sleek floating top-navbar feel.
7. **Respect `clippy::as_conversions = "deny"` in GPUI layouts:**
   GPUI's `px(...)` and `relative(...)` take `f32`, while domain metrics often use `f64` or `u64`. Never cast with `val as f32`; use safe integer-scaled helpers (`u16` / `u32` → `f32::from(...)`) and keep `.into_any_element()` on heterogeneous conditional branches (`Div` vs `Stateful<Div>`).
8. **Honor `modern-ui-design` in GPUI:**
   Implement the semantic Dark-First Obsidian + Light Mode palette in a dedicated `theme.rs` module (see [`gpui-tokens.md`](../../modern-ui-design/references/gpui-tokens.md)) and wire all six mandatory UI states (`Loading`, `In-Flight`, `Missing Dependency`, `Policy Blocked`, `Destructive Confirmation`, `Empty`).

## Verification Matrix (macOS + Windows)

Pair `cargo run -p xtask -- verify` in CI across both `macos-latest` and `windows-latest`, and verify locally with:

```sh
# Mechanical gates (layers, purity, clippy -D warnings, unit/engine tests)
cargo run -p xtask -- verify

# Headless CLI smoke test against live OS adapters
cargo run -p <prefix>-cli -- status --json

# Native GPUI desktop build & manual launch
cargo build -p <prefix>-desktop
```
