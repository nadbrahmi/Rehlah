import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';

class MyHealthJourneyScreen extends StatelessWidget {
  const MyHealthJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(context),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: session.isMonitoring
                ? _monitoringContent(session)
                : _treatmentContent(session),
          )),
        ]),
      ),
    );
  }

  // ── Topbar ──────────────────────────────────────────────────────────────────

  Widget _topbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        _iconBtn(Icons.chevron_left_rounded,
            onTap: () => context.canPop() ? context.pop() : context.go('/')),
        const Expanded(child: Center(child: Text('Your journey',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2)))),
        _iconBtn(Icons.more_horiz_rounded, onTap: () {}),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: RColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: RColors.sand200),
        ),
        child: Icon(icon, color: RColors.sand700, size: 20),
      ),
    );
  }

  // ── Treatment content ───────────────────────────────────────────────────────

  Widget _treatmentContent(UserSession session) {
    final currentCycle = session.currentCycle;
    final totalCycles = session.totalCycles;
    final remaining = totalCycles - currentCycle;
    final treatmentName = _treatmentDisplay(session.treatmentPhase);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 4),
      _hero(treatmentName, currentCycle, totalCycles, remaining),
      _sectionHead('Treatment path'),
      _timeline(session),
      const SizedBox(height: 24),
    ]);
  }

  String _treatmentDisplay(String phase) {
    if (phase.startsWith('In ')) {
      final t = phase.substring(3);
      return t[0].toUpperCase() + t.substring(1);
    }
    return phase;
  }

  Widget _hero(String name, int current, int total, int remaining) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RColors.teal700, RColors.teal600],
        ),
        borderRadius: RRadius.xlBR,
      ),
      child: Stack(children: [
        Positioned(
          top: -70, right: -70,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('You are in',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          Text('$name · Cycle $current of $total',
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.2, height: 1.2)),
          const SizedBox(height: 10),
          Row(children: [
            ...List.generate(total > 8 ? 8 : total, (i) {
              final n = i + 1;
              final isDone = n < current;
              final isCur  = n == current;
              final bg = isDone ? RColors.sage500
                  : isCur ? RColors.saffron500
                  : Colors.white.withValues(alpha: 0.18);
              final fg = isDone ? Colors.white
                  : isCur ? RColors.sand950
                  : Colors.white.withValues(alpha: 0.7);
              return Container(
                margin: const EdgeInsets.only(right: 6),
                width: 24, height: 24,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Center(child: Text('$n',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg))),
              );
            }),
            if (remaining > 0) ...[
              const SizedBox(width: 4),
              Text('$remaining to go',
                style: TextStyle(fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7))),
            ],
          ]),
        ]),
      ]),
    );
  }

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, letterSpacing: 1.4,
          fontWeight: FontWeight.w500, color: RColors.sand500)),
    );
  }

  // ── Journey timeline ────────────────────────────────────────────────────────

  Widget _timeline(UserSession session) {
    final isNadir = session.isNadirWindow;
    final items = [
      _JItem(state: 'done', eyebrow: 'Complete · 12 Mar',
        title: 'Diagnosis & staging',
        subtitle: 'Diagnosis confirmed, staging scans reviewed'),
      _JItem(state: 'done', eyebrow: 'Complete · 28 Mar',
        title: 'Surgery',
        subtitle: 'Smooth recovery over 14 days'),
      _JItem(
        state: 'current',
        eyebrow: 'You are here · Cycle ${session.currentCycle}',
        title: '${session.protocol.name} · ${session.totalCycles} cycles',
        subtitle: 'Started 12 Apr · expected end 20 Aug',
        pills: [
          (label: isNadir ? 'Nadir soon' : 'Labs in range',
           style: isNadir ? 'warn' : 'pos'),
          (label: 'Active treatment', style: 'info'),
        ],
      ),
      _JItem(state: 'upcoming', eyebrow: 'Upcoming · September',
        title: 'Radiation therapy',
        subtitle: '20 sessions over 4 weeks'),
      _JItem(state: 'upcoming', eyebrow: 'Upcoming · 2027',
        title: 'Long-term follow-up',
        subtitle: 'Every 3 months for the first year'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: items.asMap().entries
            .map((e) => _timelineRow(e.value, isLast: e.key == items.length - 1))
            .toList(),
      ),
    );
  }

  Widget _timelineRow(_JItem item, {required bool isLast}) {
    final isDone = item.state == 'done';
    final isCurrent = item.state == 'current';

    final dotSize = isCurrent ? 18.0 : 14.0;
    final dotColor = isDone ? RColors.sage500
        : isCurrent ? RColors.saffron500
        : RColors.sand200;
    final dotShadow = isDone
        ? [const BoxShadow(color: RColors.sage300, blurRadius: 0, spreadRadius: 1)]
        : isCurrent
            ? [
                const BoxShadow(color: RColors.saffron300, blurRadius: 0, spreadRadius: 1),
                BoxShadow(color: RColors.saffron500.withValues(alpha: 0.18),
                    blurRadius: 0, spreadRadius: 6),
              ]
            : [const BoxShadow(color: RColors.sand300, blurRadius: 0, spreadRadius: 1)];

    final dot = Container(
      width: dotSize, height: dotSize,
      decoration: BoxDecoration(
        color: dotColor, shape: BoxShape.circle,
        border: Border.all(color: RColors.sand50, width: 2),
        boxShadow: dotShadow,
      ),
    );

    final cardBg     = isCurrent ? RColors.saffron100 : RColors.surface;
    final cardBorder = isCurrent ? RColors.saffron300  : RColors.sand200;
    final eyeColor   = isCurrent ? RColors.saffron700  : RColors.sand500;

    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Dot + vertical line
        SizedBox(
          width: 36,
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            const SizedBox(height: 14),
            Center(child: dot),
            if (!isLast)
              Expanded(child: Center(
                child: Container(width: 2, color: RColors.sand200),
              ))
            else
              const SizedBox(height: 14),
          ]),
        ),
        // Card
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: RRadius.mdBR,
                border: Border.all(color: cardBorder),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.eyebrow.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10, letterSpacing: 1.2,
                    fontWeight: FontWeight.w500, color: eyeColor)),
                const SizedBox(height: 2),
                Text(item.title,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: RColors.sand950)),
                const SizedBox(height: 2),
                Text(item.subtitle,
                  style: const TextStyle(
                    fontSize: 11, color: RColors.sand700, height: 1.4)),
                if (item.pills != null && item.pills!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(children: item.pills!.map((p) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _pill(p.label, p.style),
                  )).toList()),
                ],
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _pill(String label, String style) {
    final Color bg, fg;
    switch (style) {
      case 'warn':  bg = RColors.saffron100; fg = RColors.saffron700;
      case 'pos':   bg = RColors.sage100;    fg = RColors.sage700;
      case 'alert': bg = RColors.clay100;    fg = RColors.clay700;
      case 'info':  bg = RColors.teal100;    fg = RColors.teal700;
      default:      bg = RColors.sand100;    fg = RColors.sand700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      height: 22,
      decoration: BoxDecoration(color: bg, borderRadius: RRadius.pillBR),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fg)),
        const SizedBox(width: 5),
        Text(label,
          style: TextStyle(
            fontSize: 10.5, fontWeight: FontWeight.w500, color: fg, height: 1)),
      ]),
    );
  }

  // ── Monitoring content ──────────────────────────────────────────────────────

  Widget _monitoringContent(UserSession session) {
    final days = session.daysCancerFree;
    final milestones = [
      (0, 'Treatment completed 🎗️', 'The hardest chapter is behind you.', true),
      (30, '1 month cancer-free', 'Your body begins to recover.', days >= 30),
      (90, '3 months cancer-free', 'Energy and strength returning.', days >= 90),
      (180, '6 months cancer-free', 'First surveillance scan done.', days >= 180),
      (365, '1 year cancer-free 🌟', 'A major milestone.', days >= 365),
      (730, '2 years cancer-free', 'Risk continues to drop.', days >= 730),
      (1825, '5 years cancer-free 🏆', 'Considered cured for many cancers.', days >= 1825),
    ];
    final currentIdx = milestones.lastIndexWhere((m) => days >= m.$1);
    final nextIdx = currentIdx + 1 < milestones.length ? currentIdx + 1 : -1;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 4),
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [RColors.sage700, RColors.sage500],
          ),
          borderRadius: RRadius.xlBR,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Monitoring & surveillance',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4, fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          Text('$days days cancer-free',
            style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.3)),
          if (nextIdx >= 0) ...[
            const SizedBox(height: 6),
            Text('Next: ${milestones[nextIdx].$2} in ${milestones[nextIdx].$1 - days} days',
              style: TextStyle(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.78))),
          ],
        ]),
      ),
      _sectionHead('Your survivorship milestones'),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(children: milestones.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final isDone = m.$4;
          final isCur  = i == currentIdx;
          return _timelineRow(
            _JItem(
              state: isDone ? 'done' : isCur ? 'current' : 'upcoming',
              eyebrow: isDone ? 'Complete' : isCur ? 'You are here' : 'Upcoming',
              title: m.$2,
              subtitle: m.$3,
            ),
            isLast: i == milestones.length - 1,
          );
        }).toList()),
      ),
      const SizedBox(height: 24),
    ]);
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _JItem {
  final String state; // 'done' | 'current' | 'upcoming'
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<({String label, String style})>? pills;

  const _JItem({
    required this.state,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.pills,
  });
}
