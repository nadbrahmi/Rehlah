import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../providers/lab_provider.dart';
import '../../models/models.dart';

// ─── Shared palette ───────────────────────────────────────────────────────────
class _C {
  static const bg         = Color(0xFFFCF7FC);
  static const card       = Color(0xFFFFFFFF);
  static const heroA      = Color(0xFFD894D3);
  static const heroB      = Color(0xFFC178BB);
  static const heroC      = Color(0xFFBD6BB8);
  static const purple     = Color(0xFF9B5DC4);
  static const purpleLight= Color(0xFFEEE0F9);
  static const purpleMid  = Color(0xFFD370C8);
  static const rose       = Color(0xFFF75B9A);
  static const textDark   = Color(0xFF3A2A3F);
  static const textMid    = Color(0xFF6B4F72);
  static const textSoft   = Color(0xFFB68AB3);
  static const textFaint  = Color(0xFFCCA8CC);
  static const greenBg    = Color(0xFFEAF8EC);
  static const greenFg    = Color(0xFF22C55E);
  static const greenDark  = Color(0xFF166534);
  static const peachBg    = Color(0xFFFFF1E4);
  static const peachFg    = Color(0xFFFF7A00);
  static const divider    = Color(0xFFF3E8F5);
  static const border     = Color(0xFFEDD8F0);
}

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
        decorationColor: c);

BoxDecoration _cardDeco({double r = 20, Color? border}) => BoxDecoration(
      color: _C.card,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(
          color: border ?? _C.border.withValues(alpha: 0.50)),
      boxShadow: [
        BoxShadow(
            color: const Color(0xFF9B5DC4).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 4)),
      ],
    );

// ═══════════════════════════════════════════════════════════════════════════════
class AppointmentTrackerScreen extends StatefulWidget {
  const AppointmentTrackerScreen({super.key});

  @override
  State<AppointmentTrackerScreen> createState() =>
      _AppointmentTrackerScreenState();
}

class _AppointmentTrackerScreenState extends State<AppointmentTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, LabProvider>(
      builder: (context, app, lab, _) {
        final upcoming = app.appointments
            .where((a) => a.dateTime.isAfter(DateTime.now()) && !a.isCompleted)
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        final past = app.appointments
            .where((a) =>
                a.dateTime.isBefore(DateTime.now()) || a.isCompleted)
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return Scaffold(
          backgroundColor: _C.bg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Header ─────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                floating: false,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_C.heroA, _C.heroB, _C.heroC],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 48, 20, 0),
                        child: Row(children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('My Appointments',
                                  style: _t(
                                      s: 20,
                                      w: FontWeight.w700,
                                      c: Colors.white)),
                              Text(
                                '${upcoming.length} upcoming  ·  AI reminders',
                                style: _t(
                                    s: 12,
                                    c: Colors.white
                                        .withValues(alpha: 0.75)),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ),
                  title: Container(
                    color: const Color(0xFFBD6BB8).withValues(alpha: 0.95),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('My Appointments',
                        style: _t(
                            s: 17,
                            w: FontWeight.w700,
                            c: Colors.white)),
                  ),
                  titlePadding: EdgeInsets.zero,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  child: Container(
                    color: _C.heroC,
                    child: TabBar(
                      controller: _tab,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Colors.white.withValues(alpha: 0.60),
                      labelStyle: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700),
                      unselectedLabelStyle:
                          GoogleFonts.inter(fontSize: 13),
                      tabs: const [
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Past'),
                      ],
                    ),
                  ),
                ),
              ),

              // ── AI Reminder Card (if upcoming) ───────────────────────
              if (upcoming.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _AiReminderCard(
                        next: upcoming.first, app: app, lab: lab),
                  ),
                ),

              // ── Tab content ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _UpcomingTab(
                          appointments: upcoming, app: app, lab: lab),
                      _PastTab(appointments: past, app: app),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddSheet(context, app),
            backgroundColor: _C.purple,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('Add Appointment',
                style: _t(s: 13, w: FontWeight.w700, c: Colors.white)),
          ),
        );
      },
    );
  }

  void _showAddSheet(BuildContext ctx, AppProvider app) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddApptSheet(app: app),
    );
  }
}

// ─── AI Reminder Card ─────────────────────────────────────────────────────────
class _AiReminderCard extends StatelessWidget {
  final Appointment next;
  final AppProvider app;
  final LabProvider lab;
  const _AiReminderCard(
      {required this.next, required this.app, required this.lab});

  @override
  Widget build(BuildContext context) {
    final days = next.dateTime.difference(DateTime.now()).inDays;
    final hours = next.dateTime.difference(DateTime.now()).inHours;

    // AI-generated reminder text
    final tips = <String>[];
    if (!app.hasCheckedInToday) {
      tips.add('Log today\'s symptoms before your appointment so your doctor has the latest data');
    }
    if (lab.hasData && lab.overallStatus != OverallLabStatus.good) {
      tips.add('Your latest labs have values outside normal range — bring your results to discuss');
    }
    final missed = app.recentCheckIns
        .take(7)
        .where((c) => !c.medicationsTaken)
        .length;
    if (missed > 0) {
      tips.add('Missed medications $missed time${missed > 1 ? "s" : ""} this week — mention this to your doctor');
    }
    if (app.recentCheckIns.isNotEmpty) {
      final avgPain = app.recentCheckIns.take(7).map((c) => c.painScore)
              .reduce((a, b) => a + b) /
          app.recentCheckIns.take(7).length;
      if (avgPain >= 3.0) {
        tips.add('Pain has been elevated (avg ${avgPain.toStringAsFixed(1)}/5) — ask about pain management options');
      }
    }
    if (tips.isEmpty) {
      tips.add('Write down any questions you have before the appointment');
      tips.add('Bring your insurance card and a list of current medications');
    }

    final urgencyColor = days == 0
        ? _C.rose
        : days <= 2
            ? _C.peachFg
            : _C.heroB;
    final urgencyBg = days == 0
        ? _C.peachBg
        : days <= 2
            ? _C.peachBg
            : _C.purpleLight;

    return Container(
      decoration: _cardDeco(border: urgencyColor.withValues(alpha: 0.35)),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_C.purple, _C.purpleMid]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Appointment Reminder',
                        style:
                            _t(s: 14, w: FontWeight.w700, c: _C.textDark)),
                    Text(next.title,
                        style: _t(s: 12, c: _C.textSoft)),
                  ]),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: urgencyBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                days == 0
                    ? 'Today!'
                    : days < 1
                        ? 'In ${hours}h'
                        : '$days days',
                style: _t(
                    s: 12, w: FontWeight.w700, c: urgencyColor),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          ...tips.take(3).map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 7),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            color: urgencyColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(tip,
                              style: _t(s: 12.5, c: _C.textMid, h: 1.5))),
                    ]),
              )),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showPrepReport(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_C.purple, _C.purpleMid]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description_outlined,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text('Generate Doctor-Ready Report',
                      style: _t(
                          s: 13, w: FontWeight.w700, c: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrepReport(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrepReportSheet(app: app, lab: lab, appt: next),
    );
  }
}

// ─── Upcoming Appointments Tab ────────────────────────────────────────────────
class _UpcomingTab extends StatelessWidget {
  final List<Appointment> appointments;
  final AppProvider app;
  final LabProvider lab;
  const _UpcomingTab(
      {required this.appointments, required this.app, required this.lab});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          const SizedBox(height: 40),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: _C.purpleLight,
                borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.calendar_today_outlined,
                color: _C.purple, size: 36),
          ),
          const SizedBox(height: 16),
          Text('No upcoming appointments',
              style: _t(s: 16, w: FontWeight.w600, c: _C.textDark)),
          const SizedBox(height: 6),
          Text('Tap "Add Appointment" to schedule one.',
              textAlign: TextAlign.center,
              style: _t(s: 13, c: _C.textSoft)),
        ]),
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        children: appointments
            .map((a) => _ApptCard(
                  appt: a,
                  showPrep: true,
                  onComplete: () => app.completeAppointment(a.id),
                  onPrepReport: () =>
                      _openPrepReport(context, a),
                ))
            .toList(),
      ),
    );
  }

  void _openPrepReport(BuildContext ctx, Appointment appt) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrepReportSheet(app: app, lab: lab, appt: appt),
    );
  }
}

// ─── Past Appointments Tab ────────────────────────────────────────────────────
class _PastTab extends StatelessWidget {
  final List<Appointment> appointments;
  final AppProvider app;
  const _PastTab({required this.appointments, required this.app});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          const SizedBox(height: 40),
          Text('No past appointments yet',
              style: _t(s: 16, w: FontWeight.w600, c: _C.textDark)),
        ]),
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        children: appointments
            .map((a) => _ApptCard(
                  appt: a,
                  showPrep: false,
                  onComplete: null,
                  onPrepReport: null,
                ))
            .toList(),
      ),
    );
  }
}

// ─── Appointment Card ─────────────────────────────────────────────────────────
class _ApptCard extends StatelessWidget {
  final Appointment appt;
  final bool showPrep;
  final VoidCallback? onComplete;
  final VoidCallback? onPrepReport;
  const _ApptCard({
    required this.appt,
    required this.showPrep,
    required this.onComplete,
    required this.onPrepReport,
  });

  IconData get _typeIcon {
    switch (appt.type) {
      case 'oncologist': return Icons.person_pin_rounded;
      case 'lab': return Icons.science_outlined;
      case 'imaging': return Icons.biotech_rounded;
      case 'chemo': return Icons.medication_liquid_rounded;
      default: return Icons.local_hospital_rounded;
    }
  }

  Color get _typeColor {
    switch (appt.type) {
      case 'oncologist': return _C.purple;
      case 'lab': return const Color(0xFF3B82F6);
      case 'imaging': return const Color(0xFF10B981);
      case 'chemo': return _C.rose;
      default: return _C.heroB;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = appt.dateTime.difference(DateTime.now()).inDays;
    final isPast = appt.isCompleted || appt.dateTime.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _cardDeco(),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: isPast ? 0.10 : 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon,
                  color: isPast
                      ? _typeColor.withValues(alpha: 0.5)
                      : _typeColor,
                  size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.title,
                        style: _t(
                            s: 15,
                            w: FontWeight.w600,
                            c: isPast ? _C.textSoft : _C.textDark)),
                    Text(appt.doctorName,
                        style: _t(s: 12, c: _C.textSoft)),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEE, MMM d  ·  h:mm a')
                          .format(appt.dateTime),
                      style: _t(s: 12, c: _C.textSoft),
                    ),
                    if (appt.location != null) ...[
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 12, color: _C.textFaint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(appt.location!,
                              style: _t(s: 11, c: _C.textFaint),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ]),
            ),
            if (!isPast)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: days <= 1 ? _C.peachBg : _C.purpleLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  days == 0
                      ? 'Today'
                      : days == 1
                          ? 'Tomorrow'
                          : '$days days',
                  style: _t(
                      s: 11,
                      w: FontWeight.w700,
                      c: days <= 1 ? _C.peachFg : _C.purple),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _C.greenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Done',
                    style: _t(
                        s: 11, w: FontWeight.w700, c: _C.greenDark)),
              ),
          ]),
        ),
        if (showPrep && !isPast)
          Container(
            decoration: BoxDecoration(
              color: _C.purpleLight.withValues(alpha: 0.50),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: onPrepReport,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description_outlined,
                            color: _C.purple, size: 14),
                        const SizedBox(width: 6),
                        Text('AI Prep Report',
                            style: _t(
                                s: 12,
                                w: FontWeight.w700,
                                c: _C.purple)),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                  width: 1, height: 32,
                  color: _C.border.withValues(alpha: 0.5)),
              Expanded(
                child: GestureDetector(
                  onTap: onComplete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            color: _C.greenFg, size: 14),
                        const SizedBox(width: 6),
                        Text('Mark Complete',
                            style: _t(
                                s: 12,
                                w: FontWeight.w700,
                                c: _C.greenDark)),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

// ─── Doctor-Ready Prep Report Sheet ──────────────────────────────────────────
class _PrepReportSheet extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  final Appointment appt;
  const _PrepReportSheet(
      {required this.app, required this.lab, required this.appt});

  List<String> _symptoms() {
    final r = app.recentCheckIns.take(7).toList();
    if (r.isEmpty) return ['No recent symptom data'];
    final avgPain    = r.map((c) => c.painScore).reduce((a, b) => a + b) / r.length;
    final avgFatigue = r.map((c) => c.fatigueScore).reduce((a, b) => a + b) / r.length;
    final avgNausea  = r.map((c) => c.nauseaScore).reduce((a, b) => a + b) / r.length;
    final avgMood    = r.map((c) => c.moodScore).reduce((a, b) => a + b) / r.length;
    return [
      'Pain level: ${avgPain.toStringAsFixed(1)}/5 avg over 7 days',
      'Fatigue: ${avgFatigue.toStringAsFixed(1)}/5 avg over 7 days',
      'Nausea: ${avgNausea.toStringAsFixed(1)}/5 avg over 7 days',
      'Mood: ${avgMood.toStringAsFixed(1)}/5 avg over 7 days',
      'Medication adherence: ${(app.medAdherenceRate(days: 7) * 100).round()}% (7 days)',
    ];
  }

  List<String> _questions() {
    final qs = <String>[];
    final r = app.recentCheckIns.take(7).toList();
    if (r.isNotEmpty) {
      final avgPain = r.map((c) => c.painScore).reduce((a, b) => a + b) / r.length;
      final avgFat  = r.map((c) => c.fatigueScore).reduce((a, b) => a + b) / r.length;
      if (avgPain >= 3.0) qs.add('Can we review my pain management plan?');
      if (avgFat >= 3.5)  qs.add('Any recommendations for treatment fatigue?');
    }
    if (lab.overallStatus != OverallLabStatus.good) {
      qs.add('Can you explain my recent lab values?');
    }
    qs.add('Am I on track with my treatment plan?');
    qs.add('What warning signs should I watch for?');
    if (app.medications.isNotEmpty && app.medAdherenceRate(days: 7) < 0.8) {
      qs.add('Can we simplify my medication schedule?');
    }
    return qs.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    final days = appt.dateTime.difference(DateTime.now()).inDays;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: _C.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Container(
                width: 50,
                height: 58,
                decoration: BoxDecoration(
                  color: _C.purpleLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        days == 0 ? '!' : '$days',
                        style: GoogleFonts.inter(
                            fontSize: days > 9 ? 18 : 24,
                            fontWeight: FontWeight.w900,
                            color: _C.heroB),
                      ),
                      Text(
                          days == 0
                              ? 'TODAY'
                              : days == 1
                                  ? 'DAY'
                                  : 'DAYS',
                          style: _t(
                              s: 8,
                              w: FontWeight.w700,
                              c: _C.textSoft,
                              ls: 0.5)),
                    ]),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Doctor-Ready Report',
                          style: _t(
                              s: 17, w: FontWeight.w700, c: _C.textDark)),
                      Text(appt.title,
                          style: _t(s: 13, c: _C.textSoft)),
                      Text(
                          '${appt.doctorName}  ·  '
                          '${DateFormat("MMM d, h:mm a").format(appt.dateTime)}',
                          style: _t(s: 12, c: _C.textFaint)),
                    ]),
              ),
            ]),
          ),

          const Divider(height: 24, color: _C.divider),

          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              children: [
                // Note
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _C.purpleLight.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: _C.purple, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AI-generated from your recent check-ins and lab data. Share with your doctor for context.',
                        style: _t(s: 12, c: _C.textMid, h: 1.5),
                      ),
                    ),
                  ]),
                ),

                // Symptom Summary
                _ReportSection(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Symptom Summary (Last 7 Days)',
                  color: _C.heroB,
                  items: _symptoms(),
                ),

                const SizedBox(height: 20),

                // Medications
                _ReportSection(
                  icon: Icons.medication_rounded,
                  title: 'Current Medications',
                  color: _C.purple,
                  items: app.medications
                      .where((m) => m.isActive)
                      .map((m) => '${m.name} · ${m.dosage} · ${m.frequency}')
                      .toList()
                      .isEmpty
                      ? ['No medications listed']
                      : app.medications
                          .where((m) => m.isActive)
                          .map((m) => '${m.name} · ${m.dosage} · ${m.frequency}')
                          .toList(),
                ),

                const SizedBox(height: 20),

                // Lab Results
                if (lab.hasData) ...[
                  _ReportSection(
                    icon: Icons.science_outlined,
                    title: 'Recent Lab Status',
                    color: lab.overallStatus == OverallLabStatus.good
                        ? _C.greenFg
                        : _C.peachFg,
                    items: [
                      'Overall status: ${lab.overallStatus == OverallLabStatus.good ? "Stable ✓" : lab.overallStatus == OverallLabStatus.caution ? "Review ⚠" : "Critical ✕"}',
                      ...lab.trackedMetrics.take(4).map((k) {
                        final v = lab.latestFor(k);
                        return v != null ? '$k: ${v.value}' : '$k: no data';
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Questions to Ask
                _ReportSection(
                  icon: Icons.help_outline_rounded,
                  title: 'Suggested Questions for Doctor',
                  color: _C.greenFg,
                  items: _questions(),
                  bulletColor: _C.greenFg,
                ),

                const SizedBox(height: 24),

                // Share button
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Report sharing will be available when connected to your hospital platform.',
                            style: GoogleFonts.inter(fontSize: 13)),
                        backgroundColor: _C.purple,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_C.purple, _C.purpleMid]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_outlined,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text('Share with Care Team',
                              style: _t(
                                  s: 14,
                                  w: FontWeight.w700,
                                  c: Colors.white)),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> items;
  final Color? bulletColor;
  const _ReportSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
    this.bulletColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(title,
              style: _t(s: 13, w: FontWeight.w700, c: color)),
        ]),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                          color: (bulletColor ?? _C.textFaint)
                              .withValues(alpha: 0.60),
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(item,
                            style: _t(s: 13, c: _C.textMid, h: 1.5))),
                  ]),
            )),
      ],
    );
  }
}

// ─── Add Appointment Bottom Sheet ─────────────────────────────────────────────
class _AddApptSheet extends StatefulWidget {
  final AppProvider app;
  const _AddApptSheet({required this.app});

  @override
  State<_AddApptSheet> createState() => _AddApptSheetState();
}

class _AddApptSheetState extends State<_AddApptSheet> {
  final _titleCtrl    = TextEditingController();
  final _doctorCtrl   = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();
  String _type        = 'oncologist';
  DateTime _dateTime  = DateTime.now().add(const Duration(days: 7));

  static const _types = [
    ('oncologist', 'Oncologist', Icons.person_pin_rounded),
    ('lab',        'Lab Work',   Icons.science_outlined),
    ('imaging',    'Imaging',    Icons.biotech_rounded),
    ('chemo',      'Chemo',      Icons.medication_liquid_rounded),
    ('other',      'Other',      Icons.local_hospital_rounded),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _doctorCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.purple,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      if (!mounted) return;
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );
      setState(() {
        _dateTime = DateTime(
          d.year, d.month, d.day,
          t?.hour ?? _dateTime.hour,
          t?.minute ?? _dateTime.minute,
        );
      });
    }
  }

  void _save() {
    final title  = _titleCtrl.text.trim();
    final doctor = _doctorCtrl.text.trim();
    if (title.isEmpty || doctor.isEmpty) return;
    widget.app.addAppointment(Appointment(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      doctorName: doctor,
      dateTime: _dateTime,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      type: _type,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _C.border,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Add Appointment',
                style: _t(s: 19, w: FontWeight.w700, c: _C.textDark)),
            const SizedBox(height: 20),

            _SheetField(ctrl: _titleCtrl, label: 'Appointment Title', hint: 'e.g. Oncologist Visit'),
            const SizedBox(height: 14),
            _SheetField(ctrl: _doctorCtrl, label: 'Doctor / Specialist', hint: 'e.g. Dr. Sarah Chen'),
            const SizedBox(height: 14),

            // Type selector
            Text('Type', style: _t(s: 13, w: FontWeight.w600, c: _C.textMid)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((rec) {
                final (val, label, icon) = rec;
                final sel = _type == val;
                return GestureDetector(
                  onTap: () => setState(() => _type = val),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? _C.purple : _C.purpleLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icon,
                          size: 14,
                          color: sel ? Colors.white : _C.purple),
                      const SizedBox(width: 6),
                      Text(label,
                          style: _t(
                              s: 12,
                              w: FontWeight.w600,
                              c: sel ? Colors.white : _C.purple)),
                    ]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Date / Time picker
            Text('Date & Time',
                style: _t(s: 13, w: FontWeight.w600, c: _C.textMid)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _C.purpleLight.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: _C.purple, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('EEE, MMM d, yyyy  ·  h:mm a')
                        .format(_dateTime),
                    style: _t(s: 14, c: _C.textDark),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_rounded,
                      color: _C.textSoft, size: 16),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            _SheetField(ctrl: _locationCtrl, label: 'Location (optional)', hint: 'e.g. Oncology Clinic, Floor 3'),
            const SizedBox(height: 14),
            _SheetField(ctrl: _notesCtrl, label: 'Notes (optional)', hint: 'Any prep notes…'),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_C.purple, _C.purpleMid]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Add Appointment',
                        style: _t(
                            s: 15, w: FontWeight.w700, c: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  const _SheetField(
      {required this.ctrl, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _t(s: 13, w: FontWeight.w600, c: _C.textMid)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: _t(s: 14, c: _C.textDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _t(s: 14, c: _C.textFaint),
            filled: true,
            fillColor: _C.purpleLight.withValues(alpha: 0.40),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
