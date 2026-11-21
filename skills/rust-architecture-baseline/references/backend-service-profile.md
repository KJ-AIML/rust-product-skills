# Profile A: Rust Backend Service (Axum + MCP + Postgres / SQLite)

Use this profile for networked APIs, multi-tenant web backends, background workers, and MCP servers.

## Recommended Stack Additions

- **HTTP / MCP Surfaces (`apps/<prefix>-server`):** `axum`, `tower-http`, `rmcp` (if exposing MCP tools), `tracing` + `tracing-subscriber`.
- **Database (`crates/<prefix>-store`):**
  - Multi-tenant services: **Postgres 15+** (`sqlx` with compile-time checked queries, migrations in `crates/<prefix>-store/migrations/`).
  - Single-node / embedded services: **SQLite** (`sqlx` or `rusqlite`) isolated strictly in `L3 store`.
- **External HTTP (`crates/<prefix>-integrations`):** `reqwest` (only crate allowed to import `reqwest`).

## Multi-Tenant Postgres Rules

Apply these when the service holds data for multiple organizations/tenants:

1. **Private `TenantTx` wrapper:** `TenantTx` wraps a `sqlx::Transaction`, keeps the inner transaction private, and executes `SET LOCAL app.tenant_id = $1` upon creation. No raw pool leaks to handlers or commands.
2. **Tenant identity comes only from auth:** Derive `tenant_id` from verified JWT/session/API token claims in middleware, never from request body or path parameters.
3. **Defense-in-depth schema:** Every tenant table includes `tenant_id`, `ENABLE ROW LEVEL SECURITY`, `FORCE ROW LEVEL SECURITY`, composite foreign keys `(tenant_id, target_id)`, and unique indexes leading with `tenant_id`.
4. **Least-privilege DB roles:** Separate `migration_owner` (DDL), `app_runtime` (DML constrained by RLS), and `app_worker` (outbox/background consumer).
5. **Outbox pattern:** Commands write domain rows and outbox event rows inside the same `TenantTx`. A separate worker drains the outbox and calls `L5 integrations` with no transaction open.

## Engine & Surface Hygiene

- **Thin transport adapters:** Axum routes, MCP tool handlers, and CLI subcommands only deserialize inputs, resolve `AuthContext`, call `Engine::execute`, and map typed errors to HTTP status codes or JSON payloads.
- **Test DB guard:** Integration test helpers must parse `DATABASE_URL` with `PgConnectOptions::from_str` (never substring checks) and refuse to run against non-test databases.
- **CI gates:** Add an `xtask rls` gate that parses SQL migrations and verifies every newly created tenant table enables forced RLS (unless explicitly allowlisted with justification).
