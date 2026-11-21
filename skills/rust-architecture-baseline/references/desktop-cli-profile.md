# Profile B: Rust Desktop & CLI App (Tauri v2 + Local Store)

Use this profile for native Windows/macOS/Linux utilities, developer tools, system-tray apps, and paired Rust CLIs.

## Recommended Stack Additions

- **Desktop Shell (`desktop-tauri/src-tauri`):** `tauri` v2 (`features = ["tray-icon", "image-png", "image-ico"]`), `tauri-plugin-single-instance`, `tauri-build`.
- **CLI Companion (`crates/<prefix>-cli`):** Shares the exact same `L4 engine` + `L5 integrations` crates and supports `--json` output for scripting and smoke testing.
- **Local Persistence (`crates/<prefix>-store`):**
  - `SessionStore` trait with `JsonFileStore` (atomic write-to-`.tmp` + `fs::rename` for settings/history/audit) or embedded SQLite, plus `MemoryStore` for isolated unit tests.
  - Inject `app.path().app_data_dir()` from the Tauri shell so `L3 store` never imports `tauri`.
- **Network / OS Adapters (`crates/<prefix>-integrations`):**
  - `reqwest` with `default-features = false, features = ["native-tls", "socks"]` avoids requiring `nasm`/`aws-lc-rs` C toolchains on Windows while using the OS certificate store.
  - On Windows, set `.creation_flags(0x0800_0000)` (`CREATE_NO_WINDOW`) on every `tokio::process::Command` so background CLI invocations never flash console windows.
  - Enforce explicit timeouts and byte caps on every subprocess output and HTTP body.

## Tauri v2 Specific Practices

1. **Isolate `#[tauri::command]` macro expansions from `clippy::unreachable`:**
   Tauri's `#[tauri::command]` macro generates hidden IPC dispatch code that triggers `clippy::unreachable`. Keep all workspace lints strict globally and isolate IPC handlers in a tiny wrapper module:
   ```rust
   mod ipc {
       #![allow(clippy::unreachable)]
       // thin wrappers delegating straight to Engine::execute
   }
   ```
   Similarly, keep `#[allow(...)]` for `tauri::generate_context!()` strictly on the `pub fn run()` shell entrypoint.
2. **Prevent white flash on startup:** Set `"backgroundColor"` in `tauri.conf.json` to match your dark canvas surface (e.g., `"#0F0F0F"`).
3. **Embed tray icons at compile time:** Use `include_bytes!("../icons/tray.png")` + `tauri::image::Image::from_bytes(...)` so portable single-`.exe` builds never break from missing relative paths.
4. **Update tray menu items in place:** Hold `MenuItem<Wry>` handles and call `.set_enabled(...)` / `tray.set_tooltip(...)` instead of tearing down the tray menu on every state tick.
5. **Single-instance & close-to-tray:** Focus the existing main window on second launch; intercept `WindowEvent::CloseRequested` to hide the window when `close_to_tray` is enabled and exit cleanly when `Quit` is clicked from the tray menu.
6. **Strict CSP:** Lock `app.security.csp` in `tauri.conf.json` to `'self'` and Tauri IPC origins (`ipc: http://ipc.localhost https://ipc.localhost`).
