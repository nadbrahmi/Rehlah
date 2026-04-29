import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

class MyHealthExpectScreen extends StatelessWidget {
  final bool embedded;
  const MyHealthExpectScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final phase = session.currentPhase;
    final isNadir = session.isNadirWindow;
    final isNadirApproaching = session.isNadirApproaching;
    final maxDay = session.protocol == BreastProtocol.cmf ? 28 : 21;

    final content = SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Hero card
        HeroCard(
          gradientColors: const [
            Color(0xFFCCC0EC), Color(0xFFD4E8F0), Color(0xFFCCC0EC)],
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            HeroPill('${session.protocol.name} · Cycle ${session.currentCycle} of ${session.totalCycles}'),
            Text(
              '${session.cancerType} · Day ${session.dayInCycle} of $maxDay',
              style: const TextStyle(fontFamily: 'Inter',
                fontSize: 13, fontWeight: FontWeight.w500,
                color: AppColors.text1)),
            const SizedBox(height: 10),
            Text('Where you are in your cycle',
              style: AppText.caption.copyWith(fontSize: 11)),
            const SizedBox(height: 6),
            _buildCycleDots(session, maxDay),
            const SizedBox(height: 8),
            // Status pill
            if (isNadir)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.peachLight,
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(color: AppColors.peach, width: 0.5)),
                child: Text(
                  '⚠ Nadir window · Days active · Immune system at lowest',
                  style: AppText.caption.copyWith(
                    color: AppColors.peach, fontWeight: FontWeight.w500,
                    fontSize: 10)))
            else if (isNadirApproaching)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.10),
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3), width: 0.5)),
                child: Text(
                  '⚡ Nadir window approaching · Monitor temperature',
                  style: AppText.caption.copyWith(
                    color: AppColors.gold, fontWeight: FontWeight.w500,
                    fontSize: 10)))
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.10),
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: AppColors.teal.withOpacity(0.25), width: 0.5)),
                child: Text(
                  '✓ ${phase.name}',
                  style: AppText.caption.copyWith(
                    color: AppColors.teal, fontWeight: FontWeight.w500,
                    fontSize: 10))),
          ]),
        ),
        const SectionLabel('Learn about your phase'),
        _buildEduCards(session),
        const SectionLabel('What to expect this phase'),
        // Dynamic symptoms from protocol
        ...phase.primarySymptoms.take(4).map((s) =>
          _buildExpectCard(s.emoji, s.label, s.tip ?? phase.phaseNote)),
        const SectionLabel('📞  When to contact your care team'),
        // Dynamic urgent symptoms
        ...phase.watchSymptoms.where((s) => s.isUrgent).map((s) =>
          _buildWhenToCall(s.label, s.urgentMessage ?? 'Contact your care team.')),
        // Always show fever if not already listed
        if (!phase.watchSymptoms.any((s) => s.key == 'fever'))
          _buildWhenToCall('Fever above 38°C',
              'Do not wait — call immediately, day or night.'),
        _buildWhenToCall('Sudden severe pain',
            'Any pain that is new, sharp, or does not pass.'),
        _buildWhenToCall('Difficulty breathing',
            'Shortness of breath or chest tightness at rest.'),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
          child: Text(
            'General information only — not a substitute for medical advice. '
            'Always contact your care team with any concern.',
            style: AppText.caption.copyWith(
              fontSize: 12, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center),
        ),
      ]),
    );

    if (embedded) return content;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: content));
  }

  Widget _buildCycleDots(UserSession session, int maxDay) {
    final day = session.dayInCycle;
    final phase = session.currentPhase;

    return SizedBox(
      height: 14,
      child: Row(children: List.generate(maxDay, (i) {
        final d = i + 1;
        final dayPhase = ProtocolResolver.resolve(
          session.protocol, d, isTaxolPhase: session.isTaxolPhase);
        final isCurrent = d == day;
        final isNadirDay = dayPhase.isNadir;
        final isDone = d < day;

        Color color;
        double size = 8;
        if (isCurrent) {
          color = AppColors.primary;
          size = 12;
        } else if (isNadirDay) {
          color = AppColors.peach;
        } else if (isDone) {
          color = AppColors.teal;
        } else {
          color = AppColors.primary.withOpacity(0.13);
        }

        return Container(
          margin: const EdgeInsets.only(right: 2),
          width: size, height: size,
          decoration: BoxDecoration(
            color: color, shape: BoxShape.circle,
            boxShadow: isCurrent ? [BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 4, spreadRadius: 1)] : null),
        );
      })),
    );
  }

  Widget _buildEduCards(UserSession session) {
    final protocol = session.protocol;
    final phase = session.currentPhase;

    final cards = [
      ('🧪', '${protocol.name} basics',
          'What happens during ${phase.name.toLowerCase()}',
          AppColors.primaryLight),
      ('😴', 'Side effects',
          'Managing ${phase.primarySymptoms.isNotEmpty ? phase.primarySymptoms.first.label.toLowerCase() : "symptoms"}',
          AppColors.tealLight),
      ('🍽️', 'Nutrition',
          'Eating well during treatment',
          AppColors.peachLight),
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
              border: Border.all(color: AppColors.border, width: 0.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(height: 48,
                decoration: BoxDecoration(
                  color: c.$4,
                  borderRadius: const BorderRadius.only(
                    topLeft: AppRadius.md, topRight: AppRadius.md)),
                child: Center(child: Text(c.$1,
                  style: const TextStyle(fontSize: 22)))),
              Padding(padding: const EdgeInsets.all(9),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.$2, style: AppText.bodySemibold.copyWith(
                    fontSize: 11, color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(c.$3, style: AppText.caption.copyWith(
                    fontSize: 10, height: 1.3)),
                ])),
            ]),
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
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.bodySemibold),
          const SizedBox(height: 3),
          Text(body, style: AppText.bodySecondary),
        ])),
      ]),
    );
  }

  Widget _buildWhenToCall(String title, String body) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 7, height: 7, margin: const EdgeInsets.only(top: 5),
          decoration: const BoxDecoration(
            color: AppColors.peach, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.bodySemibold),
          const SizedBox(height: 2),
          Text(body, style: AppText.bodySecondary),
        ])),
      ]),
    );
  }
}
