import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';

// ─── Shared palette (matches home_screen.dart _C) ────────────────────────────
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
  // divider used in sheet
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

BoxDecoration _cardDeco({double r = 20}) => BoxDecoration(
      color: _C.card,
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: _C.border.withValues(alpha: 0.50)),
      boxShadow: [
        BoxShadow(
            color: const Color(0xFF9B5DC4).withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 4)),
      ],
    );

// ═══════════════════════════════════════════════════════════════════════════════
class MedicationTrackerScreen extends StatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  State<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen>
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
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        return Scaffold(
          backgroundColor: _C.bg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Header ───────────────────────────────────────────
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.medication_rounded,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Medication Tracker',
                                      style: _t(
                                          s: 20,
                                          w: FontWeight.w700,
                                          c: Colors.white)),
                                  Text(
                                    'AI-powered adherence tracking',
                                    style: _t(
                                        s: 12,
                                        c: Colors.white
                                            .withValues(alpha: 0.75)),
                                  ),
                                ],
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                  title: Container(
                    color: const Color(0xFFBD6BB8).withValues(alpha: 0.95),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Medication Tracker',
                        style: _t(
                            s: 17, w: FontWeight.w700, c: Colors.white)),
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
                        Tab(text: "Today's Doses"),
                        Tab(text: 'My Medications'),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Adherence Summary ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _AdherenceSummary(app: app),
                ),
              ),

              // ── Tab content ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _TodayDosesTab(app: app),
                      _MyMedicationsTab(app: app),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddMedSheet(context, app),
            backgroundColor: _C.purple,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('Add Medication',
                style: _t(s: 13, w: FontWeight.w700, c: Colors.white)),
          ),
        );
      },
    );
  }

  void _showAddMedSheet(BuildContext ctx, AppProvider app) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMedSheet(app: app),
    );
  }
}

// ─── Adherence Summary Card ───────────────────────────────────────────────────
class _AdherenceSummary extends StatelessWidget {
  final AppProvider app;
  const _AdherenceSummary({required this.app});

  @override
  Widget build(BuildContext context) {
    final rate7   = app.medAdherenceRate(days: 7);
    final rate14  = app.medAdherenceRate(days: 14);
    final active  = app.medications.where((m) => m.isActive).length;
    final todayTaken = app.medications
        .where((m) => m.isActive && app.isMedTakenToday(m.id))
        .length;
    final pctToday = active == 0 ? 1.0 : todayTaken / active;

    // AI insight
    String aiMsg;
    Color aiColor;
    IconData aiIcon;
    if (rate7 >= 0.9) {
      aiMsg = 'Excellent adherence this week! Consistent medication timing helps maximise treatment effectiveness.';
      aiColor = _C.greenFg;
      aiIcon = Icons.star_rounded;
    } else if (rate7 >= 0.7) {
      aiMsg = 'Good progress. Try setting a daily reminder to maintain your ${(rate7 * 100).round()}% adherence.';
      aiColor = _C.heroB;
      aiIcon = Icons.auto_awesome_rounded;
    } else {
      aiMsg = 'Adherence dropped below 70%. Missing medications can affect treatment. Speak to your care team.';
      aiColor = _C.peachFg;
      aiIcon = Icons.warning_amber_rounded;
    }

    return Container(
      decoration: _cardDeco(),
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
            Text('AI Adherence Insights',
                style: _t(s: 15, w: FontWeight.w600, c: _C.textDark)),
          ]),
          const SizedBox(height: 14),

          // Stats row
          Row(children: [
            _StatPill(
              label: 'Today',
              value: '$todayTaken/$active',
              subLabel: 'doses taken',
              color: pctToday >= 1.0 ? _C.greenFg : _C.peachFg,
              bg: pctToday >= 1.0 ? _C.greenBg : _C.peachBg,
            ),
            const SizedBox(width: 10),
            _StatPill(
              label: '7-Day',
              value: '${(rate7 * 100).round()}%',
              subLabel: 'adherence',
              color: rate7 >= 0.8 ? _C.greenFg : _C.peachFg,
              bg: rate7 >= 0.8 ? _C.greenBg : _C.peachBg,
            ),
            const SizedBox(width: 10),
            _StatPill(
              label: '14-Day',
              value: '${(rate14 * 100).round()}%',
              subLabel: 'adherence',
              color: rate14 >= 0.8 ? _C.greenFg : _C.peachFg,
              bg: rate14 >= 0.8 ? _C.greenBg : _C.peachBg,
            ),
          ]),

          const SizedBox(height: 14),

          // AI message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: aiColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: aiColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(aiIcon, color: aiColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(aiMsg,
                      style: _t(s: 12.5, c: _C.textMid, h: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value, subLabel;
  final Color color, bg;
  const _StatPill({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text(label,
              style: _t(s: 10, w: FontWeight.w600, c: color, ls: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: _t(s: 18, w: FontWeight.w800, c: color)),
          Text(subLabel,
              style: _t(s: 10, c: color.withValues(alpha: 0.70))),
        ]),
      ),
    );
  }
}

// ─── Today's Doses Tab ────────────────────────────────────────────────────────
class _TodayDosesTab extends StatelessWidget {
  final AppProvider app;
  const _TodayDosesTab({required this.app});

  @override
  Widget build(BuildContext context) {
    final meds = app.medications.where((m) => m.isActive).toList();
    if (meds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                  color: _C.purpleLight,
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.medication_rounded,
                  color: _C.purple, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No medications yet',
                style: _t(s: 16, w: FontWeight.w600, c: _C.textDark)),
            const SizedBox(height: 6),
            Text('Tap "Add Medication" to start tracking.',
                textAlign: TextAlign.center,
                style: _t(s: 13, c: _C.textSoft)),
          ],
        ),
      );
    }

    final takenCount = meds.where((m) => app.isMedTakenToday(m.id)).length;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & progress
          Row(children: [
            Text(DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: _t(s: 14, w: FontWeight.w600, c: _C.textDark)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: takenCount == meds.length
                    ? _C.greenBg
                    : _C.peachBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$takenCount/${meds.length} taken',
                style: _t(
                    s: 12,
                    w: FontWeight.w600,
                    c: takenCount == meds.length
                        ? _C.greenDark
                        : _C.peachFg),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: meds.isEmpty ? 1.0 : takenCount / meds.length,
              minHeight: 6,
              backgroundColor: _C.purpleLight,
              valueColor: AlwaysStoppedAnimation<Color>(_C.heroB),
            ),
          ),
          const SizedBox(height: 20),

          // Pending meds first
          if (takenCount < meds.length) ...[
            Text('Pending',
                style: _t(
                    s: 11,
                    w: FontWeight.w700,
                    c: _C.textSoft,
                    ls: 1.1)),
            const SizedBox(height: 10),
            ...meds
                .where((m) => !app.isMedTakenToday(m.id))
                .map((m) => _DoseRow(
                      med: m,
                      isTaken: false,
                      onMarkTaken: () => app.logMedTaken(m.id, taken: true),
                    )),
            const SizedBox(height: 16),
          ],

          // Taken meds
          if (takenCount > 0) ...[
            Text('Taken Today',
                style: _t(
                    s: 11,
                    w: FontWeight.w700,
                    c: _C.textSoft,
                    ls: 1.1)),
            const SizedBox(height: 10),
            ...meds
                .where((m) => app.isMedTakenToday(m.id))
                .map((m) => _DoseRow(
                      med: m,
                      isTaken: true,
                      takenAt: app.medLogs
                          .where((l) =>
                              l.medId == m.id &&
                              l.date.day == DateTime.now().day)
                          .firstOrNull
                          ?.takenAt,
                      onMarkTaken: () => app.logMedTaken(m.id, taken: false),
                    )),
          ],
        ],
      ),
    );
  }
}

class _DoseRow extends StatelessWidget {
  final Medication med;
  final bool isTaken;
  final DateTime? takenAt;
  final VoidCallback onMarkTaken;
  const _DoseRow({
    required this.med,
    required this.isTaken,
    this.takenAt,
    required this.onMarkTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTaken ? _C.greenBg : _C.peachBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isTaken ? _C.greenFg : _C.peachFg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            isTaken ? Icons.check_rounded : Icons.medication_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: _t(
                        s: 14,
                        w: FontWeight.w600,
                        c: isTaken ? _C.greenDark : _C.peachFg)),
                Text(
                  isTaken
                      ? (takenAt != null
                          ? 'Taken at ${DateFormat("h:mm a").format(takenAt!)}'
                          : 'Taken ✓')
                      : '${med.dosage}  ·  ${med.frequency}',
                  style: _t(
                      s: 12,
                      c: (isTaken ? _C.greenDark : _C.peachFg)
                          .withValues(alpha: 0.75)),
                ),
              ]),
        ),
        GestureDetector(
          onTap: onMarkTaken,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isTaken
                  ? _C.greenFg.withValues(alpha: 0.15)
                  : _C.peachFg,
              borderRadius: BorderRadius.circular(10),
              border: isTaken
                  ? Border.all(color: _C.greenFg.withValues(alpha: 0.4))
                  : null,
            ),
            child: Text(
              isTaken ? 'Undo' : 'Mark Taken',
              style: _t(
                  s: 12,
                  w: FontWeight.w700,
                  c: isTaken ? _C.greenDark : Colors.white),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── My Medications Tab ───────────────────────────────────────────────────────
class _MyMedicationsTab extends StatelessWidget {
  final AppProvider app;
  const _MyMedicationsTab({required this.app});

  @override
  Widget build(BuildContext context) {
    final meds = app.medications;
    if (meds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          const SizedBox(height: 40),
          Text('No medications added yet',
              style: _t(s: 16, w: FontWeight.w600, c: _C.textDark)),
        ]),
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: meds
            .map((m) => _MedListTile(
                  med: m,
                  onRemove: () => app.removeMedication(m.id),
                ))
            .toList(),
      ),
    );
  }
}

class _MedListTile extends StatelessWidget {
  final Medication med;
  final VoidCallback onRemove;
  const _MedListTile({required this.med, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDeco(r: 16),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_C.purple, _C.purpleMid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.medication_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: _t(s: 14, w: FontWeight.w600, c: _C.textDark)),
                Text('${med.dosage}  ·  ${med.frequency}',
                    style: _t(s: 12, c: _C.textSoft)),
                if (med.notes != null && med.notes!.isNotEmpty)
                  Text(med.notes!,
                      style: _t(
                          s: 11,
                          c: _C.textFaint,
                          d: TextDecoration.none)),
              ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: med.isActive ? _C.greenBg : _C.purpleLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            med.isActive ? 'Active' : 'Inactive',
            style: _t(
                s: 11,
                w: FontWeight.w600,
                c: med.isActive ? _C.greenDark : _C.purple),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: _C.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text('Remove medication?',
                  style: _t(s: 16, w: FontWeight.w700)),
              content: Text(
                  'Remove ${med.name} from your medication list?',
                  style: _t(s: 14, c: _C.textMid)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: _t(s: 13, c: _C.textSoft)),
                ),
                TextButton(
                  onPressed: () {
                    onRemove();
                    Navigator.pop(context);
                  },
                  child: Text('Remove',
                      style: _t(s: 13, w: FontWeight.w700, c: _C.rose)),
                ),
              ],
            ),
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: _C.textFaint, size: 20),
        ),
      ]),
    );
  }
}

// ─── Add Medication Bottom Sheet ──────────────────────────────────────────────
class _AddMedSheet extends StatefulWidget {
  final AppProvider app;
  const _AddMedSheet({required this.app});

  @override
  State<_AddMedSheet> createState() => _AddMedSheetState();
}

class _AddMedSheetState extends State<_AddMedSheet> {
  final _nameCtrl   = TextEditingController();
  final _doseCtrl   = TextEditingController();
  final _notesCtrl  = TextEditingController();
  String _frequency = 'Daily Morning';

  static const _freqOptions = [
    'Daily Morning',
    'Daily Evening',
    'Twice Daily',
    'Three Times Daily',
    'As needed',
    'Before meals',
    'After meals',
    'Weekly',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final dose = _doseCtrl.text.trim();
    if (name.isEmpty || dose.isEmpty) return;
    widget.app.addMedication(Medication(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      dosage: dose,
      frequency: _frequency,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
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
          Text('Add Medication',
              style: _t(s: 19, w: FontWeight.w700, c: _C.textDark)),
          const SizedBox(height: 20),
          _SheetField(
            ctrl: _nameCtrl,
            label: 'Medication Name',
            hint: 'e.g. Tamoxifen',
          ),
          const SizedBox(height: 14),
          _SheetField(
            ctrl: _doseCtrl,
            label: 'Dosage',
            hint: 'e.g. 20mg',
          ),
          const SizedBox(height: 14),
          Text('Frequency',
              style: _t(s: 13, w: FontWeight.w600, c: _C.textMid)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _freqOptions.map((f) {
              final sel = _frequency == f;
              return GestureDetector(
                onTap: () => setState(() => _frequency = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _C.purple : _C.purpleLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(f,
                      style: _t(
                          s: 12,
                          w: FontWeight.w600,
                          c: sel ? Colors.white : _C.purple)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _SheetField(
            ctrl: _notesCtrl,
            label: 'Notes (optional)',
            hint: 'e.g. Take with food',
          ),
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
                  child: Text('Add Medication',
                      style:
                          _t(s: 15, w: FontWeight.w700, c: Colors.white)),
                ),
              ),
            ),
          ),
        ],
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
