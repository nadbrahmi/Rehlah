import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../theme/rehlah_theme.dart';
import '../../../../../core/utils/user_session.dart';
import '../../../../../core/utils/protocols.dart';

class ChemoCycleTrackerScreen extends StatefulWidget {
  const ChemoCycleTrackerScreen({super.key});
  @override
  State<ChemoCycleTrackerScreen> createState() =>
      _ChemoCycleTrackerScreenState();
}

class _ChemoCycleTrackerScreenState extends State<ChemoCycleTrackerScreen> {
  final _session = UserSession();
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  // ── Derived values ────────────────────────────────────────────────────────

  int get _protocolCycleLength {
    switch (_session.protocol) {
      case BreastProtocol.cmf: return 28;
      default: return 21;
    }
  }

  DateTime get _cycleStart {
    if (_session.cycleStartDate != null) return _session.cycleStartDate!;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: _session.dayInCycle - 1));
  }

  DateTime get _nextCycleStart =>
      _cycleStart.add(Duration(days: _protocolCycleLength));

  int get _daysUntilNext =>
      _nextCycleStart.difference(DateTime.now()).inDays.clamp(0, 999);

  bool _isCycleDay(DateTime date) {
    final s = _cycleStart;
    final d = DateTime(date.year, date.month, date.day)
        .difference(DateTime(s.year, s.month, s.day))
        .inDays + 1;
    return d >= 1 && d <= _protocolCycleLength;
  }

  bool _isNadirDay(DateTime date) {
    final s = _cycleStart;
    final d = DateTime(date.year, date.month, date.day)
        .difference(DateTime(s.year, s.month, s.day))
        .inDays + 1;
    if (d < 1 || d > _protocolCycleLength) return false;
    return ProtocolResolver.isNadirDay(_session.protocol, d,
        isTaxolPhase: _session.isTaxolPhase);
  }

  bool _hasAppointment(DateTime date) {
    return _session.upcomingAppointments.any((a) =>
        a.dateTime.year == date.year &&
        a.dateTime.month == date.month &&
        a.dateTime.day == date.day);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              _phaseBanner(),
              const SizedBox(height: 12),
              _calendarCard(),
              const SizedBox(height: 12),
              _nextCycleRow(),
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Topbar ────────────────────────────────────────────────────────────────

  Widget _topbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        _iconBtn(Icons.chevron_left_rounded,
            onTap: () => context.canPop() ? context.pop() : context.go('/')),
        const Expanded(child: Center(child: Text('Cycle tracker',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        _iconBtn(Icons.more_horiz_rounded, onTap: () {}),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: RColors.surface, shape: BoxShape.circle,
            border: Border.all(color: RColors.sand200),
          ),
          child: Icon(icon, color: RColors.sand700, size: 20),
        ),
      );

  // ── Phase banner ──────────────────────────────────────────────────────────

  Widget _phaseBanner() {
    final phase    = _session.currentPhase;
    final isNadir  = _session.isNadirWindow;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RColors.saffron100, RColors.sand100],
          begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.saffron300, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isNadir ? RColors.clay500 : RColors.teal700,
            shape: BoxShape.circle),
          child: Center(child: Text(
            '${_session.currentCycle}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: Colors.white))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CYCLE ${_session.currentCycle} · DAY ${_session.dayInCycle}',
              style: const TextStyle(fontSize: 10.5, letterSpacing: 1.2,
                  fontWeight: FontWeight.w500, color: RColors.saffron700)),
            const SizedBox(height: 2),
            Text(phase.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: RColors.sand950)),
            const SizedBox(height: 1),
            Text('$_daysUntilNext days until next cycle',
              style: const TextStyle(fontSize: 11, color: RColors.sand700)),
          ])),
      ]),
    );
  }

  // ── Calendar ──────────────────────────────────────────────────────────────

  Widget _calendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(children: [
        Row(children: [
          _calNavBtn(Icons.chevron_left_rounded,
              () => setState(() => _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month - 1))),
          Expanded(child: Center(child: Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                letterSpacing: -0.2)))),
          _calNavBtn(Icons.chevron_right_rounded,
              () => setState(() => _focusedMonth =
                  DateTime(_focusedMonth.year, _focusedMonth.month + 1))),
        ]),
        const SizedBox(height: 12),
        Row(children: ['Mo','Tu','We','Th','Fr','Sa','Su'].map((d) =>
          Expanded(child: Center(child: Text(d,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                color: RColors.sand400))))).toList()),
        const SizedBox(height: 6),
        _calGrid(_focusedMonth),
        const SizedBox(height: 12),
        Container(height: 0.5, color: RColors.sand200),
        const SizedBox(height: 10),
        Wrap(spacing: 14, runSpacing: 6, children: [
          _legendSwatch(RColors.teal700,    'Today'),
          _legendSwatch(RColors.saffron100, 'Cycle days'),
          _legendSwatch(RColors.clay100,    'Nadir'),
          _legendDot(   RColors.sky500,     'Appointment'),
        ]),
      ]),
    );
  }

  Widget _calNavBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: const BoxDecoration(
          color: RColors.sand100, borderRadius: RRadius.smBR),
      child: Icon(icon, size: 14, color: RColors.sand700)),
  );

  Widget _calGrid(DateTime month) {
    final firstDay    = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset      = (firstDay.weekday - 1) % 7;
    final now         = DateTime.now();

    final cells = <Widget>[
      for (int i = 0; i < offset; i++) const SizedBox.shrink(),
      for (int d = 1; d <= daysInMonth; d++)
        _dayCell(DateTime(month.year, month.month, d), now),
    ];

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }

  Widget _dayCell(DateTime date, DateTime now) {
    final isToday  = date.year == now.year &&
        date.month == now.month && date.day == now.day;
    final isNadir  = !isToday && _isNadirDay(date);
    final isCycle  = !isToday && !isNadir && _isCycleDay(date);
    final hasAppt  = _hasAppointment(date);

    Color bg        = Colors.transparent;
    Color textColor = RColors.sand700;
    bool  bold      = false;

    if (isToday) {
      bg = RColors.teal700; textColor = Colors.white; bold = true;
    } else if (isNadir) {
      bg = RColors.clay100; textColor = RColors.clay700;
    } else if (isCycle) {
      bg = RColors.saffron100; textColor = RColors.saffron700;
    }

    return Container(
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: Stack(alignment: Alignment.center, children: [
        Center(child: Text('${date.day}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: textColor,
            fontFeatures: const [FontFeature.tabularFigures()]))),
        if (hasAppt)
          Positioned(
            bottom: 3,
            child: Container(
              width: 4, height: 4,
              decoration: const BoxDecoration(
                  color: RColors.sky500, shape: BoxShape.circle))),
      ]),
    );
  }

  Widget _legendSwatch(Color bg, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: RColors.sand700)),
    ]);
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 11, color: RColors.sand700)),
    ]);
  }

  // ── Next cycle row ────────────────────────────────────────────────────────

  Widget _nextCycleRow() {
    final nextStart = _nextCycleStart;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: RColors.surface, borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
              color: RColors.saffron100, borderRadius: RRadius.smBR),
          child: const Icon(Icons.circle_outlined,
              color: RColors.saffron700, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cycle ${_session.currentCycle + 1} begins',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: RColors.sand950)),
          Text(
            '${DateFormat('d MMM').format(nextStart)} · in $_daysUntilNext days',
            style: const TextStyle(fontSize: 11, color: RColors.sand500)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          height: 22,
          decoration: const BoxDecoration(
              color: RColors.sky100, borderRadius: RRadius.pillBR),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 5, height: 5,
              decoration: const BoxDecoration(
                  color: RColors.sky500, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('Scheduled',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500,
                  color: RColors.sand700, height: 1)),
          ]),
        ),
      ]),
    );
  }
}
