import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import '../main_screen.dart';
import '../yusr/yusr_overlay.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CARE SCREEN  (root)
// ─────────────────────────────────────────────────────────────────────────────
class CareScreen extends StatelessWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final l = AppLocalizations(isArabic: provider.isArabic);
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(title: l.tabCare),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _SegmentedControl(
                  labels: [l.careMeds, l.careAppts, l.careLabs],
                  selected: provider.careTabIndex,
                  onChanged: provider.setCareTab,
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: provider.careTabIndex,
                  children: const [
                    _MedicationsTab(),
                    _AppointmentsTab(),
                    _LabsTab(),
                  ],
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
//  Segmented control — pill style, premium
// ─────────────────────────────────────────────────────────────────────────────
class _SegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const _SegmentedControl(
      {required this.labels, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ]
                      : [],
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.primary : AppColors.textSecondary,
                    letterSpacing: active ? 0.1 : 0,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MEDICATIONS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _MedicationsTab extends StatefulWidget {
  const _MedicationsTab();
  @override
  State<_MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends State<_MedicationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this);
    _tc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      final daily = provider.medications.where((m) => !m.isAsNeeded).toList();
      final asNeeded = provider.medications.where((m) => m.isAsNeeded).toList();
      final takenCount = daily.where((m) => m.isTaken).length;
      final totalDaily = daily.length;
      final adherencePct =
          totalDaily == 0 ? 0 : (takenCount / totalDaily * 100).round();

      return Column(
        children: [
          // ── Header card ─────────────────────────────────────────────────
          _CareHeader(
            title: isAr ? 'الأدوية والجرعات' : 'Medications',
            subtitle: isAr
                ? 'تتبّعي جرعاتكِ اليومية'
                : 'Track your daily doses',
            icon: Icons.medication_rounded,
            child: _MedHeaderStats(
              takenCount: takenCount,
              totalDaily: totalDaily,
              adherencePct: adherencePct,
              isAr: isAr,
            ),
          ),
          // ── Sub-tabs ─────────────────────────────────────────────────────
          _SubTabBar(
            controller: _tc,
            tabs: [
              isAr ? 'جرعات اليوم' : "Today's Doses",
              isAr ? 'أدويتي' : 'My Medications',
            ],
          ),
          // ── Tab views ────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                // Today's Doses
                _MedTodayView(
                  daily: daily,
                  asNeeded: asNeeded,
                  takenCount: takenCount,
                  totalDaily: totalDaily,
                  isAr: isAr,
                  onAddMed: () => _showAddMedDialog(context, isAr),
                ),
                // All Medications
                _MedAllView(
                  medications: provider.medications,
                  isAr: isAr,
                  onAddMed: () => _showAddMedDialog(context, isAr),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showAddMedDialog(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: _AddMedSheet(),
      ),
    );
  }
}

// Medications header stats row
class _MedHeaderStats extends StatelessWidget {
  final int takenCount;
  final int totalDaily;
  final int adherencePct;
  final bool isAr;
  const _MedHeaderStats({
    required this.takenCount,
    required this.totalDaily,
    required this.adherencePct,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderStat(
          value: '$takenCount/$totalDaily',
          label: isAr ? 'مأخوذة اليوم' : 'Taken today',
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF86EFAC),
        ),
        const SizedBox(width: 10),
        _HeaderStat(
          value: '$adherencePct%',
          label: isAr ? 'الالتزام' : 'Adherence',
          icon: Icons.trending_up_rounded,
          iconColor: const Color(0xFFC4B5FD),
        ),
        const SizedBox(width: 10),
        _HeaderStat(
          value: '${totalDaily - takenCount}',
          label: isAr ? 'متبقية' : 'Remaining',
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFFFDE68A),
        ),
      ],
    );
  }
}

// Today's doses view
class _MedTodayView extends StatelessWidget {
  final List<Medication> daily;
  final List<Medication> asNeeded;
  final int takenCount;
  final int totalDaily;
  final bool isAr;
  final VoidCallback onAddMed;

  const _MedTodayView({
    required this.daily,
    required this.asNeeded,
    required this.takenCount,
    required this.totalDaily,
    required this.isAr,
    required this.onAddMed,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final pending = totalDaily - takenCount;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // Adherence banner
            if (pending > 0 && totalDaily > 0) ...[
              _DoseReminderBanner(pending: pending, isAr: isAr),
              const SizedBox(height: 12),
            ],
            if (daily.isEmpty && asNeeded.isEmpty)
              _EmptyState(
                icon: Icons.medication_outlined,
                heading: isAr ? 'لم تُضيفي أي دواء بعد' : 'No medications yet',
                subtext: isAr
                    ? 'أضيفي أدويتكِ لتتبّع جرعاتكِ بسهولة.'
                    : 'Add your medications to easily track your doses.',
                buttonLabel: isAr ? 'أضيفي دواءً' : 'Add medication',
                onTap: onAddMed,
              )
            else ...[
              if (daily.isNotEmpty) ...[
                _SectionHeader(
                  isAr ? 'الجرعات اليومية' : 'Daily doses',
                  trailing: '$takenCount/$totalDaily ${isAr ? "مأخوذة" : "taken"}',
                ),
                const SizedBox(height: 8),
                ...daily.map((m) => _MedCard(
                      med: m,
                      onTake: m.isTaken ? null : () => provider.takeMedication(m.id),
                      isArabic: isAr,
                    )),
              ],
              if (asNeeded.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SectionHeader(
                  isAr ? 'عند الحاجة' : 'As needed',
                ),
                const SizedBox(height: 8),
                ...asNeeded.map((m) => _MedCard(
                      med: m,
                      onTake: null,
                      isArabic: isAr,
                    )),
              ],
            ],
          ],
        ),
        Positioned(
          bottom: 24,
          right: 20,
          child: _FAB(
            label: isAr ? 'إضافة دواء' : 'Add Medication',
            onTap: onAddMed,
          ),
        ),
      ],
    );
  }
}

// All medications view
class _MedAllView extends StatelessWidget {
  final List<Medication> medications;
  final bool isAr;
  final VoidCallback onAddMed;

  const _MedAllView({
    required this.medications,
    required this.isAr,
    required this.onAddMed,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            if (medications.isEmpty)
              _EmptyState(
                icon: Icons.medication_outlined,
                heading: isAr ? 'لم تُضيفي أي دواء بعد' : 'No medications yet',
                subtext: isAr
                    ? 'أضيفي أدويتكِ لتتبّع جرعاتكِ.'
                    : 'Add your medications to track your doses.',
                buttonLabel: isAr ? 'أضيفي دواءً' : 'Add medication',
                onTap: onAddMed,
              )
            else
              ...medications.map((m) => _MedCard(
                    med: m,
                    onTake: m.isAsNeeded || m.isTaken
                        ? null
                        : () => provider.takeMedication(m.id),
                    isArabic: isAr,
                  )),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 20,
          child: _FAB(
            label: isAr ? 'إضافة دواء' : 'Add Medication',
            onTap: onAddMed,
          ),
        ),
      ],
    );
  }
}

// Dose reminder banner
class _DoseReminderBanner extends StatelessWidget {
  final int pending;
  final bool isAr;
  const _DoseReminderBanner({required this.pending, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_active_rounded,
                size: 18, color: Color(0xFF92400E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isAr
                  ? 'لديكِ $pending جرعة متبقية اليوم'
                  : 'You have $pending dose${pending > 1 ? 's' : ''} remaining today',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Medication card — premium clinical design
class _MedCard extends StatelessWidget {
  final Medication med;
  final VoidCallback? onTake;
  final bool isArabic;
  const _MedCard({required this.med, required this.onTake, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    final isTaken = med.isTaken;
    final isAsNeeded = med.isAsNeeded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTaken
              ? AppColors.tealBorder
              : isAsNeeded
                  ? AppColors.primaryBorder.withValues(alpha: 0.5)
                  : AppColors.border,
          width: 1,
        ),
        boxShadow: shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isTaken
                        ? AppColors.tealLight
                        : isAsNeeded
                            ? AppColors.primaryLight
                            : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isTaken
                        ? Icons.check_circle_rounded
                        : Icons.medication_rounded,
                    size: 22,
                    color: isTaken ? AppColors.teal : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${med.dose} · ${med.frequency}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _MedStatusBadge(med: med),
              ],
            ),
            // Time row
            if (med.time.isNotEmpty && !isAsNeeded) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 5),
                  Text(
                    med.time,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  if (isTaken && med.takenAt != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'أُخذ الساعة ${med.takenAt}' : 'Taken at ${med.takenAt}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            // Take button
            if (!isAsNeeded && !isTaken && onTake != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: onTake,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    isArabic ? 'تأكيد الأخذ' : 'Mark as taken',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    minimumSize: const Size(0, 42),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MedStatusBadge extends StatelessWidget {
  final Medication med;
  const _MedStatusBadge({required this.med});

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<AppProvider>().isArabic;
    String label;
    Color bg, fg;
    if (med.isAsNeeded) {
      label = isAr ? 'عند الحاجة' : 'PRN';
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
    } else if (med.isTaken) {
      label = isAr ? 'تم ✓' : 'Taken ✓';
      bg = AppColors.tealLight;
      fg = AppColors.teal;
    } else {
      label = isAr ? 'بانتظار' : 'Pending';
      bg = AppColors.amberLight;
      fg = AppColors.amber;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _AddMedSheet extends StatefulWidget {
  @override
  State<_AddMedSheet> createState() => _AddMedSheetState();
}

class _AddMedSheetState extends State<_AddMedSheet> {
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  int _freqIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<AppProvider>().isArabic;
    final freqLabels = isAr
        ? ['مرة يومياً', 'مرتين يومياً', 'عند الحاجة']
        : ['Once daily', 'Twice daily', 'As needed'];
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? 'إضافة دواء جديد' : 'Add Medication',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _SheetField(
              controller: _nameCtrl,
              label: isAr ? 'اسم الدواء' : 'Medication name',
              hint: 'Tamoxifen',
              isArabic: isAr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SheetField(
                    controller: _doseCtrl,
                    label: isAr ? 'الجرعة' : 'Dose',
                    hint: '20mg',
                    isArabic: isAr),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SheetField(
                    controller: _timeCtrl,
                    label: isAr ? 'الوقت' : 'Time',
                    hint: '08:00',
                    isArabic: isAr),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isAr ? 'التكرار' : 'Frequency',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              freqLabels.length,
              (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _freqIndex = i),
                  child: Container(
                    margin: EdgeInsets.only(right: i < freqLabels.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _freqIndex == i
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _freqIndex == i
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      freqLabels[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _freqIndex == i
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    isAr ? 'إلغاء' : 'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty) return;
                    context.read<AppProvider>().addMedication(Medication(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameCtrl.text.trim(),
                          dose: _doseCtrl.text.trim(),
                          frequency: freqLabels[_freqIndex],
                          time: _timeCtrl.text.trim(),
                          isAsNeeded: _freqIndex == 2,
                        ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isAr ? 'إضافة الدواء' : 'Add Medication',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  APPOINTMENTS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab();
  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this);
    _tc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      final now = DateTime.now();
      final upcoming = provider.appointments
          .where((a) => a.dateTime.isAfter(now) || _isSameDay(a.dateTime, now))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      final past = provider.appointments
          .where((a) => a.dateTime.isBefore(now) && !_isSameDay(a.dateTime, now))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _CareHeader(
            title: isAr ? 'مواعيدي الطبية' : 'Appointments',
            subtitle: isAr
                ? 'جدولكِ مع الفريق الطبي'
                : 'Your medical schedule',
            icon: Icons.calendar_month_rounded,
            child: _ApptHeaderStats(
              upcoming: upcoming,
              isAr: isAr,
              now: now,
            ),
          ),
          // ── Sub-tabs ─────────────────────────────────────────────────────
          _SubTabBar(
            controller: _tc,
            tabs: [
              isAr ? 'القادمة' : 'Upcoming',
              isAr ? 'السابقة' : 'Past',
            ],
          ),
          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                // Upcoming
                Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      children: [
                        // Next appointment banner
                        if (upcoming.isNotEmpty) ...[
                          _NextApptBanner(
                              appt: upcoming.first, now: now, isAr: isAr),
                          const SizedBox(height: 12),
                        ],
                        if (upcoming.isEmpty)
                          _EmptyState(
                            icon: Icons.calendar_today_rounded,
                            heading: isAr
                                ? 'لا مواعيد قادمة'
                                : 'No upcoming appointments',
                            subtext: isAr
                                ? 'أضيفي مواعيدكِ الطبية لمتابعة جدولكِ.'
                                : 'Add your medical appointments to stay on track.',
                            buttonLabel:
                                isAr ? 'أضيفي موعداً' : 'Add appointment',
                            onTap: () => _showAddApptDialog(context, isAr),
                          )
                        else
                          ...upcoming.map((appt) =>
                              _ApptCard(appt: appt, isAr: isAr, now: now)),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 20,
                      child: _FAB(
                        label: isAr ? 'إضافة موعد' : 'Add Appointment',
                        onTap: () => _showAddApptDialog(context, isAr),
                      ),
                    ),
                  ],
                ),
                // Past
                Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      children: [
                        if (past.isEmpty)
                          _EmptyState(
                            icon: Icons.history_rounded,
                            heading: isAr
                                ? 'لا مواعيد سابقة'
                                : 'No past appointments',
                            subtext: isAr
                                ? 'ستظهر مواعيدكِ المنتهية هنا.'
                                : 'Your completed appointments will appear here.',
                            buttonLabel: isAr ? 'أضيفي موعداً' : 'Add',
                            onTap: () => _showAddApptDialog(context, isAr),
                          )
                        else
                          ...past.map((appt) => _ApptCard(
                              appt: appt, isAr: isAr, now: now, isPast: true)),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 20,
                      child: _FAB(
                        label: isAr ? 'إضافة موعد' : 'Add Appointment',
                        onTap: () => _showAddApptDialog(context, isAr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showAddApptDialog(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: _AddApptSheet(isArabic: isArabic),
      ),
    );
  }
}

// Appointments header stats
class _ApptHeaderStats extends StatelessWidget {
  final List<Appointment> upcoming;
  final bool isAr;
  final DateTime now;

  const _ApptHeaderStats({
    required this.upcoming,
    required this.isAr,
    required this.now,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final todayCount = upcoming.where((a) => _isSameDay(a.dateTime, now)).length;
    final next = upcoming.isNotEmpty ? upcoming.first : null;
    final daysToNext = next != null && !_isSameDay(next.dateTime, now)
        ? next.dateTime.difference(now).inDays
        : 0;

    return Row(
      children: [
        _HeaderStat(
          value: '${upcoming.length}',
          label: isAr ? 'قادمة' : 'Upcoming',
          icon: Icons.calendar_today_rounded,
          iconColor: const Color(0xFFC4B5FD),
        ),
        const SizedBox(width: 10),
        _HeaderStat(
          value: '$todayCount',
          label: isAr ? 'اليوم' : 'Today',
          icon: Icons.today_rounded,
          iconColor: const Color(0xFFFCA5A5),
        ),
        const SizedBox(width: 10),
        _HeaderStat(
          value: next != null
              ? (_isSameDay(next.dateTime, now)
                  ? (isAr ? 'اليوم' : 'Today')
                  : '$daysToNext${isAr ? " أيام" : "d"}')
              : '—',
          label: isAr ? 'القادم' : 'Next in',
          icon: Icons.arrow_circle_right_rounded,
          iconColor: const Color(0xFF86EFAC),
        ),
      ],
    );
  }
}

// Next appointment banner
class _NextApptBanner extends StatelessWidget {
  final Appointment appt;
  final DateTime now;
  final bool isAr;
  const _NextApptBanner(
      {required this.appt, required this.now, required this.isAr});

  bool get _isToday =>
      appt.dateTime.year == now.year &&
      appt.dateTime.month == now.month &&
      appt.dateTime.day == now.day;

  @override
  Widget build(BuildContext context) {
    final diff = appt.dateTime.difference(now).inDays;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isToday
                      ? (isAr ? 'موعد اليوم' : 'Today\'s appointment')
                      : (isAr
                          ? 'الموعد القادم بعد $diff ${diff == 1 ? "يوم" : "أيام"}'
                          : 'Next appointment in $diff day${diff != 1 ? "s" : ""}'),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  appt.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  appt.doctor,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_isToday)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAr ? 'اليوم' : 'TODAY',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Appointment card — clinical, professional
class _ApptCard extends StatelessWidget {
  final Appointment appt;
  final bool isAr;
  final DateTime now;
  final bool isPast;
  const _ApptCard(
      {required this.appt,
      required this.isAr,
      required this.now,
      this.isPast = false});

  static const _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];
  static const _enMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  bool get _isToday =>
      appt.dateTime.year == now.year &&
      appt.dateTime.month == now.month &&
      appt.dateTime.day == now.day;

  @override
  Widget build(BuildContext context) {
    final diff = appt.dateTime.difference(now).inDays;
    final monthName =
        isAr ? _arMonths[appt.dateTime.month - 1] : _enMonths[appt.dateTime.month - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isToday
              ? AppColors.emergencyRed.withValues(alpha: 0.3)
              : isPast
                  ? AppColors.tealBorder.withValues(alpha: 0.5)
                  : AppColors.border,
          width: 1,
        ),
        boxShadow: shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar date block
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: _isToday
                        ? AppColors.redLight
                        : isPast
                            ? AppColors.tealLight
                            : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isToday
                          ? AppColors.redBorder
                          : isPast
                              ? AppColors.tealBorder
                              : AppColors.primaryBorder,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        monthName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _isToday
                              ? AppColors.emergencyRed
                              : isPast
                                  ? AppColors.teal
                                  : AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        '${appt.dateTime.day}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _isToday
                              ? AppColors.emergencyRed
                              : isPast
                                  ? AppColors.teal
                                  : AppColors.primary,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        '${appt.dateTime.year}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              appt.title,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!isPast && !_isToday && diff >= 0)
                            _DaysBadge(days: diff, isAr: isAr),
                          if (_isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.emergencyRed,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isAr ? 'اليوم' : 'TODAY',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (isPast)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tealLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppColors.tealBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded,
                                      size: 11, color: AppColors.teal),
                                  const SizedBox(width: 3),
                                  Text(
                                    isAr ? 'مكتمل' : 'Done',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 13,
                              color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appt.doctor,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 13,
                              color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${appt.dateTime.hour.toString().padLeft(2, '0')}:${appt.dateTime.minute.toString().padLeft(2, '0')}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Prep button for upcoming
            if (!isPast) ...[
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: AppColors.borderLight,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OutlineButton(
                      icon: Icons.auto_awesome_rounded,
                      label: isAr ? 'استعدّي للزيارة' : 'Prepare for visit',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const YusrOverlay()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DaysBadge extends StatelessWidget {
  final int days;
  final bool isAr;
  const _DaysBadge({required this.days, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Text(
        isAr ? '$days ${days == 1 ? "يوم" : "أيام"}' : '${days}d',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _AddApptSheet extends StatefulWidget {
  final bool isArabic;
  const _AddApptSheet({this.isArabic = false});
  @override
  State<_AddApptSheet> createState() => _AddApptSheetState();
}

class _AddApptSheetState extends State<_AddApptSheet> {
  final _titleCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? 'إضافة موعد جديد' : 'Add Appointment',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _SheetField(
              controller: _titleCtrl,
              label: isAr ? 'نوع الموعد' : 'Appointment type',
              hint: isAr ? 'مراجعة أورام' : 'Oncology review',
              isArabic: isAr),
          const SizedBox(height: 12),
          _SheetField(
              controller: _doctorCtrl,
              label: isAr ? 'اسم الطبيب' : 'Doctor',
              hint: isAr ? 'د. سارة شين' : 'Dr. Sarah Chen',
              isArabic: isAr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _DatePickerField(
                  date: _date,
                  isAr: isAr,
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                      builder: (ctx, child) => Directionality(
                        textDirection:
                            isAr ? TextDirection.rtl : TextDirection.ltr,
                        child: child!,
                      ),
                    );
                    if (d != null) setState(() => _date = d);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _TimePickerField(
                  time: _time,
                  isAr: isAr,
                  onTap: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t != null) setState(() => _time = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    isAr ? 'إلغاء' : 'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleCtrl.text.trim().isEmpty || _date == null) {
                      return;
                    }
                    final dt = DateTime(
                      _date!.year,
                      _date!.month,
                      _date!.day,
                      _time?.hour ?? 9,
                      _time?.minute ?? 0,
                    );
                    context.read<AppProvider>().addAppointment(Appointment(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleCtrl.text.trim(),
                          doctor: _doctorCtrl.text.trim(),
                          dateTime: dt,
                        ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isAr ? 'حفظ الموعد' : 'Save Appointment',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LABS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _LabsTab extends StatefulWidget {
  const _LabsTab();
  @override
  State<_LabsTab> createState() => _LabsTabState();
}

class _LabsTabState extends State<_LabsTab> with SingleTickerProviderStateMixin {
  late TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
    _tc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      final hasAttention = provider.labs.any((l) => l.status == 'attention');
      final criticalCount =
          provider.labs.where((l) => l.status == 'critical').length;
      final attentionCount =
          provider.labs.where((l) => l.status == 'attention').length;
      final normalCount =
          provider.labs.where((l) => l.status == 'normal').length;

      return Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _CareHeader(
            title: isAr ? 'التحاليل المخبرية' : 'Lab Results',
            subtitle: isAr
                ? 'تتبّعي نتائج تحاليلكِ'
                : 'Track your lab results',
            icon: Icons.biotech_rounded,
            child: _LabHeaderStats(
              normal: normalCount,
              attention: attentionCount,
              critical: criticalCount,
              isAr: isAr,
            ),
          ),
          // ── Alert banner ─────────────────────────────────────────────────
          if (hasAttention || criticalCount > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: _LabAlertBanner(
                  isAr: isAr,
                  isCritical: criticalCount > 0),
            ),
          if (hasAttention || criticalCount > 0) const SizedBox(height: 2),
          // ── Sub-tabs ─────────────────────────────────────────────────────
          _SubTabBar(
            controller: _tc,
            tabs: [
              isAr ? 'النتائج' : 'Results',
              isAr ? 'التحليل الذكي' : 'AI Insights',
              isAr ? 'التقارير' : 'Reports',
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                // ── Results ─────────────────────────────────────────────
                _LabResultsView(
                  labs: provider.labs,
                  isAr: isAr,
                  onAdd: () => _showAddLabDialog(context),
                ),
                // ── AI Insights ─────────────────────────────────────────
                _LabInsightsView(isAr: isAr, ctx: context),
                // ── Reports ─────────────────────────────────────────────
                _LabReportsView(isAr: isAr, onAdd: () => _showAddLabDialog(context)),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showAddLabDialog(BuildContext context) {
    final isAr = context.read<AppProvider>().isArabic;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: _AddLabSheet(isArabic: isAr),
      ),
    );
  }
}

// Lab header stats
class _LabHeaderStats extends StatelessWidget {
  final int normal;
  final int attention;
  final int critical;
  final bool isAr;
  const _LabHeaderStats({
    required this.normal,
    required this.attention,
    required this.critical,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderStat(
          value: '$normal',
          label: isAr ? 'طبيعي' : 'Normal',
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF86EFAC),
        ),
        const SizedBox(width: 10),
        _HeaderStat(
          value: '$attention',
          label: isAr ? 'تحتاج اهتماماً' : 'Attention',
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFFDE68A),
        ),
        const SizedBox(width: 10),
        _HeaderStat(
          value: '$critical',
          label: isAr ? 'حرج' : 'Critical',
          icon: Icons.error_rounded,
          iconColor: const Color(0xFFFCA5A5),
        ),
      ],
    );
  }
}

// Lab alert banner
class _LabAlertBanner extends StatelessWidget {
  final bool isAr;
  final bool isCritical;
  const _LabAlertBanner({required this.isAr, required this.isCritical});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCritical ? AppColors.redLight : AppColors.amberLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical
              ? AppColors.redBorder
              : AppColors.amberBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.error_rounded : Icons.warning_amber_rounded,
            color: isCritical ? AppColors.emergencyRed : AppColors.amber,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isCritical
                  ? (isAr
                      ? 'نتائج حرجة — تواصلي مع فريقكِ الطبي فوراً'
                      : 'Critical results — contact your care team immediately')
                  : (isAr
                      ? 'بعض نتائجكِ تستحق الانتباه — راجعي طبيبكِ'
                      : 'Some results need attention — review with your doctor'),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCritical ? AppColors.emergencyRed : AppColors.amberDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lab results view
class _LabResultsView extends StatelessWidget {
  final List<LabResult> labs;
  final bool isAr;
  final VoidCallback onAdd;
  const _LabResultsView(
      {required this.labs, required this.isAr, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            if (labs.isEmpty)
              _EmptyState(
                icon: Icons.biotech_outlined,
                heading: isAr ? 'لم تُضيفي أي تحاليل بعد' : 'No lab results yet',
                subtext: isAr
                    ? 'أضيفي نتائج تحاليلكِ لمتابعة وضعكِ الصحي.'
                    : 'Add your lab results to track your health.',
                buttonLabel: isAr ? 'أضيفي نتائج' : 'Add results',
                onTap: onAdd,
              )
            else ...[
              // Status summary card
              _LabSummaryCard(labs: labs, isAr: isAr),
              const SizedBox(height: 16),
              // Lab cards grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: labs
                    .map((lab) => _LabMetricCard(lab: lab, isAr: isAr))
                    .toList(),
              ),
              const SizedBox(height: 20),
              // When to contact section
              _WhenToContactCard(isAr: isAr),
              const SizedBox(height: 16),
              // Yusr suggestion
              _YusrCard(isAr: isAr, ctx: context),
              const SizedBox(height: 16),
              // Care team coming soon
              _CareTeamCard(isAr: isAr),
            ],
          ],
        ),
        Positioned(
          bottom: 24,
          right: 20,
          child: _FAB(
            label: isAr ? 'إضافة نتيجة' : 'Add Result',
            onTap: onAdd,
          ),
        ),
      ],
    );
  }
}

// Lab summary card
class _LabSummaryCard extends StatelessWidget {
  final List<LabResult> labs;
  final bool isAr;
  const _LabSummaryCard({required this.labs, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final hasAttention = labs.any((l) => l.status != 'normal');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasAttention ? AppColors.amberLight : AppColors.tealLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasAttention ? AppColors.amberBorder : AppColors.tealBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasAttention ? AppColors.amber : AppColors.teal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasAttention ? Icons.warning_amber_rounded : Icons.verified_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAttention
                      ? (isAr ? 'بعض النتائج تحتاج متابعة' : 'Some results need follow-up')
                      : (isAr ? 'نتائجكِ الأخيرة مستقرة' : 'Your latest results are stable'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: hasAttention ? AppColors.amberDark : AppColors.teal,
                  ),
                ),
                Text(
                  isAr ? '${labs.length} نتيجة مسجّلة' : '${labs.length} result${labs.length != 1 ? "s" : ""} recorded',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: hasAttention ? AppColors.amber : AppColors.teal,
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

// Lab metric card (grid)
class _LabMetricCard extends StatelessWidget {
  final LabResult lab;
  final bool isAr;
  const _LabMetricCard({required this.lab, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final isAttention = lab.status == 'attention';
    final isCritical = lab.status == 'critical';
    Color statusColor = isCritical
        ? AppColors.emergencyRed
        : isAttention
            ? AppColors.amber
            : AppColors.teal;
    Color statusBg = isCritical
        ? AppColors.redLight
        : isAttention
            ? AppColors.amberLight
            : AppColors.tealLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  lab.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lab.value,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          Text(
            lab.unit,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isCritical
                  ? (isAr ? 'حرج' : 'Critical')
                  : isAttention
                      ? (isAr ? 'تحتاج اهتماماً' : 'Attention')
                      : (isAr ? 'طبيعي' : 'Normal'),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// When to contact card
class _WhenToContactCard extends StatelessWidget {
  final bool isAr;
  const _WhenToContactCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final items = isAr
        ? [
            ('حمى تتجاوز ٣٨ درجة', Icons.thermostat_rounded),
            ('ألم شديد مفاجئ', Icons.warning_rounded),
            ('صعوبة في التنفس', Icons.air_rounded),
            ('نزيف أو كدمات غير مبررة', Icons.healing_rounded),
          ]
        : [
            ('Fever above 38°C', Icons.thermostat_rounded),
            ('Sudden severe pain', Icons.warning_rounded),
            ('Difficulty breathing', Icons.air_rounded),
            ('Unexplained bleeding or bruising', Icons.healing_rounded),
          ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.redLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone_in_talk_rounded,
                      size: 18, color: AppColors.emergencyRed),
                ),
                const SizedBox(width: 12),
                Text(
                  isAr ? 'متى تتصلين بالفريق الطبي' : 'When to contact your team',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.borderLight),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.redLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(item.$2,
                                  size: 15, color: AppColors.emergencyRed),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.$1,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Yusr CTA card
class _YusrCard extends StatelessWidget {
  final bool isAr;
  final BuildContext ctx;
  const _YusrCard({required this.isAr, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const YusrOverlay()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6D28D9), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'اسأل يُسر عن نتائجكِ' : 'Ask Yusr about your results',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isAr
                        ? 'غير متأكدة من نتيجة؟ يُسر تشرح لكِ بوضوح.'
                        : 'Not sure what a result means? Yusr explains it clearly.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isAr ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

// Care team coming soon
class _CareTeamCard extends StatelessWidget {
  final bool isAr;
  const _CareTeamCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        boxShadow: shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_rounded,
                size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'الفريق الطبي' : 'Care Team',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isAr
                      ? 'التواصل المباشر مع فريقكِ — قريباً'
                      : 'Direct messaging with your team — coming soon',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAr ? 'قريباً' : 'Soon',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// AI Insights view
class _LabInsightsView extends StatelessWidget {
  final bool isAr;
  final BuildContext ctx;
  const _LabInsightsView({required this.isAr, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (_, provider, __) {
      final labs = provider.labs;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // AI header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.primaryBorder, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'تحليل يُسر الذكي' : 'Yusr AI Analysis',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        isAr
                            ? 'بناءً على نتائجكِ الأخيرة'
                            : 'Based on your latest results',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (labs.isEmpty)
            _EmptyState(
              icon: Icons.insights_rounded,
              heading: isAr ? 'لا توجد نتائج بعد' : 'No results yet',
              subtext: isAr
                  ? 'أضيفي تحاليلكِ لعرض تحليل يُسر.'
                  : 'Add your lab results to see Yusr\'s analysis.',
              buttonLabel: isAr ? 'أضيفي نتائج' : 'Add results',
              onTap: () {},
            )
          else ...[
            // Insight cards
            ...labs.map((lab) => _LabInsightCard(lab: lab, isAr: isAr)),
            const SizedBox(height: 16),
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'يُسر ليست بديلاً عن طبيبكِ. استشيري دائماً فريقكِ الطبي المتخصص.'
                          : 'Yusr is not a substitute for your doctor. Always consult your medical team.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _LabInsightCard extends StatelessWidget {
  final LabResult lab;
  final bool isAr;
  const _LabInsightCard({required this.lab, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final isAttention = lab.status == 'attention';
    final isCritical = lab.status == 'critical';
    Color accent = isCritical
        ? AppColors.emergencyRed
        : isAttention
            ? AppColors.amber
            : AppColors.teal;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                lab.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${lab.value} ${lab.unit}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lab.explanation,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

// Lab reports view
class _LabReportsView extends StatelessWidget {
  final bool isAr;
  final VoidCallback onAdd;
  const _LabReportsView({required this.isAr, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            _EmptyState(
              icon: Icons.folder_open_rounded,
              heading: isAr ? 'لا تقارير مضافة' : 'No reports yet',
              subtext: isAr
                  ? 'يمكنكِ إضافة تقارير تحاليلكِ هنا لمتابعتها.'
                  : 'Upload your lab reports here for tracking.',
              buttonLabel: isAr ? 'أضيفي تقريراً' : 'Upload Report',
              onTap: onAdd,
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          right: 20,
          child: _FAB(
            label: isAr ? 'إضافة تقرير' : 'Add Report',
            onTap: onAdd,
          ),
        ),
      ],
    );
  }
}

class _AddLabSheet extends StatefulWidget {
  final bool isArabic;
  const _AddLabSheet({this.isArabic = false});
  @override
  State<_AddLabSheet> createState() => _AddLabSheetState();
}

class _AddLabSheetState extends State<_AddLabSheet> {
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  int _statusIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final statusLabels = isAr
        ? ['طبيعي', 'يحتاج اهتماماً', 'حرج']
        : ['Normal', 'Attention', 'Critical'];
    final statusValues = ['normal', 'attention', 'critical'];
    final statusColors = [AppColors.teal, AppColors.amber, AppColors.emergencyRed];

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? 'إضافة نتيجة تحليل' : 'Add Lab Result',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _SheetField(
              controller: _nameCtrl,
              label: isAr ? 'اسم التحليل' : 'Test name',
              hint: isAr ? 'الهيموغلوبين' : 'Hemoglobin',
              isArabic: isAr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _SheetField(
                    controller: _valueCtrl,
                    label: isAr ? 'النتيجة' : 'Result',
                    hint: '10.2',
                    isArabic: isAr),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SheetField(
                    controller: _unitCtrl,
                    label: isAr ? 'الوحدة' : 'Unit',
                    hint: 'g/dL',
                    isArabic: isAr),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isAr ? 'الحالة' : 'Status',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              statusLabels.length,
              (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _statusIndex = i),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: i < statusLabels.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _statusIndex == i
                          ? statusColors[i].withValues(alpha: 0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _statusIndex == i
                            ? statusColors[i]
                            : AppColors.border,
                        width: _statusIndex == i ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      statusLabels[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusIndex == i
                            ? statusColors[i]
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    isAr ? 'إلغاء' : 'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty) return;
                    context.read<AppProvider>().addLabResult(LabResult(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _nameCtrl.text.trim(),
                          value: _valueCtrl.text.trim(),
                          unit: _unitCtrl.text.trim(),
                          status: statusValues[_statusIndex],
                          explanation: '',
                        ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isAr ? 'إضافة النتيجة' : 'Add Result',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// Premium care header with gradient and stats
class _CareHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _CareHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// Header stat chip
class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 10, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-tab bar
class _SubTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  const _SubTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          TabBar(
            controller: controller,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            indicatorPadding:
                const EdgeInsets.symmetric(horizontal: 16),
            labelStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
          Container(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}

// Section header with optional trailing
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionHeader(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

// Floating action button — pill style
class _FAB extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FAB({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Outline action button
class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryBorder, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty state
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String heading;
  final String subtext;
  final String buttonLabel;
  final VoidCallback onTap;
  const _EmptyState({
    required this.icon,
    required this.heading,
    required this.subtext,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            heading,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtext,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                buttonLabel,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sheet text field
class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isArabic;
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.inter(
              fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// Date picker field
class _DatePickerField extends StatelessWidget {
  final DateTime? date;
  final bool isAr;
  final VoidCallback onTap;
  const _DatePickerField(
      {required this.date, required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'التاريخ' : 'Date',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: date != null ? AppColors.primary : AppColors.border,
                width: date != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color:
                      date != null ? AppColors.primary : AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date!.day}/${date!.month}/${date!.year}'
                      : (isAr ? 'اختاري' : 'Select'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        date != null ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Time picker field
class _TimePickerField extends StatelessWidget {
  final TimeOfDay? time;
  final bool isAr;
  final VoidCallback onTap;
  const _TimePickerField(
      {required this.time, required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'الوقت' : 'Time',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: time != null ? AppColors.primary : AppColors.border,
                width: time != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color:
                      time != null ? AppColors.primary : AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  time != null
                      ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}'
                      : (isAr ? 'الوقت' : 'Time'),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color:
                        time != null ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
