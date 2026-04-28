import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

// ── Severity helpers ──────────────────────────────────────────────────────────
class _Sev {
  static Color color(double v, {bool invert = false}) {
    final iv = invert ? (10 - v) : v;
    if (v == 0) return const Color(0xFFE0D8F5);
    if (iv <= 3) return AppColors.teal;
    if (iv <= 6) return AppColors.peach;
    return AppColors.rose;
  }

  static Color bgColor(double v, {bool invert = false}) {
    final iv = invert ? (10 - v) : v;
    if (v == 0) return const Color(0xFFF5F5F5);
    if (iv <= 3) return AppColors.teal.withOpacity(0.10);
    if (iv <= 6) return AppColors.peach.withOpacity(0.10);
    return AppColors.rose.withOpacity(0.10);
  }

  static Color borderColor(double v, {bool invert = false}) {
    final iv = invert ? (10 - v) : v;
    if (v == 0) return const Color(0x12000000);
    if (iv <= 3) return AppColors.teal.withOpacity(0.30);
    if (iv <= 6) return AppColors.peach.withOpacity(0.30);
    return AppColors.rose.withOpacity(0.28);
  }

  static Color textColor(double v, {bool invert = false}) {
    final iv = invert ? (10 - v) : v;
    if (v == 0) return AppColors.text3;
    if (iv <= 3) return const Color(0xFF1A6B43);
    if (iv <= 6) return const Color(0xFF924A10);
    return AppColors.rose;
  }

  static String label(double v, {bool invert = false}) {
    final iv = invert ? (10 - v) : v;
    if (v == 0) return '—';
    if (iv <= 3) return 'Mild';
    if (iv <= 6) return 'Moderate';
    return 'Severe';
  }

  // Phase pill color scheme
  static Map<String, Color> phaseColors(bool isNadir, bool isRecovery) {
    if (isNadir) return {
      'bg': AppColors.peach.withOpacity(0.10),
      'border': AppColors.peach.withOpacity(0.35),
      'text': const Color(0xFF924A10),
      'dot': AppColors.peach,
      'ctx_bg': AppColors.peach.withOpacity(0.06),
      'ctx_border': AppColors.peach.withOpacity(0.25),
    };
    if (isRecovery) return {
      'bg': AppColors.teal.withOpacity(0.10),
      'border': AppColors.teal.withOpacity(0.28),
      'text': const Color(0xFF1A6B43),
      'dot': AppColors.teal,
      'ctx_bg': AppColors.teal.withOpacity(0.05),
      'ctx_border': AppColors.teal.withOpacity(0.18),
    };
    return {
      'bg': AppColors.primaryLight,
      'border': AppColors.primaryMid,
      'text': AppColors.primaryDark,
      'dot': AppColors.primary,
      'ctx_bg': AppColors.primary.withOpacity(0.05),
      'ctx_border': AppColors.primary.withOpacity(0.15),
    };
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────
class CheckInSlidersScreen extends StatefulWidget {
  const CheckInSlidersScreen({super.key});
  @override
  State<CheckInSlidersScreen> createState() => _CheckInSlidersState();
}

class _CheckInSlidersState extends State<CheckInSlidersScreen> {
  final _noteController = TextEditingController();
  final _session = UserSession();
  late ChemoPhase _phase;
  late Map<String, double> _scores;
  final Map<String, String> _interference = {};

  bool get _isRecovery =>
      _phase.name.toLowerCase().contains('recovery');

  @override
  void initState() {
    super.initState();
    _phase = _session.currentPhase;
    final all = _allSymptoms;
    _scores = {for (final s in all) s.key: 0.0};
    _session.symptomScores.forEach((k, v) {
      if (_scores.containsKey(k)) _scores[k] = v;
    });
  }

  @override
  void dispose() { _noteController.dispose(); super.dispose(); }

  // Urgent first, then primary, then watch-only
  List<ProtocolSymptom> get _allSymptoms {
    final seen = <String>{};
    final urgent = <ProtocolSymptom>[];
    final primary = <ProtocolSymptom>[];
    final watchOnly = <ProtocolSymptom>[];
    for (final s in [..._phase.primarySymptoms, ..._phase.watchSymptoms]) {
      if (seen.contains(s.key)) continue;
      if (s.isUrgent) { seen.add(s.key); urgent.add(s); }
    }
    for (final s in _phase.primarySymptoms) {
      if (seen.add(s.key)) primary.add(s);
    }
    for (final s in _phase.watchSymptoms) {
      if (seen.add(s.key)) watchOnly.add(s);
    }
    return [...urgent, ...primary, ...watchOnly];
  }

  // Symptoms with score > 0
  List<MapEntry<String, double>> get _activeSeverity =>
      _scores.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  ProtocolSymptom? _symptomByKey(String key) {
    try {
      return _allSymptoms.firstWhere((s) => s.key == key);
    } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _Sev.phaseColors(_session.isNadirWindow, _isRecovery);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back
              GestureDetector(
                onTap: () => context.go('/checkin'),
                child: Row(children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                    color: AppColors.text2.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text('Back', style: AppText.caption.copyWith(
                    color: AppColors.text2)),
                ]),
              ),
              const SizedBox(height: 14),

              // Phase pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: colors['bg'],
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(color: colors['border']!, width: 0.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: colors['dot'])),
                  const SizedBox(width: 6),
                  Text(
                    _session.isNadirWindow
                        ? '⚠ ${_session.protocol.name} · Nadir · Day ${_session.dayInCycle}'
                        : '${_session.protocol.name} · ${_phase.name} · Day ${_session.dayInCycle}',
                    style: AppText.caption.copyWith(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: colors['text'])),
                ]),
              ),
              const SizedBox(height: 12),

              // Title — changes by phase
              RichText(text: TextSpan(
                style: AppText.displayTitle.copyWith(fontSize: 20),
                children: [
                  TextSpan(text: _isRecovery
                      ? 'How are you\n'
                      : 'Rate your\n'),
                  TextSpan(
                    text: _isRecovery ? 'recovering?' : 'symptoms',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              )),
              const SizedBox(height: 5),
              Text('Drag · 0 = none · 10 = severe',
                style: AppText.bodySecondary),
              const SizedBox(height: 12),

              // Phase context card — color coded
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors['ctx_bg'],
                  borderRadius: AppRadius.mdBR,
                  border: Border.all(color: colors['ctx_border']!, width: 0.5)),
                child: Text(_phase.phaseNote,
                  style: AppText.body.copyWith(
                    fontSize: 12, height: 1.6,
                    color: colors['text'])),
              ),
              const SizedBox(height: 14),

              // Legend
              Row(children: [
                _legendDot(AppColors.teal, 'Mild 1–3'),
                const SizedBox(width: 12),
                _legendDot(AppColors.peach, 'Moderate 4–6'),
                const SizedBox(width: 12),
                _legendDot(AppColors.rose, 'Severe 7–10'),
              ]),
              const SizedBox(height: 16),

              // Symptom cards
              ..._allSymptoms.map((s) => _buildCard(s)),

              // Summary card
              if (_activeSeverity.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildSummaryCard(),
              ],

              const SizedBox(height: 14),
              Text('ANYTHING TO ADD?', style: AppText.label),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: AppText.body,
                decoration: InputDecoration(
                  hintText: 'Any symptom, feeling, or question for your doctor…',
                  hintStyle: AppText.body.copyWith(color: AppColors.text3),
                ),
              ),
              const SizedBox(height: 16),

              // Save button
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.fullBR,
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: const Center(child: Text('Save check-in',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                      fontWeight: FontWeight.w500, color: Colors.white))),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.border, width: 0.5)),
                  child: const Center(child: Text('Save quickly',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text2))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(width: 7, height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: AppText.caption.copyWith(fontSize: 10)),
    ]);
  }

  Widget _buildCard(ProtocolSymptom s) {
    final v = _scores[s.key] ?? 0.0;
    // Inverted symptoms: high score = better (mood etc.)
    final invert = s.isInverted;
    // Calculate severity ONCE using effective value — used everywhere in this card
    final effectiveV = invert ? (v == 0 ? 0.0 : 10 - v) : v;
    final color = effectiveV == 0
        ? const Color(0xFFE0D8F5)
        : effectiveV <= 3
            ? AppColors.teal
            : effectiveV <= 6
                ? AppColors.peach
                : AppColors.rose;
    final bgCol = effectiveV == 0
        ? const Color(0xFFF5F5F5)
        : effectiveV <= 3
            ? AppColors.teal.withOpacity(0.10)
            : effectiveV <= 6
                ? AppColors.peach.withOpacity(0.10)
                : AppColors.rose.withOpacity(0.10);
    final borderCol = effectiveV == 0
        ? const Color(0x12000000)
        : effectiveV <= 3
            ? AppColors.teal.withOpacity(0.30)
            : effectiveV <= 6
                ? AppColors.peach.withOpacity(0.30)
                : AppColors.rose.withOpacity(0.28);
    final textCol = effectiveV == 0
        ? AppColors.text3
        : effectiveV <= 3
            ? const Color(0xFF1A6B43)
            : effectiveV <= 6
                ? const Color(0xFF924A10)
                : AppColors.rose;
    final sevLabel = effectiveV == 0
        ? '—'
        : effectiveV <= 3 ? 'Mild'
        : effectiveV <= 6 ? 'Moderate'
        : 'Severe';

    final showWarning = s.isUrgent && v >= s.urgentThreshold;
    final showInterference = v >= 3 && !showWarning;
    final isActive = v > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBR,
        border: Border.all(
          color: showWarning
              ? AppColors.peach.withOpacity(0.4)
              : isActive
                  ? color.withOpacity(0.22)
                  : AppColors.border,
          width: showWarning ? 1.5 : 0.5),
        boxShadow: isActive ? [BoxShadow(
          color: color.withOpacity(0.06),
          blurRadius: 10, offset: const Offset(0, 2))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nadir tag
          if (s.isUrgent && _session.isNadirWindow) ...[
            Text('MONITOR CLOSELY',
              style: AppText.label.copyWith(
                color: AppColors.peach, fontSize: 10,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
          ],

          // Top row: icon + label + score badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? color.withOpacity(0.12) : AppColors.primaryLight,
                    borderRadius: AppRadius.smBR),
                  child: Center(child: Text(s.emoji,
                    style: const TextStyle(fontSize: 15)))),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(s.label, style: AppText.bodySemibold.copyWith(
                      fontSize: 14, color: AppColors.text1)),
                    if (s.isUrgent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.peachLight,
                          borderRadius: AppRadius.fullBR),
                        child: Text('monitor',
                          style: AppText.caption.copyWith(
                            fontSize: 9, color: AppColors.peach,
                            fontWeight: FontWeight.w700))),
                    ],
                  ]),
                  Text(s.arabicLabel,
                    style: AppText.caption.copyWith(
                      fontSize: 11, color: AppColors.text3)),
                ]),
              ]),
              // Score badge
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: bgCol,
                  borderRadius: AppRadius.smBR,
                  border: Border.all(color: borderCol, width: 1.5)),
                child: Center(child: Text(
                  v == 0 ? '—' : '${v.toInt()}',
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: v == 0 ? 16 : 18,
                    fontWeight: FontWeight.w400, color: textCol)))),
            ],
          ),
          const SizedBox(height: 12),

          // Severity label above slider
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: bgCol,
                      borderRadius: AppRadius.fullBR,
                      border: Border.all(color: borderCol, width: 0.5)),
                    child: Text(sevLabel,
                      style: AppText.caption.copyWith(
                        fontSize: 11, color: textCol,
                        fontWeight: FontWeight.w600))),
                ],
              ),
            ),

          // Slider with dynamic color
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: isActive ? color : AppColors.primary.withOpacity(0.15),
              inactiveTrackColor: AppColors.primary.withOpacity(0.08),
              thumbColor: isActive ? color : AppColors.primary,
              overlayColor: (isActive ? color : AppColors.primary).withOpacity(0.12),
            ),
            child: Slider(
              value: v, min: 0, max: 10, divisions: 10,
              onChanged: (val) => setState(() => _scores[s.key] = val),
            ),
          ),

          // Tick marks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (i) => Text(
              '$i',
              style: AppText.caption.copyWith(
                fontSize: i == v.toInt() && isActive ? 11 : 9,
                color: i == v.toInt() && isActive ? color : AppColors.text3,
                fontWeight: i == v.toInt() && isActive
                    ? FontWeight.w700 : FontWeight.w400))),
          ),

          // Protocol tip
          if (s.tip != null && isActive && !showWarning) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.05),
                borderRadius: AppRadius.smBR,
                border: Border.all(
                  color: AppColors.teal.withOpacity(0.18), width: 0.5)),
              child: Row(children: [
                const Text('💡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 7),
                Expanded(child: Text(s.tip!,
                  style: AppText.body.copyWith(
                    fontSize: 12, color: AppColors.teal))),
              ]),
            ),
          ],

          // Urgent warning
          if (showWarning) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.peachLight,
                borderRadius: AppRadius.smBR,
                border: Border.all(
                  color: AppColors.peach.withOpacity(0.3), width: 0.5)),
              child: Row(children: [
                const Text('⚠', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  s.urgentMessage ?? 'Contact your care team.',
                  style: AppText.body.copyWith(
                    color: AppColors.peach, fontSize: 12,
                    fontWeight: FontWeight.w400))),
              ]),
            ),
          ],

          // Interference question — show when score ≥ 3 and warning is NOT showing
          if (showInterference && !showWarning && s.interferenceQuestion != null) ...[
            const SizedBox(height: 12),
            Divider(color: AppColors.border, height: 1, thickness: 0.5),
            const SizedBox(height: 10),
            Text(
              s.interferenceQuestion ?? 'Does this stop you doing normal things?',
              style: AppText.body.copyWith(
                fontSize: 12, color: AppColors.text2,
                fontWeight: FontWeight.w300, height: 1.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5, runSpacing: 5,
              children: ['Not at all', 'A little', 'Quite a bit', 'Very much']
                  .map((o) {
                final sel = _interference[s.key] == o;
                return GestureDetector(
                  onTap: () => setState(() => _interference[s.key] = o),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryLight : AppColors.surface,
                      borderRadius: AppRadius.fullBR,
                      border: Border.all(
                        color: sel ? AppColors.primaryMid : AppColors.border,
                        width: 0.5)),
                    child: Text(o,
                      style: AppText.caption.copyWith(
                        fontSize: 11,
                        color: sel ? AppColors.primary : AppColors.text2,
                        fontWeight: sel ? FontWeight.w500 : FontWeight.w400))),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Live summary card
  Widget _buildSummaryCard() {
    final active = _activeSeverity;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15), width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUMMARY FOR YOUR DOCTOR',
            style: AppText.label.copyWith(fontSize: 10)),
          const SizedBox(height: 10),
          ...active.map((e) {
            final s = _symptomByKey(e.key);
            final isInvert = s?.isInverted ?? false;
            final effV = isInvert ? (e.value == 0 ? 0.0 : 10 - e.value) : e.value;
            final color = effV == 0
                ? AppColors.text3
                : effV <= 3 ? AppColors.teal
                : effV <= 6 ? AppColors.peach
                : AppColors.rose;
            final label = effV == 0 ? 'None'
                : effV <= 3 ? 'Mild'
                : effV <= 6 ? 'Moderate'
                : 'Severe';
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  '${s?.label ?? e.key} — $label (${e.value.toInt()}/10)',
                  style: AppText.body.copyWith(fontSize: 13))),
              ]),
            );
          }),
          Divider(
            color: AppColors.border, height: 16, thickness: 0.5),
          Row(children: [
            const Icon(Icons.check_circle_outline_rounded,
              size: 14, color: AppColors.teal),
            const SizedBox(width: 6),
            Expanded(child: Text(
              'This will be included in your pre-visit report for Dr. Sarah Chen.',
              style: AppText.caption.copyWith(
                color: AppColors.teal, fontSize: 11, height: 1.5))),
          ]),
        ],
      ),
    );
  }

  void _save() {
    _session.symptomScores = Map<String, double>.from(_scores);
    _session.interferenceAnswers = Map<String, String>.from(_interference);
    _session.checkInNote = _noteController.text.trim();
    _session.lastCheckIn = DateTime.now();
    context.go('/checkin/success');
  }
}
