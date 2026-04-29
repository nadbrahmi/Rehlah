import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/models.dart';
import '../../../../core/utils/user_session.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE · d MMMM').format(today);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        Positioned(top: -60, right: -40,
          child: Container(width: 220, height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withOpacity(0.11), Colors.transparent])))),
        SafeArea(
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, session, dateStr)),
            SliverToBoxAdapter(child: _buildHeroCard(context, session)),
            if (session.isNadirWindow)
              SliverToBoxAdapter(child: _buildNadirCard(session)),
            if (session.isNadirApproaching && !session.isNadirWindow)
              SliverToBoxAdapter(child: _buildNadirApproachingCard()),
            SliverToBoxAdapter(child: _buildPhaseCard(session)),
            SliverToBoxAdapter(child: _buildMoodRecap(session)),
            SliverToBoxAdapter(child: const SectionLabel('Quick access')),
            SliverToBoxAdapter(child: _buildQuickTiles(context, session)),
            SliverToBoxAdapter(child: _buildNextAppointment(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ]),
        ),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, UserSession session, String dateStr) {
    final name = session.displayName;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dateStr.toUpperCase(), style: AppText.label),
          const SizedBox(height: 3),
          RichText(text: TextSpan(
            style: AppText.displayTitle,
            children: [
              TextSpan(text: '${session.greeting},\n'),
              TextSpan(text: name,
                style: AppText.displayTitle.copyWith(fontWeight: FontWeight.w700)),
            ],
          )),
          const SizedBox(height: 4),
          Text('Take it one moment at a time.', style: AppText.bodySecondary),
        ])),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryMid, width: 0.5)),
            child: Center(child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 15,
                fontWeight: FontWeight.w600, color: AppColors.primary))),
          ),
        ),
      ]),
    );
  }

  // ── Check-in hero card ────────────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context, UserSession session) {
    final hasCheckedIn = session.lastCheckIn != null &&
        session.lastCheckIn!.day == DateTime.now().day;
    return HeroCard(
      onTap: () => context.push('/checkin'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HeroPill(hasCheckedIn ? 'Check-in done today ✓' : 'Daily check-in'),
        Text('How are you\nfeeling today?',
          style: AppText.sectionHeading.copyWith(
            fontSize: 17, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text(
          '${session.protocol.name} · Cycle ${session.currentCycle} · Day ${session.dayInCycle}',
          style: AppText.bodySecondary.copyWith(
            color: AppColors.primary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: AppRadius.fullBR,
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 0.5)),
          child: Text(hasCheckedIn ? 'View today\'s check-in →' : 'Begin check-in →',
            style: AppText.bodySemibold.copyWith(
              color: AppColors.primaryDark, fontSize: 12)),
        ),
      ]),
    );
  }

  // ── Nadir cards ───────────────────────────────────────────────────────────
  Widget _buildNadirCard(UserSession session) {
    return NadirCard(
      title: '⚠ Nadir window — Day ${session.dayInCycle}',
      body: 'Your immune system is at its lowest. Avoid crowds, monitor temperature twice daily. Call your team if fever reaches 38°C.',
    );
  }

  Widget _buildNadirApproachingCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 9, 14, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.07),
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.gold.withOpacity(0.25), width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⚡', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nadir window approaching',
            style: AppText.bodySemibold.copyWith(color: AppColors.gold)),
          const SizedBox(height: 3),
          Text('Your WBC count will reach its lowest in 1–2 days. Start monitoring your temperature twice daily.',
            style: AppText.bodySecondary),
        ])),
      ]),
    );
  }

  // ── Phase summary card ────────────────────────────────────────────────────
  Widget _buildPhaseCard(UserSession session) {
    final phase = session.currentPhase;
    final progress = session.currentCycle / session.totalCycles;
    final progressPct = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            borderRadius: AppRadius.smBR,
            gradient: LinearGradient(colors: [
              AppColors.peach.withOpacity(0.12),
              AppColors.gold.withOpacity(0.08)]),
            border: Border.all(
              color: AppColors.peach.withOpacity(0.18), width: 0.5)),
          child: const Center(child: Text('🌱',
            style: TextStyle(fontSize: 18)))),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(phase.name, style: AppText.bodySemibold),
          const SizedBox(height: 1),
          Text('${session.protocol.name} · Cycle ${session.currentCycle} of ${session.totalCycles} · $progressPct% complete',
            style: AppText.bodySecondary),
          const SizedBox(height: 7),
          AppProgressBar(value: progress, foreground: AppColors.peach),
        ])),
      ]),
    );
  }

  // ── Mood recap ────────────────────────────────────────────────────────────
  Widget _buildMoodRecap(UserSession session) {
    // Show today's mood if checked in, otherwise show placeholder strip
    final hasCheckedIn = session.lastCheckIn != null &&
        session.lastCheckIn!.day == DateTime.now().day;
    final todayMood = session.moodEmoji.isNotEmpty ? session.moodEmoji : '😐';

    // Generate a 7-day visual — today real, others placeholder
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Today'];
    final emojis = ['😐','🙂','😔','😐','🙂','😊', hasCheckedIn ? todayMood : '?'];

    return SurfaceCard(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LAST 7 DAYS', style: AppText.label),
          if (hasCheckedIn)
            Text('Checked in today ✓',
              style: AppText.body.copyWith(
                color: AppColors.teal, fontWeight: FontWeight.w500,
                fontSize: 12))
          else
            GestureDetector(
              onTap: null,
              child: Text('Not checked in yet',
                style: AppText.body.copyWith(
                  color: AppColors.text3, fontSize: 12))),
        ]),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isToday = i == 6;
            return Expanded(child: Column(children: [
              Text(
                isToday && !hasCheckedIn ? '·' : emojis[i],
                style: TextStyle(
                  fontSize: isToday && !hasCheckedIn ? 20 : 15,
                  color: isToday && !hasCheckedIn
                      ? AppColors.text3 : null)),
              const SizedBox(height: 2),
              Text(days[i], style: AppText.caption.copyWith(
                fontSize: 9,
                color: isToday ? AppColors.primary : AppColors.text3,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400)),
            ]));
          }),
        ),
      ]),
    );
  }

  // ── Quick tiles ───────────────────────────────────────────────────────────
  Widget _buildQuickTiles(BuildContext context, UserSession session) {
    final phase = session.currentPhase;
    final tiles = [
      _TileData('Ask AI', 'Any question', Icons.auto_awesome_rounded,
          AppColors.primaryLight, AppColors.primary, '/ai-chat'),
      _TileData('Appointments', 'Next visit', Icons.calendar_month_rounded,
          AppColors.peachLight, AppColors.peach, '/care/appointments'),
      _TileData('Medications', 'Track doses', Icons.medication_rounded,
          AppColors.tealLight, AppColors.teal, '/care/medications'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: tiles.map((t) => Expanded(
          child: GestureDetector(
            onTap: () => context.push(t.route),
            child: Container(
              margin: EdgeInsets.only(right: t == tiles.last ? 0 : 7),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: t.iconBg, borderRadius: AppRadius.smBR),
                  child: Icon(t.icon, color: t.iconColor, size: 15)),
                const SizedBox(height: 7),
                Text(t.label, style: AppText.bodySemibold.copyWith(fontSize: 11)),
                Text(t.sublabel, style: AppText.caption.copyWith(fontSize: 10)),
              ]),
            ),
          ),
        )).toList(),
      ),
    );
  }

  // ── Next appointment ──────────────────────────────────────────────────────
  Widget _buildNextAppointment(BuildContext context) {
    // Use session data if available, otherwise show placeholder
    final session = UserSession();
    final apt = MockData.appointments.first;

    return GestureDetector(
      onTap: () => context.push('/care/appointments'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5)),
        child: Row(children: [
          Container(
            width: 38,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.smBR),
            child: Column(children: [
              Text('${apt.dateTime.day}',
                style: AppText.sectionHeading.copyWith(
                  color: AppColors.primary, fontSize: 16)),
              Text(DateFormat('MMM').format(apt.dateTime).toUpperCase(),
                style: AppText.caption.copyWith(
                  color: AppColors.primary.withOpacity(0.5), fontSize: 8,
                  fontWeight: FontWeight.w600, letterSpacing: 0.05)),
            ]),
          ),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(apt.title, style: AppText.bodySemibold),
            Text('${apt.doctorName} · ${DateFormat('HH:mm').format(apt.dateTime)}',
              style: AppText.caption),
          ])),
          PillBadge(
            text: '${apt.daysUntil} days',
            bg: AppColors.peachLight,
            textColor: AppColors.peach,
            borderColor: AppColors.peach.withOpacity(0.2)),
        ]),
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
