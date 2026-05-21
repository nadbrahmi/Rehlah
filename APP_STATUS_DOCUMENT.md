# Rehlah · رحلة — App Status Document
**Version:** 1.7  
**Last Updated:** 2026-05-20  
**Branch:** main

---

## 1. Screen Implementation Status

| # | Screen | Route | Status | Notes |
|---|--------|-------|--------|-------|
| 1 | Home | `/` | ✅ Complete | Hero pill shadow, phase card % badge, dashed-circle today dot, 2×2 quick tiles, NadirCard, ScanxietyCard, MonitoringWellnessCard, MicroEducationCard, CycleAndScanCard (monitoring only) |
| 2 | Check-in (Emoji) | `/checkin` | ✅ Complete | Mood selector + symptom chips; phase-aware symptom sets via ProtocolResolver |
| 3 | Check-in (Sliders) | `/checkin/sliders` | ✅ Complete | 0–10 sliders for 5 symptoms (alias of `/checkin`) |
| 4 | Check-in Success | `/checkin/success` | ✅ Complete | 4s auto-return countdown; all widgets inlined (no rehlah_widgets.dart dependency) |
| 5 | AI Chat | `/ai-chat` | ✅ Complete | Wired to Anthropic claude-sonnet-4-6 |
| 6 | My Health — Journey | `/my-health/journey` | ✅ Complete | Phase card + milestones; Survivorship 🌟 always visible |
| 7 | My Health — Expect | `/my-health/expect` | ✅ Complete | Cycle dots + side effects by phase |
| 8 | Care Hub | `/care` | ✅ Complete | Journey Progress Card (cycle pips + phase line) at top; hero "things on your plate"; Track / Understand / Records sections; Understand has What to Expect + Cycle Tracker (phase-aware) |
| 9 | Lab Results | `/care/labs` | ✅ Complete | Hero status + AI summary + metric cards |
| 10 | Lab History | `/care/labs/history` | ✅ Complete | Chronological list; "+" button pops back to labs |
| 11 | Lab Add Form | `/care/labs/add` | ✅ Complete | Redirects to `/care/labs`; add is done via bottom sheet on that screen |
| 12 | Medications | `/care/medications` | ✅ Complete | Vertical-line timeline layout; dot ring shadows; tappable card to mark taken; long-press to edit |
| 13 | Appointments | `/care/appointments` | ✅ Complete | Countdown hero + upcoming/past list |
| 14 | Prep Report | `/care/appointments/prep` | ✅ Demo-ready | Full 6-section bilingual clinical report: Protocol Context, Symptom Summary, Threshold Alerts, Medication Adherence, Lab Correlation, Talking Points; session-matched patient (Nadia/Layla/Amira); instant render, no API call; color-coded alert cards, adherence bars, lab status badges, EN+AR talking points with action rows; **Share / Print PDF** — system print dialog (save as PDF) + OS share sheet via `pdf` + `printing` packages |
| 15 | Connect | `/connect` | ✅ Complete | 4 tabs: Feed / Mentors / Coaches / Stories |
| 16 | Profile | `/profile` | ✅ Complete | Completion bar + personal/treatment info |
| 17 | Privacy | `/profile/privacy` | ✅ Complete | Data controls |
| — | Welcome | `/welcome` | ✅ Complete | Invite code entry; GoRouter redirect → `/` if session already active |
| — | Onboarding | `/onboarding` | ✅ Complete | Demo walkthrough |
| — | Caregiver Home | `/caregiver` | ✅ Complete | Caregiver view |
| — | Vitals | `/vitals` | ✅ Complete | Temperature + pulse + SpO₂ logging |
| — | Chemo Cycle Tracker | `/care/cycle-tracker` | ✅ Complete | Treatment cycle calendar: cycle days (saffron), nadir (clay), appointment dots (sky); phase banner (cycle N · day D); "Next cycle begins" row; shown for active chemo patients only |
| — | Period & Scan Tracker | `/monitoring/cycle-tracker` | ✅ Complete | Full redesign: period tracker tab (phase banner, calendar with period/ovulation/fertile/predicted days, stats row, history, log button) + scan planner tab (optimal window calendar for 6 months); shown for monitoring patients only |

---

## 2. Navigation / Routing

| Route | Handler | Notes |
|-------|---------|-------|
| `/welcome` | `WelcomeScreen` | GoRouter redirect → `/` if `UserSession().supabasePatientId != null` |
| `/` | `HomeScreen` | ShellRoute (bottom nav) |
| `/checkin` | `CheckInScreen` | Also aliased at `/checkin/sliders` |
| `/checkin/success` | `CheckInSuccessScreen` | — |
| `/ai-chat` | `AiChatScreen` | — |
| `/care` | `CareHubScreen` | ShellRoute — bottom nav "Care" tab |
| `/care/cycle-tracker` | `ChemoCycleTrackerScreen` | Chemo patients only; pushed from Care Hub Understand section |
| `/care/labs` | `LabResultsScreen` | — |
| `/care/labs/history` | `LabHistoryScreen` | — |
| `/care/labs/add` | `AddLabScreen` | Redirect stub → `/care/labs` |
| `/care/medications` | `MedicationsScreen` | — |
| `/care/appointments` | `AppointmentsScreen` | — |
| `/care/appointments/prep` | `PrepReportScreen` | — |
| `/my-health/journey` | `MyHealthJourneyScreen` | ShellRoute |
| `/my-health/expect` | `MyHealthExpectScreen` | ShellRoute |
| `/monitoring/cycle-tracker` | `CycleTrackerScreen` | Monitoring patients only |
| `/vitals` | `VitalsScreen` | — |
| `/connect` | `ConnectScreen` | ShellRoute |
| `/profile` | `ProfileScreen` | ShellRoute |
| `/profile/privacy` | `PrivacyScreen` | — |
| `/onboarding` | `OnboardingScreen` | — |
| `/caregiver` | `CaregiverHomeScreen` | — |

**Navigation audit (2026-05-19):** All 23 defined routes have valid handlers. All `context.go()` / `context.push()` call sites point to defined routes. No broken links.

---

## 3. Data Wiring

| Feature | Source | Status |
|---------|--------|--------|
| Patient profile | Supabase `patients` table | ✅ Live — fetched on invite activation and on every app restart |
| Medications | Supabase `medications` table | ✅ Live — fetched via `getMedications()`, cached offline |
| Appointments | Supabase `appointments` table | ✅ Live — fetched via `getAppointments()`, cached offline |
| Lab results | Supabase `labs` + `lab_metrics` tables | ✅ Live — join query via `getLabs()`, cached offline |
| Check-in history | Supabase `checkins` table | ⚠️ Write-only — saved via `saveCheckin()`, not yet reloaded into session |
| AI Chat | Anthropic API | ✅ Live — uses `ANTHROPIC_API_KEY` from `.env` |
| Offline session | SharedPreferences (4 keys) | ✅ Live — full patient + meds + apts + labs cached after every successful fetch |
| Vitals | Local (`UserSession._vitals`) | 🟡 In-memory only — not persisted or synced |
| Cycle tracker (chemo) | `UserSession` (protocol, cycle, dayInCycle, cycleStartDate) | 🟡 In-memory; cycleStartDate from Supabase if present |
| Cycle tracker (period) | `UserSession` (menstrualStatus, lastPeriodDate, cycleLength) | 🟡 In-memory; no Supabase persistence yet |

---

## 4. Session / State Flow

### First activation (new patient, invite code)
1. Patient enters invite code on `/welcome`
2. `validateInviteCode()` → Supabase lookup → returns patient row
3. `SupabaseService.applyPatientToSession(data)` → fetches meds, apts, labs → calls `_populateSession()` → writes 4-key offline cache
4. `patient_id` saved to SharedPreferences key `rehlah_patient_id`
5. `activatePatient()` sets `invite_status = 'active'` (fire-and-forget)
6. GoRouter navigates to `/`

### Subsequent launches — online
1. `main()` reads `rehlah_patient_id` from SharedPreferences
2. `getPatientById(savedId)` → fresh row from Supabase
3. `applyPatientToSession(data)` → fetches all clinical data → updates offline cache
4. GoRouter redirect fires: `/welcome` → `/`

### Subsequent launches — offline
1. `main()` reads `rehlah_patient_id` — present
2. `getPatientById()` returns null (no network)
3. `applyPatientFromCache()` → reads 4 SharedPreferences keys → calls `_populateSession()`
4. GoRouter redirect fires: `/welcome` → `/`

### Demo mode (no Supabase credentials)
- `Env.hasSupabase` is false → all Supabase blocks skipped
- `UserSession` populated with `MockData` on first screen access
- All screens function with mock data

---

## 5. Environment / Configuration

| Key | File | Required |
|-----|------|----------|
| `SUPABASE_URL` | `env` (gitignored) | For live data |
| `SUPABASE_ANON_KEY` | `env` | For live data |
| `ANTHROPIC_API_KEY` | `env` | For AI Chat |

- `env.example` documents all required keys
- App runs in demo mode if `env` file is absent or keys are blank

---

## 6. Component Library

| Component | File | Description |
|-----------|------|-------------|
| `HeroCard` | shared_widgets.dart | Teal gradient card with title/subtitle/child |
| `SurfaceCard` | shared_widgets.dart | White card with shadow |
| `ToolRow` | shared_widgets.dart | Icon + label row tile |
| `AppBottomNav` | shared_widgets.dart | 5-tab bottom nav (Home / Care / — / Connect / Profile) |
| `_DashedCircle` | home_screen.dart | Dashed-border circle for cycle day dot |
| `_DashedCirclePainter` | home_screen.dart | CustomPainter using dart:math arc segments |
| `_RingPainter` | medications_screen.dart | CustomPainter for saffron arc on adherence hero ring |
| `ShellScreen` | shell_screen.dart | Bottom nav shell wrapping ShellRoute children |

---

## 7. Working Features (End-to-End Verified)

- ✅ Care team onboarding web app enrolls patient → Supabase row created
- ✅ Invite code activation in Flutter app
- ✅ Patient data (name, diagnosis, cycle, protocol) loaded from Supabase
- ✅ Medications loaded from Supabase; timeline layout with mark-taken tap
- ✅ Appointments loaded from Supabase
- ✅ Lab results loaded from Supabase (with nested metrics via join)
- ✅ Session persists across app restarts (online path)
- ✅ Session restores from offline cache when network unavailable
- ✅ GoRouter skips welcome screen on relaunch when session is active
- ✅ Check-in submitted to Supabase `checkins` table
- ✅ AI Chat responds via Anthropic API
- ✅ Phase-aware Care Hub (Journey card, chemo cycle tracker vs period tracker)
- ✅ Chemo cycle tracker shows treatment cycle, nadir window, appointment dots
- ✅ Period & scan tracker with calendar, stats, history, settings, and scan planner
- ✅ All navigation links verified — no broken routes
- ✅ All screens render without errors
- ✅ Prep report exports full 6-section clinical PDF (print + share)

---

## 8. Known Issues / Gaps

| Issue | Severity | Notes |
|-------|----------|-------|
| Check-in history not reloaded into session | Low | `saveCheckin()` writes to Supabase but `checkins` are not fetched back |
| Vitals not persisted | Low | VitalRecord stored in-memory only; lost on app restart |
| Cycle tracker data not persisted | Low | Period entries, menstrualStatus, cycleLength in-memory only |
| Migration 002 not auto-applied | Medium | `supabase/migrations/002_labs_schema.sql` must be run manually; labs show mock data until applied |
| No Supabase auth (email/password) | Low | App uses invite codes only; no password reset or account management |
| Windows VS toolchain warning | Info | "Unable to find suitable Visual Studio toolchain" — iOS/Android unaffected |
| `caregiver_session.dart` access denied | Info | Intermittent Windows file lock during hot reload; resolves on restart |
| `/checkin/sliders` dead route | Info | Defined as alias for `/checkin` but never navigated to; harmless |

---

## 9. Dependencies

| Package | Version | Status |
|---------|---------|--------|
| flutter_riverpod | ^2.5.1 | Active |
| go_router | ^13.2.0 | Active |
| supabase_flutter | ^2.x | Active |
| flutter_dotenv | ^5.x | Active |
| shared_preferences | ^2.x | Active — patient_id + offline cache |
| http | ^1.x | Active — Anthropic API calls |
| intl | ^0.x | Active — date formatting across all screens |
| pdf | ^3.10.8 | Active — PDF generation for prep report |
| printing | ^5.13.1 | Active — system print dialog + OS share sheet |
| hive_flutter | ^1.x | Declared, not yet used |

---

## 10. Backend Schema

| Table | Migration | Columns | Notes |
|-------|-----------|---------|-------|
| `patients` | 001 | id, name, diagnosis, protocol_id, cycle_number, total_cycles, cycle_start_date, invite_code, invite_status, invite_expires_at | Core patient record |
| `medications` | 001 | id, patient_id, name, dose, frequency, active | `active=true` filter applied |
| `appointments` | 001 | id, patient_id, title, date_time, location, notes | Ordered by date_time |
| `checkins` | 001 | id, patient_id, mood, fatigue, pain, nausea, fever, mood_score, notes, created_at | Write-only from app |
| `labs` | 002 | id, patient_id, panel_name, date, ai_summary, created_at | Ordered by date DESC |
| `lab_metrics` | 002 | id, lab_id, name, value, unit, normal_min, normal_max, previous_value | Fetched via join on labs |

---

## 11. Open Decisions & TODOs

- [ ] Apply migration 002 to production Supabase project
- [ ] Add `checkins` fetch to session restore (display check-in history on home or profile)
- [ ] Persist vitals and cycle tracker data (Supabase or SharedPreferences)
- [ ] Arabic localization — all strings currently English only
- [ ] Push notifications for appointment reminders
- [ ] Caregiver flow — `CaregiverHomeScreen` exists but session/data not wired
- [ ] App icon and splash screen (currently Flutter defaults)
- [ ] TestFlight / Play Store internal testing track setup

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| Total screens | 17 numbered + 6 utility screens |
| Defined routes | 23 |
| Backend tables | 6 |
| SQL migrations | 2 |
| Actively used packages | 9 |
| Persistence layers | 2 (Supabase + SharedPreferences) |
| AI integrations | 1 (Anthropic Messages API) |
