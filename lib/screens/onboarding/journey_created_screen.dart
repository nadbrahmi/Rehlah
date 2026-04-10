import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// JOURNEY CREATED SCREEN — The Celebration Moment
// "Your journey begins today, [Name]."
// This is the most emotional screen in the app.
// Auto-navigates after 8 seconds — give the patient time to read.
// They may cry. Give them time.
// ═══════════════════════════════════════════════════════════════════════════════

class JourneyCreatedScreen extends StatefulWidget {
  const JourneyCreatedScreen({super.key});

  @override
  State<JourneyCreatedScreen> createState() => _JourneyCreatedScreenState();
}

class _JourneyCreatedScreenState extends State<JourneyCreatedScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  late final AnimationController _fadeCtrl;
  late final AnimationController _countdownCtrl;
  late final Animation<double> _heartScale;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _contentFade;
  Timer? _autoNavTimer;
  int _countdown = 8;

  @override
  void initState() {
    super.initState();

    // Heartbeat pulse on the 💜
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _heartScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut),
    );

    // Main fade-in
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeCtrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _fadeCtrl.forward();

    // Countdown timer — auto navigate after 8 seconds
    _countdownCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();

    // Per-second tick for countdown display
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _countdown = (_countdown - 1).clamp(0, 8);
      });
      if (_countdown == 0) t.cancel();
    });

    // Auto-navigate
    _autoNavTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) _navigateToMain();
    });
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _fadeCtrl.dispose();
    _countdownCtrl.dispose();
    _autoNavTimer?.cancel();
    super.dispose();
  }

  void _navigateToMain() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final journey = provider.journey;
    final firstName = journey?.name.split(' ').first ?? '';
    final phase = journey?.treatmentPhase ?? 'Diagnosis & Planning';

    return GestureDetector(
      onTap: _navigateToMain,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Confetti / celebration emoji with heartbeat ──────────
                  const Text('🎉', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 16),

                  // Pulsing 💜
                  ScaleTransition(
                    scale: _heartScale,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFD894D3), Color(0xFF9B5DC4)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('💜', style: TextStyle(fontSize: 44)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Headline
                  FadeTransition(
                    opacity: _contentFade,
                    child: Column(
                      children: [
                        Text(
                          firstName.isNotEmpty
                              ? 'Your journey begins today, $firstName. 💜'
                              : 'Your journey begins today. 💜',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.28,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Rehlah will be right here with you\nevery step of the way.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── First milestone card ────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF3E8F5)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9B5DC4).withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your first milestone',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySurface,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _phaseEmoji(phase),
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _firstMilestoneTitle(phase),
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _firstMilestoneDesc(phase),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Quick wins list ─────────────────────────────────
                        _QuickWinsList(),

                        const SizedBox(height: 28),

                        // ── CTA ─────────────────────────────────────────────
                        PurpleGradientButton(
                          label: 'Go to my journey',
                          icon: Icons.arrow_forward_rounded,
                          onTap: _navigateToMain,
                        ),

                        const SizedBox(height: 18),

                        // Countdown hint
                        AnimatedBuilder(
                          animation: _countdownCtrl,
                          builder: (_, __) {
                            return Text(
                              _countdown > 0
                                  ? 'Or tap anywhere · continues in ${_countdown}s'
                                  : 'Taking you to your dashboard…',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),
                        Text(
                          'Your data stays on this device.\nNo account needed. No password required.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _phaseEmoji(String phase) {
    switch (phase) {
      case 'Chemotherapy': return '💊';
      case 'Radiation': return '☢️';
      case 'Surgery': return '🏥';
      case 'Recovery': return '🌱';
      case 'Immunotherapy': return '💉';
      default: return '🔬';
    }
  }

  String _firstMilestoneTitle(String phase) {
    switch (phase) {
      case 'Chemotherapy': return 'First Chemo Session';
      case 'Radiation': return 'First Radiation Session';
      case 'Surgery': return 'Pre-Surgery Preparation';
      case 'Recovery': return 'Recovery & Healing';
      case 'Immunotherapy': return 'First Immunotherapy Session';
      default: return 'Initial Consultation';
    }
  }

  String _firstMilestoneDesc(String phase) {
    switch (phase) {
      case 'Chemotherapy': return 'Track how you feel before, during and after your first session';
      case 'Radiation': return 'Log your daily radiation sessions and side effects';
      case 'Surgery': return 'Prepare your questions and document your health status';
      case 'Recovery': return 'Rest, heal, and track your recovery progress each day';
      case 'Immunotherapy': return 'Monitor your immune response and side effects over time';
      default: return 'Meeting your care team and getting your full picture';
    }
  }
}

// ── Quick Wins List ───────────────────────────────────────────────────────────
class _QuickWinsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('💜', 'Do your first 2-minute check-in', 'Takes less time than making tea'),
      ('💊', 'Add your medications', 'Never forget a dose again'),
      ('🧪', 'Log your lab results', "We'll explain what they mean"),
      ('🤝', 'Read a community story', "You're not the first. You won't be the last."),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's waiting for you",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$3,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
