# REHLAH — Complete Technical & UX Specification Documents
**Version 1.0 | April 2026 | Confidential — Internal Team Use**
**Live Prototype:** https://nadbrahmi.github.io/Rehlah/
**Codebase:** https://github.com/nadbrahmi/Rehlah

---

# DOCUMENT INDEX

| # | Document | Purpose |
|---|----------|---------|
| 1 | Product Vision & Scope | Why this product exists |
| 2 | Information Architecture | All screens, routes, navigation |
| 3 | Data Models Specification | Every entity, field, and type |
| 4 | State Management Specification | Providers, computed values, persistence |
| 5 | Screen-by-Screen UX Specification | Full UX detail per screen |
| 6 | Design System Specification | Colours, typography, spacing, components |
| 7 | AI Features Specification | Lab AI, AI Assistant, check-in insights |
| 8 | Known Issues & Backlog | Bugs, gaps, next-phase features |

---

# DOCUMENT 1 — PRODUCT VISION & SCOPE

## 1.1 Product Name
**Rehlah** (رحلة) — Arabic for "journey."
Tagline: *"Your companion between appointments."*

## 1.2 Problem Statement
Cancer patients experience a dangerous information vacuum between clinical appointments. They feel isolated, forget medications, cannot interpret lab results, and arrive at appointments unprepared. Caregivers face the same gap with the added burden of coordination.

## 1.3 Vision
Rehlah is a personal cancer journey companion — a mobile-first app that sits in the patient's daily life, not in the clinic system. It bridges the gap between hospital visits by:
- Logging how the patient feels every day (check-ins)
- Tracking medications per dose, per day
- Helping patients understand their lab results through AI
- Preparing them for appointments with AI-generated talking points
- Connecting them with peers in a moderated safe-space community
- Educating them about each phase of their treatment journey

## 1.4 Target Users

| User Type | Description |
|-----------|-------------|
| Primary — Patient | Adult cancer patient, any type or stage, any treatment phase |
| Secondary — Caregiver | Spouse, family member, or friend managing care on behalf of a patient |

## 1.5 Platform
- Primary: Android (Flutter native APK)
- Preview/Demo: Flutter Web (GitHub Pages: https://nadbrahmi.github.io/Rehlah/)
- Future: iOS

## 1.6 MVP Scope (Current Build)

IN SCOPE:
- Onboarding & demo mode
- Home dashboard with smart adaptive hero card
- Daily check-in (quick mode + full mode + voice mode)
- Medication tracker with per-dose, per-day logging
- Appointment tracker with upcoming/past tabs
- AI Lab Tracker (CBC, Metabolic, Tumour Markers) with pattern detection
- AI Lab Analyzer (manual entry screen)
- AI Health Assistant (chat-style, knowledge-base driven)
- My Journey (treatment phase education, milestones, guidance videos)
- Care Hub (aggregated navigation to all care tools)
- Community (read-only moderated feed with filter tabs)
- Profile & Settings (journey stats, edit, reset)
- Design system (tokens, gradients, shadows, typography)

OUT OF SCOPE (MVP):
- Push notifications
- Real AI/LLM calls
- Hospital system integration
- Account/auth & cloud sync
- Report PDF export
- Community write/reply
- Care Binder export

## 1.7 Technology Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter 3.35.4 / Dart 3.9.2 |
| State Management | Provider 6.1.5+1 |
| Local Persistence | SharedPreferences 2.5.3 |
| Charts | fl_chart ^0.69.0 |
| Progress UI | percent_indicator ^4.2.3 |
| Animations | flutter_animate ^4.5.0 |
| Fonts | google_fonts ^6.2.1 (Inter) |
| Internationalisation | intl ^0.19.0 |
| Local DB (future) | Hive 2.2.3 + hive_flutter 1.1.0 |

---

# DOCUMENT 2 — INFORMATION ARCHITECTURE

## 2.1 Route Map

```
/                   → WelcomeScreen
/onboarding         → OnboardingScreen  (5-step PageView)
/journey_created    → JourneyCreatedScreen  (celebration splash)
/main               → MainScreen  (IndexedStack shell + BottomNav)
  └─ index 0        → HomeScreen
  └─ index 1        → JourneyScreen
  └─ index 2        → DailyCheckInScreen
  └─ index 3        → CareHubScreen
  └─ index 4        → CommunityScreen

Side drawer (endDrawer from MainScreen)
  └─                → ProfileScreen

Full-screen pushes (MaterialPageRoute):
  ├─               → MedicationTrackerScreen
  ├─               → AppointmentTrackerScreen
  ├─               → LabTrackerScreen
  ├─               → LabAnalyzerScreen
  ├─               → AIAssistantScreen
  └─               → VoiceCheckInScreen
```

## 2.2 Bottom Navigation Bar (5 items)

| Index | Icon | Label | Screen |
|-------|------|-------|--------|
| 0 | home_rounded | Home | HomeScreen |
| 1 | show_chart_rounded | Journey | JourneyScreen |
| 2 | FAB circle 56x56 | Check-In | DailyCheckInScreen |
| 3 | local_hospital_rounded | Care | CareHubScreen |
| 4 | people_rounded | Community | CommunityScreen |

Profile is accessed via end-drawer (swipe from right or avatar tap).

## 2.3 Deep Navigation Map

HomeScreen
- Smart Hero Card CTA → AppointmentTrackerScreen (if appt within 7 days)
- Smart Hero Card CTA → DailyCheckInScreen (if not checked in)
- Quick Action: Scan Lab → LabTrackerScreen
- Quick Action: Voice → VoiceCheckInScreen
- Quick Action: Check-In → DailyCheckInScreen
- Quick Action: Ask AI → AIAssistantScreen
- Quick Action: My Meds → MedicationTrackerScreen
- Quick Action: Appointments → AppointmentTrackerScreen
- Labs Card "View All" → LabTrackerScreen
- Meds Card "View All" → MedicationTrackerScreen

CareHubScreen
- Medications & Adherence → MedicationTrackerScreen
- Appointments → AppointmentTrackerScreen
- Lab Tracker → LabTrackerScreen
- AI Lab Analyzer → LabAnalyzerScreen
- Ask AI Assistant → AIAssistantScreen

---

# DOCUMENT 3 — DATA MODELS SPECIFICATION

## 3.1 UserJourney

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | YES | user_{timestamp} or demo_journey |
| name | String | YES | Patient or caregiver first name |
| cancerType | String | YES | One of 8 predefined types |
| stage | String | YES | One of 5 stage values |
| treatmentPhase | String | YES | One of 8 predefined phases |
| diagnosisDate | DateTime? | NO | ISO 8601 string when stored |
| treatmentStartDate | DateTime? | NO | Used for check-in rate calculation |
| isPatient | bool | YES | true = patient, false = caregiver |
| caregiverName | String? | NO | Populated if isPatient = false |

Persistence key: "journey" (SharedPreferences, JSON)

## 3.2 CheckIn

One daily health log. One per day maximum (previous replaced on re-submission).

| Field | Type | Range | Description |
|-------|------|-------|-------------|
| id | String | — | checkin_{timestamp} |
| date | DateTime | — | Day of check-in |
| moodScore | int | 1–5 | 1=Bad, 5=Great |
| painScore | int | 1–5 | 1=None, 5=Severe |
| fatigueScore | int | 1–5 | 1=None, 5=Severe |
| nauseaScore | int | 1–5 | 1=None, 5=Severe |
| appetiteScore | int | 1–5 | 1=None, 5=Great |
| sleepScore | int | 1–5 | 1=Poor, 5=Excellent |
| medicationsTaken | bool | — | Overall flag (legacy) |
| waterGlasses | int | 0–12 | Glasses of water |
| notes | String? | — | Free-text general notes |
| foodNotes | String? | — | Free-text food diary |
| activitiesAble | bool | — | Normal activities possible |
| symptoms | List<String> | — | e.g. ['Fatigue', 'Nausea'] |

Persistence key: "check_ins" (SharedPreferences, JSON array)

## 3.3 MedLog

Per-medication, per-day dose log.

| Field | Type | Description |
|-------|------|-------------|
| medId | String | References Medication.id |
| date | DateTime | Calendar day of the log |
| takenAt | DateTime? | Timestamp of ingestion; null = not taken |

Computed getter: isTaken → takenAt != null
Persistence key: "med_logs"

## 3.4 Medication

| Field | Type | Description |
|-------|------|-------------|
| id | String | med_{timestamp} |
| name | String | Full name + strength e.g. "Tamoxifen 20mg" |
| dosage | String | e.g. "20mg", "1000 IU" |
| frequency | String | e.g. "Daily Morning", "As needed" |
| notes | String? | Optional clinical notes |
| isActive | bool | Archived meds show in history only |

Default medications (new user): Tamoxifen 20mg, Vitamin D 1000 IU, Pain Relief 500mg
Persistence key: "medications"

## 3.5 Appointment

| Field | Type | Description |
|-------|------|-------------|
| id | String | appt_{timestamp} |
| title | String | e.g. "Chemo Session #7" |
| doctorName | String | e.g. "Dr. Sarah Chen" |
| dateTime | DateTime | Full datetime |
| location | String? | Clinic name / room |
| notes | String? | Patient prep notes |
| type | String | oncologist, lab, chemo, imaging, general |
| isCompleted | bool | Marked done after appointment |

Persistence key: "appointments"

## 3.6 Milestone (runtime only, not persisted)

| Field | Type | Description |
|-------|------|-------------|
| id | String | m1–m6 |
| title | String | Milestone name |
| description | String | One-sentence detail |
| date | DateTime? | When it happened |
| phase | String | Treatment phase this belongs to |
| isCompleted | bool | Computed from current phase |
| isCurrent | bool | The active milestone |

## 3.7 Reference Constants

Cancer Types:
Breast Cancer, Lung Cancer, Colorectal Cancer, Prostate Cancer, Leukemia, Lymphoma, Ovarian Cancer, Other

Cancer Stages:
Stage I, Stage II, Stage III, Stage IV, Unknown / TBD

Treatment Phases:
Pre-Treatment (Planning), Diagnosis & Planning, Weekly Treatment (Chemo), Radiation Therapy, Surgery, Recovery, Maintenance, Survivorship

## 3.8 Lab Models

### LabReport
| Field | Type | Description |
|-------|------|-------------|
| id | String | lab_{timestamp} |
| date | DateTime | Date of lab draw |
| reportName | String | e.g. "CBC Panel – Jan 15" |
| source | String | Lab or hospital name |
| entries | List<LabEntry> | All metrics in this report |

Persistence key: "rehla_lab_reports_v2"

### LabEntry
| Field | Type | Description |
|-------|------|-------------|
| metricKey | String | Canonical key e.g. wbc, hemoglobin |
| value | double | Numeric measurement |
| unit | String | e.g. x10³/µL, g/dL |

### Lab Metric Catalog (16 metrics)

| Key | Name | Panel | Normal Range | Unit |
|-----|------|-------|-------------|------|
| wbc | White Blood Cells | CBC | 4.5–11.0 | x10³/µL |
| anc | Abs. Neutrophil Count | CBC | 1.5–8.0 | x10³/µL |
| rbc | Red Blood Cells | CBC | 3.8–5.2 | x10⁶/µL |
| hemoglobin | Hemoglobin | CBC | 12.0–17.5 | g/dL |
| platelets | Platelets | CBC | 150–400 | x10³/µL |
| hematocrit | Hematocrit | CBC | 36–52 | % |
| creatinine | Creatinine | Metabolic | 0.6–1.2 | mg/dL |
| alt | Liver ALT | Metabolic | 7–56 | U/L |
| ast | Liver AST | Metabolic | 10–40 | U/L |
| bilirubin | Total Bilirubin | Metabolic | 0.2–1.2 | mg/dL |
| glucose | Blood Glucose | Metabolic | 70–100 | mg/dL |
| sodium | Sodium | Metabolic | 136–145 | mEq/L |
| potassium | Potassium | Metabolic | 3.5–5.0 | mEq/L |
| ca153 | Cancer Antigen 15-3 | Tumour Markers | 0–31 | U/mL |
| cea | Carcinoembryonic Ag | Tumour Markers | 0–3 | ng/mL |
| ca125 | Cancer Antigen 125 | Tumour Markers | 0–35 | U/mL |
| psa | PSA | Tumour Markers | 0–4 | ng/mL |

Zone Classification (LabZone):
- green = normal
- orange = borderline
- red = abnormal
- critical = requires immediate action

---

# DOCUMENT 4 — STATE MANAGEMENT SPECIFICATION

## 4.1 Architecture

Two ChangeNotifier providers injected at app root via MultiProvider:

| Provider | Responsibility |
|----------|---------------|
| AppProvider | Journey, check-ins, medications, appointments, navigation, demo mode |
| LabProvider | Lab reports, metric timelines, AI pattern detection |

Both initialise asynchronously via .init() in main.dart.

## 4.2 AppProvider — Computed Getters

| Getter | Return | Logic |
|--------|--------|-------|
| isMedTakenToday(medId) | bool | MedLog matching medId + today + non-null takenAt |
| medLogsForDate(date) | List<MedLog> | Filter by exact calendar day |
| medAdherenceRate({days=14}) | double 0–1 | taken/total across active meds × last N days |
| hasCheckedInToday | bool | Any CheckIn with today's date |
| todayCheckIn | CheckIn? | First matching check-in for today |
| recentCheckIns | List<CheckIn> | Last 14, sorted descending |
| checkInStreak | int | Consecutive days with check-in, up to 30 |
| averageMood | double | Mean moodScore across last 14 check-ins |
| checkInRate | double 0–1 | Check-ins / days since treatment start |
| nextAppointment | Appointment? | First upcoming non-completed appointment |

## 4.3 AppProvider — Actions

| Method | Effect |
|--------|--------|
| init() | Load all data from SharedPreferences |
| activateDemoMode() | Populate demo journey + 14 check-ins + 4 meds + 3 appointments |
| exitDemoMode() | Clear demo data, reset to defaults |
| saveJourney(journey) | Persist journey, set onboardingComplete = true |
| saveCheckIn(checkIn) | Replace today's existing check-in if any, persist |
| logMedTaken(medId) | Upsert MedLog for today, persist |
| addMedication(med) | Append to list, persist |
| removeMedication(id) | Remove by id, persist |
| addAppointment(appt) | Append, persist |
| completeAppointment(id) | Set isCompleted = true, persist |
| setNavIndex(i) | Update currentNavIndex, notify listeners |
| resetJourney() | Full wipe back to new-user state |
| getMilestones() | Return 6 phase-aware Milestone objects |

## 4.4 LabProvider — Key API

| Method/Getter | Description |
|---------------|-------------|
| init() | Load from SharedPreferences key rehla_lab_reports_v2 |
| addReport(report) | Upsert + sort by date, persist |
| deleteReport(id) | Remove + persist |
| clearAll() | Wipe all lab data |
| timelineFor(key) | Chronological data points for metric key |
| latestFor(key) | Most recent LabDataPoint for metric |
| trackedMetrics | Distinct metric keys across all reports |
| overallStatus | good / caution / critical based on worst zone |
| detectPatterns() | Run AI pattern logic → List<LabPattern> |
| seedDemoData() | Insert 6 realistic reports spanning 8 weeks of chemo |

## 4.5 Persistence Schema (SharedPreferences)

| Key | Type | Content |
|-----|------|---------|
| journey | String JSON | UserJourney.toMap() |
| check_ins | String JSON array | List<CheckIn.toMap()> |
| medications | String JSON array | List<Medication.toMap()> |
| med_logs | String JSON array | List<MedLog.toMap()> |
| appointments | String JSON array | List<Appointment.toMap()> |
| onboarding_complete | bool | Has user completed onboarding |
| demo_mode | bool | Is demo mode active |
| rehla_lab_reports_v2 | String JSON array | List<LabReport.toMap()> |

---

# DOCUMENT 5 — SCREEN-BY-SCREEN UX SPECIFICATION

## SCREEN 01 — WelcomeScreen (route: /)

Purpose: First impression, mode selection.

Layout (top to bottom):
1. Gradient logo tile (72x72, rounded-20, purple gradient, heart icon)
2. App name "Rehla" — 36pt bold
3. Tagline "رحلة — Your Journey Towards Healing" — 13pt muted
4. Hero copy "Your companion between appointments." — 26pt bold
5. Sub-copy "Track your journey, reminders, and daily check-ins in minutes."
6. Feature pills: Track Symptoms / Reminders / AI Insights / Community
7. PRIMARY CTA: "Set up your journey" → /onboarding
8. SECONDARY CTA: "View demo — explore with sample data" → activateDemoMode() → /main
9. Disclaimer text (terms, privacy, medical disclaimer)

Business rules:
- If onboardingComplete = true → redirect to /main immediately
- Demo mode sets isDemoMode = true, fills demo data, navigates to /main
- Demo mode shows persistent pink banner at top of MainScreen

---

## SCREEN 02 — OnboardingScreen (route: /onboarding)

Purpose: Capture minimum viable patient profile in 5 sequential steps.
Structure: PageView (5 pages) with animated progress bar.

| Step | Title | Input Type | Validation |
|------|-------|-----------|-----------|
| 0 — Who | "Who is this journey for?" | 2-option cards: Patient / Caregiver | Must select one |
| 1 — Name | "What's your name?" | TextField | Min 2 characters |
| 2 — Cancer Type | "What type of cancer?" | 8-item grid selector | Must select one |
| 3 — Stage | "What stage?" | 5-item list | Must select one |
| 4 — Phase | "Current treatment phase?" | 8-item list | Must select one |

Navigation: Back arrow (Step 0 → Welcome; Steps 1–4 → previous page)
"Continue" button disabled if validation fails.
Completion: saveJourney() → navigate to /journey_created.

---

## SCREEN 03 — JourneyCreatedScreen (route: /journey_created)

Purpose: Celebration moment after onboarding.
Content: Animated celebration, "Your journey has been created", patient name, encouragement copy, "Go to my dashboard" button → /main.

---

## SCREEN 04 — HomeScreen (bottom nav index 0)

Purpose: Daily mission control — adaptive, contextual, time-aware.

HEADER (collapsing SliverAppBar):
Expanded state:
  - Current date (e.g. "Sunday, 5 April")
  - Time-based greeting: "Good morning/afternoon/evening, [Name]"
  - Contextual friendly message
  - Avatar circle (initial letter) — tap opens Profile drawer

Collapsed state:
  - App name "Rehla Care" left-aligned
  - Critical lab badge (red pill) if overallStatus == critical
  - Avatar circle right-aligned

SMART STATUS HERO CARD (adaptive — 4 modes):

| Priority | Condition | Display | CTA |
|----------|-----------|---------|-----|
| 1st | Lab status = critical | Lab Alert warning | View lab results → LabTrackerScreen |
| 2nd | Next appointment ≤ 7 days | Appointment countdown | View Doctor-Ready Report |
| 3rd | Not checked in today | Check-in prompt | Start Check-In |
| 4th | Default | Today's mood + pain summary | View Week Summary |

Card: 3-stop mauve-purple gradient (#D894D3 → #C178BB → #BD6BB8), white text, rounded-24.

NEXT APPOINTMENT BANNER:
Shown when nextAppointment exists.
Shows: title, doctor, formatted date/time, location. Tappable.

QUICK ACTIONS GRID (6 tiles, 2 rows of 3):

| Tile | Icon | Navigation |
|------|------|-----------|
| Scan Lab Results | science_rounded | LabTrackerScreen |
| Voice Check-In | mic_rounded (highlighted) | VoiceCheckInScreen |
| Daily Check-In | edit_note / check (state) | DailyCheckInScreen |
| Ask AI | auto_awesome_rounded | AIAssistantScreen |
| My Meds | medication_rounded | MedicationTrackerScreen |
| Appointments | calendar_month_rounded | AppointmentTrackerScreen |

LATEST LABS CARD:
- Overall status badge: Good (green) / Caution (orange) / Critical (red)
- Up to 2 recent metrics with mini progress bars + normal range text
- "View All Labs" footer → LabTrackerScreen
- Empty state: "Upload Lab Results" prompt

TODAY'S MEDS CARD:
- Circular progress indicator with today's adherence %
- Each active medication: name, dosage, taken/pending, "Mark Taken" button
- "View All Medications" footer → MedicationTrackerScreen

AI HEALTH INSIGHTS CARD:
- Placeholder summary from recent check-ins
- CTA → AIAssistantScreen

---

## SCREEN 05 — JourneyScreen (bottom nav index 1)

Purpose: Treatment phase education, milestone tracking, guidance.

Sections:
1. Phase Selector — horizontal scrollable chips (8 phases)
2. Phase Overview Card — icon + name + duration + overview paragraph
3. What to Expect — 4–6 bulleted items
4. Milestone Tracker — vertical timeline, 6 milestones (completed / current / upcoming)
5. Guidance Videos — horizontal scrollable cards with external links
6. Tips — 3–5 practical tips per phase
7. [FLAG: Appointments section here is duplicate — remove in next sprint]

Milestone statuses computed from UserJourney.treatmentPhase.

---

## SCREEN 06 — DailyCheckInScreen (bottom nav index 2)

Purpose: Daily health self-report. Two modes: Quick and Full.

QUICK MODE (default — single scrollable page):

Step 1 — Overall Mood
  MoodEmojiSelector: 5 emojis (overwhelmed → strong)
  Scores: 1=Overwhelmed, 2=Anxious, 3=Okay, 4=Hopeful, 5=Strong

Step 2 — Emotional Wellbeing
  5 coloured cards in a row (danger → warning → info → accent → primary)
  Labels: Overwhelmed / Anxious / Okay / Hopeful / Strong

Step 3 — Medications Taken Today
  If medications exist: individual per-med tap-to-mark checklist (live logMedTaken())
  If no medications: Yes/No toggle cards
  Shows: name, dosage, frequency, "Taken ✓" / "Tap to mark"

Optional — Top Concern Chips (single select):
  Pain / Fatigue / Nausea / Anxiety / Sleep / Appetite / Isolation / Fear of recurrence

Submit: "Save Quick Check-In" → saveCheckIn() → CompletionView
Link: "Add more detail (full check-in)" → switches to Full mode

FULL MODE (adds to Quick Mode):
  - Pain, Fatigue, Nausea selectors (1–5 each)
  - Sleep quality selector (1–5)
  - Appetite selector (1–5)
  - Water glasses counter (stepper, 0–12)
  - Activities able toggle (Yes/No)
  - Food notes text field (optional)
  - General notes text field (optional)

COMPLETION VIEW:
  - Celebration animation
  - Today's mood + emotional score summary
  - "Go Home" button → nav index 0

---

## SCREEN 07 — VoiceCheckInScreen

Purpose: Voice-first check-in.

Flow:
1. Microphone activation with animated pulse ring
2. Patient speaks health update
3. Speech-to-text transcription displayed
4. AI parsing maps voice → check-in fields
5. Review parsed values
6. Confirm → saveCheckIn()

Known issue: use_build_context_synchronously warning in async navigation path.

---

## SCREEN 08 — CareHubScreen (bottom nav index 3)

Purpose: Central navigation hub for all clinical-support tools.

Layout:
- Hero gradient header: "Care Hub" / "Your health tools in one place"
- Scrollable list of labeled sections

Hub Sections:

| Section | Links To | Status |
|---------|---------|--------|
| Medications & Adherence | MedicationTrackerScreen | Live |
| Appointments | AppointmentTrackerScreen | Live |
| Lab Tracker | LabTrackerScreen | Live |
| AI Lab Analyzer | LabAnalyzerScreen | Live |
| Ask AI Assistant | AIAssistantScreen | Live |
| Emotional Wellbeing | Inline summary | Live |
| Care Team | Read-only doctor list | Partial |
| Care Binder | Export summary | Placeholder |
| Support Resources | External links | Placeholder |

FLAG: Medications and Care Team sections duplicate Home screen data.

---

## SCREEN 09 — MedicationTrackerScreen

Purpose: Full medication management with AI-powered adherence tracking.

Header: Hero gradient, "AI-powered adherence tracking" subtitle

TABS (2):

Tab 1 — Today's Doses:
  Adherence Summary Card:
    - Circular progress indicator with today's adherence %
    - Count: "X of Y meds taken today"
    - 14-day streak badge
  Medication List:
    Each card: name, dosage, frequency
    Status: Taken (green) / Pending (peach)
    "Mark Taken" button → logMedTaken()
    If taken: timestamp displayed

Tab 2 — My Medications:
  Active medications list with swipe-to-delete
  Archived (isActive=false) medications collapsed section

FAB: "+ Add Medication" → bottom sheet form:
  Fields: Name, Dosage, Frequency (dropdown), Notes (optional)

---

## SCREEN 10 — AppointmentTrackerScreen

Purpose: Full appointment lifecycle management.

TABS (2):

Tab 1 — Upcoming:
  Appointments sorted ascending by dateTime
  Each card:
    - Type badge (colour-coded: oncologist=purple, lab=blue, chemo=primary, imaging=orange)
    - Title, doctor name, formatted date/time, location, notes
    - "Mark Complete" button → completeAppointment()
    - "Prepare for Appointment" → AI talking points (expansion)
  AI Reminder Card if appointment ≤ 7 days away
  Empty state: "No upcoming appointments — tap + to add"

Tab 2 — Past:
  Completed / past-due appointments sorted descending
  Each card: greyed out, "Completed" badge
  Option to add post-appointment notes

FAB: "+ Add Appointment" → bottom sheet form:
  Fields: Title, Doctor Name, Date/Time picker, Location, Type selector, Notes

---

## SCREEN 11 — LabTrackerScreen

Purpose: Upload, view, and get AI analysis of blood lab results over time.

Header: Overall status badge + Upload button

TABS (3):

Tab 1 — Metrics:
  Panel selector chips: CBC / Metabolic / Tumour Markers
  For each tracked metric in selected panel:
    - Name + short name
    - Trend sparkline (fl_chart LineChart)
    - Current value + unit
    - Colour-coded zone indicator
    - Normal range text
  Empty state: "Upload a lab report to start tracking"

Tab 2 — AI Insights:
  List of LabPattern objects from detectPatterns()
  Each pattern card: severity icon, title, description, recommendation
  Alert badge on tab if critical/red patterns exist

Tab 3 — History:
  Chronological list of LabReport objects
  Each: report name, source, date, metric count, delete button

Upload Flow (bottom sheet):
  - Enter report name, source, date
  - Add metric rows: select from catalog, enter value
  - Alias lookup for common name variants
  - Save → addReport()

Demo data: 6 pre-seeded reports spanning 8 weeks of simulated chemo
(baseline → nadir → recovery → improvement)

---

## SCREEN 12 — LabAnalyzerScreen

Purpose: Manual lab entry with AI interpretation for a single report.

Flow:
1. Enter lab values (metric selector + value input)
2. AI analyses each entry against normal ranges in real-time
3. Summary shows zones (green/orange/red/critical) per value
4. Optional: save to LabProvider as new LabReport

---

## SCREEN 13 — AIAssistantScreen

Purpose: Conversational AI health assistant, knowledge-base driven.

UI:
- Chat interface (user bubbles right / AI bubbles left)
- Pulsing AI avatar during typing animation
- Scrollable history

Quick Suggestion Chips (8):
  - "What do my lab results mean?"
  - "Side effects of chemo?"
  - "Tips for nausea?"
  - "When to call my doctor?"
  - "What is nadir?"
  - "Managing fatigue tips"
  - "Foods good during treatment"
  - "Infection warning signs"

Knowledge Base Topics:

| Key | Keywords | Key Content |
|-----|---------|-------------|
| nausea | nausea, vomit, sick, queasy | Timing, BRAT diet, ginger; red flags |
| fatigue | tired, fatigue, exhausted, energy, weak | Conservation, gentle activity, nutrition |
| labs | lab, blood, results, cbc, wbc, markers | CBC + metabolic + tumour marker interpretation |
| nadir | nadir, lowest, counts drop | Timing, protection strategies, recovery |
| doctor | doctor, call, emergency, when, worried | Red flag list (fever, bleeding, chest pain...) |
| side effects | side effects, chemo, hair loss | Alopecia, nausea, neuropathy, mucositis |
| food | food, eat, nutrition, diet, meal | Best foods, foods to limit, tips |
| infection | infection, fever, immune, neutropenia | Fever protocol, hygiene, avoidance |

Response logic:
- Input matched against keywords (case-insensitive)
- Match → rich formatted response with bold section headers
- No match → empathetic fallback + suggestion chips
- Simulated typing delay 0.8–1.5s

---

## SCREEN 14 — CommunityScreen (bottom nav index 4)

Purpose: Peer support feed. Read-only in MVP.

Header: Gradient, "Safe Space" badge, "You are not alone 💜"

Tabs (inside header):
  Feed / My Posts / Support Groups

Filters:
  Cancer type: All / Breast / Colorectal / Lymphoma / Lung / Prostate
  Phase: All / Diagnosis / Chemo / Radiation / Surgery / Recovery

Feed post cards:
  - Avatar (coloured circle, initial)
  - Username + cancer type tag + phase tag
  - Posted date (relative)
  - Post body text
  - Reaction counts (read-only)
  - Reply count (read-only)
  - "Reply" button → PLACEHOLDER (no functional state)

My Posts tab: Empty state — write feature pending
Support Groups tab: Static group cards

---

## SCREEN 15 — ProfileScreen (end-drawer)

Purpose: User identity, stats, settings, data management.

Profile Card:
  - Avatar (initial, purple background)
  - Name, cancer type, stage, treatment phase
  - Edit icon → edit profile bottom sheet

Journey Stats (3 cards):
  - Check-ins: provider.checkIns.length
  - Day Streak: provider.checkInStreak
  - Med Rate: [BUG: hardcoded "95%" — should be medAdherenceRate()]

Settings:
  - Account: Create Account / Log In (placeholder)
  - Privacy & Data: Export Data / Delete All Data
  - Help & Support: Tutorial / Contact / About

Data Security Badge: "Your data stays on your device."

Reset Journey: Confirmation dialog → resetJourney() → navigate to /

---

# DOCUMENT 6 — DESIGN SYSTEM SPECIFICATION

## 6.1 Colour Palette

### Brand Colours
| Token | Hex | Usage |
|-------|-----|-------|
| background | #FCF7FC | Page canvas — blush-lilac |
| surface | #FFFFFF | Cards, inputs |
| primary | #9B5DC4 | Brand purple — icons, active state |
| primaryDark | #7A3FAA | Pressed state |
| primaryLight | #D370C8 | Mid purple-pink |
| primarySurface | #EEE0F9 | Pale purple wash |
| accent | #F75B9A | Rose pink — active tab, highlights |
| accentLight | #FDE8F2 | Pale rose wash |

### Hero Gradient
Stops: #D894D3 → #C178BB → #BD6BB8
Direction: topLeft to bottomRight
Used on: Home hero card, all screen headers, bottom nav FAB

### Semantic Colours
| Token | Hex | Meaning |
|-------|-----|---------|
| success | #22C55E | Done, taken, normal range |
| successLight | #EAF8EC | Green card background |
| warning | #FF7A00 | Pending, due, borderline |
| warningLight | #FFF1E4 | Peach card background |
| danger | #DC2626 | Critical, errors |
| dangerLight | #FEF2F2 | Red card background |
| info | #2563EB | Informational, diagnosis phase |

### Text Hierarchy
| Token | Hex | Usage |
|-------|-----|-------|
| textPrimary | #3A2A3F | Headings, primary content |
| textSecondary | #6B4F72 | Body text |
| textTertiary | #B68AB3 | Captions, secondary labels |
| textMuted | #CCA8CC | Hints, disabled |
| textOnDark | #FFFFFF | Text on gradient backgrounds |

### Symptom Domain Colours
| Symptom | Hex |
|---------|-----|
| Pain | #DC2626 |
| Fatigue | #FF7A00 |
| Nausea | #2563EB |
| Appetite | #22C55E |
| Sleep | #9B5DC4 |
| Mood | #F75B9A |

### Treatment Phase Colours
| Phase | Hex |
|-------|-----|
| Diagnosis | #2563EB |
| Chemo | #9B5DC4 |
| Radiation | #FF7A00 |
| Surgery | #DC2626 |
| Recovery | #22C55E |
| Immunotherapy | #4F46E5 |

## 6.2 Typography

Font family: Inter (Google Fonts) — used exclusively throughout.

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| display | 28pt | 700 | Hero card headings |
| headline | 20pt | 700 | Screen titles |
| title | 16pt | 600 | Section headings |
| subtitle | 14pt | 500 | Card subtitles |
| body | 14pt | 400 | Primary body text |
| bodySmall | 13pt | 400 | Secondary body |
| caption | 12pt | 500 | Labels, timestamps |
| label | 11pt | 700 | Badges, status chips |
| overline | 10pt | 700 | Nav labels, micro-text |

Line heights: 1.25 (headlines), 1.5 (body), 1.4 (captions)

## 6.3 Spacing System

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight gaps |
| sm | 8px | Icon-label gaps |
| md | 16px | Standard padding |
| lg | 24px | Section spacing |
| xl | 32px | Large section gaps |
| xxl | 48px | Hero padding |

Page padding: 20px horizontal, 24px vertical
Card padding: 16–20px all sides

## 6.4 Border Radius

| Context | Radius |
|---------|--------|
| Cards | 24px |
| Hero | 28px |
| Chips/badges | 20px |
| Buttons | 14px |
| Inputs | 12px |
| Icon tiles | 12px |
| Small badges | 8px |

## 6.5 Shadows

| Shadow | Spec |
|--------|------|
| Card | color: rgba(155,93,196,0.07), blur: 18px, offset: 0 4px |
| Elevated | Stronger version for modals |
| FAB | Coloured glow matching button gradient |
| Nav | Upward shadow under bottom navigation bar |
| Danger | Red-tinted for critical alert cards |

## 6.6 Component Library

PurpleGradientButton
  Full-width primary CTA. Gradient #9B5DC4 → #D370C8.
  White text + optional icon. Loading spinner state.

RehlaCard
  Standard card container. White, r=24, purple-tinted shadow.

SectionHeader
  Title left-aligned, optional "See all" right-aligned.

MoodEmojiSelector
  5-emoji horizontal row. Animated selection (scale + colour).

ActionTile
  64x64 container, icon, label, optional gradient active state.

AdherenceSummary
  Circular progress + textual breakdown. 14-day window.

HubLabel
  CareHub row: icon + title + chevron. Tappable.

NavItem
  Bottom nav item. Animated width on selection. Icon + label with colour transition.

CheckInFAB
  56px circle FAB. State-aware gradient:
  Purple = not checked in, Rose = checked in.

## 6.7 Gradients Reference

| Name | Stops | Usage |
|------|-------|-------|
| heroGradient | #D894D3 → #C178BB → #BD6BB8 | All screen headers |
| heroGradientSoft | Same at lower opacity | Demo banner |
| cardGradient | Soft purple variation | Check-in FAB unchecked |
| accentGradient | Rose variation | Check-in FAB checked |
| aiGradient | Purple-blue | AI feature highlights |

---

# DOCUMENT 7 — AI FEATURES SPECIFICATION

## 7.1 AI Lab Pattern Detection (LabProvider.detectPatterns())

Pattern Types:

| Type | Trigger | Severity |
|------|---------|----------|
| criticalAlert | Latest value in critical zone | Critical |
| rapidDecline | ≥20% drop + currently red/orange (non-tumour metrics) | Red |
| risingConcern | ≥15% rise in tumour marker + currently orange/red | Orange |
| nadirDetected | 3+ readings: previous was lowest, now recovering, still below normal | Orange |
| normalRestored | Current = green, previous = red/orange/critical | Green |
| steadyImprovement | Tumour marker declining ≥10% OR 3+ monotonically improving readings | Green |
| stable | No significant change at current zone | Varies |

Output per pattern:
- type (PatternType)
- metricKey (canonical key)
- title (human-readable headline)
- description (2-3 sentence clinical explanation with actual values)
- recommendation (actionable patient guidance)
- severity (LabZone — determines display colour + sort order)

Sort order: Critical → Red → Orange → Green

Critical Recommendations:
  ANC: Fever ≥38°C → go to ER; avoid crowds
  WBC: Frequent handwashing; avoid sick contacts; report fever
  Platelets: Avoid NSAIDs, falls, cuts; report bruising/bleeding
  Hemoglobin: May need transfusion; report extreme fatigue/breathlessness
  Creatinine: Possible kidney injury; fluids; dose adjustment may be needed
  Potassium: Palpitations/weakness → emergency care
  Default: Contact oncology team or go to nearest emergency department

## 7.2 AI Health Assistant

Architecture:
- Simulated AI (no LLM API call in MVP)
- Input → keyword matching against 8-topic knowledge base
- Response delivered with animated typing delay (0.8–1.5s)
- Rich markdown-style formatting (bold headers, bullet points)

Response quality standards per topic:
- Clinical accuracy (oncology-aligned)
- Patient-facing language (no jargon)
- Red flag escalation ("Call your care team if...")
- Actionable next steps
- Empathetic tone

Fallback: Empathetic acknowledgement + available topic chips + check-in encouragement

Future Phase — Real AI Integration:
- Replace keyword matcher with LLM API (OpenAI GPT-4 / Azure OpenAI)
- Patient context injection: cancer type, phase, recent labs, last 7 check-in scores
- Structured system prompt with clinical safety guardrails
- Mandatory medical disclaimer on every AI response

## 7.3 AI Appointment Preparation (Partial MVP)

In AppointmentTrackerScreen, expandable section shows:
- AI-generated talking points based on appointment type
- Derived from: recent check-in trends, lab status, medication adherence
- Example: "Your pain scores have been 3–4 this week — mention this to your oncologist"
- Current state: Card exists, content is placeholder

## 7.4 Smart Home Card Logic

Priority decision tree (lightweight "AI"):

IF critical lab → show Lab Alert card
ELSE IF appointment within 7 days → show Appointment Countdown card
ELSE IF not checked in today → show Check-In Prompt
ELSE → show Today's Summary (mood + pain)

---

# DOCUMENT 8 — KNOWN ISSUES, GAPS & BACKLOG

## 8.1 Known Bugs

| ID | Severity | Location | Description | Fix |
|----|----------|----------|-------------|-----|
| BUG-01 | CRITICAL | home_screen.dart | _NextAppointmentBanner widget was missing (caused web build failure) | FIXED |
| BUG-02 | HIGH | profile_screen.dart:79 | Med adherence hardcoded as "95%" | Replace with (provider.medAdherenceRate() * 100).round()% |
| BUG-03 | MEDIUM | voice_checkin_screen.dart | use_build_context_synchronously warning | Wrap with if (mounted) guard |
| BUG-04 | MEDIUM | journey_screen.dart | Duplicate appointments section | Remove from JourneyScreen |
| BUG-05 | MEDIUM | File structure | Two copies of appointment_tracker_screen.dart | Delete screens/appointments/ copy |
| BUG-06 | LOW | welcome_screen.dart | App name shows "Rehla" not "Rehlah" | Update text string |

## 8.2 Feature Gaps

| ID | Priority | Feature | Description |
|----|----------|---------|-------------|
| GAP-01 | HIGH | Push notifications | Medication + appointment reminders not implemented |
| GAP-02 | HIGH | Community write/reply | Post creation and reply state missing |
| GAP-03 | HIGH | Report PDF generation | Doctor-Ready Report button is placeholder |
| GAP-04 | HIGH | Care Binder export | Referenced in Care Hub, not implemented |
| GAP-05 | HIGH | Real AI/LLM | AI Assistant uses keyword matching, not real language model |
| GAP-06 | HIGH | Profile nav tab | Profile accessible via avatar only; no bottom nav tab |
| GAP-07 | MEDIUM | Lab report OCR | Lab upload requires manual entry; camera scan not implemented |
| GAP-08 | MEDIUM | Appointment calendar export | No Google Calendar / device calendar sync |
| GAP-09 | MEDIUM | Hospital platform link | Care Team section has no external system integration |
| GAP-10 | MEDIUM | Consistent empty states | Some screens lack proper empty-state illustrations |
| GAP-11 | LOW | Loading skeletons | No shimmer/skeleton during data initialisation |
| GAP-12 | LOW | Caregiver UX | Onboarding captures caregiver but UI is always patient-centric |

## 8.3 Next Phase Roadmap

Phase 2 — Next Sprint:
1. Fix BUG-02 (medication adherence %)
2. Fix BUG-03, BUG-04, BUG-05, BUG-06
3. Community reply/post with local state
4. Consistent empty states and loading patterns globally
5. PDF report generator (check-in summary + appointment prep sheet)

Phase 3 — Medium Term:
1. Push notifications for medications and appointments
2. Real LLM integration (OpenAI or Azure) for AI Assistant
3. Lab report camera OCR via Google ML Kit
4. Hospital calendar integration via Android Intent system
5. Profile as bottom-nav tab

Phase 4 — Long Term:
1. Account creation + cloud sync (Firebase)
2. Caregiver mode with separate UX flows
3. iOS build
4. Multi-language support (Arabic RTL as primary second language)
5. Integration with KSA hospital platforms (NPHIES / Sehhaty ecosystem)

## 8.4 Technical Debt

| Item | Description |
|------|-------------|
| Duplicate colour classes | _C class redefined locally in home_screen, medication_tracker, appointment_tracker — should all import AppColors |
| No unit tests | Zero test coverage currently |
| No error boundaries | Unhandled exceptions will crash silently |
| SharedPreferences only | No structured DB for complex queries — needs Hive migration |
| No offline-first strategy | App assumes device storage is always available |

---

END OF DOCUMENT
Version 1.0 | April 2026 | Rehlah — Internal Team Specifications
Live prototype: https://nadbrahmi.github.io/Rehlah/
Codebase: https://github.com/nadbrahmi/Rehlah

