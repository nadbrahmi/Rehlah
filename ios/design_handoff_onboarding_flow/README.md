# Handoff: Rehlah — Coordinator Onboarding Tool

> **Audience:** A developer using Claude Code to deploy the coordinator-facing patient onboarding tool to the live Rehlah website (`docs/care-team/`) and wire it to the Flutter patient app.

---

## TL;DR for Claude Code

1. The Rehlah website is **statically hosted from the `docs/` folder** (GitHub Pages convention). Marketing site at `docs/index.html`, care-team landing page at `docs/care-team/index.html.html` (note the doubled extension — likely a deploy artifact).
2. Add the coordinator tool as a new page: **`docs/care-team/onboarding/index.html`**.
3. Use the prototype in `design/Rehlah Onboarding.html` as the visual + behavioral spec — recreate it in vanilla HTML/CSS/JS to match the rest of the `docs/` site (no React build step in this repo).
4. Align token values with the **existing care-team page** (`repo_context/care-team-existing.html`), not the prototype's slightly-different palette. Diffs noted below.
5. Link to it from:
   - The marketing site nav ("Care teams" → onboarding tool, gated by sign-in)
   - The existing care-team landing page primary CTA

The Flutter app integration (invite-code activation → meds pre-load) is **out of scope for this handoff** — it's the next milestone. For now, the tool persists to whatever backend the Rehlah team designates (Firebase / Supabase / custom API). If no backend is wired yet, ship with `localStorage` so the demo works end-to-end at the hospital.

---

## Repo Layout (relevant parts)

```
rehlah/
├── docs/                          ← GitHub Pages root
│   ├── index.html                 ← Marketing landing page
│   ├── care-team/
│   │   └── index.html.html        ← Existing care-team landing page (rename to index.html when touched)
│   └── app/                       ← Compiled Flutter web build (do not touch)
├── lib/                           ← Flutter source
│   └── features/
│       ├── onboarding/            ← Patient-side onboarding (the receiving end of the invite code)
│       └── care/
│           ├── medications/       ← Where pre-loaded meds appear in patient app
│           ├── appointments/
│           ├── labs/
│           └── hub/
└── ...
```

The coordinator tool is a **separate web app** from the Flutter patient app. They communicate only via:
- Backend writes (coordinator creates patient record + meds list)
- Backend reads (Flutter app pulls record by invite code on activation)

---

## About the Design Files

`design/Rehlah Onboarding.html` is a **single-file design reference** — final colors, typography, copy, validation rules, microinteractions. The recommended path for this codebase (which is plain HTML+CSS+JS in `docs/`) is to **port the prototype into 1–3 cleanly-organized files** in `docs/care-team/onboarding/` rather than trying to introduce a build pipeline:

```
docs/care-team/onboarding/
├── index.html        ← Markup + screen routing
├── styles.css        ← Lift the prototype's <style> block
└── app.js            ← Lift the prototype's <script> block; replace generateInvite stub with a real backend call
```

If the team prefers, you can keep it as one file matching the existing `index.html.html` pattern.

---

## Fidelity

**High-fidelity (hifi).** Pixel-perfect, with one exception — **align tokens with the existing care-team page**, see "Token Reconciliation" below.

---

## Token Reconciliation

The prototype uses warm-paper backgrounds and slightly different purples than the live site. The live `docs/` site is the source of truth — use its values, not the prototype's.

| Token | Prototype | **Live site (use this)** | Notes |
|---|---|---|---|
| `--p` | `#7B5CC4` | `#7B5CC4` | ✅ matches |
| `--pd` | `#5C3FA8` | **`#5B3A9C`** | use site value |
| `--pl` | `#F0E9FB` | **`#EDE8F8`** | use site value |
| `--bg` | `#FAF9F7` (warm) | **`#F5F2FC` (cool, on care-team page)** / `#FAFAF9` (on marketing) | Use **`#F5F2FC`** for the coordinator tool — it's care-team adjacent |
| `--sf` | `#FFFFFF` | `#FFFFFF` | ✅ matches |
| `--brd` | `#E8E2D6` (warm) | **`rgba(123,92,196,0.13)`** | site uses translucent purple borders |
| Body font | DM Sans | **Inter** (on care-team), DM Sans (on marketing) | The coordinator tool sits inside `/care-team/`, so use **Inter** to stay consistent with the parent page. Keep Fraunces for h1 italics — both pages already load it. |

**Implication:** the prototype's "warm paper" feel becomes "soft purple-tinted" — same purple primary, but the surrounding chrome reads cooler. Update `--bg`, `--sf2`, `--brd` to match. Leave the validation/error palette alone (red/orange) — it's chromatic and doesn't conflict.

Reconciled tokens to drop in:
```css
:root {
  --p:    #7B5CC4;
  --pd:   #5B3A9C;
  --pl:   #EDE8F8;
  --pm:   rgba(123,92,196,0.25);

  --bg:   #F5F2FC;
  --bg2:  #EDE8F8;
  --sf:   #FFFFFF;
  --sf2:  #F5F2FC;

  --brd:  rgba(123,92,196,0.13);
  --brd2: rgba(123,92,196,0.22);

  --t1:   #2A2040;
  --t2:   #6858A0;
  --t3:   #B8A8D8;

  --ok:   #3DB87A;   --okl:  #EAF8F0;   --okd:  #1F7D4E;
  --warn: #C49030;   --warnl:#FBF4E0;   --warnd:#8C6418;
  --err:  #E05050;   --errl: #FFF5F5;   --errd: #C03030;

  --r:    14px;
  --r-sm: 9px;
  --r-pill: 999px;
}
```

**Fonts** (already loaded on the care-team page — reuse the existing `<link>`):
```html
<link href="https://fonts.googleapis.com/css2?family=Almarai:wght@300;400;700;800&family=Inter:wght@300;400;500;600;700&family=Fraunces:ital,opsz,wght@0,9..144,300;0,9..144,400;0,9..144,600;0,9..144,700;1,9..144,300;1,9..144,400&display=swap" rel="stylesheet">
```

---

## Screens

(Same flow as the prototype — see `design/Rehlah Onboarding.html` for the source of truth. Section anchors inside that file: search for `═══ DASHBOARD ═══`, `═══ STEP 1`, etc.)

1. **Dashboard** — patient list + KPI tiles + "Enroll new patient" CTA
2. **Step 1 — Identity** — name (with `dir="auto"` for Arabic auto-RTL), DOB, UAE mobile, email, cancer type/stage/subtype
3. **Step 2 — Protocol** — protocol grid → cycle details → meds (editable) → care-team routing
4. **Step 3 — Review** — read-only summary with per-card "Edit" links
5. **Step 4 — Invite** — generated code, SMS preview, copy/enroll-another/view-all actions

---

## Validation Rules

`Continue` buttons run client-side validation; `Edit` links in Step 3 bypass it (intentional jump-back).

| Step | Field | Rule | Error message |
|---|---|---|---|
| 1 | patient-name | Non-empty | "This field is required" |
| 1 | patient-dob | Non-empty | "This field is required" |
| 1 | patient-phone | Non-empty + 9 digits starting with `5` | "Enter a UAE mobile starting with 5 (e.g. 50 123 4567)" |
| 1 | cancer-type | Non-empty | "This field is required" |
| 2 | protocol | Selected | "Please select a treatment protocol" (orange banner around grid) |
| 2 | meds | ≥1 confirmed | "Confirm at least one medication" (orange banner above meds list) |
| 2 | cycle-start | Non-empty | "This field is required" |
| 2 | appt-date | Non-empty | "This field is required" |
| 2 | onco-email | Non-empty + contains `@` | "This field is required" / "Enter a valid email" |

**Visual treatment:**
- Field-level: red border `#E05050`, light-red bg `#FFF5F5`, soft red ring `0 0 0 4px rgba(224,80,80,0.10)`, 0.3s `shake-x`, inline error hint replaces the regular hint.
- Card-level (protocol grid, meds list): orange banner — bg `#FEF0E6`, border `#E09060`, text `#9A5020`, icon `#C0651A`.
- On submit with errors: smooth-scroll to first error, focus the input, red toast at bottom.
- Errors clear on `oninput` / `onchange` per-field via `clearError(this)`.

**Phone normalization (live, on input):**
- Strip `+971` / `00971` / leading `0` if pasted.
- Keep digits only, cap at 9.
- Pretty-format as `50 123 4567`.

---

## Backend Integration Plan

The prototype mocks all data. Replace these stubs:

| Function | Current behavior | Production behavior |
|---|---|---|
| `generateInvite()` | Builds `${initials}-${4 random digits}` client-side | POST to `/api/patients` → server returns canonical code, persists patient record, queues SMS |
| `resendInvite(name, phone)` | Toast only | POST to `/api/patients/{id}/resend` → re-trigger SMS with same code |
| Patient list on dashboard | Hardcoded HTML | GET `/api/patients?coordinatorId={me}` → render |
| Sidebar "Reports" / "Activity" | Toast "Coming in v1.1" | Leave as-is for v1 |
| Med list seeding | Static `protocols` object in JS | Same — protocols are clinical, not user data; ship the static map |

**Auth:** the coordinator must be authenticated. Use whatever the rest of `docs/` uses (likely a Firebase Auth or NextAuth-equivalent). If nothing is wired, gate `/care-team/onboarding/` behind a simple sign-in page that issues a session cookie.

**Patient record schema** (suggested):
```ts
{
  id: string,                  // UUID
  inviteCode: string,          // "NAD-7291", unique, expires in 14 days
  status: 'pending' | 'active' | 'completed',
  identity: {
    name: string,              // unicode-safe
    dob: string,               // ISO date
    phone: string,             // E.164 +9715XXXXXXXX
    email?: string,
    cancerType: string,
    cancerStage?: string,
    cancerSubtype?: string,
  },
  protocol: {
    key: 'AC-21'|'Taxol-W'|'Carbo-T'|'CMF',
    cycleNum: number,
    cycleStart: string,        // ISO
    apptDate: string,          // ISO — drives 48h-pre-visit pipeline
    meds: Med[],               // post-edit, the persisted list
    oncoEmail: string,
    coordEmail?: string,
  },
  createdAt, updatedAt, createdBy,
}

type Med = {
  name: string, dose: string, freq: string,
  route: 'Oral'|'IV push'|'IV infusion'|'Subcutaneous'|'Intramuscular'|'Topical',
  checked: boolean,            // confirmed by coordinator → seeded into Flutter daily tracker
}
```

**Flutter side** (next milestone, not this handoff): on invite-code activation in `lib/features/onboarding/presentation/screens/`, fetch the record, hydrate `lib/features/care/medications/` with the `meds[]` list. The patient never enters this data themselves.

---

## Linking In

After deploying:

1. **Care-team landing page** (`docs/care-team/index.html.html` → rename to `index.html`):
   - Primary CTA "Enroll a patient" → `/care-team/onboarding/`
   - Add to nav links

2. **Marketing site** (`docs/index.html`):
   - Existing "For Care Teams" link → `/care-team/`
   - From `/care-team/`, the user gets to onboarding. No direct link from marketing → onboarding (gated).

3. **Filename cleanup:** rename `docs/care-team/index.html.html` → `docs/care-team/index.html`. The doubled extension is a bug; GitHub Pages serves it but it breaks pretty URLs.

---

## Microinteractions (lift verbatim)

- **Phone input** live-format on every keystroke; auto-strip pasted country code.
- **Protocol selection** card lifts (`translateY(-1px)`), purple gradient fills, tick fades in, cycle + meds + routing cards reveal below.
- **Med rows** hover reveals edit/delete; click row toggles confirmed state.
- **Toast** `pointer-events:none` when hidden; click-to-dismiss; auto-dismiss 2.6s; navigation clears any visible toast.
- **Sidebar** swaps between "default" workspace nav and "onboarding" steps based on current screen.
- **Reset** `startOnboarding()` and "Enroll another patient" both call `resetForm()` — clears every field, deselects protocol, hides cycle/meds cards, clears errors, resets `currentMeds = []`, re-defaults dates.

---

## Animations

- Field shake: `shake-x .3s ease` (translateX -3,3,-3,3,0).
- Toast slide: `transform .35s cubic-bezier(.65,.05,.35,1)` from `translateY(120%)` to `translateY(0)`.
- Screen fade: `fade .25s ease` (opacity + translateY 6→0).

---

## i18n

- The **coordinator tool** is English (coordinators are bilingual in Abu Dhabi hospitals).
- The **patient name input** uses `dir="auto"` — Arabic names auto-RTL, English LTR, no toggle needed.
- The **patient-facing strings** (SMS body, pre-visit report) must be **Arabic-first with English fallback**. The prototype's English SMS preview is illustrative only — the production SMS template should use Almarai for Arabic and ship as a localized template, not a hardcoded string.

---

## Files in This Handoff

- `README.md` — this document.
- `design/Rehlah Onboarding.html` — full prototype, source of truth for visuals + behavior.
- `repo_context/care-team-existing.html` — copy of the live site's `docs/care-team/index.html.html`, included so you can see token values + nav patterns to match.
- `repo_context/marketing-index.html` — copy of `docs/index.html`, for the same reason.

---

## Implementation Checklist

- [ ] Rename `docs/care-team/index.html.html` → `docs/care-team/index.html`.
- [ ] Create `docs/care-team/onboarding/{index.html, styles.css, app.js}`.
- [ ] Port prototype markup → `index.html`. Keep all section anchors as comments for future grepping.
- [ ] Port prototype CSS → `styles.css`. Apply token reconciliation (cool palette, Inter body font).
- [ ] Port prototype JS → `app.js`. Stub backend functions clearly (`// TODO(api):` comments).
- [ ] Wire `localStorage` persistence for the demo if no API is ready.
- [ ] Link from `docs/care-team/index.html` → `/care-team/onboarding/`.
- [ ] Verify on a phone-width viewport (the table goes single-column at <780px — already in the CSS).
- [ ] Test full flow with an Arabic name to confirm `dir="auto"` works end-to-end (review screen, SMS preview, invite code initials).
- [ ] Hand off to Flutter team for the patient-side activation hookup.

---

*Generated from the Rehlah onboarding prototype. Source of truth lives in `design/Rehlah Onboarding.html` — when in doubt, open it and look.*
