import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';

class PeriodEntry {
  final String id;
  DateTime startDate;
  DateTime endDate;
  int flowLevel; // 1=light, 2=moderate, 3=heavy
  List<String> symptoms;
  String notes;

  PeriodEntry({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.flowLevel = 2,
    this.symptoms = const [],
    this.notes = '',
  });

  int get duration => endDate.difference(startDate).inDays + 1;
}

class CycleTrackerScreen extends StatefulWidget {
  const CycleTrackerScreen({super.key});
  @override
  State<CycleTrackerScreen> createState() => _CycleTrackerScreenState();
}

class _CycleTrackerScreenState extends State<CycleTrackerScreen> {
  final _session = UserSession();
  final List<PeriodEntry> _periods = [];
  DateTime _focusedMonth = DateTime.now();
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (_session.lastPeriodDate != null) {
      final start = _session.lastPeriodDate!;
      _periods.add(PeriodEntry(
        id: 'p1',
        startDate: start,
        endDate: start.add(Duration(days: _session.cycleLength ~/ 7)),
        flowLevel: 2,
      ));
      final prev = start.subtract(Duration(days: _session.cycleLength));
      _periods.add(PeriodEntry(
        id: 'p0',
        startDate: prev,
        endDate: prev.add(Duration(days: _session.cycleLength ~/ 7)),
        flowLevel: 2,
      ));
    }
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  // ── Cycle calculations ────────────────────────────────────────────────────

  DateTime? get _lastPeriodStart {
    if (_periods.isEmpty && _session.lastPeriodDate == null) return null;
    if (_periods.isNotEmpty) {
      return ([..._periods]..sort((a, b) => b.startDate.compareTo(a.startDate)))
          .first.startDate;
    }
    return _session.lastPeriodDate;
  }

  DateTime? _nextPeriodDate() {
    final last = _lastPeriodStart;
    if (last == null) return null;
    DateTime next = last.add(Duration(days: _session.cycleLength));
    while (next.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      next = next.add(Duration(days: _session.cycleLength));
    }
    return next;
  }

  bool _isPeriodDay(DateTime date) {
    for (final p in _periods) {
      if (!date.isBefore(DateTime(p.startDate.year, p.startDate.month, p.startDate.day)) &&
          !date.isAfter(DateTime(p.endDate.year, p.endDate.month, p.endDate.day))) {
        return true;
      }
    }
    return false;
  }

  bool _isPredictedPeriod(DateTime date) {
    final last = _lastPeriodStart;
    if (last == null) return false;
    DateTime next = last.add(Duration(days: _session.cycleLength));
    final avgDuration = _periods.isNotEmpty
        ? (_periods.map((p) => p.duration).reduce((a, b) => a + b) / _periods.length).round()
        : 5;
    for (int i = 0; i < 12; i++) {
      if (!_isPeriodDay(date)) {
        final nextEnd = next.add(Duration(days: avgDuration - 1));
        if (!date.isBefore(DateTime(next.year, next.month, next.day)) &&
            !date.isAfter(DateTime(nextEnd.year, nextEnd.month, nextEnd.day))) {
          return true;
        }
      }
      next = next.add(Duration(days: _session.cycleLength));
    }
    return false;
  }

  bool _isFertileDay(DateTime date) {
    final next = _nextPeriodDate();
    if (next == null) return false;
    final ovulation = next.subtract(const Duration(days: 14));
    final fertileStart = ovulation.subtract(const Duration(days: 5));
    return !date.isBefore(DateTime(fertileStart.year, fertileStart.month, fertileStart.day)) &&
        date.isBefore(DateTime(ovulation.year, ovulation.month, ovulation.day));
  }

  bool _isOvulationDay(DateTime date) {
    final next = _nextPeriodDate();
    if (next == null) return false;
    final ovulation = next.subtract(const Duration(days: 14));
    return date.year == ovulation.year &&
        date.month == ovulation.month && date.day == ovulation.day;
  }

  List<(DateTime, DateTime)> _optimalWindowsInMonth(DateTime month) {
    if (_session.menstrualStatus != 'regular') return [];
    final last = _lastPeriodStart;
    if (last == null) return [];
    final windows = <(DateTime, DateTime)>[];
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final planningMin = DateTime.now().add(const Duration(days: 14));
    DateTime cycleStart = last;
    while (cycleStart.isAfter(monthStart.subtract(Duration(days: _session.cycleLength + 14)))) {
      cycleStart = cycleStart.subtract(Duration(days: _session.cycleLength));
    }
    for (int i = 0; i < 12; i++) {
      final ws = cycleStart.add(const Duration(days: 6));
      final we = cycleStart.add(const Duration(days: 13));
      if (!we.isBefore(monthStart) && !ws.isAfter(monthEnd) && !we.isBefore(planningMin)) {
        final cs = ws.isBefore(monthStart) ? monthStart : ws;
        final ce = we.isAfter(monthEnd) ? monthEnd : we;
        windows.add((cs, ce));
      }
      cycleStart = cycleStart.add(Duration(days: _session.cycleLength));
      if (cycleStart.isAfter(monthEnd.add(const Duration(days: 14)))) break;
    }
    return windows;
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
          _tabs(),
          Expanded(child: _tabIndex == 0
              ? _periodTracker()
              : _scanCalendar()),
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
        _iconBtn(Icons.tune_rounded, onTap: _showSettingsSheet),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
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
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Container(
        height: 36, padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: RColors.sand100,
          borderRadius: RRadius.pillBR,
          border: Border.all(color: RColors.sand200)),
        child: Row(
          children: ['Period tracker', 'Scan planner'].asMap().entries.map((e) {
            final active = e.key == _tabIndex;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() => _tabIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: active ? RColors.surface : Colors.transparent,
                  borderRadius: RRadius.pillBR,
                  boxShadow: active
                      ? [BoxShadow(color: RColors.teal700.withValues(alpha: 0.08),
                          blurRadius: 4)]
                      : null),
                child: Center(child: Text(e.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: active ? RColors.teal700 : RColors.sand400,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400)))),
            ));
          }).toList(),
        ),
      ),
    );
  }

  // ── Period tracker ────────────────────────────────────────────────────────

  Widget _periodTracker() {
    final nextPeriod = _nextPeriodDate();
    final daysUntil  = nextPeriod?.difference(DateTime.now()).inDays;

    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 10),
          _phaseBanner(daysUntil, nextPeriod),
          const SizedBox(height: 12),
          _calendarCard(),
          const SizedBox(height: 12),
          _statsRow(daysUntil),
          const SizedBox(height: 12),
          if (_periods.isNotEmpty) _periodHistory(),
          const SizedBox(height: 12),
          _nextCycleTileOrEmpty(nextPeriod, daysUntil),
          const SizedBox(height: 20),
        ]),
      )),
      _logButton(),
    ]);
  }

  Widget _phaseBanner(int? daysUntil, DateTime? nextPeriod) {
    final hasData = _lastPeriodStart != null;
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
          width: 36, height: 36,
          decoration: const BoxDecoration(
            color: RColors.saffron500, shape: BoxShape.circle),
          child: Center(child: Text(
            hasData ? '${_session.cycleLength}d' : '?',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: RColors.sand950))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            hasData ? 'Cycle · ${_session.cycleLength} days' : 'Set up your cycle',
            style: const TextStyle(fontSize: 10.5, letterSpacing: 1.2,
                fontWeight: FontWeight.w500, color: RColors.saffron700)),
          const SizedBox(height: 2),
          Text(
            hasData && nextPeriod != null
                ? 'Next period ~${DateFormat('d MMM').format(nextPeriod)}'
                : 'Log your first period to start',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: RColors.sand950)),
          if (daysUntil != null)
            Text('in $daysUntil days',
              style: const TextStyle(fontSize: 11, color: RColors.sand700)),
        ])),
      ]),
    );
  }

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
        // Month nav header
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
        // DOW headers — Monday first
        Row(children: ['Mo','Tu','We','Th','Fr','Sa','Su'].map((d) =>
          Expanded(child: Center(child: Text(d,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                color: RColors.sand400))))).toList()),
        const SizedBox(height: 6),
        // Grid
        _calGrid(_focusedMonth),
        // Legend
        const SizedBox(height: 12),
        Container(height: 0.5, color: RColors.sand200),
        const SizedBox(height: 10),
        Wrap(spacing: 14, runSpacing: 6, children: [
          _legendItem(RColors.teal700,    Colors.white,       'Today'),
          _legendItem(RColors.saffron100, RColors.saffron700, 'Period'),
          _legendItem(RColors.sage100,    RColors.sage500,    'Fertile'),
          _legendItem(RColors.sage500,    Colors.white,       'Ovulation'),
          _legendItem(RColors.clay100,    RColors.clay700,    'Predicted'),
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
    final offset      = (firstDay.weekday - 1) % 7; // Mon=0 … Sun=6
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
    final isToday     = date.year == now.year &&
        date.month == now.month && date.day == now.day;
    final isPeriod    = _isPeriodDay(date);
    final isOvul      = _isOvulationDay(date);
    final isFertile   = !isOvul && _isFertileDay(date);
    final isPredicted = !isPeriod && !isOvul && !isFertile &&
        _isPredictedPeriod(date);

    Color bg        = Colors.transparent;
    Color textColor = RColors.sand700;
    bool  bold      = false;
    Color? dotColor;

    if (isToday) {
      bg = RColors.teal700; textColor = Colors.white; bold = true;
    } else if (isPeriod) {
      bg = RColors.saffron100; textColor = RColors.saffron700; bold = true;
      dotColor = RColors.saffron500;
    } else if (isOvul) {
      bg = RColors.sage500; textColor = Colors.white; bold = true;
      dotColor = Colors.white;
    } else if (isFertile) {
      bg = RColors.sage100; textColor = RColors.sage700;
      dotColor = RColors.sage500;
    } else if (isPredicted) {
      bg = RColors.clay100; textColor = RColors.clay700;
    }

    return GestureDetector(
      onTap: () => _showDayInfo(date, isPeriod, isFertile, isOvul, isPredicted),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(alignment: Alignment.center, children: [
          Center(child: Text('${date.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()]))),
          if (dotColor != null)
            Positioned(
              bottom: 3,
              child: Container(
                width: 4, height: 4,
                decoration: BoxDecoration(
                  color: dotColor, shape: BoxShape.circle))),
        ]),
      ),
    );
  }

  Widget _legendItem(Color bg, Color dotColor, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(3),
          border: bg == Colors.transparent
              ? Border.all(color: RColors.sand200) : null),
      ),
      const SizedBox(width: 5),
      Text(label,
          style: const TextStyle(fontSize: 11, color: RColors.sand700)),
    ]);
  }

  Widget _statsRow(int? daysUntil) {
    final avgDays = _periods.isNotEmpty
        ? (_periods.map((p) => p.duration).reduce((a, b) => a + b) / _periods.length).round()
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _statChip(
          daysUntil != null ? '$daysUntil' : '—',
          'days to next', RColors.clay500),
        const SizedBox(width: 8),
        _statChip('${_session.cycleLength}', 'cycle length', RColors.teal700),
        const SizedBox(width: 8),
        _statChip(avgDays != null ? '$avgDays' : '—',
            'avg period days', RColors.sage500),
      ]),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: RRadius.mdBR,
        border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(
            fontSize: 9, color: RColors.sand400, height: 1.3),
          textAlign: TextAlign.center),
      ]),
    ));
  }

  Widget _periodHistory() {
    final sorted = [..._periods]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('RECENT PERIODS',
            style: TextStyle(fontSize: 10.5, letterSpacing: 1.4,
                fontWeight: FontWeight.w500, color: RColors.sand500)),
          const Spacer(),
          GestureDetector(
            onTap: _showSettingsSheet,
            child: const Text('Edit settings',
              style: TextStyle(fontSize: 11, color: RColors.teal700,
                  fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 8),
        ...sorted.take(3).map((p) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          decoration: BoxDecoration(
            color: RColors.surface, borderRadius: RRadius.mdBR,
            border: Border.all(color: RColors.sand200)),
          child: Row(children: [
            Container(width: 8, height: 8,
              decoration: BoxDecoration(
                color: RColors.saffron500.withValues(alpha: 0.6),
                shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat('d MMM yyyy').format(p.startDate),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                    color: RColors.sand950)),
              Text('${p.duration} days · ${_flowLabel(p.flowLevel)}',
                style: const TextStyle(fontSize: 11, color: RColors.sand500)),
            ])),
            GestureDetector(
              onTap: () => _showEditPeriodSheet(p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: const BoxDecoration(
                  color: RColors.sand100, borderRadius: RRadius.pillBR),
                child: const Text('Edit',
                  style: TextStyle(fontSize: 10, color: RColors.sand700,
                      fontWeight: FontWeight.w500)))),
          ]),
        )),
      ]),
    );
  }

  Widget _nextCycleTileOrEmpty(DateTime? nextPeriod, int? daysUntil) {
    if (nextPeriod == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RColors.surface, borderRadius: RRadius.mdBR,
            border: Border.all(color: RColors.sand200)),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: const BoxDecoration(
                color: RColors.saffron100, borderRadius: RRadius.smBR),
              child: const Icon(Icons.calendar_today_rounded,
                  color: RColors.saffron700, size: 18)),
            const SizedBox(width: 12),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('No cycle data yet',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                    color: RColors.sand950)),
              Text('Log your first period to get predictions',
                style: TextStyle(fontSize: 11, color: RColors.sand500)),
            ])),
          ]),
        ),
      );
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: RColors.surface, borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.sand200)),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: const BoxDecoration(
              color: RColors.saffron100, borderRadius: RRadius.smBR),
            child: const Icon(Icons.circle_outlined,
                color: RColors.saffron700, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Next period',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: RColors.sand950)),
            Text('${DateFormat('d MMM').format(nextPeriod)} · in $daysUntil days',
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
              const Text('Predicted',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500,
                    color: RColors.sand700, height: 1)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _logButton() {
    return Container(
      decoration: const BoxDecoration(
        color: RColors.surface,
        border: Border(top: BorderSide(color: RColors.sand200, width: 0.5))),
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: GestureDetector(
        onTap: _showLogPeriodSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: RColors.clay500,
            borderRadius: RRadius.pillBR,
            boxShadow: [BoxShadow(
              color: RColors.clay500.withValues(alpha: 0.25),
              blurRadius: 10, offset: const Offset(0, 3))]),
          child: const Center(child: Text('+ Log period',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: Colors.white))),
        ),
      ),
    );
  }

  String _flowLabel(int level) =>
      {1: 'Light', 2: 'Moderate', 3: 'Heavy'}[level] ?? '';

  // ── Scan planner ──────────────────────────────────────────────────────────

  Widget _scanCalendar() {
    final now    = DateTime.now();
    final months = List.generate(6, (i) =>
        DateTime(now.year, now.month + i + 1));

    return Column(children: [
      // Info banner
      Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: RColors.teal50, borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.teal100)),
        child: Row(children: [
          const Text('📅', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(
            _session.menstrualStatus == 'regular'
                ? 'Teal = optimal scan window (Days 7–14). Book MRI or Mammogram 4–6 weeks ahead.'
                : 'No cycle restriction — schedule MRI / Mammogram at any convenient time.',
            style: const TextStyle(fontSize: 11, color: RColors.teal700,
                height: 1.5))),
        ]),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: months.length,
        itemBuilder: (_, i) => _scanMonthCard(months[i]),
      )),
    ]);
  }

  Widget _scanMonthCard(DateTime month) {
    final windows     = _optimalWindowsInMonth(month);
    final firstDay    = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset      = (firstDay.weekday - 1) % 7;
    final hasWindows  = windows.isNotEmpty;
    final noRestriction = _session.menstrualStatus != 'regular';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: RColors.surface, borderRadius: RRadius.mdBR,
        border: Border.all(
          color: hasWindows ? RColors.teal200 : RColors.sand200,
          width: hasWindows ? 1 : 0.5)),
      child: Column(children: [
        // Month header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(children: [
            Text(DateFormat('MMMM yyyy').format(month),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: RColors.sand950)),
            const Spacer(),
            if (hasWindows)
              _scanPill('${windows.length} window${windows.length > 1 ? "s" : ""}',
                  RColors.teal50, RColors.teal700)
            else if (noRestriction)
              _scanPill('Any time', RColors.teal50, RColors.teal700),
          ]),
        ),
        // DOW
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: ['Mo','Tu','We','Th','Fr','Sa','Su'].map((d) =>
            Expanded(child: Center(child: Text(d,
              style: const TextStyle(fontSize: 9, color: RColors.sand400,
                  fontWeight: FontWeight.w500))))).toList()),
        ),
        const SizedBox(height: 4),
        // Grid
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 2,
              crossAxisSpacing: 0, childAspectRatio: 1.1),
            itemCount: offset + daysInMonth,
            itemBuilder: (_, i) {
              if (i < offset) return const SizedBox.shrink();
              final day  = i - offset + 1;
              final date = DateTime(month.year, month.month, day);
              return _scanDayCell(date, windows, noRestriction);
            },
          ),
        ),
        // Window labels
        if (hasWindows)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 0.5, color: RColors.sand200),
                const SizedBox(height: 10),
                ...windows.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Container(width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: RColors.teal200, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('d MMM').format(w.$1)} – ${DateFormat('d MMM').format(w.$2)}',
                      style: const TextStyle(fontSize: 12,
                          fontWeight: FontWeight.w600, color: RColors.teal700)),
                    const SizedBox(width: 6),
                    const Text('· Best time to book',
                      style: TextStyle(fontSize: 10, color: RColors.sand400)),
                  ]),
                )),
              ],
            ),
          ),
      ]),
    );
  }

  Widget _scanDayCell(DateTime date, List<(DateTime, DateTime)> windows,
      bool noRestriction) {
    final isOptimal = windows.any((w) =>
        !date.isBefore(DateTime(w.$1.year, w.$1.month, w.$1.day)) &&
        !date.isAfter(DateTime(w.$2.year, w.$2.month, w.$2.day)));

    BorderRadius radius = BorderRadius.circular(6);
    if (isOptimal) {
      for (final w in windows) {
        final isStart = date.year == w.$1.year &&
            date.month == w.$1.month && date.day == w.$1.day;
        final isEnd   = date.year == w.$2.year &&
            date.month == w.$2.month && date.day == w.$2.day;
        if (isStart && isEnd) {
          radius = BorderRadius.circular(8);
        } else if (isStart) {
          radius = const BorderRadius.horizontal(left: Radius.circular(8));
        } else if (isEnd) {
          radius = const BorderRadius.horizontal(right: Radius.circular(8));
        } else {
          radius = BorderRadius.zero;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: noRestriction
            ? RColors.teal700.withValues(alpha: 0.06)
            : isOptimal
                ? RColors.teal700.withValues(alpha: 0.12)
                : Colors.transparent,
        borderRadius: radius),
      child: Center(child: Text('${date.day}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: isOptimal || noRestriction
              ? FontWeight.w600 : FontWeight.w400,
          color: isOptimal || noRestriction
              ? RColors.teal700 : RColors.sand700,
          fontFeatures: const [FontFeature.tabularFigures()]))),
    );
  }

  Widget _scanPill(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: RRadius.pillBR),
    child: Text(label,
      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: fg)),
  );

  // ── Sheets ────────────────────────────────────────────────────────────────

  void _showSettingsSheet() {
    int cycleLen = _session.cycleLength;
    String status = _session.menstrualStatus;
    final outerSetState = setState;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20,
              MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
              decoration: const BoxDecoration(
                color: RColors.sand200, borderRadius: RRadius.pillBR))),
            const SizedBox(height: 16),
            const Text('CYCLE SETTINGS',
              style: TextStyle(fontSize: 10.5, letterSpacing: 1.4,
                  fontWeight: FontWeight.w500, color: RColors.sand500)),
            const SizedBox(height: 14),
            const Text('Cycle length',
              style: TextStyle(fontSize: 13, color: RColors.sand500)),
            const SizedBox(height: 8),
            Row(children: [
              GestureDetector(
                onTap: () => setS(() => cycleLen = (cycleLen - 1).clamp(21, 45)),
                child: _circleBtn(Icons.remove_rounded)),
              const SizedBox(width: 16),
              Text('$cycleLen days',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: RColors.teal700)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setS(() => cycleLen = (cycleLen + 1).clamp(21, 45)),
                child: _circleBtn(Icons.add_rounded)),
            ]),
            const SizedBox(height: 16),
            const Text('Current menstrual status',
              style: TextStyle(fontSize: 13, color: RColors.sand500)),
            const SizedBox(height: 8),
            ...[
              ('regular',    '🔄', 'Regular cycles'),
              ('irregular',  '〰️', 'Irregular cycles'),
              ('amenorrhea', '⏸️', 'No period yet'),
              ('menopause',  '🍂', 'Menopause'),
            ].map((opt) {
              final sel = status == opt.$1;
              return GestureDetector(
                onTap: () => setS(() => status = opt.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel ? RColors.teal50 : RColors.sand50,
                    borderRadius: RRadius.mdBR,
                    border: Border.all(
                      color: sel ? RColors.teal100 : RColors.sand200,
                      width: 0.5)),
                  child: Row(children: [
                    Text(opt.$2, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Text(opt.$3,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                          color: sel ? RColors.teal700 : RColors.sand900)),
                    if (sel) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded, size: 16,
                          color: RColors.teal700)],
                  ]),
                ),
              );
            }),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                _session.cycleLength = cycleLen;
                _session.menstrualStatus = status;
                Navigator.pop(context);
                outerSetState(() {});
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: RColors.teal700, borderRadius: RRadius.pillBR,
                  boxShadow: [BoxShadow(
                    color: RColors.teal700.withValues(alpha: 0.3),
                    blurRadius: 10, offset: const Offset(0, 3))]),
                child: const Center(child: Text('Save settings',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: Colors.white)))),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: const BoxDecoration(
      color: RColors.teal50, shape: BoxShape.circle),
    child: Icon(icon, size: 18, color: RColors.teal700));

  void _showLogPeriodSheet()                 => _showPeriodSheet(null, setState);
  void _showEditPeriodSheet(PeriodEntry p)   => _showPeriodSheet(p, setState);

  void _showPeriodSheet(PeriodEntry? existing, StateSetter outerSetState) {
    final dates = [
      existing?.startDate ?? DateTime.now(),
      existing?.endDate   ?? DateTime.now().add(const Duration(days: 4)),
    ];
    int flowLevel = existing?.flowLevel ?? 2;
    final symptoms = <String>{...?existing?.symptoms};
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20,
              MediaQuery.of(context).viewInsets.bottom + 32),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
              decoration: const BoxDecoration(
                color: RColors.sand200, borderRadius: RRadius.pillBR))),
            const SizedBox(height: 12),
            Text(isEdit ? 'EDIT PERIOD' : 'LOG PERIOD',
              style: const TextStyle(fontSize: 10.5, letterSpacing: 1.4,
                  fontWeight: FontWeight.w500, color: RColors.sand500)),
            const SizedBox(height: 12),
            _dateRow('Start date', dates[0], () async {
              final p = await _pickDate(dates[0]);
              if (p != null) setS(() => dates[0] = p);
            }),
            const SizedBox(height: 8),
            _dateRow('End date', dates[1], () async {
              final p = await _pickDate(dates[1], allowFuture: true);
              if (p != null) setS(() => dates[1] = p);
            }),
            const SizedBox(height: 12),
            const Text('Flow level',
              style: TextStyle(fontSize: 13, color: RColors.sand500)),
            const SizedBox(height: 6),
            Row(children: [1, 2, 3].map((l) {
              final sel = flowLevel == l;
              final labels = {1: '💧 Light', 2: '💧💧 Moderate', 3: '💧💧💧 Heavy'};
              return Expanded(child: GestureDetector(
                onTap: () => setS(() => flowLevel = l),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: EdgeInsets.only(right: l < 3 ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? RColors.clay500.withValues(alpha: 0.10)
                        : RColors.sand50,
                    borderRadius: RRadius.mdBR,
                    border: Border.all(
                      color: sel
                          ? RColors.clay500.withValues(alpha: 0.3)
                          : RColors.sand200,
                      width: 0.5)),
                  child: Center(child: Text(labels[l]!,
                    style: TextStyle(
                      fontSize: 10,
                      color: sel ? RColors.clay500 : RColors.sand700,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400))))));
            }).toList()),
            const SizedBox(height: 12),
            const Text('Symptoms',
              style: TextStyle(fontSize: 13, color: RColors.sand500)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6,
              children: ['Cramps', 'Bloating', 'Headache', 'Spotting',
                  'Fatigue', 'Mood changes', 'Back pain',
                  'Breast tenderness'].map((s) {
                final sel = symptoms.contains(s);
                return GestureDetector(
                  onTap: () => setS(() {
                    if (sel) { symptoms.remove(s); } else { symptoms.add(s); }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel
                          ? RColors.clay500.withValues(alpha: 0.08)
                          : RColors.sand50,
                      borderRadius: RRadius.pillBR,
                      border: Border.all(
                        color: sel
                            ? RColors.clay500.withValues(alpha: 0.3)
                            : RColors.sand200,
                        width: 0.5)),
                    child: Text(s,
                      style: TextStyle(fontSize: 11,
                        color: sel ? RColors.clay500 : RColors.sand700))));
              }).toList()),
            const SizedBox(height: 16),
            Row(children: [
              if (isEdit) ...[
                Expanded(child: GestureDetector(
                  onTap: () {
                    _periods.remove(existing);
                    Navigator.pop(context);
                    outerSetState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: RColors.clay100, borderRadius: RRadius.mdBR,
                      border: Border.all(
                          color: RColors.clay500.withValues(alpha: 0.2),
                          width: 0.5)),
                    child: const Center(child: Text('Delete',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                          color: RColors.clay500)))))),
                const SizedBox(width: 8),
              ],
              Expanded(flex: 2, child: GestureDetector(
                onTap: () {
                  if (isEdit) {
                    existing.startDate = dates[0];
                    existing.endDate   = dates[1];
                    existing.flowLevel = flowLevel;
                    existing.symptoms   = symptoms.toList();
                  } else {
                    _periods.add(PeriodEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      startDate: dates[0],
                      endDate:   dates[1],
                      flowLevel: flowLevel,
                      symptoms:  symptoms.toList(),
                    ));
                    _session.lastPeriodDate = dates[0];
                  }
                  Navigator.pop(context);
                  outerSetState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: RColors.clay500, borderRadius: RRadius.mdBR,
                    boxShadow: [BoxShadow(
                      color: RColors.clay500.withValues(alpha: 0.28),
                      blurRadius: 8, offset: const Offset(0, 3))]),
                  child: Center(child: Text(
                    isEdit ? 'Save changes' : 'Save period',
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)))))),
            ]),
          ])),
        ),
      ),
    );
  }

  Widget _dateRow(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: RColors.sand50, borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.clay500.withValues(alpha: 0.2),
              width: 0.5)),
        child: Row(children: [
          Text('$label:',
            style: const TextStyle(fontSize: 13, color: RColors.sand500)),
          const SizedBox(width: 10),
          Text(DateFormat('d MMMM yyyy').format(date),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: RColors.clay500)),
          const Spacer(),
          Icon(Icons.edit_rounded, size: 14,
              color: RColors.clay500.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime initial, {bool allowFuture = false}) =>
      showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: allowFuture
            ? DateTime.now().add(const Duration(days: 30))
            : DateTime.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: RColors.clay500)),
          child: child!),
      );

  void _showDayInfo(DateTime date, bool isPeriod, bool isFertile,
      bool isOvulation, bool isPredicted) {
    if (!isPeriod && !isFertile && !isOvulation && !isPredicted) return;
    final (title, body) = isPeriod
        ? ('Period day', 'Logged period on ${DateFormat('d MMMM').format(date)}.')
        : isOvulation
            ? ('Estimated ovulation',
               'Based on your ${_session.cycleLength}-day cycle. Highest fertility day.')
            : isFertile
                ? ('Fertile window',
                   'You may be in your fertile window. Pregnancy possible if unprotected sex occurs.')
                : ('Predicted period',
                   'Period predicted around ${DateFormat('d MMMM').format(date)} based on your cycle.');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: RColors.surface,
        title: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(body,
            style: const TextStyle(fontSize: 13, color: RColors.sand700,
                height: 1.5)),
        actions: [TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK',
              style: TextStyle(color: RColors.teal700)))],
      ),
    );
  }
}
