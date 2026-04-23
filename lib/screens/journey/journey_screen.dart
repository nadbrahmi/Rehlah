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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    // Section 1 — Where I am
                    _WhereIAmSection(provider: provider, isAr: isAr),
                    const SizedBox(height: 24),
                    // Section 2 — What is happening
                    _WhatIsHappeningSection(isAr: isAr),
                    const SizedBox(height: 24),
                    // Section 3 — When to worry
                    _WhenToWorrySection(isAr: isAr),
                    const SizedBox(height: 24),
                    // Section 4 — What comes next
                    _WhatComesNextSection(isAr: isAr),
                    const SizedBox(height: 24),
                    // Footer
                    Center(
                      child: Text(
                        isAr
                            ? 'معلومات عامة فقط — ليست نصيحة طبية. تواصلي مع فريقكِ بأي استفسار.'
                            : 'General information only — not medical advice. Contact your care team with any concerns.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
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

// ── Section 1 — Where I Am ────────────────────────────────────────────────────
class _WhereIAmSection extends StatelessWidget {
  final AppProvider provider;
  final bool isAr;
  const _WhereIAmSection({required this.provider, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: isAr
              ? BorderSide.none
              : const BorderSide(color: AppColors.primary, width: 4),
          right: isAr
              ? const BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'العلاج الكيميائي' : 'Chemotherapy',
            style: GoogleFonts.almarai(
                fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            isAr
                ? 'الدورة ٢ · اليوم ٧ من ٢١ · سرطان الثدي'
                : 'Cycle 2 · Day 7 of 21 · Breast Cancer',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? 'أين أنتِ في دورتكِ' : 'Where you are in your cycle',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          _CycleDotsStrip(
              currentDay: provider.currentDay, totalDays: provider.totalDays),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amberLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAr
                  ? 'أنتِ في اليوم ٧. نافذة النادير تبدأ غداً — الأيام ٨ إلى ١٤.'
                  : 'You are on Day 7. Nadir window starts tomorrow — Days 8 to 14.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.amberDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleDotsStrip extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  const _CycleDotsStrip({required this.currentDay, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalDays, (i) {
        final day = i + 1;
        final isCurrent = day == currentDay;
        final isDone = day < currentDay;
        final isNadir = day >= 8 && day <= 14 && !isDone && !isCurrent;

        Color color;
        double size;
        if (isDone) {
          color = AppColors.teal;
          size = 8;
        } else if (isCurrent) {
          color = AppColors.primary;
          size = 12;
        } else if (isNadir) {
          color = AppColors.amber;
          size = 8;
        } else {
          color = AppColors.border;
          size = 8;
        }

        return Expanded(
          child: Center(
            child: isCurrent
                ? Container(
                    width: size + 4,
                    height: size + 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: size - 2,
                        height: size - 2,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                      ),
                    ),
                  )
                : Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
          ),
        );
      }),
    );
  }
}

// ── Section 2 — What is happening ────────────────────────────────────────────
class _WhatIsHappeningSection extends StatelessWidget {
  final bool isAr;
  const _WhatIsHappeningSection({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final symptoms = isAr
        ? [
            (Icons.battery_0_bar, '⚡', isAr ? 'الإرهاق' : 'Fatigue',
                isAr
                    ? 'يبلغ ذروته عادةً في الأيام ٧-٩. استريحي بقدر ما تحتاجين اليوم.'
                    : 'Usually peaks Days 7–9. Rest as much as you need today.'),
            (Icons.sick_outlined, '🤢', isAr ? 'الغثيان' : 'Nausea',
                isAr
                    ? 'تناولي مضادات الغثيان بانتظام حتى عند الشعور بالتحسن.'
                    : 'Take anti-nausea medication regularly, even when feeling okay.'),
            (Icons.face_outlined, '💇', isAr ? 'تساقط الشعر' : 'Hair loss',
                isAr
                    ? 'يبدأ عادةً بعد ٢-٣ أسابيع من بدء العلاج.'
                    : 'Usually begins 2–3 weeks after treatment starts.'),
            (Icons.restaurant_outlined, '🍽', isAr ? 'تغيّر الشهية' : 'Appetite changes',
                isAr
                    ? 'الوجبات الصغيرة المتكررة أسهل على جسمكِ.'
                    : 'Small frequent meals are easier on your body.'),
          ]
        : [
            (Icons.battery_0_bar, '⚡', 'Fatigue',
                'Usually peaks Days 7–9. Rest as much as you need today.'),
            (Icons.sick_outlined, '🤢', 'Nausea',
                'Take anti-nausea medication regularly, even when feeling okay.'),
            (Icons.face_outlined, '💇', 'Hair loss',
                'Usually begins 2–3 weeks after treatment starts.'),
            (Icons.restaurant_outlined, '🍽', 'Appetite changes',
                'Small frequent meals are easier on your body.'),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'ما الذي قد تشعرين به الآن' : 'What you may feel right now',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ...symptoms.map((s) => _SymptomCard(
              icon: s.$1,
              emoji: s.$2,
              title: s.$3,
              desc: s.$4,
            )),
      ],
    );
  }
}

class _SymptomCard extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String title;
  final String desc;
  const _SymptomCard(
      {required this.icon,
      required this.emoji,
      required this.title,
      required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Center(child: Icon(icon, color: AppColors.primary, size: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(desc,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section 3 — When to worry ─────────────────────────────────────────────────
class _WhenToWorrySection extends StatelessWidget {
  final bool isAr;
  const _WhenToWorrySection({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final rows = isAr
        ? ['درجة حرارة فوق ٣٨°', 'ألم شديد مفاجئ', 'صعوبة في التنفس']
        : ['Fever above 38°', 'Sudden severe pain', 'Difficulty breathing'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.phone_outlined, color: AppColors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              isAr ? 'متى تتواصلين مع فريقكِ' : 'When to contact your care team',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Column(
            children: [
              ...rows.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(r,
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: AppColors.textPrimary))),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.amber, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 8, color: AppColors.border),
              const SizedBox(height: 8),
              Text(
                isAr
                    ? 'إذا ظهر أيٌّ من هذه الأعراض، تواصلي مع فريقكِ فوراً. لا تنتظري موعدكِ القادم.'
                    : 'If any of these appear, contact your care team immediately. Do not wait for your next appointment.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.amberDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Section 4 — What comes next ───────────────────────────────────────────────
class _WhatComesNextSection extends StatelessWidget {
  final bool isAr;
  const _WhatComesNextSection({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: isAr
              ? BorderSide.none
              : const BorderSide(color: AppColors.teal, width: 4),
          right: isAr
              ? const BorderSide(color: AppColors.teal, width: 4)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'بعد نافذة النادير' : 'After the nadir window',
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.teal),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? 'بعد اليوم ١٤ يبدأ جهازكِ المناعي بالتعافي. تعود الطاقة عادةً في الأيام ١٦-١٨. أنتِ تقتربين من النهاية.'
                : 'After Day 14 your immune system begins recovering. Energy usually returns around Days 16–18. You are nearly there.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
