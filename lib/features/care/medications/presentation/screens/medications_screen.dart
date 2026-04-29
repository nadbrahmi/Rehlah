import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
import '../../../../../core/utils/models.dart';
import '../../../../../core/utils/user_session.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final _session = UserSession();
  final _meds = MockData.medications; // medication list stays from MockData
  final today = DateFormat('EEEE d MMMM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final taken = _meds.where((m) => _session.isMedTaken(m.id)).length;
    final total = _meds.length;
    final adherence = _session.adherencePct(total);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          // Header
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => context.go('/care'),
                child: Row(children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                    color: AppColors.text2.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text('Care hub', style: AppText.caption.copyWith(
                    color: AppColors.text2, fontSize: 11)),
                ]),
              ),
              const SizedBox(height: 10),
              RichText(text: TextSpan(
                style: AppText.displayTitle,
                children: const [
                  TextSpan(text: 'Medications'),
                ],
              )),
              Text(today, style: AppText.bodySecondary),
            ]),
          )),

          // Adherence hero card
          SliverToBoxAdapter(child: HeroCard(
            gradientColors: const [
              Color(0xFFC8E8D8), Color(0xFFC0D0F0), Color(0xFFC8E0D8)],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 9),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.18),
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(
                      color: AppColors.teal.withOpacity(0.28), width: 0.5)),
                  child: Text('✦ 14-day adherence',
                    style: AppText.caption.copyWith(
                      color: const Color(0xFF1A6B43),
                      fontWeight: FontWeight.w500, fontSize: 11))),
                RichText(text: TextSpan(
                  style: AppText.statNumber,
                  children: [
                    TextSpan(text: adherence > 0 ? '$adherence' : '—'),
                    if (adherence > 0) TextSpan(text: '%',
                      style: AppText.statNumber.copyWith(
                        fontSize: 14,
                        color: AppColors.text1.withOpacity(0.4))),
                  ],
                )),
                Text(
                  adherence > 0
                      ? 'of doses taken on time'
                      : 'Start tracking to see adherence',
                  style: AppText.bodySecondary.copyWith(fontSize: 11)),
                if (adherence > 0) ...[
                  const SizedBox(height: 6),
                  Text('🔥 ${_session.adherencePct(total) > 80 ? "Great" : "Keep going"} — keep it up',
                    style: AppText.bodySemibold.copyWith(
                      color: AppColors.teal, fontSize: 12)),
                ],
                const SizedBox(height: 10),
                _buildAdherenceDots(taken, total),
              ],
            ),
          )),

          // Today's count
          SliverToBoxAdapter(child: SectionLabel(
            'Today · $taken of $total taken')),

          // Med rows
          ..._meds.map((med) => SliverToBoxAdapter(
            child: _buildMedRow(med))),

          // Add medication
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Text('+ Add medication',
              style: AppText.bodySemibold.copyWith(
                color: AppColors.primary, fontSize: 13)),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _buildAdherenceDots(int taken, int total) {
    // Show 14 dots representing last 14 days
    // Last dot = today, shows taken/not based on session
    return Wrap(
      spacing: 4, runSpacing: 4,
      children: List.generate(14, (i) {
        final isToday = i == 13;
        // Today: green if all taken, orange if partial, grey if none
        Color color;
        if (isToday) {
          if (taken == total && total > 0) {
            color = AppColors.teal;
          } else if (taken > 0) {
            color = AppColors.peach;
          } else {
            color = AppColors.primary.withOpacity(0.13);
          }
        } else {
          // Past days — simulate some adherence data
          final pastTaken = i > 10 || i.isEven;
          color = pastTaken
              ? AppColors.teal
              : AppColors.primary.withOpacity(0.10);
        }
        return Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color, shape: BoxShape.circle,
            boxShadow: isToday && taken == total && total > 0 ? [
              BoxShadow(color: AppColors.teal.withOpacity(0.5), blurRadius: 5)
            ] : null),
        );
      }),
    );
  }

  Widget _buildMedRow(Medication med) {
    final isTaken = _session.isMedTaken(med.id);
    final takenAt = _session.medTakenAt(med.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: isTaken
              ? AppColors.teal.withOpacity(0.2)
              : AppColors.border,
          width: isTaken ? 1 : 0.5)),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isTaken ? AppColors.tealLight : AppColors.peachLight,
            borderRadius: AppRadius.smBR),
          child: Center(child: Text(med.emoji,
            style: const TextStyle(fontSize: 17)))),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(med.name, style: AppText.bodySemibold),
            Text('${med.dose} · ${med.frequency}',
              style: AppText.caption.copyWith(fontSize: 10)),
            if (isTaken && takenAt != null)
              Text('Taken at $takenAt ✓',
                style: AppText.bodySecondary.copyWith(
                  color: AppColors.teal, fontSize: 11))
            else
              Text('Not yet taken today',
                style: AppText.bodySecondary.copyWith(fontSize: 11)),
          ],
        )),
        GestureDetector(
          onTap: isTaken ? null : () {
            setState(() => _session.markMedTaken(med.id));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isTaken ? AppColors.tealLight : AppColors.peachLight,
              borderRadius: AppRadius.fullBR,
              border: Border.all(
                color: isTaken
                    ? AppColors.teal.withOpacity(0.2)
                    : AppColors.peach.withOpacity(0.2),
                width: 0.5)),
            child: Text(
              isTaken ? 'Taken ✓' : 'Mark taken',
              style: AppText.caption.copyWith(
                fontWeight: FontWeight.w500, fontSize: 11,
                color: isTaken
                    ? const Color(0xFF1A6B43)
                    : const Color(0xFF924A10))),
          ),
        ),
      ]),
    );
  }
}
