// ── Screen 13: Appointments ───────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
import '../../../../../core/utils/models.dart';
import '../../../../../core/utils/user_session.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final isMonitoring = session.isMonitoring;

    // Use phase-appropriate appointments
    final allAppointments = isMonitoring
        ? _monitoringAppointments()
        : MockData.appointments;

    final upcoming = allAppointments.where((a) => !a.isPast).toList();
    final past = allAppointments.where((a) => a.isPast).toList();
    final next = upcoming.isNotEmpty ? upcoming.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
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
                RichText(text: TextSpan(style: AppText.displayTitle, children: const [
                  TextSpan(text: '', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: 'Appointments'),
                ])),
                Text('${upcoming.length} upcoming · ${past.length} past',
                  style: AppText.bodySecondary),
              ]),
            )),

            // Monitoring controls reminder
            if (isMonitoring) SliverToBoxAdapter(child: _buildMonitoringSchedule(session)),

            // Next appointment hero
            if (next != null) SliverToBoxAdapter(child: HeroCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const HeroPill('Next appointment'),
                RichText(text: TextSpan(
                  style: AppText.statNumber,
                  children: [
                    TextSpan(text: '${next!.daysUntil}'),
                    TextSpan(text: ' days away',
                      style: AppText.statNumber.copyWith(
                        fontSize: 13, color: AppColors.text1.withOpacity(0.4))),
                  ],
                )),
                const SizedBox(height: 5),
                Text(next.title, style: AppText.sectionHeading),
                Text('${next.doctorName} · ${DateFormat('EEE d MMM · HH:mm').format(next.dateTime)}',
                  style: AppText.bodySecondary),
                const SizedBox(height: 13),
                Row(children: [
                  Expanded(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: AppRadius.mdBR,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7), width: 0.5),
                    ),
                    child: Center(child: Text('Add to calendar',
                      style: AppText.caption.copyWith(
                        color: AppColors.text1, fontWeight: FontWeight.w500))),
                  )),
                  const SizedBox(width: 6),
                  Expanded(child: GestureDetector(
                    onTap: () => context.push('/care/appointments/prep'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius: AppRadius.mdBR,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.18), width: 0.5),
                      ),
                      child: Center(child: Text('Prep report ✨',
                        style: AppText.caption.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w500))),
                    ),
                  )),
                ]),
              ]),
            )),
            SliverToBoxAdapter(child: const SectionLabel('Upcoming')),
            ...upcoming.map((a) => SliverToBoxAdapter(
              child: _buildApptRow(context, a, false))),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Text('+ Add appointment',
                style: AppText.bodySemibold.copyWith(
                  color: AppColors.primary, fontSize: 13)),
            )),
            SliverToBoxAdapter(child: const SectionLabel('Past')),
            ...past.map((a) => SliverToBoxAdapter(
              child: Opacity(opacity: 0.4,
                child: _buildApptRow(context, a, true)))),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildApptRow(BuildContext context, Appointment apt, bool isPast) {
    return GestureDetector(
      onTap: isPast ? null : () => context.push('/care/appointments/prep'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isPast ? AppColors.background2
                  : apt.daysUntil <= 7 ? AppColors.primaryLight : AppColors.blueLight,
              borderRadius: AppRadius.smBR,
            ),
            child: Column(children: [
              Text('${apt.dateTime.day}',
                style: AppText.sectionHeading.copyWith(
                  fontSize: 16,
                  color: isPast ? AppColors.text3
                      : apt.daysUntil <= 7 ? AppColors.primary : AppColors.blue,
                )),
              Text(DateFormat('MMM').format(apt.dateTime).toUpperCase(),
                style: AppText.caption.copyWith(
                  fontSize: 8, letterSpacing: 0.05, fontWeight: FontWeight.w600,
                  color: (isPast ? AppColors.text3
                      : apt.daysUntil <= 7 ? AppColors.primary : AppColors.blue)
                      .withOpacity(0.5),
                )),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(apt.title, style: AppText.bodySemibold),
            Text(apt.location.isNotEmpty
                ? '${apt.doctorName} · ${DateFormat('HH:mm').format(apt.dateTime)}'
                : apt.location,
              style: AppText.caption),
          ])),
          if (isPast)
            PillBadge(text: 'Done ✓',
              bg: AppColors.tealLight, textColor: AppColors.teal)
          else
            PillBadge(
              text: '${apt.daysUntil} days',
              bg: AppColors.peachLight, textColor: AppColors.peach,
              borderColor: AppColors.peach.withOpacity(0.2)),
        ]),
      ),
    );
  }

  List<Appointment> _monitoringAppointments() {
    final now = DateTime.now();
    return [
      Appointment(
        id: 'mon1', title: 'Oncology surveillance review',
        doctorName: 'Dr. Sarah Chen', location: 'Oncology Clinic',
        dateTime: DateTime(now.year, now.month + 1, 15, 10, 30),
      ),
      Appointment(
        id: 'mon2', title: 'Annual mammogram',
        doctorName: 'Radiology Dept', location: 'Breast Imaging Centre',
        dateTime: DateTime(now.year, now.month + 2, 8, 9, 0),
      ),
      Appointment(
        id: 'mon3', title: 'Gynecology review',
        doctorName: 'Dr. Layla Hassan', location: 'Outpatient Clinic',
        dateTime: DateTime(now.year, now.month + 3, 20, 11, 0),
      ),
      Appointment(
        id: 'mon4', title: 'Oncology surveillance review',
        doctorName: 'Dr. Sarah Chen', location: 'Oncology Clinic',
        dateTime: DateTime(now.year - 1, now.month, 15, 10, 30),
        isPast: true,
      ),
      Appointment(
        id: 'mon5', title: 'Breast MRI',
        doctorName: 'Radiology Dept', location: 'MRI Suite',
        dateTime: DateTime(now.year - 1, now.month + 2, 8, 9, 0),
        isPast: true,
      ),
    ];
  }

  Widget _buildMonitoringSchedule(UserSession session) {
    final scheduleItems = [
      ('mammogram', '🎗️', 'Mammogram', 'Annual · Both breasts'),
      ('mri', '🧲', 'Breast MRI', 'Annual if high risk'),
      ('oncology', '👨‍⚕️', 'Oncology review', 'Every 3–6 months'),
      ('gynecology', '👩‍⚕️', 'Gynecology review', 'Annual · Important on Tamoxifen'),
      ('dexa', '🦴', 'Bone density (DEXA)', 'Every 1–2 years on AI'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.05),
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.teal.withOpacity(0.2), width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('MONITORING SCHEDULE',
            style: AppText.label.copyWith(fontSize: 10, color: AppColors.teal)),
          Text('Log a control →',
            style: AppText.caption.copyWith(
              color: AppColors.teal, fontWeight: FontWeight.w500, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        ...scheduleItems.map((item) {
          final last = session.lastControlOfType(item.$1);
          final overdue = last?.nextScheduled != null &&
              last!.nextScheduled!.isBefore(DateTime.now());
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Text(item.$2, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.$3, style: AppText.bodySemibold.copyWith(fontSize: 12)),
                  Text(item.$4, style: AppText.caption.copyWith(fontSize: 10)),
                ],
              )),
              last != null
                  ? Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(DateFormat('MMM yyyy').format(last.date),
                        style: AppText.caption.copyWith(fontSize: 10)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: overdue
                              ? AppColors.roseLight : AppColors.tealLight,
                          borderRadius: AppRadius.fullBR),
                        child: Text(overdue ? 'Due' : '✓',
                          style: AppText.caption.copyWith(
                            fontSize: 9,
                            color: overdue ? AppColors.rose : AppColors.teal))),
                    ])
                  : Text('Not logged',
                      style: AppText.caption.copyWith(
                        color: AppColors.text3, fontSize: 10)),
            ]),
          );
        }),
      ]),
    );
  }
}

