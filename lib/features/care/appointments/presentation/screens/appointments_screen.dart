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

// ── Screen 14: Prep Report ────────────────────────────────────────────────────
class PrepReportScreen extends StatelessWidget {
  const PrepReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final next = MockData.appointments.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Row(children: [
                    Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                      color: AppColors.text2.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text('Appointments', style: AppText.caption.copyWith(
                      color: AppColors.text2)),
                  ]),
                ),
                const SizedBox(height: 12),
                RichText(text: TextSpan(style: AppText.displayTitle, children: const [
                  TextSpan(text: '', style: TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: 'Doctor-ready '),
                  TextSpan(text: 'report',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                ])),
              ]),
            )),
            SliverToBoxAdapter(child: HeroCard(
              gradientColors: const [
                Color(0xFFC8D8F0), Color(0xFFCCC0EC), Color(0xFFC0D0E8)],
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 9),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.18),
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(
                      color: AppColors.blue.withOpacity(0.28), width: 0.5),
                  ),
                  child: Text('✦ AI-generated · ${DateFormat('d MMM').format(DateTime.now())}',
                    style: AppText.caption.copyWith(
                      color: const Color(0xFF245080),
                      fontWeight: FontWeight.w500, fontSize: 11)),
                ),
                Text('Oncology · Dr. Sarah Chen · ${DateFormat('d MMM').format(next.dateTime)}',
                  style: AppText.bodySemibold),
                const SizedBox(height: 2),
                Text('Covering the last 14 days', style: AppText.bodySecondary),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.14),
                      borderRadius: AppRadius.mdBR,
                      border: Border.all(color: AppColors.blue.withOpacity(0.22), width: 0.5),
                    ),
                    child: Center(child: Text('Share with doctor',
                      style: AppText.caption.copyWith(
                        color: AppColors.blue, fontWeight: FontWeight.w500))),
                  )),
                  const SizedBox(width: 6),
                  Expanded(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: AppRadius.mdBR,
                      border: Border.all(color: Colors.white.withOpacity(0.7), width: 0.5),
                    ),
                    child: Center(child: Text('Save PDF',
                      style: AppText.caption.copyWith(
                        color: AppColors.text1, fontWeight: FontWeight.w500))),
                  )),
                ]),
              ]),
            )),
            SliverToBoxAdapter(child: SurfaceCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight, borderRadius: AppRadius.smBR),
                    child: const Center(child: Text('😊',
                      style: TextStyle(fontSize: 14)))),
                  const SizedBox(width: 8),
                  Text('How I\'ve been feeling', style: AppText.bodySemibold),
                ]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final e in [('W1','😔'),('W2','😐'),('W3','😐'),
                        ('W4','🙂'),('W5','😊'),('W6','🙂'),('W7','🙂')])
                      Column(children: [
                        Text(e.$2, style: const TextStyle(fontSize: 14)),
                        Text(e.$1, style: AppText.caption.copyWith(fontSize: 9)),
                      ]),
                  ],
                ),
                Divider(color: AppColors.border, height: 16, thickness: 0.5),
                RichText(text: TextSpan(
                  style: AppText.bodySecondary,
                  children: [
                    const TextSpan(text: 'Avg mood '),
                    TextSpan(text: '3.8/5 ',
                      style: TextStyle(color: AppColors.text1,
                        fontWeight: FontWeight.w500)),
                    const TextSpan(text: '· Improving week-on-week.'),
                  ],
                )),
              ]),
            )),
            SliverToBoxAdapter(child: SurfaceCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.blueLight, borderRadius: AppRadius.smBR),
                    child: const Center(child: Text('💬',
                      style: TextStyle(fontSize: 14)))),
                  const SizedBox(width: 8),
                  Text('AI talking points for doctor', style: AppText.bodySemibold),
                ]),
                const SizedBox(height: 9),
                ...[
                  (AppColors.peach, 'Hemoglobin 10.2', '— ask about iron supplements'),
                  (AppColors.blue, 'Fatigue most days', '— impact on daily activities'),
                  (AppColors.teal, 'Adherence 82%', '— 1 missed dose Apr 14'),
                  (AppColors.primary, 'CA15-3 trending down', '— positive sign?'),
                ].map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 5, height: 5, margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(color: t.$1, shape: BoxShape.circle)),
                      const SizedBox(width: 7),
                      Expanded(child: RichText(text: TextSpan(
                        style: AppText.bodySecondary,
                        children: [
                          TextSpan(text: t.$2,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500, color: AppColors.text1)),
                          TextSpan(text: t.$3),
                        ],
                      ))),
                    ],
                  ),
                )),
              ]),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
