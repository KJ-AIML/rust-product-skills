# Modern Component Patterns & Verification Checklist

## 1. Page Anatomy (Desktop Utility / Control Plane)

Keep primary workspace layouts scannable in under two seconds:

1. **Minimal Top Bar:** Product mark + title on the left; a single glass **Status Pill** (connection dot, active state/mode, quick refresh action) on the right. Avoid overcrowded toolbars.
2. **Asymmetric Two-Column Grid (`lg:grid-cols-[minmax(0,1.45fr)_minmax(290px,0.85fr)]`):**
   - **Left Hero Card:** Primary live value (large `font-mono tabular-nums`), top-row utility actions (placed on the eyebrow header row so long values like IPv6 strings never push buttons onto a second line!), 2–3 compact metric tiles, inline policy/warning callouts, and a bottom **Floating Action Dock** with the primary CTA + keyboard shortcut badge (`Ctrl+Enter`).
   - **Right Control Rail:** 2–3 focused cards grouping related controls (connection/mode, safety/destructive toggle, schedule/preferences) with generous `rounded-3xl` corners and clear helper copy.
3. **Full-Width Activity Section:** Clean segmented tabs switching between **History / Events** and **Engine Rules & Audit Log** so operational transparency stays one click away without cluttering the hero view.

## 2. Mandatory UI States

Never ship only the "happy path" state. Design and preview all six:

| State | Visual Pattern |
| :--- | :--- |
| **Boot / Loading** | Centered minimal pill with subtle pulse dot (`Initializing engine…`) |
| **In-Flight Action** | Multi-stage **Phase Stepper** mapping typed backend `PhaseId` steps + live phase label, disabling conflicting controls |
| **Missing Dependency** | Clear onboarding state inside Hero Card with copyable install command and `Check again` button |
| **Policy Blocked** | Tinted warning banner naming the enforced engine rule (e.g., `Rule R1`) and the detected signals; primary action disabled |
| **Destructive Confirmation** | Accessible modal (`radix-ui` Dialog) explaining exact impact before invoking backend |
| **Empty List** | Concise single-line explanation of what will appear once actions run |

## 3. Pre-Release Visual & Code Checklist

- [ ] Types imported exclusively from `src/generated/` (`ts-rs`); zero hand-copied backend interfaces.
- [ ] All numeric metrics, timestamps, ports, and addresses use `font-mono tabular-nums`.
- [ ] Long strings (`IPv6`, paths, UUIDs) tested with `break-all` or `truncate` + `title` tooltip; zero horizontal overflow.
- [ ] Copy actions show transient confirmation (`Copy` → `Copied` with check icon for ~1.4s).
- [ ] Keyboard shortcuts ignore focused `<input>` / `<textarea>` elements.
- [ ] Verified in browser at both desktop (`1280×900`) and narrow (`~768px`) viewports with zero console errors.
