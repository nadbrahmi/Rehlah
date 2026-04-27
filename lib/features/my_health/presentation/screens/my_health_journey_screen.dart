import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/models.dart';
import 'my_health_expect_screen.dart';

// ── Screen 6: My Health — Journey ────────────────────────────────────────────
class MyHealthJourneyScreen extends StatefulWidget {
  const MyHealthJourneyScreen({super.key});
  @override
  State<MyHealthJourneyScreen> createState() => _MyHealthJourneyState();
}

class _MyHealthJourneyState extends State<MyHealthJourneyScreen> {
  int _segIndex = 0; // 0=Journey, 1=Expect

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(top: -40, right: -20,
            child: Container(width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.09), Colors.transparent])))),
          SafeArea(
            child: Column(
              children: [
                _buildSegControl(),
                Expanded(
                  child: _segIndex == 0
                      ? _buildJourneyTab()
                      : MyHealthExpectScreen(embedded: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegControl() {
    return Column(
      children: [
        AppHeader(title: 'My |Health', subtitle: '${MockData.profile.cancerType} · Week ${MockData.profile.currentCycle}'),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Container(
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: AppRadius.fullBR,
            ),
            child: Row(
              children: ['My Journey', 'What to Expect'].asMap().entries.map((e) {
                final active = e.key == _segIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _segIndex = e.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: active ? AppColors.surface : Colors.transparent,
                        borderRadius: AppRadius.fullBR,
                        boxShadow: active ? [BoxShadow(
                          color: AppColors.primary.withOpacity(0.12),
                          blurRadius: 4)] : null,
                      ),
                      child: Center(
                        child: Text(e.value,
                          style: AppText.body.copyWith(
                            fontSize: 12,
                            color: active ? AppColors.primary : AppColors.text3,
                            fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                          )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _buildPhaseCard(),
          InsightCard(
            title: 'AI insight · Week 6',
            body: 'Fatigue often peaks around now. Your check-ins show you\'re managing well. Rest is part of treatment.',
          ),
          const SectionLabel('Your milestones'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              _milestoneRow('ms-done', 'Diagnosis confirmed',
                  'The hardest day — and the start of your fight.', 'Feb 3, 2026'),
              _milestoneRow('ms-done', 'First chemo session',
                  'The first step is always the bravest.', 'Mar 4, 2026'),
              _milestoneRow('ms-cur', 'Midpoint · Week 6',
                  'Halfway through. Your team is reviewing your labs.', null,
                  badge: '← You are here'),
              _milestoneRow('ms-fut', 'Final chemo session',
                  'Session 12. The last one.', 'Est. Jun 2026'),
              _milestoneRow('ms-fut', 'Recovery & monitoring',
                  'Regular scans. Your body begins to heal.', 'Est. Jul 2026'),
              _milestoneRow('ms-surv', 'Survivorship 🌟',
                  'Life beyond treatment. Always visible, always the goal.', null,
                  last: true),
            ]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPhaseCard() {
    final profile = MockData.profile;
    const weeks = ['W1–3', 'W4–5', 'W6 ←', 'W7–9', 'W10–12'];
    return HeroCard(
      gradientColors: const [Color(0xFFD4E8F0), Color(0xFFCCC0EC), Color(0xFFC8D8F0)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: AppRadius.fullBR,
                border: Border.all(color: Colors.white.withOpacity(0.7), width: 0.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: 5, decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.teal)),
                const SizedBox(width: 4),
                Text('Active treatment', style: AppText.caption.copyWith(
                  color: AppColors.primaryDark, fontWeight: FontWeight.w500, fontSize: 10)),
              ]),
            ),
          ]),
          const SizedBox(height: 8),
          Text('Chemotherapy', style: AppText.sectionHeading.copyWith(fontSize: 15)),
          Text('${profile.cancerType} · ${profile.stage} · Week ${profile.currentCycle} of ${profile.totalCycles}',
            style: AppText.bodySecondary),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Treatment progress', style: AppText.caption),
            Text('50%', style: AppText.caption.copyWith(
              color: AppColors.teal, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 4),
          AppProgressBar(value: 0.5, foreground: AppColors.teal),
          const SizedBox(height: 10),
          Row(children: weeks.asMap().entries.map((e) {
            final isCurrent = e.value.contains('←');
            final isDone = e.key < 2;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: e.key < 4 ? 4 : 0),
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary.withOpacity(0.22)
                      : isDone
                          ? AppColors.teal.withOpacity(0.18)
                          : Colors.white.withOpacity(0.35),
                  borderRadius: AppRadius.smBR,
                  border: isCurrent
                      ? Border.all(color: AppColors.primaryMid, width: 0.5)
                      : null,
                ),
                child: Center(child: Text(e.value,
                  style: AppText.caption.copyWith(
                    fontSize: 9, fontWeight: FontWeight.w500,
                    color: isCurrent ? AppColors.primary
                        : isDone ? AppColors.teal : AppColors.text3,
                  ))),
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _milestoneRow(String type, String name, String desc,
      String? date, {String? badge, bool last = false}) {
    Color dotBg, lineColor;
    Widget? dotIcon;
    switch (type) {
      case 'ms-done':
        dotBg = AppColors.tealLight;
        lineColor = AppColors.teal.withOpacity(0.5);
        dotIcon = Icon(Icons.check_rounded, size: 9, color: AppColors.teal);
        break;
      case 'ms-cur':
        dotBg = AppColors.primaryLight;
        lineColor = AppColors.border;
        dotIcon = Container(width: 6, height: 6, decoration: const BoxDecoration(
          shape: BoxShape.circle, color: AppColors.primary));
        break;
      case 'ms-surv':
        dotBg = AppColors.gold.withOpacity(0.09);
        lineColor = Colors.transparent;
        break;
      default:
        dotBg = Colors.white.withOpacity(0.5);
        lineColor = AppColors.border;
    }

    final nameStyle = AppText.bodySemibold.copyWith(
      fontSize: 13,
      color: type == 'ms-done' || type == 'ms-fut'
          ? (type == 'ms-done' ? AppColors.text2 : AppColors.text3)
          : type == 'ms-surv' ? AppColors.gold.withOpacity(0.55) : AppColors.text1,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: dotBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: type == 'ms-done' ? AppColors.teal
                    : type == 'ms-cur' ? AppColors.primary
                    : type == 'ms-surv' ? AppColors.gold.withOpacity(0.22)
                    : AppColors.border,
                width: 1.5),
              boxShadow: type == 'ms-cur' ? [BoxShadow(
                color: AppColors.primary.withOpacity(0.25), blurRadius: 7)] : null,
            ),
            child: dotIcon != null ? Center(child: dotIcon) : null,
          ),
          if (!last) Container(
            width: 1.5, height: 50,
            color: lineColor,
          ),
        ]),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: nameStyle),
                const SizedBox(height: 2),
                Text(desc, style: AppText.bodySecondary.copyWith(
                  color: type == 'ms-fut' || type == 'ms-surv'
                      ? AppColors.text3 : AppColors.text2)),
                if (date != null) Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(date, style: AppText.caption.copyWith(fontSize: 10)),
                ),
                if (badge != null) Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.primaryMid, width: 0.5),
                  ),
                  child: Text(badge, style: AppText.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w500,
                    fontSize: 10)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}