import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../theme/rehlah_theme.dart';
import '../../../../../core/utils/user_session.dart';

class CareHubScreen extends StatefulWidget {
  const CareHubScreen({super.key});
  @override
  State<CareHubScreen> createState() => _CareHubScreenState();
}

class _CareHubScreenState extends State<CareHubScreen> {
  final _session = UserSession();

  @override
  void initState() {
    super.initState();
    _session.addListener(_onChanged);
    _session.initDefaultAppointments();
  }

  @override
  void dispose() {
    _session.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  // ── Hero data ────────────────────────────────────────────────────────────────

  int get _pendingDoses {
    final total = _session.medications.length;
    final taken = _session.medsTakenTodayCount;
    return (total - taken).clamp(0, 99);
  }

  bool get _needsTempLog {
    final latest = _session.vitals.isNotEmpty ? _session.vitals.first : null;
    if (latest == null) return true;
    final now = DateTime.now();
    return latest.recordedAt.day != now.day ||
        latest.recordedAt.month != now.month ||
        latest.recordedAt.year != now.year;
  }

  bool get _needsCheckin => !_session.checkedInToday;

  String get _heroTitle {
    final count = (_pendingDoses > 0 ? 1 : 0) +
        (_needsTempLog ? 1 : 0) +
        (_needsCheckin ? 1 : 0);
    if (count == 0) return 'You\'re all caught up';
    if (count == 1) return 'One thing on your plate';
    if (count == 2) return 'Two things on your plate';
    return 'Three things on your plate';
  }

  // ── Lab status ───────────────────────────────────────────────────────────────

  String get _labSub {
    if (_session.labs.isEmpty) return 'No results logged yet';
    final lab = _session.labs.first;
    final d = lab.date;
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return 'Last drawn ${d.day} ${months[d.month - 1]}';
  }

  bool get _labsInRange =>
      _session.labs.isNotEmpty &&
      _session.labs.first.metrics.every((m) => m.isNormal);

  // ── Appointment subtitle ──────────────────────────────────────────────────────

  String get _apptSub {
    final upcoming = _session.upcomingAppointments;
    if (upcoming.isEmpty) return 'No upcoming appointments';
    final next = upcoming.first;
    final days = next.daysUntil;
    final when = days == 0 ? 'Today'
        : days == 1 ? 'Tomorrow'
        : 'in $days days';
    final doc = next.doctorName.isNotEmpty ? next.doctorName : next.title;
    return '$doc · $when';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              _journeyCard(),
              const SizedBox(height: 12),
              _hero(),
              _sectionHead('Track'),
              const SizedBox(height: 8),
              _toolRow(
                iconBg: RColors.sage100, iconFg: RColors.sage700,
                icon: Icons.medication_rounded,
                title: 'Medications',
                subtitle: '${_session.medsTakenTodayCount} of '
                    '${_session.medications.length} doses today',
                trailing: _pendingDoses > 0
                    ? _pill('Due soon', RColors.saffron100, RColors.saffron700)
                    : _pill('All done ✓', RColors.sage100, RColors.sage700),
                onTap: () => context.push('/care/medications'),
              ),
              _toolRow(
                iconBg: RColors.clay100, iconFg: RColors.clay700,
                icon: Icons.thermostat_rounded,
                title: 'Vitals',
                subtitle: _vitalsSubtitle(),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: () => context.push('/vitals'),
              ),
              _toolRow(
                iconBg: RColors.saffron100, iconFg: RColors.saffron700,
                icon: Icons.book_outlined,
                title: 'Journal',
                subtitle: _session.checkedInToday
                    ? 'Checked in today · ${_session.moodEmoji} ${_session.moodLabel}'
                    : 'Last entry ${_lastCheckinAgo()}',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: () => context.push('/care/checkin-history'),
              ),
              _sectionHead('Understand'),
              const SizedBox(height: 8),
              _toolRow(
                iconBg: RColors.teal100, iconFg: RColors.teal700,
                icon: Icons.info_outline_rounded,
                title: 'What to expect',
                subtitle: 'Side effects and phase guidance',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: () => context.push('/my-health/expect'),
              ),
              if (!_session.isMonitoring)
                _toolRow(
                  iconBg: RColors.sky100, iconFg: RColors.sky500,
                  icon: Icons.calendar_view_month_rounded,
                  title: 'Cycle tracker',
                  subtitle: 'Track your treatment cycle and plan ahead',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: RColors.sand300, size: 20),
                  onTap: () => context.push('/care/cycle-tracker'),
                ),
              if (_session.isMonitoring)
                _toolRow(
                  iconBg: RColors.sky100, iconFg: RColors.sky500,
                  icon: Icons.calendar_view_month_rounded,
                  title: 'Cycle tracker',
                  subtitle: 'Track periods and plan scans',
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: RColors.sand300, size: 20),
                  onTap: () => context.push('/monitoring/cycle-tracker'),
                ),
              _sectionHead('Records'),
              const SizedBox(height: 8),
              _toolRow(
                iconBg: RColors.teal100, iconFg: RColors.teal700,
                icon: Icons.science_outlined,
                title: 'Lab results',
                subtitle: _labSub,
                trailing: _session.labs.isEmpty
                    ? _pill('Add first', RColors.sand100, RColors.sand500)
                    : _labsInRange
                        ? _pill('In range', RColors.sage100, RColors.sage700)
                        : _pill('Review', RColors.clay100, RColors.clay700),
                onTap: () => context.push('/care/labs'),
              ),
              _toolRow(
                iconBg: RColors.sky100, iconFg: RColors.sky500,
                icon: Icons.calendar_month_rounded,
                title: 'Appointments',
                subtitle: _apptSub,
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: RColors.sand300, size: 20),
                onTap: () => context.push('/care/appointments'),
              ),
              const SizedBox(height: 16),
              _aiPrepCard(context),
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Journey progress card ─────────────────────────────────────────────────────

  Widget _journeyCard() {
    final isMonitoring = _session.isMonitoring;
    final current = _session.currentCycle;
    final total   = _session.totalCycles;
    final phase   = _session.currentPhase.name;
    final day     = _session.dayInCycle;
    final isNadir = _session.isNadirWindow;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('YOUR JOURNEY',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4,
              fontWeight: FontWeight.w500, color: RColors.sand500)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/my-health/journey'),
            child: const Text('View full',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: RColors.teal700)),
          ),
        ]),
        if (!isMonitoring) ...[
          const SizedBox(height: 12),
          Row(children: List.generate(total, (i) {
            final n          = i + 1;
            final isComplete = n < current;
            final isCurrent  = n == current;
            return Padding(
              padding: const EdgeInsets.only(right: 5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isCurrent ? 28 : 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isComplete || isCurrent
                      ? RColors.teal700 : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isComplete || isCurrent
                        ? RColors.teal700 : RColors.sand200,
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Center(child: isComplete
                  ? const Icon(Icons.check_rounded, size: 10,
                      color: Colors.white)
                  : Text('$n',
                      style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: isCurrent ? Colors.white : RColors.sand400))),
              ),
            );
          })),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: isNadir ? RColors.clay500 : RColors.teal500,
              shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(
            isMonitoring ? phase : '$phase · Day $day',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: RColors.sand900))),
          if (!isMonitoring)
            Text('Cycle $current of $total',
              style: const TextStyle(fontSize: 11, color: RColors.sand500)),
        ]),
      ]),
    );
  }

  // ── Topbar ───────────────────────────────────────────────────────────────────

  Widget _topbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        const SizedBox(width: 36),
        const Expanded(child: Center(child: Text('Care',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: RColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: RColors.sand200),
            ),
            child: const Icon(Icons.more_horiz_rounded,
                color: RColors.sand700, size: 20),
          ),
        ),
      ]),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────────

  Widget _hero() {
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
          Text('Today',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4, fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          Text(_heroTitle,
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.2, height: 1.2)),
          const SizedBox(height: 14),
          Row(children: [
            if (_pendingDoses > 0) ...[
              _chip('$_pendingDoses', 'doses'),
              const SizedBox(width: 10),
            ],
            if (_needsTempLog) ...[
              _chip('1', 'temp log'),
              const SizedBox(width: 10),
            ],
            if (_needsCheckin)
              _chip('1', 'check-in'),
            if (_pendingDoses == 0 && !_needsTempLog && !_needsCheckin)
              _chip('0', 'pending'),
          ]),
        ]),
      ]),
    );
  }

  Widget _chip(String num, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: RRadius.smBR,
      ),
      child: Column(children: [
        Text(num,
          style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700,
            color: Colors.white, height: 1.0,
            fontFeatures: [FontFeature.tabularFigures()])),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontSize: 10.5, color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400)),
      ]),
    );
  }

  // ── Section head ──────────────────────────────────────────────────────────────

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, letterSpacing: 1.4,
          fontWeight: FontWeight.w500, color: RColors.sand500)),
    );
  }

  // ── Tool row ──────────────────────────────────────────────────────────────────

  Widget _toolRow({
    required Color iconBg,
    required Color iconFg,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.sand200),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: RRadius.smBR),
            child: Icon(icon, color: iconFg, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: RColors.sand950)),
            const SizedBox(height: 2),
            Text(subtitle,
              style: const TextStyle(fontSize: 11, color: RColors.sand500,
                  height: 1.3)),
          ])),
          const SizedBox(width: 8),
          trailing,
        ]),
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      height: 24,
      decoration: BoxDecoration(color: bg, borderRadius: RRadius.pillBR),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
          decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500,
              color: fg, height: 1.0)),
      ]),
    );
  }

  // ── AI prep card ─────────────────────────────────────────────────────────────

  Widget _aiPrepCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/care/appointments/prep'),
      child: Container(
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
              color: RColors.teal700, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI PREP REPORT',
              style: TextStyle(fontSize: 10.5, letterSpacing: 1.2,
                  fontWeight: FontWeight.w500, color: RColors.teal700)),
            SizedBox(height: 2),
            Text('A briefing for your doctor',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: RColors.sand900)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: RColors.sand400, size: 22),
        ]),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _vitalsSubtitle() {
    final vitals = _session.vitals;
    if (vitals.isEmpty) return 'No reading logged today';
    final latest = vitals.first;
    final now = DateTime.now();
    if (latest.recordedAt.day == now.day) {
      final temp = latest.temperatureCelsius;
      return 'Max ${temp.toStringAsFixed(1)}° · logged today';
    }
    return 'No reading logged today';
  }

  String _lastCheckinAgo() {
    final last = _session.lastCheckIn;
    if (last == null) return 'never';
    final diff = DateTime.now().difference(last).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '$diff days ago';
  }
}
