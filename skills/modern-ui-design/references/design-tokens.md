# Brand-Neutral Design Tokens (Dark-First + Light Mode)

Drop this semantic foundation into `src/index.css` (Tailwind CSS v4) and customize only the `--accent-*` variables per product.

## 1. Semantic Token Layers

```css
@import "tailwindcss";

@custom-variant dark (&:is(.dark *));

:root {
  color-scheme: light;
  /* Light mode neutral surfaces */
  --surface-canvas: #fafafb;
  --surface-elevated: rgba(255, 255, 255, 0.92);
  --surface-subtle: rgba(15, 15, 18, 0.035);
  --surface-dock: rgba(255, 255, 255, 0.84);

  /* Text */
  --text-primary: #111114;
  --text-secondary: rgba(17, 17, 20, 0.68);
  --text-muted: rgba(17, 17, 20, 0.48);

  /* Hairlines */
  --border-hairline: rgba(17, 17, 20, 0.09);
  --border-strong: rgba(17, 17, 20, 0.16);
  --glint-top: rgba(255, 255, 255, 0.9);

  /* Product accents (customize per product) */
  --accent-primary: #111114;
  --accent-primary-fg: #ffffff;
  --status-ok: #0d9488;
  --status-info: #2563eb;
  --status-warn: #d97706;
  --status-danger: #dc2626;
}

.dark {
  color-scheme: dark;
  /* Dark-first obsidian neutral surfaces */
  --surface-canvas: #0f0f0f;
  --surface-elevated: rgba(21, 21, 24, 0.88);
  --surface-subtle: rgba(255, 255, 255, 0.035);
  --surface-dock: rgba(26, 26, 30, 0.78);

  /* Text */
  --text-primary: #ffffff;
  --text-secondary: rgba(255, 255, 255, 0.72);
  --text-muted: rgba(255, 255, 255, 0.46);

  /* Hairlines */
  --border-hairline: rgba(255, 255, 255, 0.085);
  --border-strong: rgba(255, 255, 255, 0.16);
  --glint-top: rgba(255, 255, 255, 0.06);

  /* Clean pastel-luminous accents for dark obsidian */
  --accent-primary: #ffffff;
  --accent-primary-fg: #0f0f0f;
  --status-ok: #6fd8ee;
  --status-info: #9fc8ff;
  --status-warn: #ffc48a;
  --status-danger: #ff9f88;
}
```

## 2. Elevation & Glass Utilities

```css
.surface-card {
  background: var(--surface-elevated);
  border: 1px solid var(--border-hairline);
  box-shadow:
    inset 0 1px 0 var(--glint-top),
    0 24px 64px -24px rgba(0, 0, 0, 0.35);
  backdrop-filter: blur(20px);
}

.surface-dock {
  background: var(--surface-dock);
  border: 1px solid var(--border-strong);
  box-shadow:
    inset 0 1px 0 var(--glint-top),
    0 12px 32px -12px rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(24px);
}
```

## 3. Contrast & Accessibility Rules

- Primary text vs. card background: target **≥ 10:1** (`#FFFFFF` on `#151518`, `#111114` on `#FFFFFF`).
- Secondary text: never drop below **4.5:1** WCAG AA (`rgba(255,255,255,0.65+)` on `#151518`).
- Reserve low-opacity text (`0.45`) only for non-critical metadata (kicker labels, shortcut hints).
- Always include visible keyboard focus rings (`focus-visible:ring-2`) and `@media (prefers-reduced-motion: reduce)` overrides.
