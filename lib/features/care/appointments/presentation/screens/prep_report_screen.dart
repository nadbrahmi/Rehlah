import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
import '../../../../../core/utils/models.dart';
import '../../../../../core/utils/user_session.dart';

class PrepReportScreen extends StatelessWidget {
  const PrepReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final next = MockData.appointments.first;
    final history = session.history.toList();
    final now = DateTime.now();

    // ── Period: last 14 days ──────────────────────────────────────────────
    final periodStart = now.subtract(const Duration(days: 13));
    final periodRecords = history.where((r) =>
        r.date.isAfter(periodStart)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final totalPossible = 14;
    final completed = periodRecords.length;
    final adherencePct = totalPossible > 0
        ? ((completed / totalPossible) * 100).round() : 0;
    final dateRange =
        '${DateFormat('d MMM').format(periodStart)} – ${DateFormat('d MMM').format(now)}';

    // ── Mood trend ────────────────────────────────────────────────────────
    final moodValues = <double>[];
    for (final r in periodRecords) {
      final v = _moodValue(r.moodEmoji);
      if (v > 0) moodValues.add(v);
    }
    final avgMood = moodValues.isEmpty
        ? 0.0
        : moodValues.reduce((a, b) => a + b) / moodValues.length;
    final moodTrend = _moodTrend(moodValues);

    // ── Symptom analysis across period ───────────────────────────────────
    final symptomDays = <String, List<double>>{};
    for (final r in periodRecords) {
      r.symptomScores.forEach((k, v) {
        if (v > 0) {
          symptomDays.putIfAbsent(k, () => []).add(v);
        }
      });
    }
    // Build symptom flags — only those that crossed threshold
    final flags = <_SymptomFlag>[];
    symptomDays.forEach((key, scores) {
      final avg = scores.reduce((a, b) => a + b) / scores.length;
      if (avg >= 2) { // only flag if avg score ≥ 2
        flags.add(_SymptomFlag(
          key: key,
          label: key.replaceAll('_', ' ').capitalize(),
          avgScore: avg,
          daysReported: scores.length,
          maxScore: scores.reduce((a, b) => a > b ? a : b),
        ));
      }
    });
    flags.sort((a, b) => b.avgScore.compareTo(a.avgScore));

    // ── Meds ──────────────────────────────────────────────────────────────
    final totalMeds = MockData.medications.length;
    final medAdherence = session.adherencePct(totalMeds);
    final medsTodayTaken = session.medsTakenTodayCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [

          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => context.go('/care/appointments'),
                child: Row(children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                    color: AppColors.text2.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text('Appointments', style: AppText.caption.copyWith(
                    color: AppColors.text2)),
                ]),
              ),
              const SizedBox(height: 12),
              RichText(text: TextSpan(style: AppText.displayTitle, children: const [
                TextSpan(text: 'Doctor-ready '),
                TextSpan(text: 'report',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              ])),
              Text('For ${next.doctorName} · ${DateFormat('d MMM').format(next.dateTime)}',
                style: AppText.bodySecondary),
            ]),
          )),

          // ── Report meta card ─────────────────────────────────────────────
          SliverToBoxAdapter(child: HeroCard(
            gradientColors: const [
              Color(0xFFC8D8F0), Color(0xFFCCC0EC), Color(0xFFC0D0E8)],
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                margin: const EdgeInsets.only(bottom: 9),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.18),
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: AppColors.blue.withOpacity(0.28), width: 0.5)),
                child: Text(
                  'Generated ${DateFormat('d MMM yyyy · HH:mm').format(now)}',
                  style: AppText.caption.copyWith(
                    color: const Color(0xFF245080),
                    fontWeight: FontWeight.w500, fontSize: 11))),
              Text(
                '${session.protocol.name} · Cycle ${session.currentCycle} of '
                '${session.totalCycles} · Day ${session.dayInCycle}',
                style: AppText.bodySemibold),
              Text(session.cancerType, style: AppText.bodySecondary),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _heroBtn('Share with doctor',
                    AppColors.blue.withOpacity(0.14),
                    AppColors.blue.withOpacity(0.22), AppColors.blue)),
                const SizedBox(width: 6),
                Expanded(child: _heroBtn('Save PDF',
                    Colors.white.withOpacity(0.55),
                    Colors.white.withOpacity(0.7), AppColors.text1)),
              ]),
            ]),
          )),

          // ── Section 1: Period Summary ─────────────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('1', 'Period Summary')),
          SliverToBoxAdapter(child: SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: completed == 0
                      ? AppColors.background2
                      : adherencePct >= 70
                          ? AppColors.teal.withOpacity(0.07)
                          : AppColors.peach.withOpacity(0.07),
                  borderRadius: AppRadius.smBR,
                  border: Border.all(
                    color: completed == 0
                        ? AppColors.border
                        : adherencePct >= 70
                            ? AppColors.teal.withOpacity(0.2)
                            : AppColors.peach.withOpacity(0.2),
                    width: 0.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Covering $dateRange — $completed of $totalPossible '
                      'check-ins completed ($adherencePct%)',
                      style: AppText.bodySemibold.copyWith(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      completed == 0
                          ? 'No check-ins recorded yet. Data reliability: none.'
                          : adherencePct >= 70
                              ? 'Data reliability: high. Results can be trusted.'
                              : adherencePct >= 40
                                  ? 'Data reliability: moderate. Some gaps present.'
                                  : 'Data reliability: low. Interpret with caution.',
                      style: AppText.bodySecondary.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                _statBox('$completed', 'Check-ins', AppColors.primary),
                const SizedBox(width: 8),
                _statBox('$adherencePct%', 'Completion', AppColors.teal),
                const SizedBox(width: 8),
                _statBox('${session.streak}d', 'Streak', AppColors.gold),
              ]),
            ]),
          )),

          // ── Section 2: Mood & Functional Trend ───────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('2', 'Mood & Functional Trend')),
          SliverToBoxAdapter(child: SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (moodValues.isEmpty)
                Text('No mood data yet. Complete check-ins to populate this section.',
                  style: AppText.bodySecondary.copyWith(
                    fontStyle: FontStyle.italic, fontSize: 12))
              else ...[
                // Trend line dots
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _buildTrendLine(periodRecords)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(avgMood.toStringAsFixed(1),
                          style: AppText.statNumber.copyWith(
                            color: AppColors.primary, fontSize: 22)),
                        Text('avg / 5.0',
                          style: AppText.caption.copyWith(fontSize: 10)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: moodTrend == 'improving'
                                ? AppColors.tealLight
                                : moodTrend == 'declining'
                                    ? AppColors.roseLight
                                    : AppColors.background2,
                            borderRadius: AppRadius.fullBR),
                          child: Text(
                            moodTrend == 'improving' ? '↑ Improving'
                                : moodTrend == 'declining' ? '↓ Declining'
                                : '→ Stable',
                            style: AppText.caption.copyWith(
                              fontSize: 10,
                              color: moodTrend == 'improving'
                                  ? AppColors.teal
                                  : moodTrend == 'declining'
                                      ? AppColors.rose
                                      : AppColors.text2,
                              fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: AppColors.border, height: 1, thickness: 0.5),
                const SizedBox(height: 8),
                // AI summary sentence
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.04),
                    borderRadius: AppRadius.smBR,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.12), width: 0.5)),
                  child: Text(
                    _moodSummary(avgMood, moodTrend, flags),
                    style: AppText.bodySecondary.copyWith(
                      fontSize: 12, fontStyle: FontStyle.italic,
                      height: 1.6))),
              ],
            ]),
          )),

          // ── Section 3: Symptom Flags ──────────────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('3', 'Symptom Flags')),
          SliverToBoxAdapter(child: SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (flags.isEmpty)
                Text(
                  completed == 0
                      ? 'No symptom data. Complete check-ins to populate this section.'
                      : 'No symptoms crossed the reporting threshold.',
                  style: AppText.bodySecondary.copyWith(
                    fontStyle: FontStyle.italic, fontSize: 12))
              else ...[
                Text('Only symptoms crossing reporting threshold (avg ≥ 2/10)',
                  style: AppText.caption.copyWith(
                    fontSize: 10, color: AppColors.text3)),
                const SizedBox(height: 10),
                ...flags.take(6).map((f) => _buildSymptomFlag(f, completed)),
              ],
            ]),
          )),

          // ── Section 4: Medication Adherence ──────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('4', 'Medication Adherence')),
          SliverToBoxAdapter(child: SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Adherence bar
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('14-day adherence',
                      style: AppText.bodySecondary),
                    const SizedBox(height: 6),
                    Stack(children: [
                      Container(height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.background2,
                          borderRadius: AppRadius.fullBR)),
                      FractionallySizedBox(
                        widthFactor: (medAdherence / 100).clamp(0.0, 1.0),
                        child: Container(height: 8,
                          decoration: BoxDecoration(
                            color: medAdherence >= 80
                                ? AppColors.teal
                                : medAdherence >= 50
                                    ? AppColors.peach
                                    : AppColors.rose,
                            borderRadius: AppRadius.fullBR))),
                    ]),
                  ],
                )),
                const SizedBox(width: 16),
                Text(
                  medAdherence > 0 ? '$medAdherence%' : '—',
                  style: AppText.statNumber.copyWith(
                    color: medAdherence >= 80
                        ? AppColors.teal
                        : medAdherence >= 50
                            ? AppColors.peach
                            : AppColors.text2,
                    fontSize: 22)),
              ]),
              const SizedBox(height: 12),
              // Today's status
              Row(children: [
                Expanded(child: _statBox(
                  '$medsTodayTaken/$totalMeds',
                  'Today', AppColors.teal)),
                const SizedBox(width: 8),
                Expanded(child: _statBox(
                  medAdherence >= 80 ? 'Good' : medAdherence >= 50 ? 'Fair' : 'Low',
                  '14-day',
                  medAdherence >= 80 ? AppColors.teal : AppColors.peach)),
              ]),
              const SizedBox(height: 10),
              // Med list
              ...MockData.medications.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Text(m.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${m.name} · ${m.dose}',
                        style: AppText.bodySemibold.copyWith(fontSize: 12)),
                      Text(m.frequency,
                        style: AppText.caption.copyWith(fontSize: 10)),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: session.isMedTaken(m.id)
                          ? AppColors.tealLight : AppColors.background2,
                      borderRadius: AppRadius.fullBR),
                    child: Text(
                      session.isMedTaken(m.id) ? 'Taken today ✓' : 'Not yet today',
                      style: AppText.caption.copyWith(
                        fontSize: 10,
                        color: session.isMedTaken(m.id)
                            ? AppColors.teal : AppColors.text3))),
                ]),
              )),
            ]),
          )),

          // ── Section 5: Lab Correlation ────────────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('5', 'Lab Correlation')),
          SliverToBoxAdapter(child: SurfaceCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // AI correlation based on symptoms
              if (flags.isEmpty)
                Text('Add lab results and complete check-ins to see correlations.',
                  style: AppText.bodySecondary.copyWith(
                    fontStyle: FontStyle.italic, fontSize: 12))
              else ...[
                Text('Correlating reported symptoms with last lab results',
                  style: AppText.caption.copyWith(
                    fontSize: 10, color: AppColors.text3)),
                const SizedBox(height: 10),
                ..._buildLabCorrelations(flags, session),
              ],
              const SizedBox(height: 10),
              // Last CBC values from MockData
              Divider(color: AppColors.border, height: 1, thickness: 0.5),
              const SizedBox(height: 8),
              Text('LAST LAB VALUES', style: AppText.label.copyWith(fontSize: 10)),
              const SizedBox(height: 6),
              ...[
                ('WBC', '3.2', 'K/μL', AppColors.peach, 'Low — nadir expected'),
                ('Hemoglobin', '10.2', 'g/dL', AppColors.peach, 'Below normal range'),
                ('Platelets', '182', 'K/μL', AppColors.teal, 'Within range'),
                ('Neutrophils', '1.4', 'K/μL', AppColors.peach, 'Watch closely'),
              ].map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(children: [
                  Container(width: 5, height: 5,
                    decoration: BoxDecoration(
                      color: l.$4, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.$1,
                    style: AppText.bodySemibold.copyWith(fontSize: 12))),
                  Text('${l.$2} ${l.$3}',
                    style: AppText.bodySecondary.copyWith(fontSize: 12)),
                  const SizedBox(width: 8),
                  Text(l.$5,
                    style: AppText.caption.copyWith(
                      color: l.$4, fontSize: 10)),
                ]),
              )),
            ]),
          )),

          // ── Disclaimer ────────────────────────────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 32),
            child: Text(
              'This report is generated from patient self-reported data via Rehlah. '
              'It is a summary of the patient\'s own records and should be used '
              'alongside clinical assessment.',
              style: AppText.caption.copyWith(
                fontSize: 11, fontStyle: FontStyle.italic,
                color: AppColors.text3),
              textAlign: TextAlign.center),
          )),
        ]),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────
  Widget _sectionHeader(String num, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary, shape: BoxShape.circle),
          child: Center(child: Text(num,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
              fontWeight: FontWeight.w600, color: Colors.white)))),
        const SizedBox(width: 8),
        Text(title, style: AppText.sectionHeading.copyWith(fontSize: 14)),
      ]),
    );
  }

  Widget _heroBtn(String label, Color bg, Color border, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg, borderRadius: AppRadius.mdBR,
        border: Border.all(color: border, width: 0.5)),
      child: Center(child: Text(label,
        style: AppText.caption.copyWith(
          color: text, fontWeight: FontWeight.w500))));
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: AppRadius.smBR,
        border: Border.all(color: color.withOpacity(0.15), width: 0.5)),
      child: Column(children: [
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 15,
          fontWeight: FontWeight.w600, color: color)),
        Text(label, style: AppText.caption.copyWith(fontSize: 9)),
      ]),
    ));
  }

  Widget _buildTrendLine(List<CheckInRecord> records) {
    if (records.isEmpty) return const SizedBox(height: 48);
    final values = records.map((r) => _moodValue(r.moodEmoji)).toList();
    return SizedBox(
      height: 48,
      child: CustomPaint(
        painter: _TrendPainter(values),
        child: const SizedBox.expand()),
    );
  }

  Widget _buildSymptomFlag(_SymptomFlag f, int totalDays) {
    final sev = f.avgScore >= 7 ? 'high'
        : f.avgScore >= 4 ? 'moderate' : 'low';
    final sevColor = sev == 'high' ? AppColors.rose
        : sev == 'moderate' ? AppColors.peach : AppColors.teal;
    final sevIcon = sev == 'high' ? '🔴' : sev == 'moderate' ? '🟡' : '🟢';
    final talkingPoint = _symptomTalkingPoint(f.key, f.avgScore, f.daysReported);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: sevColor.withOpacity(0.04),
        borderRadius: AppRadius.smBR,
        border: Border.all(color: sevColor.withOpacity(0.18), width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(sevIcon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 7),
          Expanded(child: Text(f.label,
            style: AppText.bodySemibold.copyWith(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: sevColor.withOpacity(0.10),
              borderRadius: AppRadius.fullBR),
            child: Text('${f.avgScore.toStringAsFixed(1)}/10',
              style: AppText.caption.copyWith(
                color: sevColor, fontWeight: FontWeight.w600, fontSize: 11))),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          _flagPill('${f.daysReported} of $totalDays days', AppColors.text3),
          const SizedBox(width: 6),
          _flagPill('Max ${f.maxScore.toInt()}/10', sevColor),
          const SizedBox(width: 6),
          _flagPill(sev.capitalize(), sevColor),
        ]),
        const SizedBox(height: 6),
        Text('"$talkingPoint"',
          style: AppText.bodySecondary.copyWith(
            fontSize: 11, fontStyle: FontStyle.italic, height: 1.5)),
      ]),
    );
  }

  Widget _flagPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: AppRadius.fullBR,
        border: Border.all(color: color.withOpacity(0.15), width: 0.5)),
      child: Text(text, style: AppText.caption.copyWith(
        fontSize: 10, color: color)));
  }

  List<Widget> _buildLabCorrelations(
      List<_SymptomFlag> flags, UserSession session) {
    final correlations = <String>[];

    // Fatigue → Hemoglobin
    if (flags.any((f) => f.key == 'fatigue' || f.key == 'energy')) {
      correlations.add(
          'Hemoglobin 10.2 — consistent with reported fatigue pattern. '
          'Below normal range may explain reduced energy levels.');
    }
    // Infection/fever → WBC
    if (flags.any((f) => f.key == 'fever' || f.key == 'infection') ||
        session.isNadirWindow) {
      correlations.add(
          'WBC 3.2 K/μL — low count consistent with nadir phase. '
          'Elevated infection risk. Temperature monitoring is essential.');
    }
    // Breathlessness → Hemoglobin
    if (flags.any((f) => f.key == 'breathlessness')) {
      correlations.add(
          'Hemoglobin 10.2 — mild anaemia may contribute to reported breathlessness. '
          'Consider whether iron supplementation discussion is warranted.');
    }
    // Mouth sores → WBC
    if (flags.any((f) => f.key == 'mouth_sores')) {
      correlations.add(
          'WBC 3.2 — low white cell count may be contributing to mouth sores. '
          'Neutrophils 1.4 K/μL — borderline low.');
    }

    if (correlations.isEmpty) {
      correlations.add(
          'No direct correlations identified between current symptoms and lab values. '
          'All reported symptoms appear within expected range for this treatment phase.');
    }

    return correlations.map((c) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.05),
        borderRadius: AppRadius.smBR,
        border: Border.all(color: AppColors.blue.withOpacity(0.15), width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🔗', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 7),
        Expanded(child: Text(c,
          style: AppText.bodySecondary.copyWith(
            fontSize: 12, height: 1.5))),
      ]),
    )).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  double _moodValue(String emoji) {
    const map = {'😣': 1, '😔': 2, '😐': 3, '🙂': 4, '😊': 5,
                 '😄': 5, '😢': 1, '😕': 2, '🙁': 2};
    return (map[emoji] ?? 0).toDouble();
  }

  String _moodTrend(List<double> values) {
    if (values.length < 3) return 'stable';
    final first = values.take(values.length ~/ 2).reduce((a, b) => a + b) /
        (values.length ~/ 2);
    final last = values.skip(values.length ~/ 2).reduce((a, b) => a + b) /
        (values.length - values.length ~/ 2);
    if (last > first + 0.3) return 'improving';
    if (last < first - 0.3) return 'declining';
    return 'stable';
  }

  String _moodSummary(double avg, String trend, List<_SymptomFlag> flags) {
    final trendStr = trend == 'improving' ? 'improving week-on-week'
        : trend == 'declining' ? 'declining over the period'
        : 'stable across the period';
    final dominant = flags.isNotEmpty ? flags.first.label.toLowerCase() : null;
    final base = 'Mood $trendStr (avg ${avg.toStringAsFixed(1)}/5.0).';
    if (dominant != null) {
      return '$base ${'$dominant'.capitalize()} remains the dominant reported symptom.';
    }
    return '$base No dominant symptom pattern identified.';
  }

  String _symptomTalkingPoint(String key, double avg, int days) {
    const tips = {
      'fatigue': 'Ask about impact on daily activities and whether dose adjustment warrants discussion',
      'nausea': 'Currently managed — confirm anti-emetic regimen is still effective',
      'fever': 'Clarify fever threshold protocol and when to call emergency line',
      'pain': 'Describe location, type and duration — ask about pain management options',
      'mouth_sores': 'Ask about mouthwash protocol and whether dose reduction is appropriate',
      'neuropathy': 'Document affected areas — dose reduction may be indicated if worsening',
      'breathlessness': 'Clarify onset triggers — may warrant anaemia assessment',
      'mood': 'Discuss emotional support options and whether psychological referral would help',
      'sleep': 'Ask about sleep hygiene support or pharmacological options',
      'appetite': 'Ask about nutritional supplements and dietitian referral',
      'infection': 'Clarify infection signs and emergency contact protocol',
      'vomiting': 'Review anti-emetic medication — may need adjustment',
      'joint_pain': 'Document severity and functional impact — consider physio referral',
    };
    return tips[key] ??
        'Discuss severity (avg ${avg.toStringAsFixed(1)}/10 over $days days) and management options';
  }
}

// ── Symptom flag model ────────────────────────────────────────────────────────
class _SymptomFlag {
  final String key, label;
  final double avgScore, maxScore;
  final int daysReported;

  const _SymptomFlag({
    required this.key, required this.label,
    required this.avgScore, required this.daysReported,
    required this.maxScore,
  });
}

// ── Trend line painter ────────────────────────────────────────────────────────
class _TrendPainter extends CustomPainter {
  final List<double> values;
  _TrendPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.15),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / 5.0) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / 5.0) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.values != values;
}

extension _StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
