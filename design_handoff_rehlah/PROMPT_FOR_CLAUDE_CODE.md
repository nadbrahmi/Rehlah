# Prompt for Claude Code — Rehlah v0.1 reskin + Check-in v2 redesign

Paste the prompt below into a new Claude Code session, with this `design_handoff_rehlah/` folder available in your repo (drop it at the repo root or `docs/design_handoff_rehlah/`).

---

```
I'm doing two coordinated changes to my Flutter app Rehlah (رحلة) — a bilingual
(Arabic / English) cancer-care companion app. The changes are:

  (A) Visual reskin to the v0.1 design system — every screen
  (B) Daily Check-in redesign — IA, copy, and clinical logic

None of the data plumbing, routing, or business logic should change.

## Handoff package

A folder named `design_handoff_rehlah/` is in this repo. Read these in order:

  1. `design_handoff_rehlah/README.md`  — visual system, tokens, every component
  2. `design_handoff_rehlah/Rehlah_Checkin_Redesign_v1.0.md`  — check-in spec

The README has Dart-ready color constants, typography scale, spacing/radius/
elevation tokens, and a per-route map pointing at the design files.

The `.html` files in the folder are the visual source of truth — open them in a
browser. The `.jsx` files are the React source for each mock. The
`rehlah-styles.css` file holds every token and component class.

`Rehlah All Screens.html` shows every screen in one canvas. Section "02b · Daily
check-in v2 (phase-aware redesign)" is the new check-in.

## What I want you to do

This is **two visual changes plus one IA change**, applied as one coordinated
sweep of the existing Flutter codebase.

### (A) Visual reskin — every existing screen

Recreate every screen visually in the v0.1 system:

1. Add fonts to `pubspec.yaml`: **Tajawal** (300/400/500/700/900) and
   **Newsreader** (400/500, italic 400). Use `google_fonts` or bundle .ttf.
2. Create `lib/theme/rehlah_theme.dart` with the full token set from README §
   "Design tokens — exact values". Wrap `MaterialApp` in this theme.
3. Reskin shared widgets in `lib/shared_widgets.dart` — keep their public
   API, change visuals:
     - `HeroCard` — teal-700 → teal-600 gradient, radius 24, saffron decorative
       bloom in the top corner (mirror in RTL). Add an optional
       `variant: HeroVariant.teal / plum / sage` for journey / caregiver /
       completion moments.
     - `SurfaceCard` — white, radius 16, shadow-2
     - `ToolRow` — leading 36×36 icon tile (radius 10), 14 px title + 11 px
       caption, trailing chevron OR `StatusPill`. 60 px min height.
     - `AppBottomNav` — floating card 38 px from bottom, radius 24, shadow-3,
       5 tabs with sand/teal color states, saffron 52 px FAB on the centre slot
       that turns sage when `UserSession.checkInDoneToday` is true.
4. Add the new shared widgets listed in README § "New widgets / patterns to
   add" — `PhaseBanner`, `PhaseSubheadPill`, `StatusPill`, `AdherenceRing`,
   `Timeline` + `TimelineItem`, `MetricCard`, `MoodLikert`,
   `SymptomSegmented`, `AddSymptomDisclosure`, `TemperaturePromptCard`,
   `FeverRedFlagBanner`, `Notes`, `SubmitFooter`, `TrendCard`, `LabRangeRow`,
   `AISummary`, `CycleCalendar`, `CareTeamStrip`, `AskRehlahPrompt`.
5. Reskin every screen in the order suggested by README §
   "Implementation order (suggested)". Aim for pixel parity at 402 × 874 with
   the corresponding artboard in `Rehlah All Screens.html`.

### (B) Check-in v2 — IA + clinical logic

Implement the redesign in `Rehlah_Checkin_Redesign_v1.0.md` exactly:

  - **Merge** `/checkin` and `/checkin/sliders` into ONE scrollable screen
  - **Retire** `/checkin/sliders` (redirect to `/checkin`)
  - **Replace** 0–10 sliders with **5-point segmented controls** using verbal
    anchors (None / Mild / Moderate / Severe / Worst), stored as 0/2/5/7/10
    for DB continuity (`kSegmentedToNrs` in the spec)
  - **Remove** the fever slider; fever is only ever logged via `/vitals` in °C
  - **Phase-aware symptom set**:
      - Treatment (Day 0–2 post-infusion) → nausea, fatigue, infusion site
      - Nadir (Day 7–14) → fatigue, mouth sores, appetite loss (+ temperature
        prompt linking to `/vitals`)
      - Recovery (Day 15–21) → energy level, mood, appetite
  - **Red-flag escalation**: when today's logged temperature ≥ 38°C AND
    `phase == nadir`, show `FeverRedFlagBanner` at the TOP of the scroll with
    one-tap "Call care team now" (NOT a modal — pushes the form down)
  - **Notes** field is always shown and prominent (with voice-to-text mic chip)
  - **Success** screen: replace the 4-second auto-return with **manual
    dismiss + today-vs-yesterday trend** (better / same / worse arrows in
    sage / sand / clay). Show the green/sage FAB in the bottom nav to confirm
    the state change.
  - **Validation**: submit disabled until mood is set AND (any severity > 0 OR
    notes filled). All copy strings come from § 5 of the spec — no paraphrasing.

The Flutter widget tree in § 6 of the spec is a strong starting point, but
treat it as a sketch — adapt class names and structure to your codebase.

Use Riverpod for `CheckinFormState`, gate everything behind
`Env.useNewCheckin` (default `true` in debug; gradual prod rollout via a
Supabase feature flag), and wire `checkin_started / submitted / abandoned`
events to `analytics_events` for the A/B targets.

## Bilingual / RTL

  - Wrap the app in `Directionality` based on locale
  - Arabic addresses the patient in **feminine singular** by default
  - Most layouts mirror automatically. Manually flip: arrows, sparklines,
    progress fill direction, microphone chip position
  - Use Arabic-Indic numerals (٠١٢٣) when locale is `ar`; consistent within a
    screen. The mocks show this pattern.

## Hard constraints — do not change

  - Routes (except retiring `/checkin/sliders`) — all preserved
  - `UserSession` API surface, `SupabaseService` methods, `MockData` shape
  - GoRouter redirect logic
  - Public APIs of `HeroCard`, `SurfaceCard`, `ToolRow`, `AppBottomNav`,
    `VitalsScreen`
  - Anthropic API integration in AI Chat
  - Offline cache (SharedPreferences, 5 keys)
  - Supabase schema and migrations (the spec's "Migration Plan" says no schema
    change needed for v1.0 — extras hack into `notes` until v1.1's JSONB
    `extra_symptoms` column)

If you find yourself wanting to change any of these, stop and ask me.

## Working approach

1. **Theme + tokens first.** Create `rehlah_theme.dart` and a `severity_colors`
   ThemeExtension. Show me the theme file before moving on.
2. **One widget at a time.** Smallest possible diffs.
3. **One screen at a time.** After each, take a screenshot at 402×874 and
   compare visually to the corresponding artboard.
4. **Check-in v2 last among the existing screens** — but BEFORE retiring the
   old `/checkin/sliders` route. Build behind the `useNewCheckin` flag so I
   can A/B before retiring the old flow.
5. Don't try to use `rehlah-styles.css` in Flutter — it's a spec, not source.
   Translate CSS values into Flutter widget properties. When uncertain about a
   number (padding, font size, color), search the .css for the exact value.

## Start here

Begin with task A.1 (add fonts to pubspec.yaml) and A.2 (create
`rehlah_theme.dart`). Show me the theme file before moving on.

Then we'll work through this order:
  - A.3 — reskin `HeroCard`, `SurfaceCard`, `ToolRow`, `AppBottomNav`
  - A.4 — add new shared widgets (in dependency order: `StatusPill` first,
    then everything that uses it)
  - A.5 — reskin daily-loop screens: Home → Care Hub → Vitals → Medications
  - **B — Check-in v2** behind `useNewCheckin` flag
  - A.5 (cont.) — Journey, Expect, Cycle Tracker, Labs (×3), Appointments,
    Prep Report, AI Chat, Connect, Profile, Privacy, Welcome, Onboarding,
    Caregiver Home
  - Finally — retire `/checkin/sliders` route and remove old check-in widgets

Open questions are listed at the bottom of the README and in § 9 of the
check-in spec — flag any that come up.
```

---

That's the prompt. After Claude Code starts, it will produce the theme file first — review it, then say "go" and it will work through the list.
