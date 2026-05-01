import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
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
    final past = _session.pastAppointments;
    final next = upcoming.isNotEmpty ? upcoming.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [

          // Header
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => context.go('/'),
                child: Row(children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                    color: AppColors.text2.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text('Home', style: AppText.caption.copyWith(
                    color: AppColors.text2, fontSize: 11)),
                ]),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                RichText(text: TextSpan(style: AppText.displayTitle,
                  children: const [
                    TextSpan(text: 'Appoint', style: TextStyle(fontWeight: FontWeight.w300)),
                    TextSpan(text: 'ments', style: TextStyle(fontWeight: FontWeight.w700)),
                  ])),
                GestureDetector(
                  onTap: () => _showAddEditSheet(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.fullBR),
                    child: Row(children: [
                      const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('Add', style: AppText.caption.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
              ]),
              Text('${upcoming.length} upcoming · ${past.length} past',
                style: AppText.bodySecondary),
            ]),
          )),

          // Next appointment hero
          if (next != null)
            SliverToBoxAdapter(child: HeroCard(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              HeroPill('Next · ${next.daysUntil == 0 ? 'Today' : 'in ${next.daysUntil} days'}'),
              Text(next.title, style: AppText.statNumber.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('EEEE d MMMM').format(next.dateTime)} · '
                '${DateFormat('HH:mm').format(next.dateTime)}',
                style: AppText.bodySecondary),
              if (next.location.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(next.location, style: AppText.bodySecondary),
              ],
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => context.push('/care/appointments/prep'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: AppRadius.fullBR),
                    child: Center(child: Text('Prep report ✨',
                      style: AppText.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500))),
                  ),
                )),
              ]),
            ]))),

          // Empty state
          if (upcoming.isEmpty)
            SliverToBoxAdapter(child: Container(
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.peachLight,
                    borderRadius: AppRadius.mdBR),
                  child: const Center(child: Text('📅',
                    style: TextStyle(fontSize: 26)))),
                const SizedBox(height: 16),
                Text('No upcoming appointments',
                  style: AppText.bodySemibold.copyWith(fontSize: 15)),
                const SizedBox(height: 8),
                Text('Add your next oncology visit so Rehlah can prepare your doctor-ready report.',
                  style: AppText.bodySecondary.copyWith(fontSize: 13),
                  textAlign: TextAlign.center),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showAddEditSheet(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.fullBR,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 12, offset: const Offset(0, 4))]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Add appointment',
                        style: AppText.bodySemibold.copyWith(
                          color: Colors.white, fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
            )),

          // Upcoming list
          if (upcoming.isNotEmpty) ...[
            SliverToBoxAdapter(child: const SectionLabel('Upcoming')),
            ...upcoming.map((a) => SliverToBoxAdapter(
              child: _buildApptRow(a, false))),
          ],

          if (_session.isMonitoring)
            SliverToBoxAdapter(
              child: _buildMonitoringSchedule()),

          // Past
          if (past.isNotEmpty) ...[
            SliverToBoxAdapter(child: const SectionLabel('Past')),
            ...past.map((a) => SliverToBoxAdapter(
              child: Opacity(opacity: 0.5,
                child: _buildApptRow(a, true)))),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _buildApptRow(Appointment apt, bool isPast) {
    return GestureDetector(
      onTap: () => isPast ? null : _showAddEditSheet(apt),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5)),
        child: Row(children: [
          // Date box
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isPast ? AppColors.background2
                  : apt.daysUntil <= 7
                      ? AppColors.primaryLight : AppColors.blueLight,
              borderRadius: AppRadius.smBR),
            child: Column(children: [
              Text('${apt.dateTime.day}',
                style: AppText.sectionHeading.copyWith(
                  fontSize: 16,
                  color: isPast ? AppColors.text3
                      : apt.daysUntil <= 7
                          ? AppColors.primary : AppColors.blue)),
              Text(DateFormat('MMM').format(apt.dateTime).toUpperCase(),
                style: AppText.caption.copyWith(
                  fontSize: 8, fontWeight: FontWeight.w600,
                  color: (isPast ? AppColors.text3
                      : apt.daysUntil <= 7
                          ? AppColors.primary : AppColors.blue)
                      .withOpacity(0.6))),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(apt.title, style: AppText.bodySemibold),
            Text(
              '${apt.doctorName.isNotEmpty ? '${apt.doctorName} · ' : ''}'
              '${DateFormat('HH:mm').format(apt.dateTime)}'
              '${apt.location.isNotEmpty ? ' · ${apt.location}' : ''}',
              style: AppText.caption.copyWith(fontSize: 11)),
          ])),
          const SizedBox(width: 8),
          if (isPast)
            PillBadge(text: 'Done ✓',
              bg: AppColors.tealLight, textColor: AppColors.teal)
          else
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              PillBadge(
                text: apt.daysUntil == 0 ? 'Today!'
                    : apt.daysUntil == 1 ? 'Tomorrow'
                    : '${apt.daysUntil} days',
                bg: apt.daysUntil <= 1
                    ? AppColors.roseLight : AppColors.peachLight,
                textColor: apt.daysUntil <= 1
                    ? AppColors.rose : AppColors.peach,
                borderColor: (apt.daysUntil <= 1
                    ? AppColors.rose : AppColors.peach).withOpacity(0.2)),
              const SizedBox(height: 4),
              Row(children: [
                GestureDetector(
                  onTap: () => _showAddEditSheet(apt),
                  child: Text('Edit',
                    style: AppText.caption.copyWith(
                      color: AppColors.text3, fontSize: 10))),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _confirmDelete(apt),
                  child: Icon(Icons.delete_outline_rounded,
                    size: 13, color: AppColors.text3)),
              ]),
            ]),
        ]),
      ),
    );
  }

  Widget _buildMonitoringSchedule() {
    final scheduleItems = [
      ('mammogram', '🎗️', 'Mammogram', 'Annual · Both breasts'),
      ('mri', '🧲', 'Breast MRI', 'Annual if high risk'),
      ('onco', '👩‍⚕️', 'Oncology review', 'Every 6 months for 5 years'),
      ('gynae', '🩺', 'Gynaecology', 'Annual · Tamoxifen monitoring'),
      ('bone', '🦴', 'Bone density', 'Every 2 years'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SURVEILLANCE SCHEDULE', style: AppText.label),
        const SizedBox(height: 10),
        ...scheduleItems.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Text(s.$2, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.$3, style: AppText.bodySemibold.copyWith(fontSize: 12)),
              Text(s.$4, style: AppText.bodySecondary.copyWith(fontSize: 11)),
            ])),
          ]),
        )),
      ]),
    );
  }

  void _showAddEditSheet(Appointment? existing) {
    final isEdit = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final doctorCtrl = TextEditingController(text: existing?.doctorName ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    DateTime selectedDate = existing?.dateTime ??
        DateTime.now().add(const Duration(days: 7));
    TimeOfDay selectedTime = existing != null
        ? TimeOfDay(hour: existing.dateTime.hour,
            minute: existing.dateTime.minute)
        : const TimeOfDay(hour: 10, minute: 0);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              Text(isEdit ? 'EDIT APPOINTMENT' : 'ADD APPOINTMENT',
                style: AppText.label.copyWith(fontSize: 10)),
              const SizedBox(height: 14),

              // Title
              _field('Appointment title', titleCtrl,
                'e.g. Oncology follow-up'),
              const SizedBox(height: 8),
              _field('Doctor / department', doctorCtrl,
                'e.g. Dr. Sarah Chen'),
              const SizedBox(height: 8),
              _field('Location', locationCtrl,
                'e.g. Oncology Clinic'),
              const SizedBox(height: 12),

              // Date picker
              Text('Date', style: AppText.bodySecondary),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now()
                        .subtract(const Duration(days: 365)),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 730)),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primary)),
                      child: child!),
                  );
                  if (p != null) setS(() => selectedDate = p);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.mdBR,
                    border: Border.all(
                      color: AppColors.primaryMid, width: 0.5)),
                  child: Row(children: [
                    const Text('📅', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEEE, d MMMM yyyy')
                        .format(selectedDate),
                      style: AppText.bodySemibold.copyWith(
                        color: AppColors.primary)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),

              // Time picker
              Text('Time', style: AppText.bodySecondary),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primary)),
                      child: child!),
                  );
                  if (t != null) setS(() => selectedTime = t);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.mdBR,
                    border: Border.all(
                      color: AppColors.primaryMid, width: 0.5)),
                  child: Row(children: [
                    const Text('⏰', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(selectedTime.format(context),
                      style: AppText.bodySemibold.copyWith(
                        color: AppColors.primary)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Save / delete
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
                        color: AppColors.roseLight,
                        borderRadius: AppRadius.mdBR,
                        border: Border.all(
                          color: AppColors.rose.withOpacity(0.2),
                          width: 0.5)),
                      child: Center(child: Text('Delete',
                        style: AppText.caption.copyWith(
                          color: AppColors.rose,
                          fontWeight: FontWeight.w500,
                          fontSize: 13)))))),
                  const SizedBox(width: 8),
                ],
                Expanded(flex: 2, child: GestureDetector(
                  onTap: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final dt = DateTime(
                      selectedDate.year, selectedDate.month,
                      selectedDate.day, selectedTime.hour,
                      selectedTime.minute);
                    final apt = Appointment(
                      id: isEdit
                          ? existing.id
                          : DateTime.now()
                              .millisecondsSinceEpoch.toString(),
                      title: titleCtrl.text.trim(),
                      doctorName: doctorCtrl.text.trim(),
                      location: locationCtrl.text.trim(),
                      dateTime: dt,
                      isPast: dt.isBefore(DateTime.now()),
                    );
                    _session.addAppointment(apt);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.mdBR,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8, offset: const Offset(0, 3))]),
                    child: Center(child: Text(
                      isEdit ? 'Save changes' : 'Add appointment',
                      style: const TextStyle(fontFamily: 'Inter',
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: Colors.white)))))),
              ]),
            ],
          )),
        ),
      ),
    );
  }

  void _confirmDelete(Appointment apt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete appointment?',
          style: AppText.sectionHeading.copyWith(fontSize: 15)),
        content: Text(
          '${apt.title} on ${DateFormat('d MMM').format(apt.dateTime)} will be removed.',
          style: AppText.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
              style: TextStyle(color: AppColors.text2))),
          TextButton(
            onPressed: () {
              _session.removeAppointment(apt.id);
              Navigator.pop(context);
            },
            child: Text('Delete',
              style: TextStyle(
                color: AppColors.rose,
                fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.bodySecondary),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        style: const TextStyle(fontFamily: 'Inter',
          fontSize: 14, color: AppColors.text1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.text3),
          filled: true, fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.border, width: 0.5)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.border, width: 0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.primaryMid, width: 1.5))),
      ),
    ]);
  }
}
