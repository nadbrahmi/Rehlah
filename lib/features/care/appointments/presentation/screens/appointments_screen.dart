// ── Screen 13: Appointments ───────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
import '../../../../../core/utils/models.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final upcoming = MockData.appointments.where((a) => !a.isPast).toList();
    final past = MockData.appointments.where((a) => a.isPast).toList();
    final next = upcoming.first;

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
            // Next appointment hero
            SliverToBoxAdapter(child: HeroCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const HeroPill('Next appointment'),
                RichText(text: TextSpan(
                  style: AppText.statNumber,
                  children: [
                    TextSpan(text: '${next.daysUntil}'),
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
}

