# REHLAH — Document 10: Complete Screen Specification
## Full UI/UX Inventory · All Screens · Flutter Prototype
**Version 1.0 | April 2026 | Confidential**
**Source:** GitHub repo https://github.com/nadbrahmi/Rehlah
**Live prototype:** https://nadbrahmi.github.io/Rehlah/

---

> **How to read this document**
> Each screen block uses a consistent structure:
> Screen name · Route · File path · Entry point · UI elements · Text content · States · Interactions · Colors & assets.
> All hex codes, font sizes, and animation durations are taken directly from the source code unless otherwise noted.
> Design rationale from Document 09 (14-Day UX Flow) is cited where relevant.

---

## GLOBAL DESIGN TOKENS

### Color Palette (AppColors)
| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#FCF7FC` | App-wide screen background |
| `surface` | `#FFFFFF` | Cards, modals, sheets |
| `primary` | `#9B5DC4` | Primary buttons, active nav, key accents |
| `primaryLight` | `#D370C8` | Gradient endpoints, soft accents |
| `primarySurface` | `#EEE0F9` | Button backgrounds, chip fills |
| `primarySurface2` | `#E4D0F5` | Hover states, card backgrounds |
| `accent` (rose) | `#F75B9A` | Mood high, accent icons, celebration states |
| `accentLight` | `#FFF0F6` | Rose-tinted backgrounds |
| `textPrimary` | `#3A2A3F` | Main body text, headings |
| `textSecondary` | `#6B4F72` | Subtitles, captions |
| `textMuted` | `#B68AB3` | Placeholders, disabled |
| `divider` | `#E8D8EC` | Dividers, subtle borders |
| `border` | `#D8C8DC` | Input borders |
| `heroGradient` | `#D894D3 → #C178BB → #BD6BB8` (135°) | SliverAppBar headers, welcome hero, FAB |
| `success` | `#22C55E` | Taken medication, good lab zone, streak |
| `warning` | `#FF7A00` | Orange lab zone, upcoming alerts |
| `danger` | `#DC2626` | Red lab zone, critical alerts |
| `info` | `#2563EB` | Informational alerts, diagnosis phase |
| `diagnosis` phase color | `AppColors.diagnosis` | Diagnosis & Planning phase accent |

### Typography
- **Font family:** Inter (via `GoogleFonts.inter`)
- **Display / Hero headline:** 28 px, `FontWeight.w700`, color `textPrimary`, letterSpacing -0.3
- **Section headline:** 20–24 px, `FontWeight.w700`
- **Card title:** 16–18 px, `FontWeight.w700`
- **Body:** 14–15 px, `FontWeight.w400`, lineHeight 1.5–1.6
- **Caption / tag:** 11–13 px
- **Micro stats:** 11 px, `FontWeight.w500`

### Reusable Components
| Component | Description |
|-----------|-------------|
| `PurpleGradientButton` | 56 px height, heroGradient fill, white text+icon, rounded 16 px, shadow |
| `RehlaCard` | White card, 24 px radius, dual drop shadows, 16 px default padding |
| `MoodEmojiSelector` | 5-emoji row (😫 😔 😐 🙂 😊), selected grows to 52 px with purple ring |
| `ScoreSlider` | Symptom slider: Pain / Fatigue / Nausea / Appetite / Sleep |
| `SectionHeader` | Bold section label with optional trailing action |
| `_CheckInFAB` | Center nav FAB, gradient shifts purple↔rose based on `hasCheckedInToday` |

---

## SCREEN 1 — Welcome Screen

```
Screen:       Welcome
Route:        /
File:         lib/screens/onboarding/welcome_screen.dart
Accessed from: App cold launch
```

### UI Elements
| Zone | Element | Detail |
|------|---------|--------|
| Hero (top ~40%) | Gradient container | `#D894D3 → #C178BB → #BD6BB8`, 135°, `bottomLeft/Right radius 32` |
| Hero | Animated logo icon | `Icons.favorite_rounded`, white, 40 px, inside 80×80 container with white 20% bg, 24 px radius, 1.5 px border |
| Hero | Arabic name | "رحلة", 22 px w700, white 90% |
| Hero | English name | "R E H L A H", 14 px w700, white 70%, letterSpacing 5.0 |
| Hero | Tagline | "Your companion between appointments", 13 px, white 75% |
| Hero | Micro-stats row | 3 items: 💜 For patients · 🤝 For caregivers · 🌟 Judged by none — 11 px, separated by 3×3 white 40% dots |
| Content | Headline | "You don't have to navigate this alone." — 24 px w700 `textPrimary`, lineHeight 1.28, letterSpacing -0.3, centered |
| Content | Sub-headline | "Rehlah helps you track how you feel, understand your results, and remember what matters most between appointments." — 15 px, `textSecondary`, lineHeight 1.6 |
| Content | Feature pills | Wrap row, 5 pills: 💜 Track symptoms · 🧪 Lab results · 💊 Medications · 🤝 Community · 🤖 AI insights — `primarySurface` bg, `divider` border, 20 px radius, 13/14 px pill padding |
| Content | Trust badge card | `primarySurface` bg, 16 px radius, 3 columns: 🔒 Private & secure · 📱 Stays on your device · 🚫 No account needed — icons `primary` color, 11 px labels |
| Content | Primary CTA | `PurpleGradientButton`: "Set up your journey" + `Icons.arrow_forward_rounded` → navigates to `/onboarding` |
| Content | Demo CTA | Secondary bordered button: `play_circle_outline_rounded` + "Explore with demo data" — `surface` bg, `primary` border 25% alpha, `primary` text — activates demo mode → `/main` |
| Content | Privacy disclaimer | "No account needed · Your data stays on your device\nRehlah supports you, but does not replace medical advice." — 11 px, `textMuted`, centered |

### Animations
| Animation | Controller | Duration | Detail |
|-----------|-----------|---------|--------|
| Screen fade-in | `_fadeCtrl` | 600 ms | `CurvedAnimation(Curves.easeOut)`, wraps full body |
| Logo heartbeat pulse | `_pulseCtrl` | 1500 ms, repeat | `Tween(1.0 → 1.04)`, `ScaleTransition` on logo container |

### Text Content (verbatim)
- Headline: **"You don't have to navigate this alone."**
- Sub-headline: "Rehlah helps you track how you feel, understand your results, and remember what matters most between appointments."
- Primary CTA label: **"Set up your journey"**
- Demo CTA label: "Explore with demo data"
- Privacy line: "No account needed · Your data stays on your device · Rehlah supports you, but does not replace medical advice."
- Hero tagline: "Your companion between appointments"
- Micro-stats: "For patients" / "For caregivers" / "Judged by none"
- Trust badges: "Private & secure" / "Stays on your device" / "No account needed"

### States
| State | Description |
|-------|-------------|
| Default | Fade-in animation plays, logo pulses, all static content visible |
| Demo tap | Calls `AppProvider.activateDemoMode()`, shows demo banner on MainScreen |

### Interactions
| Element | Action | Result |
|---------|--------|--------|
| "Set up your journey" button | Tap | `Navigator.pushNamed(context, '/onboarding')` |
| "Explore with demo data" | Tap | `AppProvider.activateDemoMode()` → `Navigator.pushReplacementNamed(context, '/main')` |

### Design Rationale (Doc 09)
Screen must answer in 3 seconds: "This was made for me / This is safe / I don't have to do everything right now." No red colours. No statistics. No clinical imagery.

---

## SCREEN 2 — Onboarding (5-Step Flow)

```
Screen:       Onboarding
Route:        /onboarding
File:         lib/screens/onboarding/onboarding_screen.dart
Accessed from: Welcome Screen (primary CTA)
```

### Shared Chrome
- `SafeArea` wraps content
- **Top bar:** Back `IconButton` (→ `primarySurface` bg, 12 px radius) | 5 animated progress dots | Skip `TextButton` (steps 0–1 only)
- **Progress dots:** Active dot = 22 px wide × 8 px tall, `primary` color; past dots = 8×8, `primaryLight`; future = 8×8, `divider`. All 300 ms `AnimatedContainer` transitions
- **Bottom CTA:** `PurpleGradientButton`, full width, `fromLTRB(24, 8, 24, 24)` padding. Label switches: steps 0–3 = "Continue" + `arrow_forward_rounded`; step 4 = "Begin My Journey" + `auto_awesome_rounded`. Opacity fades to 0.45 when `_canContinue == false`
- **Page transitions:** 380 ms `Curves.easeInOutCubic`; `NeverScrollableScrollPhysics` on `PageView`

---

### Step 1 — Role Selection (page 0)

**Headline:** "Let's make Rehlah yours." — 28 px w700, `textPrimary`
**Sub:** "Who will be using the app?" — 15 px, `textSecondary`

**Role cards** (two `_RoleCard` widgets):
| Option | Emoji | Title | Subtitle |
|--------|-------|-------|---------|
| Patient | 💜 | "I am a patient" | "I'm going through treatment" |
| Caregiver | 🤝 | "I am a caregiver" | "I'm supporting someone I love" |

**Role card spec:**
- 20 px all-side padding, 18 px radius
- **Unselected:** `surface` bg, `divider` 1 px border
- **Selected:** `primarySurface` bg, `primary` 2 px border, `primary` 12% shadow (blurRadius 16, offset 0,4)
- Right-side radio circle: 24×24, fills `primary` with white check when selected
- 200 ms `AnimatedContainer` transitions

**Info note card:** "Both roles are equal here. Rehlah is built for patients and caregivers alike." — 12 px, `textSecondary`, `primarySurface` bg, 14 px radius

**Continue enabled when:** `_whoIsThis.isNotEmpty` (defaults to 'patient' → button active immediately)

---

### Step 2 — Name Entry (page 1)

**Headline:** "What should we call you?" — 28 px w700
**Sub (patient):** "Just your first name is enough."
**Sub (caregiver):** "So Rehlah feels like it was made just for you."

**TextField spec:**
- `autofocus: true`, `textCapitalization: TextCapitalization.words`
- Font: 22 px w600, `textPrimary`
- Hint: "Your first name" (patient) / "e.g. Ahmad" (caregiver), 22 px w400 `textMuted`
- Borders: `surface` fill, `border` 1 px enabled, `primary` 2 px focused, 16 px radius

**Live greeting preview:** `FadeTransition` on `_greetingFade` (400 ms `Curves.easeOut`)
- Triggers when `name.length >= 2`
- Content: `"Hi [firstName] 💜"` — 22 px w700, `primary`, centered
- Container: gradient `#EEE0F9 → #F5E8F8`, 16 px border, 16 px radius

**Privacy note card:** `lock_outline_rounded` icon + "Your data stays on this device. No account required." — 12 px `textSecondary`, `primarySurface` bg

**Continue enabled when:** `_name.length >= 2`

---

### Step 3 — Cancer Type (page 2)

**Headline:** "What type of cancer is it?" — 28 px w700
**Sub:** "This helps us show you the most relevant guidance." — 15 px, `textSecondary`

**Cancer type list** (scrollable, `_CompactOptionCard` for each):
| Type | Emoji |
|------|-------|
| Breast Cancer | 🎀 |
| Lung Cancer | 🫁 |
| Colorectal Cancer | 🔵 |
| Prostate Cancer | 💙 |
| Blood / Hematologic | 🩸 |
| Lymphoma | 🟣 |
| Thyroid Cancer | 🦋 |
| Skin Cancer | 🌞 |
| Ovarian Cancer | 💜 |
| Cervical Cancer | 💜 |
| Other | 💜 |

**`_CompactOptionCard` spec:**
- 13 px horizontal, 16 px vertical padding; 14 px radius
- Unselected: `surface` bg, `divider` 1 px border
- Selected: `primarySurface` bg, `primary` 1.8 px border
- 20 px radio circle right; 200 ms animated

**Continue enabled when:** `_cancerType.isNotEmpty`

---

### Step 4 — Stage & Treatment Phase (page 3)

**Headline:** "Where are you in your journey?" — 28 px w700
**Sub:** "Take your time — both are optional to update later." — 15 px, `textSecondary`

**SECTION A — Cancer Stage**
Label: "What stage is your cancer?" — 14 px w600
Layout: 2×2 grid of `_StageTile` + 1 full-width "Not sure" tile

| Stage tiles |
|-------------|
| Stage I · Stage II (row 1) |
| Stage III · Stage IV (row 2) |
| "Not sure yet — I'll add this later" (full-width, centered text) |

**`_StageTile`:** Expanded, 16 px vertical padding, 14 px radius; selected = `primarySurface` bg + `primary` 2 px border + `primary` text; 200 ms animated

**SECTION B — Treatment Phase**
Label: "What phase of treatment are you in?" — 14 px w600
Layout: 3×2 `GridView.count`, crossAxisSpacing/mainAxisSpacing 8, childAspectRatio 1.0

| Phase | Emoji |
|-------|-------|
| Diagnosis & Planning | 🔬 |
| Chemotherapy | 💊 |
| Radiation | ☢️ |
| Surgery | 🏥 |
| Recovery | 🌱 |
| Immunotherapy | 💉 |

**Phase tile:** 14 px radius, selected = `primarySurface` + `primary` 1.8 px border; emoji 26 px; label 10 px w600 `textSecondary` (selected → `primary`)

**Phase description banner** (appears when phase selected):
- `AnimatedContainer`, 200 ms
- `primarySurface` bg, `divider` border, 10 px radius
- Italic 12 px `textSecondary`

| Phase | Description shown |
|-------|------------------|
| Diagnosis & Planning | "Meeting your care team and getting your full picture" |
| Chemotherapy | "Treatment sessions to destroy or shrink cancer cells" |
| Radiation | "Targeted radiation to treat the tumour area" |
| Surgery | "Surgical procedure to remove or treat cancer" |
| Recovery | "Rest and healing after active treatment" |
| Immunotherapy | "Building your immune system to fight cancer" |

**Continue enabled when:** `_treatmentPhase.isNotEmpty` (stage is optional)

---

### Step 5 — Dates (page 4)

**Headline:** "Two last things — both are optional." — 28 px w700
**Sub:** "These dates help us personalise your milestones. Skip them if you're not sure yet." — 15 px, lineHeight 1.5

**Date pickers** (2 × `_DatePicker`):
| Field | Label | Placeholder hint |
|-------|-------|-----------------|
| Diagnosis date | "📅 When were you diagnosed?" | "Optional · e.g. March 15, 2026" |
| Treatment start | "💊 When did treatment start?" | "Optional · e.g. April 1, 2026" |

**`_DatePicker` spec:**
- `showDatePicker` with `primary` theme accent, range: 2 years back to 1 year ahead
- Container: `surface` bg, 14 px radius; unset = `border` 1 px; set = `primary` 1.5 px
- Row: calendar icon (18 px) + text + trailing "Tap to set" / "✓" (`success`)

**Info card (bottom):** 💜 emoji + "Even without dates, Rehlah will track your journey from today. You can always add these later in settings." — 12 px, `textSecondary`

**Continue always enabled** (dates are fully optional)

**On tap "Begin My Journey":**
1. Creates `UserJourney(id, name, cancerType, stage, treatmentPhase, treatmentStartDate, isPatient)`
2. Calls `AppProvider.saveJourney(journey)`
3. `Navigator.pushReplacementNamed(context, '/journey_created')`

---

## SCREEN 3 — Journey Created (Celebration)

```
Screen:       Journey Created
Route:        /journey_created
File:         lib/screens/onboarding/journey_created_screen.dart
Accessed from: Onboarding Step 5 (CTA "Begin My Journey")
```

### UI Elements
| Element | Detail |
|---------|--------|
| 🎉 Confetti emoji | Top center, large display |
| Pulsing 💜 heart | `ScaleTransition` (1.5 s heartbeat loop, scale 1.0→1.04) |
| Headline | "Your journey begins today, [firstName]." — 28 px w700, centered |
| Sub-headline | "Rehlah will be right here with you every step of the way." — 14 px, `textSecondary` |
| First milestone card | Label: "Your first milestone" (12 px grey) + milestone tile: emoji + title + description |
| Quick wins list | "💜 Do your first 2-minute check-in · 💊 Add your medications · 🧪 Log your lab results · 🤝 Read a community story" |
| CTA button | "Go to my journey" → `PurpleGradientButton` |
| Countdown hint | "Continuing in [n]s..." — updates each second, 8 s total |

### Animations
| Controller | Duration | Purpose |
|-----------|---------|---------|
| `_heartCtrl` | 1500 ms, repeat | Heartbeat scale pulse on 💜 |
| `_fadeCtrl` | 700 ms, forward | Main screen fade-in |
| `_countdownCtrl` | 8000 ms | Countdown timer (updates `_secondsLeft`) |

### First Milestone by Phase
| Phase | Emoji | Title | Description |
|-------|-------|-------|-------------|
| Diagnosis & Planning | 🔬 | "First Oncologist Visit" | "Meeting your specialist and getting your full picture" |
| Chemotherapy | 💊 | "First Treatment Session" | "Beginning your chemotherapy regimen" |
| Radiation | ☢️ | "Radiation Planning CT" | "Mapping your treatment zone with precision imaging" |
| Surgery | 🏥 | "Pre-Surgery Consultation" | "Final preparations and consent for your procedure" |
| Recovery | 🌱 | "First Follow-Up Scan" | "Checking your recovery progress" |
| Immunotherapy | 💉 | "First Infusion Session" | "Starting your immunotherapy protocol" |

### States
| State | Trigger | Behaviour |
|-------|---------|-----------|
| Default | Screen mounted | Animations start, countdown begins |
| Auto-navigate | 8 s elapsed | `Navigator.pushReplacementNamed('/main')` |
| Manual continue | Any tap on CTA | Same navigation immediately |

---

## SCREEN 4 — Main Shell

```
Screen:       Main Shell
Route:        /main
File:         lib/screens/home/main_screen.dart
Accessed from: Journey Created screen / Demo mode launch
```

### Architecture
- **Scaffold** with `endDrawer` = `ProfileScreen` wrapped in `Drawer`
- **Body:** Optional `_DemoBanner` (top) + `IndexedStack` of 5 screens
- **Bottom nav:** `_BottomNav` with 4 `_NavItem` + central `_CheckInFAB`

### IndexedStack Tabs
| Index | Screen | Nav Icon | Nav Label |
|-------|--------|---------|----------|
| 0 | `HomeScreen` | `home_rounded` | "Home" |
| 1 | `JourneyScreen` | `show_chart_rounded` | "Journey" |
| 2 | `DailyCheckInScreen` | FAB center | "Check-In" |
| 3 | `CareHubScreen` | `local_hospital_rounded` | "Care" |
| 4 | `CommunityScreen` | `people_rounded` | "Community" |

### Bottom Nav Spec
- Container: `surface` bg, `BorderRadius.vertical(top: 28)`, `divider` top border 1 px, `AppShadows.nav`
- Nav item selected: `primary` 10% bg pill, 16 px horizontal padding; icon `primary` 22 px; label 10 px w700 `primary`
- Nav item unselected: transparent bg, icon `textMuted`, label 10 px w400 `textMuted`
- 200 ms `AnimatedContainer` / `AnimatedDefaultTextStyle`

### Check-In FAB (`_CheckInFAB`) Spec
- 56×56 circle
- **Not checked in:** `AppColors.cardGradient` (purple gradient), icon `edit_note_rounded` white 26 px
- **Checked in today:** `AppColors.accentGradient` (rose gradient), icon `check_rounded` white 26 px
- Shadow: `primary` or `accent` at 28%/50% opacity (50% when active tab)
- Label: "Check-In", 10 px w500/w700

### Demo Banner (`_DemoBanner`)
- Shows only when `provider.isDemoMode == true`
- Container: `AppColors.heroGradientSoft` gradient, full width
- Content: play icon + "Demo Mode — Sarah's journey (sample data)" + "Exit" pill button
- "Exit" tap: `provider.exitDemoMode()` → `/`

### Profile Drawer
- Opens via `Scaffold.of(context).openEndDrawer()`
- Contains `ProfileScreen` (see Screen 16)

---

## SCREEN 5 — Home Screen

```
Screen:       Home
Route:        (index 0 in MainScreen)
File:         lib/screens/home/home_screen.dart
Accessed from: Main Shell bottom nav "Home"
```

### Layout Structure
`CustomScrollView` with `BouncingScrollPhysics`, containing these slivers in order:

1. `SliverAppBar` — Greeting header (collapsing)
2. `SmartStatusCard` — Priority hero card (dynamic)
3. `_NextAppointmentBanner` — (conditional)
4. `_QuickActionsGrid`
5. `_LatestLabsCard`
6. `_MedsCard`
7. `_14DayJourneyDots`
8. `_PhaseGuideCard`
9. `_CommunityStoryCard`
10. `_AIInsightsCard`
11. `SliverPadding` spacer

### SliverAppBar (Greeting Header)
- Gradient bg: `#D894D3 → #C178BB → #BD6BB8`
- `expandedHeight`: ~120 px
- Greeting: "Good [morning/afternoon/evening], [firstName] 💜" — 20 px w600, white
- Sub: "Day [n] of your journey • [date]" — 13 px, white 70%
- Pinned; on collapse shows compact "Rehlah" title with profile icon that opens endDrawer

### SmartStatus Hero Card
The most important card on the home screen. Renders one of 7 priority branches:

| Priority | Condition | Card content |
|----------|-----------|-------------|
| 1 — Lab Alert | `lab.overallStatus == 'Critical'` | 🔴 "⚠️ Lab Alert" + critical metric name + "View lab report →" → `LabTrackerScreen` |
| 2 — Upcoming Appt | `nextAppointment` within 48 h | 📅 Appointment name + "In [n] hours" badge + "See details →" → `AppointmentTrackerScreen` |
| 3 — Day 1 Welcome | Day 1 + no check-in | 💜 "How are you feeling today? Your first check-in takes 2 minutes." + white outline button "Do my first check-in →" → `DailyCheckInScreen` |
| 4 — Missed nudge | Day 5+ + no check-in + no check-in yesterday | "Treatment weeks are tough. We're still here, whenever you're ready." + "Check in for today →" |
| 5 — Day 7 milestone | Day 7 reached | "One week in, [name]. 💜" + stats summary + "See my week summary →" → `_WeekSheet` |
| 6 — Day 14 milestone | Day 14 reached | "Two weeks in, [name]. 💜" + checklist of accomplishments + "See my 2-week summary →" |
| 7 — Checked in today | `hasCheckedInToday == true` | 💚 "Check-in logged! You're building something." + streak count |

Card spec: `primarySurface` bg or gradient bg (branches 1, 3, 5); 20 px margin, 24 px radius; white outline CTA button on gradient variants

### Quick Actions Grid
3 columns × 2 rows, 12 px gaps:
| Tile | Icon | Label | Navigation target |
|------|------|-------|------------------|
| Scan Lab Results | `document_scanner_rounded` | "Scan Lab Results" | `LabAnalyzerScreen` |
| Voice Check-In | `mic_rounded` | "Voice Check-In" | `VoiceCheckInScreen` |
| Daily Check-In | `edit_note_rounded` | "Daily Check-In" | `DailyCheckInScreen` |
| Ask AI | `smart_toy_rounded` | "Ask AI" | `AIAssistantScreen` |
| My Meds | `medication_rounded` | "My Meds" | `MedicationTrackerScreen` |
| Appointments | `calendar_today_rounded` | "Appointments" | `AppointmentTrackerScreen` |

Tile spec: `surface` bg, 16 px radius, dual shadow; active tile (matching current route) = `primarySurface` bg + `primary` border 1.5 px; icon `primary` 24 px

### Latest Labs Card
- Header: "Latest Labs" + status pill (`Good` → `success`, `Caution` → `warning`, `Critical` → `danger`) + "View full report →" → `LabTrackerScreen`
- Collapsible (default collapsed); shows sample 3 metrics with value + zone dot
- Empty state: "No lab reports yet. Scan or enter your first results."

### Today's Meds Card
- Header: "Today's Meds" + circular progress indicator (% taken) + "All Meds →" → `MedicationTrackerScreen`
- Lists today's medications with taken/pending status chips
- Empty state: "No medications added yet. Add them in Care Hub."

### 14-Day Journey Dot Grid
- 2 rows × 7 columns dot grid representing 14 days from `journey.startDate`
- Past days with check-in: filled `primary` circle
- Past days without check-in: `divider` outline circle
- Today: `primary` with pulsing ring + "TODAY" label
- Future days: light grey outline
- Streak counter displayed below grid
- Tap on week row → opens `_WeekSheet` bottom sheet

### Phase Guide Card
- Content driven by `journey.treatmentPhase`
- Shows: phase emoji + title + overview (2 lines) + 2 "what to expect" bullets
- CTA: "Read your phase guide →" → `JourneyScreen` (Phases tab)

### Community Story Card
- Rotating story based on treatment phase (hardcoded `_storyForPhase`)
- Avatar circle with initials + color, quote, detail line ("Name · Cancer type · Stage · Week/year info")
- CTA: "Read more stories →" → `CommunityScreen`

### AI Insights Card
- Derives up to 3 insights from recent check-ins:
  - Fatigue trend (if fatigue score > 3 for 3+ days)
  - Medication adherence (if `medicationsTaken == false` 2+ days)
  - Pain/mood pattern
- Each insight: colour-coded dot + short sentence + "Ask AI →" → `AIAssistantScreen`

### Bottom Sheets
| Sheet | Trigger | Content |
|-------|---------|---------|
| `_PrepSheet` | (deprecated/internal) | Prep task checklist |
| `_WeekSheet` | Day-7/14 hero card CTA, dot grid tap | Weekly summary: mood avg, pain trend, med adherence, streak, AI comment |

---

## SCREEN 6 — Pre-Check-In Interstitial

```
Screen:       Check-In Interstitial
Route:        (within DailyCheckInScreen, _showInterstitial state)
File:         lib/screens/checkin/checkin_screen.dart → _CheckInInterstitial widget
Accessed from: Any entry to DailyCheckInScreen
```

### UI Elements
- Centered `Column` on `AppColors.background` scaffold
- Large 💜 emoji (top center)
- Headline: "Just a few questions about today." — 20 px, centered
- Sub: "There are no wrong answers." — 14 px, `textMuted`, centered
- Auto-advances after **2.5 seconds** via `Timer`

### Interaction
- `onContinue` callback → `setState(() => _showInterstitial = false)`
- Any tap accelerates advance (not implemented as tap — auto-only)

### Design Rationale
One-breath pause between deciding to check in and seeing the questions. Reduces anxiety. Equivalent of a nurse saying "Take your time."

---

## SCREEN 7 — Daily Check-In (Quick Mode)

```
Screen:       Daily Check-In — Quick Mode
Route:        (index 2 in MainScreen)
File:         lib/screens/checkin/checkin_screen.dart → _buildQuick()
Accessed from: Main Shell nav FAB · Home SmartStatus CTA · Quick Actions grid
```

### Header
- `SliverAppBar` collapsed: "← Daily Check-In" + today's date + "[Full]" mode toggle button
- Mode toggle: `TextButton` "Full" (quick mode) / "Quick" (full mode)

### Step 1 — Mood
Label: "How's your overall mood?" (via `_StepLabel` widget: "1" bubble + label)
`MoodEmojiSelector` widget — 5 emoji buttons:
| Value | Emoji | Label |
|-------|-------|-------|
| 1 | 😫 | "Very hard" |
| 2 | 😔 | "Not great" |
| 3 | 😐 | "Okay" |
| 4 | 🙂 | "Good" |
| 5 | 😊 | "Great" |
Selected: 52 px, purple ring, label visible. Unselected: 40 px, no ring.

### Step 2 — Emotional Wellbeing
Label: "Emotionally, I feel…"
5 emotional rating buttons (1–5):
| Value | Emoji | Label | Color |
|-------|-------|-------|-------|
| 1 | 😰 | "Overwhelmed" | `danger` |
| 2 | 😟 | "Anxious" | `warning` |
| 3 | 😐 | "Okay" | `info` |
| 4 | 🙂 | "Hopeful" | `accent` |
| 5 | 💪 | "Strong" | `primary` |

### Step 3 — Medications
Label: "Did you take your medications today?"
- If medications exist: Toggle card showing med names + taken/not-taken switch
- If no medications: "You haven't added medications yet. Add them later in the Care Hub." + "Add medications" link

### Step 4 — Top Concern Chips
Label: "What's most on your mind today?"
Concern chips (wrap): Pain · Fatigue · Nausea · Anxiety · Sleep · Appetite · Isolation · Fear of recurrence
- Tap selects one at a time; selected = `primarySurface` bg + `primary` border

### Submit
- `PurpleGradientButton`: "Save my check-in" + `check_rounded`
- Below: "Or try full check-in for more detail" (text link)

---

## SCREEN 8 — Daily Check-In (Full Mode)

```
Screen:       Daily Check-In — Full Mode
Route:        (same screen, _isQuickMode = false)
File:         lib/screens/checkin/checkin_screen.dart → _buildFull()
Accessed from: Check-In screen mode toggle; Quick mode "try full check-in" link
```

### Sections (scrollable)
| Section | Label | Widget |
|---------|-------|--------|
| 1 | "How's your overall mood?" | `MoodEmojiSelector` (same as quick) |
| 2 | "Emotionally, I feel…" | 5-button emotional rating |
| 3 | "Physical symptoms today" | 5 `ScoreSlider` widgets |
| 4 | "Medications & Hydration" | Medication card + water intake stepper |
| 5 | "Able to do light activities?" | `Switch` (yes/no) |
| 6 | "Notes (optional)" | `TextField`, 3 lines, multiline |
| 7 | "Food & appetite notes (optional)" | `TextField`, 2 lines |

### Symptom Sliders (`ScoreSlider`)
| Symptom | Range label | Default |
|---------|------------|---------|
| Pain | Low → High | 1 |
| Fatigue | Low → High | 2 |
| Nausea | Low → High | 1 |
| Appetite | Good → Poor | 3 |
| Sleep | Good → Poor | 3 |

### Water Intake Stepper
`[-]  [n] glasses  [+]` — 16 px w600; default 4 glasses

### Submit
- `PurpleGradientButton`: "Submit full check-in"
- Calls `_submitFull()` → creates `CheckIn` object → `AppProvider.addCheckIn()`

---

## SCREEN 9 — Check-In Completion View

```
Screen:       Check-In Completion
Route:        (within DailyCheckInScreen, _isComplete state)
File:         lib/screens/checkin/checkin_screen.dart → _CompletionView widget
Accessed from: Quick or Full mode submission
```

### UI Elements
- Animated check circle (draws in 600 ms)
- Mood-based headline:
  - Mood 1–2: "It's been a hard day. You still showed up. That matters. 💜"
  - Mood 3: "Check-in saved, [name] 💜"
  - Mood 4–5: "You're doing great, [name]! 💜"
- Sub: "That was your first one. That matters more than you know." (Day 1) / "Keep it up — every check-in counts." (Day 2+)
- Day 1 streak badge: 🔥 "Day 1 streak started!" (animated in from above)
- AI encouragement card (optional — derived from symptom scores)
- Auto-returns to Home after **4 seconds** via `Timer`

### Interactions
| Trigger | Result |
|---------|--------|
| 4-second timer | `provider.setNavIndex(0)` + `Navigator.pop()` |
| Tap anywhere | Same |

---

## SCREEN 10 — Journey Screen

```
Screen:       Journey
Route:        (index 1 in MainScreen)
File:         lib/screens/journey/journey_screen.dart
Accessed from: Main Shell bottom nav "Journey"
```

### Layout
- `SliverAppBar` with gradient header "My Journey"
- `TabBar` below header: **Overview · Phases · Analytics**
- `TabBarView` content

### Overview Tab
- Phase hero card: large phase emoji + name + duration + overview text
- Milestones list (from phase data): each with `PhaseInfo.milestones` — icon + title + description
- "What to expect" bullet list from `PhaseInfo.whatToExpect`
- Guidance video cards from `PhaseInfo.videos` (thumbnail placeholder + title + channel + duration + description)

### Phases Tab
- Horizontal scrollable phase selector (all 6 phases as tabs)
- Selected phase: full detail view with tips + milestones
- Phases defined in `_phases` const list:
  - Diagnosis & Planning: `AppColors.diagnosis` / `infoLight`, 2–4 weeks
  - Additional phases follow same `PhaseInfo` model

### Analytics Tab
- Check-in history chart (line/bar chart placeholder)
- 7-day mood trend
- Symptom frequency view
- Medication adherence rate

### Phase Data Model
```
PhaseInfo {
  id, name, icon (emoji), color, lightColor
  overview (long string), duration (string)
  whatToExpect: List<String>  // 4–6 items
  milestones: List<PhaseMilestone>  // 4 items
  videos: List<GuidanceVideo>
  tips: List<String>
}

PhaseMilestone { title, description, icon (IconData) }
GuidanceVideo { title, channel, duration, thumbnail, url, description }
```

---

## SCREEN 11 — AI Health Assistant

```
Screen:       AI Health Assistant (Lina)
Route:        (push navigation)
File:         lib/screens/ai/ai_assistant_screen.dart
Accessed from: Home Quick Actions "Ask AI" · Care Hub AI Tools · Home AI Insights "Ask AI"
```

### Header
- Gradient bar: "AI Health Assistant" title + "🤖 Rehlah AI — Here to help you understand, 24/7" subtitle
- Back arrow `←`

### Quick Suggestion Chips (horizontal scroll)
| Chip | Icon |
|------|------|
| "What do my lab results mean?" | `science_rounded` |
| "Side effects of chemo?" | `medication_rounded` |
| "Tips for nausea?" | `sick_rounded` |
| "When to call my doctor?" | `phone_rounded` |
| "What is nadir?" | `help_rounded` |
| "Managing fatigue tips" | `battery_charging_full_rounded` |
| "Foods good during treatment" | `restaurant_rounded` |
| "Infection warning signs" | `warning_rounded` |

Shown only when message list is empty or has only greeting.

### Chat Interface
- `ListView` of message bubbles, auto-scrolls to bottom
- **AI bubble (left):** `primarySurface` bg, 16 px radius (flat top-left), 12 px padding, 14 px `textPrimary`, line-height 1.5
- **User bubble (right):** white card, `primary` border 1 px, 14 px text
- **Typing indicator:** 3 dots animate with `_pulseCtrl` (1200 ms loop)

### AI Greeting (on mount, 500 ms delay)
Time-aware: "Good [morning/afternoon/evening][, name if known]"
Body: "I'm here to help you understand what's happening and answer your questions. I'm not a doctor — but I know a lot about what people going through treatment often experience. What's on your mind?"

### Knowledge Base (keyword-matched responses)
| Key | Keywords | Response summary |
|-----|---------|-----------------|
| `nausea` | nausea, vomit, sick, queasy | Timing, food choices, lifestyle tips; escalation: call if vomiting 24h+ |
| `fatigue` | tired, fatigue, exhausted, energy, weak | Energy conservation, gentle activity, nutrition, tracking |
| `labs` | lab, blood, results, cbc, wbc, hemoglobin | CBC breakdown (WBC, ANC, RBC, platelets, creatinine, tumor markers) |
| `nadir` | nadir, lowest, counts drop | 7–14 day post-chemo window, protective actions, rebound timeline |
| `doctor` | doctor, call, emergency, when, worried | Red flags list (fever ≥38°C, bleeding, vomiting 24h, chest pain, etc.) |
| `side effects` | side effects, chemo, hair loss, neuropathy | Hair loss, nausea, neuropathy, mucositis, cognitive changes |
| `food` | food, eat, nutrition, diet, meal | Best foods, foods to limit, practical tips |

### Input Bar
- `TextField` with hint "Ask anything..."
- Send `IconButton`: `send_rounded`, `primary` color
- On send: matches keywords → shows typing indicator (1–1.5 s simulated) → renders AI response

### Design Principles (Doc 09)
1. Validate first ("Yes, nausea is common")
2. Practical & actionable (specific items, not vague)
3. Know when to escalate ("Call your care team if…")
4. Human closing (emotional acknowledgement)
5. Always honest ("Not medical advice" present but not dominant)
6. Uses patient's name in greeting

---

## SCREEN 12 — Lab Tracker

```
Screen:       Lab Tracker
Route:        (push navigation)
File:         lib/screens/ai/lab_tracker_screen.dart
Accessed from: Home Quick Actions "Scan Lab Results" · Home Latest Labs card · Care Hub AI Tools
```

### Header (`_Header` widget)
- Status bar: overall status pill (`Good` / `Caution` / `Critical`) + # reports + # metrics tracked
- Upload button: `upload_file_rounded` icon — opens `_UploadReportSheet`
- "Add Report" FAB: `add_rounded` → same sheet

### Tab Bar (3 tabs + `TabController`)
| Tab | Label | Badge |
|-----|-------|-------|
| 0 | Metrics | — |
| 1 | AI Insights | Alert count (red pill, e.g. "2") |
| 2 | Reports | — |

### Metrics Tab (`_MetricsTab`)
- Panel selector: horizontal chip row for metric categories (CBC, Liver, Kidney, etc.)
- For each metric: `_MetricChartCard`:
  - Metric name + current value + unit
  - Trend arrow (↑↓→) + trend label ("Stable" / "Rising" / "Falling")
  - Sparkline mini chart
  - Zone pill: 🟢 Normal / 🟠 Caution / 🔴 Critical
  - Tap → expands to `_MetricChartCard` detail:
    - Full `_ZoneLineChart` (FLChart `LineChart`) with colour-coded zone bands
    - `_StatsRow`: min / avg / max / trend
    - `_AINote`: contextual AI comment
    - `_ZoneLegend`: Normal band / Caution / Critical colour key

### AI Insights Tab (`_AlertsTab`)
- Summary row: alert count chips by severity
- `_AIPatternCard` for each alert:
  - Severity dot (red/orange/green) + metric name + zone
  - Plain-language explanation (2–4 sentences)
  - Contextual action (e.g. "Watch for fever above 38°C")
  - Always includes: "[This is not medical advice]" — 12 px grey, directly below card

### Reports Tab (`_ReportsTab`)
- List of saved reports in reverse chronological order
- Each report row: date + report name + source hospital + critical/abnormal flags + value chips
- Tap → expands to show all values in that report

### Upload Report Sheet (`_UploadReportSheet`)
Multi-step modal bottom sheet:
1. Report name field
2. Date picker (calendar icon)
3. Source / Hospital name field
4. "Add your results" section:
   - Search field: "🔍 e.g., WBC, haemoglobin, platelets..."
   - On type → shows matching test names
   - On select → shows: test name + normal range + value input field + real-time zone pill
   - **Inline reassurance messages** (zone-dependent):
     - Red zone: "This is common during chemotherapy. Your doctor monitors this closely."
     - Critical ANC: "Your ANC is very low. This means your infection risk is higher. Please contact your care team today."
     - Normal: "This is within the normal range — good news 💜"
5. "+ Add another test result" link
6. "Save report" `PurpleGradientButton`

---

## SCREEN 13 — Voice Check-In

```
Screen:       Voice Check-In
Route:        (push navigation)
File:         lib/screens/checkin/voice_checkin_screen.dart
Accessed from: Home Quick Actions "Voice Check-In"
```

### UI Elements
- Waveform visualization (animated bars)
- Question headline (one at a time)
- Recording indicator (pulsing mic icon)
- "Next" / "Done" button progression

### 6 Sequential Voice Questions
| # | Question |
|---|---------|
| 1 | "How are you feeling today on a scale of 1 to 5?" |
| 2 | "Any pain — and if so, how would you rate it?" |
| 3 | "How's your energy level?" |
| 4 | "Any nausea or digestive issues?" |
| 5 | "Did you take your medications today?" |
| 6 | "Anything else you'd like to note?" |

- Auto-extracts numerical scores from voice input
- Submits same `CheckIn` model as text check-in

---

## SCREEN 14 — Lab Analyzer (Document Scanner)

```
Screen:       Lab Analyzer
Route:        (push navigation)
File:         lib/screens/ai/lab_analyzer_screen.dart
Accessed from: Home Quick Actions "Scan Lab Results" · Care Hub AI Tools
```

### UI Elements
- Camera/document scanner interface
- "Scan your lab report" instruction
- Scan area overlay with corner markers
- "From gallery" fallback option
- AI analysis output:
  - Extracted values table
  - Zone classification for each value
  - Plain-language summary
  - "Save to Lab Tracker" CTA

---

## SCREEN 15 — Care Hub

```
Screen:       Care Hub
Route:        (index 3 in MainScreen)
File:         lib/screens/care/care_hub_screen.dart
Accessed from: Main Shell bottom nav "Care"
```

### Layout
- `CustomScrollView` with `BouncingScrollPhysics`
- Collapsing `SliverAppBar`: gradient bg, title "Care Hub", sub "Your health tools in one place"
- On collapse: dark (`#150A30` 92% alpha) collapsed title bar

### Section 1 — Medications & Adherence
Label row: "MEDICATIONS & ADHERENCE" + "Track →" link → `MedicationTrackerScreen`
`_MedicationsSummaryCard`:
- Today's meds listed with taken/pending chips
- Circular adherence percentage indicator
- "Add Medication" FAB-style card

### Section 2 — Appointments
Label row: "APPOINTMENTS" + "All →" link → `AppointmentTrackerScreen`
`_AppointmentsSummaryCard`:
- Next appointment: date, time, doctor name, location
- "Days until" badge
- Quick add button

### Section 3 — Emotional Wellbeing
Label row: "EMOTIONAL WELLBEING"
Cards: check-in streak display + mood trend mini-chart + "Do today's check-in" CTA

### Section 4 — AI Tools Grid
Label row: "AI TOOLS"
2×2 grid:
| Tool | Icon | Navigation |
|------|------|-----------|
| Ask AI | `smart_toy_rounded` | `AIAssistantScreen` |
| Lab Tracker | `science_rounded` | `LabTrackerScreen` |
| Voice Check-In | `mic_rounded` | `VoiceCheckInScreen` |
| Lab Analyzer | `document_scanner_rounded` | `LabAnalyzerScreen` |

---

## SCREEN 16 — Medication Tracker

```
Screen:       Medication Tracker
Route:        (push navigation)
File:         lib/screens/care/medication_tracker_screen.dart
Accessed from: Care Hub "Track" link · Home Meds card · Quick Actions "My Meds"
```

### Layout
- AppBar: "Medication Tracker" + FAB "+" to add medication

### Tabs
| Tab | Content |
|-----|---------|
| Today's Doses | List of today's medications with taken/skip toggles |
| All Medications | Complete medication list with frequency, dosage, notes |

### Today's Doses
Each med row: med name + dosage + frequency + taken/pending chip + `check_rounded` / `close_rounded` action

### Adherence Display
- Circular progress indicator with percentage
- "Adherence this week: n/7 days"

### Add Medication Bottom Sheet
| Field | Type | Detail |
|-------|------|--------|
| Medication name | `TextField` | Required, "e.g., Tamoxifen" placeholder |
| Dosage | `TextField` | Required, "mg / ml / tablet" suffix |
| Frequency | `DropdownButton` | Once daily / Twice daily / Three times daily / Weekly / As needed |
| Notes | `TextField` | Optional, "e.g., Take with food" |
| Save button | `PurpleGradientButton` | "Save medication" |

Post-save toast: "Tamoxifen added 💊 — it will appear in your daily check-in tomorrow."

---

## SCREEN 17 — Appointment Tracker

```
Screen:       Appointment Tracker
Route:        (push navigation)
File:         lib/screens/care/appointment_tracker_screen.dart
Accessed from: Care Hub "All" link · Home Next Appointment banner · Quick Actions "Appointments"
```

### Layout
- AppBar: "My Appointments" + FAB "+" to add

### Tabs
| Tab | Content |
|-----|---------|
| Upcoming | Future appointments sorted by date |
| Past | Historical appointments |

### Appointment Card
- Doctor name + specialty
- Date + time
- Location / hospital
- "In [n] days" countdown badge (green if >7 d, orange if ≤7 d, red if ≤2 d)
- Notes field (expandable)

---

## SCREEN 18 — Community

```
Screen:       Community
Route:        (index 4 in MainScreen)
File:         lib/screens/community/community_screen.dart
Accessed from: Main Shell bottom nav "Community"
```

### Header
- Gradient bg (`heroGradient`)
- Title: "Community" — 24 px w700, white
- "Safe Space" badge: `shield_rounded` icon + "Safe Space" — white pill, 15% white bg
- Sub: "You are not alone on this journey 💜" — 13 px, white 80%
- **Tab selector (inside header):** 4 pill-style tabs (white selected, 15% white unselected)

### 4 Tabs

#### Tab 1 — Feed
- Filter chips row: cancer type (All/Breast/Colorectal/Lymphoma/Lung/Prostate) + phase (All/Diagnosis/Chemo/Radiation/Surgery/Recovery)
- Safety banner: "This is a peer support space. Content is not medical advice. Always consult your care team."
- **`_PostCard` spec:**
  - `RehlaCard` container
  - Author row: circle avatar (initials + color) + name + time + optional "Survivor" badge + cancer type tag + phase tag
  - Content text: 14 px, lineHeight 1.5
  - Action row: ❤️ like count (toggleable, red when liked) + 💬 reply count + "Reply" button

**Sample posts (hardcoded):**
| Author | Cancer/Phase | Content snippet |
|--------|-------------|-----------------|
| Sarah J. | Breast/Chemo | "Week 6 of chemo done! The fatigue is real, but staying positive..." |
| Michael R. | Colorectal/Recovery | "Had my first post-treatment scan today. Waiting for results is the hardest part..." |
| Emma L. ✓Survivor | Breast/Recovery | "Tip: The Rehla check-ins have been so helpful for my doctor visits..." |
| David K. | Lymphoma/Chemo | "Anyone experience extreme cold sensitivity from chemo?..." |
| Lisa T. | Lung/Radiation | "Week 3 of radiation complete..." |
| Priya M. | Breast/Diagnosis | "Just got my diagnosis last week. Stage II breast cancer. I'm scared..." |

**Compose post (FAB + sheet):**
- FAB: `FloatingActionButton.extended` — `primary` bg + "Share" label + `edit_rounded` icon
- Sheet: "Share with the Community" title + "Your experience can help someone feel less alone." + `TextField` (4 lines) + anonymous note + "Share Post" button

#### Tab 2 — Coaches
- Info banner: "All coaches are certified oncology professionals. Sessions are not a substitute for medical care."
- **Coach cards** (3 sample coaches):

| Name | Role | Rating | Sessions | Specialties | Available |
|------|------|--------|---------|------------|----------|
| Maria Rodriguez | Oncology Life Coach | 4.9 (47) | 230 | Chemotherapy, Breast cancer, Anxiety management | ✅ |
| Sarah Chen | Cancer Support Specialist | 4.8 (89) | 415 | Lymphoma, Side effects, Mental health | ✅ |
| James Wilson | Oncology Counselor | 4.7 (31) | 120 | Radiation, Surgery prep, Family support | ❌ |

Card: avatar circle + green availability dot + name + role + star rating + sessions count + bio text + specialty tags + "View Profile" + "Book Session" / "Unavailable" buttons

#### Tab 3 — Mentors
- Info banner: "Peer mentors are volunteer cancer survivors. Connect for peer support — not medical advice."
- **Mentor cards** (4 sample mentors):

| Name | Type | Detail | Tags |
|------|------|--------|------|
| Jennifer K. | Breast Cancer Survivor | 3 years post-treatment · Stage II | Stage II, Chemo veteran, Working mom, Breast |
| Robert M. | Colorectal Cancer Survivor | 5 years post-treatment · Stage III | Surgery, Recovery, Active lifestyle, Colorectal |
| Lisa T. | Lymphoma Survivor | 2 years post-treatment | Immunotherapy, Mental health, Lymphoma |
| Ahmed S. | Lung Cancer Survivor | 4 years post-treatment · Stage II | Radiation, Lung, Non-smoker, Recovery |

Card: avatar + "Survivor" badge + name + type + detail + quoted story + tags + "Connect with this Mentor" button

**Connect sheet:** "Send a connection request" explanation + "Send Connection Request" button + "Maybe Later"

#### Tab 4 — Stories
- Header: "Real stories from real patients. Read, be inspired, share your own."
- **Story cards** (4 sample stories):

| Title | Author | Cancer | Read time | Views |
|-------|--------|--------|-----------|-------|
| "From Diagnosis to Marathon: My Comeback Story" | Jennifer K. | Breast | 8 min | 1,240 |
| "What Nobody Tells You About the Mental Health Side of Chemo" | David K. | Lymphoma | 6 min | 2,890 |
| "How I Talked to My Kids About Cancer (At Ages 5 and 8)" | Sarah J. | Breast | 5 min | 4,500 |
| "Finding Gratitude in the Worst Year of My Life" | Lisa T. | Lymphoma | 7 min | 3,200 |

Card: gradient story header with book icon + title + excerpt (3 lines, ellipsis) + author row + cancer type tag + read time + view count + topic tags

**Story detail sheet:** `DraggableScrollableSheet` (85%–95% height) with full story display (excerpt + "Full story coming in next update" card)

---

## SCREEN 19 — Profile & Settings

```
Screen:       Profile & Settings
Route:        (Drawer — endDrawer of MainScreen)
File:         lib/screens/profile/profile_screen.dart
Accessed from: SliverAppBar profile icon in Home → opens endDrawer
```

### AppBar
- Title: "Profile & Settings" — 20 px w700
- No leading (drawer context)

### Sections (scrollable)

#### Profile Card (`RehlaCard`)
- `CircleAvatar` (radius 32): first letter of name, `primary` text, `primarySurface` bg
- Name: 18 px w700 `textPrimary`
- Cancer type: 13 px `textSecondary`
- Stage + treatment phase: 12 px `textMuted`
- Edit button: `edit_rounded` icon → `_showEditProfile` bottom sheet

#### Journey Stats Row (3 `_StatCard` widgets)
| Stat | Icon | Color |
|------|------|-------|
| Check-ins (count) | `check_circle_rounded` | `primary` |
| Day Streak | `local_fire_department_rounded` | `#F4B63E` amber |
| Med Rate (hardcoded 95%) | `medication_rounded` | `accent` |

#### Account Section (`_SettingsSection`)
| Item | Icon | Color |
|------|------|-------|
| Edit Profile | `person_rounded` | `primary` |
| Journey Details | `medical_information_rounded` | `info` |
| Notifications | `notifications_rounded` | `warning` |
| Language (subtitle: "English") | `language_rounded` | `accent` |

#### Privacy & Data Section
| Item | Icon | Color |
|------|------|-------|
| Privacy & Data Security | `lock_rounded` | `primary` |
| Export My Data | `download_rounded` | `accent` |
| Share Care Binder | `share_rounded` | `info` |

#### Help & Support Section
| Item | Icon | Color |
|------|------|-------|
| FAQ & Help Center | `help_rounded` | `primary` |
| Send Feedback | `feedback_rounded` | `accent` |
| Terms & Privacy Policy | `policy_rounded` | `textMuted` |

#### Data Security Badge
- `accentLight` bg, `accent` border 30%
- `verified_user_rounded` icon (24 px, `accent`)
- "Your data is encrypted and HIPAA compliant" — 13 px w600
- "We never share your data without your explicit consent." — 12 px `textSecondary`

#### Create Account CTA
- Gradient bg `#F5F0F9 → #FDF8FD`, `divider` border
- Title: "Create an account" — 16 px w700
- Sub: "Save your journey, invite a caregiver, and sync across devices."
- Buttons: "Create Account" (ElevatedButton) + "Log In" (OutlinedButton)
- Both → MVP message toast ("Account creation coming soon") or `_showLoginSheet`

**Login Sheet:** "Log In to Rehla" title + "Cloud sync and multi-device support coming soon." + info card "Rehla MVP runs offline. Cloud accounts will be available in the next release." + "Got it" dismiss button

#### Reset Journey Button
- Danger style: `danger` 5% bg, `danger` 20% border, "Reset Journey" — 14 px w600 `danger`
- Tap → `AlertDialog`:
  - Title: "Reset Journey?"
  - Body: "This will delete all your check-ins and journey data. This cannot be undone."
  - Actions: "Cancel" / "Reset" (`danger` color)
  - On confirm: `provider.resetJourney()` → `Navigator.pushReplacementNamed('/')`

#### Footer
- "Rehla v1.0.0 • Free (donations welcome)" — 11 px `textMuted`, centered

### Settings Item Behavior (all non-implemented items)
All `_SettingsSection` items show `SnackBar` "[label] — coming in next release" except:
- "Export My Data" → "Export started — your data will be emailed to you." (`accent` bg)
- "Edit Profile" → opens `_showEditProfile` sheet

---

## SCREEN 20 — Edit Profile Sheet

```
Screen:       Edit Profile (Bottom Sheet)
Route:        (modal bottom sheet)
File:         lib/screens/profile/profile_screen.dart → _showEditProfile()
Accessed from: Profile card edit button · Account section "Edit Profile"
```

### UI Elements
- Handle bar (36×4 `divider` pill)
- Title: "Edit Profile" — 17 px w700
- `TextField`: "Your name" + `person_rounded` prefix icon + `OutlineInputBorder` 12 px radius
- "Save Changes" `ElevatedButton`
- On save: updates `provider.journey.name` → `provider.saveJourney()` → toast "Profile updated!"

---

## APPENDIX A — Route Map

| Route | Widget | File |
|-------|--------|------|
| `/` | `WelcomeScreen` | `lib/screens/onboarding/welcome_screen.dart` |
| `/onboarding` | `OnboardingScreen` | `lib/screens/onboarding/onboarding_screen.dart` |
| `/journey_created` | `JourneyCreatedScreen` | `lib/screens/onboarding/journey_created_screen.dart` |
| `/main` | `MainScreen` | `lib/screens/home/main_screen.dart` |
| `/main` index 0 | `HomeScreen` | `lib/screens/home/home_screen.dart` |
| `/main` index 1 | `JourneyScreen` | `lib/screens/journey/journey_screen.dart` |
| `/main` index 2 | `DailyCheckInScreen` | `lib/screens/checkin/checkin_screen.dart` |
| `/main` index 3 | `CareHubScreen` | `lib/screens/care/care_hub_screen.dart` |
| `/main` index 4 | `CommunityScreen` | `lib/screens/community/community_screen.dart` |
| `endDrawer` | `ProfileScreen` | `lib/screens/profile/profile_screen.dart` |
| push | `AIAssistantScreen` | `lib/screens/ai/ai_assistant_screen.dart` |
| push | `LabTrackerScreen` | `lib/screens/ai/lab_tracker_screen.dart` |
| push | `LabAnalyzerScreen` | `lib/screens/ai/lab_analyzer_screen.dart` |
| push | `VoiceCheckInScreen` | `lib/screens/checkin/voice_checkin_screen.dart` |
| push | `MedicationTrackerScreen` | `lib/screens/care/medication_tracker_screen.dart` |
| push | `AppointmentTrackerScreen` | `lib/screens/care/appointment_tracker_screen.dart` |

---

## APPENDIX B — Key Data Models

```dart
// User journey created at onboarding completion
UserJourney {
  id: String              // 'user_[timestamp]'
  name: String            // First name entered
  cancerType: String      // From cancerTypes list
  stage: String           // 'Stage I'/'II'/'III'/'IV'/'Unknown'
  treatmentPhase: String  // From _phases list
  treatmentStartDate: DateTime
  isPatient: bool         // patient vs caregiver
}

// Daily check-in data model
CheckIn {
  timestamp: DateTime
  moodScore: int          // 1–5
  emotionalScore: int     // 1–5
  painScore: int          // 1–5
  fatigueScore: int       // 1–5
  nauseaScore: int        // 1–5
  appetiteScore: int      // 1–5
  sleepScore: int         // 1–5
  medicationsTaken: bool
  waterGlasses: int
  activitiesAble: bool
  topConcern: String?     // from _concerns list
  notes: String?
  foodNotes: String?
}
```

---

## APPENDIX C — Animation Inventory

| Screen | Animation | Duration | Type |
|--------|-----------|---------|------|
| Welcome | Screen fade-in | 600 ms | `FadeTransition`, `Curves.easeOut` |
| Welcome | Logo heartbeat | 1500 ms, repeat | `ScaleTransition`, `Tween(1.0→1.04)` |
| Onboarding | Progress dot pill | 300 ms | `AnimatedContainer` |
| Onboarding | Page transitions | 380 ms | `Curves.easeInOutCubic` |
| Onboarding | Name greeting fade | 400 ms | `FadeTransition`, `Curves.easeOut` |
| Onboarding | Role/phase selection | 200 ms | `AnimatedContainer` |
| Journey Created | Screen fade-in | 700 ms | `FadeTransition` |
| Journey Created | Heart pulse | 1500 ms, repeat | `ScaleTransition` |
| Journey Created | Countdown | 8000 ms | `Timer.periodic(1s)` |
| Check-In Interstitial | Auto-advance | 2500 ms | `Timer` |
| Check-In Completion | Auto-return | 4000 ms | `Timer` |
| Check-In Completion | Check circle draw | 600 ms | Custom painter |
| AI Assistant | Typing indicator | 1200 ms, repeat | `AnimationController` pulse |
| AI Assistant | Response delay | 1000–1500 ms | Simulated `Timer` |
| Home | Fade-in | 600 ms | `FadeTransition` |
| Main Shell FAB | Gradient/icon switch | 250 ms | `AnimatedContainer` + `AnimatedSwitcher` |
| Nav items | Selection | 200 ms | `AnimatedContainer`, `AnimatedDefaultTextStyle` |

---

## APPENDIX D — 14-Day UX Flow × Screen Map

| Day | UX Event | Primary Screen | Secondary Screens |
|-----|---------|---------------|-----------------|
| 0 (evening) | First launch | Welcome | — |
| 0 (evening) | Onboarding | Onboarding (5 steps) | — |
| 0 (evening) | Journey created | Journey Created | — |
| 1 (morning) | Day 1 return | Home (Day 1 state) | — |
| 1 | First check-in | Check-In Interstitial → Quick Mode → Completion | — |
| 3 | Add medications | Care Hub → Medication Tracker (add sheet) | — |
| 5 (hard day) | Missed check-in | Home (missed nudge state, no guilt) | — |
| 5 | Full mode prompt | Check-In Full Mode (optional invite) | — |
| 7 | Week 1 milestone | Home (Day 7 hero card) | WeekSheet |
| 9 | First lab entry | Lab Tracker (upload sheet) → AI Insights tab | — |
| 11 (11pm) | AI nausea question | AI Assistant | — |
| 12 | Doctor visit | Home check-in history / Lab Tracker / Medication Tracker | — |
| 14 | Two-week milestone | Home (Day 14 hero card) | Caregiver invitation card |

---

*Document 10 of the Rehlah Specification Suite*
*Version 1.0 | April 2026*
*Compiled from: GitHub repo (lib/screens/**), Document 09 (14-Day UX Flow), Document 06 (Design System)*
*Live Prototype: https://nadbrahmi.github.io/Rehlah/*
*Repository: https://github.com/nadbrahmi/Rehlah/*
