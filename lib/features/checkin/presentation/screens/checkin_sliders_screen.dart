import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

class CheckInSlidersScreen extends StatefulWidget {
  const CheckInSlidersScreen({super.key});
  @override
  State<CheckInSlidersScreen> createState() => _CheckInSlidersState();
}

class _CheckInSlidersState extends State<CheckInSlidersScreen> {
  final _noteController = TextEditingController();
  final _session = UserSession();
  late ChemoPhase _phase;
  // map key → slider value
  late Map<String, double> _scores;
  // map key → interference answer
  final Map<String, String> _interference = {};

  @override
  void initState() {
    super.initState();
    _phase = _session.currentPhase;
    // Build score map from all phase symptoms (primary + watch, deduplicated)
    final all = <String, ProtocolSymptom>{};
    for (final s in _phase.primarySymptoms) all[s.key] = s;
    for (final s in _phase.watchSymptoms) all[s.key] = s;
    _scores = {for (final k in all.keys) k: 0.0};
    // Pre-fill from session if already saved
    _session.symptomScores.forEach((k, v) {
      if (_scores.containsKey(k)) _scores[k] = v;
    });
  }

  @override
  void dispose() { _noteController.dispose(); super.dispose(); }

  // All symptoms in order: urgent/safety first, then primary, then watch-only
  List<ProtocolSymptom> get _allSymptoms {
    final seen = <String>{};
    final urgent = <ProtocolSymptom>[];
    final primary = <ProtocolSymptom>[];
    final watchOnly = <ProtocolSymptom>[];

    // Collect urgent symptoms from both lists first
    for (final s in [..._phase.primarySymptoms, ..._phase.watchSymptoms]) {
      if (seen.contains(s.key)) continue;
      if (s.isUrgent) {
        seen.add(s.key);
        urgent.add(s);
      }
    }
    // Then non-urgent primary
    for (final s in _phase.primarySymptoms) {
      if (seen.add(s.key)) primary.add(s);
    }
    // Then watch-only non-urgent
    for (final s in _phase.watchSymptoms) {
      if (seen.add(s.key)) watchOnly.add(s);
    }

    return [...urgent, ...primary, ...watchOnly];
  }

  Color _sevColor(double v, bool isUrgent) {
    if (v == 0) return AppColors.primaryLight;
    if (v <= 3) return AppColors.teal;
    if (v <= 6) return isUrgent ? AppColors.peach : AppColors.peach;
    return AppColors.rose;
  }

  String _sevLabel(double v) {
    if (v == 0) return 'None';
    if (v <= 3) return 'Mild';
    if (v <= 6) return 'Moderate';
    return 'Severe';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              // Phase context
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: _session.isNadirWindow
                      ? AppColors.peachLight
                      : AppColors.primaryLight,
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: _session.isNadirWindow
                        ? AppColors.peach.withOpacity(0.3)
                        : AppColors.primaryMid,
                    width: 0.5)),
                child: Text(
                  '${_session.protocol.name} · ${_phase.description}',
                  style: AppText.caption.copyWith(
                    fontSize: 11, fontWeight: FontWeight.w500,
                    color: _session.isNadirWindow
                        ? AppColors.peach
                        : AppColors.primary)),
              ),
              const SizedBox(height: 12),
              RichText(text: TextSpan(
                style: AppText.displayTitle.copyWith(fontSize: 20),
                children: const [
                  TextSpan(text: 'Rate your\n'),
                  TextSpan(text: 'symptoms',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              )),
              const SizedBox(height: 5),
              Text('Drag · 0 = none · 10 = severe',
                style: AppText.bodySecondary),
              const SizedBox(height: 16),
              ..._allSymptoms.map(_buildCard),
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
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save check-in'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ProtocolSymptom s) {
    final v = _scores[s.key] ?? 0.0;
    final color = _sevColor(v, s.isUrgent);
    final showWarning = s.isUrgent && v >= s.urgentThreshold;
    final showInterference = v >= 3 && !showWarning;
    const opts = ['Not at all', 'A little', 'Quite a bit', 'Very much'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: showWarning
              ? AppColors.peach.withOpacity(0.4)
              : (v > 0 ? color.withOpacity(0.25) : AppColors.border),
          width: showWarning ? 1.5 : 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: v > 0 ? color.withOpacity(0.12) : AppColors.primaryLight,
                borderRadius: AppRadius.smBR),
              child: Center(child: Text(s.emoji,
                style: const TextStyle(fontSize: 16)))),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(s.label, style: AppText.bodySemibold),
                  if (s.isUrgent) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.peachLight,
                        borderRadius: AppRadius.fullBR),
                      child: Text('monitor',
                        style: AppText.caption.copyWith(
                          fontSize: 9, color: AppColors.peach,
                          fontWeight: FontWeight.w600))),
                  ],
                ]),
                Text(s.arabicLabel,
                  style: AppText.body.copyWith(
                    fontSize: 12, color: AppColors.text3)),
              ],
            )),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: v > 0 ? color.withOpacity(0.12) : AppColors.primaryLight,
                borderRadius: AppRadius.smBR),
              child: Center(child: Text(
                '${v.toInt()}',
                style: AppText.bodySemibold.copyWith(
                  color: v > 0 ? color : AppColors.text3,
                  fontSize: 15)))),
          ]),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: color,
              inactiveTrackColor: AppColors.primary.withOpacity(0.1),
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
            ),
            child: Slider(
              value: v, min: 0, max: 10, divisions: 10,
              onChanged: (val) => setState(() => _scores[s.key] = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: AppText.caption.copyWith(fontSize: 11)),
              Text('${_sevLabel(v)} (${v.toInt()})',
                style: AppText.caption.copyWith(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              Text('10', style: AppText.caption.copyWith(fontSize: 11)),
            ],
          ),
          // Protocol-specific tip
          if (s.tip != null && v > 0 && v <= 6 && !showWarning) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.05),
                borderRadius: AppRadius.smBR,
                border: Border.all(
                  color: AppColors.teal.withOpacity(0.18), width: 0.5)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('💡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Expanded(child: Text(s.tip!,
                  style: AppText.body.copyWith(
                    fontSize: 12, color: AppColors.teal))),
              ]),
            ),
          ],
          // Urgent warning
          if (showWarning) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.peachLight,
                borderRadius: AppRadius.smBR,
                border: Border.all(
                  color: AppColors.peach.withOpacity(0.3), width: 0.5)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('⚠', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 7),
                Expanded(child: Text(
                  s.urgentMessage ?? 'Contact your care team.',
                  style: AppText.body.copyWith(
                    color: AppColors.peach, fontSize: 12))),
              ]),
            ),
          ],
          // Interference
          if (showInterference) ...[
            const SizedBox(height: 10),
            Text('Does this stop you doing normal things?',
              style: AppText.caption.copyWith(
                color: AppColors.text2, fontSize: 11)),
            const SizedBox(height: 7),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: opts.map((o) {
                final selected = _interference[s.key] == o;
                return GestureDetector(
                  onTap: () => setState(
                    () => _interference[s.key] = o),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 130),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryLight
                          : AppColors.surface,
                      borderRadius: AppRadius.fullBR,
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryMid
                            : AppColors.border,
                        width: 0.5)),
                    child: Text(o,
                      style: AppText.caption.copyWith(
                        fontSize: 11,
                        color: selected
                            ? AppColors.primary
                            : AppColors.text2,
                        fontWeight: selected
                            ? FontWeight.w500
                            : FontWeight.w400)),
                  ),
                );
              }).toList(),
            ),
          ],
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