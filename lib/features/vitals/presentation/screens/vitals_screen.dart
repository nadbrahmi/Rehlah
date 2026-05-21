import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});
  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _session = UserSession();
  final _tempController = TextEditingController();
  final _pulseController = TextEditingController();
  final _o2Controller = TextEditingController();
  final _tempFocus = FocusNode();

  double? _parsedTemp;
  bool _saved = false;

  @override
  void dispose() {
    _tempController.dispose();
    _pulseController.dispose();
    _o2Controller.dispose();
    _tempFocus.dispose();
    super.dispose();
  }

  Color get _tempColor {
    if (_parsedTemp == null) return RColors.sand500;
    if (_parsedTemp! >= 38.5) return RColors.clay700;
    if (_parsedTemp! >= 37.5) return RColors.clay500;
    if (_parsedTemp! < 36.0) return RColors.sky500;
    return RColors.sage500;
  }

  String get _tempLabel {
    if (_parsedTemp == null) return '';
    if (_parsedTemp! >= 38.5) return 'High fever — contact your care team now';
    if (_parsedTemp! >= 37.5) return 'Fever — call your care team today';
    if (_parsedTemp! < 36.0) return 'Low — note this and mention to your team';
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

  void _record() {
    final temp = _parsedTemp;
    if (temp == null) {
      _tempFocus.requestFocus();
      return;
    }
    final pulse = int.tryParse(_pulseController.text.trim());
    final o2    = int.tryParse(_o2Controller.text.trim());
    _session.recordVital(VitalRecord(
      recordedAt: DateTime.now(),
      temperatureCelsius: temp,
      pulse: pulse,
      oxygenSaturation: o2,
    ));
    HapticFeedback.lightImpact();
    setState(() { _saved = true; });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNadir = _session.isNadirWindow;
    final vitals  = _session.vitals;

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: RColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: RColors.sand200),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: RColors.sand700, size: 22),
                ),
              ),
              const Expanded(child: Center(child: Text('Vitals',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                    letterSpacing: -0.2)))),
              if (vitals.isNotEmpty)
                Container(
                  height: 36,
                  alignment: Alignment.center,
                  child: Text('${vitals.length} recorded',
                    style: const TextStyle(fontSize: 11, color: RColors.sand500)),
                )
              else
                const SizedBox(width: 36),
            ]),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (isNadir) _buildNadirBanner(),
              if (!isNadir && _session.treatmentPhase == 'In chemotherapy')
                _buildPhaseBanner(),

              const SizedBox(height: 16),
              _buildTemperatureCard(),
              const SizedBox(height: 12),
              _buildOptionalRow(),
              const SizedBox(height: 20),
              _buildRecordButton(),

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
          style: RText.body.copyWith(fontWeight: FontWeight.w600, color: RColors.clay700, fontSize: 13)),
        const SizedBox(height: 2),
        Text('Record temperature at least twice a day. Fever ≥37.5°C requires immediate contact with your care team.',
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
        style: RText.body.copyWith(fontWeight: FontWeight.w600, color: RColors.teal700, fontSize: 13)),
    ]),
  );

  Widget _buildTemperatureCard() {
    final color = _tempColor;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        border: Border.all(
          color: _parsedTemp != null ? color.withValues(alpha: 0.35) : RColors.sand200,
          width: _parsedTemp != null ? 1 : 0.5),
        boxShadow: RShadow.shadow2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _parsedTemp != null ? color.withValues(alpha: 0.12) : RColors.sand100,
              borderRadius: RRadius.smBR),
            child: Icon(_tempIcon, size: 17,
              color: _parsedTemp != null ? color : RColors.sand500)),
          const SizedBox(width: 11),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Temperature',
              style: RText.body.copyWith(fontWeight: FontWeight.w600)),
            Text('Normal: 36.0–37.4 °C', style: RText.small.copyWith(fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 90,
            child: TextField(
              controller: _tempController,
              focusNode: _tempFocus,
              onChanged: _onTempChanged,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                LengthLimitingTextInputFormatter(4),
              ],
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: _parsedTemp != null ? color : RColors.sand900,
                letterSpacing: -1,
                fontFeatures: const [FontFeature('tnum')],
              ),
              decoration: InputDecoration(
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

  Widget _buildOptionalRow() => Row(children: [
    Expanded(child: _buildOptionalField(
      label: 'Pulse',
      unit: 'bpm',
      hint: '70',
      controller: _pulseController,
      icon: Icons.favorite_border_rounded,
      color: RColors.clay500,
    )),
    const SizedBox(width: 10),
    Expanded(child: _buildOptionalField(
      label: 'O₂ saturation',
      unit: '%',
      hint: '98',
      controller: _o2Controller,
      icon: Icons.air_rounded,
      color: RColors.sky500,
    )),
  ]);

  Widget _buildOptionalField({
    required String label, required String unit, required String hint,
    required TextEditingController controller,
    required IconData icon, required Color color,
  }) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: RColors.surface,
      borderRadius: RRadius.mdBR,
      border: Border.all(color: RColors.sand200, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label, style: RText.small.copyWith(fontSize: 10, color: RColors.sand700)),
      ]),
      const SizedBox(height: 6),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
        SizedBox(
          width: 50,
          child: TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w300,
              color: RColors.sand900,
              fontFeatures: [FontFeature('tnum')]),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w300, color: RColors.sand400),
              isDense: true, contentPadding: EdgeInsets.zero),
          ),
        ),
        Text(' $unit', style: RText.small),
      ]),
    ]),
  );

  Widget _buildRecordButton() {
    final canRecord = _parsedTemp != null;
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
            style: RText.body.copyWith(fontWeight: FontWeight.w600, color: RColors.sage700, fontSize: 14)),
        ]),
      );
    }
    return GestureDetector(
      onTap: canRecord ? _record : () => _tempFocus.requestFocus(),
      child: AnimatedContainer(
        duration: RMotion.duration,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: canRecord ? RColors.teal700 : RColors.sand100,
          borderRadius: RRadius.pillBR,
          boxShadow: canRecord ? RShadow.shadow3 : const []),
        child: Center(child: Text('Record reading',
          style: RText.body.copyWith(
            fontWeight: FontWeight.w600,
            color: canRecord ? RColors.surface : RColors.sand500,
            fontSize: 14))),
      ),
    );
  }

  Widget _buildHistory(List<VitalRecord> vitals) {
    return Container(
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        boxShadow: RShadow.shadow1),
      child: Column(children: [
        ...vitals.take(10).toList().asMap().entries.map((e) {
          final i = e.key;
          final v = e.value;
          final isLast = i == vitals.take(10).length - 1;
          final color = v.isHighFever ? RColors.clay700
              : v.isFever ? RColors.clay500
              : v.isLowTemp ? RColors.sky500
              : RColors.sage500;
          final now = DateTime.now();
          final diff = now.difference(v.recordedAt);
          final timeLabel = diff.inMinutes < 60
              ? '${diff.inMinutes}m ago'
              : diff.inHours < 24
                  ? '${diff.inHours}h ago'
                  : DateFormat('d MMM · HH:mm').format(v.recordedAt);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: isLast ? null : const BoxDecoration(
              border: Border(bottom: BorderSide(color: RColors.sand200, width: 0.5))),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Row(children: [
                Text('${v.temperatureCelsius.toStringAsFixed(1)} °C',
                  style: RText.body.copyWith(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
                if (v.pulse != null) ...[
                  const SizedBox(width: 10),
                  Text('${v.pulse} bpm', style: RText.small),
                ],
                if (v.oxygenSaturation != null) ...[
                  const SizedBox(width: 8),
                  Text('${v.oxygenSaturation}% O₂', style: RText.small),
                ],
              ])),
              Text(timeLabel, style: RText.small.copyWith(fontSize: 10)),
            ]),
          );
        }),
      ]),
    );
  }
}
