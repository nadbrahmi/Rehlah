// ── Screen 2: Check-in Emoji ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/models.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  MoodLevel _mood = MoodLevel.okay;
  final Set<String> _selectedSymptoms = {'Fatigue', 'Nausea'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -50, left: -25,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.10), Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
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
                            child: Row(
                              children: [
                                Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 15, color: AppColors.text2.withOpacity(0.4)),
                                const SizedBox(width: 4),
                                Text('Back', style: AppText.caption.copyWith(
                                  color: AppColors.text2, fontSize: 11)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          RichText(
                            text: TextSpan(
                              style: AppText.displayTitle.copyWith(fontSize: 20),
                              children: const [
                                TextSpan(text: 'How are you\n'),
                                TextSpan(text: 'feeling today?',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('No right answers. Just how you are.',
                            style: AppText.bodySecondary),
                          const SizedBox(height: 16),
                          Text('OVERALL MOOD', style: AppText.label),
                          const SizedBox(height: 8),
                          _buildMoodRow(),
                          const SizedBox(height: 14),
                          Text('WHAT ARE YOU EXPERIENCING?', style: AppText.label),
                          const SizedBox(height: 8),
                          _buildSymptomChips(),
                          EncouragementCard(
                            text: 'Your check-ins help your care team understand what you need between visits.',
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/checkin/sliders'),
                            child: const Text('Rate specific symptoms →'),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => context.go('/checkin/success'),
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.fullBR,
                                  side: const BorderSide(color: AppColors.border, width: 0.5),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Save check-in', style: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodRow() {
    return Row(
      children: MoodLevel.values.map((m) {
        final selected = m == _mood;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _mood = m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: m != MoodLevel.great ? 4 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryLight : AppColors.surface,
                borderRadius: AppRadius.mdBR,
                border: Border.all(
                  color: selected ? AppColors.primaryMid : AppColors.border,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Text(m.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(m.label,
                    style: AppText.caption.copyWith(
                      fontSize: 10, fontWeight: FontWeight.w500,
                      color: selected ? AppColors.primary : AppColors.text3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSymptomChips() {
    return Wrap(
      spacing: 5, runSpacing: 5,
      children: MockData.symptoms.map((s) {
        final sel = _selectedSymptoms.contains(s);
        return GestureDetector(
          onTap: () => setState(() {
            if (sel) _selectedSymptoms.remove(s);
            else _selectedSymptoms.add(s);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: sel ? AppColors.primaryLight : AppColors.surface,
              borderRadius: AppRadius.fullBR,
              border: Border.all(
                color: sel ? AppColors.primaryMid : AppColors.border,
                width: 0.5,
              ),
            ),
            child: Text(s,
              style: AppText.body.copyWith(
                fontSize: 12,
                color: sel ? AppColors.primary : AppColors.text2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
