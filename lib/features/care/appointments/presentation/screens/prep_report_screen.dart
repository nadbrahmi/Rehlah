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
    session.initDefaultAppointments();
    final upcoming = session.upcomingAppointments;
    final next = upcoming.isNotEmpty ? upcoming.first : null;
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
    final totalMeds = UserSession().medications.length;
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
              Text('For ${next?.doctorName ?? 'your doctor'} · ${next != null ? DateFormat('d MMM').format(next.dateTime) : 'upcoming'}',
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

          // ── Section 2: In her own words ──────────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('2', 'في كلماتها | In Her Own Words')),
          SliverToBoxAdapter(child: _buildPatientVoiceSection(periodRecords)),

          // ── Section 3: Mood & Functional Trend ───────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('3', 'Mood & Functional Trend')),
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

          // ── Section 4: Symptom Flags ──────────────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('4', 'Symptom Flags')),
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

          // ── Section 5: Functional Status ─────────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('5', 'الوضع الوظيفي | Functional Status')),
          SliverToBoxAdapter(child: _buildFunctionalStatusSection(periodRecords)),

          // ── Section 6: Medication Adherence ──────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('6', 'Medication Adherence')),
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
              ...UserSession().medications.map((m) => Padding(
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

          // ── Section 7: Lab Correlation ────────────────────────────────────
          SliverToBoxAdapter(child: _sectionHeader('7', 'Lab Correlation')),
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
              // Last lab values from session
              Divider(color: AppColors.border, height: 1, thickness: 0.5),
              const SizedBox(height: 8),
              Text('LAST LAB VALUES', style: AppText.label.copyWith(fontSize: 10)),
              const SizedBox(height: 6),
              Builder(builder: (_) {
                final latestLab = session.labs.isNotEmpty ? session.labs.first : null;
                if (latestLab == null) {
                  return Text('No lab results logged yet.',
                    style: AppText.bodySecondary.copyWith(
                      fontSize: 12, fontStyle: FontStyle.italic));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${latestLab.panelName} · ${DateFormat('d MMM yyyy').format(latestLab.date)}',
                      style: AppText.caption.copyWith(
                        fontSize: 10, color: AppColors.text3)),
                    const SizedBox(height: 6),
                    ...latestLab.metrics.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(children: [
                        Container(width: 5, height: 5,
                          decoration: BoxDecoration(
                            color: m.isLow ? AppColors.peach
                                : m.isHigh ? AppColors.rose
                                : AppColors.teal,
                            shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(m.name,
                          style: AppText.bodySemibold.copyWith(fontSize: 12))),
                        Text('${m.value} ${m.unit}',
                          style: AppText.bodySecondary.copyWith(fontSize: 12)),
                        const SizedBox(width: 8),
                        Text(m.isLow ? 'Low' : m.isHigh ? 'High' : 'Normal',
                          style: AppText.caption.copyWith(
                            color: m.isLow ? AppColors.peach
                                : m.isHigh ? AppColors.rose
                                : AppColors.teal,
                            fontSize: 10)),
                      ]),
                    )),
                  ],
                );
              }),
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
    final values = records.map((r) => _moodValue(r.moodEmoji)).toList().cast<double>();
    return SizedBox(
      height: 48,
      child: CustomPaint(
        painter: _TrendPainter(values),
        child: const SizedBox.expand()),
    );
  }

  Widget _buildPatientVoiceSection(List<CheckInRecord> records) {
    final notes = records
        .where((r) => r.note.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (notes.isEmpty)
          Text(
            'No notes recorded in the last 14 days. When the patient writes in their own words, those notes appear here — verbatim and unedited.',
            style: AppText.bodySecondary.copyWith(
              fontStyle: FontStyle.italic, fontSize: 12))
        else ...[
          Text(
            'Verbatim notes from the last ${notes.length} check-in${notes.length > 1 ? 's' : ''} — unedited, as written by the patient.',
            style: AppText.caption.copyWith(fontSize: 10, color: AppColors.text3)),
          const SizedBox(height: 10),
          ...notes.take(5).map((r) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: AppRadius.smBR,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15), width: 0.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat('d MMM').format(r.date),
                style: AppText.caption.copyWith(
                  fontSize: 10, color: AppColors.text3)),
              const SizedBox(height: 4),
              Text('"${r.note.trim()}"',
                style: AppText.body.copyWith(
                  fontSize: 13, fontStyle: FontStyle.italic,
                  color: AppColors.text1, height: 1.6)),
            ]),
          )),
        ],
      ]),
    );
  }

  Widget _buildFunctionalStatusSection(List<CheckInRecord> records) {
    final interferenceDays =
        records.where((r) => r.hasInterferenceToday).length;

    // Physical activity distribution from recovery phase records
    final recoveryRecords =
        records.where((r) => r.physicalActivity != null).toList();
    final noneCount =
        recoveryRecords.where((r) => r.physicalActivity == 'none').length;
    final lightCount =
        recoveryRecords.where((r) => r.physicalActivity == 'light').length;
    final moderateCount =
        recoveryRecords.where((r) => r.physicalActivity == 'moderate').length;

    // HADS anxiety from recovery records
    final hadsRecords =
        records.where((r) => r.hadsAnxietyScore >= 0).toList();
    final avgHads = hadsRecords.isEmpty
        ? -1.0
        : hadsRecords.map((r) => r.hadsAnxietyScore).reduce((a, b) => a + b) /
            hadsRecords.length;

    // Consecutive elevated HADS (≥8) recovery phases
    final elevatedHads =
        hadsRecords.where((r) => r.hadsAnxietyScore >= 8).length;

    return SurfaceCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Interference count
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: interferenceDays > 7
                ? AppColors.peach.withOpacity(0.07)
                : AppColors.teal.withOpacity(0.07),
            borderRadius: AppRadius.smBR,
            border: Border.all(
              color: interferenceDays > 7
                  ? AppColors.peach.withOpacity(0.2)
                  : AppColors.teal.withOpacity(0.2),
              width: 0.5)),
          child: Row(children: [
            Text(interferenceDays > 7 ? '⚠' : '✓',
              style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'On $interferenceDays of ${records.length} days, symptoms interfered with normal daily activities.',
              style: AppText.bodySemibold.copyWith(fontSize: 13))),
          ]),
        ),

        // Physical activity (if recovery data available)
        if (recoveryRecords.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('PHYSICAL ACTIVITY · أسبوع التعافي',
            style: AppText.label.copyWith(fontSize: 10)),
          const SizedBox(height: 6),
          Row(children: [
            _statBox('$noneCount', 'None 🛋️', AppColors.rose),
            const SizedBox(width: 6),
            _statBox('$lightCount', 'Light 🚶', AppColors.peach),
            const SizedBox(width: 6),
            _statBox('$moderateCount', 'Moderate 🏃', AppColors.teal),
          ]),
          const SizedBox(height: 4),
          Text(
            'Reported on ${recoveryRecords.length} recovery-phase check-in${recoveryRecords.length > 1 ? 's' : ''}. '
            'Physical activity during treatment reduces fatigue and improves survival outcomes (ASCO/ESMO).',
            style: AppText.caption.copyWith(
              fontSize: 10, color: AppColors.text3, height: 1.5)),
        ],

        // HADS anxiety indicator
        if (hadsRecords.isNotEmpty) ...[
          const SizedBox(height: 12),
          Divider(color: AppColors.border, height: 1, thickness: 0.5),
          const SizedBox(height: 10),
          Text('HADS ANXIETY INDICATOR · مؤشر القلق',
            style: AppText.label.copyWith(fontSize: 10)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: avgHads >= 8
                    ? AppColors.peach.withOpacity(0.08)
                    : avgHads >= 5
                        ? AppColors.gold.withOpacity(0.08)
                        : AppColors.teal.withOpacity(0.08),
                borderRadius: AppRadius.smBR,
                border: Border.all(
                  color: avgHads >= 8
                      ? AppColors.peach.withOpacity(0.25)
                      : avgHads >= 5
                          ? AppColors.gold.withOpacity(0.25)
                          : AppColors.teal.withOpacity(0.25),
                  width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    avgHads >= 8 ? '🔴 High anxiety' : avgHads >= 5 ? '🟡 Moderate anxiety' : '🟢 Low anxiety',
                    style: AppText.bodySemibold.copyWith(fontSize: 13)),
                  Text(
                    'Avg HADS score ${avgHads.toStringAsFixed(1)} / 12 · '
                    'Based on ${hadsRecords.length} recovery-phase check-in${hadsRecords.length > 1 ? 's' : ''}',
                    style: AppText.caption.copyWith(fontSize: 10, color: AppColors.text3)),
                  if (elevatedHads >= 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '⚠ Elevated anxiety on $elevatedHads consecutive recovery phases — consider psychosocial referral.',
                        style: AppText.caption.copyWith(
                          fontSize: 11, color: AppColors.peach, height: 1.4))),
                ]),
            )),
          ]),
        ],
      ]),
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
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.04),
            borderRadius: AppRadius.smBR,
            border: Border.all(color: AppColors.blue.withOpacity(0.15), width: 0.5)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('💬', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 6),
            Expanded(child: Text(talkingPoint,
              style: AppText.bodySecondary.copyWith(
                fontSize: 11, fontStyle: FontStyle.italic, height: 1.5))),
          ])),
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
    final latestLab = session.labs.isNotEmpty ? session.labs.first : null;

    // Get real values from latest lab if available
    double? hgb = latestLab?.metrics
        .where((m) => m.name == 'Hemoglobin').firstOrNull?.value;
    double? wbc = latestLab?.metrics
        .where((m) => m.name == 'WBC').firstOrNull?.value;
    double? neutrophils = latestLab?.metrics
        .where((m) => m.name == 'Neutrophils').firstOrNull?.value;

    // Fatigue → Hemoglobin
    if (flags.any((f) => f.key == 'fatigue' || f.key == 'energy')) {
      if (hgb != null && hgb < 12) {
        correlations.add(
            'Hemoglobin $hgb g/dL — below normal range, consistent with reported fatigue. '
            'May explain reduced energy levels.');
      } else {
        correlations.add(
            'Fatigue reported — not clearly linked to Hemoglobin levels. '
            'May be treatment-related. Worth discussing with your team.');
      }
    }
    // Infection/fever → WBC/Neutrophils
    if (flags.any((f) => f.key == 'fever' || f.key == 'infection') ||
        session.isNadirWindow) {
      if (neutrophils != null && neutrophils < 1.8) {
        correlations.add(
            'Neutrophils $neutrophils K/µL — low, consistent with nadir phase. '
            'Elevated infection risk. Temperature monitoring is essential.');
      } else if (wbc != null) {
        correlations.add(
            'WBC $wbc K/µL — ${wbc < 4.5 ? 'below normal range' : 'within range'}. '
            'Monitor for signs of infection given treatment phase.');
      }
    }
    // Breathlessness → Hemoglobin
    if (flags.any((f) => f.key == 'breathlessness')) {
      if (hgb != null && hgb < 12) {
        correlations.add(
            'Hemoglobin $hgb g/dL — mild anaemia may contribute to breathlessness. '
            'Consider whether iron supplementation discussion is warranted.');
      }
    }
    // Mouth sores → WBC
    if (flags.any((f) => f.key == 'mouth_sores')) {
      if (wbc != null && wbc < 4.5) {
        correlations.add(
            'WBC $wbc — low white cell count may be contributing to mouth sores. '
            '${neutrophils != null ? 'Neutrophils $neutrophils K/µL.' : ''}');
      }
    }

    if (correlations.isEmpty) {
      if (latestLab == null) {
        correlations.add(
            'No lab results logged yet. Add lab results to see correlations '
            'with your reported symptoms.');
      } else {
        correlations.add(
            'No direct correlations identified between current symptoms and lab values. '
            'All reported symptoms appear within expected range for this treatment phase.');
      }
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
    // Framed as shared decision prompts (co-construction), not one-way summaries
    const prompts = {
      'fatigue': 'Fatigue is limiting daily activity — discuss together what level of activity is realistic and manageable this cycle',
      'nausea': 'Nausea has been present this period — explore together whether the current anti-emetic approach is working and what to adjust',
      'fever': 'Temperature monitoring has flagged concerns — decide together the threshold and exact contact to call, day or night',
      'pain': 'Pain is affecting daily life — explore together where it is, what type, and what management options are realistic right now',
      'mouth_sores': 'Mouth sores are interfering with eating — discuss together the mouthwash protocol and whether a dose adjustment is the right call',
      'neuropathy': 'Tingling and numbness are present — document together the affected areas and decide whether dose adjustment is warranted',
      'breathlessness': 'Breathlessness has been reported — explore together what triggers it and whether an anaemia assessment is needed now',
      'mood': 'Mood has been difficult this period — explore together what support would actually help: psychological referral, a peer group, or another option',
      'sleep': 'Sleep has been disrupted — decide together what to try first: sleep hygiene, relaxation techniques, or pharmacological support',
      'appetite': 'Appetite has been reduced — discuss together whether nutritional supplements or a dietitian referral would help most right now',
      'infection': 'Signs of infection concern have been reported — agree together on the exact symptoms to watch and the specific number to call',
      'vomiting': 'Vomiting has occurred — review together whether the anti-emetic medication needs to be changed or adjusted',
      'joint_pain': 'Joint pain is affecting movement — discuss together its functional impact and whether physiotherapy referral is the right next step',
      'anxiety': 'Anxiety has been elevated this period — explore together what form of support would be most helpful right now',
      'hot_flashes': 'Hot flashes are frequent — discuss together management options and whether current hormone therapy plan needs reviewing',
    };
    return prompts[key] ??
        'This symptom has been present for $days of 14 days (avg ${avg.toStringAsFixed(1)}/10) — discuss together what is manageable this cycle';
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
