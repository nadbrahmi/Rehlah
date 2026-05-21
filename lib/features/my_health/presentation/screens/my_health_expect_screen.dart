import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

class MyHealthExpectScreen extends StatelessWidget {
  const MyHealthExpectScreen({super.key});

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
        const Expanded(child: Center(child: Text('What to expect',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
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
    final phase    = session.currentPhase;
    final isNadir  = session.isNadirWindow;
    final maxDay   = session.protocol == BreastProtocol.cmf ? 28 : 21;

    // Build symptom list with severity levels
    final symptoms = _buildSymptomRows(phase, isNadir);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      _dayStripHeader(session),
      _dayStrip(session, maxDay),
      const SizedBox(height: 8),
      _plumHero(session, phase, isNadir),
      _sectionHead('Likely this cycle'),
      const SizedBox(height: 8),
      ...symptoms.map((s) => _seRow(s)),
      const SizedBox(height: 8),
      _askRehlahCard(),
      const SizedBox(height: 24),
    ]);
  }

  // ── Day strip ───────────────────────────────────────────────────────────────

  Widget _dayStripHeader(UserSession session) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(children: [
        Text(
          'Cycle ${session.currentCycle} · these days'.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5, letterSpacing: 1.4,
            fontWeight: FontWeight.w500, color: RColors.sand500)),
        const Spacer(),
        const Text('View cycle',
          style: TextStyle(fontSize: 12, color: RColors.teal700,
              fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _dayStrip(UserSession session, int maxDay) {
    final today    = session.dayInCycle;
    final start    = session.cycleStartDate;

    // Show 7 days centred on today
    final days = List.generate(7, (i) => today - 3 + i)
        .where((d) => d >= 1 && d <= maxDay)
        .toList();

    String _weekLetter(int cycleDay) {
      if (start == null) return 'D';
      final date = start.add(Duration(days: cycleDay - 1));
      const letters = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
      return letters[date.weekday - 1].substring(0, 1);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: days.map((d) {
        final isToday = d == today;
        final isNadir = ProtocolResolver.resolve(
          session.protocol, d, isTaxolPhase: session.isTaxolPhase).isNadir;

        Color bg = Colors.transparent;
        Color dayColor  = RColors.sand700;
        Color numColor  = RColors.sand900;
        FontWeight numW = FontWeight.w400;

        if (isToday) {
          bg = RColors.teal700;
          dayColor  = Colors.white.withValues(alpha: 0.8);
          numColor  = Colors.white;
          numW      = FontWeight.w700;
        } else if (isNadir) {
          bg = RColors.clay100;
          dayColor  = RColors.clay700;
          numColor  = RColors.clay700;
          numW      = FontWeight.w500;
        }

        return Container(
          width: 44, height: 64,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: RRadius.smBR,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_weekLetter(d),
                style: TextStyle(fontSize: 11, color: dayColor,
                    fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('$d',
                style: TextStyle(fontSize: 15, color: numColor,
                    fontWeight: numW)),
            ],
          ),
        );
      }).toList()),
    );
  }

  // ── Plum hero ────────────────────────────────────────────────────────────────

  Widget _plumHero(UserSession session, ChemoPhase phase, bool isNadir) {
    final title = isNadir
        ? 'Expect more fatigue — and rest is key'
        : 'You are in the ${phase.name.toLowerCase()} phase';
    final body  = phase.phaseNote;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RColors.plum700, RColors.plum500],
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
          Text('These days',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          Text(title,
            style: const TextStyle(
              fontSize: 19, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.2, height: 1.25)),
          const SizedBox(height: 8),
          Text(body,
            style: TextStyle(
              fontSize: 12.5, color: Colors.white.withValues(alpha: 0.78),
              height: 1.5)),
        ]),
      ]),
    );
  }

  // ── Section head ─────────────────────────────────────────────────────────────

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, letterSpacing: 1.4,
          fontWeight: FontWeight.w500, color: RColors.sand500)),
    );
  }

  // ── Side effect rows ─────────────────────────────────────────────────────────

  List<_SeItem> _buildSymptomRows(ChemoPhase phase, bool isNadir) {
    final levels = ['high', 'med', 'med', 'low', 'low'];
    final symptoms = phase.primarySymptoms.take(5).toList();
    return symptoms.asMap().entries.map((e) {
      final level = e.key < levels.length ? levels[e.key] : 'low';
      final sym   = e.value;
      return _SeItem(
        name:  sym.label,
        level: level,
        when:  sym.tip?.split('.').first ?? 'This cycle',
      );
    }).toList();
  }

  Widget _seRow(_SeItem item) {
    final barFill = item.level == 'high' ? 0.82
        : item.level == 'med' ? 0.54 : 0.22;
    final Color barColor = item.level == 'high' ? RColors.clay500
        : item.level == 'med' ? RColors.saffron500 : RColors.sand400;

    final pillLabel = item.level == 'high' ? 'Likely'
        : item.level == 'med' ? 'Possible' : 'Less likely';
    final Color pillBg = item.level == 'high' ? RColors.clay100
        : item.level == 'med' ? RColors.saffron100 : RColors.sand100;
    final Color pillFg = item.level == 'high' ? RColors.clay700
        : item.level == 'med' ? RColors.saffron700 : RColors.sand700;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: RColors.sand950)),
            const SizedBox(height: 6),
            LayoutBuilder(builder: (_, constraints) {
              return Stack(children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: RColors.sand200,
                    borderRadius: RRadius.pillBR),
                ),
                Container(
                  height: 6,
                  width: constraints.maxWidth * barFill,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: RRadius.pillBR),
                ),
              ]);
            }),
            const SizedBox(height: 4),
            Text(item.when,
              style: const TextStyle(fontSize: 10, color: RColors.sand500),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          height: 22,
          decoration: BoxDecoration(color: pillBg, borderRadius: RRadius.pillBR),
          child: Text(pillLabel,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500,
                color: pillFg, height: 1)),
        ),
      ]),
    );
  }

  // ── Ask Rehlah card ──────────────────────────────────────────────────────────

  Widget _askRehlahCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: RColors.sand100,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
            color: RColors.plum500, shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ask Rehlah',
            style: TextStyle(fontSize: 10.5, letterSpacing: 1.2,
                fontWeight: FontWeight.w500, color: RColors.plum700)),
          const SizedBox(height: 2),
          const Text('When should I call my team?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: RColors.sand900)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: RColors.sand400, size: 22),
      ]),
    );
  }

  // ── Monitoring content ──────────────────────────────────────────────────────

  Widget _monitoringContent(UserSession session) {
    final symptoms = MonitoringSymptomLibrary.allSymptoms;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 4),
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
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
          Text(session.cancerType,
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Long-term follow-up · What to expect',
            style: TextStyle(
              fontSize: 12.5, color: Colors.white.withValues(alpha: 0.78))),
        ]),
      ),
      _sectionHead('What to expect post-treatment'),
      const SizedBox(height: 8),
      ...symptoms.take(5).map((s) => _monitoringCard(s.emoji, s.label,
          s.tip ?? 'Common after treatment. Track and discuss with your team.')),
      const SizedBox(height: 8),
      _askRehlahCard(),
      const SizedBox(height: 24),
    ]);
  }

  Widget _monitoringCard(String emoji, String title, String body) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: RColors.sand950)),
          const SizedBox(height: 3),
          Text(body,
            style: const TextStyle(fontSize: 11, color: RColors.sand700, height: 1.4)),
        ])),
      ]),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _SeItem {
  final String name;
  final String level; // 'high' | 'med' | 'low'
  final String when;

  const _SeItem({required this.name, required this.level, required this.when});
}
