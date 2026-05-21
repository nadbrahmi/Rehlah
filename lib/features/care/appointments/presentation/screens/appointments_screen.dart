import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../theme/rehlah_theme.dart';
import '../../../../../core/utils/models.dart';
import '../../../../../core/utils/user_session.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _session = UserSession();

  @override
  void initState() {
    super.initState();
    _session.initDefaultAppointments();
    _session.addListener(_rebuild);
  }

  @override
  void dispose() {
    _session.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final upcoming = _session.upcomingAppointments;
    final past     = _session.pastAppointments;
    final next     = upcoming.isNotEmpty ? upcoming.first : null;

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(context),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              if (next != null) _hero(context, next),
              if (upcoming.isNotEmpty) ...[
                _sectionHead('Upcoming'),
                const SizedBox(height: 8),
                ...upcoming.map((a) => _apptCard(a, primary: a == next)),
              ] else _emptyState(),
              if (past.isNotEmpty) ...[
                _sectionHead('Past'),
                const SizedBox(height: 8),
                ...past.map((a) => Opacity(opacity: 0.65,
                    child: _pastRow(a))),
              ],
              const SizedBox(height: 24),
            ]),
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
        const Expanded(child: Center(child: Text('Appointments',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        _iconBtn(Icons.add_rounded, onTap: () => _showAddEditSheet(null)),
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

  // ── Countdown hero ───────────────────────────────────────────────────────────

  Widget _hero(BuildContext context, Appointment next) {
    final days = next.daysUntil;
    final dayLabel = days == 0 ? 'today'
        : days == 1 ? 'tomorrow' : 'days';
    final dayNum = days == 0 ? '' : '$days';
    final docLine = '${next.doctorName.isNotEmpty ? next.doctorName : next.title}'
        ' · ${DateFormat('EEE').format(next.dateTime)}';

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
          Text('Next appointment in',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
            if (dayNum.isNotEmpty) ...[
              Text(dayNum,
                style: const TextStyle(
                  fontSize: 56, fontWeight: FontWeight.w700,
                  color: Colors.white, height: 1,
                  fontFeatures: [FontFeature.tabularFigures()])),
              const SizedBox(width: 8),
            ],
            Text(dayLabel,
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.78))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            GestureDetector(
              onTap: () => context.push('/care/appointments/prep'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: RColors.saffron500,
                  borderRadius: RRadius.pillBR,
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.auto_awesome_rounded,
                      color: RColors.sand950, size: 13),
                  SizedBox(width: 6),
                  Text('AI prep report',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: RColors.sand950)),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            Text(docLine,
              style: TextStyle(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
          ]),
        ]),
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

  // ── Appointment card ──────────────────────────────────────────────────────────

  Widget _apptCard(Appointment apt, {bool primary = false}) {
    final dayStr = '${apt.dateTime.day}'.padLeft(2, '0');
    final monStr = DateFormat('MMM').format(apt.dateTime).toUpperCase();
    final timeStr = DateFormat('EEEE · HH:mm').format(apt.dateTime);

    return GestureDetector(
      onTap: () => _showAddEditSheet(apt),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          border: Border.all(
            color: primary ? RColors.saffron300 : RColors.sand200),
          boxShadow: primary
              ? [BoxShadow(
                  color: RColors.saffron500.withValues(alpha: 0.18),
                  blurRadius: 14, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Date box
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: RColors.saffron100,
              borderRadius: RRadius.smBR,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dayStr,
                  style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: RColors.saffron700, height: 1,
                    fontFeatures: [FontFeature.tabularFigures()])),
                const SizedBox(height: 4),
                Text(monStr,
                  style: const TextStyle(
                    fontSize: 10, letterSpacing: 1.2,
                    fontWeight: FontWeight.w500, color: RColors.saffron700)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Body
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(apt.title,
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: RColors.sand950)),
              const SizedBox(height: 2),
              Text(
                '$timeStr${apt.location.isNotEmpty ? ' · ${apt.location}' : ''}',
                style: const TextStyle(fontSize: 11, color: RColors.sand500)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: primary
                    ? null // could open maps
                    : () => _showAddEditSheet(apt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: RRadius.pillBR,
                    border: Border.all(color: RColors.teal200),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (primary) ...[
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: RColors.teal700),
                      const SizedBox(width: 4),
                      const Text('Directions',
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: RColors.teal700)),
                    ] else
                      const Text('Details',
                        style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: RColors.teal700)),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Past row ──────────────────────────────────────────────────────────────────

  Widget _pastRow(Appointment apt) {
    final dateStr = DateFormat('d MMM').format(apt.dateTime);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(
            color: RColors.sand100, borderRadius: RRadius.smBR),
          child: Center(child: Text(dateStr.split(' ').first,
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: RColors.sand500,
              fontFeatures: [FontFeature.tabularFigures()]))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(apt.title,
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: RColors.sand950)),
          Text('$dateStr · ${DateFormat('HH:mm').format(apt.dateTime)}'
              '${apt.location.isNotEmpty ? ' · ${apt.location}' : ''}',
            style: const TextStyle(fontSize: 11, color: RColors.sand500)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          height: 22,
          decoration: const BoxDecoration(
            color: RColors.sage100, borderRadius: RRadius.pillBR),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 5, height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: RColors.sage700)),
            const SizedBox(width: 5),
            const Text('Done',
              style: TextStyle(fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: RColors.sage700, height: 1)),
          ]),
        ),
      ]),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.sand200),
        ),
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              color: RColors.saffron100, borderRadius: RRadius.mdBR),
            child: const Center(child: Text('📅',
              style: TextStyle(fontSize: 26)))),
          const SizedBox(height: 16),
          const Text('No upcoming appointments',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: RColors.sand950)),
          const SizedBox(height: 8),
          const Text(
            'Add your next oncology visit so Rehlah can prepare your doctor-ready report.',
            style: TextStyle(fontSize: 13, color: RColors.sand700, height: 1.5),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showAddEditSheet(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: RColors.teal700, borderRadius: RRadius.pillBR),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('Add appointment',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: Colors.white)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Add / Edit sheet ──────────────────────────────────────────────────────────

  void _showAddEditSheet(Appointment? existing) {
    final isEdit     = existing != null;
    final titleCtrl  = TextEditingController(text: existing?.title ?? '');
    final doctorCtrl = TextEditingController(text: existing?.doctorName ?? '');
    final locCtrl    = TextEditingController(text: existing?.location ?? '');
    DateTime selectedDate = existing?.dateTime ??
        DateTime.now().add(const Duration(days: 7));
    TimeOfDay selectedTime = existing != null
        ? TimeOfDay(hour: existing.dateTime.hour,
            minute: existing.dateTime.minute)
        : const TimeOfDay(hour: 10, minute: 0);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: RColors.sand200,
                    borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              Text(isEdit ? 'EDIT APPOINTMENT' : 'ADD APPOINTMENT',
                style: const TextStyle(
                  fontSize: 10.5, letterSpacing: 1.4,
                  fontWeight: FontWeight.w500, color: RColors.sand500)),
              const SizedBox(height: 14),
              _field('Appointment title', titleCtrl, 'e.g. Oncology follow-up'),
              const SizedBox(height: 8),
              _field('Doctor / department', doctorCtrl, 'e.g. Dr. Sarah Chen'),
              const SizedBox(height: 8),
              _field('Location', locCtrl, 'e.g. Oncology Clinic'),
              const SizedBox(height: 12),
              const Text('Date',
                style: TextStyle(fontSize: 12, color: RColors.sand500)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(
                        const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: RColors.teal700)),
                      child: child!),
                  );
                  if (p != null) setS(() => selectedDate = p);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: RColors.sand50, borderRadius: RRadius.mdBR,
                    border: Border.all(color: RColors.teal200)),
                  child: Row(children: [
                    const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500, color: RColors.teal700)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Time',
                style: TextStyle(fontSize: 12, color: RColors.sand500)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: context, initialTime: selectedTime,
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: RColors.teal700)),
                      child: child!),
                  );
                  if (t != null) setS(() => selectedTime = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: RColors.sand50, borderRadius: RRadius.mdBR,
                    border: Border.all(color: RColors.teal200)),
                  child: Row(children: [
                    const Text('⏰', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(selectedTime.format(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500, color: RColors.teal700)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                if (isEdit) ...[
                  Expanded(child: GestureDetector(
                    onTap: () {
                      _session.removeAppointment(existing.id);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: RColors.clay100,
                        borderRadius: RRadius.mdBR,
                        border: Border.all(
                            color: RColors.clay300.withValues(alpha: 0.5))),
                      child: const Center(child: Text('Delete',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: RColors.clay700)))))),
                  const SizedBox(width: 8),
                ],
                Expanded(flex: 2, child: GestureDetector(
                  onTap: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final dt = DateTime(
                      selectedDate.year, selectedDate.month,
                      selectedDate.day, selectedTime.hour,
                      selectedTime.minute);
                    _session.addAppointment(Appointment(
                      id: isEdit
                          ? existing.id
                          : DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleCtrl.text.trim(),
                      doctorName: doctorCtrl.text.trim(),
                      location: locCtrl.text.trim(),
                      dateTime: dt,
                      isPast: dt.isBefore(DateTime.now()),
                    ));
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: RColors.teal700,
                      borderRadius: RRadius.mdBR),
                    child: Center(child: Text(
                      isEdit ? 'Save changes' : 'Add appointment',
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)))))),
              ]),
            ],
          )),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
        style: const TextStyle(fontSize: 12, color: RColors.sand500)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 14, color: RColors.sand900),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: RColors.sand400),
          filled: true, fillColor: RColors.sand50,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: RColors.sand200)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: RColors.sand200)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: RColors.teal200, width: 1.5))),
      ),
    ]);
  }
}
