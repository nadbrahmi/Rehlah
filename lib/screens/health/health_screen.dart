import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import '../main_screen.dart';
// cycle strip defined locally

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final l = AppLocalizations(isArabic: provider.isArabic);
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: ScreenHeader(title: l.tabHealth)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (provider.isChemoUser) ...[
                      _PhaseCard(provider: provider),
                      const SizedBox(height: 16),
                      if (provider.isNadirWindow) ...[
                        _NadirAlertCard(isArabic: provider.isArabic),
                        const SizedBox(height: 16),
                      ],
                      _SymptomsSection(isArabic: provider.isArabic),
                      const SizedBox(height: 16),
                      _ContactSection(isArabic: provider.isArabic),
                    ] else ...[
                      _NonChemoPhaseCard(provider: provider),
                      const SizedBox(height: 16),
                      _FeedbackCard(isArabic: provider.isArabic),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        l.healthDisclaimer,
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

class _PhaseCard extends StatelessWidget {
  final AppProvider provider;
  const _PhaseCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(provider.isArabic ? 'مرحلتكِ الحالية' : 'Your current phase',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(provider.treatmentPhaseLabel,
              style: GoogleFonts.almarai(
                  fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(provider.isArabic
              ? 'الدورة ${provider.currentCycle} · اليوم ${provider.currentDay} من ${provider.totalDays} · ${provider.cancerType}'
              : 'Cycle ${provider.currentCycle} · Day ${provider.currentDay} of ${provider.totalDays} · ${provider.cancerType}',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Text(provider.isArabic ? 'أين أنتِ في دورتكِ' : 'Where you are in your cycle',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          _HealthCycleStrip(
              currentDay: provider.currentDay, totalDays: provider.totalDays),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendItem(color: AppColors.teal, label: provider.isArabic ? 'مكتمل' : 'Done'),
              _LegendItem(color: AppColors.primary, label: provider.isArabic ? 'اليوم' : 'Today'),
              _LegendItem(color: AppColors.amber, label: provider.isArabic ? 'ذروة' : 'Nadir'),
              _LegendItem(color: AppColors.border, label: provider.isArabic ? 'قادم' : 'Upcoming'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthCycleStrip extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  const _HealthCycleStrip({required this.currentDay, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalDays, (i) {
        final day = i + 1;
        Color color;
        double size;
        if (day < currentDay) {
          color = AppColors.teal; size = 8;
        } else if (day == currentDay) {
          color = AppColors.primary; size = 12;
        } else if (day >= 8 && day <= 14) {
          color = AppColors.amber; size = 8;
        } else {
          color = AppColors.border; size = 8;
        }
        return Expanded(
          child: Center(
            child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ),
        );
      }),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _NadirAlertCard extends StatelessWidget {
  final bool isArabic;
  const _NadirAlertCard({this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: isArabic ? const BorderSide(color: AppColors.amber, width: 4) : BorderSide.none,
          left: isArabic ? BorderSide.none : const BorderSide(color: AppColors.amber, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isArabic
                  ? 'أنتِ تقتربين من نافذة الذروة — الأيام ٨ إلى ١٤. جهازكِ المناعي في أدنى مستوياته. راقبي درجة حرارتكِ.'
                  : 'You are approaching your nadir window — days 8 to 14. Your immune system is at its lowest. Monitor your temperature.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.amberDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomsSection extends StatelessWidget {
  final bool isArabic;
  const _SymptomsSection({this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    final symptoms = isArabic
        ? [
            ('الإرهاق', 'غالباً ما يبلغ ذروته في الأيام ٣ إلى ٧ بعد كل جرعة.'),
            ('الغثيان', 'مضادات الغثيان تساعد عند تناولها بانتظام.'),
            ('تساقط الشعر', 'يبدأ عادةً بعد ٢ إلى ٣ أسابيع من بدء العلاج.'),
            ('تغيّر الشهية', 'وجبات صغيرة متكررة أسهل على الجسم.'),
          ]
        : [
            ('Fatigue', 'Usually peaks on days 3–7 after each dose.'),
            ('Nausea', 'Anti-nausea medications help when taken regularly.'),
            ('Hair loss', 'Usually begins 2–3 weeks after starting treatment.'),
            ('Appetite changes', 'Small, frequent meals are easier on the body.'),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            isArabic ? 'ما الذي قد تشعرين به' : 'What you may be feeling',
            style: GoogleFonts.almarai(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...symptoms.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: cardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(s.$2,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            )),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  final bool isArabic;
  const _ContactSection({this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    final items = isArabic
        ? ['درجة حرارة فوق ٣٨°', 'ألم شديد مفاجئ', 'صعوبة في التنفس']
        : ['Temperature above 38°C', 'Sudden severe pain', 'Difficulty breathing'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            isArabic ? 'متى تتواصلين مع فريقكِ' : 'When to contact your team',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.amberLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items.map((t) => _ContactRow(t)).toList(),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String text;
  const _ContactRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(text, style: GoogleFonts.inter(fontSize: 14, color: AppColors.amberDark)),
        ],
      ),
    );
  }
}

class _NonChemoPhaseCard extends StatelessWidget {
  final AppProvider provider;
  const _NonChemoPhaseCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isAr = provider.isArabic;
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAr ? 'مرحلتكِ الحالية' : 'Your current phase',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(provider.treatmentPhaseLabel,
              style: GoogleFonts.almarai(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(isAr
              ? 'فريقكِ الطبي سيرشدكِ في هذه المرحلة. رحلة يُسر هنا لدعمكِ.'
              : 'Your medical team will guide you through this phase. Rehlah is here to support you.',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatefulWidget {
  final bool isArabic;
  const _FeedbackCard({this.isArabic = true});

  @override
  State<_FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<_FeedbackCard> {
  final _ctrl = TextEditingController();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isAr ? 'ما الذي تودّين رؤيته هنا؟' : 'What would you like to see here?',
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (_sent)
            Text(isAr ? 'شكراً لمشاركتكِ! 💜' : 'Thank you for sharing! 💜', style: GoogleFonts.inter(fontSize: 14, color: AppColors.teal))
          else ...[
            TextField(
              controller: _ctrl,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: isAr ? 'شاركيني أفكارك...' : 'Share your thoughts...',
                hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _sent = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: Text(isAr ? 'أرسلي' : 'Send', style: GoogleFonts.almarai(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }
}
