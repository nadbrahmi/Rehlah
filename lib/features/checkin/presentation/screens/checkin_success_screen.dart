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
    final session = _session;
    if (session.isNadirWindow) {
      return 'You\'re in the nadir window right now — the toughest days of the cycle. '
          'Rest is genuinely part of your treatment this week. '
          'Watch for fever above 38°C and call your team immediately if it occurs. '
          'You\'re doing exactly what you need to do by checking in. 💜';
    }
    final symptoms = session.symptomScores.entries
        .where((e) => e.value >= 5)
        .map((e) => e.key)
        .toList();
    if (symptoms.isNotEmpty) {
      return 'Your ${symptoms.first} today is real and valid — it\'s one of the most '
          'common experiences at this stage of treatment. '
          'Small, gentle movement and staying hydrated can help. '
          'Your care team sees every check-in, and you\'re not going through this alone. 💜';
    }
    return 'Every check-in you complete helps your care team understand your journey. '
        'The fact that you showed up today — even on a hard day — says a lot about your strength. '
        'Rest when you need to. You\'re doing well. 💜';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              // Ring
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.teal.withOpacity(0.18),
                    AppColors.primary.withOpacity(0.10),
                  ]),
                  border: Border.all(
                    color: AppColors.teal.withOpacity(0.28), width: 1.5),
                  boxShadow: [BoxShadow(
                    color: AppColors.teal.withOpacity(0.12), blurRadius: 28)],
                ),
                child: const Center(child: Text('🌿',
                  style: TextStyle(fontSize: 30))),
              ),
              const SizedBox(height: 20),
              Text('Well done today',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text(
                'Streak: ${_streakText()}',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  color: AppColors.teal, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),

              // AI insight card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgBR,
                  border: Border.all(color: AppColors.border, width: 0.5),
                  boxShadow: [BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: AppRadius.smBR),
                        child: const Icon(Icons.auto_awesome_rounded,
                          size: 14, color: AppColors.primary)),
                      const SizedBox(width: 8),
                      Text('Rehlah AI · Your insight today',
                        style: AppText.bodySemibold.copyWith(
                          color: AppColors.primary, fontSize: 13)),
                    ]),
                    const SizedBox(height: 12),
                    if (_loading)
                      _buildLoadingDots()
                    else
                      Text(_insight ?? '',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.text1, height: 1.75)),
                  ],
                ),
              ),
              const Spacer(),

              // Go to dashboard
              GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3DB87A), Color(0xFF2A9060)]),
                    borderRadius: AppRadius.fullBR,
                    boxShadow: [BoxShadow(
                      color: AppColors.teal.withOpacity(0.28),
                      blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: const Center(child: Text('Go to dashboard',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                      fontWeight: FontWeight.w500, color: Colors.white))),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.go('/ai-chat'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.primaryMid, width: 0.5)),
                  child: const Center(child: Text('Ask AI a follow-up question',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w400, color: AppColors.primary))),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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

  String _streakText() => '6 days in a row 🔥';
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
