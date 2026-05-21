import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/rehlah_theme.dart';
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
      backgroundColor: RColors.sand50,
      body: SafeArea(
        child: CustomScrollView(slivers: [

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: RColors.teal50,
                  borderRadius: RRadius.pillBR,
                  border: Border.all(
                    color: RColors.teal200.withValues(alpha: 0.5), width: 0.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: RColors.teal600, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Caregiver view · Read only',
                    style: RText.small.copyWith(
                      color: RColors.teal700,
                      fontSize: 10, fontWeight: FontWeight.w500)),
                ]),
              ),
              const SizedBox(height: 12),
              Text(dateStr.toUpperCase(), style: RText.eyebrow),
              const SizedBox(height: 3),
              RichText(text: TextSpan(
                style: RText.h2,
                children: [
                  const TextSpan(text: 'How is '),
                  TextSpan(text: patientName,
                    style: RText.h2.copyWith(fontWeight: FontWeight.w700)),
                  const TextSpan(text: '\ntoday?'),
                ],
              )),
              const SizedBox(height: 4),
              Text(_caregiver.patientPhase, style: RText.bodyMuted),
            ]),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(child: _buildMoodCard(patientName)),
          SliverToBoxAdapter(child: _buildPhaseCard()),
          SliverToBoxAdapter(child: _buildMedsCard()),
          SliverToBoxAdapter(child: _buildAppointmentCard()),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: GestureDetector(
              onTap: _showDisconnectSheet,
              child: Center(child: Text(
                'Disconnect from ${patientName}\'s journey',
                style: RText.small.copyWith(
                  color: RColors.sand400, fontSize: 11))),
            ),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
      ),
    );
  }

  Widget _buildMoodCard(String name) {
    final checkedIn = _session.checkedInToday;
    final mood = _session.moodEmoji;
    final label = _session.moodLabel;
    final note = _session.checkInNote;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        boxShadow: RShadow.shadow1,
        border: Border.all(color: RColors.sand200, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('TODAY\'S CHECK-IN', style: RText.eyebrow),
          const Spacer(),
          if (checkedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: RColors.sage100,
                borderRadius: RRadius.pillBR),
              child: Text('✓ Checked in',
                style: RText.small.copyWith(
                  color: RColors.sage700,
                  fontSize: 10, fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 10),
        if (checkedIn) ...[
          Row(children: [
            Text(mood, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: RText.body.copyWith(fontWeight: FontWeight.w500, fontSize: 15)),
              Text('Feeling $label today',
                style: RText.bodyMuted.copyWith(fontSize: 12)),
            ]),
          ]),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: RColors.sand100,
                borderRadius: RRadius.smBR),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text('💬', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Expanded(child: Text('"$note"',
                  style: RText.bodyMuted.copyWith(
                    fontSize: 12,
                    fontStyle: FontStyle.italic))),
              ]),
            ),
          ],
        ] else ...[
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(
                color: RColors.sand100,
                shape: BoxShape.circle),
              child: const Center(child: Text('·',
                style: TextStyle(fontSize: 20, color: RColors.sand400)))),
            const SizedBox(width: 12),
            Expanded(child: Text(
              '$name hasn\'t checked in yet today.',
              style: RText.bodyMuted.copyWith(fontSize: 13))),
          ]),
        ],
      ]),
    );
  }

  Widget _buildPhaseCard() {
    final isMonitoring = _session.isMonitoring;
    final isNadir = _session.isNadirWindow;
    final isNadirApproaching = _session.isNadirApproaching;

    String title;
    String body;
    String emoji;
    Color bgColor;
    Color borderColor;
    Color titleColor;

    if (isMonitoring) {
      if (_session.isScanxietyPeriod) {
        title = 'Scan week approaching';
        body = 'It\'s normal to feel anxious before a scan. Be present and patient — scan anxiety is real and valid.';
        emoji = '⚡';
        bgColor = RColors.saffron100;
        borderColor = RColors.saffron300;
        titleColor = RColors.saffron700;
      } else {
        final days = _session.daysCancerFree;
        title = '$days days cancer-free';
        body = 'Regular monitoring and staying consistent with medications are the most important things right now.';
        emoji = '🎗️';
        bgColor = RColors.sage100;
        borderColor = RColors.sage300;
        titleColor = RColors.sage700;
      }
    } else if (isNadir) {
      title = 'Nadir window — immune system at lowest';
      body = 'This is the most vulnerable week. Watch for fever above 38°C. If it happens, call the care team immediately — don\'t wait.';
      emoji = '⚠';
      bgColor = RColors.clay100;
      borderColor = RColors.clay300;
      titleColor = RColors.clay700;
    } else if (isNadirApproaching) {
      title = 'Nadir approaching in 1–2 days';
      body = 'The immune system will reach its lowest point soon. Check temperature morning and evening. Avoid crowded places if possible.';
      emoji = '⚡';
      bgColor = RColors.saffron100;
      borderColor = RColors.saffron300;
      titleColor = RColors.saffron700;
    } else {
      final phase = _session.currentPhase;
      title = phase.name;
      body = phase.caregiverNote.isNotEmpty
          ? phase.caregiverNote
          : 'Supporting someone through treatment means being present. You\'re doing that.';
      emoji = '💜';
      bgColor = RColors.teal50;
      borderColor = RColors.teal200;
      titleColor = RColors.teal700;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('THIS WEEK', style: RText.eyebrow),
        const SizedBox(height: 8),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RText.body.copyWith(
                color: titleColor, fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 4),
              Text(body, style: RText.bodyMuted.copyWith(
                fontSize: 12, height: 1.5)),
            ],
          )),
        ]),
      ]),
    );
  }

  Widget _buildMedsCard() {
    final meds = _session.medications;
    if (meds.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        boxShadow: RShadow.shadow1,
        border: Border.all(color: RColors.sand200, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MEDICATIONS TODAY', style: RText.eyebrow),
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
                  Text(med.name, style: RText.body.copyWith(
                    fontWeight: FontWeight.w500, fontSize: 13)),
                  Text(med.frequency,
                    style: RText.small.copyWith(
                      fontSize: 11, color: RColors.sand400)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: taken ? RColors.sage100 : RColors.sand100,
                  borderRadius: RRadius.pillBR),
                child: Text(taken ? 'Taken ✓' : 'Not yet',
                  style: RText.small.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: taken ? RColors.sage700 : RColors.sand400))),
            ]),
          );
        }),
        if (_session.hasRefillAlert) ...[
          const Divider(height: 16, color: RColors.sand200),
          Row(children: [
            const Text('⚠', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Expanded(child: Text(
              'Refill needed for ${_session.medsRunningLow.map((m) => m.name).join(', ')}',
              style: RText.small.copyWith(
                color: RColors.clay500, fontSize: 11,
                fontWeight: FontWeight.w500))),
          ]),
        ],
      ]),
    );
  }

  Widget _buildAppointmentCard() {
    _session.initDefaultAppointments();
    final upcoming = _session.upcomingAppointments;

    if (upcoming.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          boxShadow: RShadow.shadow1,
          border: Border.all(color: RColors.sand200, width: 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('NEXT APPOINTMENT', style: RText.eyebrow),
          const SizedBox(height: 10),
          Text('No upcoming appointments scheduled.',
            style: RText.bodyMuted.copyWith(fontSize: 13)),
        ]),
      );
    }

    final next = upcoming.first;
    final daysAway = next.daysUntil;
    final statusColor = daysAway <= 1 ? RColors.clay500
        : daysAway <= 3 ? RColors.saffron500
        : RColors.sand700;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        boxShadow: RShadow.shadow1,
        border: Border.all(color: RColors.sand200, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NEXT APPOINTMENT', style: RText.eyebrow),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: RColors.saffron100,
              borderRadius: RRadius.smBR),
            child: const Center(child: Text('📅',
              style: TextStyle(fontSize: 18)))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(next.title, style: RText.body.copyWith(fontWeight: FontWeight.w500)),
              Text(
                '${DateFormat('EEEE, d MMMM').format(next.dateTime)}'
                '${next.location.isNotEmpty ? ' · ${next.location}' : ''}',
                style: RText.bodyMuted.copyWith(fontSize: 12)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: RRadius.pillBR),
            child: Text(
              daysAway == 0 ? 'Today!'
                  : daysAway == 1 ? 'Tomorrow'
                  : 'In $daysAway days',
              style: RText.small.copyWith(
                color: statusColor, fontSize: 11,
                fontWeight: FontWeight.w500))),
        ]),
      ]),
    );
  }

  void _showDisconnectSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(
              color: RColors.sand200,
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Disconnect?', style: RText.h3),
          const SizedBox(height: 8),
          Text(
            'You will no longer see ${_caregiver.patientName}\'s updates. '
            'You can reconnect anytime with the same code.',
            style: RText.bodyMuted,
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
                color: RColors.clay100,
                borderRadius: RRadius.pillBR,
                border: Border.all(
                  color: RColors.clay300.withValues(alpha: 0.4))),
              child: Center(child: Text('Disconnect',
                style: RText.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: RColors.clay700))))),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(child: Text('Keep connected',
              style: RText.bodyMuted))),
        ]),
      ),
    );
  }
}
