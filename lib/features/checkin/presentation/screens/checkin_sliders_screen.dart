import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';

class _Symptom {
  final String key, label, arabicLabel, emoji;
  final String? warningText;
  final bool isMoodInverted;
  double value;

  _Symptom({
    required this.key, required this.label,
    required this.arabicLabel, required this.emoji,
    this.warningText, this.isMoodInverted = false,
    this.value = 0,
  });
}

class CheckInSlidersScreen extends StatefulWidget {
  const CheckInSlidersScreen({super.key});
  @override
  State<CheckInSlidersScreen> createState() => _CheckInSlidersState();
}

class _CheckInSlidersState extends State<CheckInSlidersScreen> {
  final _noteController = TextEditingController();
  final _symptoms = [
    _Symptom(key: 'fatigue', label: 'Fatigue', arabicLabel: 'إرهاق',
        emoji: '🌙', value: 7),
    _Symptom(key: 'pain', label: 'Pain', arabicLabel: 'ألم',
        emoji: '⚡', value: 3),
    _Symptom(key: 'nausea', label: 'Nausea', arabicLabel: 'غثيان',
        emoji: '🌊', value: 5),
    _Symptom(key: 'fever', label: 'Fever / Temp', arabicLabel: 'حمى / حرارة',
        emoji: '🌡️', value: 0,
        warningText: '⚠ Fever above 38°C — call your care team now, day or night.'),
    _Symptom(key: 'mood', label: 'Mood', arabicLabel: 'مزاج',
        emoji: '💜', value: 4, isMoodInverted: true),
  ];

  Color _sevColor(double v, bool isMoodInverted) {
    final iv = isMoodInverted ? (10 - v) : v;
    if (v == 0) return AppColors.primaryLight;
    if (iv <= 3) return AppColors.teal;
    if (iv <= 6) return AppColors.peach;
    return AppColors.rose;
  }

  String _sevLabel(double v, bool isMoodInverted) {
    final iv = isMoodInverted ? (10 - v) : v;
    if (v == 0) return 'None';
    if (iv <= 3) return 'Mild (1–3)';
    if (iv <= 6) return 'Moderate (4–6)';
    return 'Severe (7–10)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Row(children: [
                          Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                            color: AppColors.text2.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text('Back', style: AppText.caption.copyWith(
                            color: AppColors.text2)),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      Text('Nadir window · Day 8',
                        style: AppText.caption.copyWith(
                          color: AppColors.peach, fontWeight: FontWeight.w600,
                          fontSize: 11, letterSpacing: 0.05)),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: AppText.displayTitle.copyWith(fontSize: 20),
                          children: const [
                            TextSpan(text: 'Rate your\n'),
                            TextSpan(text: 'symptoms today',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('Tap or drag · 0 = none · 10 = severe',
                        style: AppText.bodySecondary),
                      const SizedBox(height: 16),
                      ..._symptoms.map(_buildSymptomCard),
                      const SizedBox(height: 14),
                      Text('ANYTHING TO ADD?', style: AppText.label),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        style: AppText.body,
                        decoration: InputDecoration(
                          hintText: 'Any symptom, feeling, or question for your doctor… (optional)',
                          hintStyle: AppText.body.copyWith(color: AppColors.text3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Summary for your doctor',
                        style: AppText.caption.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/checkin/success'),
                        child: const Text('Save check-in'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomCard(_Symptom s) {
    final color = _sevColor(s.value, s.isMoodInverted);
    final sevLabel = _sevLabel(s.value, s.isMoodInverted);
    final showWarning = s.warningText != null && s.value >= 4;
    final showInterference = s.value >= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: s.value > 0
              ? color.withOpacity(0.3)
              : AppColors.border,
          width: s.value > 0 ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: s.value > 0
                      ? color.withOpacity(0.12)
                      : AppColors.primaryLight,
                  borderRadius: AppRadius.smBR,
                ),
                child: Center(child: Text(s.emoji,
                  style: const TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.label, style: AppText.bodySemibold),
                    Text(s.arabicLabel,
                      style: AppText.body.copyWith(
                        fontFamily: 'Almarai', fontSize: 12,
                        color: AppColors.text3)),
                  ],
                ),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: s.value > 0
                      ? color.withOpacity(0.12)
                      : AppColors.primaryLight,
                  borderRadius: AppRadius.smBR,
                ),
                child: Center(
                  child: Text('${s.value.toInt()}',
                    style: AppText.bodySemibold.copyWith(
                      color: s.value > 0 ? color : AppColors.text3,
                      fontSize: 15)),
                ),
              ),
            ],
          ),
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
              value: s.value,
              min: 0, max: 10, divisions: 10,
              onChanged: (v) => setState(() => s.value = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: AppText.caption.copyWith(fontSize: 11)),
              Text(sevLabel,
                style: AppText.caption.copyWith(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              Text('10', style: AppText.caption.copyWith(fontSize: 11)),
            ],
          ),
          if (showWarning) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.roseLight,
                borderRadius: AppRadius.smBR,
                border: Border.all(color: AppColors.rose.withOpacity(0.3), width: 0.5),
              ),
              child: Text(s.warningText!,
                style: AppText.body.copyWith(color: AppColors.rose, fontSize: 12)),
            ),
          ],
          if (showInterference && !showWarning) ...[
            const SizedBox(height: 8),
            Text('Does this stop you doing normal things?',
              style: AppText.caption.copyWith(color: AppColors.text2, fontSize: 11)),
            const SizedBox(height: 6),
            _buildInterferenceButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildInterferenceButtons() {
    const options = ['Not at all', 'A little', 'Quite a bit', 'Very much'];
    return Wrap(
      spacing: 5, runSpacing: 5,
      children: options.map((o) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: AppRadius.fullBR,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Text(o,
          style: AppText.caption.copyWith(
            fontSize: 11, color: AppColors.text2)),
      )).toList(),
    );
  }
}
