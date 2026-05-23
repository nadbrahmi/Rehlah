# Handoff: Rehlah Design System v0.1 — Cancer-care companion app

## Overview

Rehlah (رحلة — "journey") is a bilingual (Arabic / English) cancer-care companion app for patients undergoing chemotherapy. The app is already built in Flutter and live with real Supabase data, AI chat via Anthropic, and ~22 functional screens — see `APP_STATUS_DOCUMENT.md` (provided separately) for the current state.

This handoff is a **visual redesign** of every screen using a new design system (v0.1) that replaces the previous purple-clinical aesthetic with a warmer, MENA-rooted, more humane visual language. The intent is to apply this design system to the existing Flutter app's UI layer **without changing any business logic, data flow, or screen routing**.

## About the design files

The files in this bundle are **design references created in HTML/React/JSX** — prototypes built to communicate the intended look, feel, and behaviour of each screen. They are **not production code to copy directly**.

The task is to **recreate these screens in the existing Flutter codebase** (`flutter_riverpod`, `go_router`, `supabase_flutter` — see status doc) using Flutter's widget system. Every screen already exists in the Flutter app; this is a **visual reskin** that should swap colors, typography, spacing, component shapes, and layout details to match the v0.1 design system — while preserving:

- All routes (`/`, `/checkin`, `/care/medications`, etc.)
- All `UserSession`, Supabase, and offline cache plumbing
- The `AppBottomNav`, `HeroCard`, `SurfaceCard`, `ToolRow`, `VitalsScreen` API shapes (you'll change their internals, not their public interfaces)

If a Flutter widget already does the job, refactor it rather than replacing it. If a new pattern is needed (e.g. the timeline view in Medications), add a new widget.

## Fidelity

**High-fidelity.** All colors, typography, spacing, radii, and component composition are final. The developer should recreate the UI pixel-perfectly in Flutter, using exact values from the design tokens.

## Design language summary

| Principle | Direction |
|---|---|
| **Mood** | Grounded, warm, calm — not clinical |
| **Palette** | Sand neutrals (warm, low-chroma) base · Teal as primary "journey" color · Saffron as accent for "today" · Sage / Clay / Sky as semantic state colors |
| **Type** | Single family: **Tajawal** (Arabic + Latin in one family, weights 300–900). **Newsreader** serif for editorial moments only (welcome headline, milestone names) |
| **Geometry** | Soft radii (16–24 px on cards), pill radii on actions |
| **Bilingual** | Every screen mirrors cleanly RTL — icons flip, progress reverses, layout reflows |
| **Numbers** | Tabular figures everywhere (`fontFeatureSettings: 'tnum'`) |
| **Imagery** | No cartoon mascots; warmth comes from typography, motion, language |

## Design tokens — exact values

### Colors (oklch — use sRGB equivalents in Flutter)

```dart
// Sand neutrals
const sand50  = Color(0xFFFAF8F4);   // page bg
const sand100 = Color(0xFFF3F0EA);   // subtle surface
const sand200 = Color(0xFFE6E1D7);   // divider, chip bg
const sand300 = Color(0xFFD2CABE);
const sand400 = Color(0xFFA89E8E);
const sand500 = Color(0xFF7E7468);   // muted text
const sand700 = Color(0xFF4F473C);
const sand900 = Color(0xFF231E16);   // primary text
const sand950 = Color(0xFF14110B);

// Teal — primary
const teal50  = Color(0xFFE6F2F1);
const teal100 = Color(0xFFCEE6E4);
const teal200 = Color(0xFFA7D2CE);
const teal500 = Color(0xFF457A77);
const teal600 = Color(0xFF356561);
const teal700 = Color(0xFF275350);   // **primary brand**
const teal900 = Color(0xFF142E2C);

// Saffron — accent for "today"
const saffron100 = Color(0xFFFAF1DE);
const saffron300 = Color(0xFFE9C997);
const saffron500 = Color(0xFFD4A258);  // **FAB / accent**
const saffron700 = Color(0xFF8B6328);

// Sage — positive / "taken" / "complete"
const sage100 = Color(0xFFE8F1E5);
const sage300 = Color(0xFFB4D2A9);
const sage500 = Color(0xFF7CA773);
const sage700 = Color(0xFF466540);

// Clay — alert / fever / missed
const clay100 = Color(0xFFFAEAE0);
const clay300 = Color(0xFFE9B79A);
const clay500 = Color(0xFFC76F47);
const clay700 = Color(0xFF8B4824);

// Sky — informational
const sky100 = Color(0xFFE7EEF8);
const sky500 = Color(0xFF6D8FB8);

// Plum — caregiver mode / journey
const plum100 = Color(0xFFEDE3EE);
const plum500 = Color(0xFF8967A0);
const plum700 = Color(0xFF5B4276);

const surface = Color(0xFFFFFFFF);
```

> **Note:** The HTML files use `oklch()` color notation for precision. The hex equivalents above are sRGB approximations — close enough for visual identity. If color precision matters (e.g. matching across iOS/Android color profiles), use a library to convert oklch → display-P3.

### Typography

| Style | Family | Weight | Size | Line height | Letter spacing | Uses |
|---|---|---|---|---|---|---|
| Display | Newsreader | 400 | 64 / 40 | 1.0 | -0.02em | Welcome, success state |
| Numeric hero | Tajawal | 700 | 48–56 | 1.0 | -0.02em | Temperature, days, % |
| H1 | Tajawal | 700 | 32 | 36 | -0.01em | Section landings |
| H2 | Tajawal | 700 | 22–24 | 28 | -0.01em | Card titles, hero |
| H3 | Tajawal | 500 | 18 | 24 | 0 | Subheads |
| Body | Tajawal | 400 | 15 | 23 | 0 | All paragraph copy |
| Small | Tajawal | 400 | 13 | 19 | 0 | Metadata, captions |
| Eyebrow | Tajawal | 500 | 11 | 11 | 0.14em UPPERCASE | Section labels |

Tabular numerals (`tabular-nums`) on every number that's a value, dose, time, or measurement.

### Spacing scale (4 px base)

`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 56 · 72`

### Radii

```
xs:  6
sm:  10
md:  14   ← inline rows, metric cards
lg:  20   ← surface cards
xl:  28   ← hero cards, sheets
pill: 999 ← buttons, status pills
```

### Elevation

```
shadow-1: 0 1px 2px rgba(40,30,20,.04), 0 1px 1px rgba(40,30,20,.03)   // resting card
shadow-2: 0 2px 6px rgba(40,30,20,.05), 0 4px 12px rgba(40,30,20,.04) // surface card
shadow-3: 0 8px 24px rgba(40,30,20,.08), 0 2px 6px rgba(40,30,20,.04) // sheet, FAB, nav
```

### Motion

Default easing `cubic-bezier(.2, .8, .2, 1)` at 180 ms. Page transitions slide-up at 240 ms. Mirror horizontal motion in RTL.

## Component library (reuse, don't reinvent)

### Existing widgets to update (don't change their API)

These already exist in `lib/shared_widgets.dart`. **Update their visuals, keep their interfaces.**

| Widget | What to change |
|---|---|
| `HeroCard` | Background → `LinearGradient` of teal-700 → teal-600. Border-radius 24. Saffron decorative "bloom" circle in the top corner (mirror in RTL). Padding 20-20-22. White text. Optional `variant: plum / sage` for journey / caregiver / completion contexts. |
| `SurfaceCard` | White background, radius 16, `shadow-2`. Keep child API. |
| `ToolRow` | 36×36 icon tile (radius 10) on the leading side · label (Tajawal 500 14) + caption (Tajawal 400 11 sand-500) · chevron OR status pill on trailing. Min height 60. |
| `AppBottomNav` | Floating card with radius 24, shadow-3, sitting 38 px from bottom. 5 tabs (Today, Health, ·, Connect, Profile) with sage/teal/sand color states. Saffron 52 px FAB centered on the middle slot; turns **sage** when `checkInDone` is true (already wired in `UserSession.checkInDoneToday` — keep). |
| `VitalsScreen` | Apply new HeroCard (teal gradient, 38.9° style) + line-chart card · phase-aware nadir banner above hero · "Record temperature" saffron pill button |

### New widgets / patterns to add

| New widget | Used in | Description |
|---|---|---|
| `PhaseBanner` | Home, Care Hub, Cycle Tracker, Vitals | Pill-radius row with cycle number badge, eyebrow ("Cycle 2 of 6"), title, subtitle. Three variants: saffron (default, "current"), clay (alert / nadir), sage (complete / on-track) |
| `PhaseSubheadPill` | Check-in v2 | Smaller flat pill that sits under the greeting (NOT a full phase banner — quieter, just naming the cycle/day/phase inline). Same three variants. |
| `StatusPill` | Everywhere | 22 px tall pill with leading dot. Variants: `warn / pos / alert / info / neutral` |
| `AdherenceRing` | Medications hero | 100 px SVG ring, 8 px stroke, sage / saffron / clay by % |
| `Timeline` + `TimelineItem` | Medications, Journey | Vertical thread with status dot · time (mono) · card on trailing side. Dot color follows status (taken / missed / next / scheduled) |
| `MetricCard` | Vitals, Lab Results, Caregiver Home | Compact card with 32 px icon tile · label · big tabular value · "X ago" caption |
| `MoodLikert` | Check-in v2 | 5-cell row of abstract face glyphs (◐ ◑ ● ◔ ◕) inside circle tiles. Selected = teal-700 ring + teal-100 fill + halo shadow. Anchor word below each. |
| `SymptomSegmented` | Check-in v2 | 5-step segmented control with verbal anchors (None/Mild/Mod./Severe/Worst). Pad colors ramp through severity: sand-200 → saffron-100 → saffron-300 → clay-300 → clay-500. Unfilled cells (above current value) show dashed sand outline. **Stored as 0/2/5/7/10 in DB for NRS continuity** (see `kSegmentedToNrs` in the spec). |
| `AddSymptomDisclosure` | Check-in v2 | Dashed-outline pill button "＋ Add another symptom". Expands to show extra symptoms not in the phase default. |
| `TemperaturePromptCard` | Check-in v2 (nadir only) | Mirrors the Home Vitals tile: clay-tinted thermometer icon tile · "Temperature" title · last reading caption · "Log temperature now →" CTA that routes to `/vitals`. **Only renders when phase == nadir.** |
| `FeverRedFlagBanner` | Check-in v2 (conditional) | Clay-tinted card pinned to the TOP of the scroll. Warning icon · URGENT eyebrow · monospace temperature · clinical body copy · clay-500 "Call care team now" pill button with phone icon · underlined "Continue check-in" secondary. **Renders only when temperature ≥ 38°C AND phase == nadir.** Pushes the rest of the form down — it is not a modal. |
| `Notes` | Check-in v2 | Sand-tinted input area inside a white surface card. Title + "optional" caption + placeholder. Inline "🎙 Speak" mic chip in the bottom-end corner. |
| `SubmitFooter` | Check-in v2 | Sticky-to-bottom full-width primary button "Send to care team". Sand-50 gradient fade-out behind it for visual separation from scrolling form. Disabled until valid (mood set AND (any severity > 0 OR notes filled)). |
| `TrendCard` | Check-in success | Three-row card showing today vs yesterday for the day's symptoms. `↓ better` in sage, `→ same` in sand-500, `↑ slightly worse` in clay-700. |
| `LabRangeRow` | Lab Results | Name · gradient range bar (clay → sage → clay) · current value marker · monospace value with unit |
| `AISummary` | Lab Results, Prep Report, AI Chat | Teal-tinted card with sparkle icon and AI-generated text |
| `CycleCalendar` | Cycle Tracker | 7-col grid with overlay colors (today, cycle days, nadir, appointment dots) |
| `CareTeamStrip` | Home | Horizontal row of 48 px avatars with role labels below |
| `AskRehlahPrompt` | Home, Expect, anywhere | Inline row with teal sparkle icon + suggested question + chevron — routes to AI Chat |

## Screens & layouts

> All screens are 402 × 874 logical pixels (iPhone 16 Pro size). Scale spacing/typography proportionally for larger devices. Status bar safe-area is 56 px from top; bottom nav sits 38 px above the home indicator.

The HTML mocks under `screens/` are the source of truth for layout. For each route, find the corresponding `.jsx` and replicate the visual hierarchy in Flutter.

| Route | Mock file | Section in `Rehlah All Screens.html` |
|---|---|---|
| `/welcome` | `screens-onboarding.jsx` → `WelcomeScreen` | 01 |
| `/onboarding` | `screens-onboarding.jsx` → `OnboardingScreen` | 01 |
| `/caregiver` | `screens-onboarding.jsx` → `CaregiverHomeScreen` | 01 |
| `/` (Home) | `home-screen.jsx` → `HomeScreen` | 02, 03 |
| `/checkin` (**new — single screen**, phase-aware) | `screens-checkin-v2.jsx` → `CheckinTreatmentScreen / CheckinNadirScreen / CheckinRecoveryScreen` | 02b |
| `/checkin/success` (**new — manual dismiss, with trend**) | `screens-checkin-v2.jsx` → `CheckinSuccessV2Screen` | 02b |
| ~~`/checkin/sliders`~~ | _Retired._ Redirect to `/checkin`. The old emoji + slider variants in `screens-checkin.jsx` exist only for reference comparison. | 02 |
| `/my-health/journey` | `screens-journey.jsx` → `JourneyScreen` | 04 |
| `/my-health/expect` | `screens-journey.jsx` → `ExpectScreen` | 04 |
| `/monitoring/cycle-tracker` | `screens-journey.jsx` → `CycleTrackerScreen` | 04 |
| `/care` (Hub) | `screens.jsx` → `CareHubScreen` | 05 |
| `/care/medications` | `screens.jsx` → `MedicationsScreen` | 05 |
| `/vitals` | `screens.jsx` → `VitalsScreen` | 05 |
| `/care/labs` | `screens-records.jsx` → `LabResultsScreen` | 06 |
| `/care/labs/history` | `screens-records.jsx` → `LabHistoryScreen` | 06 |
| `/care/labs/add` | `screens-records.jsx` → `LabAddScreen` | 06 |
| `/care/appointments` | `screens-records.jsx` → `AppointmentsScreen` | 06 |
| `/care/appointments/prep` | `screens-records.jsx` → `PrepReportScreen` | 06 |
| `/ai-chat` | `screens-social.jsx` → `AIChatScreen` | 07 |
| `/connect` | `screens-social.jsx` → `ConnectScreen` | 07 |
| `/profile` | `screens-profile.jsx` → `ProfileScreen` | 08 |
| `/privacy` | `screens-profile.jsx` → `PrivacyScreen` | 08 |

## Interactions & behavior

Most interactions are already in place — preserve them.

| Pattern | Behavior |
|---|---|
| **Bottom nav FAB** | Saffron when no check-in today; **sage** with check icon when `UserSession.checkInDoneToday` is true. Already reactive via `ListenableBuilder`. |
| **Check-in flow** | `/checkin` → continue → `/checkin/sliders` → save → `/checkin/success` (4s auto-return) |
| **Phase banner** | Reads `UserSession.cycleDay` and `nadirWindow`. Saffron when `nadirSoon`, clay when `inNadir`, sage when `recovered` |
| **Medication timeline cards** | Tap "Take now" on the active (saffron-highlighted) card to log. Active card is the next-due dose within 1 hour. |
| **Cycle calendar** | Tap any day to see what's scheduled. Today is teal-700 filled. Cycle days are saffron tinted. Nadir days are clay tinted. Appointments show sky dots beneath the date. |
| **AI Chat suggestions** | Three chips render only on first message. Tapping fills the input. Source citation cards appear when AI references a specific lab or check-in. |
| **Privacy toggles** | Per-person sharing — saving immediately updates Supabase ACL. Show subtle haptic on toggle. |
| **Page transitions** | Slide from leading edge in 240 ms with default easing. Mirror in RTL. |
| **RTL behavior** | Set `Directionality(textDirection: TextDirection.rtl)` on the app when locale is `ar`. Everything mirrors automatically except: progress bars (`Transform.scale(-1, 1)` on the painter), arrow icons (also flip), and sparkline charts (also flip). The HTML mocks show this explicitly with `[dir="rtl"]` selectors — match those flips. |

## State management

No new state — everything is already in place:

- `UserSession` (Riverpod / `ChangeNotifier`) holds patient profile, meds, appointments, labs, check-ins, vitals
- Supabase tables: `patients`, `medications`, `appointments`, `checkins`, `labs`, `lab_metrics` (see migration SQL in repo)
- `flutter_dotenv` for `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `ANTHROPIC_API_KEY`
- 5-key SharedPreferences cache for offline mode

The redesign should not require new state or new endpoints. If a screen renders data that isn't yet in `UserSession`, log a TODO rather than inventing a fetch.

## Asset list

- **Fonts:** Tajawal (300, 400, 500, 700, 900) and Newsreader (400, 500, italic 400) — both from Google Fonts. Use `google_fonts: ^6.x` package or bundle the .ttf files in `assets/fonts/`.
- **Icons:** All icons in the mocks are inline SVG stroked at 1.8 px. Use `flutter_svg` or rebuild as `CustomPainter` widgets. Stroke linecap = round, linejoin = round.
- **No raster images required** — the design uses no photos or illustrations. The Welcome screen "orb" is a CSS gradient with an Arabic letter ر; in Flutter this is a `Container` with `BoxDecoration` gradient + a centered `Text`.

## Files in this bundle

| File | Purpose |
|---|---|
| `Rehlah Design System.html` | Documents the full design system: color, type, spacing, radius, elevation, components, usage rules. **Read this first.** |
| `Rehlah All Screens.html` | Pan/zoom canvas with every screen — both the original daily-loop and the new check-in v2 — across 9 sections. **The source of truth for layout.** |
| `Rehlah Check-in v2.html` | Standalone canvas for the 7 phase-aware check-in screens (Treatment / Nadir / Nadir+Fever / Recovery / Success + Arabic variants) |
| `Rehlah Home v2.html` | Standalone bilingual Home mockup for reference |
| `Rehlah Core Screens.html` | Standalone Home + Medications + Vitals + Care Hub for reference |
| `rehlah-styles.css` | All design tokens as CSS custom properties + every component class. **Use this as the spec.** |
| `Rehlah_Checkin_Redesign_v1.0.md` | The clinical/IA spec for the check-in v2 redesign — copy, validation rules, Flutter widget tree, migration plan. **Implement check-in from this doc.** |
| `home-screen.jsx`, `screens.jsx`, `screens-checkin.jsx`, `screens-checkin-v2.jsx`, `screens-journey.jsx`, `screens-records.jsx`, `screens-social.jsx`, `screens-profile.jsx`, `screens-onboarding.jsx` | Individual screen mocks. Each component receives `lang: "en" \| "ar"`. The `-v2.jsx` file has the new check-in. |
| `ios-frame.jsx`, `design-canvas.jsx` | Presentation chrome — not part of the design, just the device bezel and canvas. Ignore for implementation. |
| `PROMPT_FOR_CLAUDE_CODE.md` | Ready-to-paste prompt for Claude Code to implement everything in Flutter |

## Implementation order (suggested)

1. **Theme** — Create a `RehlahTheme` (`ThemeData`) with the color scheme + text theme + radii. Wrap your `MaterialApp`/`CupertinoApp` in it.
2. **Update existing primitives** — `HeroCard`, `SurfaceCard`, `ToolRow`, `AppBottomNav`. Each becomes a 1-screen PR. Verify Home renders correctly after each.
3. **Phase banner** — New widget. Add it to Home, Care Hub, Vitals, Cycle Tracker.
4. **Status pill + pill button** — Tiny but used everywhere. Get them right first.
5. **Reskin daily-loop screens** — Home, Check-in (×3). These are the most-used.
6. **Reskin care screens** — Care Hub, Medications (new timeline pattern), Vitals.
7. **Reskin journey screens** — Journey, Expect, Cycle Tracker (new calendar widget).
8. **Reskin labs + appointments** — Lab Results (range bars), Lab History, Add Form, Appointments, Prep Report.
9. **Reskin social** — AI Chat, Connect.
10. **Reskin profile + onboarding** — Profile, Privacy, Welcome, Onboarding, Caregiver Home.

Per screen, take a screenshot of the corresponding artboard in `Rehlah All Screens.html` and aim for pixel parity at 402 × 874.

## Open questions / things the design doesn't cover

- **Dark mode** — not yet designed. If your app supports it, pause and ask for dark tokens.
- **Tablet / iPad layouts** — out of scope. Mocks are phone-only.
- **Error / empty / loading states** — only success-path mocks were created. Use the existing app's patterns for these states; just apply the new colors.
- **Accessibility / Dynamic Type** — minimum body text is 13 pt; numeric heroes max out at 56 pt. Verify all hit targets ≥ 44 pt. Run the Flutter accessibility scanner; pause and ask if anything fails.
- **Animations** — page transitions and the FAB-turns-sage moment are spec'd. Other micro-animations (e.g. ring fills, slider drag) are open. Use sensible defaults (`Curves.easeOutCubic`, 200 ms).

## Notes for the implementer

- The HTML mocks intentionally avoid emoji, mascots, and any decorative SVG imagery — keep it that way. Warmth comes from type, color, and language, not from drawn faces.
- **No purple anywhere** except the plum-tinted Caregiver Mode banner. The previous app used heavy purple headers — those are gone.
- Saffron is reserved for "today" and "act now" moments. Don't let it creep into general decoration.
- Numbers always get tabular figures. This matters more than it sounds — it's the difference between feeling clinical and feeling chaotic.
- When in doubt, **less color, more whitespace**.
