import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        final days = ['الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'];
        final months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
        dateStr = '${days[now.weekday - 1]}، ${now.day} ${months[now.month - 1]}';
      } else {
        final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
        final months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
        dateStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: ScreenHeader(title: l.tabToday, subtitle: dateStr)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero card ───────────────────────────────────────
                      _HeroCard(provider: provider, isAr: isAr, l: l),
                      const SizedBox(height: 16),

                      // ── Nadir alert ────────────────────────────────────
                      if (provider.isChemoUser) ...[
                        _NadirAlertCard(isAr: isAr),
                        const SizedBox(height: 16),
                      ],

                      // ── Quick access ───────────────────────────────────
                      _QuickAccessRow(provider: provider, isAr: isAr, l: l),
                      const SizedBox(height: 16),

                      // ── Yusr card ──────────────────────────────────────
                      _YusrCard(isAr: isAr),
                      const SizedBox(height: 16),

                      // ── Today's summary ────────────────────────────────
                      if (provider.isDemoMode) ...[
                        _TodaySummarySection(isAr: isAr, provider: provider),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Hero Card
// ─────────────────────────────────────────────────────────────────────────────
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadowPurple(opacity: 0.22),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle pattern overlay
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: provider.checkedInToday
                  ? _CheckedInState(provider: provider, isAr: isAr, l: l, greeting: _greeting())
                  : _NotCheckedInState(provider: provider, isAr: isAr, l: l, greeting: _greeting()),
            ),
          ],
        ),
      ),
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
        // Greeting
        Text(
          '$greeting,',
          style: GoogleFonts.inter(
              fontSize: 15, color: Colors.white.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 2),
        Text(
          provider.userName,
          style: GoogleFonts.inter(
              fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
              letterSpacing: -0.5),
        ),
        const SizedBox(height: 10),
        // Cycle badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Text(
            isAr
                ? 'الدورة ٢ · اليوم ٧ · نافذة النادير تقترب'
                : 'Cycle 2 · Day 7 · Nadir window approaching',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          isAr ? 'كيف حالكِ اليوم؟' : 'How are you feeling today?',
          style: GoogleFonts.inter(
              fontSize: 14, color: Colors.white.withValues(alpha: 0.75)),
        ),
        const SizedBox(height: 12),
        // CTA button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: const CheckinScreen(),
              ),
            ));
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'ابدئي تسجيلكِ — أقل من دقيقة' : 'Begin Check-In — less than a minute',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                ],
              ),
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
        Text('$greeting,',
            style: GoogleFonts.inter(
                fontSize: 15, color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(height: 2),
        Text(provider.userName,
            style: GoogleFonts.inter(
                fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: -0.5)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                    color: const Color(0xFF10B981), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                isAr ? 'سجّلتِ حالكِ اليوم ✓' : 'Check-in done today ✓',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isAr ? 'أحسنتِ — عودي غداً.' : 'You are doing great. See you tomorrow.',
          style: GoogleFonts.inter(
              fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Nadir Alert Card
// ─────────────────────────────────────────────────────────────────────────────
class _NadirAlertCard extends StatelessWidget {
  final bool isAr;
  const _NadirAlertCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.amberBorder),
        boxShadow: shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.amber, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'تنبيه: نافذة النادير' : 'Nadir window alert',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.amberDark),
                ),
                const SizedBox(height: 3),
                Text(
                  isAr
                      ? 'الأيام ٨–١٤: جهازكِ المناعي في أدنى مستوياته. راقبي درجة حرارتكِ يومياً.'
                      : 'Days 8–14: Your immune system is at its lowest. Monitor your temperature daily.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.amberDark, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Quick Access Row
// ─────────────────────────────────────────────────────────────────────────────
class _QuickAccessRow extends StatelessWidget {
  final AppProvider provider;
  final bool isAr;
  final AppLocalizations l;
  const _QuickAccessRow(
      {required this.provider, required this.isAr, required this.l});

  @override
  Widget build(BuildContext context) {
    final hasPendingMeds = provider.medications.any((m) => !m.isTaken && !m.isAsNeeded);
    final labNormal = provider.labStatusNormal;

    return Row(
      children: [
        _QuickCard(
          icon: Icons.medication_outlined,
          iconColor: hasPendingMeds ? AppColors.amber : AppColors.teal,
          iconBg: hasPendingMeds ? AppColors.amberLight : AppColors.tealLight,
          label: l.todayMeds,
          sub: provider.pendingMedsCount,
          subColor: hasPendingMeds ? AppColors.amber : AppColors.teal,
          onTap: () {
            context.read<AppProvider>().setTab(2);
            context.read<AppProvider>().setCareTab(0);
          },
        ),
        const SizedBox(width: 10),
        _QuickCard(
          icon: Icons.calendar_month_outlined,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
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
          icon: Icons.biotech_outlined,
          iconColor: labNormal ? AppColors.teal : AppColors.amber,
          iconBg: labNormal ? AppColors.tealLight : AppColors.amberLight,
          label: l.todayLabs,
          sub: provider.labStatusLabel,
          subColor: labNormal ? AppColors.teal : AppColors.amber,
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
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String sub;
  final Color subColor;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.sub,
    required this.subColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.1)),
              const SizedBox(height: 3),
              Text(sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: subColor, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Yusr Card
// ─────────────────────────────────────────────────────────────────────────────
class _YusrCard extends StatelessWidget {
  final bool isAr;
  const _YusrCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const YusrOverlay(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBorder),
          boxShadow: shadowSm,
        ),
        child: Row(
          children: [
            // Yusr avatar
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryMid, AppColors.gradEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('Y',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'يُسر — مساعدتكِ الصحية' : 'Yusr — Your health companion',
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAr
                        ? 'هل لديكِ أسئلة حول ما تشعرين به هذا الأسبوع؟'
                        : 'Have questions about what you are experiencing?',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAr ? 'تحدّثي' : 'Chat',
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Today Summary Section
// ─────────────────────────────────────────────────────────────────────────────
class _TodaySummarySection extends StatelessWidget {
  final bool isAr;
  final AppProvider provider;
  const _TodaySummarySection({required this.isAr, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isAr ? 'ملاحظات من هذا الأسبوع' : 'This week\'s insights',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: Text(
                isAr ? 'يُسر' : 'AI',
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InsightTile(
          icon: Icons.bolt_rounded,
          iconColor: AppColors.amber,
          iconBg: AppColors.amberLight,
          text: isAr
              ? 'الإرهاق كان مرتفعاً في ٥ من آخر ٧ أيام — وهذا طبيعي في هذه المرحلة.'
              : 'Fatigue was high in 5 of the last 7 days — this is typical at this stage.',
        ),
        const SizedBox(height: 8),
        _InsightTile(
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.teal,
          iconBg: AppColors.tealLight,
          text: isAr
              ? 'الغثيان تحسّن مقارنة بالأسبوع الماضي — أحسنتِ.'
              : 'Nausea improved compared to last week — great progress.',
        ),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String text;
  const _InsightTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textPrimary, height: 1.45)),
          ),
        ],
      ),
    );
  }
}
