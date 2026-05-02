import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

class CheckInSuccessScreen extends StatefulWidget {
  const CheckInSuccessScreen({super.key});
  @override
  State<CheckInSuccessScreen> createState() => _CheckInSuccessState();
}

class _CheckInSuccessState extends State<CheckInSuccessScreen> {
  String? _insight;
  bool _loading = true;
  bool _error = false;
  final _session = UserSession();

  @override
  void initState() {
    super.initState();
    _fetchInsight();
  }

  Future<void> _fetchInsight() async {
    try {
      final prompt = _buildPrompt();
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': const String.fromEnvironment('ANTHROPIC_API_KEY',
              defaultValue: ''),
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 200,
          'system': '''You are Rehlah AI, a compassionate oncology companion.
Write a 2–3 sentence personalised insight for a cancer patient after their daily check-in.
Rules:
- Warm, empathetic, never clinical or alarming
- Acknowledge their specific symptoms by name
- Include one practical tip relevant to their phase
- End with a sentence of emotional validation
- Never mention specific medications or dosages
- Keep it under 60 words''',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['content'][0]['text'] as String;
        if (mounted) setState(() { _insight = text; _loading = false; });
      } else {
        if (mounted) setState(() { _insight = _fallbackInsight(); _loading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _insight = _fallbackInsight(); _loading = false; });
    }
  }

  String _buildPrompt() {
    final session = _session;
    final phase = session.currentPhase;
    return 'Patient: ${session.displayName}, ${session.cancerType}.\n'
        'Protocol: ${session.protocol.fullName}.\n'
        'Phase: ${session.phaseContext}.\n'
        'Current phase note: ${phase.phaseNote}\n'
        'Today\'s mood: ${session.moodLabel.isNotEmpty ? session.moodLabel : "okay"}.\n'
        'Symptoms today: ${session.symptomSummary}.\n'
        '${session.isNadirWindow ? "IMPORTANT: Patient is in nadir window — immune system at lowest.\n" : ""}'
        '${session.checkInNote.isNotEmpty ? "Patient note: ${session.checkInNote}\n" : ""}'
        'Write a warm, personalised 2–3 sentence insight for ${session.displayName}.';
  }

  String _fallbackInsight() {
    final s = _session;
    final phase = s.currentPhase;
    final name = s.displayName;
    final history = s.history;

    // ── Monitoring phase insights ─────────────────────────────────────────
    if (s.isMonitoring) {
      // Scanxiety
      if (s.isScanxietyPeriod) {
        final next = s.nextControl;
        final days = next?.nextScheduled?.difference(DateTime.now()).inDays ?? 0;
        return '$name, with your ${next?.typeLabel ?? 'scan'} $days day${days != 1 ? 's' : ''} away, '
            'it\'s completely normal to feel anxious. Scanxiety is real and valid. '
            'Tracking your feelings here helps your care team understand how you\'re doing. '
            'If anxiety is affecting your sleep or daily life, mention it at your next appointment. 💜';
      }
      // Severe anxiety/mood for monitoring
      final severeAnxiety = s.symptomScores.entries
          .where((e) => (e.key == 'anxiety' || e.key == 'mood') && e.value >= 7)
          .toList();
      if (severeAnxiety.isNotEmpty) {
        return '$name, high anxiety or low mood after cancer treatment is very common '
            'and doesn\'t mean anything is wrong medically. '
            'Post-treatment emotional challenges deserve the same attention as physical ones. '
            'Consider mentioning this to your care team — support is available. 💜';
      }
      // Trend: improving mood
      if (history.length >= 3) {
        final recent = history.take(3).toList();
        final moodValues = recent.map((r) => _moodValue(r.moodEmoji)).toList();
        if (moodValues.every((v) => v > 0) && moodValues.first >= moodValues.last + 0.5) {
          return '$name, your mood has been improving over the last few check-ins — '
              'that\'s a meaningful sign of recovery. '
              'Staying consistent with tracking gives your team the full picture. '
              'Every check-in matters. 💜';
        }
      }
      // Cancer-free milestone
      final days = s.daysCancerFree;
      if (days > 0) {
        final milestone = days >= 1825 ? '5 years'
            : days >= 1095 ? '3 years'
            : days >= 730 ? '2 years'
            : days >= 365 ? '1 year'
            : days >= 180 ? '6 months'
            : days >= 90 ? '3 months' : null;
        if (milestone != null) {
          return '$name, $milestone cancer-free is a milestone worth acknowledging. '
              'Long-term monitoring is part of staying well — and you\'re doing it. '
              'Keep tracking how you feel. Your data tells a story worth sharing with your team. 💜';
        }
      }
      return '$name, staying consistent with check-ins during monitoring '
          'helps your care team spot patterns early. '
          'Joint pain, fatigue, and mood changes from hormone therapy are worth tracking. '
          'You\'re doing the right thing. 💜';
    }

    // ── Trend-based insights (needs history) ─────────────────────────────
    if (history.length >= 3) {
      final recent = history.take(3).toList();

      // Same symptom high for 3 days
      final topSymptom = s.symptomScores.entries
          .where((e) => e.value >= 5)
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

      if (topSymptom.isNotEmpty) {
        final key = topSymptom.first.key;
        final daysHigh = recent.where((r) =>
            (r.symptomScores[key] ?? 0) >= 5).length;
        if (daysHigh >= 2) {
          final label = key.replaceAll('_', ' ');
          return '$name, $label has been consistently high for the last $daysHigh check-ins. '
              'This pattern is worth mentioning to your care team — '
              'it may indicate something that needs attention or a management adjustment. '
              'Your doctor-ready report captures this automatically. 💜';
        }
      }

      // Mood improving
      final moodValues = recent.map((r) => _moodValue(r.moodEmoji)).toList();
      if (moodValues.every((v) => v > 0) &&
          moodValues.first > moodValues.last) {
        return '$name, your mood has been improving since your last check-in. '
            'Even small improvements matter during treatment. '
            'Keep noting what helps on the days you feel better. 💜';
      }

      // Mood declining
      if (moodValues.every((v) => v > 0) &&
          moodValues.first < moodValues.last - 0.5) {
        return '$name, your mood has been lower these past few days. '
            'This is completely expected during ${phase.name.toLowerCase()}. '
            'If it continues or feels overwhelming, please let your care team know — '
            'emotional support is part of your treatment. 💜';
      }
    }

    // ── Nadir window — highest priority ──────────────────────────────────
    if (s.isNadirWindow) {
      return '$name, you\'re in the nadir window — days when your immune system '
          'is at its lowest. Rest is genuinely part of your treatment right now. '
          'Take your temperature morning and evening, and call your team '
          'immediately if it reaches 38°C. Checking in every day during this '
          'window is one of the most important things you can do. 💜';
    }

    // Nadir approaching
    if (s.isNadirApproaching) {
      return 'Your nadir window is 1–2 days away — the phase when your WBC '
          'count reaches its lowest. Start monitoring your temperature now, '
          'twice daily. Avoid crowds where possible and wash hands frequently. '
          'You\'re being proactive by tracking this. 💜';
    }

    // Severe symptoms (score ≥ 7)
    final severe = s.symptomScores.entries
        .where((e) => e.value >= 7)
        .map((e) => e.key.replaceAll('_', ' '))
        .toList();
    if (severe.isNotEmpty) {
      final sym = severe.first;
      return '$name, your $sym today is significant — please don\'t push through '
          'it alone. ${phase.phaseNote} '
          'Your care team can see this entry. If it worsens, reach out directly '
          'rather than waiting for your next appointment. 💜';
    }

    // Moderate symptoms (score 4–6)
    final moderate = s.symptomScores.entries
        .where((e) => e.value >= 4 && e.value < 7)
        .map((e) => e.key.replaceAll('_', ' '))
        .toList();
    if (moderate.isNotEmpty) {
      final sym = moderate.first;
      final symptom = phase.primarySymptoms
          .where((p) => p.key == moderate.first.replaceAll(' ', '_'))
          .firstOrNull;
      final tip = symptom?.tip ?? 'Rest when your body asks.';
      return '$name, the $sym you\'re feeling is a known part of the '
          '${phase.name.toLowerCase()} phase. $tip '
          'You\'re doing the right thing by tracking it. 💜';
    }

    // Recovery phase
    if (phase.name.toLowerCase().contains('recovery')) {
      return '$name, you\'re in the recovery phase — your body is rebuilding. '
          'Energy usually improves day by day from here. '
          'Gentle movement, good hydration, and nutrition all help your '
          'counts recover faster. You\'re almost through this cycle. 💜';
    }

    // Streak milestone
    if (s.streak == 7) {
      return '$name, 7 days in a row — a full week of check-ins. '
          'Consistency like this gives your care team a much clearer picture '
          'of how you\'re doing. Keep it going. 💜';
    }
    if (s.streak == 14) {
      return '$name, 14 consecutive check-ins. '
          'That\'s remarkable commitment to your own care. '
          'Your prep report now has two weeks of real data to share with your team. 💜';
    }

    // Default
    return '$name, you completed today\'s check-in for ${s.protocol.name} '
        '${phase.name.toLowerCase()}. ${phase.phaseNote} '
        'Your care team sees every entry you make. 💜';
  }

  double _moodValue(String emoji) {
    const map = {'😣': 1.0, '😔': 2.0, '😐': 3.0, '🙂': 4.0, '😊': 5.0,
                 '😄': 5.0, '😢': 1.0, '😕': 2.0, '🙁': 2.0};
    return map[emoji] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // Top section — celebration
          Expanded(child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Celebration icon
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.teal.withOpacity(0.20),
                    AppColors.primary.withOpacity(0.08),
                  ]),
                  border: Border.all(
                    color: AppColors.teal.withOpacity(0.30), width: 1.5),
                  boxShadow: [BoxShadow(
                    color: AppColors.teal.withOpacity(0.15),
                    blurRadius: 32)],
                ),
                child: const Center(child: Text('✓',
                  style: TextStyle(fontSize: 36,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w300))),
              ),
              const SizedBox(height: 20),
              Text('Check-in complete',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text1, letterSpacing: -0.3)),
              const SizedBox(height: 6),
              Text(_streakText(),
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: AppColors.teal, fontWeight: FontWeight.w500)),
              const SizedBox(height: 28),

              // Insight card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.mdBR,
                  border: Border.all(color: AppColors.border, width: 0.5),
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withOpacity(0.05),
                    blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.smBR),
                      child: const Icon(Icons.auto_awesome_rounded,
                        size: 12, color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Text('Your insight today',
                      style: AppText.bodySemibold.copyWith(
                        color: AppColors.primary, fontSize: 12)),
                  ]),
                  const SizedBox(height: 10),
                  if (_loading)
                    _buildLoadingDots()
                  else
                    Text(_insight ?? '',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.text1, height: 1.7)),
                ]),
              ),
            ]),
          )),

          // Bottom actions — always visible
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(children: [
              // Primary
              GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.fullBR,
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.28),
                      blurRadius: 12, offset: const Offset(0, 3))]),
                  child: const Center(child: Text('Back to home',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                      fontWeight: FontWeight.w500, color: Colors.white))),
                ),
              ),
              const SizedBox(height: 10),
              // Secondary
              GestureDetector(
                onTap: () => context.push('/care/appointments/prep'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.border, width: 0.5)),
                  child: Center(child: Text('View doctor-ready report →',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.text2))),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(children: [
      Text('Generating your insight',
        style: AppText.bodySecondary.copyWith(fontSize: 13)),
      const SizedBox(width: 6),
      SizedBox(
        width: 40, height: 20,
        child: _AnimatedDots(),
      ),
    ]);
  }

  String _streakText() {
    final streak = _session.streak;
    if (streak <= 1) return 'First check-in! Keep it going 🌱';
    if (streak == 7) return '7 days in a row 🔥 One full week!';
    if (streak >= 30) return '$streak days in a row 🏆 Incredible!';
    return '$streak days in a row 🔥';
  }
}

class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _anim = _ctrl;
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final t = (_ctrl.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(
                i == t ? 1.0 : 0.3)),
          )),
        );
      },
    );
  }
}
