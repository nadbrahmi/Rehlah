import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/services/supabase_service.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});
  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _session = UserSession();

  // ── Controllers ───────────────────────────────────────────────────────────
  final _tempCtrl   = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _sbpCtrl    = TextEditingController();
  final _dbpCtrl    = TextEditingController();
  final _hrCtrl     = TextEditingController();
  final _o2Ctrl     = TextEditingController();
  final _gluCtrl    = TextEditingController();
  final _tempFocus  = FocusNode();

  double? _parsedTemp;
  bool _saved = false;

  @override
  void dispose() {
    _tempCtrl.dispose(); _weightCtrl.dispose();
    _sbpCtrl.dispose(); _dbpCtrl.dispose(); _hrCtrl.dispose();
    _o2Ctrl.dispose(); _gluCtrl.dispose(); _tempFocus.dispose();
    super.dispose();
  }

  // ── Temperature feedback ──────────────────────────────────────────────────
  Color get _tempColor {
    if (_parsedTemp == null) return RColors.sand500;
    if (_parsedTemp! >= 38.5) return RColors.clay700;
    if (_parsedTemp! >= 38.0) return RColors.clay500;
    if (_parsedTemp! >= 37.5) return RColors.saffron500;
    if (_parsedTemp! < 36.0)  return RColors.sky500;
    return RColors.sage500;
  }

  String get _tempLabel {
    if (_parsedTemp == null) return '';
    if (_parsedTemp! >= 38.5) return 'High fever — contact your care team now';
    if (_parsedTemp! >= 38.0) return 'Fever — call your care team today';
    if (_parsedTemp! >= 37.5) return 'Low-grade fever — monitor closely';
    if (_parsedTemp! < 36.0)  return 'Low — note this and mention to your team';
    return 'Normal range';
  }

  IconData get _tempIcon {
    if (_parsedTemp == null) return Icons.thermostat_rounded;
    if (_parsedTemp! >= 37.5) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline_rounded;
  }

  void _onTempChanged(String v) {
    setState(() {
      _parsedTemp = double.tryParse(v.replaceAll(',', '.'));
      _saved = false;
    });
  }

  // ── BP feedback ───────────────────────────────────────────────────────────
  Color _bpColor(int? sys, int? dia) {
    if (sys == null && dia == null) return RColors.sand500;
    if ((sys != null && (sys > 160 || sys < 90)) ||
        (dia != null && dia > 100)) return RColors.clay500;
    if ((sys != null && sys >= 140) ||
        (dia != null && dia >= 90)) return RColors.saffron500;
    return RColors.sage500;
  }

  // ── HR feedback ───────────────────────────────────────────────────────────
  Color _hrColor(int? hr) {
    if (hr == null) return RColors.sand500;
    if (hr > 100 || hr < 50) return RColors.clay500;
    if (hr >= 90) return RColors.saffron500;
    return RColors.sage500;
  }

  // ── SpO₂ feedback ─────────────────────────────────────────────────────────
  Color _o2Color(int? o2) {
    if (o2 == null) return RColors.sand500;
    if (o2 < 94) return RColors.clay500;
    if (o2 <= 95) return RColors.saffron500;
    return RColors.sky500;
  }

  // ── Glucose feedback ──────────────────────────────────────────────────────
  Color _gluColor(double? g) {
    if (g == null) return RColors.sand500;
    if (g > 11.0 || g < 3.9) return RColors.clay500;
    if (g >= 8.0) return RColors.saffron500;
    return RColors.sage500;
  }

  // ── Any input entered? ────────────────────────────────────────────────────
  bool get _hasAnyInput => _parsedTemp != null ||
      _weightCtrl.text.trim().isNotEmpty ||
      _sbpCtrl.text.trim().isNotEmpty ||
      _hrCtrl.text.trim().isNotEmpty ||
      _o2Ctrl.text.trim().isNotEmpty ||
      _gluCtrl.text.trim().isNotEmpty;

  // ── Record ────────────────────────────────────────────────────────────────
  void _record() {
    if (!_hasAnyInput) {
      _tempFocus.requestFocus();
      return;
    }
    final sys = int.tryParse(_sbpCtrl.text.trim());
    final dia = int.tryParse(_dbpCtrl.text.trim());
    final record = VitalRecord(
      recordedAt:         DateTime.now(),
      temperatureCelsius: _parsedTemp,
      weightKg:           double.tryParse(_weightCtrl.text.replaceAll(',', '.')),
      systolicBp:         sys,
      diastolicBp:        dia,
      heartRateBpm:       int.tryParse(_hrCtrl.text.trim()),
      spo2Pct:            int.tryParse(_o2Ctrl.text.trim()),
      glucoseMmol:        double.tryParse(_gluCtrl.text.replaceAll(',', '.')),
      cycleDay:           _session.dayInCycle > 0 ? _session.dayInCycle : null,
      phase:              _session.treatmentPhase.isNotEmpty ? _session.treatmentPhase : null,
    );
    _session.recordVital(record);
    if (_session.supabasePatientId != null) {
      SupabaseService.saveVital(_session.supabasePatientId!, record);
    }
    HapticFeedback.lightImpact();
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) context.pop();
    });
  }

  // ── Weight flag helper (needs history context) ────────────────────────────
  VitalFlag _weightFlag(VitalRecord r, List<VitalRecord> all) {
    if (r.weightKg == null) return VitalFlag.normal;
    final prev = all.where((v) => v != r && v.weightKg != null).toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    if (prev.isEmpty) return VitalFlag.normal;
    final delta = (r.weightKg! - prev.first.weightKg!).abs();
    if (delta >= 2.0) return VitalFlag.high;
    if (delta >= 1.0) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isNadir  = _session.isNadirWindow;
    final vitals   = _session.vitals;
    final sys = int.tryParse(_sbpCtrl.text.trim());
    final dia = int.tryParse(_dbpCtrl.text.trim());
    final hr  = int.tryParse(_hrCtrl.text.trim());
    final o2  = int.tryParse(_o2Ctrl.text.trim());
    final glu = double.tryParse(_gluCtrl.text.replaceAll(',', '.'));

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        child: Column(children: [
          _topbar(context, vitals),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isNadir) _buildNadirBanner(),
              if (!isNadir && _session.treatmentPhase == 'In chemotherapy')
                _buildPhaseBanner(),

              const SizedBox(height: 16),

              // ── Temperature (featured card) ────────────────────────────
              _buildTempCard(),
              const SizedBox(height: 12),

              // ── Weight + BP row ────────────────────────────────────────
              Row(children: [
                Expanded(child: _buildField(
                  label: 'Weight', unit: 'kg', hint: '65.0',
                  ctrl: _weightCtrl, decimal: true,
                  icon: Icons.monitor_weight_outlined,
                  color: RColors.sand500,
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildBpCard(sys, dia)),
              ]),
              const SizedBox(height: 10),

              // ── HR + SpO₂ row ──────────────────────────────────────────
              Row(children: [
                Expanded(child: _buildField(
                  label: 'Heart rate', unit: 'bpm', hint: '70',
                  ctrl: _hrCtrl, decimal: false,
                  icon: Icons.monitor_heart_outlined,
                  color: _hrColor(hr),
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildField(
                  label: 'SpO₂', unit: '%', hint: '98',
                  ctrl: _o2Ctrl, decimal: false,
                  icon: Icons.air_rounded,
                  color: _o2Color(o2),
                )),
              ]),
              const SizedBox(height: 10),

              // ── Glucose (full width) ───────────────────────────────────
              _buildField(
                label: 'Blood glucose', unit: 'mmol/L', hint: '5.5',
                ctrl: _gluCtrl, decimal: true,
                icon: Icons.water_drop_outlined,
                color: _gluColor(glu),
                fullWidth: true,
              ),

              const SizedBox(height: 20),
              _buildRecordButton(),

              // ── History ────────────────────────────────────────────────
              if (vitals.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('RECENT READINGS', style: RText.eyebrow),
                const SizedBox(height: 8),
                _buildHistory(vitals),
              ],
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _topbar(BuildContext context, List<VitalRecord> vitals) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: RColors.surface, shape: BoxShape.circle,
              border: Border.all(color: RColors.sand200)),
            child: const Icon(Icons.chevron_left_rounded,
                color: RColors.sand700, size: 22),
          ),
        ),
        const Expanded(child: Center(child: Text('Vitals',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        if (vitals.isNotEmpty)
          Container(
            height: 36, alignment: Alignment.center,
            child: Text('${vitals.length} recorded',
              style: const TextStyle(fontSize: 11, color: RColors.sand500)),
          )
        else
          const SizedBox(width: 36),
      ]),
    );
  }

  // ── Nadir / phase banners ─────────────────────────────────────────────────
  Widget _buildNadirBanner() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: RColors.clay100,
      borderRadius: RRadius.mdBR,
      border: Border.all(color: RColors.clay300.withValues(alpha: 0.4), width: 0.5)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('⚠', style: TextStyle(fontSize: 15)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Nadir window — extra vigilance',
          style: RText.body.copyWith(
            fontWeight: FontWeight.w600, color: RColors.clay700, fontSize: 13)),
        const SizedBox(height: 2),
        Text('Record temperature at least twice a day. '
            'Fever ≥37.5°C requires immediate contact with your care team.',
          style: RText.small.copyWith(color: RColors.clay500, height: 1.5)),
      ])),
    ]),
  );

  Widget _buildPhaseBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: RColors.teal50,
      borderRadius: RRadius.mdBR,
      border: Border.all(color: RColors.teal200, width: 0.5)),
    child: Row(children: [
      const Text('💊', style: TextStyle(fontSize: 14)),
      const SizedBox(width: 10),
      Text('Day ${_session.dayInCycle} · ${_session.currentPhase.name}',
        style: RText.body.copyWith(
          fontWeight: FontWeight.w600, color: RColors.teal700, fontSize: 13)),
    ]),
  );

  // ── Temperature card (featured) ───────────────────────────────────────────
  Widget _buildTempCard() {
    final color = _tempColor;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        border: Border.all(
          color: _parsedTemp != null
              ? color.withValues(alpha: 0.35) : RColors.sand200,
          width: _parsedTemp != null ? 1 : 0.5),
        boxShadow: RShadow.shadow2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _parsedTemp != null
                  ? color.withValues(alpha: 0.12) : RColors.sand100,
              borderRadius: RRadius.smBR),
            child: Icon(_tempIcon, size: 17,
              color: _parsedTemp != null ? color : RColors.sand500)),
          const SizedBox(width: 11),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Temperature',
              style: RText.body.copyWith(fontWeight: FontWeight.w600)),
            Text('Normal: 36.0–37.4 °C',
              style: RText.small.copyWith(fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 90,
            child: TextField(
              controller: _tempCtrl,
              focusNode: _tempFocus,
              onChanged: _onTempChanged,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                LengthLimitingTextInputFormatter(4),
              ],
              style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w300,
                color: _parsedTemp != null ? color : RColors.sand900,
                letterSpacing: -1,
                fontFeatures: const [FontFeature('tnum')],
              ),
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
          const SizedBox(height: 8),
          Row(children: [
            Icon(_tempIcon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(_tempLabel,
              style: RText.small.copyWith(
                color: color, fontWeight: FontWeight.w500)),
          ]),
        ],
        if (_parsedTemp == null) ...[
          const SizedBox(height: 4),
          Text('Tap to enter your temperature', style: RText.small),
        ],
      ]),
    );
  }

  // ── BP card (sys / dia combined) ──────────────────────────────────────────
  Widget _buildBpCard(int? sys, int? dia) {
    final color = _bpColor(sys, dia);
    final hasValue = sys != null || dia != null;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(
          color: hasValue ? color.withValues(alpha: 0.35) : RColors.sand200,
          width: hasValue ? 1 : 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.favorite_border_rounded, size: 13,
            color: hasValue ? color : RColors.sand500),
          const SizedBox(width: 5),
          Text('Blood pressure',
            style: RText.small.copyWith(fontSize: 10, color: RColors.sand700)),
        ]),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, children: [
          SizedBox(
            width: 36,
            child: TextField(
              controller: _sbpCtrl,
              onChanged: (_) => setState(() { _saved = false; }),
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
            ),
          ),
          Text('/',
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w300,
              color: hasValue ? color : RColors.sand400)),
          SizedBox(
            width: 36,
            child: TextField(
              controller: _dbpCtrl,
              onChanged: (_) => setState(() { _saved = false; }),
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
            ),
          ),
          Text(' mmHg', style: RText.small.copyWith(color: RColors.sand500)),
        ]),
      ]),
    );
  }

  // ── Generic optional field card ───────────────────────────────────────────
  Widget _buildField({
    required String label, required String unit, required String hint,
    required TextEditingController ctrl, required bool decimal,
    required IconData icon, required Color color, bool fullWidth = false,
  }) {
    final hasValue = ctrl.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(
          color: hasValue ? color.withValues(alpha: 0.35) : RColors.sand200,
          width: hasValue ? 1 : 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: hasValue ? color : RColors.sand500),
          const SizedBox(width: 5),
          Text(label,
            style: RText.small.copyWith(fontSize: 10, color: RColors.sand700)),
        ]),
        const SizedBox(height: 6),
        Row(crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, children: [
          SizedBox(
            width: fullWidth ? 80 : 50,
            child: TextField(
              controller: ctrl,
              onChanged: (_) => setState(() { _saved = false; }),
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
                border: InputBorder.none,
                hintText: hint,
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

  // ── Record button ─────────────────────────────────────────────────────────
  Widget _buildRecordButton() {
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
          Text('Recorded',
            style: RText.body.copyWith(
              fontWeight: FontWeight.w600,
              color: RColors.sage700, fontSize: 14)),
        ]),
      );
    }
    return GestureDetector(
      onTap: _hasAnyInput ? _record : () => _tempFocus.requestFocus(),
      child: AnimatedContainer(
        duration: RMotion.duration,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _hasAnyInput ? RColors.teal700 : RColors.sand100,
          borderRadius: RRadius.pillBR,
          boxShadow: _hasAnyInput ? RShadow.shadow3 : const []),
        child: Center(child: Text('Record reading',
          style: RText.body.copyWith(
            fontWeight: FontWeight.w600,
            color: _hasAnyInput ? RColors.surface : RColors.sand500,
            fontSize: 14))),
      ),
    );
  }

  // ── History list ──────────────────────────────────────────────────────────
  Widget _buildHistory(List<VitalRecord> vitals) {
    final reversed = vitals.reversed.toList(); // newest first
    return Container(
      decoration: const BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        boxShadow: RShadow.shadow1),
      child: Column(children: [
        ...reversed.take(10).toList().asMap().entries.map((e) {
          final i = e.key;
          final v = e.value;
          final isLast = i == reversed.take(10).length - 1;

          final flag = v.worstFlag;
          final dotColor = flag == VitalFlag.high   ? RColors.clay500
              : flag == VitalFlag.moderate ? RColors.saffron500
              : v.isFever                  ? RColors.clay500
              : RColors.sage500;

          final now  = DateTime.now();
          final diff = now.difference(v.recordedAt);
          final timeLabel = diff.inMinutes < 60
              ? '${diff.inMinutes}m ago'
              : diff.inHours < 24
                  ? '${diff.inHours}h ago'
                  : DateFormat('d MMM · HH:mm').format(v.recordedAt);

          final wf = _weightFlag(v, vitals.toList());

          return Container(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            decoration: isLast ? null : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: RColors.sand200, width: 0.5))),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Wrap(
                spacing: 10, runSpacing: 2,
                children: [
                  if (v.temperatureCelsius != null)
                    _historyChip(
                      '${v.temperatureCelsius!.toStringAsFixed(1)} °C',
                      v.tempFlag),
                  if (v.systolicBp != null && v.diastolicBp != null)
                    _historyChip(
                      '${v.systolicBp}/${v.diastolicBp} mmHg',
                      v.bpFlag),
                  if (v.heartRateBpm != null)
                    _historyChip('${v.heartRateBpm} bpm', v.hrFlag),
                  if (v.spo2Pct != null)
                    _historyChip('${v.spo2Pct}% O₂', v.spo2Flag),
                  if (v.glucoseMmol != null)
                    _historyChip(
                      '${v.glucoseMmol!.toStringAsFixed(1)} mmol/L',
                      v.glucoseFlag),
                  if (v.weightKg != null)
                    _historyChip(
                      '${v.weightKg!.toStringAsFixed(1)} kg', wf),
                ],
              )),
              const SizedBox(width: 8),
              Text(timeLabel,
                style: RText.small.copyWith(fontSize: 10)),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _historyChip(String value, VitalFlag flag) {
    final c = flag == VitalFlag.normal ? RColors.sand700
        : flag == VitalFlag.moderate   ? RColors.saffron500
        : RColors.clay500;
    return Text(value,
      style: RText.body.copyWith(
        fontSize: 13,
        color: c,
        fontWeight: flag != VitalFlag.normal
            ? FontWeight.w600 : FontWeight.w400,
        fontFeatures: const [FontFeature('tnum')]));
  }
}
