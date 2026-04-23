import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import '../main_screen.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      final l = AppLocalizations(isArabic: isAr);
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l.tabJourney,
                  subtitle: isAr ? 'رحلتكِ العلاجية' : 'Your treatment journey',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _WhereIAmCard(provider: provider, isAr: isAr),
                    const SizedBox(height: 24),
                    _SectionHeading(
                      icon: Icons.mood_outlined,
                      label: isAr ? 'ما الذي قد تشعرين به الآن' : 'What you may feel right now',
                    ),
                    const SizedBox(height: 12),
                    _SymptomsGrid(isAr: isAr),
                    const SizedBox(height: 24),
                    _WhenToWorryCard(isAr: isAr),
                    const SizedBox(height: 24),
                    _WhatComesNextCard(isAr: isAr),
                    const SizedBox(height: 20),
                    _DisclaimerFooter(isAr: isAr),
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

// ─────────────────────────────────────────────────────────────────────────────
//  Section heading
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeading({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section 1 — Where I Am
// ─────────────────────────────────────────────────────────────────────────────
class _WhereIAmCard extends StatelessWidget {
  final AppProvider provider;
  final bool isAr;
  const _WhereIAmCard({required this.provider, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: AppColors.primaryBorder)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryMid, AppColors.gradEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'العلاج الكيميائي' : 'Chemotherapy',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w800,
                            color: AppColors.primary, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAr
                            ? 'الدورة ٢ · اليوم ٧ من ٢١ · سرطان الثدي'
                            : 'Cycle 2 · Day 7 of 21 · Breast Cancer',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'موقعكِ في الدورة الحالية' : 'Your position in this cycle',
                  style: tsLabel(c: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                _CycleDotsStrip(
                    currentDay: provider.currentDay,
                    totalDays: provider.totalDays),
                const SizedBox(height: 6),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _LegendDot(color: AppColors.teal, label: isAr ? 'مكتمل' : 'Done'),
                    const SizedBox(width: 10),
                    _LegendDot(color: AppColors.primary, label: isAr ? 'اليوم' : 'Today'),
                    const SizedBox(width: 10),
                    _LegendDot(color: AppColors.amber, label: isAr ? 'نادير' : 'Nadir'),
                  ],
                ),
                const SizedBox(height: 14),
                // Alert inline
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.amberBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.amber, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAr
                              ? 'أنتِ في اليوم ٧. نافذة النادير تبدأ غداً — الأيام ٨ إلى ١٤.'
                              : 'You are on Day 7. Nadir window starts tomorrow — Days 8 to 14.',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.amberDark,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: tsCaption()),
      ],
    );
  }
}

class _CycleDotsStrip extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  const _CycleDotsStrip(
      {required this.currentDay, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        children: List.generate(totalDays, (i) {
          final day = i + 1;
          final isCurrent = day == currentDay;
          final isDone = day < currentDay;
          final isNadir = day >= 8 && day <= 14 && !isDone && !isCurrent;

          Color color;
          if (isDone) {
            color = AppColors.teal;
          } else if (isCurrent) {
            color = AppColors.primary;
          } else if (isNadir) {
            color = AppColors.amber;
          } else {
            color = AppColors.borderLight;
          }

          return Expanded(
            child: Center(
              child: isCurrent
                  ? Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2.5),
                      ),
                      child: Center(
                        child: Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                        ),
                      ),
                    )
                  : AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isDone ? 10 : 8,
                      height: isDone ? 10 : 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section 2 — Symptoms Grid
// ─────────────────────────────────────────────────────────────────────────────
class _SymptomsGrid extends StatelessWidget {
  final bool isAr;
  const _SymptomsGrid({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SymptomData(
        icon: Icons.bolt_rounded,
        color: const Color(0xFFB45309),
        bg: const Color(0xFFFFFBEB),
        title: isAr ? 'الإرهاق' : 'Fatigue',
        desc: isAr
            ? 'يبلغ ذروته في الأيام ٧–٩. الراحة أولوية.'
            : 'Peaks Days 7–9. Rest is your priority.',
      ),
      _SymptomData(
        icon: Icons.sentiment_dissatisfied_outlined,
        color: const Color(0xFF0F766E),
        bg: const Color(0xFFF0FDFA),
        title: isAr ? 'الغثيان' : 'Nausea',
        desc: isAr
            ? 'تناولي الدواء بانتظام حتى عند التحسن.'
            : 'Take medication regularly, even when okay.',
      ),
      _SymptomData(
        icon: Icons.face_outlined,
        color: const Color(0xFF7C3AED),
        bg: const Color(0xFFF5F3FF),
        title: isAr ? 'تساقط الشعر' : 'Hair loss',
        desc: isAr
            ? 'يبدأ بعد ٢–٣ أسابيع من بدء العلاج.'
            : 'Usually begins 2–3 weeks after start.',
      ),
      _SymptomData(
        icon: Icons.restaurant_outlined,
        color: const Color(0xFF0369A1),
        bg: const Color(0xFFF0F9FF),
        title: isAr ? 'تغيّر الشهية' : 'Appetite changes',
        desc: isAr
            ? 'وجبات صغيرة ومتكررة أسهل على جسمكِ.'
            : 'Small, frequent meals are easier.',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: items.map((s) => _SymptomTile(data: s)).toList(),
    );
  }
}

class _SymptomData {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String desc;
  const _SymptomData({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.desc,
  });
}

class _SymptomTile extends StatelessWidget {
  final _SymptomData data;
  const _SymptomTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: data.bg, borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(data.title,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Expanded(
            child: Text(data.desc,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Section 3 — When to Worry
// ─────────────────────────────────────────────────────────────────────────────
class _WhenToWorryCard extends StatelessWidget {
  final bool isAr;
  const _WhenToWorryCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final rows = isAr
        ? ['درجة حرارة فوق ٣٨°م', 'ألم شديد مفاجئ', 'صعوبة في التنفس']
        : ['Fever above 38°C', 'Sudden severe pain', 'Difficulty breathing'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone_in_talk_outlined,
                      color: AppColors.emergencyRed, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAr ? 'متى تتواصلين مع فريقكِ' : 'When to contact your care team',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...rows.asMap().entries.map((e) => Padding(
                  padding: EdgeInsets.only(
                      bottom: e.key < rows.length - 1 ? 10 : 0),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text('${e.key + 1}',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w800,
                                  color: AppColors.emergencyRed)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(e.value,
                            style: GoogleFonts.inter(
                                fontSize: 14, color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: AppColors.emergencyRed, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAr
                              ? 'تواصلي مع فريقكِ فوراً. لا تنتظري موعدكِ القادم.'
                              : 'Contact your care team immediately. Do not wait for your next appointment.',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.emergencyRed,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
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
//  Section 4 — What comes next
// ─────────────────────────────────────────────────────────────────────────────
class _WhatComesNextCard extends StatelessWidget {
  final bool isAr;
  const _WhatComesNextCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tealBorder),
        boxShadow: shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_forward_rounded,
                color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'ما الذي يأتي بعد ذلك' : 'What comes next',
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppColors.teal),
                ),
                const SizedBox(height: 6),
                Text(
                  isAr
                      ? 'بعد اليوم ١٤ يبدأ جهازكِ المناعي بالتعافي. تعود الطاقة عادةً في الأيام ١٦–١٨. أنتِ تقتربين من النهاية — استمري.'
                      : 'After Day 14 your immune system begins recovering. Energy usually returns around Days 16–18. You are nearly there — keep going.',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.teal,
                      height: 1.55),
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
//  Disclaimer footer
// ─────────────────────────────────────────────────────────────────────────────
class _DisclaimerFooter extends StatelessWidget {
  final bool isAr;
  const _DisclaimerFooter({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAr
                  ? 'معلومات عامة فقط — ليست نصيحة طبية. تواصلي مع فريقكِ بأي استفسار.'
                  : 'General information only — not medical advice. Contact your care team with any concerns.',
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
