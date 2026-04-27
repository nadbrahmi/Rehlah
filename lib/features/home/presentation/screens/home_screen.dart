import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockData.profile;
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE · d MMMM').format(today);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // background orb
          Positioned(
            top: -60, right: -40,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.11), Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(profile, dateStr)),
                SliverToBoxAdapter(child: _buildHeroCard(context)),
                SliverToBoxAdapter(child: _buildNadirCard()),
                SliverToBoxAdapter(child: _buildMoodRecap()),
                SliverToBoxAdapter(child: _buildMissionCard()),
                SliverToBoxAdapter(child: const SectionLabel('Quick access')),
                SliverToBoxAdapter(child: _buildQuickTiles(context)),
                SliverToBoxAdapter(child: _buildNextAppointment(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProfile profile, String dateStr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr.toUpperCase(), style: AppText.label),
          const SizedBox(height: 3),
          RichText(
            text: TextSpan(
              style: AppText.displayTitle,
              children: [
                const TextSpan(text: 'Good morning,\n'),
                TextSpan(text: profile.name,
                  style: AppText.displayTitle.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('Take it one moment at a time.', style: AppText.bodySecondary),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return HeroCard(
      onTap: () => context.push('/checkin'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroPill('Daily check-in'),
          Text('How are you\nfeeling today?',
            style: AppText.sectionHeading.copyWith(
              fontSize: 17, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppText.bodySecondary,
              children: [
                TextSpan(text: '6 days in a row. ',
                  style: AppText.bodySecondary.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w500)),
                const TextSpan(text: 'Your team sees every entry.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: AppRadius.fullBR,
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 0.5),
            ),
            child: Text('Begin check-in →',
              style: AppText.bodySemibold.copyWith(
                color: AppColors.primaryDark, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNadirCard() {
    if (!MockData.profile.isNadirWindow) return const SizedBox.shrink();
    return const NadirCard(
      title: '⚠ Nadir window — Days 8–14',
      body: 'Your immune system is at its lowest. Avoid crowds and monitor your temperature.',
    );
  }

  Widget _buildMoodRecap() {
    return SurfaceCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LAST 7 DAYS', style: AppText.label),
              Text('↑ Improving',
                style: AppText.body.copyWith(
                  color: AppColors.teal, fontWeight: FontWeight.w500, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: MockData.moodHistory.map((e) {
              final isToday = e.day == 'Today';
              return Expanded(
                child: Column(
                  children: [
                    Text(e.mood.emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(e.day,
                      style: AppText.caption.copyWith(
                        fontSize: 9,
                        color: isToday ? AppColors.primary : AppColors.text3,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              borderRadius: AppRadius.smBR,
              gradient: LinearGradient(colors: [
                AppColors.peach.withOpacity(0.12),
                AppColors.gold.withOpacity(0.08),
              ]),
              border: Border.all(color: AppColors.peach.withOpacity(0.18), width: 0.5),
            ),
            child: const Center(child: Text('🌱', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your care today', style: AppText.bodySemibold),
                const SizedBox(height: 1),
                Text('2 of 3 meds · 14-day streak', style: AppText.bodySecondary),
                const SizedBox(height: 7),
                AppProgressBar(
                  value: 2 / 3,
                  foreground: AppColors.peach,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTiles(BuildContext context) {
    final tiles = [
      _TileData('Ask AI', 'Any question', Icons.auto_awesome_rounded,
          AppColors.primaryLight, AppColors.primary, '/ai-chat'),
      _TileData('Appointments', 'Mon 28 Apr', Icons.calendar_month_rounded,
          AppColors.peachLight, AppColors.peach, '/care/appointments'),
      _TileData('Medications', '2 of 3 done', Icons.medication_rounded,
          AppColors.tealLight, AppColors.teal, '/care/medications'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: tiles.map((t) => Expanded(
          child: GestureDetector(
            onTap: () => context.push(t.route),
            child: Container(
              margin: EdgeInsets.only(
                right: t == tiles.last ? 0 : 7),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: t.iconBg, borderRadius: AppRadius.smBR),
                    child: Icon(t.icon, color: t.iconColor, size: 15),
                  ),
                  const SizedBox(height: 7),
                  Text(t.label, style: AppText.bodySemibold.copyWith(fontSize: 11)),
                  Text(t.sublabel, style: AppText.caption.copyWith(fontSize: 10)),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildNextAppointment(BuildContext context) {
    final apt = MockData.appointments.first;
    return GestureDetector(
      onTap: () => context.push('/care/appointments'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.smBR,
              ),
              child: Column(
                children: [
                  Text('${apt.dateTime.day}',
                    style: AppText.sectionHeading.copyWith(
                      color: AppColors.primary, fontSize: 16)),
                  Text(DateFormat('MMM').format(apt.dateTime).toUpperCase(),
                    style: AppText.caption.copyWith(
                      color: AppColors.primary.withOpacity(0.5), fontSize: 8,
                      fontWeight: FontWeight.w600, letterSpacing: 0.05)),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(apt.title, style: AppText.bodySemibold),
                  Text('${apt.doctorName} · ${DateFormat('HH:mm').format(apt.dateTime)}',
                    style: AppText.caption),
                ],
              ),
            ),
            PillBadge(
              text: '${apt.daysUntil} days',
              bg: AppColors.peachLight,
              textColor: AppColors.peach,
              borderColor: AppColors.peach.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileData {
  final String label, sublabel, route;
  final IconData icon;
  final Color iconBg, iconColor;
  const _TileData(this.label, this.sublabel, this.icon,
      this.iconBg, this.iconColor, this.route);
}
