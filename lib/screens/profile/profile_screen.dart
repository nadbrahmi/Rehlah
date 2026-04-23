import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isArabic = provider.isArabic;
      final l = AppLocalizations(isArabic: isArabic);
      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: Icon(
                isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(l.profileTitle,
                style: GoogleFonts.almarai(
                    fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            children: [
              // Completion card
              _CompletionCard(provider: provider, l: l),
              const SizedBox(height: 16),

              // Stats row
              _StatsRow(l: l),
              const SizedBox(height: 20),

              // Personal info
              _SectionHeader(isArabic ? 'ملفّكِ الشخصي' : 'Personal Info'),
              _EditableSection(rows: [
                (isArabic ? 'الاسم' : 'Name', provider.userFullName),
                (l.profileCancerType, provider.cancerType),
                (l.profileStage, provider.diseaseStage),
              ]),
              const SizedBox(height: 12),
              // Missing fields — tappable Add rows
              _MissingFieldsSection(
                isArabic: isArabic,
                fields: [
                  (isArabic ? 'تاريخ التشخيص' : 'Diagnosis date'),
                  (isArabic ? 'تاريخ بدء العلاج' : 'Treatment start date'),
                  (isArabic ? 'مرحلة السرطان' : 'Cancer stage'),
                ],
              ),
              const SizedBox(height: 20),

              // Treatment journey
              _SectionHeader(isArabic ? 'رحلتكِ العلاجية' : 'Treatment Journey'),
              _TreatmentSection(provider: provider, l: l),
              const SizedBox(height: 20),

              // Settings
              _SectionHeader(l.profileSettings),
              _SettingsSection(provider: provider, l: l),
              const SizedBox(height: 20),

              // Privacy
              _SectionHeader(l.profilePrivacy),
              _PrivacySection(l: l, isArabic: isArabic),
              const SizedBox(height: 24),

              // Trust badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isArabic
                      ? 'بياناتكِ مشفّرة ومتوافقة مع لوائح هيئة الصحة — أبوظبي'
                      : 'Your data is encrypted and compliant with UAE Health Authority regulations.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _CompletionCard extends StatelessWidget {
  final AppProvider provider;
  final AppLocalizations l;
  const _CompletionCard({required this.provider, required this.l});

  @override
  Widget build(BuildContext context) {
    final isArabic = provider.isArabic;
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                child: Text(
                  provider.userName.isNotEmpty ? provider.userName[0] : 'أ',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.userFullName,
                        style: GoogleFonts.almarai(
                            fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('${provider.cancerType} · ${provider.treatmentPhaseLabel}',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'أضيفي المزيد لنقدّم دعماً أدق لكِ' : 'Add more for personalised support',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(isArabic ? '٦٠٪ مكتمل' : '60% complete',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppLocalizations l;
  const _StatsRow({required this.l});

  @override
  Widget build(BuildContext context) {
    final isArabic = l.isArabic;
    return Row(
      children: [
        _StatCard(isArabic ? '١٤' : '14', l.profileCheckIns, AppColors.primary),
        const SizedBox(width: 10),
        // Med Rate shown as '--' per spec
        _StatCard('--', isArabic ? 'نسبة الأدوية' : 'Med Rate', AppColors.amber),
        const SizedBox(width: 10),
        _StatCard(isArabic ? '٨' : '8', l.profileDaysTracked, AppColors.teal),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: cardDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.almarai(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Missing Fields Section ────────────────────────────────────────────────────
class _MissingFieldsSection extends StatelessWidget {
  final bool isArabic;
  final List<String> fields;
  const _MissingFieldsSection({required this.isArabic, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: List.generate(fields.length, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fields[i],
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      isArabic ? 'أضيفي ←' : 'Add →',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              if (i < fields.length - 1)
                const Divider(height: 1, indent: 16, color: AppColors.border),
            ],
          );
        }),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: GoogleFonts.almarai(
              fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    );
  }
}

class _EditableSection extends StatelessWidget {
  final List<(String, String)> rows;
  const _EditableSection({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.$1,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(row.$2,
                              style: GoogleFonts.inter(
                                  fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
              if (i < rows.length - 1)
                const Divider(height: 1, indent: 16, color: AppColors.border),
            ],
          );
        }),
      ),
    );
  }
}

class _TreatmentSection extends StatefulWidget {
  final AppProvider provider;
  final AppLocalizations l;
  const _TreatmentSection({required this.provider, required this.l});

  @override
  State<_TreatmentSection> createState() => _TreatmentSectionState();
}

class _TreatmentSectionState extends State<_TreatmentSection> {
  bool _showBanner = false;

  void _editPhase() {
    final isArabic = widget.provider.isArabic;
    final phases = isArabic
        ? ['العلاج الكيميائي', 'العلاج المناعي', 'التعافي', 'مرحلة ما بعد العلاج']
        : ['Chemotherapy', 'Immunotherapy', 'Recovery', 'Post-treatment'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'تعديل مرحلة العلاج' : 'Edit treatment phase',
                style: GoogleFonts.almarai(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...phases.map((p) => ListTile(
                    title: Text(p, style: GoogleFonts.inter(fontSize: 15)),
                    trailing: widget.provider.treatmentPhaseLabel == p
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      widget.provider.updateTreatmentPhase(p);
                      Navigator.pop(context);
                      setState(() => _showBanner = true);
                      Future.delayed(const Duration(seconds: 5), () {
                        if (mounted) setState(() => _showBanner = false);
                      });
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final l = widget.l;
    final isArabic = provider.isArabic;
    final rows = [
      (l.profilePhase, provider.treatmentPhaseLabel),
      (isArabic ? 'نوع العلاج' : 'Treatment type', provider.treatmentTypeLabel),
      (isArabic ? 'تاريخ البدء' : 'Start date', provider.treatmentStartDate != null
          ? '${provider.treatmentStartDate!.month}/${provider.treatmentStartDate!.year}'
          : (isArabic ? 'يناير ٢٠٢٦' : 'January 2026')),
      (isArabic ? 'الدورة الحالية' : 'Current cycle',
          isArabic ? 'الدورة ${provider.currentCycle}' : 'Cycle ${provider.currentCycle}'),
      (l.profileDiagDate, provider.diagnosisDate != null
          ? '${provider.diagnosisDate!.month}/${provider.diagnosisDate!.year}'
          : (isArabic ? 'أكتوبر ٢٠٢٥' : 'October 2025')),
    ];

    return Column(
      children: [
        if (_showBanner)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.teal, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.provider.isArabic
                      ? 'تم تحديث مرحلة العلاج ✓'
                      : 'Treatment phase updated ✓',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.teal),
                ),
              ],
            ),
          ),
        Container(
          decoration: cardDecoration(),
          child: Column(
            children: List.generate(rows.length, (i) {
              final row = rows[i];
              return Column(
                children: [
                  InkWell(
                    onTap: i == 0 ? _editPhase : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(row.$1,
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(row.$2,
                                    style: GoogleFonts.inter(
                                        fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  if (i < rows.length - 1)
                    const Divider(height: 1, indent: 16, color: AppColors.border),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatefulWidget {
  final AppProvider provider;
  final AppLocalizations l;
  const _SettingsSection({required this.provider, required this.l});

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final provider = widget.provider;
    final isArabic = provider.isArabic;
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          // Language toggle row
          InkWell(
            onTap: () {
              provider.setLanguage(!isArabic);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Text('🌐', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l.profileLanguage,
                        style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary)),
                  ),
                  // Language pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isArabic ? '🇦🇪 العربية' : '🇬🇧 English',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.swap_horiz, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Text('🔤', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l.profileFontSize,
                      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary)),
                ),
                Icon(
                  isArabic ? Icons.chevron_left : Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('🔔', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l.profileNotifications,
                      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary)),
                ),
                Switch(
                  value: _notificationsOn,
                  onChanged: (v) => setState(() => _notificationsOn = v),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final AppLocalizations l;
  final bool isArabic;
  const _PrivacySection({required this.l, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final chevron = isArabic ? Icons.chevron_left : Icons.chevron_right;
    return Container(
      decoration: cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              isArabic
                  ? 'بياناتكِ محمية وفق لوائح هيئة الصحة — أبوظبي'
                  : 'Your data is protected under UAE Health Authority regulations.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          const Divider(height: 1, indent: 16, color: AppColors.border),
          _privacyRow(l.profileExportData, false, context, chevron),
          const Divider(height: 1, indent: 16, color: AppColors.border),
          _privacyRow(isArabic ? 'حذف الحساب' : 'Delete account', true, context, chevron),
          const Divider(height: 1, indent: 16, color: AppColors.border),
          Center(
            child: TextButton(
              onPressed: () => _confirmAction(
                context,
                isArabic ? 'إعادة ضبط التطبيق' : 'Reset app',
                isArabic ? 'إعادة' : 'reset',
                false,
              ),
              child: Text(
                isArabic ? 'إعادة ضبط التطبيق' : 'Reset app',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyRow(
      String label, bool isDestructive, BuildContext context, IconData chevron) {
    return InkWell(
      onTap: () => _confirmAction(
        context,
        label,
        isDestructive ? (isArabic ? 'حذف' : 'delete') : (isArabic ? 'تصدير' : 'export'),
        isDestructive,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDestructive ? AppColors.emergencyRed : AppColors.textPrimary)),
            const Spacer(),
            Icon(chevron,
                color: isDestructive ? AppColors.emergencyRed : AppColors.textSecondary,
                size: 18),
          ],
        ),
      ),
    );
  }

  void _confirmAction(
      BuildContext context, String title, String keyword, bool isDestructive) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title:
              Text(title, style: GoogleFonts.almarai(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'اكتبي "$keyword" للتأكيد' : 'Type "$keyword" to confirm',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: keyword,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.profileCancel,
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDestructive ? AppColors.emergencyRed : AppColors.primary),
              onPressed: () {
                if (ctrl.text.trim() == keyword) Navigator.pop(context);
              },
              child: Text(isArabic ? 'تأكيد' : 'Confirm',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
