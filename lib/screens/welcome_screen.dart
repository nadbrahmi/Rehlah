import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import 'onboarding/onboarding_flow.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isArabic = provider.isArabic;
      final l = AppLocalizations(isArabic: isArabic);
      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Gradient hero ──────────────────────────────────────────
                Container(
                  height: MediaQuery.of(context).size.height * 0.42,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7C3AED), Color(0xFF9F67F8), Color(0xFFC4B5FD)],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        // Language toggle button (top corner)
                        Positioned(
                          top: 8,
                          right: isArabic ? null : 16,
                          left: isArabic ? 16 : null,
                          child: GestureDetector(
                            onTap: () => provider.setLanguage(!isArabic),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                isArabic ? 'EN' : 'عر',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        // Main hero content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App icon
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                                ),
                                child: const Center(
                                  child: Text('💜', style: TextStyle(fontSize: 36)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isArabic ? 'رحلة يُسر' : 'Rehlah',
                                style: GoogleFonts.almarai(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'REHLAH',
                                style: GoogleFonts.inter(
                                    fontSize: 11,
                                    letterSpacing: 4,
                                    color: Colors.white.withValues(alpha: 0.7)),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l.appTagline,
                                style: GoogleFonts.almarai(
                                    fontSize: 16,
                                    color: Colors.white.withValues(alpha: 0.92)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── White content area ─────────────────────────────────────
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Trust chips
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text('💜 ${isArabic ? "للمريضات" : "For patients"}',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textSecondary)),
                          Text(' · ',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textSecondary)),
                          Text('🤝 ${isArabic ? "لمقدّمي الرعاية" : "For caregivers"}',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textSecondary)),
                          Text(' · ',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textSecondary)),
                          Text('⭐ ${isArabic ? "بلا حكم" : "No judgment"}',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Headline
                      Text(
                        isArabic ? 'لستِ وحدكِ في هذه الرحلة' : 'You are not alone on this journey',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.almarai(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isArabic
                            ? 'رحلة يُسر تساعدكِ على تتبّع شعوركِ، وفهم تحاليلكِ، والتواصل مع من مررن بتجربتكِ.'
                            : 'Rehlah helps you track how you feel, understand your tests, and connect with others who\'ve been through it.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 15, color: AppColors.textSecondary, height: 1.6),
                      ),
                      const SizedBox(height: 20),

                      // Feature chips scrollable
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FeatureChip('💜 ${isArabic ? "تتبّع الأعراض" : "Symptom tracking"}'),
                            _FeatureChip('🔬 ${isArabic ? "التحاليل" : "Lab results"}'),
                            _FeatureChip('💊 ${isArabic ? "الأدوية" : "Medications"}'),
                            _FeatureChip('🤝 ${isArabic ? "مجتمع الدعم" : "Support community"}'),
                            _FeatureChip('🤖 ${isArabic ? "يُسر AI" : "Yusr AI"}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Trust icons row
                      Row(
                        children: [
                          _TrustIcon('🔒', isArabic ? 'خاص وآمن' : 'Private & secure'),
                          _TrustIcon('📱', isArabic ? 'على جهازكِ' : 'On your device'),
                          _TrustIcon('✨', isArabic ? 'بلا تسجيل' : 'No registration'),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Primary CTA
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: provider,
                                child: const OnboardingFlow(),
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28)),
                            elevation: 0,
                          ),
                          child: Text(
                            l.welcomeCta,
                            style: GoogleFonts.almarai(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Demo link
                      TextButton(
                        onPressed: () {
                          provider.enterDemoMode();
                        },
                        child: Text(
                          l.welcomeDemo,
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
    );
  }
}

class _TrustIcon extends StatelessWidget {
  final String icon;
  final String label;
  const _TrustIcon(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
