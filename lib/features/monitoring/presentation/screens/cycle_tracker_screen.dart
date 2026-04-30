import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
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
  int _scanViewMonth = 0; // offset from next month

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
    // Default to showing the month with the next period/fertile window
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  // ── Cycle calculations ────────────────────────────────────────────────────
  DateTime? get _lastPeriodStart {
    if (_periods.isEmpty && _session.lastPeriodDate == null) return null;
    if (_periods.isNotEmpty) {
      final sorted = [..._periods]..sort(
          (a, b) => b.startDate.compareTo(a.startDate));
      return sorted.first.startDate;
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
        ? (_periods.map((p) => p.duration).reduce((a, b) => a + b) /
            _periods.length).round()
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

  // Fertile window: 5 days before ovulation + ovulation day
  bool _isFertileDay(DateTime date) {
    final next = _nextPeriodDate();
    if (next == null) return false;
    // Ovulation ~14 days before next period
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
        date.month == ovulation.month &&
        date.day == ovulation.day;
  }

  List<(DateTime, DateTime)> _optimalWindowsInMonth(DateTime month) {
    if (_session.menstrualStatus != 'regular') return [];
    final last = _lastPeriodStart;
    if (last == null) return [];

    final windows = <(DateTime, DateTime)>[];
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final planningMin = DateTime.now().add(const Duration(days: 14));

    // Start far enough back to catch windows that begin before monthStart
    DateTime cycleStart = last;
    while (cycleStart.isAfter(
        monthStart.subtract(Duration(days: _session.cycleLength + 14)))) {
      cycleStart = cycleStart.subtract(Duration(days: _session.cycleLength));
    }

    // Scan forward through enough cycles to cover the month
    for (int i = 0; i < 12; i++) {
      final ws = cycleStart.add(const Duration(days: 6));  // day 7
      final we = cycleStart.add(const Duration(days: 13)); // day 14

      // Window overlaps with this month AND is far enough in future to plan
      if (!we.isBefore(monthStart) && !ws.isAfter(monthEnd) &&
          !we.isBefore(planningMin)) {
        final cs = ws.isBefore(monthStart) ? monthStart : ws;
        final ce = we.isAfter(monthEnd) ? monthEnd : we;
        windows.add((cs, ce));
      }

      cycleStart = cycleStart.add(Duration(days: _session.cycleLength));
      // Stop once cycle starts are well past the month
      if (cycleStart.isAfter(monthEnd.add(const Duration(days: 14)))) break;
    }
    return windows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(child: _tabIndex == 0
              ? _buildPeriodTracker()
              : _buildScanCalendar()),
        ]),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => context.go('/'),
        child: Row(children: [
          Icon(Icons.arrow_back_ios_new_rounded, size: 15,
            color: AppColors.text2.withOpacity(0.4)),
          const SizedBox(width: 4),
          Text('Home', style: AppText.caption.copyWith(color: AppColors.text2)),
        ]),
      ),
      const SizedBox(height: 8),
      RichText(text: TextSpan(style: AppText.displayTitle, children: const [
        TextSpan(text: 'Cycle & '),
        TextSpan(text: 'scan tracker',
          style: TextStyle(fontWeight: FontWeight.w700)),
      ])),
    ]),
  );

  Widget _buildTabs() => Padding(
    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
    child: Container(
      height: 36, padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: AppRadius.fullBR),
      child: Row(
        children: ['Period tracker', 'Scan calendar']
            .asMap().entries.map((e) {
          final active = e.key == _tabIndex;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _tabIndex = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: active ? AppColors.surface : Colors.transparent,
                borderRadius: AppRadius.fullBR,
                boxShadow: active ? [BoxShadow(
                  color: AppColors.primary.withOpacity(0.10),
                  blurRadius: 4)] : null),
              child: Center(child: Text(e.value,
                style: AppText.body.copyWith(
                  fontSize: 12,
                  color: active ? AppColors.primary : AppColors.text3,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400)))),
          ));
        }).toList(),
      ),
    ),
  );

  // ── Period Tracker ────────────────────────────────────────────────────────
  Widget _buildPeriodTracker() {
    final nextPeriod = _nextPeriodDate();
    final daysUntil = nextPeriod != null
        ? nextPeriod.difference(DateTime.now()).inDays : null;

    return Column(children: [
      // Stats strip
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Row(children: [
          _miniStat(
            daysUntil != null ? '$daysUntil' : '—',
            'days to\nnext period', AppColors.rose),
          const SizedBox(width: 6),
          _miniStat('${_session.cycleLength}', 'cycle\nlength', AppColors.primary),
          const SizedBox(width: 6),
          _miniStat(
            _periods.isNotEmpty
                ? '${(_periods.map((p) => p.duration).reduce((a, b) => a + b) / _periods.length).round()}'
                : '—',
            'avg period\ndays', AppColors.teal),
          const SizedBox(width: 6),
          // Settings button
          GestureDetector(
            onTap: _showSettingsSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(children: [
                const Icon(Icons.tune_rounded, size: 16, color: AppColors.text2),
                const SizedBox(height: 2),
                Text('Settings', style: AppText.caption.copyWith(
                  fontSize: 9, color: AppColors.text3)),
              ]),
            ),
          ),
        ]),
      ),

      // Month navigation
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navBtn(Icons.chevron_left_rounded,
                () => setState(() => _focusedMonth = DateTime(
                    _focusedMonth.year, _focusedMonth.month - 1))),
            Text(DateFormat('MMMM yyyy').format(_focusedMonth),
              style: AppText.bodySemibold.copyWith(fontSize: 15)),
            _navBtn(Icons.chevron_right_rounded,
                () => setState(() => _focusedMonth = DateTime(
                    _focusedMonth.year, _focusedMonth.month + 1))),
          ],
        ),
      ),

      // Cycle info for this month
      _buildMonthCycleInfo(_focusedMonth),

      // Calendar
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        child: Column(children: [
          _buildCompactCalendar(_focusedMonth),
          const SizedBox(height: 8),
          _buildLegend(),
          const SizedBox(height: 12),
          _buildPeriodHistory(),
          const SizedBox(height: 80),
        ]),
      )),

      // Log button
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        child: GestureDetector(
          onTap: _showLogPeriodSheet,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.rose,
              borderRadius: AppRadius.fullBR,
              boxShadow: [BoxShadow(
                color: AppColors.rose.withOpacity(0.28),
                blurRadius: 10, offset: const Offset(0, 3))]),
            child: const Center(child: Text('+ Log period',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w500, color: Colors.white))))),
      ),
    ]);
  }

  Widget _miniStat(String value, String label, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: AppRadius.smBR,
        border: Border.all(color: color.withOpacity(0.12), width: 0.5)),
      child: Column(children: [
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 16,
          fontWeight: FontWeight.w600, color: color)),
        Text(label, style: AppText.caption.copyWith(
          fontSize: 8, color: AppColors.text3, height: 1.3),
          textAlign: TextAlign.center),
      ]),
    ));
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface, shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Icon(icon, size: 18, color: AppColors.text2)));

  Widget _buildMonthCycleInfo(DateTime month) {
    final next = _nextPeriodDate();
    if (next == null) return const SizedBox(height: 4);

    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final ovulation = next.subtract(const Duration(days: 14));
    final fertileStart = ovulation.subtract(const Duration(days: 5));

    final items = <String>[];

    // Check if period is in this month
    for (final p in _periods) {
      if (!p.endDate.isBefore(monthStart) && !p.startDate.isAfter(monthEnd)) {
        items.add('🔴 Period: ${DateFormat('d').format(p.startDate)}–${DateFormat('d MMM').format(p.endDate)}');
      }
    }

    // Fertile window in this month
    if (!fertileStart.isAfter(monthEnd) && !ovulation.isBefore(monthStart)) {
      final fs = fertileStart.isBefore(monthStart) ? monthStart : fertileStart;
      items.add('🌿 Fertile: ${DateFormat('d').format(fs)}–${DateFormat('d MMM').format(ovulation)}');
    }

    // Ovulation in this month
    if (ovulation.month == month.month && ovulation.year == month.year) {
      items.add('🟢 Ovulation: ${DateFormat('d MMM').format(ovulation)}');
    }

    // Predicted next period in this month
    if (next.month == month.month && next.year == month.year) {
      items.add('🔮 Next period: ~${DateFormat('d MMM').format(next)}');
    }

    if (items.isEmpty) return const SizedBox(height: 4);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.primaryMid, width: 0.5)),
      child: Wrap(
        spacing: 12, runSpacing: 4,
        children: items.map((item) => Text(item,
          style: AppText.caption.copyWith(fontSize: 11))).toList(),
      ),
    );
  }

  Widget _buildCompactCalendar(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final now = DateTime.now();

    return Column(children: [
      // Headers
      Row(children: ['S','M','T','W','T','F','S'].map((d) =>
        Expanded(child: Center(child: Text(d,
          style: AppText.caption.copyWith(
            fontSize: 11, color: AppColors.text3,
            fontWeight: FontWeight.w600))))).toList()),
      const SizedBox(height: 4),
      // Grid
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2,
          childAspectRatio: 1),
        itemCount: startWeekday + daysInMonth,
        itemBuilder: (_, i) {
          if (i < startWeekday) return const SizedBox.shrink();
          final day = i - startWeekday + 1;
          final date = DateTime(month.year, month.month, day);
          return _buildDayCell(date, now);
        },
      ),
    ]);
  }

  Widget _buildDayCell(DateTime date, DateTime now) {
    final isToday = date.year == now.year &&
        date.month == now.month && date.day == now.day;
    final isPeriod = _isPeriodDay(date);
    final isOvulation = _isOvulationDay(date);
    final isFertile = !isOvulation && _isFertileDay(date);
    final isPredicted = !isPeriod && !isOvulation && !isFertile &&
        _isPredictedPeriod(date);

    Color? bg;
    Color textColor = AppColors.text2;
    Widget? dot;

    if (isPeriod) {
      bg = const Color(0xFFFFCDD2); // strong pink
      textColor = const Color(0xFFB71C1C);
    } else if (isOvulation) {
      bg = const Color(0xFF2E7D32); // deep green
      textColor = Colors.white;
      dot = Container(
        width: 4, height: 4,
        margin: const EdgeInsets.only(top: 1),
        decoration: const BoxDecoration(
          color: Colors.white, shape: BoxShape.circle));
    } else if (isFertile) {
      bg = const Color(0xFFC8E6C9); // light green
      textColor = const Color(0xFF2E7D32);
    } else if (isPredicted) {
      bg = const Color(0xFFFFEBEE); // very light pink
      textColor = const Color(0xFFE57373);
    }

    return GestureDetector(
      onTap: () => _showDayInfo(date, isPeriod, isFertile, isOvulation, isPredicted),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: isToday ? Border.all(
            color: AppColors.primary, width: 2) : null),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${date.day}', style: TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            fontWeight: isToday || isPeriod || isOvulation
                ? FontWeight.w700 : FontWeight.w400,
            color: isToday && bg == null ? AppColors.primary : textColor)),
          if (dot != null) dot,
        ]),
      ),
    );
  }

  Widget _buildLegend() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _legendDot(const Color(0xFFFFCDD2), const Color(0xFFB71C1C), 'Period'),
      const SizedBox(width: 12),
      _legendDot(const Color(0xFFC8E6C9), const Color(0xFF2E7D32), 'Fertile'),
      const SizedBox(width: 12),
      _legendDot(const Color(0xFF2E7D32), Colors.white, 'Ovulation'),
      const SizedBox(width: 12),
      _legendDot(const Color(0xFFFFEBEE), const Color(0xFFE57373), 'Predicted'),
    ]),
  );

  Widget _legendDot(Color bg, Color textColor, String label) => Row(children: [
    Container(width: 12, height: 12,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle,
        border: Border.all(
          color: textColor.withOpacity(0.3), width: 0.5))),
    const SizedBox(width: 4),
    Text(label, style: AppText.caption.copyWith(fontSize: 10)),
  ]);

  Widget _buildPeriodHistory() {
    if (_periods.isEmpty) return const SizedBox.shrink();
    final sorted = [..._periods]
        ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('RECENT PERIODS', style: AppText.label.copyWith(fontSize: 10)),
        GestureDetector(
          onTap: _showSettingsSheet,
          child: Text('Edit cycle settings →',
            style: AppText.caption.copyWith(
              color: AppColors.primary, fontSize: 11,
              fontWeight: FontWeight.w500))),
      ]),
      const SizedBox(height: 8),
      ...sorted.take(3).map((p) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5)),
        child: Row(children: [
          Container(width: 8, height: 8,
            decoration: BoxDecoration(
              color: AppColors.rose.withOpacity(0.5),
              shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('d MMM yyyy').format(p.startDate),
                style: AppText.bodySemibold.copyWith(fontSize: 13)),
              Text('${p.duration} days · ${_flowLabel(p.flowLevel)}',
                style: AppText.caption.copyWith(fontSize: 11)),
            ],
          )),
          // Edit button
          GestureDetector(
            onTap: () => _showEditPeriodSheet(p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background2,
                borderRadius: AppRadius.fullBR),
              child: Text('Edit',
                style: AppText.caption.copyWith(
                  fontSize: 10, color: AppColors.text2)))),
        ]),
      )),
    ]);
  }

  String _flowLabel(int level) {
    return {1: 'Light', 2: 'Moderate', 3: 'Heavy'}[level] ?? '';
  }

  // ── Scan Calendar ─────────────────────────────────────────────────────────
  Widget _buildScanCalendar() {
    final now = DateTime.now();
    // Show 6 months starting from next month
    final months = List.generate(6, (i) =>
        DateTime(now.year, now.month + i + 1));

    return Column(children: [
      // Info banner
      Container(
        margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.06),
          borderRadius: AppRadius.mdBR,
          border: Border.all(
            color: AppColors.teal.withOpacity(0.18), width: 0.5)),
        child: Row(children: [
          const Text('📅', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(
            _session.menstrualStatus == 'regular'
                ? 'Green = optimal scan window (Days 7–14). Book MRI or Mammogram 4–6 weeks ahead.'
                : 'No cycle restriction. Schedule MRI / Mammogram at any convenient time.',
            style: AppText.caption.copyWith(
              color: AppColors.teal, fontSize: 11, height: 1.5))),
        ]),
      ),

      Expanded(child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        itemCount: months.length,
        itemBuilder: (_, i) => _buildScanMonthCard(months[i]),
      )),
    ]);
  }

  Widget _buildScanMonthCard(DateTime month) {
    final windows = _optimalWindowsInMonth(month);
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: windows.isNotEmpty
              ? AppColors.teal.withOpacity(0.2)
              : AppColors.border,
          width: windows.isNotEmpty ? 1 : 0.5)),
      child: Column(children: [
        // Month header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Row(children: [
            Text(DateFormat('MMMM yyyy').format(month),
              style: AppText.bodySemibold),
            const Spacer(),
            if (windows.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: AppRadius.fullBR),
                child: Text(
                  windows.length == 1
                      ? '1 window'
                      : '${windows.length} windows',
                  style: AppText.caption.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600, fontSize: 10)))
            else if (_session.menstrualStatus != 'regular')
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.fullBR),
                child: Text('Any time',
                  style: AppText.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600, fontSize: 10))),
          ]),
        ),

        // Day headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: ['S','M','T','W','T','F','S'].map((d) =>
            Expanded(child: Center(child: Text(d,
              style: AppText.caption.copyWith(
                fontSize: 9, color: AppColors.text3,
                fontWeight: FontWeight.w600))))).toList()),
        ),
        const SizedBox(height: 4),

        // Grid
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 2,
              crossAxisSpacing: 2, childAspectRatio: 1.1),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startWeekday) return const SizedBox.shrink();
              final day = i - startWeekday + 1;
              final date = DateTime(month.year, month.month, day);
              return _buildScanDayCell(date, windows);
            },
          ),
        ),

        // Window labels
        if (windows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity, height: 0.5,
                  color: AppColors.border),
                const SizedBox(height: 8),
                ...windows.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(children: [
                    Container(width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.35),
                        shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('d MMM').format(w.$1)} – ${DateFormat('d MMM').format(w.$2)}',
                      style: AppText.bodySemibold.copyWith(
                        color: AppColors.teal, fontSize: 12)),
                    const SizedBox(width: 6),
                    Text('· Best time to book',
                      style: AppText.caption.copyWith(
                        color: AppColors.text3, fontSize: 10)),
                  ]),
                )),
              ],
            ),
          ),
      ]),
    );
  }

  Widget _buildScanDayCell(DateTime date, List<(DateTime, DateTime)> windows) {
    final isOptimal = windows.any((w) =>
        !date.isBefore(DateTime(w.$1.year, w.$1.month, w.$1.day)) &&
        !date.isAfter(DateTime(w.$2.year, w.$2.month, w.$2.day)));

    // Determine position for rounded ends
    BorderRadius? radius;
    for (final w in windows) {
      final isStart = date.year == w.$1.year &&
          date.month == w.$1.month && date.day == w.$1.day;
      final isEnd = date.year == w.$2.year &&
          date.month == w.$2.month && date.day == w.$2.day;
      if (isStart && isEnd) {
        radius = BorderRadius.circular(8);
      } else if (isStart) {
        radius = const BorderRadius.horizontal(left: Radius.circular(8));
      } else if (isEnd) {
        radius = const BorderRadius.horizontal(right: Radius.circular(8));
      } else if (isOptimal) {
        radius = BorderRadius.zero;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isOptimal ? AppColors.teal.withOpacity(0.14) : Colors.transparent,
        borderRadius: radius ?? BorderRadius.circular(6)),
      child: Center(child: Text('${date.day}',
        style: TextStyle(
          fontFamily: 'Inter', fontSize: 11,
          fontWeight: isOptimal ? FontWeight.w600 : FontWeight.w400,
          color: isOptimal ? AppColors.teal : AppColors.text2))),
    );
  }

  // ── Sheets ────────────────────────────────────────────────────────────────
  void _showSettingsSheet() {
    int cycleLen = _session.cycleLength;
    String status = _session.menstrualStatus;
    final outerSetState = setState;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20,
              MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('CYCLE SETTINGS', style: AppText.label.copyWith(fontSize: 10)),
            const SizedBox(height: 14),

            // Cycle length
            Text('Cycle length', style: AppText.bodySecondary),
            const SizedBox(height: 8),
            Row(children: [
              GestureDetector(
                onTap: () => setS(() => cycleLen = (cycleLen - 1).clamp(21, 45)),
                child: _circleBtn(Icons.remove_rounded)),
              const SizedBox(width: 16),
              Text('$cycleLen days',
                style: AppText.sectionHeading.copyWith(
                  color: AppColors.primary, fontSize: 18)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setS(() => cycleLen = (cycleLen + 1).clamp(21, 45)),
                child: _circleBtn(Icons.add_rounded)),
            ]),

            const SizedBox(height: 16),

            // Menstrual status
            Text('Current menstrual status', style: AppText.bodySecondary),
            const SizedBox(height: 8),
            ...[
              ('regular', '🔄', 'Regular cycles'),
              ('irregular', '〰️', 'Irregular cycles'),
              ('amenorrhea', '⏸️', 'No period yet'),
              ('menopause', '🍂', 'Menopause'),
            ].map((opt) {
              final sel = status == opt.$1;
              return GestureDetector(
                onTap: () => setS(() => status = opt.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primaryLight : AppColors.background,
                    borderRadius: AppRadius.mdBR,
                    border: Border.all(
                      color: sel ? AppColors.primaryMid : AppColors.border,
                      width: 0.5)),
                  child: Row(children: [
                    Text(opt.$2, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Text(opt.$3, style: AppText.bodySemibold.copyWith(
                      color: sel ? AppColors.primary : AppColors.text1,
                      fontSize: 13)),
                    if (sel) ...[const Spacer(),
                      Icon(Icons.check_rounded, size: 16,
                        color: AppColors.primary)],
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
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.fullBR,
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10, offset: const Offset(0, 3))]),
                child: const Center(child: Text('Save settings',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                    fontWeight: FontWeight.w500, color: Colors.white)))),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.primaryLight, shape: BoxShape.circle,
      border: Border.all(color: AppColors.primaryMid, width: 0.5)),
    child: Icon(icon, size: 18, color: AppColors.primary));

  void _showLogPeriodSheet() => _showPeriodSheet(null, setState);
  void _showEditPeriodSheet(PeriodEntry p) => _showPeriodSheet(p, setState);

  void _showPeriodSheet(PeriodEntry? existing, StateSetter outerSetState) {
    // Use lists so reassignment inside StatefulBuilder is visible to save button
    final dates = [
      existing?.startDate ?? DateTime.now(),
      existing?.endDate ?? DateTime.now().add(const Duration(days: 4)),
    ];
    int flowLevel = existing?.flowLevel ?? 2;
    final symptoms = <String>{...?existing?.symptoms};
    final isEdit = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20,
              MediaQuery.of(context).viewInsets.bottom + 32),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            Text(isEdit ? 'EDIT PERIOD' : 'LOG PERIOD',
              style: AppText.label.copyWith(fontSize: 10)),
            const SizedBox(height: 12),

            // Start date
            _dateRow('Start date', dates[0], () async {
              final p = await _pickDate(dates[0]);
              if (p != null) setS(() => dates[0] = p);
            }, AppColors.rose),
            const SizedBox(height: 8),
            _dateRow('End date', dates[1], () async {
              final p = await _pickDate(dates[1], allowFuture: true);
              if (p != null) setS(() => dates[1] = p);
            }, AppColors.rose),

            const SizedBox(height: 12),

            // Flow
            Text('Flow level', style: AppText.bodySecondary),
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
                        ? AppColors.rose.withOpacity(0.10)
                        : AppColors.background,
                    borderRadius: AppRadius.mdBR,
                    border: Border.all(
                      color: sel
                          ? AppColors.rose.withOpacity(0.3)
                          : AppColors.border,
                      width: 0.5)),
                  child: Center(child: Text(labels[l]!,
                    style: AppText.caption.copyWith(
                      color: sel ? AppColors.rose : AppColors.text2,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 10)))),
              ));
            }).toList()),

            const SizedBox(height: 12),

            // Symptoms
            Text('Symptoms', style: AppText.bodySecondary),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6,
              children: ['Cramps', 'Bloating', 'Headache',
                  'Spotting', 'Fatigue', 'Mood changes', 'Back pain',
                  'Breast tenderness'].map((s) {
                final sel = symptoms.contains(s);
                return GestureDetector(
                  onTap: () => setS(() {
                    if (sel) symptoms.remove(s); else symptoms.add(s);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.rose.withOpacity(0.08)
                          : AppColors.background,
                      borderRadius: AppRadius.fullBR,
                      border: Border.all(
                        color: sel
                            ? AppColors.rose.withOpacity(0.3)
                            : AppColors.border,
                        width: 0.5)),
                    child: Text(s, style: AppText.caption.copyWith(
                      color: sel ? AppColors.rose : AppColors.text2,
                      fontSize: 11))),
                );
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
                      color: AppColors.roseLight,
                      borderRadius: AppRadius.mdBR,
                      border: Border.all(
                        color: AppColors.rose.withOpacity(0.2), width: 0.5)),
                    child: Center(child: Text('Delete',
                      style: AppText.caption.copyWith(
                        color: AppColors.rose, fontWeight: FontWeight.w500,
                        fontSize: 13)))))),
                const SizedBox(width: 8),
              ],
              Expanded(flex: 2, child: GestureDetector(
                onTap: () {
                  if (isEdit) {
                    existing!.startDate = dates[0];
                    existing.endDate = dates[1];
                    existing.flowLevel = flowLevel;
                    existing.symptoms = symptoms.toList();
                  } else {
                    _periods.add(PeriodEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      startDate: dates[0],
                      endDate: dates[1],
                      flowLevel: flowLevel,
                      symptoms: symptoms.toList(),
                    ));
                    _session.lastPeriodDate = dates[0];
                  }
                  Navigator.pop(context);
                  outerSetState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.rose,
                    borderRadius: AppRadius.mdBR,
                    boxShadow: [BoxShadow(
                      color: AppColors.rose.withOpacity(0.28),
                      blurRadius: 8, offset: const Offset(0, 3))]),
                  child: Center(child: Text(
                    isEdit ? 'Save changes' : 'Save period',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                      fontWeight: FontWeight.w500, color: Colors.white)))))),
            ]),
          ])),
        ),
      ),
    );
  }

  Widget _dateRow(String label, DateTime date, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: color.withOpacity(0.25), width: 0.5)),
        child: Row(children: [
          Text('$label:', style: AppText.bodySecondary.copyWith(fontSize: 13)),
          const SizedBox(width: 10),
          Text(DateFormat('d MMMM yyyy').format(date),
            style: AppText.bodySemibold.copyWith(color: color, fontSize: 13)),
          const Spacer(),
          Icon(Icons.edit_rounded, size: 14, color: color.withOpacity(0.5)),
        ]),
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime initial, {bool allowFuture = false}) => showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime.now().subtract(const Duration(days: 365)),
    lastDate: allowFuture
        ? DateTime.now().add(const Duration(days: 30))
        : DateTime.now(),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(primary: AppColors.rose)),
      child: child!),
  );

  void _showDayInfo(DateTime date, bool isPeriod, bool isFertile,
      bool isOvulation, bool isPredicted) {
    if (!isPeriod && !isFertile && !isOvulation && !isPredicted) return;
    String title, body;
    if (isPeriod) {
      title = '🔴 Period day';
      body = 'Logged period on ${DateFormat('d MMMM').format(date)}.';
    } else if (isOvulation) {
      title = '🟢 Estimated ovulation';
      body = 'Based on your ${_session.cycleLength}-day cycle. Highest fertility day.';
    } else if (isFertile) {
      title = '🌿 Fertile window';
      body = 'You may be in your fertile window. Pregnancy possible if unprotected sex occurs.';
    } else {
      title = '🔮 Predicted period';
      body = 'Period predicted around ${DateFormat('d MMMM').format(date)} based on your cycle.';
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppText.sectionHeading.copyWith(fontSize: 15)),
        content: Text(body, style: AppText.bodySecondary),
        actions: [TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK',
            style: TextStyle(color: AppColors.primary)))],
      ),
    );
  }
}
