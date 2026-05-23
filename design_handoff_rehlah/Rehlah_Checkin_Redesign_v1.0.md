# Rehlah · رحلة — Daily Check-in Redesign Specification

**Version:** 1.0
**Date:** 2026-05-17
**Branch:** main
**Author:** Senior Product Designer · Healthcare / Oncology UX
**For:** Rehlah engineering & clinical leadership

---

## Executive Summary

The current 3-screen check-in (emoji → 0–10 sliders → 4-second auto-dismiss) is being replaced with a single-screen, phase-aware, clinically intelligent flow targeting ≤45 second completion for fatigued chemotherapy patients.

Key shifts:
- Merged 3 screens into 1 scrollable form
- 5-point segmented controls with verbal anchors (PRO-CTCAE-aligned), replacing 0–10 sliders
- Fever removed from sliders — handled via existing `/vitals` flow in °C
- Phase-aware symptom set (treatment / nadir / recovery)
- Red-flag escalation banner when temp ≥ 38°C during nadir
- Manual-dismiss success screen with trend feedback (no 4s auto-timer)
- RTL-ready foundation for Arabic localization

---

## 1. Context & Design Principles

Target users: adult oncology patients (primarily Arabic-speaking MENA), often fatigued, nauseous, or cognitively impaired ("chemo brain"). Many check in from a hospital bed.

Non-negotiable design principles:

1. Single screen, vertically scrollable. No multi-step wizard.
2. 5-point segmented control with verbal anchors (None / Mild / Moderate / Severe / Worst), mapped to 0/2/5/7/10 on the backend for clinical continuity with PRO-CTCAE / NRS norms.
3. Fever is NEVER a subjective slider. It is a temperature in °C, logged via `/vitals`. Check-in shows a contextual prompt to `/vitals` only during the nadir phase.
4. Phase-aware symptom set:
   - Treatment day → nausea, fatigue, infusion-site reaction
   - Nadir → temperature, mouth sores, infection signs
   - Recovery → mood, appetite, energy return
5. Red-flag escalation: if logged temp ≥ 38°C during nadir, show banner "Call your care team now" with one-tap dial.
6. Notes field is prominent (not buried). Supports voice-to-text.
7. RTL-ready from day one: use Directionality, semantic color tokens, no hardcoded LTR gradients.
8. Accessibility: 48×48 dp minimum touch targets, dynamic type to 200%, screen-reader labels, subtle haptic on submit.
9. Tone: companion, not surveyor. Acknowledge, don't audit.
10. Emoji used sparingly. Default to abstract faces + words for mood selector; emoji as a setting.

---

## 2. Current State Analysis

Seven issues with the existing flow:

| # | Issue | Impact |
|---|-------|--------|
| 1 | Two-screen split (emoji → sliders) | Context-switch between two mental models; duplicates "mood"; two abandonment moments |
| 2 | 0–10 NRS sliders | Thumb-driven ±2 errors on mobile; patients cannot intuitively distinguish 6 from 7 |
| 3 | Fever as a slider | Clinically meaningless and dangerous during nadir; subjective scale masks real fever |
| 4 | No phase-awareness | Nadir-day prompts identical to recovery-day; misses infection-signal opportunities |
| 5 | 4s auto-return success screen | Removes agency; feels transactional, not therapeutic; blocks adding notes |
| 6 | Notes field buried | Single most clinically valuable field is underused |
| 7 | No RTL groundwork | Future Arabic localization will cost 3× more to retrofit |

---

## 3. Information Architecture

New `/checkin` is one vertically scrollable screen composed of seven content blocks plus a sticky submit footer. Block visibility and content adapt to the patient's current phase.

| Block | Purpose | Phase Rule |
|---|---|---|
| A. Greeting + Phase Subhead | Anchor the moment, acknowledge phase | Always shown; subhead text changes per phase |
| B. Overall Mood | 5-point Likert (abstract faces + words). Maps to legacy `mood` + `mood_score` columns | Always shown |
| C. Core Symptoms | 5-point segmented controls with verbal anchors | 2–3 symptoms always; set varies by phase |
| D. Add Another Symptom | Progressive disclosure for long-tail symptoms | Always available; collapsed by default |
| E. Temperature Prompt | Inline nudge to `/vitals`. Shows last reading if logged today | Nadir only |
| F. Red-Flag Banner | Reactive — appears if today's temp ≥ 38°C. One-tap call to care team | Conditional |
| G. Notes | Free-text + voice-to-text | Always shown, prominent |
| Submit CTA | "Send to care team" — sticky footer, full-width | Always |

---

## 4. Wireframes

### Treatment Day (Day 0–2 post-infusion)

```
┌─────────────────────────────────┐
│ ← Back                  Skip ›  │
├─────────────────────────────────┤
│ Good morning, Layla             │
│ Cycle 2 · Day 1 · Treatment day │
├─────────────────────────────────┤
│ How are you overall?            │
│ ◐  ◑  ●  ◔  ◕                   │
│ Awful Low Okay Good Great       │
├─────────────────────────────────┤
│ Today's symptoms                │
│                                 │
│ Nausea                          │
│ ●━━○━━○━━○━━○                   │
│                                 │
│ Fatigue                         │
│ ○━━●━━○━━○━━○                   │
│                                 │
│ Infusion site                   │
│ ●━━○━━○━━○━━○                   │
│                                 │
│ ＋ Add another symptom          │
├─────────────────────────────────┤
│ Anything else? (optional)       │
│ ┌─────────────────────────────┐ │
│ │ Felt dizzy when standing... │ │
│ │                    🎙 Speak │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ [   Send to care team   →   ]   │
└─────────────────────────────────┘
```

### Nadir Window (Day 7–14)

```
│ Cycle 2 · Day 9 · Nadir window  │
│ Your immunity is at its lowest. │
│ Be extra alert for fever or     │
│ infection.                      │
├─────────────────────────────────┤
│ How are you overall? [...]      │
├─────────────────────────────────┤
│ Today's symptoms                │
│   Fatigue       ●━●━○━○━○       │
│   Mouth sores   ●━○━○━○━○       │
│   Appetite loss ●━●━○━○━○       │
│ ＋ Add another symptom          │
├─────────────────────────────────┤
│ 🌡 Temperature                  │
│    Last logged: not yet today   │
│    [ Log temperature now → ]    │
├─────────────────────────────────┤
│ Anything else? (optional) [...] │
```

### Nadir + Fever ≥ 38°C (red-flag escalation)

```
┌─────────────────────────────────┐
│ ⚠️  TEMPERATURE 38.4°C          │
│                                 │
│ During nadir, any fever ≥ 38°C  │
│ needs urgent attention from     │
│ your care team.                 │
│                                 │
│ [ 📞  Call care team now    ]   │
│ [ Continue check-in         ]   │
└─────────────────────────────────┘
```

### Recovery Phase (Day 15–21)

```
│ Cycle 2 · Day 17 · Recovery     │
│ Energy should be returning.     │
│ Keep logging — patterns help    │
│ your team.                      │
├─────────────────────────────────┤
│ Today's symptoms                │
│   Energy level   ●━●━●━○━○      │
│   Mood           ●━●━○━○━○      │
│   Appetite       ●━○━○━○━○      │
```

### Success Screen (replaces 4s auto-dismiss)

```
┌─────────────────────────────────┐
│             ✓                   │
│      Logged at 9:14 AM          │
│  Your care team can see this.   │
├─────────────────────────────────┤
│      Today vs. yesterday        │
│                                 │
│   Fatigue   ↓ better            │
│   Nausea    → same              │
│   Pain      ↑ slightly worse    │
├─────────────────────────────────┤
│  [ Add a note ]   [   Done   ]  │
└─────────────────────────────────┘
```

Visual reference: English mockups (Treatment / Nadir / Success): https://www.genspark.ai/api/files/s/oFMjpT0D

---

## 5. Copy Deck — English + Arabic

Arabic is MSA clinical-friendly, addressing patient in feminine singular by default (Arabic verbs require gender; pick at runtime from patient profile, fallback feminine).

| Element | English | العربية |
|---|---|---|
| Greeting AM | Good morning, {name} | صباح الخير، {name} |
| Greeting PM | Good evening, {name} | مساء الخير، {name} |
| Subhead — Treatment | Cycle {n} · Day {d} · Treatment day | الدورة {n} · اليوم {d} · يوم العلاج |
| Subhead — Nadir | Cycle {n} · Day {d} · Nadir window | الدورة {n} · اليوم {d} · فترة الهبوط المناعي |
| Subhead — Recovery | Cycle {n} · Day {d} · Recovery | الدورة {n} · اليوم {d} · مرحلة التعافي |
| Nadir caution | Your immunity is at its lowest. Be extra alert for fever or infection. | مناعتكِ في أدنى مستوياتها. انتبهي جيدًا لأي ارتفاع في الحرارة أو علامات عدوى. |
| Recovery note | Energy should be returning. Keep logging — patterns help your team. | من المتوقع أن تعود طاقتكِ تدريجيًا. استمري في التسجيل — الأنماط تساعد فريقكِ الطبي. |
| Mood question | How are you overall? | كيف حالكِ بشكل عام اليوم؟ |
| Mood anchor 1 | Awful | سيئة جدًا |
| Mood anchor 2 | Low | منخفضة |
| Mood anchor 3 | Okay | مقبولة |
| Mood anchor 4 | Good | جيدة |
| Mood anchor 5 | Great | ممتازة |
| Section title | Today's symptoms | أعراض اليوم |
| Severity 0 | None | لا شيء |
| Severity 1 | Mild | خفيف |
| Severity 2 | Moderate | متوسط |
| Severity 3 | Severe | شديد |
| Severity 4 | Worst | الأسوأ |
| Symptom — Nausea | Nausea | غثيان |
| Symptom — Fatigue | Fatigue | إرهاق |
| Symptom — Pain | Pain | ألم |
| Symptom — Infusion site | Infusion site | موضع الحقن |
| Symptom — Mouth sores | Mouth sores | تقرحات الفم |
| Symptom — Appetite loss | Appetite loss | فقدان الشهية |
| Symptom — Diarrhea | Diarrhea | إسهال |
| Symptom — Sleep | Sleep quality | جودة النوم |
| Symptom — Energy | Energy level | مستوى الطاقة |
| Symptom — Mood | Mood | المزاج |
| Add another | ＋ Add another symptom | ＋ إضافة عرض آخر |
| Temp prompt title | Temperature | درجة الحرارة |
| Temp last logged | Last logged: {time} | آخر تسجيل: {time} |
| Temp not yet | Last logged: not yet today | لم يتم التسجيل بعد اليوم |
| Temp CTA | Log temperature now | سجّلي درجة الحرارة الآن |
| Red-flag title | ⚠️ Temperature {value}°C | ⚠️ درجة الحرارة {value}° مئوية |
| Red-flag body | During nadir, any fever ≥ 38 °C needs urgent attention from your care team. | في فترة الهبوط المناعي، أي حرارة ≥ ٣٨ مئوية تستدعي تواصلًا فوريًا مع فريقكِ الطبي. |
| Red-flag primary CTA | 📞 Call care team now | 📞 اتصلي بالفريق الطبي الآن |
| Red-flag secondary | Continue check-in | متابعة التسجيل |
| Notes title | Anything else? (optional) | هل تودين إضافة شيء؟ (اختياري) |
| Notes placeholder | E.g., felt dizzy when standing up… | مثلًا: شعرت بدوار عند الوقوف… |
| Voice CTA | 🎙 Speak | 🎙 تحدّثي |
| Submit | Send to care team | إرسال إلى الفريق الطبي |
| Success title | ✓ Logged at {time} | ✓ تم التسجيل في {time} |
| Success reassurance | Your care team can see this. | فريقكِ الطبي يستطيع رؤية هذا. |
| Trend section | Today vs. yesterday | اليوم مقارنةً بالأمس |
| Trend — better | ↓ better | ↓ أفضل |
| Trend — same | → same | → كما هو |
| Trend — worse | ↑ slightly worse | ↑ أسوأ قليلًا |
| Trend — no baseline | — first entry | — أول تسجيل |
| Success — add note | Add a note | إضافة ملاحظة |
| Success — done | Done | تم |

Visual reference: Arabic RTL nadir mockup: https://www.genspark.ai/api/files/s/HdptdwLu

---

## 6. Flutter Widget Tree

### `lib/screens/checkin/checkin_screen.dart`

```dart
class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(currentPhaseProvider);
    final form  = ref.watch(checkinFormProvider);
    final temp  = ref.watch(todayTemperatureProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(t.skip),
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Block A — Greeting + phase subhead
              GreetingHeader(phase: phase),
              const SizedBox(height: 20),

              // Block F — Red-flag banner (reactive)
              if (form.shouldShowFeverRedFlag)
                FeverRedFlagBanner(temp: temp!.value),

              // Block B — Overall mood
              SurfaceCard(
                child: MoodLikert(
                  value: form.mood,
                  onChanged: (v) =>
                    ref.read(checkinFormProvider.notifier).setMood(v),
                ),
              ),
              const SizedBox(height: 16),

              // Block C — Phase-aware symptom set
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(t.todaysSymptoms),
                    const SizedBox(height: 12),
                    ...form.activeSymptoms.map((s) => SymptomSegmented(
                      symptom: s,
                      value: form.severityFor(s),
                      onChanged: (v) => ref
                        .read(checkinFormProvider.notifier)
                        .setSeverity(s, v),
                    )),
                    const SizedBox(height: 8),

                    // Block D — Add another (progressive disclosure)
                    AddSymptomDisclosure(
                      available: form.availableExtraSymptoms,
                      onAdd: (s) => ref
                        .read(checkinFormProvider.notifier)
                        .addSymptom(s),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Block E — Temperature prompt (nadir only)
              if (phase == TreatmentPhase.nadir)
                TemperaturePromptCard(
                  lastReading: temp,
                  onTap: () => context.push('/vitals'),
                ),

              if (phase == TreatmentPhase.nadir)
                const SizedBox(height: 16),

              // Block G — Notes
              SurfaceCard(
                child: NotesField(
                  value: form.notes,
                  onChanged: (v) => ref
                    .read(checkinFormProvider.notifier)
                    .setNotes(v),
                  onVoiceTap: () => ref
                    .read(checkinFormProvider.notifier)
                    .startDictation(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: SubmitFooter(
        enabled: form.isValid,
        onSubmit: () async {
          await ref.read(checkinFormProvider.notifier).submit();
          if (context.mounted) context.go('/checkin/success');
        },
      ),
    );
  }
}
```

### `SymptomSegmented` — 5-point control

```dart
class SymptomSegmented extends StatelessWidget {
  final Symptom symptom;
  final int value;          // 0..4
  final ValueChanged<int> onChanged;

  const SymptomSegmented({
    super.key,
    required this.symptom,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(symptom.label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: i == 0 || i == 4 ? 0 : 2,
                ),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(i);
                  },
                  child: Container(
                    height: 48, // a11y target
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i <= value
                        ? Theme.of(context)
                            .extension<SeverityColors>()!
                            .forLevel(i)
                        : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Semantics(
                      label: '${symptom.label} ${kSeverityLabels[i]}',
                      selected: i == value,
                      child: Text(
                        kSeverityLabels[i],
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
```

### `CheckinSuccessScreen`

```dart
class CheckinSuccessScreen extends ConsumerWidget {
  const CheckinSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trend = ref.watch(checkinTrendProvider);
    final timestamp = ref.watch(lastCheckinTimestampProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                Icons.check_circle,
                size: 72,
                color: Color(0xFF2E8B57),
              ),
              const SizedBox(height: 12),
              Text(
                t.loggedAt(timestamp),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                t.careTeamCanSee,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              SurfaceCard(child: TrendComparisonBlock(trend: trend)),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(t.addNote),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => context.go('/'),
                      child: Text(t.done),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 7. State & Validation Rules

### `CheckinFormState` (Riverpod notifier)

```dart
class CheckinFormState {
  final int? mood;                       // 0..4 (Likert)
  final Map<Symptom, int> severities;    // symptom → 0..4
  final List<Symptom> activeSymptoms;    // phase default + user-added
  final String notes;
  final bool submitting;

  bool get isValid =>
      mood != null &&
      (severities.values.any((v) => v > 0) || notes.trim().isNotEmpty);

  bool get shouldShowFeverRedFlag =>
      currentPhase == TreatmentPhase.nadir &&
      (todayTemperature?.value ?? 0) >= 38.0;
}
```

### Severity mapping → legacy DB columns

5-point segmented values are stored as integers 0–10 to preserve compatibility with existing 0–10 NRS columns and historical data.

| Segmented (UI) | Stored value | Anchor |
|---|---|---|
| 0 | 0 | None |
| 1 | 2 | Mild |
| 2 | 5 | Moderate |
| 3 | 7 | Severe |
| 4 | 10 | Worst |

```dart
const kSegmentedToNrs = [0, 2, 5, 7, 10];
```

### Validation rules

| Rule | Behavior |
|---|---|
| Mood required | Submit disabled until set |
| At least one symptom rated OR notes filled | Submit disabled if all severities are 0 AND notes empty |
| Fever slider | Removed. `fever` column populated only from `/vitals`, mapped: <37.5 → 0, 37.5–37.9 → 4, 38.0–38.9 → 7, ≥39 → 10 |
| Red-flag banner | Appears immediately when temp ≥ 38°C in nadir; re-anchors at top |
| Notes | Optional, max 1000 chars |

### Offline submit

```dart
Future<void> submit() async {
  final payload = toSupabaseRow();
  try {
    await SupabaseService.insertCheckin(payload);
  } catch (_) {
    await CheckinOfflineQueue.enqueue(payload);
  }
  await UserSession().setCheckedInToday(true);
  await SupabaseService.refreshCheckinHistory();
}
```

A background sync flushes the queue on next network availability.

---

## 8. Migration Plan

| Step | Action |
|---|---|
| 1. Schema | No changes. Existing `mood, fatigue, pain, nausea, fever, mood_score, notes` columns sufficient. Extras temporarily written into `notes` as structured prefix: `[mouth_sores: mild; appetite: severe]\n{user note}`. JSONB `extra_symptoms` column targeted for v1.1. |
| 2. Routing | Keep `/checkin` as the new screen. Redirect `/checkin/sliders` → `/checkin` via GoRouter. |
| 3. Feature flag | Wrap with `Env.useNewCheckin` (default `true` in debug, gradual prod rollout via Supabase `feature_flags`). |
| 4. A/B metrics | Track `checkin_started`, `checkin_submitted`, `checkin_abandoned` + duration. Target: completion rate ≥ 85%, median time-to-submit ≤ 45s. |
| 5. Rollback | Toggling flag reverts to legacy 2-screen flow with zero data loss. |
| 6. Localization | Ship English first; Arabic shipped same release gated by `locale`. RTL `Directionality` wrapper added to MaterialApp now to avoid future churn. |

---

## 9. Open Questions for Product / Clinical

1. **Exact symptom set per phase** — clinical lead must sign off. Current proposal: Treatment (nausea, fatigue, infusion site), Nadir (fatigue, mouth sores, appetite, + temperature), Recovery (energy, mood, appetite). Aligned with oncology protocol?
2. **Escalation phone number** — for red-flag "Call care team now": assigned oncology nurse line, 24/7 hotline, or both with a chooser? Where does it live (patient record? clinic setting?)?
3. **Voice notes — audio or transcript?** Recommendation: on-device transcription (iOS Speech / Android SpeechRecognizer), discard audio. Confirm legal/compliance.
4. **Arabic grammatical gender** — `patients` table has `name` but not `gender`. Arabic copy defaults to feminine singular. Add `gender` field, infer from name (unreliable), or use gender-neutral forms (clunkier in clinical Arabic)?
5. **Skip button** — clinically, allow "skip today"? Argument for: respect autonomy. Against: gaps hurt PRO data quality. Current spec includes Skip; needs clinical sign-off.
6. **Extra-symptoms storage** — short-term hack writes into `notes`. Approve JSONB `extra_symptoms` column migration for v1.1?

---

## 10. Next Steps & Appendix

### P0 sprint allocation (recommended next 2 weeks)

| # | Title | Est. |
|---|-------|------|
| 1 | Merge `/checkin` + `/checkin/sliders` into single scrollable screen | 3d |
| 2 | Replace 0–10 sliders with 5-point segmented + verbal anchors | 2d |
| 3 | Remove `fever` slider; add phase-aware temperature prompt linking to `/vitals` | 1d |
| 4 | Red-flag banner when temp ≥ 38°C during nadir → one-tap call | 2d |
| 5 | Make symptom set phase-aware | 3d |
| 6 | "Add another symptom" disclosure | 2d |
| 7 | Redesign success screen: trend + manual dismiss + add-note CTA | 2d |

### Definition of Done — v1.0

- All 7 P0 items merged behind `Env.useNewCheckin` flag
- A/B metrics wired to Supabase `analytics_events`
- 5-patient remote usability test passed (≥4/5 complete in ≤60s without help)
- Arabic copy strings reviewed by native clinical Arabic speaker
- Accessibility audit passed (48dp targets, dynamic type, VoiceOver/TalkBack labels)
- Offline queue verified with airplane-mode test

### Glossary

- **NRS** — Numeric Rating Scale (0–10), standard pain/symptom measure
- **PRO-CTCAE** — Patient-Reported Outcomes version of Common Terminology Criteria for Adverse Events (NCI standard for cancer symptom self-report)
- **Nadir** — Lowest point of blood counts after chemotherapy, typically days 7–14 post-infusion; period of highest infection risk
- **RTL** — Right-to-left text direction (Arabic, Hebrew, Farsi)
- **PRO** — Patient-Reported Outcome

### Sign-off

| Role | Name | Date |
|---|---|---|
| Product Lead | | |
| Clinical Lead | | |
| Engineering Lead | | |
| Design Lead | | |

---

*End of specification. Rehlah Daily Check-in Redesign v1.0 · Confidential.*
