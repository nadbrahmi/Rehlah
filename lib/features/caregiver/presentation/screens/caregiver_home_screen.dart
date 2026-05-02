import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/caregiver_session.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});
  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  final _session = UserSession();
  final _caregiver = CaregiverSession();

  @override
  void initState() {
    super.initState();
    _session.addListener(_rebuild);
  }

  @override
  void dispose() {
    _session.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final patientName = _caregiver.patientName;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE · d MMMM').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [

          // Header
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Caregiver badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: AppColors.teal.withOpacity(0.2), width: 0.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.teal, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Caregiver view · Read only',
                    style: AppText.caption.copyWith(
                      color: AppColors.teal,
                      fontSize: 10, fontWeight: FontWeight.w500)),
                ]),
              ),
              const SizedBox(height: 12),
              Text(dateStr.toUpperCase(), style: AppText.label),
              const SizedBox(height: 3),
              RichText(text: TextSpan(
                style: AppText.displayTitle,
                children: [
                  const TextSpan(text: "How is "),
                  TextSpan(text: patientName,
                    style: AppText.displayTitle.copyWith(
                      fontWeight: FontWeight.w700)),
                  const TextSpan(text: '\ntoday?'),
                ],
              )),
              const SizedBox(height: 4),
              Text(_caregiver.patientPhase,
                style: AppText.bodySecondary),
            ]),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // 1 — Today's mood
          SliverToBoxAdapter(child: _buildMoodCard(patientName)),

          // 2 — Phase context (plain language)
          SliverToBoxAdapter(child: _buildPhaseCard()),

          // 3 — Medications today
          SliverToBoxAdapter(child: _buildMedsCard()),

          // 4 — Next appointment
          SliverToBoxAdapter(child: _buildAppointmentCard()),

          // Disconnect link
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: GestureDetector(
              onTap: _showDisconnectSheet,
              child: Center(child: Text(
                'Disconnect from ${patientName}\'s journey',
                style: AppText.caption.copyWith(
                  color: AppColors.text3, fontSize: 11))),
            ),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
      ),
    );
  }

  // ── 1. Mood card ────────────────────────────────────────────────────────────
  Widget _buildMoodCard(String name) {
    final checkedIn = _session.checkedInToday;
    final mood = _session.moodEmoji;
    final label = _session.moodLabel;
    final note = _session.checkInNote;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('TODAY\'S CHECK-IN', style: AppText.label),
          const Spacer(),
          if (checkedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.tealLight,
                borderRadius: AppRadius.fullBR),
              child: Text('✓ Checked in',
                style: AppText.caption.copyWith(
                  color: AppColors.teal,
                  fontSize: 10, fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 10),
        if (checkedIn) ...[
          Row(children: [
            Text(mood, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: AppText.bodySemibold.copyWith(fontSize: 15)),
              Text('Feeling $label today',
                style: AppText.bodySecondary.copyWith(fontSize: 12)),
            ]),
          ]),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background2,
                borderRadius: AppRadius.smBR),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text('💬', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Expanded(child: Text('"$note"',
                  style: AppText.bodySecondary.copyWith(
                    fontSize: 12,
                    fontStyle: FontStyle.italic))),
              ]),
            ),
          ],
        ] else ...[
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.background2,
                shape: BoxShape.circle),
              child: const Center(child: Text('·',
                style: TextStyle(fontSize: 20, color: AppColors.text3)))),
            const SizedBox(width: 12),
            Expanded(child: Text(
              '$name hasn\'t checked in yet today.',
              style: AppText.bodySecondary.copyWith(fontSize: 13))),
          ]),
        ],
      ]),
    );
  }

  // ── 2. Phase card ───────────────────────────────────────────────────────────
  Widget _buildPhaseCard() {
    final isMonitoring = _session.isMonitoring;
    final isNadir = _session.isNadirWindow;
    final isNadirApproaching = _session.isNadirApproaching;

    String title;
    String body;
    String emoji;
    Color color;

    if (isMonitoring) {
      if (_session.isScanxietyPeriod) {
        title = 'Scan week approaching';
        body = 'It\'s normal to feel anxious before a scan. Be present and patient — scan anxiety is real and valid.';
        emoji = '⚡';
        color = AppColors.gold;
      } else {
        final days = _session.daysCancerFree;
        title = '$days days cancer-free';
        body = 'Regular monitoring and staying consistent with medications are the most important things right now.';
        emoji = '🎗️';
        color = AppColors.teal;
      }
    } else if (isNadir) {
      title = 'Nadir window — immune system at lowest';
      body = 'This is the most vulnerable week. Watch for fever above 38°C. If it happens, call the care team immediately — don\'t wait.';
      emoji = '⚠';
      color = AppColors.peach;
    } else if (isNadirApproaching) {
      title = 'Nadir approaching in 1–2 days';
      body = 'The immune system will reach its lowest point soon. Check temperature morning and evening. Avoid crowded places if possible.';
      emoji = '⚡';
      color = AppColors.gold;
    } else {
      final phase = _session.currentPhase;
      title = phase.name;
      body = phase.caregiverNote.isNotEmpty
          ? phase.caregiverNote
          : 'Supporting someone through treatment means being present. You\'re doing that.';
      emoji = '💜';
      color = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: color.withOpacity(0.2), width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('THIS WEEK', style: AppText.label),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.bodySemibold.copyWith(
                color: color, fontSize: 13)),
              const SizedBox(height: 4),
              Text(body, style: AppText.bodySecondary.copyWith(
                fontSize: 12, height: 1.5)),
            ],
          )),
        ]),
      ]),
    );
  }

  // ── 3. Medications card ─────────────────────────────────────────────────────
  Widget _buildMedsCard() {
    final meds = _session.medications;
    if (meds.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MEDICATIONS TODAY', style: AppText.label),
        const SizedBox(height: 10),
        ...meds.map((med) {
          final taken = _session.isMedTaken(med.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Text(med.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name, style: AppText.bodySemibold.copyWith(
                    fontSize: 13)),
                  Text(med.frequency,
                    style: AppText.caption.copyWith(
                      fontSize: 11, color: AppColors.text3)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: taken ? AppColors.tealLight : AppColors.background2,
                  borderRadius: AppRadius.fullBR),
                child: Text(taken ? 'Taken ✓' : 'Not yet',
                  style: AppText.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: taken ? AppColors.teal : AppColors.text3))),
            ]),
          );
        }),
        // Refill alert
        if (_session.hasRefillAlert) ...[
          const Divider(height: 16),
          Row(children: [
            const Text('⚠', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Expanded(child: Text(
              'Refill needed for ${_session.medsRunningLow.map((m) => m.name).join(', ')}',
              style: AppText.caption.copyWith(
                color: AppColors.peach, fontSize: 11,
                fontWeight: FontWeight.w500))),
          ]),
        ],
      ]),
    );
  }

  // ── 4. Appointment card ─────────────────────────────────────────────────────
  Widget _buildAppointmentCard() {
    _session.initDefaultAppointments();
    final upcoming = _session.upcomingAppointments;

    if (upcoming.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEXT APPOINTMENT', style: AppText.label),
          const SizedBox(height: 10),
          Text('No upcoming appointments scheduled.',
            style: AppText.bodySecondary.copyWith(fontSize: 13)),
        ]),
      );
    }

    final next = upcoming.first;
    final daysAway = next.daysUntil;
    final color = daysAway <= 1 ? AppColors.rose
        : daysAway <= 3 ? AppColors.peach
        : AppColors.text2;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NEXT APPOINTMENT', style: AppText.label),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.peachLight,
              borderRadius: AppRadius.smBR),
            child: const Center(child: Text('📅',
              style: TextStyle(fontSize: 18)))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(next.title, style: AppText.bodySemibold),
              Text(
                '${DateFormat('EEEE, d MMMM').format(next.dateTime)}'
                '${next.location.isNotEmpty ? ' · ${next.location}' : ''}',
                style: AppText.bodySecondary.copyWith(fontSize: 12)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: AppRadius.fullBR),
            child: Text(
              daysAway == 0 ? 'Today!'
                  : daysAway == 1 ? 'Tomorrow'
                  : 'In $daysAway days',
              style: AppText.caption.copyWith(
                color: color, fontSize: 11,
                fontWeight: FontWeight.w500))),
        ]),
      ]),
    );
  }

  // ── Disconnect sheet ────────────────────────────────────────────────────────
  void _showDisconnectSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Disconnect?', style: AppText.sectionHeading),
          const SizedBox(height: 8),
          Text(
            'You will no longer see ${_caregiver.patientName}\'s updates. '
            'You can reconnect anytime with the same code.',
            style: AppText.bodySecondary,
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _caregiver.reset();
              UserSession().reset();
              Navigator.pop(context);
              context.go('/welcome');
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.roseLight,
                borderRadius: AppRadius.fullBR,
                border: Border.all(
                  color: AppColors.rose.withOpacity(0.2))),
              child: Center(child: Text('Disconnect',
                style: AppText.bodySemibold.copyWith(
                  color: AppColors.rose))))),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(child: Text('Keep connected',
              style: AppText.bodySecondary))),
        ]),
      ),
    );
  }
}
