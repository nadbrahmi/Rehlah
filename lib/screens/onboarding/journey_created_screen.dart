import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';

class JourneyCreatedScreen extends StatelessWidget {
  const JourneyCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final journey = provider.journey;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Success illustration
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE1A3D8), Color(0xFF9B5A9B)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 28),
              Text('Journey created! 🎉',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 12),
              Text(
                "We've created your personalized roadmap\nbased on your journey details.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Journey details card
              RehlaCard(
                child: Column(
                  children: [
                    _DetailRow(
                        icon: Icons.person_rounded,
                        label: 'Name',
                        value: journey?.name ?? ''),
                    const Divider(height: 24),
                    _DetailRow(
                        icon: Icons.medical_information_rounded,
                        label: 'Cancer Type',
                        value: journey?.cancerType ?? ''),
                    const Divider(height: 24),
                    _DetailRow(
                        icon: Icons.flag_rounded,
                        label: 'Stage',
                        value: journey?.stage ?? ''),
                    const Divider(height: 24),
                    _DetailRow(
                        icon: Icons.timeline_rounded,
                        label: 'Current Phase',
                        value: journey?.treatmentPhase ?? ''),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // What you can do
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("What you'll be able to do:",
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),
                    ...const [
                      'Track symptoms daily',
                      'View your treatment roadmap',
                      'Log medications & appointments',
                      'Get AI-powered insights',
                    ].map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.accent, size: 16),
                              const SizedBox(width: 8),
                              Text(f,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const Spacer(),
              PurpleGradientButton(
                label: 'Start with Home Dashboard',
                icon: Icons.home_rounded,
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
              ),
              const SizedBox(height: 12),
              Text(
                'You can create an account anytime from Settings\nto save and share your journey.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}
