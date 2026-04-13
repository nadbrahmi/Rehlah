import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICATION TRACKER SCREEN
// AI-powered per-medication check-off with time logging, adherence tracking
// ═══════════════════════════════════════════════════════════════════════════════

// Local state: tracks which meds have been marked taken today + time
class _MedState {
  bool taken;
  DateTime? takenAt;
  _MedState({this.taken = false, this.takenAt});
}

class MedicationTrackerScreen extends StatefulWidget {
  const MedicationTrackerScreen({super.key});
  @override
  State<MedicationTrackerScreen> createState() => _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen> {
  final Map<String, _MedState> _states = {};
  bool _showAiInsight = true;

  _MedState _stateFor(String id) => _states.putIfAbsent(id, () => _MedState());

  int _takenCount(List<Medication> meds) =>
      meds.where((m) => _stateFor(m.id).taken).length;

  String _aiInsight(List<Medication> meds) {
    final taken = _takenCount(meds);
    final total = meds.length;
    if (total == 0) return 'Add your medications to start tracking.';
    final pct = taken / total;
    if (pct == 1.0) return 'All medications taken today — excellent adherence! Consistent intake maximises treatment effectiveness.';
    if (pct >= 0.5) return 'Good progress — $taken of $total done. Try to take remaining medications before ${_nextWindow()}.';
    if (taken == 0) return 'You haven\'t logged any medications yet today. Starting your routine now helps maintain consistent blood levels.';
    return 'You\'ve taken $taken of $total medications. Log the remaining ones when you\'re ready — consistency is key.';
  }

  String _nextWindow() {
    final h = DateTime.now().hour;
    if (h < 12) return '12:00 PM';
    if (h < 18) return '6:00 PM';
    return '9:00 PM';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, app, _) {
      final meds = app.medications.where((m) => m.isActive).toList();
      final taken = _takenCount(meds);
      final total = meds.length;
      final pct = total == 0 ? 1.0 : taken / total;

      return Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              collapsedHeight: 60,
              elevation: 0,
              backgroundColor: AppColors.background,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                titlePadding: EdgeInsets.zero,
                title: _CollapsedBar(taken: taken, total: total),
                background: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
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
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(DateFormat('EEEE, MMM d').format(DateTime.now()),
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                            Text('Medications', style: GoogleFonts.inter(
                                fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.1)),
                          ]),
                          const Spacer(),
                          _AdherenceRing(pct: pct, taken: taken, total: total),
                        ]),
                        const SizedBox(height: 14),
                        _AdherenceBar(pct: pct),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── AI Insight ───────────────────────────────────────────
                if (_showAiInsight) ...[
                  _AiInsightBanner(
                    insight: _aiInsight(meds),
                    onDismiss: () => setState(() => _showAiInsight = false),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Today's Medications ──────────────────────────────────
                _SectionLabel('TODAY\'S MEDICATIONS'),
                const SizedBox(height: 10),

                if (meds.isEmpty)
                  _EmptyMeds(onAdd: () => _showAddMedSheet(context, app))
                else ...[
                  ...meds.map((med) {
                    final s = _stateFor(med.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MedCard(
                        med: med,
                        state: s,
                        onToggle: () {
                          setState(() {
                            if (!s.taken) {
                              s.taken = true;
                              s.takenAt = DateTime.now();
                            } else {
                              s.taken = false;
                              s.takenAt = null;
                            }
                          });
                        },
                        onLogTime: () => _showTimeLogger(context, med, s),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  _AddMedButton(onTap: () => _showAddMedSheet(context, app)),
                ],

                const SizedBox(height: 28),

                // ── Adherence History ─────────────────────────────────────
                _SectionLabel('THIS WEEK\'S ADHERENCE'),
                const SizedBox(height: 10),
                _WeekAdherence(app: app),

                const SizedBox(height: 28),

                // ── AI Tips ───────────────────────────────────────────────
                _SectionLabel('MEDICATION TIPS'),
                const SizedBox(height: 10),
                _AiTipsCard(meds: meds),
              ])),
            ),
          ],
        ),

        // ── FAB: Mark All Taken ──────────────────────────────────────────
        floatingActionButton: meds.isNotEmpty && taken < total
            ? FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    final now = DateTime.now();
                    for (final m in meds) {
                      final s = _stateFor(m.id);
                      if (!s.taken) { s.taken = true; s.takenAt = now; }
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('All ${meds.length} medications marked taken ✓',
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 2),
                  ));
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: Text('Mark All Taken', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              )
            : null,
      );
    });
  }

  void _showTimeLogger(BuildContext context, Medication med, _MedState s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TimeLogSheet(
        med: med,
        currentTime: s.takenAt,
        onSave: (time) {
          setState(() { s.taken = true; s.takenAt = time; });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddMedSheet(BuildContext context, AppProvider app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMedSheet(
        onAdd: (name, dosage, freq) async {
          await app.addMedication(Medication(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name, dosage: dosage, frequency: freq,
          ));
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Collapsed bar ─────────────────────────────────────────────────────────────
class _CollapsedBar extends StatelessWidget {
  final int taken, total;
  const _CollapsedBar({required this.taken, required this.total});
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
      Text('Medications', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
        child: Text('$taken/$total today', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
      ),
    ]),
  );
}

// ── Adherence ring ────────────────────────────────────────────────────────────
class _AdherenceRing extends StatelessWidget {
  final double pct;
  final int taken, total;
  const _AdherenceRing({required this.pct, required this.taken, required this.total});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 56, height: 56,
    child: Stack(alignment: Alignment.center, children: [
      CircularProgressIndicator(
        value: pct,
        strokeWidth: 5,
        backgroundColor: AppColors.primarySurface,
        valueColor: AlwaysStoppedAnimation<Color>(
          pct == 1.0 ? AppColors.success : AppColors.primary),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$taken', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.0)),
        Text('/$total', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted, height: 1.0)),
      ]),
    ]),
  );
}

// ── Adherence bar ─────────────────────────────────────────────────────────────
class _AdherenceBar extends StatelessWidget {
  final double pct;
  const _AdherenceBar({required this.pct});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text('Today\'s adherence', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
        const Spacer(),
        Text('${(pct * 100).round()}%', style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: pct == 1.0 ? AppColors.success : AppColors.primary)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct, minHeight: 6,
          backgroundColor: AppColors.primarySurface,
          valueColor: AlwaysStoppedAnimation<Color>(
            pct == 1.0 ? AppColors.success : AppColors.primary),
        ),
      ),
    ],
  );
}

// ── AI Insight banner ─────────────────────────────────────────────────────────
class _AiInsightBanner extends StatelessWidget {
  final String insight;
  final VoidCallback onDismiss;
  const _AiInsightBanner({required this.insight, required this.onDismiss});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.primaryLight.withValues(alpha: 0.06)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('AI Insight', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 0.3)),
        const SizedBox(height: 3),
        Text(insight, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      ])),
      GestureDetector(
        onTap: onDismiss,
        child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
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

// ── Med card ──────────────────────────────────────────────────────────────────
class _MedCard extends StatelessWidget {
  final Medication med;
  final _MedState state;
  final VoidCallback onToggle;
  final VoidCallback onLogTime;
  const _MedCard({required this.med, required this.state, required this.onToggle, required this.onLogTime});

  @override
  Widget build(BuildContext context) {
    final taken = state.taken;
    return Container(
      decoration: BoxDecoration(
        color: taken ? AppColors.successLight : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: taken ? AppColors.success.withValues(alpha: 0.30) : AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          // Check button
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: taken ? AppColors.success : AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: taken ? AppColors.success : AppColors.primary.withValues(alpha: 0.30),
                  width: 2,
                ),
              ),
              child: Icon(
                taken ? Icons.check_rounded : Icons.medication_outlined,
                color: taken ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(med.name, style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: taken ? AppColors.successDark : AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('${med.dosage} · ${med.frequency}', style: GoogleFonts.inter(
                fontSize: 12, color: taken ? AppColors.successDark.withValues(alpha: 0.65) : AppColors.textTertiary)),
            if (taken && state.takenAt != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.schedule_rounded, size: 12, color: AppColors.success),
                const SizedBox(width: 4),
                Text('Taken at ${DateFormat('h:mm a').format(state.takenAt!)}',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
              ]),
            ],
          ])),
          // Right action
          if (!taken)
            GestureDetector(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Mark Taken', style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            )
          else
            GestureDetector(
              onTap: onLogTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.30)),
                ),
                child: Text('Edit time', style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
              ),
            ),
        ]),
      ),
    );
  }
}

// ── Add med button ────────────────────────────────────────────────────────────
class _AddMedButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMedButton({required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20), style: BorderStyle.solid),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text('Add Medication', style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
    ),
  );
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyMeds extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMeds({required this.onAdd});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card),
    child: Column(children: [
      Container(width: 56, height: 56,
        decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
        child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 28)),
      const SizedBox(height: 14),
      Text('No medications yet', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Add your medications to start tracking daily adherence.', textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary, height: 1.5)),
      const SizedBox(height: 18),
      GestureDetector(onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
          decoration: BoxDecoration(gradient: AppColors.cardGradient, borderRadius: BorderRadius.circular(12)),
          child: Text('Add First Medication', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        )),
    ]),
  );
}

// ── Week adherence mini chart ─────────────────────────────────────────────────
class _WeekAdherence extends StatelessWidget {
  final AppProvider app;
  const _WeekAdherence({required this.app});
  @override
  Widget build(BuildContext context) {
    final recent = app.recentCheckIns.take(7).toList().reversed.toList();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.card),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final hasData = i < recent.length;
            final taken = hasData ? recent[i].medicationsTaken : null;
            final date = DateTime.now().subtract(Duration(days: 6 - i));
            final isToday = date.day == DateTime.now().day;
            return Column(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: taken == true ? AppColors.successLight
                      : taken == false ? AppColors.warningLight
                      : AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isToday ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(child: Icon(
                  taken == true ? Icons.check_rounded
                      : taken == false ? Icons.close_rounded
                      : Icons.remove_rounded,
                  size: 16,
                  color: taken == true ? AppColors.success
                      : taken == false ? AppColors.warning
                      : AppColors.textMuted,
                )),
              ),
              const SizedBox(height: 5),
              Text(DateFormat('E').format(date).substring(0, 1),
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
                      color: isToday ? AppColors.primary : AppColors.textMuted)),
            ]);
          }),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Legend(color: AppColors.success, label: 'Taken'),
          const SizedBox(width: 16),
          _Legend(color: AppColors.warning, label: 'Missed'),
          const SizedBox(width: 16),
          _Legend(color: AppColors.textMuted, label: 'No data'),
        ]),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color; final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
  ]);
}

// ── AI Tips card ──────────────────────────────────────────────────────────────
class _AiTipsCard extends StatelessWidget {
  final List<Medication> meds;
  const _AiTipsCard({required this.meds});

  static const _tips = [
    (icon: Icons.schedule_rounded, color: AppColors.primary,
     text: 'Take medications at the same time daily to maintain consistent blood levels.'),
    (icon: Icons.restaurant_rounded, color: AppColors.warning,
     text: 'Some medications work best with food — check your prescription notes.'),
    (icon: Icons.water_drop_rounded, color: AppColors.info,
     text: 'Drink a full glass of water with each medication for proper absorption.'),
    (icon: Icons.notifications_active_rounded, color: AppColors.accent,
     text: 'Set a daily reminder to prevent missed doses — consistency improves outcomes.'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primarySurface),
      boxShadow: AppShadows.card,
    ),
    child: Column(children: [
      Row(children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(gradient: AppColors.cardGradient, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16)),
        const SizedBox(width: 10),
        Text('AI-Powered Tips', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 14),
      ..._tips.map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(color: t.color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(8)),
            child: Icon(t.icon, color: t.color, size: 14)),
          const SizedBox(width: 10),
          Expanded(child: Text(t.text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5))),
        ]),
      )),
    ]),
  );
}

// ── Time log sheet ────────────────────────────────────────────────────────────
class _TimeLogSheet extends StatefulWidget {
  final Medication med;
  final DateTime? currentTime;
  final void Function(DateTime) onSave;
  const _TimeLogSheet({required this.med, this.currentTime, required this.onSave});
  @override
  State<_TimeLogSheet> createState() => _TimeLogSheetState();
}

class _TimeLogSheetState extends State<_TimeLogSheet> {
  late DateTime _selected;
  @override
  void initState() {
    super.initState();
    _selected = widget.currentTime ?? DateTime.now();
  }
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Center(child: Container(width: 36, height: 4,
          decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
      const SizedBox(height: 20),
      Text('Log Time Taken', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text(widget.med.name, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textTertiary)),
      const SizedBox(height: 24),
      // Quick-select time chips
      Wrap(spacing: 10, runSpacing: 10, children: [
        _timeChip('Morning 8 AM', DateTime.now().copyWith(hour: 8, minute: 0, second: 0)),
        _timeChip('Noon 12 PM', DateTime.now().copyWith(hour: 12, minute: 0, second: 0)),
        _timeChip('Evening 6 PM', DateTime.now().copyWith(hour: 18, minute: 0, second: 0)),
        _timeChip('Night 9 PM', DateTime.now().copyWith(hour: 21, minute: 0, second: 0)),
        _timeChip('Just now', DateTime.now()),
      ]),
      const SizedBox(height: 24),
      Text('Selected: ${DateFormat('h:mm a').format(_selected)}',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => widget.onSave(_selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
        ),
      ),
    ]),
  );

  Widget _timeChip(String label, DateTime time) {
    final sel = _selected.hour == time.hour && _selected.minute == time.minute;
    return GestureDetector(
      onTap: () => setState(() => _selected = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
            color: sel ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }
}

// ── Add medication sheet ──────────────────────────────────────────────────────
class _AddMedSheet extends StatefulWidget {
  final void Function(String name, String dosage, String freq) onAdd;
  const _AddMedSheet({required this.onAdd});
  @override
  State<_AddMedSheet> createState() => _AddMedSheetState();
}

class _AddMedSheetState extends State<_AddMedSheet> {
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  String _freq = 'Once daily';
  final _freqs = ['Once daily', 'Twice daily', 'Three times daily', 'As needed', 'Weekly'];

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text('Add Medication', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 20),
        TextField(controller: _nameCtrl,
          decoration: InputDecoration(labelText: 'Medication name', hintText: 'e.g. Tamoxifen'),
          style: GoogleFonts.inter(fontSize: 15)),
        const SizedBox(height: 12),
        TextField(controller: _doseCtrl,
          decoration: InputDecoration(labelText: 'Dosage', hintText: 'e.g. 20mg'),
          style: GoogleFonts.inter(fontSize: 15)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _freq,
          decoration: const InputDecoration(labelText: 'Frequency'),
          items: _freqs.map((f) => DropdownMenuItem(value: f, child: Text(f, style: GoogleFonts.inter(fontSize: 14)))).toList(),
          onChanged: (v) => setState(() => _freq = v!),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) return;
              widget.onAdd(_nameCtrl.text.trim(), _doseCtrl.text.trim().isEmpty ? '—' : _doseCtrl.text.trim(), _freq);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Add Medication', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
          ),
        ),
      ]),
    ),
  );
}

// ignore: unused_element
extension _DateTimeCopy on DateTime {
  DateTime copyWith({int? hour, int? minute, int? second}) => DateTime(
    year, month, day, hour ?? this.hour, minute ?? this.minute, second ?? this.second);
}
