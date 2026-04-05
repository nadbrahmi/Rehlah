import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../providers/lab_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// APPOINTMENT TRACKER SCREEN
// Upcoming appointments only shown, AI-powered reminders, prep report generator
// ═══════════════════════════════════════════════════════════════════════════════

class AppointmentTrackerScreen extends StatefulWidget {
  const AppointmentTrackerScreen({super.key});
  @override
  State<AppointmentTrackerScreen> createState() => _AppointmentTrackerScreenState();
}

class _AppointmentTrackerScreenState extends State<AppointmentTrackerScreen> {
  bool _showPast = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, LabProvider>(builder: (context, app, lab, _) {
      final now = DateTime.now();
      final upcoming = app.appointments
          .where((a) => a.dateTime.isAfter(now) && !a.isCompleted)
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      final past = app.appointments
          .where((a) => a.dateTime.isBefore(now) || a.isCompleted)
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              collapsedHeight: 60,
              elevation: 0,
              backgroundColor: AppColors.background,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                titlePadding: EdgeInsets.zero,
                title: _CollapsedHeader(count: upcoming.length),
                background: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                    child: Row(children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppColors.primary, size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(DateFormat('EEEE, MMM d').format(now),
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                        Text('Appointments', style: GoogleFonts.inter(
                            fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.1)),
                      ])),
                      _AddApptButton(onTap: () => _showAddSheet(context, app)),
                    ]),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── AI Reminder banner (if next appt within 7 days) ──────
                if (upcoming.isNotEmpty) ...[
                  _AiReminderBanner(appt: upcoming.first, app: app, lab: lab),
                  const SizedBox(height: 20),
                ],

                // ── Upcoming ─────────────────────────────────────────────
                _SectionLabel('UPCOMING APPOINTMENTS'),
                const SizedBox(height: 10),

                if (upcoming.isEmpty)
                  _EmptyAppts(onAdd: () => _showAddSheet(context, app))
                else ...[
                  ...upcoming.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ApptCard(
                      appt: a,
                      app: app,
                      lab: lab,
                      onPrepTap: () => _showPrepSheet(context, a, app, lab),
                      onReportTap: () => _showReportSheet(context, a, app, lab),
                    ),
                  )),
                ],

                const SizedBox(height: 24),

                // ── Past toggle ───────────────────────────────────────────
                if (past.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => setState(() => _showPast = !_showPast),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(children: [
                        Text('Past Appointments (${past.length})',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        const Spacer(),
                        Icon(_showPast ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            color: AppColors.textMuted, size: 20),
                      ]),
                    ),
                  ),
                  if (_showPast) ...[
                    const SizedBox(height: 10),
                    ...past.take(5).map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PastApptCard(appt: a),
                    )),
                  ],
                ],
              ])),
            ),
          ],
        ),
      );
    });
  }

  void _showAddSheet(BuildContext context, AppProvider app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddApptSheet(
        onAdd: (title, doctor, dt, type, location) async {
          await app.addAppointment(Appointment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title, doctorName: doctor, dateTime: dt, type: type, location: location,
          ));
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _showPrepSheet(BuildContext context, Appointment appt, AppProvider app, LabProvider lab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrepChecklist(appt: appt, app: app, lab: lab),
    );
  }

  void _showReportSheet(BuildContext context, Appointment appt, AppProvider app, LabProvider lab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AiReportSheet(appt: appt, app: app, lab: lab),
    );
  }
}

// ── Header add button ─────────────────────────────────────────────────────────
class _AddApptButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddApptButton({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.add_rounded, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text('Add', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
    ),
  );
}

// ── Collapsed header ──────────────────────────────────────────────────────────
class _CollapsedHeader extends StatelessWidget {
  final int count;
  const _CollapsedHeader({required this.count});
  @override
  Widget build(BuildContext context) => Container(
    height: 60, color: AppColors.background,
    padding: const EdgeInsets.symmetric(horizontal: 22),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 18),
      ),
      const SizedBox(width: 12),
      Text('Appointments', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const Spacer(),
      if (count > 0)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
          child: Text('$count upcoming', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ),
    ]),
  );
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1.2));
}

// ── AI Reminder banner ────────────────────────────────────────────────────────
class _AiReminderBanner extends StatefulWidget {
  final Appointment appt;
  final AppProvider app;
  final LabProvider lab;
  const _AiReminderBanner({required this.appt, required this.app, required this.lab});
  @override
  State<_AiReminderBanner> createState() => _AiReminderBannerState();
}

class _AiReminderBannerState extends State<_AiReminderBanner> {
  bool _dismissed = false;

  String _reminderText(int days) {
    final appt = widget.appt;
    final hasCritical = widget.lab.overallStatus == OverallLabStatus.critical;
    final missedMeds = widget.app.recentCheckIns.take(7).where((c) => !c.medicationsTaken).length;

    if (days == 0) {
      return 'Your ${appt.title} is TODAY with ${appt.doctorName}. '
          'Make sure you have your ID, insurance card, and medication list ready.';
    }
    if (days == 1) {
      return 'Tomorrow: ${appt.title} with ${appt.doctorName}. '
          '${hasCritical ? "⚠ You have critical lab values to discuss. " : ""}'
          'Prepare your questions tonight so you don\'t forget them.';
    }
    if (days <= 3) {
      return 'In $days days: ${appt.title} with ${appt.doctorName}. '
          '${missedMeds > 0 ? "You missed $missedMeds doses this week — mention this to your doctor. " : ""}'
          'Log your symptoms daily until the visit for a complete picture.';
    }
    return 'Upcoming in $days days: ${appt.title} with ${appt.doctorName}. '
        'Keep logging daily check-ins so your doctor sees your full health picture.';
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final days = widget.appt.dateTime.difference(DateTime.now()).inDays;
    final isUrgent = days <= 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent
              ? [AppColors.warning.withValues(alpha: 0.12), AppColors.warning.withValues(alpha: 0.06)]
              : [AppColors.heroTop.withValues(alpha: 0.12), AppColors.heroBottom.withValues(alpha: 0.06)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isUrgent ? AppColors.warning.withValues(alpha: 0.35) : AppColors.heroTop.withValues(alpha: 0.30)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isUrgent ? AppColors.warning.withValues(alpha: 0.15) : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(isUrgent ? Icons.notifications_active_rounded : Icons.auto_awesome_rounded,
              color: isUrgent ? AppColors.warning : AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Reminder', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: isUrgent ? AppColors.warning : AppColors.primary, letterSpacing: 0.3)),
          const SizedBox(height: 3),
          Text(_reminderText(days), style: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        ])),
        GestureDetector(
          onTap: () => setState(() => _dismissed = true),
          child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
        ),
      ]),
    );
  }
}

// ── Appointment card ──────────────────────────────────────────────────────────
class _ApptCard extends StatelessWidget {
  final Appointment appt;
  final AppProvider app;
  final LabProvider lab;
  final VoidCallback onPrepTap;
  final VoidCallback onReportTap;
  const _ApptCard({required this.appt, required this.app, required this.lab,
      required this.onPrepTap, required this.onReportTap});

  Color get _typeColor => switch (appt.type.toLowerCase()) {
    'oncologist' => AppColors.primary,
    'lab' => AppColors.info,
    'imaging' => AppColors.warning,
    'surgery' => AppColors.danger,
    'radiation' => AppColors.warning,
    _ => AppColors.primary,
  };

  IconData get _typeIcon => switch (appt.type.toLowerCase()) {
    'oncologist' => Icons.local_hospital_rounded,
    'lab' => Icons.science_rounded,
    'imaging' => Icons.image_search_rounded,
    'surgery' => Icons.medical_services_rounded,
    'radiation' => Icons.radio_button_checked_rounded,
    _ => Icons.calendar_today_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = appt.dateTime.difference(now).inDays;
    final isToday = days == 0 && appt.dateTime.day == now.day;
    final isTomorrow = days == 1;
    final urgentBadge = isToday ? 'Today!' : isTomorrow ? 'Tomorrow' : 'In $days days';
    final badgeColor = isToday ? AppColors.danger
        : isTomorrow ? AppColors.warning
        : days <= 3 ? AppColors.warning
        : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Type icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Urgency badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(urgentBadge, style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor, letterSpacing: 0.3)),
              ),
              const SizedBox(height: 6),
              Text(appt.title, style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(appt.doctorName, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(DateFormat('MMM d, yyyy · h:mm a').format(appt.dateTime),
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              ]),
              if (appt.location != null && appt.location!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(child: Text(appt.location!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted))),
                ]),
              ],
            ])),
          ]),
        ),

        // Action buttons
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.checklist_rounded,
                  label: 'Prep Checklist',
                  color: AppColors.primary,
                  onTap: onPrepTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.description_outlined,
                  label: 'AI Report',
                  color: AppColors.accent,
                  onTap: onReportTap,
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    ),
  );
}

// ── Past appointment card ─────────────────────────────────────────────────────
class _PastApptCard extends StatelessWidget {
  final Appointment appt;
  const _PastApptCard({required this.appt});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
    ),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(11)),
        child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(appt.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        Text('${appt.doctorName} · ${DateFormat('MMM d, yyyy').format(appt.dateTime)}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
        child: Text('Done', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
      ),
    ]),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyAppts extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyAppts({required this.onAdd});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card),
    child: Column(children: [
      Container(width: 56, height: 56,
        decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
        child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 26)),
      const SizedBox(height: 14),
      Text('No upcoming appointments', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Add your next appointment to get AI-powered preparation reminders.',
          textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary, height: 1.5)),
      const SizedBox(height: 18),
      GestureDetector(onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
          decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(12)),
          child: Text('Add Appointment', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        )),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// PREP CHECKLIST SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _PrepChecklist extends StatefulWidget {
  final Appointment appt;
  final AppProvider app;
  final LabProvider lab;
  const _PrepChecklist({required this.appt, required this.app, required this.lab});
  @override
  State<_PrepChecklist> createState() => _PrepChecklistState();
}

class _PrepChecklistState extends State<_PrepChecklist> {
  final Map<String, bool> _checked = {};

  List<({String id, String label, String hint})> get _list {
    final items = <({String id, String label, String hint})>[];
    if (!widget.app.hasCheckedInToday)
      items.add((id: 'ci', label: 'Log today\'s symptoms', hint: 'Gives your doctor your latest status'));
    else
      items.add((id: 'ci', label: 'Today\'s check-in done ✓', hint: 'Symptoms logged'));
    items.add((id: 'meds', label: 'Bring medication list', hint: '${widget.app.medications.where((m) => m.isActive).length} active medications'));
    if (widget.lab.hasData)
      items.add((id: 'labs', label: 'Review lab results', hint: 'Note values outside normal range'));
    items.add((id: 'qns', label: 'Write questions to ask', hint: 'Easy to forget — write them now'));
    items.add((id: 'id', label: 'Bring ID & insurance card', hint: 'Required for registration'));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.appt.dateTime.difference(DateTime.now()).inDays;
    final done = _list.where((i) => _checked[i.id] == true).length;
    final pct = _list.isEmpty ? 1.0 : done / _list.length;
    final accent = days <= 1 ? AppColors.warning : AppColors.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.88, minChildSize: 0.50, maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Prep Checklist', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(widget.appt.title, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
              ])),
              SizedBox(width: 48, height: 48,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(value: pct, strokeWidth: 3.5,
                      backgroundColor: accent.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(accent)),
                  Text('$done/${_list.length}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: accent)),
                ])),
            ]),
          ),
          const SizedBox(height: 4),
          Divider(height: 20, color: AppColors.divider),
          Expanded(
            child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(24, 0, 24, 40), children: [
              ..._list.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _checked[item.id] = !(_checked[item.id] ?? false)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: (_checked[item.id] ?? false) ? accent : Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: (_checked[item.id] ?? false) ? accent : AppColors.border, width: 1.5),
                      ),
                      child: (_checked[item.id] ?? false)
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500,
                          color: (_checked[item.id] ?? false) ? AppColors.textMuted : AppColors.textPrimary,
                          decoration: (_checked[item.id] ?? false) ? TextDecoration.lineThrough : null)),
                      Text(item.hint, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                    ])),
                  ]),
                ),
              )),
              const SizedBox(height: 20),
              // AI talking points
              _TalkingPoints(app: widget.app, lab: widget.lab),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _TalkingPoints extends StatelessWidget {
  final AppProvider app;
  final LabProvider lab;
  const _TalkingPoints({required this.app, required this.lab});

  List<String> get _points {
    final pts = <String>[];
    final r = app.recentCheckIns.take(7).toList();
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
    if (lab.overallStatus != OverallLabStatus.good) pts.add('Lab values outside normal range — review together');
    if (pts.isEmpty) pts.addAll(['Feeling generally okay this week', 'Medications taken consistently']);
    return pts.take(4).toList();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primarySurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.record_voice_over_outlined, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        Text('Tell your doctor', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ]),
      const SizedBox(height: 10),
      ..._points.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 6),
            child: Container(width: 5, height: 5, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.5), shape: BoxShape.circle))),
          const SizedBox(width: 10),
          Expanded(child: Text(p, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.45))),
        ]),
      )),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// AI REPORT SHEET — shareable doctor visit summary
// ═══════════════════════════════════════════════════════════════════════════════
class _AiReportSheet extends StatefulWidget {
  final Appointment appt;
  final AppProvider app;
  final LabProvider lab;
  const _AiReportSheet({required this.appt, required this.app, required this.lab});
  @override
  State<_AiReportSheet> createState() => _AiReportSheetState();
}

class _AiReportSheetState extends State<_AiReportSheet> {
  bool _generating = true;

  @override
  void initState() {
    super.initState();
    // Simulate AI generation delay
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _generating = false);
    });
  }

  String get _reportDate => DateFormat('MMMM d, yyyy').format(DateTime.now());
  String get _apptDate => DateFormat('MMMM d, yyyy').format(widget.appt.dateTime);

  Map<String, String> _buildReport() {
    final r = widget.app.recentCheckIns.take(7).toList();
    final meds = widget.app.medications.where((m) => m.isActive).toList();

    final avgPain = r.isEmpty ? 0.0 : r.map((c) => c.painScore).reduce((a, b) => a + b) / r.length;
    final avgFat = r.isEmpty ? 0.0 : r.map((c) => c.fatigueScore).reduce((a, b) => a + b) / r.length;
    final avgMood = r.isEmpty ? 0.0 : r.map((c) => c.moodScore).reduce((a, b) => a + b) / r.length;
    final adherence = r.isEmpty ? 0.0 : r.where((c) => c.medicationsTaken).length / r.length;

    final patientName = widget.app.journey?.name ?? 'Patient';

    return {
      'patient': patientName,
      'prepared_for': widget.appt.title,
      'doctor': widget.appt.doctorName,
      'visit_date': _apptDate,
      'report_date': _reportDate,
      'symptom_summary': r.isEmpty
          ? 'No check-in data available for this period.'
          : 'Over the past ${r.length} days — Pain: ${avgPain.toStringAsFixed(1)}/5 (${avgPain >= 3 ? "elevated" : "controlled"}), '
            'Fatigue: ${avgFat.toStringAsFixed(1)}/5, Mood: ${avgMood.toStringAsFixed(1)}/5.',
      'medication_adherence': meds.isEmpty
          ? 'No active medications on file.'
          : '${meds.length} active medication${meds.length > 1 ? "s" : ""}: ${meds.map((m) => "${m.name} ${m.dosage}").join(", ")}. '
            'Adherence this week: ${(adherence * 100).round()}%.',
      'lab_status': widget.lab.hasData
          ? 'Labs on file — status: ${widget.lab.overallStatus.name}.'
          : 'No lab data uploaded.',
      'concerns': _buildConcerns(avgPain, avgFat, avgMood, adherence),
    };
  }

  String _buildConcerns(double pain, double fat, double mood, double adh) {
    final items = <String>[];
    if (pain >= 3.5) items.add('Persistent elevated pain (avg ${pain.toStringAsFixed(1)}/5)');
    if (fat >= 3.5) items.add('High fatigue levels (avg ${fat.toStringAsFixed(1)}/5)');
    if (mood <= 2.0) items.add('Low mood scores — psychological support may be beneficial');
    if (adh < 0.7) items.add('Medication adherence below 70% — review challenges');
    if (widget.lab.overallStatus == OverallLabStatus.critical) items.add('Critical lab values require urgent discussion');
    if (items.isEmpty) items.add('No major concerns identified this period');
    return items.join('. ');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90, minChildSize: 0.50, maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: _generating ? _LoadingReport() : _ReportContent(
          report: _buildReport(), ctrl: ctrl, appt: widget.appt),
      ),
    );
  }
}

class _LoadingReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(gradient: AppColors.heroGradient, shape: BoxShape.circle),
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30)),
      const SizedBox(height: 20),
      Text('Generating AI Report...', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Text('Analysing your symptoms, labs, and medications', textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
      const SizedBox(height: 28),
      const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
    ],
  );
}

class _ReportContent extends StatelessWidget {
  final Map<String, String> report;
  final ScrollController ctrl;
  final Appointment appt;
  const _ReportContent({required this.report, required this.ctrl, required this.appt});

  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(height: 12),
    Center(child: Container(width: 36, height: 4,
        decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
    const SizedBox(height: 16),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AI Visit Report', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text('Ready to share with ${appt.doctorName}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
          const SizedBox(width: 4),
          Text('Ready', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
        ]),
      ),
    ])),
    Divider(height: 20, color: AppColors.divider),
    Expanded(
      child: ListView(controller: ctrl, padding: const EdgeInsets.fromLTRB(24, 0, 24, 40), children: [
        // Report header card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.medical_information_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('PATIENT VISIT SUMMARY', style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 1.0)),
            ]),
            const SizedBox(height: 12),
            Text(report['patient']!, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Prepared for: ${report['prepared_for']}', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            Text('With: ${report['doctor']}', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
            Text('Visit date: ${report['visit_date']}', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 16),
        _ReportSection(icon: Icons.monitor_heart_rounded, color: AppColors.primary,
            title: 'Symptom Summary', body: report['symptom_summary']!),
        const SizedBox(height: 12),
        _ReportSection(icon: Icons.medication_rounded, color: AppColors.success,
            title: 'Medication Adherence', body: report['medication_adherence']!),
        const SizedBox(height: 12),
        _ReportSection(icon: Icons.science_rounded, color: AppColors.info,
            title: 'Lab Status', body: report['lab_status']!),
        const SizedBox(height: 12),
        _ReportSection(icon: Icons.warning_amber_rounded, color: AppColors.warning,
            title: 'Key Concerns for Discussion', body: report['concerns']!),
        const SizedBox(height: 20),
        // Footer note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'This report is AI-generated from your app data. '
              'Share it with your care team as a starting point for conversation. '
              'Hospital platform integration coming soon.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
            )),
          ]),
        ),
        const SizedBox(height: 20),
        // Share button
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Report sharing coming with hospital platform integration',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text('Share with Doctor', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    ),
  ]);
}

class _ReportSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, body;
  const _ReportSection({required this.icon, required this.color, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: AppShadows.card,
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 28, height: 28,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 14)),
        const SizedBox(width: 9),
        Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 10),
      Text(body, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.55)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADD APPOINTMENT SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _AddApptSheet extends StatefulWidget {
  final void Function(String title, String doctor, DateTime dt, String type, String location) onAdd;
  const _AddApptSheet({required this.onAdd});
  @override
  State<_AddApptSheet> createState() => _AddApptSheetState();
}

class _AddApptSheetState extends State<_AddApptSheet> {
  final _titleCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime _dt = DateTime.now().add(const Duration(days: 7));
  String _type = 'oncologist';
  final _types = ['oncologist', 'lab', 'imaging', 'surgery', 'radiation', 'general'];

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text('Add Appointment', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 20),
        TextField(controller: _titleCtrl,
          decoration: InputDecoration(labelText: 'Appointment type', hintText: 'e.g. Oncologist Consultation'),
          style: GoogleFonts.inter(fontSize: 15)),
        const SizedBox(height: 12),
        TextField(controller: _doctorCtrl,
          decoration: InputDecoration(labelText: 'Doctor name', hintText: 'e.g. Dr. Al-Rashidi'),
          style: GoogleFonts.inter(fontSize: 15)),
        const SizedBox(height: 12),
        TextField(controller: _locationCtrl,
          decoration: InputDecoration(labelText: 'Location (optional)', hintText: 'e.g. Cleveland Clinic, Abu Dhabi'),
          style: GoogleFonts.inter(fontSize: 15)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _type,
          decoration: const InputDecoration(labelText: 'Appointment type'),
          items: _types.map((t) => DropdownMenuItem(
            value: t,
            child: Text(t[0].toUpperCase() + t.substring(1), style: GoogleFonts.inter(fontSize: 14)),
          )).toList(),
          onChanged: (v) => setState(() => _type = v!),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dt,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_dt),
              );
              if (time != null && mounted) {
                setState(() => _dt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute));
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(children: [
              Icon(Icons.schedule_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(DateFormat('EEE, MMM d, yyyy · h:mm a').format(_dt),
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary))),
              Text('Change', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_titleCtrl.text.trim().isEmpty || _doctorCtrl.text.trim().isEmpty) return;
              widget.onAdd(
                _titleCtrl.text.trim(), _doctorCtrl.text.trim(),
                _dt, _type, _locationCtrl.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Add Appointment', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
          ),
        ),
      ])),
    ),
  );
}
