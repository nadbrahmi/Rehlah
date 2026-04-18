import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../providers/lab_provider.dart';
import '../../models/lab_models.dart' show OverallLabStatus;
import '../ai/lab_tracker_screen.dart';
import '../care/medication_tracker_screen.dart';
import '../care/appointment_tracker_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// HOME SCREEN v10 — Rehlah Brand Refresh
// Above-fold: Hero card → Quick 3-item row → Yusr tip (collapsed)
// Background #FCF7FC, Primary #7C3AED, Amber #D97706, Teal #0D9488
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
        vsync: this, duration: const Duration(milliseconds: 420));
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
          backgroundColor: const Color(0xFFFCF7FC),
          body: FadeTransition(
            opacity: _anim,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Pinned top bar
                _TopBar(app: app),

                // ─── ABOVE FOLD ─────────────────────────────────────────
                // Element 1: Hero card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: _HeroCard(app: app, lab: lab),
                  ),
                ),

                // Element 2: Quick access row (3 items only)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _QuickRow(app: app),
                  ),
                ),

                // Element 3: Yusr tip card (collapsed by default)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _YusrTipCard(app: app),
                  ),
                ),

                // ─── BELOW FOLD (accessible via scroll) ─────────────────
                // Missed check-in (if applicable)
                if (!app.hasCheckedInToday)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _MissedCheckInCard(),
                    ),
                  ),

                // Next appointment
                if (app.nextAppointment != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _NextApptCard(app: app),
                    ),
                  ),

                // 14-Day streak progress
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _StreakCard(app: app),
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

// ─── Top bar ─────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final AppProvider app;
  const _TopBar({required this.app});

  @override
  Widget build(BuildContext context) {
    final name = app.journey?.name.split(' ').first ?? 'Rehlah';
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 0,
      collapsedHeight: 56,
      backgroundColor: const Color(0xFFFCF7FC),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      automaticallyImplyLeading: false,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'رحلة',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7C3AED),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d').format(DateTime.now()),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF78716C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              // Avatar
              GestureDetector(
                onTap: () => app.setNavIndex(3),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'R',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ELEMENT 1: Hero card ─────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  const _HeroCard({required this.app, required this.lab});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _journeyDay() {
    final start = app.journey?.treatmentStartDate;
    if (start == null) return 'Your journey starts today.';
    final d = DateTime.now().difference(start).inDays;
    if (d == 0) return 'Day 1 of your journey.';
    return 'Day ${d + 1} of your journey.';
  }

  ({String cta, VoidCallback? action, bool isComplete}) _ctaState(BuildContext ctx) {
    if (app.hasCheckedInToday) {
      return (
        cta: 'View today\'s summary →',
        action: () => _showWeekSheet(ctx, app),
        isComplete: true,
      );
    }
    // Critical lab → redirect to labs
    if (lab.overallStatus == OverallLabStatus.critical) {
      return (
        cta: 'View lab alert →',
        action: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LabTrackerScreen())),
        isComplete: false,
      );
    }
    return (
      cta: 'Begin Check-In',
      action: () => app.setNavIndex(1),
      isComplete: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = app.journey?.name.split(' ').first ?? '';
    final nameStr = name.isNotEmpty ? '$name 🌸' : '🌸';
    final state = _ctaState(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            '${_greeting()}, $nameStr',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1917),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _journeyDay(),
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFF78716C),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          // CTA button — purple (the ONE primary element)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.action,
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isComplete
                    ? const Color(0xFF0D9488)
                    : const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                state.cta,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ELEMENT 2: Quick access row (3 items: Meds, Appointments, Labs) ──────────
class _QuickRow extends StatelessWidget {
  final AppProvider app;
  const _QuickRow({required this.app});

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickItem(
        emoji: '💊',
        label: 'Meds',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MedicationTrackerScreen())),
      ),
      _QuickItem(
        emoji: '📅',
        label: 'Appointments',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AppointmentTrackerScreen())),
      ),
      _QuickItem(
        emoji: '🧪',
        label: 'Labs',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LabTrackerScreen())),
      ),
    ];

    return Row(
      children: items
          .map((item) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: items.indexOf(item) == 0 ? 0 : 6,
                    right: items.indexOf(item) == items.length - 1 ? 0 : 6,
                  ),
                  child: GestureDetector(
                    onTap: item.onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          child: Text(item.emoji,
                              style: const TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF78716C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _QuickItem {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _QuickItem({required this.emoji, required this.label, required this.onTap});
}

// ─── ELEMENT 3: Yusr tip card — collapsed by default ─────────────────────────
class _YusrTipCard extends StatefulWidget {
  final AppProvider app;
  const _YusrTipCard({required this.app});

  @override
  State<_YusrTipCard> createState() => _YusrTipCardState();
}

class _YusrTipCardState extends State<_YusrTipCard> {
  bool _expanded = false;

  static const String _tip =
      'Stay hydrated today — even when nausea makes it hard. Small sips every 15 minutes add up. Keeping fluids up helps your kidneys process medications more effectively and can reduce fatigue.';

  @override
  Widget build(BuildContext context) {
    final shortTip = _tip.split('.').first + '.';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: Color(0xFFD97706), width: 4),
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06), width: 1),
          right: BorderSide(color: Colors.black.withValues(alpha: 0.06), width: 1),
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Yusr avatar
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF7C3AED),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'Y',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Yusr's tip for today",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: Text(
              shortTip,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0xFF1C1917),
                height: 1.7,
              ),
            ),
            secondChild: Text(
              _tip,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0xFF1C1917),
                height: 1.7,
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 260),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show less ↑' : 'Read more →',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF78716C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Missed check-in card (CHANGE 8) — no red, no sad emoji ──────────────────
class _MissedCheckInCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Calm plant illustration (emoji)
          const Text('🪴', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'We saved your spot.',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1917),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ready when you are.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFF78716C),
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                context.read<AppProvider>().setNavIndex(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "Begin Today's Check-In",
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {/* skip for today — no action needed */},
            child: Text(
              'Skip for today',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF78716C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Next Appointment card ────────────────────────────────────────────────────
class _NextApptCard extends StatelessWidget {
  final AppProvider app;
  const _NextApptCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final appt = app.nextAppointment;
    if (appt == null) return const SizedBox.shrink();
    final days = appt.dateTime.difference(DateTime.now()).inDays;
    final daysLabel =
        days == 0 ? 'Today!' : days == 1 ? 'Tomorrow' : 'in $days days';

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AppointmentTrackerScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: Color(0xFFD97706), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appt.title,
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1917))),
              Text('${appt.doctorName} · $daysLabel',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: const Color(0xFF78716C))),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Color(0xFF78716C)),
        ]),
      ),
    );
  }
}

// ─── Streak card ─────────────────────────────────────────────────────────────
class _StreakCard extends StatelessWidget {
  final AppProvider app;
  const _StreakCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final streak = app.checkInStreak;
    final total = app.checkIns.length;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '$streak',
              label: 'Day Streak',
              icon: '🔥',
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFF3E8F5)),
          Expanded(
            child: _StatItem(
              value: '$total',
              label: 'Check-ins',
              icon: '✅',
            ),
          ),
          Container(width: 1, height: 40, color: const Color(0xFFF3E8F5)),
          Expanded(
            child: _StatItem(
              value: '${app.medications.length}',
              label: 'Meds tracked',
              icon: '💊',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label, icon;
  const _StatItem({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 22, fontWeight: FontWeight.w700,
                color: const Color(0xFF1C1917))),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: const Color(0xFF78716C))),
      ],
    );
  }
}

// ─── Week sheet (unchanged logic) ────────────────────────────────────────────
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
    final recent = app.recentCheckIns.take(7).toList();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFE0D7F5),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text('This Week',
              style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1917))),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            Text('No check-ins yet this week.',
                style: GoogleFonts.inter(fontSize: 18, color: const Color(0xFF78716C)))
          else
            ...recent.map((ci) {
              final moodEmojis = ['', '😫', '😔', '😐', '🙂', '😊'];
              final emoji = (ci.moodScore >= 1 && ci.moodScore <= 5)
                  ? moodEmojis[ci.moodScore]
                  : '😐';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          '${ci.date.day}/${ci.date.month} — mood ${ci.moodScore}/5',
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C1917))),
                      if (ci.notes != null && ci.notes!.isNotEmpty)
                        Text(ci.notes!,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF78716C))),
                    ]),
                  ),
                ]),
              );
            }),
        ],
      ),
    );
  }
}
