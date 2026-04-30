import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';
import 'my_health_expect_screen.dart';

class MyHealthJourneyScreen extends StatefulWidget {
  const MyHealthJourneyScreen({super.key});
  @override
  State<MyHealthJourneyScreen> createState() => _MyHealthJourneyState();
}

class _MyHealthJourneyState extends State<MyHealthJourneyScreen> {
  int _segIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        Positioned(top: -40, right: -20,
          child: Container(width: 160, height: 160,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withOpacity(0.09), Colors.transparent])))),
        SafeArea(child: Column(children: [
          _buildSegControl(session),
          Expanded(child: _segIndex == 0
              ? _buildJourneyTab(session)
              : MyHealthExpectScreen(embedded: true)),
        ])),
      ]),
    );
  }

  Widget _buildSegControl(UserSession session) {
    return Column(children: [
      AppHeader(
        title: 'My |Health',
        subtitle: session.isMonitoring
            ? '${session.cancerType} · Monitoring & surveillance'
            : '${session.cancerType} · ${session.protocol.name} · Cycle ${session.currentCycle}',
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Container(
          height: 36,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: AppRadius.fullBR),
          child: Row(
            children: ['My Journey', 'What to Expect'].asMap().entries.map((e) {
              final active = e.key == _segIndex;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _segIndex = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: active ? AppColors.surface : Colors.transparent,
                    borderRadius: AppRadius.fullBR,
                    boxShadow: active ? [BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 4)] : null),
                  child: Center(child: Text(e.value,
                    style: AppText.body.copyWith(
                      fontSize: 12,
                      color: active ? AppColors.primary : AppColors.text3,
                      fontWeight: active ? FontWeight.w500 : FontWeight.w400))),
                ),
              ));
            }).toList(),
          ),
        ),
      ),
    ]);
  }

  Widget _buildJourneyTab(UserSession session) {
    final phase = session.currentPhase;
    final progress = session.currentCycle / session.totalCycles;
    final progressPct = (progress * 100).round();

    if (session.isMonitoring) {
      return _buildMonitoringJourney(session);
    }

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 4),
        _buildPhaseCard(session, progress, progressPct),
        // Phase note insight
        InsightCard(
          title: '${session.protocol.name} · ${phase.name}',
          body: phase.phaseNote,
        ),
        const SectionLabel('Your milestones'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: _buildMilestones(session)),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildPhaseCard(UserSession session, double progress, int progressPct) {
    final phase = session.currentPhase;
    final isNadir = session.isNadirWindow;
    final totalCycles = session.totalCycles;
    final currentCycle = session.currentCycle;

    // Build cycle segments (max 5 shown)
    final segCount = totalCycles > 5 ? 5 : totalCycles;
    final segSize = totalCycles / segCount;

    return HeroCard(
      gradientColors: const [Color(0xFFD4E8F0), Color(0xFFCCC0EC), Color(0xFFC8D8F0)],
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Status pill
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: AppRadius.fullBR,
              border: Border.all(color: Colors.white.withOpacity(0.7), width: 0.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5, decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNadir ? AppColors.peach : AppColors.teal)),
              const SizedBox(width: 4),
              Text(isNadir ? 'Nadir window ⚠' : 'Active treatment',
                style: AppText.caption.copyWith(
                  color: isNadir ? AppColors.peach : AppColors.primaryDark,
                  fontWeight: FontWeight.w500, fontSize: 10)),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Text(session.treatmentPhase,
          style: AppText.sectionHeading.copyWith(fontSize: 15)),
        Text('${session.cancerType} · ${session.protocol.name} · Cycle $currentCycle of $totalCycles · Day ${session.dayInCycle}',
          style: AppText.bodySecondary),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Treatment progress', style: AppText.caption),
          Text('$progressPct%', style: AppText.caption.copyWith(
            color: AppColors.teal, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 4),
        AppProgressBar(value: progress, foreground: AppColors.teal),
        const SizedBox(height: 10),
        // Cycle segments
        Row(children: List.generate(segCount, (i) {
          final segCycle = ((i * segSize) + 1).round();
          final isCurrent = currentCycle >= segCycle &&
              currentCycle < (segCycle + segSize);
          final isDone = currentCycle > segCycle + segSize - 1;
          final label = segCount == totalCycles
              ? 'C$segCycle'
              : 'C$segCycle–${(segCycle + segSize - 1).round()}';
          return Expanded(child: Container(
            margin: EdgeInsets.only(right: i < segCount - 1 ? 4 : 0),
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppColors.primary.withOpacity(0.22)
                  : isDone
                      ? AppColors.teal.withOpacity(0.18)
                      : Colors.white.withOpacity(0.35),
              borderRadius: AppRadius.smBR,
              border: isCurrent
                  ? Border.all(color: AppColors.primaryMid, width: 0.5)
                  : null),
            child: Center(child: Text(
              isCurrent ? '$label ←' : label,
              style: AppText.caption.copyWith(
                fontSize: 9, fontWeight: FontWeight.w500,
                color: isCurrent ? AppColors.primary
                    : isDone ? AppColors.teal : AppColors.text3))),
          ));
        })),
      ]),
    );
  }

  List<Widget> _buildMilestones(UserSession session) {
    final currentCycle = session.currentCycle;
    final totalCycles = session.totalCycles;
    final midpoint = (totalCycles / 2).ceil();
    final isBeforeMid = currentCycle < midpoint;
    final isAtMid = currentCycle == midpoint;
    final isAfterMid = currentCycle > midpoint;

    return [
      _milestoneRow('ms-done', 'Diagnosis confirmed',
          'The hardest day — and the start of your fight.', null),
      _milestoneRow('ms-done', 'First ${session.protocol.name} session',
          'The first step is always the bravest.', null),
      if (currentCycle > 1)
        _milestoneRow('ms-done',
            'Cycle ${currentCycle - 1} complete',
            'Each cycle completed is a step closer.', null),
      _milestoneRow('ms-cur',
          'Cycle $currentCycle · Day ${session.dayInCycle}',
          session.currentPhase.phaseNote, null,
          badge: '← You are here'),
      if (!isAtMid && isBeforeMid)
        _milestoneRow('ms-fut',
            'Midpoint · Cycle $midpoint',
            'Halfway through your treatment plan.', null),
      _milestoneRow('ms-fut',
          'Final session · Cycle $totalCycles',
          'The last one. You\'re getting there.', null),
      _milestoneRow('ms-fut',
          'Recovery & monitoring',
          'Regular scans. Your body begins to heal.', null),
      _milestoneRow('ms-surv', 'Survivorship 🌟',
          'Life beyond treatment. Always visible, always the goal.',
          null, last: true),
    ];
  }

  Widget _milestoneRow(String type, String name, String desc,
      String? date, {String? badge, bool last = false}) {
    Color dotBg, lineColor;
    Widget? dotIcon;
    switch (type) {
      case 'ms-done':
        dotBg = AppColors.tealLight;
        lineColor = AppColors.teal.withOpacity(0.5);
        dotIcon = Icon(Icons.check_rounded, size: 9, color: AppColors.teal);
        break;
      case 'ms-cur':
        dotBg = AppColors.primaryLight;
        lineColor = AppColors.border;
        dotIcon = Container(width: 6, height: 6, decoration: const BoxDecoration(
          shape: BoxShape.circle, color: AppColors.primary));
        break;
      case 'ms-surv':
        dotBg = AppColors.gold.withOpacity(0.09);
        lineColor = Colors.transparent;
        break;
      default:
        dotBg = Colors.white.withOpacity(0.5);
        lineColor = AppColors.border;
    }

    final nameStyle = AppText.bodySemibold.copyWith(
      fontSize: 13,
      color: type == 'ms-done'
          ? AppColors.text2
          : type == 'ms-fut'
              ? AppColors.text3
              : type == 'ms-surv'
                  ? AppColors.gold.withOpacity(0.55)
                  : AppColors.text1,
    );

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: dotBg, shape: BoxShape.circle,
            border: Border.all(
              color: type == 'ms-done' ? AppColors.teal
                  : type == 'ms-cur' ? AppColors.primary
                  : type == 'ms-surv' ? AppColors.gold.withOpacity(0.22)
                  : AppColors.border,
              width: 1.5),
            boxShadow: type == 'ms-cur' ? [BoxShadow(
              color: AppColors.primary.withOpacity(0.25), blurRadius: 7)] : null),
          child: dotIcon != null ? Center(child: dotIcon) : null),
        if (!last) Container(width: 1.5, height: 50, color: lineColor),
      ]),
      const SizedBox(width: 10),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: nameStyle),
          const SizedBox(height: 2),
          Text(desc, style: AppText.bodySecondary.copyWith(
            color: type == 'ms-fut' || type == 'ms-surv'
                ? AppColors.text3 : AppColors.text2,
            fontSize: 12, height: 1.5)),
          if (date != null) Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(date, style: AppText.caption.copyWith(fontSize: 10))),
          if (badge != null) Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.fullBR,
              border: Border.all(color: AppColors.primaryMid, width: 0.5)),
            child: Text(badge, style: AppText.caption.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w500,
              fontSize: 10))),
        ]),
      )),
    ]);
  }

  Widget _buildMonitoringJourney(UserSession session) {
    final days = session.daysCancerFree;
    final milestones = [
      (0, 'Treatment completed 🎗️', 'The hardest chapter is behind you.', true),
      (30, '1 month cancer-free', 'Your body begins to recover.', days >= 30),
      (90, '3 months cancer-free', 'Energy and strength returning.', days >= 90),
      (180, '6 months cancer-free', 'First surveillance scan done.', days >= 180),
      (365, '1 year cancer-free 🌟', 'A major milestone.', days >= 365),
      (730, '2 years cancer-free', 'Risk continues to drop.', days >= 730),
      (1825, '5 years cancer-free 🏆', 'Considered cured for many cancers.', days >= 1825),
      (3650, '10 years cancer-free 🥇', 'The ultimate milestone.', days >= 3650),
    ];

    final currentIdx = milestones.lastIndexWhere((m) => days >= m.$1);
    final nextIdx = currentIdx + 1 < milestones.length ? currentIdx + 1 : -1;

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HeroCard(
          gradientColors: const [
            Color(0xFFC8E8D8), Color(0xFFCCC0EC), Color(0xFFC8E8D8)],
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            HeroPill('🎗️ Monitoring & surveillance'),
            Row(children: [
              Text('$days', style: AppText.statNumber.copyWith(fontSize: 36)),
              const SizedBox(width: 8),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('days', style: TextStyle(fontFamily: 'Inter',
                  fontSize: 14, color: AppColors.text2)),
                Text('cancer-free', style: TextStyle(fontFamily: 'Inter',
                  fontSize: 14, color: AppColors.text2)),
              ]),
            ]),
            if (session.treatmentEndDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Since ${DateFormat('d MMMM yyyy').format(session.treatmentEndDate!)}',
                style: AppText.bodySecondary.copyWith(fontSize: 12)),
            ],
            if (nextIdx >= 0) ...[
              const SizedBox(height: 10),
              Text(
                'Next: ${milestones[nextIdx].$2} in ${milestones[nextIdx].$1 - days} days',
                style: AppText.bodySecondary.copyWith(
                  color: AppColors.teal, fontWeight: FontWeight.w500, fontSize: 12)),
            ],
          ]),
        ),
        if (session.menstrualStatus == 'regular' &&
            session.nextOptimalWindowStart != null)
          _buildScanWindowCard(session),
        const SectionLabel('Your survivorship milestones'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: milestones.asMap().entries.map((e) {
            final i = e.key;
            final m = e.value;
            final isDone = m.$4;
            final isCurrent = i == currentIdx;
            final isNext = i == nextIdx;
            return _milestoneRow(
              isDone ? 'ms-done' : isCurrent ? 'ms-cur' : 'ms-fut',
              m.$2, m.$3, null,
              badge: isCurrent ? '← You are here' : isNext ? 'Next milestone' : null,
              last: i == milestones.length - 1);
          }).toList()),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildScanWindowCard(UserSession session) {
    final start = session.nextOptimalWindowStart!;
    final end = session.nextOptimalWindowEnd!;
    final isNow = start.isBefore(DateTime.now()) && end.isAfter(DateTime.now());
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isNow
            ? AppColors.teal.withOpacity(0.07)
            : AppColors.primary.withOpacity(0.05),
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: isNow ? AppColors.teal.withOpacity(0.25) : AppColors.primaryMid,
          width: 0.5)),
      child: Row(children: [
        Text(isNow ? '✅' : '📅', style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isNow ? 'Optimal scan window — NOW' : 'Next optimal scan window',
            style: AppText.bodySemibold.copyWith(
              color: isNow ? AppColors.teal : AppColors.primary, fontSize: 13)),
          Text(
            '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM').format(end)} · Days 7–14',
            style: AppText.bodySecondary.copyWith(fontSize: 12)),
          Text('Best time for MRI and Mammogram',
            style: AppText.caption.copyWith(color: AppColors.text3, fontSize: 10)),
        ])),
      ]),
    );
  }
}
