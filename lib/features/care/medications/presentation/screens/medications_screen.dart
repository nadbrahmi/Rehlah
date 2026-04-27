import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
import '../../../../../core/utils/models.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  late List<Medication> _meds;

  @override
  void initState() {
    super.initState();
    _meds = List.from(MockData.medications);
  }

  @override
  Widget build(BuildContext context) {
    final taken = _meds.where((m) => m.takenToday).length;
    final total = _meds.length;
    final adherencePct = 82;
    final today = DateFormat('EEEE d MMMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(
                  style: AppText.displayTitle,
                  children: const [
                    TextSpan(text: '', style: TextStyle(fontWeight: FontWeight.w700)),
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
                        color: AppColors.teal.withOpacity(0.28), width: 0.5),
                    ),
                    child: Text('✦ 14-day adherence',
                      style: AppText.caption.copyWith(
                        color: const Color(0xFF1A6B43),
                        fontWeight: FontWeight.w500, fontSize: 11)),
                  ),
                  RichText(
                    text: TextSpan(
                      style: AppText.statNumber,
                      children: [
                        TextSpan(text: '$adherencePct'),
                        TextSpan(text: '%',
                          style: AppText.statNumber.copyWith(
                            fontSize: 14, color: AppColors.text1.withOpacity(0.4))),
                      ],
                    ),
                  ),
                  Text('of doses taken on time',
                    style: AppText.bodySecondary.copyWith(fontSize: 11)),
                  const SizedBox(height: 6),
                  Text('🔥 14-day streak',
                    style: AppText.bodySemibold.copyWith(
                      color: AppColors.teal, fontSize: 12)),
                  const SizedBox(height: 10),
                  _buildAdherenceDots(),
                ],
              ),
            )),
            SliverToBoxAdapter(child: SectionLabel('Today · $total medications')),
            ..._meds.map((med) => SliverToBoxAdapter(
              child: _buildMedRow(med))),
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: GestureDetector(
                child: Text('+ Add medication',
                  style: AppText.bodySemibold.copyWith(
                    color: AppColors.primary, fontSize: 13)),
              ),
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdherenceDots() {
    const states = [
      true, true, true, false, true, true, true,
      true, true, true, true, true, true, 'today',
    ];
    return Wrap(
      spacing: 4, runSpacing: 4,
      children: states.map((s) {
        if (s == 'today') {
          return Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: AppColors.teal, shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: AppColors.teal.withOpacity(0.5), blurRadius: 5)],
            ),
          );
        }
        return Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: s == true
                ? AppColors.teal
                : AppColors.primary.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMedRow(Medication med) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: med.takenToday ? AppColors.tealLight : AppColors.peachLight,
              borderRadius: AppRadius.smBR,
            ),
            child: Center(child: Text(med.emoji,
              style: const TextStyle(fontSize: 17))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(med.name, style: AppText.bodySemibold),
              Text('${med.dose} · ${med.frequency}',
                style: AppText.caption.copyWith(fontSize: 10)),
              if (med.takenToday && med.takenAt != null)
                Text('Taken at ${med.takenAt} ✓',
                  style: AppText.bodySecondary.copyWith(fontSize: 11))
              else
                Text('Not yet taken today',
                  style: AppText.bodySecondary.copyWith(fontSize: 11)),
            ],
          )),
          GestureDetector(
            onTap: med.takenToday ? null : () {
              setState(() {
                final idx = _meds.indexOf(med);
                _meds[idx] = med.copyWith(
                  takenToday: true,
                  takenAt: DateFormat('h:mm a').format(DateTime.now()),
                );
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: med.takenToday ? AppColors.tealLight : AppColors.peachLight,
                borderRadius: AppRadius.fullBR,
                border: Border.all(
                  color: med.takenToday
                      ? AppColors.teal.withOpacity(0.2)
                      : AppColors.peach.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Text(
                med.takenToday ? 'Taken' : 'Mark taken',
                style: AppText.caption.copyWith(
                  fontWeight: FontWeight.w500, fontSize: 11,
                  color: med.takenToday
                      ? const Color(0xFF1A6B43)
                      : const Color(0xFF924A10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
