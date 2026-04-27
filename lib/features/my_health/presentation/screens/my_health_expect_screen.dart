import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';

class MyHealthExpectScreen extends StatelessWidget {
  final bool embedded;
  const MyHealthExpectScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroCard(
            gradientColors: const [
              Color(0xFFCCC0EC), Color(0xFFD4E8F0), Color(0xFFCCC0EC)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeroPill('Week 6 of chemotherapy'),
                const Text('Cycle 2 · Day 7 of 21 · Breast Cancer',
                  style: TextStyle(fontFamily: 'Inter',
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: AppColors.text1)),
                const SizedBox(height: 10),
                Text('Where you are in your cycle',
                  style: AppText.caption.copyWith(fontSize: 11)),
                const SizedBox(height: 6),
                _buildCycleDots(),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.peachLight,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.peach, width: 0.5),
                  ),
                  child: Text('⚠ Nadir window approaching · Days 8–14 · Immune system at lowest',
                    style: AppText.caption.copyWith(
                      color: AppColors.peach, fontWeight: FontWeight.w500,
                      fontSize: 10)),
                ),
              ],
            ),
          ),
          const SectionLabel('Learn about your phase'),
          _buildEduCards(),
          const SectionLabel('What to expect this week'),
          _buildExpectCard('😔', 'Fatigue',
              'Peaks around days 3–7. Rest when your body asks. That is not weakness — it is wisdom.'),
          _buildExpectCard('🤢', 'Nausea',
              'Take anti-nausea medication consistently. Small frequent meals help more than large ones.'),
          _buildExpectCard('💇', 'Hair changes',
              'Expected at this stage. Temporary. Your hair will return after treatment ends.'),
          _buildExpectCard('🍃', 'Appetite changes',
              'Try small frequent meals. Anything you can tolerate is enough right now.'),
          const SectionLabel('📞  When to contact your care team'),
          _buildWhenToCall('Fever above 38°C',
              'Do not wait — call immediately, day or night.'),
          _buildWhenToCall('Sudden severe pain',
              'Any pain that is new, sharp, or does not pass.'),
          _buildWhenToCall('Difficulty breathing',
              'Shortness of breath or chest tightness at rest.'),
          _buildWhenToCall('Unusual bleeding or bruising',
              'More than expected from a small cut or bump.'),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            child: Text(
              'General information only — not a substitute for medical advice. Always contact your care team with any concern.',
              style: AppText.caption.copyWith(
                fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    if (embedded) return content;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: content),
    );
  }

  Widget _buildCycleDots() {
    return SizedBox(
      height: 14,
      child: Row(
        children: List.generate(21, (i) {
          Color color;
          double size = 8;
          if (i < 6) {
            color = AppColors.teal; // done
          } else if (i == 6) {
            color = AppColors.primary; size = 12; // current
          } else if (i >= 7 && i <= 13) {
            color = AppColors.peach; // nadir
          } else {
            color = AppColors.primary.withOpacity(0.13); // future
          }
          return Container(
            margin: const EdgeInsets.only(right: 3),
            width: size, height: size,
            decoration: BoxDecoration(
              color: color, shape: BoxShape.circle,
              boxShadow: i == 6 ? [
                BoxShadow(color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 4, spreadRadius: 1)
              ] : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEduCards() {
    final cards = [
      ('🧪', 'Chemo basics', 'What happens during each session', AppColors.primaryLight),
      ('😴', 'Side effects', 'Managing fatigue & nausea', AppColors.tealLight),
      ('🍽️', 'Nutrition', 'Eating well when appetite changes', AppColors.peachLight),
    ];
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        itemCount: cards.length,
        itemBuilder: (context, i) {
          final c = cards[i];
          return Container(
            width: 130, margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdBR,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.$4,
                    borderRadius: const BorderRadius.only(
                      topLeft: AppRadius.md, topRight: AppRadius.md)),
                  child: Center(child: Text(c.$1,
                    style: const TextStyle(fontSize: 22))),
                ),
                Padding(
                  padding: const EdgeInsets.all(9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.$2, style: AppText.bodySemibold.copyWith(
                        fontSize: 11, color: AppColors.primary)),
                      const SizedBox(height: 2),
                      Text(c.$3, style: AppText.caption.copyWith(
                        fontSize: 10, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpectCard(String emoji, String title, String body) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodySemibold),
                const SizedBox(height: 3),
                Text(body, style: AppText.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhenToCall(String title, String body) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7, height: 7, margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              color: AppColors.peach, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.bodySemibold),
                const SizedBox(height: 2),
                Text(body, style: AppText.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
