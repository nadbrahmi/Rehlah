import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../theme/rehlah_theme.dart';
import '../../../../../core/utils/models.dart';
import '../../../../../core/utils/user_session.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final _session = UserSession();

  @override
  void initState() {
    super.initState();
    _session.initDefaultMedications();
  }

  @override
  Widget build(BuildContext context) {
    final meds    = _session.medications;
    final taken   = _session.medsTakenTodayCount;
    final total   = meds.length;
    final pct     = total == 0 ? 0.0 : (taken / total).clamp(0.0, 1.0);
    final dateStr = DateFormat('d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              _hero(taken, total, pct),
              _sectionHead('Today · $dateStr'),
              const SizedBox(height: 8),
              if (meds.isEmpty)
                _emptyState()
              else
                _timeline(meds),
              const SizedBox(height: 8),
              _addRow(),
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Topbar ───────────────────────────────────────────────────────────────────

  Widget _topbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        _iconBtn(Icons.chevron_left_rounded,
            onTap: () => context.canPop() ? context.pop() : context.go('/')),
        const Expanded(child: Center(child: Text('Medications',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        _iconBtn(Icons.more_horiz_rounded, onTap: () {}),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: RColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: RColors.sand200),
        ),
        child: Icon(icon, color: RColors.sand700, size: 20),
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────────

  Widget _hero(int taken, int total, double pct) {
    final remaining = total - taken;
    final subText = remaining == 0
        ? 'All done for today 🎉'
        : remaining == 1 ? 'One dose remaining today'
        : '$remaining doses remaining today';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
        Row(children: [
          SizedBox(
            width: 100, height: 100,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: _RingPainter(progress: pct),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${(pct * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700,
                    color: Colors.white, height: 1,
                    fontFeatures: [FontFeature.tabularFigures()])),
                const SizedBox(height: 2),
                Text('today',
                  style: TextStyle(
                    fontSize: 10, letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500)),
              ]),
            ]),
          ),
          const SizedBox(width: 20),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adherence',
                style: TextStyle(
                  fontSize: 10.5, letterSpacing: 1.4,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75))),
              const SizedBox(height: 6),
              RichText(text: TextSpan(children: [
                TextSpan(text: '$taken',
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700,
                    color: Colors.white, height: 1.1,
                    fontFeatures: [FontFeature.tabularFigures()])),
                TextSpan(text: ' of $total',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.6))),
              ])),
              const SizedBox(height: 4),
              Text(subText,
                style: TextStyle(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.78))),
            ],
          )),
        ]),
      ]),
    );
  }

  // ── Section head ─────────────────────────────────────────────────────────────

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Text(label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5, letterSpacing: 1.4,
            fontWeight: FontWeight.w500, color: RColors.sand500)),
        const Spacer(),
        const Text('View week',
          style: TextStyle(fontSize: 12, color: RColors.teal700,
              fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── Timeline ──────────────────────────────────────────────────────────────────

  Widget _timeline(List<Medication> meds) {
    final entries = meds.map((m) {
      final timeStr = _timeFromFrequency(m.frequency);
      final state   = _stateForMed(m);
      return (m, timeStr, state);
    }).toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(children: [
        // Vertical line
        Positioned(
          left: 54, top: 14, bottom: 14,
          child: Container(width: 2, color: RColors.sand200),
        ),
        Column(
          children: entries.map((e) =>
            _tlRow(e.$1, e.$2, e.$3)).toList(),
        ),
      ]),
    );
  }

  String _timeFromFrequency(String freq) {
    final f = freq.toLowerCase();
    if (f.contains('morning') || f.contains('am'))             return '08:00';
    if (f.contains('noon') || f.contains('lunch'))             return '13:00';
    if (f.contains('afternoon') || f.contains('evening') || f.contains('pm')) return '17:00';
    if (f.contains('night') || f.contains('bed'))              return '22:00';
    return '08:00';
  }

  String _stateForMed(Medication med) {
    if (_session.isMedTaken(med.id)) return 'taken';
    final now  = DateTime.now();
    final slot = _timeFromFrequency(med.frequency).split(':');
    final medTime = DateTime(now.year, now.month, now.day,
        int.parse(slot[0]), int.parse(slot[1]));
    if (medTime.isBefore(now.subtract(const Duration(minutes: 30)))) return 'missed';
    if (medTime.isBefore(now.add(const Duration(hours: 1))))         return 'next';
    return 'scheduled';
  }

  Widget _tlRow(Medication med, String time, String state) {
    // Dot colour + ring shadow per state
    Color dotColor;
    List<BoxShadow> dotShadow;
    switch (state) {
      case 'taken':
        dotColor  = RColors.sage500;
        dotShadow = [
          BoxShadow(color: RColors.sand50,   blurRadius: 0, spreadRadius: 4),
          const BoxShadow(color: RColors.sage300,  blurRadius: 0, spreadRadius: 5),
        ];
      case 'missed':
        dotColor  = RColors.clay500;
        dotShadow = [
          BoxShadow(color: RColors.sand50,   blurRadius: 0, spreadRadius: 4),
          const BoxShadow(color: RColors.clay300,  blurRadius: 0, spreadRadius: 5),
        ];
      case 'next':
        dotColor  = RColors.saffron500;
        dotShadow = [
          BoxShadow(color: RColors.sand50,   blurRadius: 0, spreadRadius: 4),
          const BoxShadow(color: RColors.saffron300, blurRadius: 0, spreadRadius: 5),
          BoxShadow(color: RColors.saffron500.withValues(alpha: 0.18),
              blurRadius: 0, spreadRadius: 10),
        ];
      default:
        dotColor  = RColors.sand300;
        dotShadow = [
          BoxShadow(color: RColors.sand50,   blurRadius: 0, spreadRadius: 4),
          const BoxShadow(color: RColors.sand200,  blurRadius: 0, spreadRadius: 5),
        ];
    }

    final isActive  = state == 'next';
    final isTaken   = state == 'taken';
    final cardBg    = isActive ? RColors.saffron100 : RColors.surface;
    final cardBorder = isActive ? RColors.saffron300 : RColors.sand200;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: isTaken ? null : () {
          HapticFeedback.lightImpact();
          setState(() => _session.markMedTaken(med.id));
        },
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showAddEditSheet(med);
        },
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Time label
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(time,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12, color: RColors.sand500,
                  fontFeatures: [FontFeature.tabularFigures()])),
            ),
          ),
          // Dot
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 5, right: 5),
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: dotColor, shape: BoxShape.circle,
                boxShadow: dotShadow),
            ),
          ),
          // Card
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: RRadius.mdBR,
                border: Border.all(color: cardBorder),
                boxShadow: isActive
                    ? [BoxShadow(
                        color: RColors.saffron500.withValues(alpha: 0.15),
                        blurRadius: 8, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(med.name,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: RColors.sand950)),
                  const SizedBox(height: 2),
                  Text('${med.dose} · ${med.frequency}',
                    style: const TextStyle(
                      fontSize: 11, color: RColors.sand500)),
                ])),
                const SizedBox(width: 10),
                _statusBadge(med, state),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _statusBadge(Medication med, String state) {
    switch (state) {
      case 'taken':
        return _pill('Taken', RColors.sage100, RColors.sage700,
            dot: RColors.sage500);
      case 'missed':
        return _pill('Missed', RColors.clay100, RColors.clay700,
            dot: RColors.clay500);
      case 'next':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: const BoxDecoration(
            color: RColors.saffron500, borderRadius: RRadius.pillBR),
          child: const Text('Take now',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: RColors.sand950)),
        );
      default:
        return _pill('Scheduled', RColors.sand100, RColors.sand700,
            dot: RColors.sand400, border: RColors.sand200);
    }
  }

  Widget _pill(String label, Color bg, Color fg,
      {Color? dot, Color? border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      height: 22,
      decoration: BoxDecoration(
        color: bg, borderRadius: RRadius.pillBR,
        border: border != null ? Border.all(color: border) : null),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (dot != null) ...[
          Container(width: 5, height: 5,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dot)),
          const SizedBox(width: 5),
        ],
        Text(label,
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500,
              color: fg, height: 1)),
      ]),
    );
  }

  // ── Add row ───────────────────────────────────────────────────────────────────

  Widget _addRow() {
    return GestureDetector(
      onTap: () => _showAddEditSheet(null),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.sand200)),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
              color: RColors.teal100, borderRadius: RRadius.smBR),
            child: const Icon(Icons.add_rounded,
                color: RColors.teal700, size: 18)),
          const SizedBox(width: 12),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add a medication',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: RColors.sand950)),
            Text('Or have your nurse add it for you',
              style: TextStyle(fontSize: 11, color: RColors.sand500)),
          ])),
          const Icon(Icons.chevron_right_rounded,
              color: RColors.sand400, size: 22),
        ]),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.sand200)),
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              color: RColors.teal50, borderRadius: RRadius.mdBR),
            child: const Center(child: Text('💊',
              style: TextStyle(fontSize: 26)))),
          const SizedBox(height: 16),
          const Text('No medications added yet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: RColors.sand950)),
          const SizedBox(height: 8),
          const Text(
            'Add your medications to track daily adherence and get reminders.',
            style: TextStyle(fontSize: 13, color: RColors.sand700, height: 1.5),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showAddEditSheet(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: RColors.teal700, borderRadius: RRadius.pillBR),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('Add first medication',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: Colors.white)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Add / Edit sheet ──────────────────────────────────────────────────────────

  void _showAddEditSheet(Medication? existing) {
    final isEdit    = existing != null;
    final nameCtrl  = TextEditingController(text: existing?.name ?? '');
    final doseCtrl  = TextEditingController(text: existing?.dose ?? '');
    final freqCtrl  = TextEditingController(text: existing?.frequency ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String emoji    = existing?.emoji ?? '💊';
    String category = existing?.category ?? 'other';
    int? totalSupply = existing?.totalSupply;
    DateTime? startDate = existing?.startDate;

    final emojis     = ['💊', '🌤️', '🦴', '🩹', '🧬', '💉', '🫀', '🧪', '🌿'];
    final categories = [
      ('hormone_therapy', 'Hormone therapy'),
      ('chemo', 'Chemotherapy'),
      ('supplement', 'Supplement'),
      ('symptomatic', 'Symptomatic'),
      ('other', 'Other'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20,
              MediaQuery.of(context).viewInsets.bottom + 32),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 36, height: 4,
                decoration: const BoxDecoration(
                  color: RColors.sand200, borderRadius: RRadius.pillBR))),
              const SizedBox(height: 12),
              Text(isEdit ? 'EDIT MEDICATION' : 'ADD MEDICATION',
                style: const TextStyle(
                  fontSize: 10.5, letterSpacing: 1.4,
                  fontWeight: FontWeight.w500, color: RColors.sand500)),
              const SizedBox(height: 14),
              const Text('Icon',
                style: TextStyle(fontSize: 12, color: RColors.sand500)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: emojis.map((e) =>
                GestureDetector(
                  onTap: () => setS(() => emoji = e),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: emoji == e ? RColors.teal50 : RColors.sand100,
                      borderRadius: RRadius.smBR,
                      border: Border.all(
                          color: emoji == e ? RColors.teal200
                              : Colors.transparent)),
                    child: Center(child: Text(e,
                      style: const TextStyle(fontSize: 20)))))).toList()),
              const SizedBox(height: 12),
              _field('Medication name', nameCtrl, 'e.g. Tamoxifen 20mg'),
              const SizedBox(height: 8),
              _field('Dose', doseCtrl, 'e.g. 1 tablet'),
              const SizedBox(height: 8),
              _field('Frequency', freqCtrl, 'e.g. Daily · Morning'),
              const SizedBox(height: 8),
              _field('Notes (optional)', notesCtrl, 'e.g. Take with food'),
              const SizedBox(height: 12),
              const Text('Category',
                style: TextStyle(fontSize: 12, color: RColors.sand500)),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6,
                children: categories.map((c) {
                  final sel = category == c.$1;
                  return GestureDetector(
                    onTap: () => setS(() => category = c.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? RColors.teal50 : RColors.sand100,
                        borderRadius: RRadius.pillBR,
                        border: Border.all(
                            color: sel ? RColors.teal200 : Colors.transparent)),
                      child: Text(c.$2,
                        style: TextStyle(fontSize: 11,
                            color: sel ? RColors.teal700 : RColors.sand700))));
                }).toList()),
              const SizedBox(height: 16),
              Row(children: [
                if (isEdit) ...[
                  Expanded(child: GestureDetector(
                    onTap: () {
                      _session.removeMedication(existing.id);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: RColors.clay100, borderRadius: RRadius.mdBR,
                        border: Border.all(
                            color: RColors.clay300.withValues(alpha: 0.5))),
                      child: const Center(child: Text('Delete',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: RColors.clay700)))))),
                  const SizedBox(width: 8),
                ],
                Expanded(flex: 2, child: GestureDetector(
                  onTap: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final med = Medication(
                      id: isEdit
                          ? existing.id
                          : DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.trim(),
                      dose: doseCtrl.text.trim().isEmpty
                          ? '1 dose' : doseCtrl.text.trim(),
                      frequency: freqCtrl.text.trim().isEmpty
                          ? 'Daily' : freqCtrl.text.trim(),
                      emoji: emoji,
                      category: category,
                      notes: notesCtrl.text.trim().isEmpty
                          ? null : notesCtrl.text.trim(),
                      startDate: startDate ?? existing?.startDate,
                      totalSupply: totalSupply,
                    );
                    if (isEdit) {
                      _session.updateMedication(med);
                    } else {
                      _session.addMedication(med);
                    }
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: RColors.teal700, borderRadius: RRadius.mdBR),
                    child: Center(child: Text(
                      isEdit ? 'Save changes' : 'Add medication',
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)))))),
              ]),
            ],
          )),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
        style: const TextStyle(fontSize: 12, color: RColors.sand500)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 14, color: RColors.sand900),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: RColors.sand400, fontSize: 13),
          filled: true, fillColor: RColors.sand50,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          border: const OutlineInputBorder(
            borderRadius: RRadius.mdBR,
            borderSide: BorderSide(color: RColors.sand200)),
          enabledBorder: const OutlineInputBorder(
            borderRadius: RRadius.mdBR,
            borderSide: BorderSide(color: RColors.sand200)),
          focusedBorder: const OutlineInputBorder(
            borderRadius: RRadius.mdBR,
            borderSide: BorderSide(color: RColors.teal200, width: 1.5))),
      ),
    ]);
  }
}

// ── Ring painter ──────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;

  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 42.0;
    const sw = 8.0;
    const startAngle = -math.pi / 2;

    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle, sweepAngle, false,
      Paint()
        ..color = RColors.saffron500
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
