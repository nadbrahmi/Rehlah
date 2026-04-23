import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../main_screen.dart';
import '../checkin/checkin_screen.dart';
import '../yusr/yusr_overlay.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      final l = AppLocalizations(isArabic: isAr);
      final now = DateTime.now();
      final String dateStr;
      if (isAr) {
        final arabicDays = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
        final arabicMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
          'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
        dateStr = '${arabicDays[now.weekday - 1]}، ${now.day} ${arabicMonths[now.month - 1]}';
      } else {
        final engDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final engMonths = ['January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'];
        dateStr = '${engDays[now.weekday - 1]}, ${now.day} ${engMonths[now.month - 1]}';
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ScreenHeader(title: l.tabToday, subtitle: dateStr),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    // Hero card
                    _HeroCard(provider: provider, isAr: isAr, l: l),
                    const SizedBox(height: 16),

                    // Nadir alert (always shown for chemo users near nadir)
                    if (provider.isChemoUser) ...[
                      _NadirAlertCard(isAr: isAr),
                      const SizedBox(height: 16),
                    ],

                    // Quick access shortcuts
                    _QuickAccessRow(provider: provider, isAr: isAr, l: l),
                    const SizedBox(height: 16),

                    // Yusr suggestion card
                    _YusrSuggestionCard(isAr: isAr),
                    const SizedBox(height: 16),

                    // Insights (demo only)
                    if (provider.isDemoMode) _InsightsSection(isAr: isAr),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final AppProvider provider;
  final bool isAr;
  final AppLocalizations l;
  const _HeroCard({required this.provider, required this.isAr, required this.l});

  String _greeting() {
    final h = DateTime.now().hour;
    if (isAr) {
      if (h < 12) return 'صباح الخير';
      if (h < 17) return 'مساء الخير';
      return 'مساء النور';
    } else {
      if (h < 12) return 'Good morning';
      if (h < 17) return 'Good afternoon';
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: provider.checkedInToday
          ? _CheckedInState(provider: provider, isAr: isAr, l: l, greeting: _greeting())
          : _NotCheckedInState(provider: provider, isAr: isAr, l: l, greeting: _greeting()),
    );
  }
}

class _NotCheckedInState extends StatelessWidget {
  final AppProvider provider;
  final bool isAr;
  final AppLocalizations l;
  final String greeting;
  const _NotCheckedInState(
      {required this.provider, required this.isAr, required this.l, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting, ${provider.userName}',
            style: GoogleFonts.almarai(
                fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(
          isAr
              ? 'الدورة ٢ · اليوم ٧ · نافذة النادير تقترب'
              : 'Cycle 2 · Day 7 · Nadir window approaching',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Text(l.todayHowAreYou,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Directionality(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  child: const CheckinScreen(),
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: Text(
              isAr ? 'ابدئي تسجيلكِ — أقل من دقيقة' : 'Begin Check-In — less than a minute',
              style: GoogleFonts.almarai(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckedInState extends StatelessWidget {
  final AppProvider provider;
  final bool isAr;
  final AppLocalizations l;
  final String greeting;
  const _CheckedInState(
      {required this.provider, required this.isAr, required this.l, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting, ${provider.userName}',
            style: GoogleFonts.almarai(
                fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration:
                  const BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: AppColors.teal, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              isAr ? 'سجّلتِ حالكِ اليوم ✓' : 'Check-in done today ✓',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.teal),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isAr ? 'أحسنتِ — عودي غداً.' : 'See you tomorrow — you are doing great.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Nadir Alert Card ──────────────────────────────────────────────────────────
class _NadirAlertCard extends StatelessWidget {
  final bool isAr;
  const _NadirAlertCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: isAr
              ? BorderSide.none
              : const BorderSide(color: AppColors.amber, width: 4),
          right: isAr
              ? const BorderSide(color: AppColors.amber, width: 4)
              : BorderSide.none,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_outlined, color: AppColors.amber, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr
                  ? 'نافذة النادير: الأيام ٨–١٤. جهازكِ المناعي سيكون في أدنى مستوياته. راقبي درجة حرارتكِ.'
                  : 'Nadir window: Days 8–14. Your immune system will be at its lowest. Monitor your temperature.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.amberDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Access Row ──────────────────────────────────────────────────────────
class _QuickAccessRow extends StatelessWidget {
  final AppProvider provider;
  final bool isAr;
  final AppLocalizations l;
  const _QuickAccessRow(
      {required this.provider, required this.isAr, required this.l});

  @override
  Widget build(BuildContext context) {
    final medColor = provider.medications.any((m) => !m.isTaken && !m.isAsNeeded)
        ? AppColors.amber
        : AppColors.teal;
    final labColor = provider.labStatusNormal ? AppColors.teal : AppColors.amber;

    return Row(
      children: [
        _QuickCard(
          emoji: '💊',
          label: l.todayMeds,
          sub: provider.pendingMedsCount,
          subColor: medColor,
          onTap: () {
            context.read<AppProvider>().setTab(2);
            context.read<AppProvider>().setCareTab(0);
          },
        ),
        const SizedBox(width: 10),
        _QuickCard(
          emoji: '📅',
          label: l.todayAppointments,
          sub: provider.nextAppointmentLabel,
          subColor: AppColors.textSecondary,
          onTap: () {
            context.read<AppProvider>().setTab(2);
            context.read<AppProvider>().setCareTab(1);
          },
        ),
        const SizedBox(width: 10),
        _QuickCard(
          emoji: '🔬',
          label: l.todayLabs,
          sub: provider.labStatusLabel,
          subColor: labColor,
          onTap: () {
            context.read<AppProvider>().setTab(2);
            context.read<AppProvider>().setCareTab(2);
          },
        ),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final Color subColor;
  final VoidCallback onTap;
  const _QuickCard(
      {required this.emoji,
      required this.label,
      required this.sub,
      required this.subColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: cardDecoration(),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(sub,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: subColor, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Yusr Suggestion Card ──────────────────────────────────────────────────────
class _YusrSuggestionCard extends StatelessWidget {
  final bool isAr;
  const _YusrSuggestionCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const YusrOverlay(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: isAr
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 3),
            right: isAr
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isAr
                    ? 'هل لديكِ أسئلة حول ما تمرين به هذا الأسبوع؟'
                    : 'Have questions about what you are experiencing this week?',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isAr ? 'تحدثي مع يُسر ←' : 'Chat with Yusr →',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Insights ──────────────────────────────────────────────────────────────────
class _InsightsSection extends StatelessWidget {
  final bool isAr;
  const _InsightsSection({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'آخر التغييرات' : 'Recent updates',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        _InsightRow(
            isAr ? 'الإرهاق كان مرتفعاً في ٥ من آخر ٧ أيام.' : 'Fatigue was high in 5 of the last 7 days.'),
        const SizedBox(height: 8),
        _InsightRow(
            isAr ? 'الغثيان تحسّن مقارنة بالأسبوع الماضي.' : 'Nausea improved compared to last week.'),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String text;
  const _InsightRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
