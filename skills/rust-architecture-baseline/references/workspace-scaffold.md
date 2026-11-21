# Workspace Scaffold & `xtask verify` Reference

Use this layout when initializing any new Rust product workspace.

## 1. Toolchain & Clippy Config

### `rust-toolchain.toml`
Pin the toolchain version explicitly so local builds and CI match:

```toml
[toolchain]
channel = "1.96.0"
components = ["clippy", "rustfmt"]
```

### `clippy.toml`
Disallow panicking helpers even in tests (return `Result<(), String>` or use `let Some(...) = ... else { ... }` in test code):

```toml
avoid-breaking-exported-api = false
allow-unwrap-in-tests = false
allow-expect-in-tests = false
allow-panic-in-tests = false
```

## 2. Root `Cargo.toml`

```toml
[workspace]
resolver = "3"
members = [
  "crates/<prefix>-primitives",
  "crates/<prefix>-spec",
  "crates/<prefix>-domain",
  "crates/<prefix>-store",
  "crates/<prefix>-engine",
  "crates/<prefix>-integrations",
  "xtask",
]

[workspace.package]
version = "0.1.0"
edition = "2024"
license = "MIT"
rust-version = "1.96"

[workspace.lints.rust]
unsafe_code = "forbid"
unused_must_use = "deny"

[workspace.lints.clippy]
unwrap_used = "deny"
expect_used = "deny"
panic = "deny"
todo = "deny"
unimplemented = "deny"
unreachable = "deny"
dbg_macro = "deny"
as_conversions = "deny"
```

Every member crate inherits lints via:

```toml
[lints]
workspace = true
```

## 3. Safe `catch_unwind` Future Boundary (Zero `unsafe`)

Inside `L4 engine`, wrap `Engine::execute` dispatch in a small `Unpin` wrapper around `Pin<Box<dyn Future<Output = T> + Send>>`:

```rust
struct CatchUnwindFut<F>(F);

impl<F: Future + Unpin> Future for CatchUnwindFut<F> {
    type Output = Result<F::Output, ()>;

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        let fut = Pin::new(&mut self.0);
        match std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| fut.poll(cx))) {
            Ok(Poll::Ready(out)) => Poll::Ready(Ok(out)),
            Ok(Poll::Pending) => Poll::Pending,
            Err(_) => Poll::Ready(Err(())),
        }
    }
}
```

## 4. `xtask` Verification Gates (`cargo run -p xtask -- verify`)

Include an `xtask/` binary crate depending on `cargo_metadata` that runs five gates in order:

1. **`layers`** — Parses `cargo metadata` and asserts each crate's direct workspace and external dependencies obey the `L0`–`L5` table.
2. **`purity`** — Walks `.rs` files in `L0`–`L4` and rejects forbidden tokens (`std::fs`, `std::process`, `std::net`, `tokio::`, `reqwest::`, `sqlx::`, `tauri::`) outside their permitted layers. Normalize path separators (`\` → `/`) so checks behave identically on Windows and Linux.
3. **`codegen`** — Runs `ts-rs` export tests on `L0`/`L1` with `TS_RS_EXPORT_DIR` pointing at `<frontend>/src/generated` and generates a deterministic `index.ts` barrel.
   - Tip: annotate `u64`/`i64` fields with `#[ts(type = "number")]` when JSON transports them as JS numbers, and mark partial patch fields with `#[ts(optional)]`.
4. **`lints`** — Runs `cargo clippy --workspace --all-targets -- -D warnings`.
5. **`tests`** — Runs `cargo test --workspace` (and for Postgres profiles, an `rls` gate verifying tenant policies on every migration).
