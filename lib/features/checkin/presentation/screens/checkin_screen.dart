import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/models.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  MoodLevel _mood = MoodLevel.okay;
  final Set<String> _selectedSymptoms = {};
  final _session = UserSession();
  late ChemoPhase _phase;

  @override
  void initState() {
    super.initState();
    _phase = _session.currentPhase;
    // Pre-select most likely symptoms for this phase (top 2)
    if (_phase.primarySymptoms.length >= 2) {
      _selectedSymptoms.add(_phase.primarySymptoms[0].label);
      _selectedSymptoms.add(_phase.primarySymptoms[1].label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        Positioned(top: -50, left: -25,
          child: Container(width: 180, height: 180,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withOpacity(0.10), Colors.transparent])))),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Row(children: [
                    Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                      color: AppColors.text2.withOpacity(0.4)),
                    const SizedBox(width: 4),
                    Text('Home', style: AppText.caption.copyWith(
                      color: AppColors.text2, fontSize: 11)),
                  ]),
                ),
                const SizedBox(height: 14),

                // Protocol + phase pill
                _buildPhasePill(),
                const SizedBox(height: 12),

                // Title
                RichText(text: TextSpan(
                  style: AppText.displayTitle.copyWith(fontSize: 22),
                  children: const [
                    TextSpan(text: 'How are you\n'),
                    TextSpan(text: 'feeling today?',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                )),
                const SizedBox(height: 5),
                Text('No right answers. Just how you are.',
                  style: AppText.bodySecondary),
                const SizedBox(height: 16),

                // Phase note card
                _buildPhaseNote(),
                const SizedBox(height: 16),

                // Nadir warning
                if (_session.isNadirWindow) ...[
                  _buildNadirCard(),
                  const SizedBox(height: 14),
                ],

                // Nadir approaching
                if (_session.isNadirApproaching && !_session.isNadirWindow) ...[
                  _buildNadirApproachingCard(),
                  const SizedBox(height: 14),
                ],

                // Mood
                Text('OVERALL MOOD', style: AppText.label),
                const SizedBox(height: 10),
                _buildMoodRow(),
                const SizedBox(height: 18),

                // Protocol-specific symptoms
                _buildSymptomsHeader(),
                const SizedBox(height: 10),
                _buildSymptomChips(),
                const SizedBox(height: 14),

                // Encouragement
                EncouragementCard(
                  text: 'Your check-ins help your care team understand '
                      'what you need. Every entry matters.',
                ),
                const SizedBox(height: 18),

                // Save
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.fullBR,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: const Center(child: Text('Save check-in',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                        fontWeight: FontWeight.w500, color: Colors.white))),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.go('/checkin/sliders'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.fullBR,
                      border: Border.all(color: AppColors.border, width: 0.5)),
                    child: const Center(child: Text('Rate symptoms in detail →',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w400, color: AppColors.primary))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPhasePill() {
    final isNadir = _session.isNadirWindow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: isNadir
            ? AppColors.peach.withOpacity(0.12)
            : AppColors.primaryLight,
        borderRadius: AppRadius.fullBR,
        border: Border.all(
          color: isNadir
              ? AppColors.peach.withOpacity(0.3)
              : AppColors.primaryMid,
          width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isNadir ? AppColors.peach : AppColors.primary)),
        const SizedBox(width: 6),
        Text(
          '${_session.protocol.name} · Cycle ${_session.currentCycle} of ${_session.totalCycles} · Day ${_session.dayInCycle}',
          style: AppText.caption.copyWith(
            fontSize: 11, fontWeight: FontWeight.w500,
            color: isNadir ? AppColors.peach : AppColors.primary)),
      ]),
    );
  }

  Widget _buildPhaseNote() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: AppRadius.smBR),
          child: const Icon(Icons.info_outline_rounded,
            size: 14, color: AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_phase.description,
              style: AppText.bodySemibold.copyWith(
                fontSize: 12, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(_phase.phaseNote,
              style: AppText.bodySecondary.copyWith(fontSize: 12, height: 1.55)),
          ],
        )),
      ]),
    );
  }

  Widget _buildNadirCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.peachLight,
        borderRadius: AppRadius.mdBR,
        border: const Border(left: BorderSide(color: AppColors.peach, width: 3))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⚠', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nadir window · Day ${_session.dayInCycle}',
              style: AppText.bodySemibold.copyWith(color: AppColors.peach)),
            const SizedBox(height: 3),
            Text(
              'Your immune system is at its lowest right now. '
              'Take your temperature morning and evening. '
              'Call your team immediately if fever reaches 38°C (100.4°F).',
              style: AppText.bodySecondary.copyWith(fontSize: 12)),
          ],
        )),
      ]),
    );
  }

  Widget _buildNadirApproachingCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.07),
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.gold.withOpacity(0.25), width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⚡', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nadir window approaching',
              style: AppText.bodySemibold.copyWith(color: AppColors.gold)),
            const SizedBox(height: 3),
            Text(
              'Your WBC count will reach its lowest in the next 1–2 days. '
              'Start monitoring your temperature twice daily.',
              style: AppText.bodySecondary.copyWith(fontSize: 12)),
          ],
        )),
      ]),
    );
  }

  Widget _buildSymptomsHeader() {
    return Row(children: [
      Text('SYMPTOMS', style: AppText.label),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: AppRadius.fullBR),
        child: Text('ranked for ${_phase.name}',
          style: AppText.caption.copyWith(
            fontSize: 10, color: AppColors.primary,
            fontWeight: FontWeight.w500)),
      ),
    ]);
  }

  Widget _buildSymptomChips() {
    // Primary symptoms from protocol
    final primary = _phase.primarySymptoms;
    // Watch symptoms (urgent) shown separately
    final watch = _phase.watchSymptoms
        .where((w) => !primary.any((p) => p.key == w.key))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6, runSpacing: 6,
          children: primary.map((s) {
            final sel = _selectedSymptoms.contains(s.label);
            return _chip(s.label, sel, s.emoji);
          }).toList(),
        ),
        if (watch.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('ALSO WATCH FOR', style: AppText.label.copyWith(fontSize: 9)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: watch.map((s) {
              final sel = _selectedSymptoms.contains(s.label);
              return _chip(s.label, sel, s.emoji,
                isUrgent: s.isUrgent);
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _chip(String label, bool sel, String emoji,
      {bool isUrgent = false}) {
    return GestureDetector(
      onTap: () => setState(() {
        if (sel) _selectedSymptoms.remove(label);
        else _selectedSymptoms.add(label);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? (isUrgent ? AppColors.peachLight : AppColors.primaryLight)
              : AppColors.surface,
          borderRadius: AppRadius.fullBR,
          border: Border.all(
            color: sel
                ? (isUrgent ? AppColors.peach.withOpacity(0.4) : AppColors.primaryMid)
                : AppColors.border,
            width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(label, style: AppText.body.copyWith(
            fontSize: 12,
            color: sel
                ? (isUrgent ? AppColors.peach : AppColors.primary)
                : AppColors.text2,
            fontWeight: sel ? FontWeight.w500 : FontWeight.w300)),
          if (isUrgent && !sel) ...[
            const SizedBox(width: 4),
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.peach)),
          ],
        ]),
      ),
    );
  }

  void _save() {
    // ignore: avoid_print
    print('🔵 _save() called on checkin_screen, mood: ${_mood.emoji}');
    _session.moodEmoji = _mood.emoji;
    _session.moodLabel = _mood.label;
    _session.symptomScores = {
      for (final s in _selectedSymptoms) s.toLowerCase(): 5.0
    };
    _session.lastCheckIn = DateTime.now();
    _session.saveCheckIn();
    // ignore: avoid_print
    print('🔵 after saveCheckIn, history: ${_session.history.length}');
    context.go('/checkin/success');
  }

  Widget _buildMoodRow() {
    return Row(
      children: MoodLevel.values.map((m) {
        final sel = m == _mood;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _mood = m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: m != MoodLevel.great ? 5 : 0),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: sel ? AppColors.primaryLight : AppColors.surface,
                borderRadius: AppRadius.mdBR,
                border: Border.all(
                  color: sel ? AppColors.primaryMid : AppColors.border,
                  width: 0.5),
              ),
              child: Column(children: [
                Text(m.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(m.label, style: AppText.caption.copyWith(
                  fontSize: 10, fontWeight: FontWeight.w500,
                  color: sel ? AppColors.primary : AppColors.text3)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}