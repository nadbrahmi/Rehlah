import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../providers/lab_provider.dart';
import '../../models/lab_models.dart' show LabCatalog;
import '../ai/lab_tracker_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../checkin/checkin_screen.dart' show DailyCheckInScreen;
import '../checkin/voice_checkin_screen.dart';
import '../care/medication_tracker_screen.dart';
import '../care/appointment_tracker_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// REHLA CARE — Home Screen v9
// Original palette restored + progressive patient UX
//
// Palette extracted from original Figma design:
//   Background   #FCF7FC  blush-lilac page
//   Card         #FFFFFF  pure white, r=24, soft shadow
//   Hero grad    #D894D3 → #C77ABF → #C770C0  soft mauve-purple
//   Plum text    #3A2A3F  headings
//   Mauve text   #B68AB3  secondary
//   Rose accent  #F75B9A  highlights, active
//   Green done   #EAF8EC bg / #22C55E icon
//   Peach pend   #FFF1E4 bg / #FF7A00 button
//   Purple grad  #9B5DC4 → #D370C8  AI / icons
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Palette ─────────────────────────────────────────────────────────────────
class _C {
  // Page background
  static const bg          = Color(0xFFFCF7FC);

  // Cards
  static const card        = Color(0xFFFFFFFF);

  // Hero gradient — soft mauve-purple from original design
  static const heroA       = Color(0xFFD894D3);
  static const heroB       = Color(0xFFC178BB);
  static const heroC       = Color(0xFFBD6BB8);

  // Brand purple (icon tiles, highlights)
  static const purple      = Color(0xFF9B5DC4);
  static const purpleLight = Color(0xFFEEE0F9);
  static const purpleMid   = Color(0xFFD370C8);

  // Rose accent (active tab, CTA highlights)
  static const rose        = Color(0xFFF75B9A);
  // roseLight available for future use
  // ignore: unused_field
  static const _roseLight   = Color(0xFFFDE8F2);

  // Text
  static const textDark    = Color(0xFF3A2A3F); // headings
  static const textMid     = Color(0xFF6B4F72); // body
  static const textSoft    = Color(0xFFB68AB3); // secondary/captions
  static const textFaint   = Color(0xFFCCA8CC); // muted

  // Semantic — green (done)
  static const greenBg     = Color(0xFFEAF8EC);
  static const greenFg     = Color(0xFF22C55E);
  static const greenDark   = Color(0xFF166534);

  // Semantic — peach (pending)
  static const peachBg     = Color(0xFFFFF1E4);
  static const peachFg     = Color(0xFFFF7A00);

  // Semantic — red
  static const red         = Color(0xFFDC2626);
  static const redBg       = Color(0xFFFEF2F2);

  // Divider
  static const divider     = Color(0xFFF3E8F5);
  static const border      = Color(0xFFEDD8F0);
}

// ─── Typography — Inter (matches Figma original) ─────────────────────────────
TextStyle _t({
  double s = 14,
  FontWeight w = FontWeight.w400,
  Color c = _C.textDark,
  double h = 1.5,
  double ls = 0,
  TextDecoration? d,
}) =>
    GoogleFonts.inter(
      fontSize: s,
      fontWeight: w,
      color: c,
      height: h,
      letterSpacing: ls,
      decoration: d,
    );

// ─── Card decoration — white, r=24, soft shadow ───────────────────────────────
BoxDecoration _cardDeco({Color? border, double r = 24}) => BoxDecoration(
      color: _C.card,
      borderRadius: BorderRadius.circular(r),
      border: border != null ? Border.all(color: border) : null,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF9B5DC4).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );

// ═══════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _anim = CurvedAnimation(parent: _fade, curve: Curves.easeOut);
    _fade.forward();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, LabProvider>(
      builder: (context, app, lab, _) {
        return Scaffold(
          backgroundColor: _C.bg,
          body: FadeTransition(
            opacity: _anim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Header
                _Header(app: app, lab: lab),

                // 2. Smart Status hero card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _SmartStatusCard(app: app, lab: lab),
                  ),
                ),

                // 3. Next Appointment banner (only shown when appt exists)
                if (app.nextAppointment != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _NextAppointmentBanner(app: app, lab: lab),
                    ),
                  ),

                // 4. Quick actions row
                SliverToBoxAdapter(
                  child: _QuickActions(app: app, lab: lab),
                ),

                // 5. Latest Labs (collapsed — tap to expand)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: _LatestLabsCard(lab: lab),
                  ),
                ),

                // 6. Today's Meds
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _MedsCard(app: app),
                  ),
                ),

                // 7. 14-Day Journey Progress
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _FourteenDayCard(app: app),
                  ),
                ),

                // 8. Phase Guide — "You are here"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _PhaseGuideCard(app: app),
                  ),
                ),

                // 9. Community Story snippet
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _CommunityStoryCard(app: app),
                  ),
                ),

                // 10. AI Health Insights
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _AiInsightsCard(app: app, lab: lab),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 1. HEADER — minimal, white background, date + greeting
// ═══════════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  const _Header({required this.app, required this.lab});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _journeySubtitle() {
    final start = app.journey?.treatmentStartDate;
    if (start == null) return 'Your companion between appointments.';
    final days = DateTime.now().difference(start).inDays;
    if (days == 0) return 'Today is the beginning of your journey. 💜';
    if (days < 7) return 'Day ${days + 1} of your journey. You\'re doing great.';
    if (days < 14) {
      final weekDay = days - 7 + 1;
      return 'Week 2, Day $weekDay of your journey. Still here. 💜';
    }
    final weeks = (days / 7).floor();
    return 'Week $weeks of your journey. You\'re not alone.';
  }

  @override
  Widget build(BuildContext context) {
    final name = app.journey?.name.split(' ').first ?? 'there';
    return SliverAppBar(
      expandedHeight: 140,
      collapsedHeight: 62,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: _C.bg,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: EdgeInsets.zero,
        title: _CollapsedBar(app: app, lab: lab),
        background: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  DateFormat('MMM d, yyyy').format(DateTime.now()),
                  style: _t(s: 13, c: _C.textSoft, w: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                // Greeting
                Text(
                  '$_greeting, $name 💜',
                  style: _t(s: 26, w: FontWeight.w600, c: _C.textDark, h: 1.2),
                ),
                const SizedBox(height: 5),
                Text(
                  _journeySubtitle(),
                  style: _t(s: 13, c: _C.textSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedBar extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  const _CollapsedBar({required this.app, required this.lab});

  @override
  Widget build(BuildContext context) {
    final name = app.journey?.name.split(' ').first ?? 'R';
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 62,
          color: _C.bg.withValues(alpha: 0.95),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(children: [
            Text(
              'Rehla Care',
              style: _t(s: 17, w: FontWeight.w700, c: _C.textDark),
            ),
            const Spacer(),
            if (lab.overallStatus == OverallLabStatus.critical)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _C.red,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('CRITICAL',
                    style: _t(s: 10, w: FontWeight.w800, c: Colors.white, ls: 0.6)),
              ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => app.setNavIndex(4),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.heroA, _C.heroC],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'R',
                    style: _t(s: 14, w: FontWeight.w700, c: Colors.white),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. SMART STATUS CARD — hero gradient card, one message + CTA
// ═══════════════════════════════════════════════════════════════════════════════
class _SmartStatusCard extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  const _SmartStatusCard({required this.app, required this.lab});

  // Day-aware greeting that changes with time
  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // How many days since journey start
  int _daysSinceJourney() {
    final start = app.journey?.treatmentStartDate;
    if (start == null) return 0;
    return DateTime.now().difference(start).inDays;
  }

  String _weekLabel(int days) {
    if (days == 0) return 'Today is the beginning of your journey.';
    if (days < 7) return 'Today is day ${days + 1} of your journey.';
    if (days < 14) return 'Today is the beginning of week 2 of your journey.';
    final weeks = (days / 7).floor();
    return 'Week $weeks of your journey. Still here. 💜';
  }

  ({IconData icon, String label, String title, String cta, VoidCallback? action}) _status(BuildContext ctx) {
    final name = app.journey?.name.split(' ').first ?? '';
    final greeting = _timeGreeting();
    final nameStr = name.isNotEmpty ? '$greeting, $name 💜' : '$greeting 💜';
    final days = _daysSinceJourney();

    // 1. Critical lab — highest priority
    if (lab.overallStatus == OverallLabStatus.critical) {
      return (
        icon: Icons.science_outlined,
        label: 'Lab Alert',
        title: 'A lab result needs attention.\nPlease contact your care team today.',
        cta: 'View Lab Results',
        action: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LabTrackerScreen())),
      );
    }

    // 2. Upcoming appointment within 2 days
    final appt = app.nextAppointment;
    if (appt != null) {
      final d = appt.dateTime.difference(DateTime.now()).inDays;
      if (d <= 2) {
        return (
          icon: Icons.calendar_today_outlined,
          label: 'Upcoming Appointment',
          title: '${appt.title} — ${d == 0 ? 'Today!' : d == 1 ? 'Tomorrow' : 'in $d days'}\n"Rehlah has your data ready to share."',
          cta: 'View Doctor-Ready Report',
          action: () => Navigator.push(ctx,
              MaterialPageRoute(builder: (_) => const AppointmentTrackerScreen())),
        );
      }
    }

    // 3. No check-in today — primary nudge
    if (!app.hasCheckedInToday) {
      // Day 1 variant — first ever check-in
      if (app.recentCheckIns.isEmpty) {
        return (
          icon: Icons.favorite_border_rounded,
          label: 'Day 1 — Welcome',
          title: '$nameStr\n${_weekLabel(days)}\n\nHow are you feeling today?\nYour first check-in takes 2 minutes.',
          cta: 'Do my first check-in →',
          action: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const DailyCheckInScreen())),
        );
      }
      // Day 5+ missed check-in — compassionate variant
      if (days >= 5 && app.recentCheckIns.length < days - 2) {
        return (
          icon: Icons.favorite_border_rounded,
          label: 'No pressure',
          title: 'Treatment weeks are tough.\nWe\'re still here, whenever you\'re ready. 💜',
          cta: 'Check in for today →',
          action: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const DailyCheckInScreen())),
        );
      }
      // Normal nudge
      return (
        icon: Icons.favorite_border_rounded,
        label: 'Daily Check-In',
        title: '$nameStr\n${_weekLabel(days)}\n\nHow are you doing today?',
        cta: 'Check in for today →',
        action: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const DailyCheckInScreen())),
      );
    }

    // 4. Day 7 milestone
    if (days == 7 && app.recentCheckIns.length >= 4) {
      return (
        icon: Icons.auto_awesome_rounded,
        label: 'One week in 🔥',
        title: 'One week in, ${name.isNotEmpty ? name : 'friend'}. 💜\nYou\'ve checked in ${app.recentCheckIns.take(7).length} times.\n"That\'s data your doctor can actually use."',
        cta: 'See my week summary →',
        action: () => _showWeekSheet(ctx, app),
      );
    }

    // 5. Day 14 milestone
    if (days == 14) {
      return (
        icon: Icons.celebration_rounded,
        label: 'Two weeks in 💜',
        title: 'Two weeks in, ${name.isNotEmpty ? name : 'friend'}. 💜\n"You are not the same person you were two weeks ago.\nYou\'re more informed, more prepared, and still here."',
        cta: 'See my 2-week summary →',
        action: () => _showWeekSheet(ctx, app),
      );
    }

    // 6. Checked in today — summary with yesterday mood chip on Day 2+
    final ci = app.todayCheckIn!;
    final moodEmojis = ['', '😫', '😔', '😐', '🙂', '😊'];
    final moodEmoji = (ci.moodScore >= 1 && ci.moodScore <= 5) ? moodEmojis[ci.moodScore] : '😐';

    // Yesterday mood chip for Day 2+ return visits
    String yesterdayNote = '';
    if (days >= 1 && app.recentCheckIns.length >= 2) {
      final yesterday = app.recentCheckIns
          .where((c) {
            final diff = DateTime.now().difference(c.date).inDays;
            return diff == 1;
          })
          .toList();
      if (yesterday.isNotEmpty) {
        final yMood = yesterday.first.moodScore;
        final yEmoji = (yMood >= 1 && yMood <= 5) ? moodEmojis[yMood] : '😐';
        yesterdayNote = '\nYesterday you felt $yEmoji — ${yMood >= 4 ? 'keeping that energy!' : yMood <= 2 ? 'glad you\'re back today.' : 'every day is different.'}';
      }
    }

    return (
      icon: Icons.check_circle_outline_rounded,
      label: 'Today logged ✓',
      title: 'All logged, ${name.isNotEmpty ? name : 'friend'} 💜\nMood: $moodEmoji · ${_weekLabel(days)}$yesterdayNote',
      cta: 'View this week →',
      action: () => _showWeekSheet(ctx, app),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _status(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.heroA, _C.heroB, _C.heroC],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _C.heroC.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + label row
            Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(s.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                s.label,
                style: _t(s: 12, w: FontWeight.w500,
                    c: Colors.white.withValues(alpha: 0.80)),
              ),
            ]),
            const SizedBox(height: 14),
            // Main title
            Text(
              s.title,
              style: _t(s: 19, w: FontWeight.w600, c: Colors.white, h: 1.35),
            ),
            const SizedBox(height: 18),
            // CTA button — white pill
            GestureDetector(
              onTap: s.action,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.cta,
                      style: _t(s: 14, w: FontWeight.w600, c: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. NEXT APPOINTMENT BANNER — compact card shown when appt within 7 days
// ═══════════════════════════════════════════════════════════════════════════════
class _NextAppointmentBanner extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  const _NextAppointmentBanner({required this.app, required this.lab});

  @override
  Widget build(BuildContext context) {
    final appt = app.nextAppointment;
    if (appt == null) return const SizedBox.shrink();
    final days = appt.dateTime.difference(DateTime.now()).inDays;
    final daysLabel = days == 0
        ? 'Today!'
        : days == 1
            ? 'Tomorrow'
            : 'in $days days';
    final accent = days <= 1 ? _C.peachFg : _C.heroB;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AppointmentTrackerScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.30)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Icon(Icons.calendar_today_rounded, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appt.title,
                  style: _t(s: 14, w: FontWeight.w700, c: _C.textDark)),
              Text('${appt.doctorName} · $daysLabel',
                  style: _t(s: 12, c: _C.textSoft)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Prep →',
                style: _t(s: 12, w: FontWeight.w700, c: accent)),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. QUICK ACTIONS — 4 tiles
// ═══════════════════════════════════════════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  const _QuickActions({required this.app, required this.lab});

  @override
  Widget build(BuildContext context) {
    final done = app.hasCheckedInToday;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions',
              style: _t(s: 18, w: FontWeight.w600, c: _C.textDark)),
          const SizedBox(height: 14),
          // Row 1
          Row(children: [
            // Scan Labs
            Expanded(
              child: _ActionTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LabTrackerScreen())),
                icon: Icons.document_scanner_outlined,
                label: 'Scan Lab\nResults',
                active: false,
              ),
            ),
            const SizedBox(width: 12),
            // Voice Check-In — active/highlighted
            Expanded(
              child: _ActionTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const VoiceCheckInScreen())),
                icon: Icons.mic_rounded,
                label: 'Voice\nCheck-In',
                active: true,
              ),
            ),
            const SizedBox(width: 12),
            // Daily check-in
            Expanded(
              child: _ActionTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DailyCheckInScreen())),
                icon: done ? Icons.check_circle_outline_rounded : Icons.edit_note_rounded,
                label: done ? 'Checked\nIn ✓' : 'Daily\nCheck-In',
                active: false,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          // Row 2
          Row(children: [
            // Ask AI
            Expanded(
              child: _ActionTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AIAssistantScreen())),
                icon: Icons.auto_awesome_rounded,
                label: 'Ask AI',
                active: false,
                singleLine: true,
              ),
            ),
            const SizedBox(width: 12),
            // Medications
            Expanded(
              child: _ActionTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MedicationTrackerScreen())),
                icon: Icons.medication_rounded,
                label: 'My Meds',
                active: false,
                singleLine: true,
              ),
            ),
            const SizedBox(width: 12),
            // Appointments
            Expanded(
              child: _ActionTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AppointmentTrackerScreen())),
                icon: Icons.calendar_month_rounded,
                label: 'Appts',
                active: false,
                singleLine: true,
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool active;
  final bool singleLine;
  const _ActionTile({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.active,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: active
            ? BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6BAF), Color(0xFFF84EA0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: _C.rose.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              )
            : _cardDeco(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.22)
                    : _C.purpleLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  color: active ? Colors.white : _C.purple, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: singleLine ? 1 : 2,
              style: _t(
                s: 13,
                w: FontWeight.w600,
                c: active ? Colors.white : _C.textDark,
                h: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. LATEST LABS — collapsed card, tap to open full view
// ═══════════════════════════════════════════════════════════════════════════════
class _LatestLabsCard extends StatefulWidget {
  final LabProvider lab;
  const _LatestLabsCard({required this.lab});
  @override
  State<_LatestLabsCard> createState() => _LatestLabsCardState();
}

class _LatestLabsCardState extends State<_LatestLabsCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasData = widget.lab.hasData;
    final status  = widget.lab.overallStatus;
    final statusLabel = status == OverallLabStatus.good
        ? '✓ Stable'
        : status == OverallLabStatus.caution
            ? '⚠ Review'
            : '✕ Critical';
    final statusBg = status == OverallLabStatus.good
        ? _C.greenBg
        : status == OverallLabStatus.caution
            ? const Color(0xFFFFF8E1)
            : _C.redBg;
    final statusFg = status == OverallLabStatus.good
        ? _C.greenDark
        : status == OverallLabStatus.caution
            ? _C.peachFg
            : _C.red;

    // Sample metrics for display
    final metrics = widget.lab.trackedMetrics.take(2).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: _cardDeco(),
        child: Column(
          children: [
            // Header row
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Latest Labs',
                            style: _t(s: 18, w: FontWeight.w600, c: _C.textDark)),
                        const SizedBox(height: 2),
                        Text(
                          hasData
                              ? DateFormat('MMM d, yyyy')
                                  .format(DateTime.now().subtract(const Duration(days: 3)))
                              : 'No data yet',
                          style: _t(s: 13, c: _C.textSoft),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: statusFg.withValues(alpha: 0.30)),
                    ),
                    child: Text(statusLabel,
                        style: _t(s: 12, w: FontWeight.w600, c: statusFg)),
                  ),
                ]),
              ),
            ),

            if (_expanded && hasData) ...[
              Divider(height: 1, color: _C.divider),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: metrics.map((k) {
                    final latest = widget.lab.latestFor(k);
                    final def = LabCatalog.byKey(k);
                    if (latest == null || def == null) return const SizedBox.shrink();
                    final pct = ((latest.value - def.normalMin) / (def.normalMax - def.normalMin)).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(def.name,
                                style: _t(s: 14, w: FontWeight.w500, c: _C.textDark)),
                            const Spacer(),
                            Text('${latest.value} ${def.unit}',
                                style: _t(s: 14, w: FontWeight.w600, c: _C.textDark)),
                            const SizedBox(width: 8),
                            const Icon(Icons.trending_up_rounded,
                                color: _C.greenFg, size: 18),
                          ]),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 8,
                              backgroundColor: _C.purpleLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _C.heroB),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Normal range: ${def.normalMin}–${def.normalMax} ${def.unit}',
                            style: _t(s: 11, c: _C.textSoft),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Footer button
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LabTrackerScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _C.bg,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined,
                        color: _C.heroB, size: 16),
                    const SizedBox(width: 8),
                    Text('View Full Lab Report',
                        style: _t(s: 14, w: FontWeight.w500, c: _C.heroB)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5. MORNING MEDS — exact match to original design
//    Taken rows: mint green. Pending: peach + orange button.
//    Progress ring on the right.
// ═══════════════════════════════════════════════════════════════════════════════
class _MedsCard extends StatelessWidget {
  final AppProvider app;
  const _MedsCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final meds = app.medications.where((m) => m.isActive).take(4).toList();
    // Use per-medication tracking (real data)
    final doneCount = meds.where((m) => app.isMedTakenToday(m.id)).length;
    final pct       = meds.isEmpty ? 1.0 : doneCount / meds.length;
    final pctLabel  = '${(pct * 100).round()}%';

    return Container(
      decoration: _cardDeco(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.purple, _C.purpleMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.medication_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Meds',
                        style: _t(s: 17, w: FontWeight.w600, c: _C.textDark)),
                    Text('$doneCount/${meds.isEmpty ? 0 : meds.length} Taken',
                        style: _t(s: 13, c: _C.textSoft)),
                  ],
                ),
              ),
              // Circular progress
              SizedBox(
                width: 54, height: 54,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 5,
                    backgroundColor: _C.purpleLight,
                    valueColor: AlwaysStoppedAnimation<Color>(_C.heroB),
                  ),
                  Text(pctLabel,
                      style: _t(s: 11, w: FontWeight.w700, c: _C.textDark)),
                ]),
              ),
            ]),

            const SizedBox(height: 16),

            // Med rows — real per-med status
            if (meds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('No medications added yet.',
                    style: _t(s: 13, c: _C.textSoft)),
              )
            else ...[
              for (final med in meds)
                _MedRow(
                  name: '${med.name} ${med.dosage}',
                  detail: app.isMedTakenToday(med.id)
                      ? 'Taken ✓'
                      : '${med.frequency} — tap to mark taken',
                  done: app.isMedTakenToday(med.id),
                  onMarkTaken: !app.isMedTakenToday(med.id)
                      ? () => app.logMedTaken(med.id, taken: true)
                      : null,
                ),
            ],

            const SizedBox(height: 6),

            // Footer
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MedicationTrackerScreen())),
              child: Center(
                child: Text('View All Medications & Track',
                    style: _t(s: 14, w: FontWeight.w500, c: _C.heroB)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedRow extends StatelessWidget {
  final String name, detail;
  final bool done;
  final VoidCallback? onMarkTaken;
  const _MedRow({
    required this.name,
    required this.detail,
    required this.done,
    this.onMarkTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: done ? _C.greenBg : _C.peachBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: done ? _C.greenFg : _C.peachFg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            done ? Icons.check_rounded : Icons.medication_outlined,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: _t(
                  s: 14,
                  w: FontWeight.w600,
                  c: done ? _C.greenDark : _C.peachFg,
                )),
            Text(detail,
                style: _t(
                  s: 12,
                  c: done
                      ? _C.greenDark.withValues(alpha: 0.70)
                      : _C.peachFg.withValues(alpha: 0.80),
                )),
          ]),
        ),
        if (onMarkTaken != null)
          GestureDetector(
            onTap: onMarkTaken,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _C.peachFg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Mark Taken',
                  style: _t(s: 12, w: FontWeight.w700, c: Colors.white)),
            ),
          ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 6. AI HEALTH INSIGHTS — matches original design
//    Purple gradient icon · 3 bullet insights with coloured icons
// ═══════════════════════════════════════════════════════════════════════════════
class _AiInsightsCard extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  const _AiInsightsCard({required this.app, required this.lab});

  List<({IconData icon, Color color, String text})> _insights() {
    final items = <({IconData icon, Color color, String text})>[];
    final w7 = app.recentCheckIns.take(7).toList();

    if (w7.length >= 3) {
      final prev = app.recentCheckIns.skip(3).take(4).toList();
      if (prev.isNotEmpty) {
        final recentFat  = w7.take(3).map((c) => c.fatigueScore).reduce((a, b) => a + b) / 3;
        final prevFat    = prev.map((c) => c.fatigueScore).reduce((a, b) => a + b) / prev.length;
        if (recentFat < prevFat) {
          final pct = ((prevFat - recentFat) / prevFat * 100).round();
          items.add((
            icon: Icons.bolt_rounded,
            color: _C.greenFg,
            text: 'Fatigue levels improved $pct% this week',
          ));
        }
      }
      final avgMeds = w7.where((c) => c.medicationsTaken).length / w7.length;
      if (avgMeds >= 0.8) {
        items.add((
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF3B82F6),
          text: 'Staying well on medications — keep up the good work!',
        ));
      }
      final avgPain = w7.map((c) => c.painScore).reduce((a, b) => a + b) / w7.length;
      if (avgPain >= 3.0) {
        items.add((
          icon: Icons.wb_sunny_outlined,
          color: _C.peachFg,
          text: 'Pain has been elevated — consider gentle rest between 10–11 AM',
        ));
      } else {
        items.add((
          icon: Icons.wb_sunny_outlined,
          color: _C.peachFg,
          text: 'Consider gentle exercise between 10–11 AM to boost energy',
        ));
      }
    }

    // Defaults if not enough data
    if (items.isEmpty) {
      items.addAll([
        (icon: Icons.bolt_rounded, color: _C.greenFg,
            text: 'Start daily check-ins to unlock personalised insights'),
        (icon: Icons.water_drop_outlined, color: const Color(0xFF3B82F6),
            text: 'Staying hydrated helps manage treatment side effects'),
        (icon: Icons.wb_sunny_outlined, color: _C.peachFg,
            text: 'Gentle morning walks can improve mood and energy'),
      ]);
    }

    return items.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final insights = _insights();
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AIAssistantScreen())),
      child: Container(
        decoration: _cardDeco(border: _C.purpleLight),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_C.purple, _C.purpleMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('AI Health Insights',
                    style: _t(s: 17, w: FontWeight.w600, c: _C.textDark)),
              ]),

              const SizedBox(height: 18),

              // Insights
              ...insights.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item.icon, color: item.color, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(item.text,
                                style: _t(
                                    s: 13.5, c: _C.textMid, h: 1.5)),
                          ),
                        ]),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEETS
// ═══════════════════════════════════════════════════════════════════════════════
// ignore: unused_element
void _showPrepSheet(BuildContext ctx, AppProvider app, LabProvider lab, int days) {
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PrepSheet(app: app, lab: lab, days: days),
  );
}

class _PrepSheet extends StatefulWidget {
  final AppProvider app;
  final LabProvider lab;
  final int days;
  const _PrepSheet({required this.app, required this.lab, required this.days});
  @override
  State<_PrepSheet> createState() => _PrepSheetState();
}

class _PrepSheetState extends State<_PrepSheet> {
  final Map<String, bool> _checked = {};

  List<({String id, String label, String hint})> get _list => [
        if (!widget.app.hasCheckedInToday)
          (id: 'ci',   label: 'Log today\'s symptoms',   hint: 'Gives your doctor your latest status')
        else
          (id: 'ci',   label: 'Today\'s check-in done ✓', hint: 'Symptoms logged'),
        (id: 'meds', label: 'Bring medication list',    hint: '${widget.app.medications.where((m) => m.isActive).length} active medications'),
        if (widget.lab.hasData)
          (id: 'labs', label: 'Review lab results',     hint: 'Note values outside normal range'),
        (id: 'qns',  label: 'Write questions to ask',  hint: 'Easy to forget — write them now'),
        (id: 'id',   label: 'Bring ID & insurance card', hint: 'Required for registration'),
      ];

  List<String> _talking() {
    final pts = <String>[];
    final r = widget.app.recentCheckIns.take(7).toList();
    if (r.isNotEmpty) {
      final p = r.map((c) => c.painScore).reduce((a, b) => a + b) / r.length;
      final f = r.map((c) => c.fatigueScore).reduce((a, b) => a + b) / r.length;
      final m = r.map((c) => c.moodScore).reduce((a, b) => a + b) / r.length;
      if (p >= 3.0) pts.add('Pain avg ${p.toStringAsFixed(1)}/5 this week');
      if (f >= 3.0) pts.add('Fatigue avg ${f.toStringAsFixed(1)}/5');
      if (m <= 2.5) pts.add('Mood has been low — may need support');
      final missed = r.where((c) => !c.medicationsTaken).length;
      if (missed > 0) pts.add('Missed medications $missed time${missed > 1 ? "s" : ""}');
    }
    if (widget.lab.overallStatus != OverallLabStatus.good) pts.add('Lab values outside normal range');
    if (pts.isEmpty) pts.addAll(['Feeling generally okay', 'Medications taken consistently']);
    return pts.take(4).toList();
  }

  List<String> _questions() {
    final qs = <String>[];
    final r = widget.app.recentCheckIns.take(7).toList();
    if (r.isNotEmpty) {
      final p = r.map((c) => c.painScore).reduce((a, b) => a + b) / r.length;
      final f = r.map((c) => c.fatigueScore).reduce((a, b) => a + b) / r.length;
      if (p >= 3.0) qs.add('Can we adjust my pain management?');
      if (f >= 3.5) qs.add('How can we reduce treatment fatigue?');
    }
    qs.add('How are my latest lab results?');
    qs.add('Any warning signs to watch for?');
    qs.add('Is my treatment plan on track?');
    return qs.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appt   = widget.app.nextAppointment;
    final list   = _list;
    final done   = list.where((i) => _checked[i.id] == true).length;
    final pct    = list.isEmpty ? 1.0 : done / list.length;
    final accent = widget.days <= 1 ? _C.peachFg : _C.heroB;

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Row(children: [
              Container(
                width: 62, height: 70,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    widget.days == 0 ? '!' : '${widget.days}',
                    style: GoogleFonts.inter(fontSize: widget.days > 9 ? 22 : 30,
                        fontWeight: FontWeight.w900, color: accent, height: 1.0),
                  ),
                  Text(widget.days == 0 ? 'TODAY' : widget.days == 1 ? 'DAY' : 'DAYS',
                      style: _t(s: 9, w: FontWeight.w700,
                          c: accent.withValues(alpha: 0.70), ls: 0.5)),
                ]),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (appt != null) ...[
                    Text(appt.title,
                        style: _t(s: 18, w: FontWeight.w700, c: _C.textDark)),
                    Text('${appt.doctorName}  ·  ${DateFormat("MMM d, h:mm a").format(appt.dateTime)}',
                        style: _t(s: 12.5, c: _C.textSoft)),
                  ] else
                    Text('Appointment Prep',
                        style: _t(s: 18, w: FontWeight.w700, c: _C.textDark)),
                ]),
              ),
              SizedBox(width: 44, height: 44,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(value: pct, strokeWidth: 3.5,
                      backgroundColor: accent.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(accent)),
                  Text('$done/${list.length}',
                      style: _t(s: 9, w: FontWeight.w700, c: accent)),
                ]),
              ),
            ]),
          ),

          Divider(height: 24, color: _C.divider),

          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              children: [
                _ShLabel(icon: Icons.checklist_rounded, title: 'Prep checklist', color: accent),
                const SizedBox(height: 12),
                ...list.map((item) => _ShCheck(
                      label: item.label, hint: item.hint,
                      checked: _checked[item.id] ?? false,
                      color: accent,
                      onTap: () => setState(() =>
                          _checked[item.id] = !(_checked[item.id] ?? false)),
                    )),
                const SizedBox(height: 20),
                Divider(color: _C.divider),
                const SizedBox(height: 16),
                _ShLabel(icon: Icons.record_voice_over_outlined, title: 'Tell your doctor', color: _C.textSoft),
                const SizedBox(height: 10),
                ..._talking().map((p) => _ShBullet(text: p)),
                const SizedBox(height: 20),
                Divider(color: _C.divider),
                const SizedBox(height: 16),
                _ShLabel(icon: Icons.help_outline_rounded, title: 'Questions to ask', color: _C.greenFg),
                const SizedBox(height: 10),
                ..._questions().map((q) => _ShBullet(text: q, dot: _C.greenFg)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ShLabel extends StatelessWidget {
  final IconData icon; final String title; final Color color;
  const _ShLabel({required this.icon, required this.title, required this.color});
  @override Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: color), const SizedBox(width: 8),
    Text(title, style: _t(s: 13, w: FontWeight.w700, c: color)),
  ]);
}

class _ShCheck extends StatelessWidget {
  final String label, hint; final bool checked; final Color color; final VoidCallback onTap;
  const _ShCheck({required this.label, required this.hint, required this.checked,
      required this.color, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 24, height: 24,
          decoration: BoxDecoration(
            color: checked ? color : Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: checked ? color : _C.border, width: 1.5),
          ),
          child: checked ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: _t(s: 14, w: FontWeight.w500,
              c: checked ? _C.textFaint : _C.textDark,
              d: checked ? TextDecoration.lineThrough : null)),
          Text(hint, style: _t(s: 11.5, c: _C.textFaint)),
        ])),
      ]),
    ),
  );
}

class _ShBullet extends StatelessWidget {
  final String text; final Color dot;
  const _ShBullet({required this.text, this.dot = _C.textFaint});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(top: 7),
        child: Container(width: 5, height: 5,
            decoration: BoxDecoration(color: dot.withValues(alpha: 0.55), shape: BoxShape.circle))),
      const SizedBox(width: 11),
      Expanded(child: Text(text, style: _t(s: 13.5, c: _C.textMid, h: 1.55))),
    ]),
  );
}

// ── Week sheet ────────────────────────────────────────────────────────────────
void _showWeekSheet(BuildContext ctx, AppProvider app) {
  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WeekSheet(app: app),
  );
}

class _WeekSheet extends StatelessWidget {
  final AppProvider app;
  const _WeekSheet({required this.app});
  @override
  Widget build(BuildContext context) {
    final w7 = app.recentCheckIns.take(7).toList();
    if (w7.length < 3) {
      return Container(
        decoration: const BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          Icon(Icons.bar_chart_rounded, color: _C.heroB, size: 44),
          const SizedBox(height: 16),
          Text('Not enough data yet', style: _t(s: 18, w: FontWeight.w700, c: _C.textDark)),
          const SizedBox(height: 8),
          Text('Check in for 3+ days to see your trends.',
              textAlign: TextAlign.center, style: _t(s: 14, c: _C.textSoft, h: 1.5)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () { Navigator.pop(context); Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DailyCheckInScreen())); },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 48),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_C.heroA, _C.heroC]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Start check-in',
                  style: _t(s: 14, w: FontWeight.w700, c: Colors.white)),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      );
    }

    final rev     = w7.reversed.toList();
    final avgMood = w7.map((c) => c.moodScore).reduce((a, b) => a + b) / w7.length;
    final avgPain = w7.map((c) => c.painScore).reduce((a, b) => a + b) / w7.length;
    final avgFat  = w7.map((c) => c.fatigueScore).reduce((a, b) => a + b) / w7.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.92,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
          children: [
            const SizedBox(height: 12),
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text('My Week', style: _t(s: 22, w: FontWeight.w700, c: _C.textDark)),
            const SizedBox(height: 4),
            Text('Last ${w7.length} check-ins', style: _t(s: 13, c: _C.textSoft)),
            const SizedBox(height: 24),

            // Bar chart
            SizedBox(height: 80,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end,
                children: rev.map((ci) {
                  final mH = (ci.moodScore / 5.0) * 68;
                  final pH = (ci.painScore / 5.0) * 68;
                  final isToday = ci.date.day == DateTime.now().day && ci.date.month == DateTime.now().month;
                  return Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(height: mH, decoration: BoxDecoration(
                          color: isToday ? _C.heroB : _C.heroA.withValues(alpha: 0.35),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))),
                      const SizedBox(height: 2),
                      Container(height: pH, decoration: BoxDecoration(
                          color: isToday ? _C.red.withValues(alpha: 0.65) : _C.red.withValues(alpha: 0.12),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)))),
                      const SizedBox(height: 6),
                      Text(DateFormat('EEE').format(ci.date).substring(0, 1),
                          style: _t(s: 10.5, w: isToday ? FontWeight.w700 : FontWeight.w400,
                              c: isToday ? _C.heroB : _C.textFaint)),
                    ]),
                  ));
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _Avg(label: 'Mood',    value: avgMood, color: _C.heroB,  up: true)),
              const SizedBox(width: 10),
              Expanded(child: _Avg(label: 'Pain',    value: avgPain, color: avgPain >= 3 ? _C.red : _C.greenFg, up: false)),
              const SizedBox(width: 10),
              Expanded(child: _Avg(label: 'Fatigue', value: avgFat,  color: avgFat >= 3.5 ? _C.peachFg : _C.greenFg, up: false)),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Avg extends StatelessWidget {
  final String label; final double value; final Color color; final bool up;
  const _Avg({required this.label, required this.value, required this.color, required this.up});
  @override Widget build(BuildContext context) {
    final good = up ? value >= 3.5 : value < 3.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(children: [
        Text(value.toStringAsFixed(1), style: _t(s: 22, w: FontWeight.w800, c: color, h: 1.1)),
        const SizedBox(height: 2),
        Text(label, style: _t(s: 10.5, c: _C.textSoft)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: good ? _C.greenBg : _C.peachBg, borderRadius: BorderRadius.circular(6)),
          child: Text(good ? 'Good' : 'Watch',
              style: _t(s: 9.5, w: FontWeight.w700, c: good ? _C.greenDark : _C.peachFg)),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 14-DAY JOURNEY PROGRESS CARD
// "Your first 14 days — visualised"
// Each dot = one day. Filled = checked in. Empty = missed. Today = pulsing.
// ═══════════════════════════════════════════════════════════════════════════════
class _FourteenDayCard extends StatelessWidget {
  final AppProvider app;
  const _FourteenDayCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startDate = app.journey?.treatmentStartDate ?? today.subtract(const Duration(days: 13));
    final daysSinceStart = today.difference(startDate).inDays;
    // daysSinceStart clamped to 0–13 for 14-day grid

    // Build 14-day check-in status
    final days = List.generate(14, (i) {
      final day = startDate.add(Duration(days: i));
      final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
      final isFuture = day.isAfter(today);
      final hasCheckIn = app.checkIns.any((c) =>
          c.date.year == day.year && c.date.month == day.month && c.date.day == day.day);
      return (day: day, isToday: isToday, isFuture: isFuture, hasCheckIn: hasCheckIn);
    });

    final checkedInCount = days.where((d) => d.hasCheckIn && !d.isFuture).length;
    final totalPastDays = days.where((d) => !d.isFuture).length;
    final streak = app.checkInStreak;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_C.heroA, _C.heroC]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('14-Day Journey', style: _t(s: 15, w: FontWeight.w700)),
                Text('Your check-in history', style: _t(s: 12, c: _C.textSoft)),
              ]),
            ),
            if (streak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFA040), Color(0xFFFF7A00)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('$streak day streak', style: _t(s: 11, w: FontWeight.w700, c: Colors.white)),
                ]),
              ),
          ]),

          const SizedBox(height: 16),

          // Dot grid — 14 dots in 2 rows of 7
          Row(
            children: List.generate(7, (col) {
              return Expanded(
                child: Column(
                  children: [0, 7].map((rowStart) {
                    final i = rowStart + col;
                    if (i >= 14) return const SizedBox(height: 28);
                    final d = days[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _DayDot(
                        day: d.day,
                        isToday: d.isToday,
                        isFuture: d.isFuture,
                        hasCheckIn: d.hasCheckIn,
                        dayNumber: i + 1,
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),

          // Legend + stats
          const SizedBox(height: 14),
          Row(children: [
            _LegendDot(color: _C.heroB, label: 'Checked in'),
            const SizedBox(width: 14),
            _LegendDot(color: const Color(0xFFEDD8F0), label: 'Missed'),
            const SizedBox(width: 14),
            _LegendDot(color: const Color(0xFFEEEEEE), label: 'Upcoming'),
          ]),

          const SizedBox(height: 14),

          // Summary row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _C.heroA.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _MiniStat(label: 'Check-ins', value: '$checkedInCount/$totalPastDays'),
              _StatDiv(),
              _MiniStat(label: 'Streak', value: '$streak days'),
              _StatDiv(),
              _MiniStat(
                label: 'Completion',
                value: totalPastDays > 0
                    ? '${((checkedInCount / totalPastDays) * 100).round()}%'
                    : '0%',
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final DateTime day;
  final bool isToday, isFuture, hasCheckIn;
  final int dayNumber;

  const _DayDot({
    required this.day,
    required this.isToday,
    required this.isFuture,
    required this.hasCheckIn,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Widget? child;

    if (isToday && hasCheckIn) {
      bg = _C.heroB;
      border = _C.heroB;
      child = const Icon(Icons.check_rounded, size: 12, color: Colors.white);
    } else if (isToday) {
      bg = _C.heroA.withValues(alpha: 0.20);
      border = _C.heroB;
      child = const Icon(Icons.add_rounded, size: 12, color: _C.heroB);
    } else if (isFuture) {
      bg = const Color(0xFFF5F5F5);
      border = const Color(0xFFEEEEEE);
      child = Text(
        '$dayNumber',
        style: _t(s: 9, c: const Color(0xFFCCCCCC), w: FontWeight.w500),
      );
    } else if (hasCheckIn) {
      bg = _C.heroA.withValues(alpha: 0.85);
      border = _C.heroA;
      child = const Icon(Icons.check_rounded, size: 11, color: Colors.white);
    } else {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFEDD8F0);
      child = Text(
        '$dayNumber',
        style: _t(s: 9, c: _C.textFaint, w: FontWeight.w500),
      );
    }

    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: isToday ? 2 : 1),
      ),
      child: Center(child: child),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: _t(s: 10.5, c: _C.textSoft)),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: _t(s: 15, w: FontWeight.w800, c: _C.heroB)),
    const SizedBox(height: 2),
    Text(label, style: _t(s: 10, c: _C.textSoft)),
  ]);
}

class _StatDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 28,
    color: _C.divider,
  );
}


// ═══════════════════════════════════════════════════════════════════════════════
// PHASE GUIDE CARD — "You are here: Diagnosis & Planning"
// Shows what to expect in the current phase
// ═══════════════════════════════════════════════════════════════════════════════
class _PhaseGuideCard extends StatelessWidget {
  final AppProvider app;
  const _PhaseGuideCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final phase = app.journey?.treatmentPhase ?? 'Diagnosis & Planning';
    final (emoji, title, desc, bullets) = _phaseContent(phase);

    return GestureDetector(
      onTap: () => app.setNavIndex(1),
      child: Container(
        decoration: _cardDeco(border: _C.purpleLight),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _C.purpleLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 You are here',
                        style: _t(s: 11, c: _C.textSoft, w: FontWeight.w600),
                      ),
                      Text(
                        title,
                        style: _t(s: 15, w: FontWeight.w700, c: _C.textDark),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _C.textSoft),
              ]),
              const SizedBox(height: 12),
              Text(desc, style: _t(s: 13, c: _C.textMid, h: 1.5)),
              const SizedBox(height: 12),
              Text(
                'What to expect this phase:',
                style: _t(s: 12, w: FontWeight.w600, c: _C.textDark),
              ),
              const SizedBox(height: 8),
              ...bullets.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: TextStyle(color: _C.purple, fontWeight: FontWeight.w700)),
                        Expanded(child: Text(b, style: _t(s: 13, c: _C.textMid, h: 1.4))),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              Text(
                'Read your phase guide →',
                style: _t(s: 13, w: FontWeight.w600, c: _C.heroB),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, String, String, List<String>) _phaseContent(String phase) {
    switch (phase) {
      case 'Chemotherapy':
        return (
          '💊',
          'Chemotherapy',
          'Your body is working hard. Treatment sessions destroy fast-growing cells — including cancer cells.',
          ['Your blood counts may drop — this is expected', 'Nausea peaks 24–48 hours after sessions', 'Rest is medicine — your energy will return', 'Keep tracking so your oncologist can adjust doses'],
        );
      case 'Radiation':
        return (
          '☢️',
          'Radiation Therapy',
          'Daily radiation targets the tumour with precision. Sessions are short, but effects build over time.',
          ['Skin changes in the treated area are normal', 'Fatigue often increases toward week 3–4', 'Stay hydrated — it helps your tissue recover', 'Short walks between sessions can reduce fatigue'],
        );
      case 'Surgery':
        return (
          '🏥',
          'Surgery',
          'You are preparing for or recovering from surgery. Your care team will guide each step.',
          ['Rest is the most important thing right now', 'Watch for signs of infection at the surgical site', 'Pain is manageable — tell your team if it changes', 'Light movement helps circulation and healing'],
        );
      case 'Recovery':
        return (
          '🌱',
          'Recovery',
          'Active treatment is complete. Your body is healing and rebuilding — one day at a time.',
          ['Follow-up scans are a normal part of monitoring', 'Energy returns slowly — be patient with yourself', 'Emotional support matters as much as physical now', 'Your Rehlah data is ready to share at follow-ups'],
        );
      case 'Immunotherapy':
        return (
          '💉',
          'Immunotherapy',
          'Your immune system is being trained to recognise and fight cancer cells.',
          ['Immune reactions can feel like flu symptoms — this is normal', 'Log every new symptom so your team can monitor', 'Infusions are usually every 2–3 weeks', 'Fatigue and joint aches are common side effects'],
        );
      default:
        return (
          '🔬',
          'Diagnosis & Planning',
          'You have just received your diagnosis. This phase is about understanding and preparing.',
          ['Specialist appointments and consultations', 'Biopsy review and imaging results', 'Treatment planning meeting with your care team', 'Your questions matter — write them down in Rehlah'],
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMMUNITY STORY CARD — one survivor story snippet
// "You are not alone on this journey 💜"
// ═══════════════════════════════════════════════════════════════════════════════
class _CommunityStoryCard extends StatelessWidget {
  final AppProvider app;
  const _CommunityStoryCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final phase = app.journey?.treatmentPhase ?? '';
    final (initials, color, quote, detail) = _storyForPhase(phase);

    return GestureDetector(
      onTap: () => app.setNavIndex(4),
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B5DC4).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _C.purpleLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people_rounded, color: _C.purple, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Community', style: _t(s: 13, w: FontWeight.w600, c: _C.textSoft)),
                const Spacer(),
                Text('Read more stories →', style: _t(s: 12, w: FontWeight.w600, c: _C.heroB)),
              ]),
              const SizedBox(height: 14),
              // Story
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: _t(s: 13, w: FontWeight.w700, c: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"$quote"',
                          style: _t(s: 14, w: FontWeight.w500, c: _C.textDark, h: 1.55),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          detail,
                          style: _t(s: 11, c: _C.textSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _C.purpleLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'You are not alone on this journey 💜',
                    style: _t(s: 13, w: FontWeight.w600, c: _C.purple),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color, String, String) _storyForPhase(String phase) {
    switch (phase) {
      case 'Chemotherapy':
        return (
          'NR',
          const Color(0xFF9B5DC4),
          'The nausea passes. The hair grows back. But the strength you find — that stays with you.',
          'Nora · Breast Cancer · Stage II · Week 8 of chemo',
        );
      case 'Radiation':
        return (
          'KA',
          const Color(0xFF2563EB),
          '30 sessions felt like forever. Session 30 felt like a miracle. You will get there too.',
          'Khalid · Prostate Cancer · Stage III · Radiation complete',
        );
      case 'Surgery':
        return (
          'AS',
          const Color(0xFFDC2626),
          'I was terrified going in. I was grateful coming out. Surgery gave me a chance I didn\'t expect.',
          'Aisha · Ovarian Cancer · Stage II · 3 months post-surgery',
        );
      case 'Recovery':
        return (
          'LM',
          const Color(0xFF22C55E),
          'Recovery is not a straight line. Some days you go backwards. But you always find your way.',
          'Laila · Lymphoma · Year 2 of survivorship',
        );
      default:
        return (
          'SR',
          const Color(0xFFF75B9A),
          'Six months in and I\'m still here. One day at a time — that\'s all it takes.',
          'Sara · Breast Cancer · Stage II · 6 months into treatment',
        );
    }
  }
}
