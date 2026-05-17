import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void initState() {
    super.initState();
    // Init default meds if none set yet
    _session.initDefaultMedications();
  }

  @override
  Widget build(BuildContext context) {
    final meds = _session.medications;
    final taken = meds.where((m) => _session.isMedTaken(m.id)).length;
    final adherence = _session.adherencePct(meds.length);

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
                  Text('Care', style: AppText.caption.copyWith(
                    color: AppColors.text2)),
                ]),
              ),
              const SizedBox(height: 10),
              RichText(text: TextSpan(style: AppText.displayTitle, children: const [
                TextSpan(text: 'My '),
                TextSpan(text: 'medications',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              ])),
              Text('Track your daily medications',
                style: AppText.bodySecondary),
            ]),
          )),

          // Hero stat
          SliverToBoxAdapter(child: HeroCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HeroPill('Today\'s progress'),
              Row(children: [
                Text('$taken', style: AppText.statNumber),
                Text(' of ${meds.length}',
                  style: AppText.statNumber.copyWith(
                    color: AppColors.text1.withOpacity(0.35), fontSize: 18)),
              ]),
              Text('doses taken today',
                style: AppText.bodySecondary),
              const SizedBox(height: 10),
              // Progress bar
              Stack(children: [
                Container(height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: AppRadius.fullBR)),
                FractionallySizedBox(
                  widthFactor: meds.isEmpty
                      ? 0 : (taken / meds.length).clamp(0.0, 1.0),
                  child: Container(height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.fullBR))),
              ]),
              const SizedBox(height: 8),
              if (adherence > 0)
                Text('14-day adherence: $adherence%',
                  style: AppText.caption.copyWith(fontSize: 11)),
            ]),
          )),

          // Tamoxifen / hormone therapy streak counter
          if (_session.hormoneTherapyMed != null)
            SliverToBoxAdapter(child: _buildTamoxifenStreakCard()),

          // Refill alert banner
          if (_session.hasRefillAlert)
            SliverToBoxAdapter(child: Container(
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.peachLight,
                borderRadius: AppRadius.mdBR,
                border: Border.all(
                  color: AppColors.peach.withOpacity(0.3), width: 0.5)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('⚠', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text('Refill needed',
                      style: AppText.bodySemibold.copyWith(
                        color: AppColors.peach, fontSize: 13)),
                  ]),
                  const SizedBox(height: 6),
                  ..._session.medsRunningLow.map((m) => Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(m.name,
                        style: AppText.bodySecondary.copyWith(fontSize: 12)),
                      const Spacer(),
                      Text(
                        _session.isMedOutOfStock(m.id)
                            ? 'Out of stock'
                            : '${_session.remainingDoses(m.id)} doses left'
                              '${_session.daysRemainingForMed(m.id) != null ? ' · ${_session.daysRemainingForMed(m.id)}d' : ''}',
                        style: AppText.caption.copyWith(
                          color: _session.isMedOutOfStock(m.id)
                              ? AppColors.rose : AppColors.peach,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                    ]),
                  )),
                ],
              ),
            )),

          // Medications list
          if (meds.isEmpty)
            SliverToBoxAdapter(child: Container(
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.mdBR),
                  child: const Center(child: Text('💊',
                    style: TextStyle(fontSize: 26)))),
                const SizedBox(height: 16),
                Text('No medications added yet',
                  style: AppText.bodySemibold.copyWith(fontSize: 15)),
                const SizedBox(height: 8),
                Text(
                  'Add your medications to track daily adherence and include them in your doctor-ready prep report.',
                  style: AppText.bodySecondary.copyWith(fontSize: 13),
                  textAlign: TextAlign.center),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showAddEditSheet(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.fullBR,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 12, offset: const Offset(0, 4))]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add_rounded,
                        size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Add first medication',
                        style: AppText.bodySemibold.copyWith(
                          color: Colors.white, fontSize: 13)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Text('You can also scan your prescription later',
                  style: AppText.caption.copyWith(
                    color: AppColors.text3, fontSize: 11)),
              ]),
            ))
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _buildMedCard(meds[i]),
              childCount: meds.length,
            )),

          // Add button
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: GestureDetector(
              onTap: () => _showAddEditSheet(null),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.mdBR,
                  border: Border.all(
                    color: AppColors.primaryMid,
                    width: 0.5,
                    style: BorderStyle.solid)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 16,
                      color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Add medication',
                      style: AppText.bodySemibold.copyWith(
                        color: AppColors.primary, fontSize: 13)),
                  ],
                ),
              ),
            ),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _buildTamoxifenStreakCard() {
    final days = _session.hormoneTherapyDays;
    final med = _session.hormoneTherapyMed!;
    final milestone = days >= 180 ? '🏆 180 days'
        : days >= 90 ? '🥈 90 days'
        : days >= 30 ? '🥉 30 days'
        : null;
    final nextMilestone = days < 30 ? 30 : days < 90 ? 90 : days < 180 ? 180 : null;
    final daysToNext = nextMilestone != null ? nextMilestone - days : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.primaryMid, width: 0.5),
        boxShadow: [BoxShadow(
          color: AppColors.primary.withOpacity(0.06),
          blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(med.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text('${med.name} · الالتزام | Streak',
            style: AppText.bodySemibold.copyWith(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.fullBR),
            child: Text('$days days 🔥',
              style: AppText.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700, fontSize: 12))),
        ]),
        const SizedBox(height: 10),
        // Progress bar toward next milestone
        if (nextMilestone != null) ...[
          Row(children: [
            Expanded(child: Stack(children: [
              Container(height: 6,
                decoration: BoxDecoration(
                  color: AppColors.background2,
                  borderRadius: AppRadius.fullBR)),
              FractionallySizedBox(
                widthFactor: (days / nextMilestone).clamp(0.0, 1.0),
                child: Container(height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.fullBR))),
            ])),
            const SizedBox(width: 10),
            Text('$daysToNext days to $nextMilestone 🎯',
              style: AppText.caption.copyWith(fontSize: 10, color: AppColors.text3)),
          ]),
          const SizedBox(height: 6),
        ],
        if (milestone != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: AppRadius.smBR),
            child: Text('$milestone milestone reached! تهانينا 🎉',
              style: AppText.caption.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w600, fontSize: 11))),
        ],
        Text(
          'تناول التاموكسيفن بانتظام يقلل خطر الانتكاس بشكل كبير — كل يوم مهم.\n'
          'Tamoxifen taken consistently reduces recurrence risk significantly. Every day counts.',
          style: AppText.caption.copyWith(
            fontSize: 11, color: AppColors.text3, height: 1.5)),
      ]),
    );
  }

  Widget _buildMedCard(Medication med) {
    final taken = _session.isMedTaken(med.id);
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: taken ? AppColors.teal.withOpacity(0.25) : AppColors.border,
          width: 0.5)),
      child: Row(children: [
        // Emoji
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: taken
                ? AppColors.tealLight : AppColors.background2,
            borderRadius: AppRadius.smBR),
          child: Center(child: Text(med.emoji,
            style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 12),

        // Info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(med.name, style: AppText.bodySemibold),
            Text('${med.dose} · ${med.frequency}',
              style: AppText.bodySecondary.copyWith(fontSize: 12)),
            if (med.notes != null && med.notes!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(med.notes!,
                style: AppText.caption.copyWith(
                  color: AppColors.text3, fontSize: 11,
                  fontStyle: FontStyle.italic)),
            ],
            if (med.totalSupply != null) ...[
              const SizedBox(height: 4),
              Builder(builder: (_) {
                final rem = _session.remainingDoses(med.id);
                final days = _session.daysRemainingForMed(med.id);
                final isLow = _session.isMedRunningLow(med.id);
                final isOut = _session.isMedOutOfStock(med.id);
                return Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOut ? AppColors.roseLight
                          : isLow ? AppColors.peachLight
                          : AppColors.tealLight,
                      borderRadius: AppRadius.fullBR),
                    child: Text(
                      isOut ? 'Out of stock'
                          : '$rem doses left'
                            '${days != null ? ' · ~${days}d' : ''}',
                      style: AppText.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isOut ? AppColors.rose
                            : isLow ? AppColors.peach
                            : AppColors.teal))),
                ]);
              }),
            ],
          ],
        )),

        const SizedBox(width: 8),

        // Actions
        Column(children: [
          // Take button
          GestureDetector(
            onTap: () {
              setState(() => _session.markMedTaken(med.id));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: taken ? AppColors.teal : AppColors.primary,
                borderRadius: AppRadius.fullBR,
                boxShadow: [BoxShadow(
                  color: (taken ? AppColors.teal : AppColors.primary)
                      .withOpacity(0.25),
                  blurRadius: 6, offset: const Offset(0, 2))]),
              child: Text(taken ? 'Taken ✓' : 'Mark taken',
                style: AppText.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500, fontSize: 11))),
          ),
          const SizedBox(height: 6),
          // Edit + delete row
          Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: () => _showAddEditSheet(med),
              child: Text('Edit',
                style: AppText.caption.copyWith(
                  color: AppColors.text3, fontSize: 10))),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmDelete(med),
              child: Icon(Icons.delete_outline_rounded,
                size: 14, color: AppColors.text3)),
          ]),
        ]),
      ]),
    );
  }

  void _confirmDelete(Medication med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Remove medication?',
          style: AppText.sectionHeading.copyWith(fontSize: 15)),
        content: Text(
          '${med.name} will be removed from your list.',
          style: AppText.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
              style: TextStyle(color: AppColors.text2))),
          TextButton(
            onPressed: () {
              _session.removeMedication(med.id);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('Remove',
              style: TextStyle(
                color: AppColors.rose,
                fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showAddEditSheet(Medication? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final doseCtrl = TextEditingController(text: existing?.dose ?? '');
    final freqCtrl = TextEditingController(text: existing?.frequency ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    String emoji = existing?.emoji ?? '💊';
    String category = existing?.category ?? 'other';
    int? totalSupply = existing?.totalSupply;
    DateTime? startDate = existing?.startDate;

    final emojis = ['💊', '🌤️', '🦴', '🩹', '🧬', '💉', '🫀', '🧪', '🌿'];
    final categories = [
      ('hormone_therapy', 'Hormone therapy'),
      ('chemo', 'Chemotherapy'),
      ('supplement', 'Supplement'),
      ('symptomatic', 'Symptomatic'),
      ('other', 'Other'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20,
              MediaQuery.of(context).viewInsets.bottom + 32),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              Text(isEdit ? 'EDIT MEDICATION' : 'ADD MEDICATION',
                style: AppText.label.copyWith(fontSize: 10)),
              const SizedBox(height: 14),

              // Emoji picker
              Text('Icon', style: AppText.bodySecondary),
              const SizedBox(height: 6),
              Wrap(spacing: 8, children: emojis.map((e) =>
                GestureDetector(
                  onTap: () => setS(() => emoji = e),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: emoji == e
                          ? AppColors.primaryLight : AppColors.background2,
                      borderRadius: AppRadius.smBR,
                      border: Border.all(
                        color: emoji == e
                            ? AppColors.primaryMid : Colors.transparent,
                        width: 1)),
                    child: Center(child: Text(e,
                      style: const TextStyle(fontSize: 20)))))).toList()),
              const SizedBox(height: 12),

              // Name
              _field('Medication name', nameCtrl, 'e.g. Tamoxifen 20mg'),
              const SizedBox(height: 8),
              _field('Dose', doseCtrl, 'e.g. 1 tablet'),
              const SizedBox(height: 8),
              _field('Frequency', freqCtrl, 'e.g. Daily · Morning'),
              const SizedBox(height: 8),
              _field('Notes (optional)', notesCtrl,
                'e.g. Take with food'),
              const SizedBox(height: 12),

              // Category
              Text('Category', style: AppText.bodySecondary),
              const SizedBox(height: 6),
              Wrap(spacing: 6, runSpacing: 6,
                children: categories.map((c) {
                  final sel = category == c.$1;
                  return GestureDetector(
                    onTap: () => setS(() => category = c.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primaryLight : AppColors.background2,
                        borderRadius: AppRadius.fullBR,
                        border: Border.all(
                          color: sel
                              ? AppColors.primaryMid : Colors.transparent,
                          width: 0.5)),
                      child: Text(c.$2, style: AppText.caption.copyWith(
                        color: sel ? AppColors.primary : AppColors.text2,
                        fontSize: 11))));
                }).toList()),

              const SizedBox(height: 12),

              // Supply tracking
              Text('Supply tracking (optional)',
                style: AppText.bodySecondary),
              const SizedBox(height: 4),
              Text('Rehlah counts down automatically each time you mark a dose taken.',
                style: AppText.caption.copyWith(
                  fontSize: 11, color: AppColors.text3)),
              const SizedBox(height: 8),
              Row(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Pack size
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pack size (doses)',
                      style: AppText.caption.copyWith(
                        fontSize: 11, color: AppColors.text3)),
                    const SizedBox(height: 4),
                    Row(children: [
                      GestureDetector(
                        onTap: () => setS(() {
                          if (totalSupply != null && totalSupply! > 1)
                            totalSupply = totalSupply! - 1;
                        }),
                        child: Container(width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.background2,
                            borderRadius: AppRadius.smBR),
                          child: const Icon(Icons.remove_rounded, size: 14))),
                      const SizedBox(width: 8),
                      Text(totalSupply != null ? '$totalSupply' : '—',
                        style: AppText.bodySemibold.copyWith(fontSize: 15)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setS(() =>
                            totalSupply = (totalSupply ?? 0) + 1),
                        child: Container(width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.background2,
                            borderRadius: AppRadius.smBR),
                          child: const Icon(Icons.add_rounded, size: 14))),
                      const SizedBox(width: 8),
                      if (totalSupply != null)
                        GestureDetector(
                          onTap: () => setS(() => totalSupply = null),
                          child: Text('Clear',
                            style: AppText.caption.copyWith(
                              color: AppColors.text3, fontSize: 10))),
                    ]),
                  ],
                )),
                const SizedBox(width: 16),
                // Start date
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Started taking',
                      style: AppText.caption.copyWith(
                        fontSize: 11, color: AppColors.text3)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 3650)),
                          lastDate: DateTime.now(),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary)),
                            child: child!),
                        );
                        if (p != null) setS(() => startDate = p);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadius.smBR,
                          border: Border.all(
                            color: AppColors.border, width: 0.5)),
                        child: Row(children: [
                          const Text('📅',
                            style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Text(
                            startDate != null
                                ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                                : 'Set date',
                            style: AppText.caption.copyWith(
                              fontSize: 11,
                              color: startDate != null
                                  ? AppColors.primary : AppColors.text3)),
                        ]),
                      ),
                    ),
                    if (startDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: GestureDetector(
                          onTap: () => setS(() => startDate = null),
                          child: Text('Clear',
                            style: AppText.caption.copyWith(
                              color: AppColors.text3, fontSize: 10)))),
                  ],
                )),
              ]),

              // Preview remaining if both set
              if (totalSupply != null && startDate != null) ...[
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  // Estimate days since start (approximate taken count)
                  final daysSinceStart =
                      DateTime.now().difference(startDate!).inDays;
                  final freq = existing?.dosesPerDay ?? 1;
                  final estimated = (daysSinceStart * freq)
                      .clamp(0, totalSupply!);
                  final remaining = totalSupply! - estimated;
                  final isLow = remaining <= 7;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isLow
                          ? AppColors.peachLight : AppColors.tealLight,
                      borderRadius: AppRadius.smBR),
                    child: Row(children: [
                      Text(isLow ? '⚠' : '✓',
                        style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        remaining <= 0
                            ? 'Pack likely finished — request refill'
                            : 'Approx. $remaining doses remaining',
                        style: AppText.caption.copyWith(
                          fontSize: 11,
                          color: isLow ? AppColors.peach : AppColors.teal,
                          fontWeight: FontWeight.w500)),
                    ]),
                  );
                }),
              ],

              const SizedBox(height: 16),

              Row(children: [
                if (isEdit) ...[
                  Expanded(child: GestureDetector(
                    onTap: () {
                      _session.removeMedication(existing.id);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.roseLight,
                        borderRadius: AppRadius.mdBR,
                        border: Border.all(
                          color: AppColors.rose.withOpacity(0.2),
                          width: 0.5)),
                      child: Center(child: Text('Delete',
                        style: AppText.caption.copyWith(
                          color: AppColors.rose,
                          fontWeight: FontWeight.w500,
                          fontSize: 13)))))),
                  const SizedBox(width: 8),
                ],
                Expanded(flex: 2, child: GestureDetector(
                  onTap: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final med = Medication(
                      id: isEdit
                          ? existing.id
                          : DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.trim(),
                      dose: doseCtrl.text.trim().isEmpty
                          ? '1 dose' : doseCtrl.text.trim(),
                      frequency: freqCtrl.text.trim().isEmpty
                          ? 'Daily' : freqCtrl.text.trim(),
                      emoji: emoji,
                      category: category,
                      notes: notesCtrl.text.trim().isEmpty
                          ? null : notesCtrl.text.trim(),
                      startDate: startDate ?? existing?.startDate,
                      totalSupply: totalSupply,
                    );
                    if (isEdit) {
                      _session.updateMedication(med);
                    } else {
                      _session.addMedication(med);
                    }
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.mdBR,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))]),
                    child: Center(child: Text(
                      isEdit ? 'Save changes' : 'Add medication',
                      style: const TextStyle(fontFamily: 'Inter',
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: Colors.white)))))),
              ]),
            ],
          )),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppText.bodySecondary),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl,
        style: const TextStyle(fontFamily: 'Inter',
          fontSize: 14, color: AppColors.text1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.text3, fontSize: 13),
          filled: true, fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.border, width: 0.5)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.border, width: 0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.primaryMid, width: 1.5))),
      ),
    ]);
}
