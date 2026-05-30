import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/services/supabase_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// VitalsScreen — display mode + bottom-sheet form
// ══════════════════════════════════════════════════════════════════════════════

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});
  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _session = UserSession();

  // ── Data helpers ─────────────────────────────────────────────────────────

  List<VitalRecord> get _todayVitals {
    final now = DateTime.now();
    final recs = _session.vitals.where((v) =>
      v.recordedAt.year == now.year &&
      v.recordedAt.month == now.month &&
      v.recordedAt.day == now.day).toList();
    recs.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return recs;
  }

  // Today's highest temperature reading
  VitalRecord? get _tempHero {
    final recs = _todayVitals.where((v) => v.temperatureCelsius != null).toList();
    if (recs.isEmpty) return null;
    return recs.reduce((a, b) =>
        a.temperatureCelsius! >= b.temperatureCelsius! ? a : b);
  }

  // Most recent reading that satisfies [hasField] — today first, then all-time
  VitalRecord? _latest(bool Function(VitalRecord) hasField) {
    for (final v in _todayVitals) {
      if (hasField(v)) return v;
    }
    final all = [..._session.vitals]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    for (final v in all) {
      if (hasField(v)) return v;
    }
    return null;
  }

  VitalFlag _weightFlag(VitalRecord r) {
    if (r.weightKg == null) return VitalFlag.normal;
    final prev = _session.vitals
        .where((v) => v != r && v.weightKg != null)
        .toList()..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    if (prev.isEmpty) return VitalFlag.normal;
    final delta = (r.weightKg! - prev.first.weightKg!).abs();
    if (delta >= 2.0) return VitalFlag.high;
    if (delta >= 1.0) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours  < 24)  return '${diff.inHours}h ago';
    return DateFormat('d MMM').format(dt);
  }

  String _recordedLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final t    = DateFormat('HH:mm').format(dt);
    if (diff.inMinutes < 60) return 'Recorded $t · ${diff.inMinutes}m ago';
    if (diff.inHours  < 24)  return 'Recorded $t · ${diff.inHours}h ago';
    return 'Recorded $t · ${DateFormat('d MMM').format(dt)}';
  }

  // ── Sheet ─────────────────────────────────────────────────────────────────

  void _openRecordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecordSheet(
        session: _session,
        onSaved: () => setState(() {}),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isNadir = _session.isNadirWindow;
    final tempRec = _tempHero;
    final bpRec   = _latest((v) => v.systolicBp != null && v.diastolicBp != null);
    final hrRec   = _latest((v) => v.heartRateBpm != null);
    final o2Rec   = _latest((v) => v.spo2Pct != null);
    final wtRec   = _latest((v) => v.weightKg != null);
    final gluRec  = _latest((v) => v.glucoseMmol != null);

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        child: Column(children: [
          _buildTopBar(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Nadir banner ─────────────────────────────────────────────
              if (isNadir) ...[
                _buildNadirBanner(),
                const SizedBox(height: 12),
              ],

              // ── Temperature hero ─────────────────────────────────────────
              _buildTempHero(tempRec),
              const SizedBox(height: 16),

              // ── Section head ─────────────────────────────────────────────
              Row(children: [
                Text('ALL VITALS TODAY', style: RText.eyebrow),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/vitals/history'),
                  child: Text('History & trends →',
                    style: RText.small.copyWith(
                      fontSize: 12, color: RColors.teal700,
                      fontWeight: FontWeight.w500)),
                ),
              ]),
              const SizedBox(height: 10),

              // ── 2-column vitals grid ──────────────────────────────────────
              GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.22,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  _vitalCard(
                    label: 'Blood pressure',
                    value: bpRec != null
                        ? '${bpRec.systolicBp}/${bpRec.diastolicBp}' : '–/–',
                    unit: 'mmHg',
                    icon: Icons.favorite_border_rounded,
                    iconBg: RColors.sky100, iconFg: RColors.sky500,
                    flag: bpRec?.bpFlag ?? VitalFlag.normal,
                    when: bpRec != null ? _ago(bpRec.recordedAt) : null,
                  ),
                  _vitalCard(
                    label: 'Heart rate',
                    value: hrRec != null ? '${hrRec.heartRateBpm}' : '–',
                    unit: 'bpm',
                    icon: Icons.monitor_heart_outlined,
                    iconBg: RColors.sky100, iconFg: RColors.sky500,
                    flag: hrRec?.hrFlag ?? VitalFlag.normal,
                    when: hrRec != null ? _ago(hrRec.recordedAt) : null,
                  ),
                  _vitalCard(
                    label: 'Oxygen SpO₂',
                    value: o2Rec != null ? '${o2Rec.spo2Pct}' : '–',
                    unit: '%',
                    icon: Icons.air_rounded,
                    iconBg: RColors.sage100, iconFg: RColors.sage700,
                    flag: o2Rec?.spo2Flag ?? VitalFlag.normal,
                    when: o2Rec != null ? _ago(o2Rec.recordedAt) : null,
                  ),
                  _vitalCard(
                    label: 'Weight',
                    value: wtRec != null
                        ? wtRec.weightKg!.toStringAsFixed(1) : '–',
                    unit: 'kg',
                    icon: Icons.monitor_weight_outlined,
                    iconBg: RColors.sand100, iconFg: RColors.sand500,
                    flag: wtRec != null ? _weightFlag(wtRec) : VitalFlag.normal,
                    when: wtRec != null ? _ago(wtRec.recordedAt) : null,
                  ),
                  _vitalCard(
                    label: 'Blood glucose',
                    value: gluRec != null
                        ? gluRec.glucoseMmol!.toStringAsFixed(1) : '–',
                    unit: 'mmol/L',
                    icon: Icons.water_drop_outlined,
                    iconBg: RColors.saffron100, iconFg: RColors.saffron700,
                    flag: gluRec?.glucoseFlag ?? VitalFlag.normal,
                    when: gluRec != null ? _ago(gluRec.recordedAt) : null,
                  ),
                  // Dashed "Add reading" tile
                  GestureDetector(
                    onTap: _openRecordSheet,
                    child: CustomPaint(
                      painter: _DashedBorderPainter(
                        RColors.teal500.withValues(alpha: 0.45), 14),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: RRadius.mdBR),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: const BoxDecoration(
                                color: RColors.teal100,
                                shape: BoxShape.circle),
                              child: const Icon(Icons.add_rounded,
                                size: 20, color: RColors.teal700),
                            ),
                            const SizedBox(height: 8),
                            Text('Add reading',
                              style: RText.small.copyWith(
                                color: RColors.teal700,
                                fontWeight: FontWeight.w500,
                                fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Record all vitals button ──────────────────────────────────
              GestureDetector(
                onTap: _openRecordSheet,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: RColors.saffron500,
                    borderRadius: RRadius.pillBR,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22D4A258),
                        blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const Icon(Icons.add_rounded,
                      size: 18, color: RColors.sand950),
                    const SizedBox(width: 8),
                    Text('Record all vitals',
                      style: RText.body.copyWith(
                        fontWeight: FontWeight.w500,
                        color: RColors.sand950, fontSize: 15)),
                  ]),
                ),
              ),

              // ── Recent readings ────────────────────────────────────────────
              if (_session.vitals.isNotEmpty) ...[
                const SizedBox(height: 28),
                _buildHistory(),
              ],
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: Row(children: [
      _iconBtn(Icons.chevron_left_rounded, () => context.pop()),
      Expanded(child: Center(child: Text('Vitals',
        style: RText.h3.copyWith(
          fontSize: 17, fontWeight: FontWeight.w700,
          letterSpacing: -0.17, color: RColors.sand900)))),
      _iconBtn(Icons.more_horiz_rounded, () {}),
    ]),
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: RColors.surface, shape: BoxShape.circle,
        border: Border.all(color: RColors.sand200)),
      child: Icon(icon, color: RColors.sand700, size: 22),
    ),
  );

  // ── Nadir banner ──────────────────────────────────────────────────────────

  Widget _buildNadirBanner() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [RColors.clay100, RColors.sand50],
        stops: [0.0, 1.0],
      ),
      borderRadius: RRadius.lgBR,
      border: Border.all(color: RColors.clay300),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(
          color: RColors.clay500, shape: BoxShape.circle),
        child: const Center(child: Text('!',
          style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NADIR WINDOW',
          style: RText.eyebrow.copyWith(color: RColors.clay700)),
        const SizedBox(height: 2),
        Text('Log your temperature twice today',
          style: RText.body.copyWith(
            fontWeight: FontWeight.w700, fontSize: 14,
            color: RColors.sand900, height: 1.3)),
        const SizedBox(height: 1),
        Text('Infection risk peaks days 7–10',
          style: RText.small.copyWith(color: RColors.sand700)),
      ])),
    ]),
  );

  // ── Temperature hero card ─────────────────────────────────────────────────

  Widget _buildTempHero(VitalRecord? rec) {
    final flag    = rec?.tempFlag ?? VitalFlag.normal;
    final tempVal = rec?.temperatureCelsius;
    final hasVal  = tempVal != null;

    // Color palette per flag tier
    final List<Color> gradColors;
    final Color borderColor, iconBg, iconFg, pillBg, pillFg;
    final String pillLabel;
    final Color valueColor, eyebrowColor;

    switch (flag) {
      case VitalFlag.high:
        gradColors  = [RColors.clay100, RColors.sand50];
        borderColor = RColors.clay300;
        iconBg = RColors.clay100; iconFg = RColors.clay700;
        pillBg = RColors.clay100; pillFg = RColors.clay700;
        pillLabel   = hasVal && tempVal >= 38.5 ? 'High fever' : 'Fever';
        valueColor  = RColors.clay700;
        eyebrowColor = RColors.clay700;
      case VitalFlag.moderate:
        gradColors  = [RColors.saffron100, RColors.sand50];
        borderColor = RColors.saffron300;
        iconBg = RColors.saffron100; iconFg = RColors.saffron700;
        pillBg = RColors.saffron100; pillFg = RColors.saffron700;
        pillLabel   = 'Slight fever';
        valueColor  = RColors.saffron700;
        eyebrowColor = RColors.saffron700;
      case VitalFlag.normal:
        gradColors  = [RColors.sage100, RColors.sand50];
        borderColor = RColors.sage300;
        iconBg = RColors.sage100; iconFg = RColors.sage700;
        pillBg = RColors.sage100; pillFg = RColors.sage700;
        pillLabel   = hasVal ? 'Normal' : 'Not logged';
        valueColor  = hasVal ? RColors.sage700 : RColors.sand400;
        eyebrowColor = RColors.sage700;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradColors,
        ),
        borderRadius: RRadius.lgBR,
        border: Border.all(color: borderColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Icon tile + eyebrow
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconBg, borderRadius: RRadius.smBR),
            child: Icon(Icons.thermostat_rounded, size: 18, color: iconFg),
          ),
          const SizedBox(width: 12),
          Text('TEMPERATURE · TODAY\'S HIGH',
            style: RText.eyebrow.copyWith(
              color: eyebrowColor, letterSpacing: 1.0)),
        ]),

        const SizedBox(height: 14),

        // Big value row: number + °C + status pill
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            hasVal ? tempVal.toStringAsFixed(1) : '–.–',
            style: TextStyle(
              fontSize: 48, fontWeight: FontWeight.w700,
              height: 1.0, letterSpacing: -1.0,
              color: valueColor,
              fontFeatures: const [FontFeature('tnum')],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 4),
            child: Text('°C',
              style: RText.h2.copyWith(
                color: valueColor, fontWeight: FontWeight.w400)),
          ),
          const Spacer(),
          // Status pill
          Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: pillBg, borderRadius: RRadius.pillBR),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 5, height: 5,
                decoration: BoxDecoration(
                  color: pillFg, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(pillLabel,
                style: TextStyle(
                  fontSize: 10.5, color: pillFg,
                  fontWeight: FontWeight.w500, height: 1.0)),
            ]),
          ),
        ]),

        const SizedBox(height: 10),

        // Meta row: recorded time (left) + 3-segment scale (right)
        Row(children: [
          Expanded(child: Text(
            rec != null
                ? _recordedLabel(rec.recordedAt)
                : 'No readings today',
            style: RText.small.copyWith(
              fontSize: 11, color: RColors.sand700, height: 1.3))),
          _buildScaleIndicator(flag),
        ]),
      ]),
    );
  }

  // 3-segment scale indicator (ok · warn · high)
  Widget _buildScaleIndicator(VitalFlag current) => Row(children: [
    _scaleSeg(VitalFlag.normal,   current, RColors.sage500),
    const SizedBox(width: 3),
    _scaleSeg(VitalFlag.moderate, current, RColors.saffron500),
    const SizedBox(width: 3),
    _scaleSeg(VitalFlag.high,     current, RColors.clay500),
  ]);

  Widget _scaleSeg(VitalFlag tier, VitalFlag current, Color color) {
    final active = tier == current;
    return AnimatedContainer(
      duration: RMotion.duration,
      width:  active ? 24 : 16,
      height: active ?  8 :  5,
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 1.0 : 0.28),
        borderRadius: RRadius.pillBR),
    );
  }

  // ── Vital card (grid cell) ────────────────────────────────────────────────

  Widget _vitalCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required VitalFlag flag,
    String? when,
  }) {
    final hasData  = value != '–' && value != '–/–';
    final dotColor = flag == VitalFlag.high     ? RColors.clay500
        : flag == VitalFlag.moderate ? RColors.saffron500
        : RColors.sage500;
    final fgColor  = flag == VitalFlag.high     ? RColors.clay700
        : flag == VitalFlag.moderate ? RColors.saffron700
        : RColors.sand900;
    final flagLabel = flag == VitalFlag.high     ? 'High'
        : flag == VitalFlag.moderate ? 'Watch'
        : 'Normal';

    // Tint the icon bg/fg when a non-normal flag is active
    final Color effIconBg = hasData && flag == VitalFlag.high ? RColors.clay100
        : hasData && flag == VitalFlag.moderate ? RColors.saffron100
        : iconBg;
    final Color effIconFg = hasData && flag == VitalFlag.high ? RColors.clay700
        : hasData && flag == VitalFlag.moderate ? RColors.saffron700
        : iconFg;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
        boxShadow: RShadow.shadow1,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Icon row + flag dot
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: effIconBg, borderRadius: RRadius.smBR),
            child: Icon(icon, size: 16, color: effIconFg),
          ),
          const Spacer(),
          if (hasData)
            Container(
              width: 8, height: 8, margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        ]),
        const SizedBox(height: 8),

        // Label
        Text(label,
          style: RText.small.copyWith(
            fontSize: 11, color: RColors.sand500, height: 1.1)),
        const SizedBox(height: 2),

        // Value + unit
        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, children: [
          Text(value,
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              letterSpacing: -0.2, height: 1.1,
              color: hasData ? fgColor : RColors.sand400,
              fontFeatures: const [FontFeature('tnum')])),
          if (hasData) ...[
            const SizedBox(width: 2),
            Text(unit,
              style: RText.small.copyWith(fontSize: 10, color: RColors.sand500)),
          ],
        ]),
        const SizedBox(height: 3),

        // When + flag label
        Text(
          when != null ? '$when · $flagLabel' : 'Not logged',
          style: RText.small.copyWith(
            fontSize: 10,
            color: when != null ? RColors.sand500 : RColors.sand400),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }

  // ── History ───────────────────────────────────────────────────────────────

  Widget _buildHistory() {
    final vitals = [..._session.vitals]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('RECENT READINGS', style: RText.eyebrow),
      const SizedBox(height: 8),
      Container(
        decoration: const BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          boxShadow: RShadow.shadow1),
        child: Column(children: [
          ...vitals.take(8).toList().asMap().entries.map((e) {
            final i = e.key;
            final v = e.value;
            final isLast = i == (vitals.length < 8 ? vitals.length : 8) - 1;
            final flag   = v.worstFlag;
            final dotC   = flag == VitalFlag.high ? RColors.clay500
                : flag == VitalFlag.moderate ? RColors.saffron500
                : RColors.sage500;
            final wf = _weightFlag(v);

            return Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: isLast ? null : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: RColors.sand200, width: 0.5))),
              child: Row(children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: dotC, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Wrap(
                  spacing: 10, runSpacing: 2,
                  children: [
                    if (v.temperatureCelsius != null)
                      _chip('${v.temperatureCelsius!.toStringAsFixed(1)} °C',
                            v.tempFlag),
                    if (v.systolicBp != null && v.diastolicBp != null)
                      _chip('${v.systolicBp}/${v.diastolicBp}', v.bpFlag),
                    if (v.heartRateBpm != null)
                      _chip('${v.heartRateBpm} bpm', v.hrFlag),
                    if (v.spo2Pct != null)
                      _chip('${v.spo2Pct}% O₂', v.spo2Flag),
                    if (v.glucoseMmol != null)
                      _chip('${v.glucoseMmol!.toStringAsFixed(1)} mmol',
                            v.glucoseFlag),
                    if (v.weightKg != null)
                      _chip('${v.weightKg!.toStringAsFixed(1)} kg', wf),
                  ],
                )),
                const SizedBox(width: 8),
                Text(_ago(v.recordedAt),
                  style: RText.small.copyWith(fontSize: 10)),
              ]),
            );
          }),
        ]),
      ),
    ]);
  }

  Widget _chip(String value, VitalFlag flag) {
    final c = flag == VitalFlag.normal   ? RColors.sand700
        : flag == VitalFlag.moderate ? RColors.saffron700
        : RColors.clay700;
    return Text(value,
      style: RText.small.copyWith(
        fontSize: 12.5, color: c,
        fontWeight: flag != VitalFlag.normal
            ? FontWeight.w600 : FontWeight.w400,
        fontFeatures: const [FontFeature('tnum')]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Dashed border painter for the "Add reading" grid tile
// ══════════════════════════════════════════════════════════════════════════════

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter(this.color, this.radius);
  final Color  color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color      = color
      ..strokeWidth = 1.5
      ..style      = PaintingStyle.stroke;

    final path = Path()..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(radius),
    ));

    const dashLen = 6.0;
    const gapLen  = 4.0;

    for (final m in path.computeMetrics()) {
      double dist = 0;
      while (dist < m.length) {
        final end = (dist + dashLen).clamp(0.0, m.length);
        canvas.drawPath(m.extractPath(dist, end), paint);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ══════════════════════════════════════════════════════════════════════════════
// Record Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════════

class _RecordSheet extends StatefulWidget {
  const _RecordSheet({required this.session, required this.onSaved});
  final UserSession session;
  final VoidCallback onSaved;

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  final _tempCtrl   = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _sbpCtrl    = TextEditingController();
  final _dbpCtrl    = TextEditingController();
  final _hrCtrl     = TextEditingController();
  final _o2Ctrl     = TextEditingController();
  final _gluCtrl    = TextEditingController();
  final _tempFocus  = FocusNode();

  double? _parsedTemp;
  bool    _saved = false;

  @override
  void dispose() {
    _tempCtrl.dispose(); _weightCtrl.dispose();
    _sbpCtrl.dispose();  _dbpCtrl.dispose();
    _hrCtrl.dispose();   _o2Ctrl.dispose();
    _gluCtrl.dispose();  _tempFocus.dispose();
    super.dispose();
  }

  // ── Feedback colors ───────────────────────────────────────────────────────

  Color get _tempColor {
    if (_parsedTemp == null)    return RColors.sand500;
    if (_parsedTemp! >= 38.5)   return RColors.clay700;
    if (_parsedTemp! >= 38.0)   return RColors.clay500;
    if (_parsedTemp! >= 37.5)   return RColors.saffron500;
    if (_parsedTemp! < 36.0)    return RColors.sky500;
    return RColors.sage500;
  }

  String get _tempLabel {
    if (_parsedTemp == null)    return '';
    if (_parsedTemp! >= 38.5)   return 'High fever — contact your care team now';
    if (_parsedTemp! >= 38.0)   return 'Fever — call your care team today';
    if (_parsedTemp! >= 37.5)   return 'Low-grade fever — monitor closely';
    if (_parsedTemp! < 36.0)    return 'Low — note and mention to your team';
    return 'Normal range';
  }

  Color _bpColor(int? sys, int? dia) {
    if (sys == null && dia == null) return RColors.sand500;
    if ((sys != null && (sys > 160 || sys < 90)) ||
        (dia != null && dia > 100)) { return RColors.clay500; }
    if ((sys != null && sys >= 140) ||
        (dia != null && dia >= 90)) { return RColors.saffron500; }
    return RColors.sage500;
  }

  Color _hrColor(int? hr) {
    if (hr == null)           return RColors.sand500;
    if (hr > 100 || hr < 50) return RColors.clay500;
    if (hr >= 90)             return RColors.saffron500;
    return RColors.sage500;
  }

  Color _o2Color(int? o2) {
    if (o2 == null) return RColors.sand500;
    if (o2 < 94)    return RColors.clay500;
    if (o2 <= 95)   return RColors.saffron500;
    return RColors.sky500;
  }

  Color _gluColor(double? g) {
    if (g == null)              return RColors.sand500;
    if (g > 11.0 || g < 3.9)   return RColors.clay500;
    if (g >= 8.0)               return RColors.saffron500;
    return RColors.sage500;
  }

  bool get _hasAnyInput =>
      _parsedTemp != null ||
      _weightCtrl.text.trim().isNotEmpty ||
      _sbpCtrl.text.trim().isNotEmpty ||
      _hrCtrl.text.trim().isNotEmpty ||
      _o2Ctrl.text.trim().isNotEmpty ||
      _gluCtrl.text.trim().isNotEmpty;

  // ── Save ──────────────────────────────────────────────────────────────────

  void _save() {
    if (!_hasAnyInput) {
      _tempFocus.requestFocus();
      return;
    }
    final sys = int.tryParse(_sbpCtrl.text.trim());
    final dia = int.tryParse(_dbpCtrl.text.trim());
    final s   = widget.session;
    final rec = VitalRecord(
      recordedAt:         DateTime.now(),
      temperatureCelsius: _parsedTemp,
      weightKg: double.tryParse(_weightCtrl.text.replaceAll(',', '.')),
      systolicBp:   sys,
      diastolicBp:  dia,
      heartRateBpm: int.tryParse(_hrCtrl.text.trim()),
      spo2Pct:      int.tryParse(_o2Ctrl.text.trim()),
      glucoseMmol:  double.tryParse(_gluCtrl.text.replaceAll(',', '.')),
      cycleDay: s.dayInCycle > 0 ? s.dayInCycle : null,
      phase:    s.treatmentPhase.isNotEmpty ? s.treatmentPhase : null,
    );
    s.recordVital(rec);
    if (s.supabasePatientId != null) {
      SupabaseService.saveVital(s.supabasePatientId!, rec);
    }
    HapticFeedback.lightImpact();
    setState(() => _saved = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        widget.onSaved();
        Navigator.of(context).pop();
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kb  = MediaQuery.of(context).viewInsets.bottom;
    final sys = int.tryParse(_sbpCtrl.text.trim());
    final dia = int.tryParse(_dbpCtrl.text.trim());
    final hr  = int.tryParse(_hrCtrl.text.trim());
    final o2  = int.tryParse(_o2Ctrl.text.trim());
    final glu = double.tryParse(_gluCtrl.text.replaceAll(',', '.'));

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: kb),
      child: Container(
        decoration: const BoxDecoration(
          color: RColors.surface,
          borderRadius: BorderRadius.vertical(top: RRadius.xl),
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle
            Center(child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36, height: 4,
              decoration: const BoxDecoration(
                color: RColors.sand300, borderRadius: RRadius.pillBR))),

            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
              child: Row(children: [
                Text('Record vitals',
                  style: RText.h3.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                      color: RColors.sand100, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                      size: 18, color: RColors.sand500))),
              ]),
            ),

            const Divider(height: 12),

            // Form fields
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Temperature (featured card)
                _buildTempField(),
                const SizedBox(height: 10),

                // Weight + Blood pressure
                Row(children: [
                  Expanded(child: _buildSimpleField(
                    label: 'Weight', unit: 'kg', hint: '65.0',
                    ctrl: _weightCtrl, decimal: true,
                    icon: Icons.monitor_weight_outlined,
                    color: RColors.sand500,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _buildBpField(sys, dia)),
                ]),
                const SizedBox(height: 10),

                // Heart rate + SpO₂
                Row(children: [
                  Expanded(child: _buildSimpleField(
                    label: 'Heart rate', unit: 'bpm', hint: '70',
                    ctrl: _hrCtrl, decimal: false,
                    icon: Icons.monitor_heart_outlined,
                    color: _hrColor(hr),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _buildSimpleField(
                    label: 'SpO₂', unit: '%', hint: '98',
                    ctrl: _o2Ctrl, decimal: false,
                    icon: Icons.air_rounded,
                    color: _o2Color(o2),
                  )),
                ]),
                const SizedBox(height: 10),

                // Glucose (full width)
                _buildSimpleField(
                  label: 'Blood glucose', unit: 'mmol/L', hint: '5.5',
                  ctrl: _gluCtrl, decimal: true,
                  icon: Icons.water_drop_outlined,
                  color: _gluColor(glu),
                  wide: true,
                ),
                const SizedBox(height: 18),

                // Save button
                _buildSaveButton(),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Temperature field (featured) ──────────────────────────────────────────

  Widget _buildTempField() {
    final color = _tempColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        border: Border.all(
          color: _parsedTemp != null
              ? color.withValues(alpha: 0.4) : RColors.sand200,
          width: _parsedTemp != null ? 1.5 : 1),
        boxShadow: RShadow.shadow1),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _parsedTemp != null
                  ? color.withValues(alpha: 0.12) : RColors.sand100,
              borderRadius: RRadius.smBR),
            child: Icon(
              _parsedTemp != null && _parsedTemp! >= 37.5
                  ? Icons.warning_amber_rounded
                  : Icons.thermostat_rounded,
              size: 17,
              color: _parsedTemp != null ? color : RColors.sand500)),
          const SizedBox(width: 11),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Temperature',
              style: RText.body.copyWith(
                fontWeight: FontWeight.w600, fontSize: 14)),
            Text('Normal: 36.0 – 37.4 °C',
              style: RText.small.copyWith(fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 90,
            child: TextField(
              controller:   _tempCtrl,
              focusNode:    _tempFocus,
              onChanged:    (v) => setState(() {
                _parsedTemp = double.tryParse(v.replaceAll(',', '.'));
                _saved = false;
              }),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                LengthLimitingTextInputFormatter(4),
              ],
              style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w300,
                color: _parsedTemp != null ? color : RColors.sand900,
                letterSpacing: -1,
                fontFeatures: const [FontFeature('tnum')]),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '36.6',
                hintStyle: TextStyle(
                  fontSize: 36, fontWeight: FontWeight.w300,
                  color: RColors.sand400, letterSpacing: -1)),
            ),
          ),
          Text('°C',
            style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w300,
              color: _parsedTemp != null ? color : RColors.sand400)),
        ]),
        if (_parsedTemp != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(
              _parsedTemp! >= 37.5
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              size: 12, color: color),
            const SizedBox(width: 5),
            Text(_tempLabel,
              style: RText.small.copyWith(
                color: color, fontWeight: FontWeight.w500, fontSize: 12)),
          ]),
        ] else ...[
          const SizedBox(height: 4),
          Text('Tap to enter your temperature',
            style: RText.small.copyWith(color: RColors.sand400)),
        ],
      ]),
    );
  }

  // ── BP field (sys / dia combined) ─────────────────────────────────────────

  Widget _buildBpField(int? sys, int? dia) {
    final color    = _bpColor(sys, dia);
    final hasValue = sys != null || dia != null;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(
          color: hasValue ? color.withValues(alpha: 0.35) : RColors.sand200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.favorite_border_rounded, size: 12,
            color: hasValue ? color : RColors.sand500),
          const SizedBox(width: 5),
          Text('Blood pressure',
            style: RText.small.copyWith(fontSize: 10, color: RColors.sand700)),
        ]),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, children: [
          SizedBox(width: 36, child: TextField(
            controller:   _sbpCtrl,
            onChanged:    (_) => setState(() { _saved = false; }),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w300,
              color: hasValue ? color : RColors.sand900,
              fontFeatures: const [FontFeature('tnum')]),
            decoration: const InputDecoration(
              border: InputBorder.none, hintText: '120',
              hintStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w300,
                color: RColors.sand400),
              isDense: true, contentPadding: EdgeInsets.zero),
          )),
          Text('/',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300,
              color: hasValue ? color : RColors.sand400)),
          SizedBox(width: 36, child: TextField(
            controller:   _dbpCtrl,
            onChanged:    (_) => setState(() { _saved = false; }),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w300,
              color: hasValue ? color : RColors.sand900,
              fontFeatures: const [FontFeature('tnum')]),
            decoration: const InputDecoration(
              border: InputBorder.none, hintText: '80',
              hintStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w300,
                color: RColors.sand400),
              isDense: true, contentPadding: EdgeInsets.zero),
          )),
          Text(' mmHg',
            style: RText.small.copyWith(color: RColors.sand500)),
        ]),
      ]),
    );
  }

  // ── Generic optional field ────────────────────────────────────────────────

  Widget _buildSimpleField({
    required String label, required String unit, required String hint,
    required TextEditingController ctrl, required bool decimal,
    required IconData icon, required Color color, bool wide = false,
  }) {
    final hasValue = ctrl.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(
          color: hasValue ? color.withValues(alpha: 0.35) : RColors.sand200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 12, color: hasValue ? color : RColors.sand500),
          const SizedBox(width: 5),
          Text(label,
            style: RText.small.copyWith(fontSize: 10, color: RColors.sand700)),
        ]),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, children: [
          SizedBox(
            width: wide ? 80 : 50,
            child: TextField(
              controller:   ctrl,
              onChanged:    (_) => setState(() { _saved = false; }),
              keyboardType: decimal
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    decimal ? RegExp(r'[\d.,]') : RegExp(r'\d')),
                LengthLimitingTextInputFormatter(decimal ? 5 : 3),
              ],
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w300,
                color: hasValue ? color : RColors.sand900,
                fontFeatures: const [FontFeature('tnum')]),
              decoration: InputDecoration(
                border: InputBorder.none, hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w300,
                  color: RColors.sand400),
                isDense: true, contentPadding: EdgeInsets.zero),
            ),
          ),
          Text(' $unit',
            style: RText.small.copyWith(color: RColors.sand500)),
        ]),
      ]),
    );
  }

  // ── Save button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    if (_saved) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: RColors.sage100,
          borderRadius: RRadius.pillBR,
          border: Border.all(color: RColors.sage300.withValues(alpha: 0.5))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_rounded, size: 16, color: RColors.sage500),
          const SizedBox(width: 8),
          Text('Saved!',
            style: RText.body.copyWith(
              fontWeight: FontWeight.w600,
              color: RColors.sage700, fontSize: 14)),
        ]),
      );
    }
    return GestureDetector(
      onTap: _save,
      child: AnimatedContainer(
        duration: RMotion.duration,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _hasAnyInput ? RColors.teal700 : RColors.sand100,
          borderRadius: RRadius.pillBR,
          boxShadow: _hasAnyInput ? RShadow.shadow3 : const []),
        child: Center(child: Text('Save reading',
          style: RText.body.copyWith(
            fontWeight: FontWeight.w600,
            color: _hasAnyInput ? RColors.surface : RColors.sand500,
            fontSize: 14))),
      ),
    );
  }
}
