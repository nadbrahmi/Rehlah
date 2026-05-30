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

  // ── Flag colour / label helpers ───────────────────────────────────────────
  static Color _flagColor(VitalFlag f) => switch (f) {
    VitalFlag.high     => RColors.clay500,
    VitalFlag.moderate => RColors.saffron500,
    VitalFlag.normal   => RColors.sage500,
  };

  static Color _flagBg(VitalFlag f) => switch (f) {
    VitalFlag.high     => RColors.clay100,
    VitalFlag.moderate => RColors.saffron100,
    VitalFlag.normal   => RColors.sage100,
  };

  static String _flagLabel(VitalFlag f) => switch (f) {
    VitalFlag.high     => 'HIGH',
    VitalFlag.moderate => 'MODERATE',
    VitalFlag.normal   => 'STABLE',
  };

  static IconData _flagIcon(VitalFlag f) => switch (f) {
    VitalFlag.high     => Icons.warning_amber_rounded,
    VitalFlag.moderate => Icons.info_outline_rounded,
    VitalFlag.normal   => Icons.check_circle_outline_rounded,
  };

  // ── Weight flag (context-dependent) ─────────────────────────────────────
  VitalFlag _weightFlag(VitalRecord r, List<VitalRecord> all) {
    if (r.weightKg == null) return VitalFlag.normal;
    final prev = all
        .where((v) => v != r && v.weightKg != null)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    if (prev.isEmpty) return VitalFlag.normal;
    final delta = (r.weightKg! - prev.first.weightKg!).abs();
    if (delta >= 2.0) return VitalFlag.high;
    if (delta >= 1.0) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  VitalFlag _worst(VitalRecord r, List<VitalRecord> all) {
    final flags = [r.worstFlag, _weightFlag(r, all)];
    if (flags.any((f) => f == VitalFlag.high))     return VitalFlag.high;
    if (flags.any((f) => f == VitalFlag.moderate)) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  // ── Log bottom sheet ──────────────────────────────────────────────────────
  void _openLog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogSheet(
        session: _session,
        onSaved: () => setState(() {}),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final vitals = _session.vitals.reversed.toList(); // newest first
    final highToday = _session.hasHighAlertToday;

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(context, vitals),
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 120 + MediaQuery.of(context).padding.bottom),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (highToday) _highBanner(),
              const SizedBox(height: 0),
              _hero(vitals),
              const SizedBox(height: 12),
              _logBtn(),
              if (vitals.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('READINGS', style: RText.eyebrow),
                const SizedBox(height: 8),
                _history(vitals),
              ],
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _topbar(BuildContext context, List<VitalRecord> vitals) {
    final highCount = vitals.where((v) => v.worstFlag == VitalFlag.high).length;
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
        if (highCount > 0)
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: RColors.clay100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: RColors.clay300.withValues(alpha: 0.5))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.warning_amber_rounded, size: 13, color: RColors.clay700),
              const SizedBox(width: 4),
              Text('$highCount HIGH',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: RColors.clay700)),
            ]),
          )
        else
          const SizedBox(width: 36),
      ]),
    );
  }

  // ── HIGH alert banner ─────────────────────────────────────────────────────
  Widget _highBanner() => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: RColors.clay100,
      borderRadius: RRadius.mdBR,
      border: Border.all(color: RColors.clay500.withValues(alpha: 0.35))),
    child: Row(children: [
      const Icon(Icons.warning_amber_rounded, size: 18, color: RColors.clay700),
      const SizedBox(width: 10),
      Expanded(child: Text('HIGH alert — contact your care team today',
        style: RText.small.copyWith(
          fontWeight: FontWeight.w600, color: RColors.clay700))),
    ]),
  );

  // ── Hero summary card ─────────────────────────────────────────────────────
  Widget _hero(List<VitalRecord> vitals) {
    if (vitals.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: const BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.lgBR,
          boxShadow: RShadow.shadow2),
        child: Column(children: [
          const Text('📋', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 10),
          Text('No readings yet',
            style: RText.body.copyWith(
              fontWeight: FontWeight.w600, color: RColors.sand700)),
          const SizedBox(height: 4),
          Text('Tap "Log reading" to track your vitals',
            style: RText.small, textAlign: TextAlign.center),
        ]),
      );
    }

    final latest = vitals.first;
    final worst  = _worst(latest, vitals);
    final fc     = _flagColor(worst);
    final now    = DateTime.now();
    final diff   = now.difference(latest.recordedAt);
    final timeAgo = diff.inMinutes < 60
        ? '${diff.inMinutes}m ago'
        : diff.inHours < 24
            ? '${diff.inHours}h ago'
            : DateFormat('d MMM · HH:mm').format(latest.recordedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        border: Border.all(
          color: worst != VitalFlag.normal ? fc.withValues(alpha: 0.35) : RColors.sand200,
          width: worst != VitalFlag.normal ? 1.5 : 0.5),
        boxShadow: RShadow.shadow2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _flagChip(worst),
          const Spacer(),
          Text('LATEST  ·  $timeAgo', style: RText.eyebrow),
        ]),
        const SizedBox(height: 14),
        Wrap(spacing: 18, runSpacing: 10, children: [
          if (latest.temperatureCelsius != null)
            _heroVal('Temp', '${latest.temperatureCelsius!.toStringAsFixed(1)}°C', latest.tempFlag),
          if (latest.systolicBp != null && latest.diastolicBp != null)
            _heroVal('BP', '${latest.systolicBp}/${latest.diastolicBp}', latest.bpFlag),
          if (latest.heartRateBpm != null)
            _heroVal('HR', '${latest.heartRateBpm} bpm', latest.hrFlag),
          if (latest.spo2Pct != null)
            _heroVal('SpO₂', '${latest.spo2Pct}%', latest.spo2Flag),
          if (latest.glucoseMmol != null)
            _heroVal('Glucose', '${latest.glucoseMmol!.toStringAsFixed(1)} mmol/L', latest.glucoseFlag),
          if (latest.weightKg != null)
            _heroVal('Weight', '${latest.weightKg!.toStringAsFixed(1)} kg', _weightFlag(latest, vitals)),
        ]),
      ]),
    );
  }

  Widget _heroVal(String label, String value, VitalFlag flag) {
    final c = flag == VitalFlag.normal ? RColors.sand900 : _flagColor(flag);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: RText.eyebrow),
      Text(value,
        style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: c,
          letterSpacing: -0.5,
          fontFeatures: const [FontFeature('tnum')])),
    ]);
  }

  Widget _flagChip(VitalFlag f) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: _flagBg(f), borderRadius: RRadius.smBR),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(_flagIcon(f), size: 12, color: _flagColor(f)),
      const SizedBox(width: 4),
      Text(_flagLabel(f),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
            color: _flagColor(f))),
    ]),
  );

  // ── Log button ────────────────────────────────────────────────────────────
  Widget _logBtn() => GestureDetector(
    onTap: _openLog,
    child: Container(
      height: 48,
      decoration: const BoxDecoration(
        color: RColors.teal700,
        borderRadius: RRadius.pillBR,
        boxShadow: RShadow.shadow3),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 6),
        Text('Log reading',
          style: RText.body.copyWith(
            fontWeight: FontWeight.w600, color: Colors.white, fontSize: 15)),
      ]),
    ),
  );

  // ── History list (grouped by day) ─────────────────────────────────────────
  Widget _history(List<VitalRecord> vitals) {
    final groups = <String, List<VitalRecord>>{};
    for (final v in vitals) {
      final key = DateFormat('yyyy-MM-dd').format(v.recordedAt);
      groups.putIfAbsent(key, () => []).add(v);
    }

    return Column(children: groups.entries.map((entry) {
      final dayVitals = entry.value;
      final date = DateTime.parse(entry.key);
      final now  = DateTime.now();
      final isToday = date.year == now.year &&
          date.month == now.month && date.day == now.day;
      final isYesterday = DateTime(now.year, now.month, now.day)
          .difference(date).inDays == 1;
      final dayLabel = isToday ? 'Today'
          : isYesterday ? 'Yesterday'
          : DateFormat('EEE, d MMM').format(date);

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 4),
          child: Text(dayLabel.toUpperCase(), style: RText.eyebrow),
        ),
        Container(
          decoration: const BoxDecoration(
            color: RColors.surface,
            borderRadius: RRadius.mdBR,
            boxShadow: RShadow.shadow1),
          child: Column(children: dayVitals.asMap().entries.map((e) {
            final isLast = e.key == dayVitals.length - 1;
            return _historyCard(e.value, vitals, isLast);
          }).toList()),
        ),
        const SizedBox(height: 12),
      ]);
    }).toList());
  }

  Widget _historyCard(VitalRecord v, List<VitalRecord> all, bool isLast) {
    final worst = _worst(v, all);
    final fc    = _flagColor(worst);
    final time  = DateFormat('HH:mm').format(v.recordedAt);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: isLast ? null : const BoxDecoration(
        border: Border(bottom: BorderSide(color: RColors.sand200, width: 0.5))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 8, height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(color: fc, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(time,
            style: RText.small.copyWith(
              fontWeight: FontWeight.w600,
              color: worst == VitalFlag.high ? fc : RColors.sand700,
              fontSize: 11)),
          const SizedBox(height: 3),
          Wrap(spacing: 10, runSpacing: 3, children: [
            if (v.temperatureCelsius != null)
              _miniVal('${v.temperatureCelsius!.toStringAsFixed(1)}°C', v.tempFlag),
            if (v.systolicBp != null && v.diastolicBp != null)
              _miniVal('${v.systolicBp}/${v.diastolicBp} mmHg', v.bpFlag),
            if (v.heartRateBpm != null)
              _miniVal('${v.heartRateBpm} bpm', v.hrFlag),
            if (v.spo2Pct != null)
              _miniVal('${v.spo2Pct}% O₂', v.spo2Flag),
            if (v.glucoseMmol != null)
              _miniVal('${v.glucoseMmol!.toStringAsFixed(1)} mmol/L', v.glucoseFlag),
            if (v.weightKg != null)
              _miniVal('${v.weightKg!.toStringAsFixed(1)} kg', _weightFlag(v, all)),
          ]),
        ])),
        if (worst != VitalFlag.normal) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _flagBg(worst), borderRadius: RRadius.smBR),
            child: Text(_flagLabel(worst),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                  color: fc))),
        ],
      ]),
    );
  }

  Widget _miniVal(String value, VitalFlag flag) {
    final c = flag == VitalFlag.normal ? RColors.sand700 : _flagColor(flag);
    return Text(value,
      style: TextStyle(
        fontSize: 12, color: c,
        fontWeight: flag != VitalFlag.normal ? FontWeight.w600 : FontWeight.w400,
        fontFeatures: const [FontFeature('tnum')]));
  }
}

// ── Log reading bottom sheet ──────────────────────────────────────────────────

class _LogSheet extends StatefulWidget {
  final UserSession session;
  final VoidCallback onSaved;
  const _LogSheet({required this.session, required this.onSaved});

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  final _weightCtrl = TextEditingController();
  final _sbpCtrl    = TextEditingController();
  final _dbpCtrl    = TextEditingController();
  final _hrCtrl     = TextEditingController();
  final _tempCtrl   = TextEditingController();
  final _o2Ctrl     = TextEditingController();
  final _gluCtrl    = TextEditingController();

  bool _saving = false;
  bool _saved  = false;

  bool get _hasInput => [
    _weightCtrl, _sbpCtrl, _dbpCtrl, _hrCtrl, _tempCtrl, _o2Ctrl, _gluCtrl,
  ].any((c) => c.text.trim().isNotEmpty);

  @override
  void dispose() {
    _weightCtrl.dispose(); _sbpCtrl.dispose(); _dbpCtrl.dispose();
    _hrCtrl.dispose(); _tempCtrl.dispose(); _o2Ctrl.dispose();
    _gluCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_hasInput) return;
    setState(() => _saving = true);

    final s = widget.session;
    final record = VitalRecord(
      recordedAt:         DateTime.now(),
      weightKg:           double.tryParse(_weightCtrl.text.replaceAll(',', '.')),
      systolicBp:         int.tryParse(_sbpCtrl.text),
      diastolicBp:        int.tryParse(_dbpCtrl.text),
      heartRateBpm:       int.tryParse(_hrCtrl.text),
      temperatureCelsius: double.tryParse(_tempCtrl.text.replaceAll(',', '.')),
      spo2Pct:            int.tryParse(_o2Ctrl.text),
      glucoseMmol:        double.tryParse(_gluCtrl.text.replaceAll(',', '.')),
      cycleDay:           s.dayInCycle > 0 ? s.dayInCycle : null,
      phase:              s.treatmentPhase.isNotEmpty ? s.treatmentPhase : null,
    );

    s.recordVital(record);
    HapticFeedback.lightImpact();

    if (s.supabasePatientId != null) {
      SupabaseService.saveVital(s.supabasePatientId!, record); // fire-and-forget
    }

    setState(() { _saving = false; _saved = true; });
    widget.onSaved();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: RColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: RColors.sand200,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Log reading', style: RText.h2.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text('Enter any values you have', style: RText.small),
          const SizedBox(height: 20),

          _field(label: 'Weight', hint: '65.0', unit: 'kg',
            ctrl: _weightCtrl, decimal: true, icon: Icons.monitor_weight_outlined),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(label: 'Systolic BP', hint: '120', unit: 'mmHg',
              ctrl: _sbpCtrl, decimal: false, icon: Icons.favorite_border_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _field(label: 'Diastolic BP', hint: '80', unit: 'mmHg',
              ctrl: _dbpCtrl, decimal: false, icon: Icons.favorite_border_rounded,
              showIcon: false)),
          ]),
          const SizedBox(height: 12),
          _field(label: 'Heart rate', hint: '70', unit: 'bpm',
            ctrl: _hrCtrl, decimal: false, icon: Icons.monitor_heart_outlined),
          const SizedBox(height: 12),
          _field(label: 'Temperature', hint: '36.6', unit: '°C',
            ctrl: _tempCtrl, decimal: true, icon: Icons.thermostat_rounded),
          const SizedBox(height: 12),
          _field(label: 'SpO₂', hint: '98', unit: '%',
            ctrl: _o2Ctrl, decimal: false, icon: Icons.air_rounded),
          const SizedBox(height: 12),
          _field(label: 'Blood glucose', hint: '5.5', unit: 'mmol/L',
            ctrl: _gluCtrl, decimal: true, icon: Icons.water_drop_outlined),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: (_saving || _saved) ? null : _save,
            child: AnimatedContainer(
              duration: RMotion.duration,
              height: 50,
              decoration: BoxDecoration(
                color: _saved    ? RColors.sage100
                    : _hasInput  ? RColors.teal700
                    : RColors.sand100,
                borderRadius: RRadius.pillBR,
                boxShadow: _hasInput && !_saved ? RShadow.shadow3 : const []),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (_saving) ...[
                  const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white)),
                ] else if (_saved) ...[
                  const Icon(Icons.check_rounded, size: 18, color: RColors.sage500),
                  const SizedBox(width: 8),
                  Text('Saved',
                    style: RText.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: RColors.sage700, fontSize: 15)),
                ] else ...[
                  Text('Save reading',
                    style: RText.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _hasInput ? Colors.white : RColors.sand400,
                      fontSize: 15)),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field({
    required String label, required String hint, required String unit,
    required TextEditingController ctrl, required bool decimal,
    required IconData icon, bool showIcon = true,
  }) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: BoxDecoration(
      color: RColors.sand50,
      borderRadius: RRadius.mdBR,
      border: Border.all(color: RColors.sand200)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        if (showIcon) ...[
          Icon(icon, size: 12, color: RColors.sand500),
          const SizedBox(width: 5),
        ],
        Text(label,
          style: RText.small.copyWith(fontSize: 11, color: RColors.sand700)),
      ]),
      const SizedBox(height: 4),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: TextField(
            controller: ctrl,
            onChanged: (_) => setState(() {}),
            keyboardType: decimal
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  decimal ? RegExp(r'[\d.,]') : RegExp(r'\d')),
              LengthLimitingTextInputFormatter(decimal ? 5 : 3),
            ],
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500,
              color: RColors.sand900,
              fontFeatures: [FontFeature('tnum')]),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w300,
                color: RColors.sand400),
              isDense: true, contentPadding: EdgeInsets.zero),
          )),
          Text(' $unit',
            style: RText.small.copyWith(color: RColors.sand500)),
        ],
      ),
    ]),
  );
}
