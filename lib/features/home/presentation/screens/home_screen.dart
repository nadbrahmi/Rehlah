import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/widgets/rehlah_widgets.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final isInChemo = session.treatmentPhase == 'In chemotherapy';
    final isMonitoring = session.isMonitoring;

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, session)),
          SliverToBoxAdapter(child: _buildPhaseBanner(session, isInChemo, isMonitoring)),
          SliverToBoxAdapter(child: _buildHeroCard(context, session)),
          if (session.hasHighAlertToday)
            SliverToBoxAdapter(child: _buildHighAlertBanner(context)),
          SliverToBoxAdapter(child: _buildMedsVitalsRow(context, session)),
          // Micro-education — hide when more specific card already shows
          if (!session.isNadirWindow &&
              !session.isNadirApproaching &&
              !session.isScanxietyPeriod)
            SliverToBoxAdapter(child: _buildMicroEducationCard(session)),
          if (isMonitoring) ...[
            SliverToBoxAdapter(child: _buildMonitoringWellnessCard(session)),
            if (session.isScanxietyPeriod)
              SliverToBoxAdapter(child: _buildScanxietyCard(session)),
            SliverToBoxAdapter(child: _buildCycleAndScanCard(context, session)),
          ],
          if (isInChemo && session.isNadirWindow)
            SliverToBoxAdapter(child: _buildNadirCard(session)),
          if (isInChemo && session.isNadirApproaching && !session.isNadirWindow)
            SliverToBoxAdapter(child: _buildNadirApproachingCard()),
          SliverToBoxAdapter(child: _buildMoodRecap(session)),
          SliverToBoxAdapter(child: _buildQuickAccess(context, session)),
          SliverToBoxAdapter(child: _buildNextAppointment(context)),
          SliverToBoxAdapter(child: _buildAskRehlah(context, session)),
          SliverToBoxAdapter(child: _buildCareTeamSection(context, session)),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ]),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, UserSession session) {
    final name = session.displayName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.greeting,
              style: RText.small.copyWith(color: RColors.sand500, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(name,
              style: RText.h1.copyWith(fontSize: 22, fontWeight: FontWeight.w700, height: 1)),
          ])),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(
                color: RColors.teal700,
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
              )),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phase Banner ───────────────────────────────────────────────────────────
  Widget _buildPhaseBanner(UserSession session, bool isInChemo, bool isMonitoring) {
    final Widget banner;
    if (isInChemo) {
      final isNadir = session.isNadirWindow;
      final isApproaching = session.isNadirApproaching;
      final isAr = session.language == 'ar';
      final variant = isNadir ? PhaseBannerVariant.alert : PhaseBannerVariant.current;
      final title = isAr
          ? _phaseNameAr(session.currentPhase.name)
          : session.currentPhase.name;
      final eyebrow = isAr
          ? 'الدورة ${session.currentCycle} من ${session.totalCycles}'
          : 'Cycle ${session.currentCycle} of ${session.totalCycles}';
      final subtitle = isNadir
          ? (isAr ? 'نافذة الناضير نشطة — راقبي درجة الحرارة مرتين يومياً' : 'Nadir window active — monitor temperature twice daily')
          : isApproaching
              ? (isAr ? 'نافذة الناضير متوقعة خلال يوم إلى يومين' : 'Nadir window expected in 1–2 days')
              : (isAr ? 'اليوم ${session.dayInCycle} من الدورة' : 'Day ${session.dayInCycle} of cycle');
      final pillLabel = isNadir
          ? (isAr ? 'الناضير الآن' : 'Nadir now')
          : isApproaching
              ? (isAr ? 'الناضير قريب' : 'Nadir soon')
              : (isAr ? 'اليوم ${session.dayInCycle}' : 'Day ${session.dayInCycle}');
      final pillVariant = isNadir ? StatusPillVariant.alert : StatusPillVariant.warn;
      banner = PhaseBanner(
        eyebrow: eyebrow,
        title: title,
        subtitle: subtitle,
        badge: '${session.currentCycle}',
        variant: variant,
        trailingPill: StatusPill(pillLabel, variant: pillVariant),
      );
    } else if (isMonitoring) {
      final days = session.daysCancerFree;
      final years = days ~/ 365;
      final months = (days % 365) ~/ 30;
      final label = years > 0
          ? '$years yr${years > 1 ? 's' : ''} ${months > 0 ? '$months mo ' : ''}cancer-free'
          : months > 0
              ? '$months month${months > 1 ? 's' : ''} cancer-free'
              : '$days days cancer-free';
      banner = PhaseBanner(
        eyebrow: 'Monitoring & Surveillance',
        title: label,
        subtitle: session.isScanxietyPeriod
            ? 'Scan coming up — scanxiety is normal'
            : 'Regular monitoring keeps you protected',
        badge: '🎗️',
        variant: PhaseBannerVariant.complete,
        trailingPill: StatusPill(
          session.isScanxietyPeriod ? 'Scan soon' : 'Active',
          variant: session.isScanxietyPeriod ? StatusPillVariant.warn : StatusPillVariant.pos,
        ),
      );
    } else {
      banner = PhaseBanner(
        eyebrow: session.treatmentPhase,
        title: _phaseTitle(session.treatmentPhase),
        subtitle: _phaseSubtitle(session.treatmentPhase),
        badge: '✦',
        variant: PhaseBannerVariant.current,
      );
    }
    return banner;
  }

  String _phaseTitle(String phase) {
    const titles = {
      'Just diagnosed': 'Diagnosis phase',
      'Awaiting treatment plan': 'Treatment planning',
      'In radiotherapy': 'Radiation therapy',
      'Post-surgery recovery': 'Recovery phase',
    };
    return titles[phase] ?? phase;
  }

  String _phaseNameAr(String name) {
    const map = {
      'Joint pain peak':    'ذروة آلام المفاصل',
      'Taxol infusion':     'يوم حقن تاكسول',
      'Nadir window':       'نافذة الناضير',
      'Recovery week':      'أسبوع التعافي',
      'Infusion day':       'يوم الحقن',
      'Peak nausea window': 'ذروة الغثيان',
    };
    return map[name] ?? name;
  }

  String _phaseSubtitle(String phase) {
    const subs = {
      'Just diagnosed': 'Your care team is building your plan',
      'Awaiting treatment plan': 'Use this time to prepare your questions',
      'In radiotherapy': 'Rest well between sessions',
      'Post-surgery recovery': 'Rest and gentle movement support healing',
    };
    return subs[phase] ?? 'You\'re on your journey — we\'re here for you';
  }

  // ── Check-in hero card ─────────────────────────────────────────────────────
  Widget _buildHeroCard(BuildContext context, UserSession session) {
    final hasCheckedIn = session.checkedInToday;
    final streak = session.streak;
    final isInChemo = session.treatmentPhase == 'In chemotherapy';

    return GestureDetector(
      onTap: () => context.push('/checkin'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
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
            Text(
              hasCheckedIn ? 'TODAY\'S CHECK-IN ✓' : 'TODAY\'S CHECK-IN',
              style: RText.eyebrowOnDark,
            ),
            const SizedBox(height: 6),
            Text('How are you\nfeeling today?', style: RText.h2OnDark),
            const SizedBox(height: 6),
            Text(
              [
                if (streak > 1) '🔥 $streak day streak · ',
                if (isInChemo)
                  '${session.protocol.name} · C${session.currentCycle} · D${session.dayInCycle}'
                else
                  session.treatmentPhase,
              ].join(),
              style: RText.smallOnDark,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: RColors.saffron500,
                borderRadius: RRadius.pillBR,
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  hasCheckedIn ? 'View today\'s check-in' : 'Start check-in',
                  style: RText.body.copyWith(
                    color: RColors.surface, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: RColors.surface),
              ]),
            ),
          ]),
        ]),
      ),
    );
  }
  // ── HIGH vitals alert banner ───────────────────────────────────────────────
  Widget _buildHighAlertBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/vitals'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: RColors.clay100,
          borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.clay500.withValues(alpha: 0.35))),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: RColors.clay700),
          const SizedBox(width: 10),
          Expanded(child: Text('Vitals HIGH alert — tap to review',
            style: RText.small.copyWith(
              fontWeight: FontWeight.w600, color: RColors.clay700))),
          const Icon(Icons.chevron_right_rounded, size: 16, color: RColors.clay500),
        ]),
      ),
    );
  }

  // ── Meds + Vitals 2-column row ─────────────────────────────────────────────
  Widget _buildMedsVitalsRow(BuildContext context, UserSession session) {
    session.initDefaultLabs();
    final taken = session.medsTakenTodayCount;
    final total = session.medications.isEmpty ? 0 : session.medications.length;
    final adherence = total > 0 ? taken / total : 0.0;
    final ringColor = adherence >= 0.8
        ? RColors.sage500
        : adherence >= 0.5
            ? RColors.saffron500
            : RColors.clay500;

    final temp = session.latestTemperature;
    final latest = session.latestVital;
    final hasFever = session.hasFeverToday;
    final hasHigh  = session.hasHighAlertToday;
    final worstFlag = latest?.worstFlag ?? VitalFlag.normal;
    final tileIconColor = hasHigh
        ? RColors.clay500
        : worstFlag == VitalFlag.moderate
            ? RColors.saffron500
            : RColors.saffron500;
    final tileIconBg = hasHigh
        ? RColors.clay100
        : worstFlag == VitalFlag.moderate
            ? RColors.saffron100
            : RColors.saffron100;
    final tempStr = temp != null ? '${temp.toStringAsFixed(1)}°' : '—';
    final tempColor = hasHigh ? RColors.clay500
        : worstFlag == VitalFlag.moderate ? RColors.saffron500
        : RColors.sand900;
    final tempCaption = hasHigh
        ? 'HIGH alert — see care team'
        : hasFever
            ? 'Fever — contact your care team'
            : latest != null
                ? 'Latest reading'
                : 'Tap to record vitals';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/care/medications'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: RColors.surface,
                borderRadius: RRadius.lgBR,
                boxShadow: RShadow.shadow2,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(
                      color: RColors.sage100,
                      borderRadius: RRadius.smBR,
                    ),
                    child: const Icon(Icons.medication_rounded,
                      size: 16, color: RColors.sage500),
                  ),
                  const SizedBox(width: 8),
                  Text('MEDICATION', style: RText.eyebrow),
                ]),
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  SizedBox(
                    width: 52, height: 52,
                    child: CustomPaint(
                      painter: _MiniRingPainter(value: adherence, color: ringColor),
                      child: Center(
                        child: Text(
                          total > 0 ? '$taken/$total' : '—',
                          style: RText.small.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: RColors.sand900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(adherence * 100).round()}%',
                        style: RText.h2.copyWith(fontSize: 22),
                      ),
                      Text(
                        total > 0 ? '$taken of $total doses today' : 'Add medications',
                        style: RText.small,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )),
                ]),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/vitals'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: RColors.surface,
                borderRadius: RRadius.lgBR,
                boxShadow: RShadow.shadow2,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: tileIconBg,
                      borderRadius: RRadius.smBR,
                    ),
                    child: Icon(Icons.thermostat_rounded,
                      size: 16,
                      color: tileIconColor),
                  ),
                  const SizedBox(width: 8),
                  Text('VITALS', style: RText.eyebrow),
                ]),
                const SizedBox(height: 10),
                Text(
                  tempStr,
                  style: RText.h1.copyWith(
                    fontSize: 32, color: tempColor,
                    fontFeatures: const [FontFeature('tnum')],
                  ),
                ),
                const SizedBox(height: 4),
                if (latest?.heartRateBpm != null)
                  Text('${latest!.heartRateBpm} bpm',
                    style: RText.small.copyWith(color: RColors.sand500)),
                const SizedBox(height: 3),
                Text(tempCaption,
                  style: RText.small.copyWith(
                    color: hasHigh
                        ? RColors.clay500
                        : hasFever
                            ? RColors.clay500
                            : RColors.sand500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Nadir cards ────────────────────────────────────────────────────────────
  Widget _buildNadirCard(UserSession session) {
    final isAr = session.language == 'ar';
    return Column(children: [
      Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: RColors.clay100,
          borderRadius: RRadius.lgBR,
          border: Border(left: BorderSide(color: RColors.clay500, width: 3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isAr
                ? '⚠ الناضير · اليوم ${session.dayInCycle}'
                : '⚠ Nadir window — Day ${session.dayInCycle}',
            style: RText.body.copyWith(
              fontWeight: FontWeight.w600, color: RColors.clay700),
          ),
          const SizedBox(height: 3),
          Text(
            isAr
                ? 'أنتِ في فترة انخفاض المناعة. هذا هو الوقت الأهم لمتابعتكِ اليومية.'
                : 'Your immune system is at its lowest. Avoid crowds, monitor temperature twice daily.',
            style: RText.bodyMuted,
          ),
        ]),
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: RColors.saffron100,
          borderRadius: RRadius.mdBR,
          border: Border.all(
            color: RColors.saffron300.withValues(alpha: 0.5), width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            isAr ? 'متى تتصلين؟' : 'WHEN TO CALL',
            style: RText.eyebrow.copyWith(color: RColors.clay500)),
          const SizedBox(height: 8),
          _whenToCallRow('🌡️',
            isAr ? 'حمّى ≥ 38°C' : 'Fever ≥ 38°C',
            isAr ? 'اتصلي بممرضة الكيمياء الآن' : 'Call chemo nurse now',
            RColors.clay500),
          const SizedBox(height: 6),
          _whenToCallRow('🫁',
            isAr ? 'ضيق في التنفس أثناء الراحة' : 'Breathlessness at rest',
            isAr ? 'اتصلي بمنسق الرعاية' : 'Call care coordinator',
            RColors.clay500),
          const SizedBox(height: 6),
          _whenToCallRow('🔴',
            isAr ? 'ألم في الصدر / نزيف شديد' : 'Chest pain / severe bleeding',
            isAr ? 'اتصلي بالطوارئ — لا تنتظري' : 'Emergency line — do not wait',
            RColors.clay700),
          const SizedBox(height: 6),
          _whenToCallRow('💊',
            isAr ? 'أسئلة عن الأدوية' : 'Medication questions',
            isAr ? 'ممرضة الكيمياء' : 'Chemo nurse',
            RColors.teal700),
        ]),
      ),
    ]);
  }

  Widget _whenToCallRow(String icon, String symptom, String action, Color color) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(icon, style: const TextStyle(fontSize: 13)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(symptom,
          style: RText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(action,
          style: RText.small.copyWith(color: color, fontWeight: FontWeight.w500)),
      ])),
    ]);
  }

  Widget _buildNadirApproachingCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RColors.saffron100,
        borderRadius: RRadius.mdBR,
        border: Border.all(
          color: RColors.saffron300.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⚡', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nadir window approaching',
            style: RText.body.copyWith(
              fontWeight: FontWeight.w600, color: RColors.saffron700)),
          const SizedBox(height: 3),
          Text(
            'Your WBC count will reach its lowest in 1–2 days. Start monitoring your temperature twice daily.',
            style: RText.bodyMuted,
          ),
        ])),
      ]),
    );
  }

  // ── Micro-education card ───────────────────────────────────────────────────
  Widget _buildMicroEducationCard(UserSession session) {
    final String title;
    final String body;
    final String emoji;
    final Color color;

    if (session.isMonitoring) {
      if (session.isScanxietyPeriod) {
        title = 'Scan anxiety is real';
        body = 'Feeling anxious before a scan is completely normal — '
            'studies show up to 70% of survivors experience it. '
            'Tracking your mood this week helps your care team support you.';
        emoji = '⚡';
        color = RColors.saffron500;
      } else if (session.hormoneTherapyDays > 0 &&
          session.hormoneTherapyDays < 365) {
        title = 'Why Tamoxifen for 5 years?';
        body = 'Hormone therapy works by blocking oestrogen that can fuel '
            'cancer regrowth. Completing the full 5-year course reduces '
            'recurrence risk by up to 40% — even when you feel well.';
        emoji = '💊';
        color = RColors.teal700;
      } else if (session.hormoneTherapyDays >= 1460) {
        title = 'The final stretch matters most';
        body = 'Research shows the protective effect of Tamoxifen continues '
            'to build in years 4 and 5. Stopping early — even at this stage — '
            'reduces the long-term benefit significantly.';
        emoji = '🏁';
        color = RColors.sage500;
      } else {
        title = 'Monitoring is active protection';
        body = 'Regular surveillance catches changes early — '
            'when they\'re most treatable. '
            'Each check-in helps your care team spot patterns before symptoms appear.';
        emoji = '🎗️';
        color = RColors.sage500;
      }
    } else if (session.isNadirWindow) {
      title = 'Why nadir monitoring matters';
      body = 'During nadir, your neutrophil count is at its lowest — '
          'meaning bacteria your body normally clears can cause serious infection. '
          'A temperature above 38°C is a medical emergency during this window.';
      emoji = '🌡️';
      color = RColors.clay500;
    } else if (session.isNadirApproaching) {
      title = 'Nadir window in 1–2 days';
      body = 'Your WBC count will reach its lowest point soon. '
          'Start monitoring your temperature now, twice daily. '
          'Avoid crowded spaces and wash hands frequently.';
      emoji = '⚡';
      color = RColors.saffron500;
    } else {
      final phase = session.currentPhase;
      final note = phase.phaseNote;
      if (note.isEmpty) return const SizedBox.shrink();
      title = phase.description;
      body = note;
      emoji = '💡';
      color = RColors.teal700;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: RRadius.mdBR,
        border: Border.all(
          color: color.withValues(alpha: 0.18), width: 0.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: RText.body.copyWith(
                fontWeight: FontWeight.w600, fontSize: 13, color: color)),
            const SizedBox(height: 4),
            Text(body,
              style: RText.small.copyWith(
                color: RColors.sand700, height: 1.55)),
          ],
        )),
      ]),
    );
  }

  // ── Monitoring wellness card ───────────────────────────────────────────────
  Widget _buildMonitoringWellnessCard(UserSession session) {
    final days = session.daysCancerFree;
    final years = days ~/ 365;
    final months = (days % 365) ~/ 30;
    final hormDays = session.hormoneTherapyDays;
    final hormProgress = session.hormoneTherapyProgress;
    final milestone = session.hormoneTherapyMilestone;
    final med = session.hormoneTherapyMed;

    String label;
    if (years > 0 && months > 0) {
      label = '$years yr $months mo cancer-free';
    } else if (years > 0) {
      label = '$years year${years > 1 ? 's' : ''} cancer-free';
    } else if (months > 0) {
      label = '$months month${months > 1 ? 's' : ''} cancer-free';
    } else {
      label = '$days days cancer-free';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RColors.teal50, RColors.sage100],
        ),
        borderRadius: RRadius.lgBR,
        border: Border.all(color: RColors.teal200.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('🎗️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(child: Text(label,
              style: RText.body.copyWith(
                fontWeight: FontWeight.w600, color: RColors.teal700, fontSize: 14))),
            Text('$days',
              style: RText.numericHero.copyWith(
                color: RColors.teal500.withValues(alpha: 0.5), fontSize: 20)),
          ]),
          if (hormDays > 0) ...[
            const SizedBox(height: 10),
            Divider(color: RColors.teal200.withValues(alpha: 0.4), height: 1),
            const SizedBox(height: 10),
            Row(children: [
              const Text('💊', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(med?.name ?? 'Hormone therapy',
                      style: RText.body.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                    if (milestone != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                        decoration: const BoxDecoration(
                          color: RColors.sage100,
                          borderRadius: RRadius.pillBR),
                        child: Text('🎉 $milestone',
                          style: RText.small.copyWith(
                            color: RColors.sage700, fontSize: 9,
                            fontWeight: FontWeight.w600))),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: hormProgress,
                      minHeight: 4,
                      backgroundColor: RColors.teal100,
                      valueColor: const AlwaysStoppedAnimation(RColors.sage500)),
                  ),
                  const SizedBox(height: 2),
                  Text('${(hormProgress * 100).round()}% of 5-year course',
                    style: RText.small.copyWith(fontSize: 10)),
                ],
              )),
            ]),
          ],
        ]),
      ),
    );
  }

  // ── Cycle + scan card ──────────────────────────────────────────────────────
  Widget _buildCycleAndScanCard(BuildContext context, UserSession session) {
    final hasOptimalWindow = session.menstrualStatus == 'regular' &&
        session.nextOptimalWindowStart != null;
    final windowStart = session.nextOptimalWindowStart;
    final windowEnd = session.nextOptimalWindowEnd;

    return GestureDetector(
      onTap: () => context.push('/monitoring/cycle-tracker'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.lgBR,
          boxShadow: RShadow.shadow1,
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              color: RColors.plum100,
              borderRadius: RRadius.smBR),
            child: const Center(
              child: Text('🌸', style: TextStyle(fontSize: 18)))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cycle & scan tracker',
                style: RText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              if (hasOptimalWindow && windowStart != null)
                Text(
                  'Best scan window: ${DateFormat('d MMM').format(windowStart)}'
                  '${windowEnd != null ? ' – ${DateFormat('d MMM').format(windowEnd)}' : ''}',
                  style: RText.small.copyWith(color: RColors.sage500))
              else
                Text('Tap to view calendar', style: RText.small),
            ],
          )),
          const Icon(Icons.arrow_forward_ios_rounded,
            size: 12, color: RColors.sand400),
        ]),
      ),
    );
  }

  // ── Scanxiety card ─────────────────────────────────────────────────────────
  Widget _buildScanxietyCard(UserSession session) {
    const scanKeywords = [
      'mammogram', 'mri', 'ultrasound', 'scan', 'ct ',
      'pet ', 'imaging', 'radiology', 'biopsy', 'echo',
    ];
    final nextScan = session.upcomingAppointments
        .where((a) {
          final title = a.title.toLowerCase();
          return scanKeywords.any((k) => title.contains(k));
        })
        .firstOrNull;

    final days = nextScan?.daysUntil ?? 0;
    final title = nextScan?.title ?? 'Scan';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RColors.saffron100,
        borderRadius: RRadius.mdBR,
        border: Border.all(
          color: RColors.saffron300.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⚡', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title in $days day${days != 1 ? 's' : ''}',
              style: RText.body.copyWith(
                fontWeight: FontWeight.w600, color: RColors.saffron700)),
            const SizedBox(height: 3),
            Text(
              'Scanxiety is normal. Talking to someone who\'s been through it helps.',
              style: RText.small.copyWith(height: 1.5)),
          ],
        )),
      ]),
    );
  }

  // ── Mood recap ─────────────────────────────────────────────────────────────
  Widget _buildMoodRecap(UserSession session) {
    final days = session.last7Days;
    final hasAnyData = days.any((d) => d.hasData);
    final streak = session.streak;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('LAST 7 DAYS', style: RText.eyebrow),
          if (streak > 1)
            Text('🔥 $streak day streak',
              style: RText.small.copyWith(
                color: RColors.sage500, fontWeight: FontWeight.w600))
          else if (session.checkedInToday)
            Text('✓ Checked in today',
              style: RText.small.copyWith(
                color: RColors.sage500, fontWeight: FontWeight.w600))
          else
            Text('Not yet today',
              style: RText.small),
        ]),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) {
            final isToday = d.label == 'Today';
            return Expanded(child: Column(children: [
              d.hasData
                  ? Text(d.emoji, style: const TextStyle(fontSize: 15))
                  : isToday
                      ? const _DashedCircle(
                          size: 22,
                          color: RColors.teal700,
                          child: Text('+',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: RColors.teal700)))
                      : Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: RColors.sand100,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: RColors.sand200, width: 0.5)),
                          child: const Center(child: Text('·',
                            style: TextStyle(
                              fontSize: 14,
                              color: RColors.sand400)))),
              const SizedBox(height: 3),
              Text(d.label,
                style: RText.small.copyWith(
                  fontSize: 9,
                  color: isToday ? RColors.teal700 : RColors.sand400,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w400)),
            ]));
          }).toList(),
        ),
        if (!hasAnyData) ...[
          const SizedBox(height: 8),
          Text(
            'Complete your first check-in to see your mood history',
            style: RText.small.copyWith(
              fontSize: 11, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center),
        ],
      ]),
    );
  }

  // ── Quick access rows ──────────────────────────────────────────────────────
  Widget _buildQuickAccess(BuildContext context, UserSession session) {
    session.initDefaultLabs();
    final labs = session.labs;
    final labSub = labs.isEmpty
        ? 'No results yet'
        : 'Last updated ${DateFormat('MMM d').format(labs.first.date)}';

    return Column(children: [
      _quickRow(
        icon: Icons.auto_awesome_rounded,
        iconBg: RColors.teal50,
        iconFg: RColors.teal700,
        title: 'Ask Rehlah AI',
        subtitle: 'Any question, any time',
        onTap: () => context.push('/ai-chat'),
      ),
      _quickRow(
        icon: Icons.biotech_rounded,
        iconBg: RColors.sage100,
        iconFg: RColors.sage500,
        title: 'Lab results',
        subtitle: labSub,
        onTap: () => context.push('/care/labs'),
      ),
    ]);
  }

  Widget _quickRow({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String subtitle,
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
              style: const TextStyle(fontSize: 11, color: RColors.sand500, height: 1.3)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: RColors.sand300, size: 20),
        ]),
      ),
    );
  }

  // ── Next appointment ───────────────────────────────────────────────────────
  Widget _buildNextAppointment(BuildContext context) {
    final session = UserSession();
    session.initDefaultAppointments();
    final upcoming = session.upcomingAppointments;
    if (upcoming.isEmpty) return const SizedBox.shrink();
    final apt = upcoming.first;

    return GestureDetector(
      onTap: () => context.push('/care/appointments'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.lgBR,
          boxShadow: RShadow.shadow2,
        ),
        child: Row(children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: RColors.teal50,
              borderRadius: RRadius.mdBR,
              border: Border.all(color: RColors.teal100, width: 1),
            ),
            child: Column(children: [
              Text('${apt.dateTime.day}',
                style: RText.h2.copyWith(
                  color: RColors.teal700, fontSize: 20,
                  fontFeatures: const [FontFeature('tnum')],
                ),
              ),
              Text(
                DateFormat('MMM').format(apt.dateTime).toUpperCase(),
                style: RText.eyebrow.copyWith(
                  color: RColors.teal500, fontSize: 9, letterSpacing: 0.5),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEXT APPOINTMENT', style: RText.eyebrow),
              const SizedBox(height: 2),
              Text(apt.title,
                style: RText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
              Text(
                '${apt.doctorName} · ${DateFormat('HH:mm').format(apt.dateTime)}',
                style: RText.small),
            ],
          )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              color: RColors.saffron100,
              borderRadius: RRadius.pillBR,
            ),
            child: Text(
              '${apt.daysUntil}d',
              style: RText.small.copyWith(
                color: RColors.saffron700, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Ask Rehlah prompt ──────────────────────────────────────────────────────
  Widget _buildAskRehlah(BuildContext context, UserSession session) {
    final question = session.isNadirWindow
        ? 'What should I watch for during nadir?'
        : session.isMonitoring
            ? 'What does my latest lab result mean?'
            : 'What side effects should I report today?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: AskRehlahPrompt(
        question: question,
        onTap: () => context.push('/ai-chat'),
      ),
    );
  }

  // ── Care team strip ────────────────────────────────────────────────────────
  Widget _buildCareTeamSection(BuildContext context, UserSession session) {
    final doctorName = session.upcomingAppointments
        .map((a) => a.doctorName)
        .where((n) => n.isNotEmpty)
        .firstOrNull ?? '';
    final members = [
      if (doctorName.isNotEmpty)
        CareTeamMember(name: doctorName, role: 'Oncologist'),
      const CareTeamMember(name: 'Nour M.', role: 'Chemo nurse'),
      const CareTeamMember(name: 'Fatima T.', role: 'Coordinator'),
      const CareTeamMember(name: 'Reem H.', role: 'Dietitian'),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('YOUR CARE TEAM', style: RText.eyebrow),
            GestureDetector(
              onTap: () => context.push('/care'),
              child: Text('Manage',
                style: RText.small.copyWith(
                  color: RColors.teal700, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      CareTeamStrip(members: members),
    ]);
  }
}

// ── Mini ring painter (52 × 52 for the Meds tile) ──────────────────────────

class _MiniRingPainter extends CustomPainter {
  final double value;
  final Color color;
  const _MiniRingPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width - 5) / 2;

    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = RColors.sand200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0);

    if (value <= 0) return;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      2 * math.pi * value.clamp(0, 1),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) =>
      old.value != value || old.color != color;
}


// ── Dashed circle (mood recap "today" empty state) ──────────────────────────

class _DashedCircle extends StatelessWidget {
  final double size;
  final Color color;
  final Widget? child;

  const _DashedCircle({required this.size, required this.color, this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color: color),
      child: SizedBox(
        width: size, height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final radius = (size.width / 2) - 1;
    final center = Offset(size.width / 2, size.height / 2);
    const dashCount = 8;
    const gapRatio = 0.4;
    const dashAngle = 2 * math.pi / dashCount;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      const sweepAngle = dashAngle * (1 - gapRatio);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
