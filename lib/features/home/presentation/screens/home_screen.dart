import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/models.dart';
import '../../../../core/utils/user_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    UserSession().addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    UserSession().removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  // Called every time this route is pushed onto the stack
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE · d MMMM').format(today);
    final isInChemo = session.treatmentPhase == 'In chemotherapy';
    final isMonitoring = session.isMonitoring;

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
            // Monitoring cards
            if (isMonitoring) ...[
              if (session.daysCancerFree > 0)
                SliverToBoxAdapter(child: _buildCancerFreeCard(session)),
              if (session.isScanxietyPeriod)
                SliverToBoxAdapter(child: _buildScanxietyCard(session)),
              SliverToBoxAdapter(child: _buildLastControlsCard(session)),
              SliverToBoxAdapter(child: _buildCycleTrackerCard(context, session)),
              if (session.menstrualStatus == 'regular' &&
                  session.nextOptimalWindowStart != null)
                SliverToBoxAdapter(child: _buildScanWindowCard(session)),
            ],
            // Chemo-specific cards
            if (isInChemo && session.isNadirWindow)
              SliverToBoxAdapter(child: _buildNadirCard(session)),
            if (isInChemo && session.isNadirApproaching && !session.isNadirWindow)
              SliverToBoxAdapter(child: _buildNadirApproachingCard()),
            // Phase card
            SliverToBoxAdapter(child: isInChemo
                ? _buildPhaseCard(session)
                : isMonitoring
                    ? const SizedBox.shrink()
                    : _buildJourneyCard(session)),
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
    final hasCheckedIn = session.checkedInToday;
    final streak = session.streak;
    final isInChemo = session.treatmentPhase == 'In chemotherapy';

    return HeroCard(
      onTap: () => context.push('/checkin'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HeroPill(hasCheckedIn ? 'Check-in done today ✓' : 'Daily check-in'),
        Text('How are you\nfeeling today?',
          style: AppText.sectionHeading.copyWith(
            fontSize: 17, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        RichText(text: TextSpan(
          style: AppText.bodySecondary,
          children: [
            if (streak > 1)
              TextSpan(text: '🔥 $streak day streak · ',
                style: AppText.bodySecondary.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w500)),
            if (isInChemo)
              TextSpan(text:
                '${session.protocol.name} · Cycle ${session.currentCycle} · Day ${session.dayInCycle}')
            else
              TextSpan(text: session.treatmentPhase),
          ],
        )),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: AppRadius.fullBR,
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 0.5)),
          child: Text(
            hasCheckedIn ? 'View today\'s check-in →' : 'Begin check-in →',
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

  // ── Cancer-free counter card ───────────────────────────────────────────────
  Widget _buildCancerFreeCard(UserSession session) {
    final days = session.daysCancerFree;
    final years = days ~/ 365;
    final months = (days % 365) ~/ 30;
    String label;
    if (years > 0) {
      label = months > 0
          ? '$years year${years > 1 ? 's' : ''}, $months month${months > 1 ? 's' : ''} cancer-free'
          : '$years year${years > 1 ? 's' : ''} cancer-free';
    } else if (months > 0) {
      label = '$months month${months > 1 ? 's' : ''} cancer-free';
    } else {
      label = '$days days cancer-free';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.teal.withOpacity(0.12),
            AppColors.primary.withOpacity(0.08)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: AppColors.teal.withOpacity(0.25), width: 0.5)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.15),
            shape: BoxShape.circle),
          child: const Center(child: Text('🎗️',
            style: TextStyle(fontSize: 22)))),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.bodySemibold.copyWith(
              color: AppColors.teal, fontSize: 14)),
            Text('Every day is a milestone. Keep going.',
              style: AppText.bodySecondary.copyWith(fontSize: 12)),
          ],
        )),
        Text('$days', style: AppText.statNumber.copyWith(
          color: AppColors.teal.withOpacity(0.4), fontSize: 20)),
      ]),
    );
  }

  // ── Scanxiety card ────────────────────────────────────────────────────────
  Widget _buildScanxietyCard(UserSession session) {
    final next = session.nextControl;
    final days = next?.nextScheduled?.difference(DateTime.now()).inDays ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.07),
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: AppColors.gold.withOpacity(0.25), width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⚡', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${next?.typeLabel ?? 'Scan'} in $days day${days != 1 ? 's' : ''}',
              style: AppText.bodySemibold.copyWith(color: AppColors.gold)),
            const SizedBox(height: 3),
            Text(
              'Scanxiety is normal. Talking to someone who\'s been through it helps.',
              style: AppText.bodySecondary.copyWith(fontSize: 12, height: 1.5)),
          ],
        )),
      ]),
    );
  }

  // ── Last controls card ────────────────────────────────────────────────────
  Widget _buildLastControlsCard(UserSession session) {
    final types = ['mammogram', 'mri', 'oncology', 'gynecology'];
    final hasAny = types.any((t) => session.lastControlOfType(t) != null);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LAST CONTROLS', style: AppText.label.copyWith(fontSize: 10)),
          Text('→ Add control',
            style: AppText.caption.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w500,
              fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        if (!hasAny)
          Text('No controls logged yet. Add your first one.',
            style: AppText.bodySecondary.copyWith(
              fontStyle: FontStyle.italic, fontSize: 12))
        else
          ...types.map((type) {
            final last = session.lastControlOfType(type);
            if (last == null) return const SizedBox.shrink();
            final overdue = last.nextScheduled != null &&
                last.nextScheduled!.isBefore(DateTime.now());
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(children: [
                Text(last.typeEmoji,
                  style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(child: Text(last.typeLabel,
                  style: AppText.bodySemibold.copyWith(fontSize: 12))),
                Text(DateFormat('MMM yyyy').format(last.date),
                  style: AppText.caption.copyWith(fontSize: 11)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: overdue
                        ? AppColors.roseLight
                        : AppColors.tealLight,
                    borderRadius: AppRadius.fullBR),
                  child: Text(
                    overdue ? 'Overdue' : last.resultLabel,
                    style: AppText.caption.copyWith(
                      fontSize: 9,
                      color: overdue ? AppColors.rose : AppColors.teal))),
              ]),
            );
          }),
      ]),
    );
  }

  // ── Cycle tracker card ────────────────────────────────────────────────────
  Widget _buildCycleTrackerCard(BuildContext context, UserSession session) {
    final hasData = session.lastPeriodDate != null;
    DateTime? nextPeriod;
    if (hasData) {
      nextPeriod = session.lastPeriodDate!.add(
        Duration(days: session.cycleLength));
      while (nextPeriod!.isBefore(DateTime.now())) {
        nextPeriod = nextPeriod.add(Duration(days: session.cycleLength));
      }
    }
    final daysUntil = nextPeriod != null
        ? nextPeriod.difference(DateTime.now()).inDays : null;

    return GestureDetector(
      onTap: () => context.push('/monitoring/cycle-tracker'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.rose.withOpacity(0.10),
              borderRadius: AppRadius.smBR),
            child: const Center(child: Text('🌸',
              style: TextStyle(fontSize: 18)))),
          const SizedBox(width: 11),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cycle & scan tracker',
                style: AppText.bodySemibold),
              Text(
                hasData && daysUntil != null
                    ? 'Next period in $daysUntil days · Tap to view scan calendar'
                    : 'Track your cycle · Plan your scans',
                style: AppText.bodySecondary.copyWith(fontSize: 12)),
            ],
          )),
          Icon(Icons.chevron_right_rounded, size: 18,
            color: AppColors.text3),
        ]),
      ),
    );
  }

  // ── Scan window card ──────────────────────────────────────────────────────
  Widget _buildScanWindowCard(UserSession session) {
    final start = session.nextOptimalWindowStart!;
    final end = session.nextOptimalWindowEnd!;
    final now = DateTime.now();
    final isNow = start.isBefore(now) && end.isAfter(now);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isNow
            ? AppColors.teal.withOpacity(0.07)
            : AppColors.primary.withOpacity(0.05),
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: isNow
              ? AppColors.teal.withOpacity(0.25)
              : AppColors.primaryMid,
          width: 0.5)),
      child: Row(children: [
        Text(isNow ? '✅' : '📅',
          style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNow
                  ? 'Optimal scan window — NOW'
                  : 'Next optimal scan window',
              style: AppText.bodySemibold.copyWith(
                color: isNow ? AppColors.teal : AppColors.primary,
                fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM').format(end)} · Days 7–14 of cycle',
              style: AppText.bodySecondary.copyWith(fontSize: 12)),
            const SizedBox(height: 2),
            Text('Plan your MRI / Mammogram appointment during this window',
              style: AppText.caption.copyWith(
                color: AppColors.text3, fontSize: 10)),
          ],
        )),
      ]),
    );
  }

  // ── Journey card (non-chemo patients) ────────────────────────────────────
  Widget _buildJourneyCard(UserSession session) {
    final phaseEmojis = {
      'Just diagnosed': '🌱',
      'Awaiting treatment plan': '📋',
      'In radiotherapy': '⚡',
      'Post-surgery recovery': '🌿',
      'Monitoring / surveillance': '🔭',
    };
    final phaseMessages = {
      'Just diagnosed':
          'You\'ve taken the first and hardest step. Your care team is building your plan.',
      'Awaiting treatment plan':
          'Your oncologist is reviewing your case. Use this time to ask questions and prepare.',
      'In radiotherapy':
          'Radiotherapy is a daily commitment. Rest well between sessions.',
      'Post-surgery recovery':
          'Your body is healing. Rest, nutrition, and gentle movement all support recovery.',
      'Monitoring / surveillance':
          'Regular monitoring keeps you and your team informed. Each clear scan is a win.',
    };
    final emoji = phaseEmojis[session.treatmentPhase] ?? '💜';
    final message = phaseMessages[session.treatmentPhase] ??
        'You\'re on your journey. We\'re here every step of the way.';

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.smBR),
          child: Center(child: Text(emoji,
            style: const TextStyle(fontSize: 18)))),
        const SizedBox(width: 11),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.treatmentPhase,
              style: AppText.bodySemibold),
            const SizedBox(height: 3),
            Text(message,
              style: AppText.bodySecondary.copyWith(height: 1.5)),
          ],
        )),
      ]),
    );
  }

  // ── Phase card (chemo patients only) ─────────────────────────────────────
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
    final days = session.last7Days;
    final hasAnyData = days.any((d) => d.hasData);
    final streak = session.streak;

    return SurfaceCard(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LAST 7 DAYS', style: AppText.label),
          if (streak > 1)
            Text('🔥 $streak day streak',
              style: AppText.body.copyWith(
                color: AppColors.teal, fontWeight: FontWeight.w500,
                fontSize: 12))
          else if (session.checkedInToday)
            Text('✓ Checked in today',
              style: AppText.body.copyWith(
                color: AppColors.teal, fontWeight: FontWeight.w500,
                fontSize: 12))
          else
            Text('Not yet today',
              style: AppText.body.copyWith(
                color: AppColors.text3, fontSize: 12)),
        ]),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) {
            final isToday = d.label == 'Today';
            return Expanded(child: Column(children: [
              d.hasData
                  ? Text(d.emoji,
                      style: const TextStyle(fontSize: 15))
                  : Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primaryLight
                            : AppColors.background2,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isToday
                              ? AppColors.primaryMid
                              : AppColors.border,
                          width: 0.5)),
                      child: Center(child: Text('·',
                        style: TextStyle(
                          fontSize: 14,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.text3)))),
              const SizedBox(height: 3),
              Text(d.label, style: AppText.caption.copyWith(
                fontSize: 9,
                color: isToday ? AppColors.primary : AppColors.text3,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w400)),
            ]));
          }).toList(),
        ),
        if (!hasAnyData) ...[
          const SizedBox(height: 8),
          Text('Complete your first check-in to see your mood history',
            style: AppText.caption.copyWith(
              fontSize: 11, color: AppColors.text3,
              fontStyle: FontStyle.italic),
            textAlign: TextAlign.center),
        ],
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
      _TileData('Medications',
          '${session.medsTakenTodayCount} of ${session.medications.length} done',
          Icons.medication_rounded,
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
    ];
  }

  Widget _buildNextAppointment(BuildContext context) {
    final session = UserSession();
    // Use monitoring appointments for monitoring patients
    final appointments = session.isMonitoring
        ? _monitoringAppointments()
        : MockData.appointments;
    final upcoming = appointments.where((a) => !a.isPast).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final apt = upcoming.first;

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
