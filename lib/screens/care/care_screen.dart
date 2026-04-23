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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
//  Segmented control
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [
                          const BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 4,
                              offset: Offset(0, 1))
                        ]
                      : [],
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight:
                        active ? FontWeight.bold : FontWeight.normal,
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondary,
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
      final daily =
          provider.medications.where((m) => !m.isAsNeeded).toList();
      final asNeeded =
          provider.medications.where((m) => m.isAsNeeded).toList();
      final takenCount = daily.where((m) => m.isTaken).length;
      final totalDaily = daily.length;
      final adherencePct = totalDaily == 0
          ? 0
          : (takenCount / totalDaily * 100).round();

      return Column(
        children: [
          // ── Purple gradient header ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'الأدوية والالتزام' : 'Medications & Adherence',
                  style: GoogleFonts.almarai(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _StatChip(
                      value: '$takenCount/$totalDaily',
                      label: isAr ? 'اليوم' : 'Today',
                      icon: Icons.medication_outlined,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      value: '$adherencePct%',
                      label: isAr ? '٧ أيام' : '7-day',
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      value: '$adherencePct%',
                      label: isAr ? '١٤ يوم' : '14-day',
                      icon: Icons.bar_chart,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Sub-tabs ────────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tc,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  GoogleFonts.inter(fontSize: 14),
              tabs: [
                Tab(text: isAr ? 'جرعات اليوم' : "Today's Doses"),
                Tab(text: isAr ? 'أدويتي' : 'My Medications'),
              ],
            ),
          ),
          // ── Tab views ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                // Today's Doses
                Stack(
                  children: [
                    ListView(
                      padding:
                          const EdgeInsets.fromLTRB(24, 16, 24, 100),
                      children: [
                        // AI adherence insight banner
                        if (takenCount < totalDaily && totalDaily > 0)
                          _AdherenceBanner(
                            isAr: isAr,
                            takenCount: takenCount,
                            totalDaily: totalDaily,
                          ),
                        if (takenCount < totalDaily && totalDaily > 0)
                          const SizedBox(height: 12),
                        if (provider.medications.isEmpty)
                          _EmptyState(
                            heading: isAr
                                ? 'لم تُضيفي أي دواء بعد'
                                : 'No medications added yet',
                            subtext: isAr
                                ? 'أضيفي أدويتكِ لتذكّري مواعيد الجرعات بسهولة.'
                                : 'Add your medications to easily track your doses.',
                            buttonLabel: isAr ? 'أضيفي دواءً' : 'Add medication',
                            onTap: () =>
                                _showAddMedDialog(context, isAr),
                          )
                        else ...[
                          if (daily.isNotEmpty) ...[
                            _SectionLabel(isAr ? 'الجرعات اليومية' : 'Daily doses'),
                            ...daily.map((m) => _MedCard(
                                  med: m,
                                  onTake: () =>
                                      provider.takeMedication(m.id),
                                  isArabic: isAr,
                                )),
                          ],
                          if (asNeeded.isNotEmpty) ...[
                            _SectionLabel(isAr ? 'عند الحاجة' : 'As needed'),
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
                      right: 24,
                      child: _FABPurple(
                        label: isAr ? '+ أضيفي دواءً' : '+ Add Medication',
                        onTap: () =>
                            _showAddMedDialog(context, isAr),
                      ),
                    ),
                  ],
                ),
                // My Medications (all list)
                Stack(
                  children: [
                    ListView(
                      padding:
                          const EdgeInsets.fromLTRB(24, 16, 24, 100),
                      children: [
                        if (provider.medications.isEmpty)
                          _EmptyState(
                            heading: isAr
                                ? 'لم تُضيفي أي دواء بعد'
                                : 'No medications added yet',
                            subtext: isAr
                                ? 'أضيفي أدويتكِ لتتبّع جرعاتكِ بسهولة.'
                                : 'Add your medications to track your doses.',
                            buttonLabel:
                                isAr ? 'أضيفي دواءً' : 'Add medication',
                            onTap: () =>
                                _showAddMedDialog(context, isAr),
                          )
                        else
                          ...provider.medications.map((m) => _MedCard(
                                med: m,
                                onTake: m.isAsNeeded
                                    ? null
                                    : () =>
                                        provider.takeMedication(m.id),
                                isArabic: isAr,
                              )),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: _FABPurple(
                        label: isAr ? '+ أضيفي دواءً' : '+ Add Medication',
                        onTap: () =>
                            _showAddMedDialog(context, isAr),
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

  void _showAddMedDialog(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection:
            isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: _AddMedSheet(),
      ),
    );
  }
}

// Adherence warning banner
class _AdherenceBanner extends StatelessWidget {
  final bool isAr;
  final int takenCount;
  final int totalDaily;
  const _AdherenceBanner(
      {required this.isAr,
      required this.takenCount,
      required this.totalDaily});

  @override
  Widget build(BuildContext context) {
    final pending = totalDaily - takenCount;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBBF24), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              color: Color(0xFFD97706), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr
                  ? 'لديكِ $pending جرعة لم تؤخذ بعد اليوم.'
                  : 'You have $pending dose${pending > 1 ? 's' : ''} remaining today.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}

// Stat chip inside gradient header
class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatChip(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.almarai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85))),
          ],
        ),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final Medication med;
  final VoidCallback? onTake;
  final bool isArabic;
  const _MedCard(
      {required this.med, required this.onTake, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Pill icon circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: med.isTaken
                      ? AppColors.tealLight
                      : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_outlined,
                  size: 20,
                  color: med.isTaken
                      ? AppColors.teal
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    Text('${med.dose} · ${med.frequency}',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              _MedBadge(med: med),
            ],
          ),
          if (!med.isAsNeeded && !med.isTaken && onTake != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onTake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text(
                  isArabic ? 'تم الأخذ ✓' : 'Mark Taken ✓',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
          if (med.isTaken) ...[
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? '✓ تم أخذه ${med.takenAt ?? ""}'
                  : '✓ Taken ${med.takenAt ?? ""}',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.teal),
            ),
          ],
        ],
      ),
    );
  }
}

class _MedBadge extends StatelessWidget {
  final Medication med;
  const _MedBadge({required this.med});

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<AppProvider>().isArabic;
    String label;
    Color bg, fg;
    if (med.isAsNeeded) {
      label = isAr ? 'عند الحاجة' : 'As needed';
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
    } else if (med.isTaken) {
      label = isAr ? 'تم' : 'Taken';
      bg = AppColors.tealLight;
      fg = AppColors.teal;
    } else {
      label = isAr ? 'بانتظار' : 'Pending';
      bg = AppColors.amberLight;
      fg = AppColors.amber;
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
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
          Text(
              isAr ? 'إضافة دواء جديد' : 'Add new medication',
              style: GoogleFonts.almarai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _SheetField(
              controller: _nameCtrl,
              label: isAr ? 'اسم الدواء' : 'Medication name',
              hint: 'Tamoxifen',
              isArabic: isAr),
          const SizedBox(height: 12),
          _SheetField(
              controller: _doseCtrl,
              label: isAr ? 'الجرعة' : 'Dose',
              hint: '20mg',
              isArabic: isAr),
          const SizedBox(height: 12),
          Text(isAr ? 'التكرار' : 'Frequency',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: List.generate(
              freqLabels.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _freqIndex = i),
                child: Chip(
                  label: Text(freqLabels[i],
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _freqIndex == i
                              ? AppColors.primary
                              : AppColors.textPrimary)),
                  backgroundColor: _freqIndex == i
                      ? AppColors.primaryLight
                      : AppColors.surface,
                  side: BorderSide(
                      color: _freqIndex == i
                          ? AppColors.primary
                          : AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty) return;
                    context.read<AppProvider>().addMedication(Medication(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: _nameCtrl.text.trim(),
                          dose: _doseCtrl.text.trim(),
                          frequency: freqLabels[_freqIndex],
                          isAsNeeded: _freqIndex == 2,
                        ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    minimumSize:
                        const Size(double.infinity, 52),
                    elevation: 0,
                  ),
                  child: Text(isAr ? 'حفظ' : 'Save',
                      style: GoogleFonts.almarai(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isAr ? 'إلغاء' : 'Cancel',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary)),
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
          .where((a) =>
              a.dateTime.isAfter(now) ||
              _isSameDay(a.dateTime, now))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      final past = provider.appointments
          .where((a) =>
              a.dateTime.isBefore(now) &&
              !_isSameDay(a.dateTime, now))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

      return Column(
        children: [
          // ── Purple gradient header ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'مواعيدي' : 'My Appointments',
                  style: GoogleFonts.almarai(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ApptChip(
                      label: isAr
                          ? '${upcoming.length} قادم'
                          : '${upcoming.length} upcoming',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    ...upcoming.take(2).map((a) {
                      final diff =
                          a.dateTime.difference(now).inDays;
                      final isToday = _isSameDay(a.dateTime, now);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _ApptChip(
                          label: isToday
                              ? (isAr ? 'اليوم' : 'TODAY')
                              : (isAr
                                  ? '$diff أيام'
                                  : '$diff DAYS'),
                          color: isToday
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFC4B5FD),
                          textColor: isToday
                              ? const Color(0xFF991B1B)
                              : const Color(0xFF4C1D95),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          // ── Sub-tabs ────────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tc,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  GoogleFonts.inter(fontSize: 14),
              tabs: [
                Tab(text: isAr ? 'القادمة' : 'Upcoming'),
                Tab(text: isAr ? 'السابقة' : 'Past'),
              ],
            ),
          ),
          // ── AI reminder banner ──────────────────────────────────────────
          if (_tc.index == 0 && upcoming.isNotEmpty)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: _AIReminderBanner(
                isAr: isAr,
                appt: upcoming.first,
                now: now,
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                // Upcoming
                Stack(
                  children: [
                    ListView(
                      padding:
                          const EdgeInsets.fromLTRB(24, 12, 24, 100),
                      children: [
                        if (upcoming.isEmpty)
                          _EmptyState(
                            heading: isAr
                                ? 'لا مواعيد قادمة'
                                : 'No upcoming appointments',
                            subtext: isAr
                                ? 'أضيفي مواعيدكِ الطبية لمتابعة جدولكِ.'
                                : 'Add your medical appointments to stay on track.',
                            buttonLabel: isAr
                                ? 'أضيفي موعداً'
                                : 'Add appointment',
                            onTap: () => _showAddApptDialog(
                                context, isAr),
                          )
                        else
                          ...upcoming.map((appt) =>
                              _ApptCard(
                                  appt: appt,
                                  isAr: isAr,
                                  now: now)),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: _FABPurple(
                        label: isAr
                            ? '+ أضيفي موعداً'
                            : '+ Add Appointment',
                        onTap: () =>
                            _showAddApptDialog(context, isAr),
                      ),
                    ),
                  ],
                ),
                // Past
                Stack(
                  children: [
                    ListView(
                      padding:
                          const EdgeInsets.fromLTRB(24, 12, 24, 100),
                      children: [
                        if (past.isEmpty)
                          _EmptyState(
                            heading: isAr
                                ? 'لا مواعيد سابقة'
                                : 'No past appointments',
                            subtext: isAr
                                ? 'ستظهر مواعيدكِ المنتهية هنا.'
                                : 'Your completed appointments will appear here.',
                            buttonLabel:
                                isAr ? 'أضيفي موعداً' : 'Add',
                            onTap: () => _showAddApptDialog(
                                context, isAr),
                          )
                        else
                          ...past.map((appt) => _ApptCard(
                              appt: appt, isAr: isAr, now: now, isPast: true)),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: _FABPurple(
                        label: isAr
                            ? '+ أضيفي موعداً'
                            : '+ Add Appointment',
                        onTap: () =>
                            _showAddApptDialog(context, isAr),
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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection:
            isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: _AddApptSheet(isArabic: isArabic),
      ),
    );
  }
}

class _ApptChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  const _ApptChip(
      {required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: color.withValues(alpha: 0.6), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor ??
              Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}

class _AIReminderBanner extends StatelessWidget {
  final bool isAr;
  final Appointment appt;
  final DateTime now;
  const _AIReminderBanner(
      {required this.isAr,
      required this.appt,
      required this.now});

  @override
  Widget build(BuildContext context) {
    final diff = appt.dateTime.difference(now).inDays;
    final isToday =
        appt.dateTime.year == now.year &&
        appt.dateTime.month == now.month &&
        appt.dateTime.day == now.day;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday
                      ? (isAr
                          ? 'موعدكِ اليوم: ${appt.title}'
                          : 'Appointment today: ${appt.title}')
                      : (isAr
                          ? 'موعدكِ القادم بعد $diff أيام: ${appt.title}'
                          : 'Next appointment in $diff day${diff != 1 ? "s" : ""}: ${appt.title}'),
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    isAr
                        ? 'استعدّي لزيارتكِ ←'
                        : 'Prepare for your visit →',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
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

  @override
  Widget build(BuildContext context) {
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final englishMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final diff = appt.dateTime.difference(now).inDays;
    final isToday = appt.dateTime.year == now.year &&
        appt.dateTime.month == now.month &&
        appt.dateTime.day == now.day;
    final monthName = isAr
        ? arabicMonths[appt.dateTime.month - 1]
        : englishMonths[appt.dateTime.month - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date block
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.redLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isAr ? 'اليوم' : 'Today',
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    Text(
                      '${appt.dateTime.day}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.almarai(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? AppColors.emergencyRed
                              : AppColors.primary),
                    ),
                    Text(
                      monthName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary),
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
                          child: Text(appt.title,
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                        ),
                        if (!isPast && !isToday)
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Text(
                              isAr ? '$diff أيام' : '$diff days',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (isPast)
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Text(
                              isAr ? 'مكتمل' : 'Done',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(appt.doctor,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                        '${appt.dateTime.hour.toString().padLeft(2, "0")}:${appt.dateTime.minute.toString().padLeft(2, "0")}',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (!isPast) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.description_outlined,
                        size: 16),
                    label: Text(
                        isAr ? 'تقرير ما قبل الزيارة' : 'AI Prep Report',
                        style: GoogleFonts.inter(
                            fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                          color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
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
          Text(
              isAr ? 'إضافة موعد جديد' : 'Add new appointment',
              style: GoogleFonts.almarai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _SheetField(
              controller: _titleCtrl,
              label: isAr ? 'نوع الموعد' : 'Appointment type',
              hint: isAr ? 'مراجعة مع الأورام' : 'Oncology review',
              isArabic: isAr),
          const SizedBox(height: 12),
          _SheetField(
              controller: _doctorCtrl,
              label: isAr ? 'اسم الطبيب' : 'Doctor name',
              hint: isAr ? 'د. سارة شين' : 'Dr. Sarah Chen',
              isArabic: isAr),
          const SizedBox(height: 12),
          Text(isAr ? 'التاريخ' : 'Date',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now()
                    .subtract(const Duration(days: 365)),
                lastDate: DateTime.now()
                    .add(const Duration(days: 365)),
                builder: (ctx, child) => Directionality(
                    textDirection: isAr
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child!),
              );
              if (d != null) setState(() => _date = d);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _date != null
                        ? AppColors.primary
                        : AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surface,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    _date != null
                        ? '${_date!.day}/${_date!.month}/${_date!.year}'
                        : (isAr ? 'اختاري التاريخ' : 'Select date'),
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _date != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_titleCtrl.text.trim().isEmpty || _date == null) {
                return;
              }
              context.read<AppProvider>().addAppointment(Appointment(
                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
                    title: _titleCtrl.text.trim(),
                    doctor: _doctorCtrl.text.trim(),
                    dateTime: _date!,
                  ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: Text(isAr ? 'حفظ' : 'Save',
                style: GoogleFonts.almarai(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
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

class _LabsTabState extends State<_LabsTab>
    with SingleTickerProviderStateMixin {
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
      final hasAttention =
          provider.labs.any((l) => l.status == 'attention');

      return Column(
        children: [
          // ── Purple gradient header ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? 'متتبّع التحاليل والدم'
                      : 'Lab & Blood Tracker',
                  style: GoogleFonts.almarai(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  isAr
                      ? 'عرض نتائج تحاليلكِ وتتبّعها'
                      : 'View and track your lab results',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white
                          .withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
          // ── Warning banner ──────────────────────────────────────────────
          if (hasAttention)
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined,
                        color: AppColors.amber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'بعض نتائجكِ تستحق الانتباه — راجعي فريقكِ الطبي.'
                            : 'Some results need attention — review with your care team.',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.amberDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ── Sub-tabs ────────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tc,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  GoogleFonts.inter(fontSize: 13),
              tabs: [
                Tab(text: isAr ? 'المقاييس' : 'Metrics'),
                Tab(text: isAr ? 'تحليل يُسر' : 'AI Insights'),
                Tab(text: isAr ? 'التقارير' : 'Reports'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                // ── Metrics ────────────────────────────────────────────
                Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                      children: [
                        if (provider.labs.isEmpty)
                          _EmptyState(
                            heading: isAr
                                ? 'لم تُضيفي أي تحاليل بعد'
                                : 'No lab results added yet',
                            subtext: isAr
                                ? 'أضيفي نتائج تحاليلكِ لمتابعة وضعكِ الصحي.'
                                : 'Add your lab results to track your health status.',
                            buttonLabel:
                                isAr ? 'أضيفي نتائج' : 'Add results',
                            onTap: () =>
                                _showAddLabDialog(context),
                          )
                        else ...[
                          // Status summary
                          Container(
                            margin:
                                const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: hasAttention
                                  ? AppColors.amberLight
                                  : AppColors.tealLight,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border(
                                left: isAr
                                    ? BorderSide.none
                                    : BorderSide(
                                        color: hasAttention
                                            ? AppColors.amber
                                            : AppColors.teal,
                                        width: 4),
                                right: isAr
                                    ? BorderSide(
                                        color: hasAttention
                                            ? AppColors.amber
                                            : AppColors.teal,
                                        width: 4)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Text(
                              hasAttention
                                  ? (isAr
                                      ? '⚠ بعض النتائج تحتاج مراجعة'
                                      : '⚠ Some results need review')
                                  : (isAr
                                      ? 'تحاليلكِ الأخيرة مستقرة ✓'
                                      : 'Your latest results are stable ✓'),
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: hasAttention
                                      ? AppColors.amber
                                      : AppColors.teal),
                            ),
                          ),
                          // Metric cards grid
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                            children: provider.labs
                                .map((lab) =>
                                    _LabMetricCard(
                                        lab: lab, isAr: isAr))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          // Yusr suggestion
                          _YusrSuggestionCard(
                              isAr: isAr, ctx: context),
                          const SizedBox(height: 16),
                          // When to contact
                          _SectionLabel(
                              isAr
                                  ? 'متى تتواصلين مع فريقكِ'
                                  : 'When to contact your team'),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: AppColors.amberLight,
                                borderRadius:
                                    BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                _AlertRow(isAr
                                    ? 'حمى فوق ٣٨°'
                                    : 'Fever above 38°C'),
                                _AlertRow(isAr
                                    ? 'ألم شديد مفاجئ'
                                    : 'Sudden severe pain'),
                                _AlertRow(isAr
                                    ? 'صعوبة في التنفس'
                                    : 'Difficulty breathing'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _CareTeamComingSoon(isAr: isAr),
                        ],
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: _FABPurple(
                        label: isAr ? '+ أضيفي تقريراً' : '+ Add Report',
                        onTap: () => _showAddLabDialog(context),
                      ),
                    ),
                  ],
                ),
                // ── AI Insights ────────────────────────────────────────
                ListView(
                  padding:
                      const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  children: [
                    _AIInsightsPanel(isAr: isAr, ctx: context),
                  ],
                ),
                // ── Reports ────────────────────────────────────────────
                Stack(
                  children: [
                    ListView(
                      padding:
                          const EdgeInsets.fromLTRB(24, 16, 24, 100),
                      children: [
                        _EmptyState(
                          heading: isAr
                              ? 'لا تقارير مضافة بعد'
                              : 'No reports uploaded yet',
                          subtext: isAr
                              ? 'يمكنكِ إضافة تقارير تحاليلكِ هنا.'
                              : 'Upload your lab reports here for tracking.',
                          buttonLabel:
                              isAr ? 'أضيفي تقريراً' : 'Add Report',
                          onTap: () => _showAddLabDialog(context),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: _FABPurple(
                        label: isAr ? '+ أضيفي تقريراً' : '+ Add Report',
                        onTap: () => _showAddLabDialog(context),
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

  void _showAddLabDialog(BuildContext context) {
    final isAr = context.read<AppProvider>().isArabic;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection:
            isAr ? TextDirection.rtl : TextDirection.ltr,
        child: _AddLabSheet(isArabic: isAr),
      ),
    );
  }
}

// Lab metric card (grid card with trend indicator)
class _LabMetricCard extends StatelessWidget {
  final LabResult lab;
  final bool isAr;
  const _LabMetricCard({required this.lab, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final isAttention = lab.status == 'attention';
    final isCritical = lab.status == 'critical';
    Color accent = isAttention || isCritical
        ? AppColors.amber
        : AppColors.teal;
    Color bg = isAttention || isCritical
        ? AppColors.amberLight
        : AppColors.tealLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: accent.withValues(alpha: 0.35), width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lab.name,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: accent, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lab.value,
            style: GoogleFonts.almarai(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          Text(
            lab.unit,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAttention
                  ? (isAr ? 'يحتاج اهتماماً' : 'Attention')
                  : isCritical
                      ? (isAr ? 'حرج' : 'Critical')
                      : (isAr ? 'طبيعي' : 'Normal'),
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: accent),
            ),
          ),
        ],
      ),
    );
  }
}

// AI Insights panel
class _AIInsightsPanel extends StatelessWidget {
  final bool isAr;
  final BuildContext ctx;
  const _AIInsightsPanel({required this.isAr, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'تحليل يُسر الذكي' : 'Yusr AI Analysis',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    Text(
                      isAr
                          ? 'بناءً على تحاليلكِ الأخيرة'
                          : 'Based on your latest results',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InsightBullet(
          icon: Icons.bloodtype_outlined,
          color: AppColors.amber,
          title: isAr ? 'الهيموجلوبين منخفض قليلاً' : 'Hemoglobin slightly low',
          body: isAr
              ? 'مستوى ١٠.٢ g/dL أقل من الطبيعي قليلاً. الإرهاق والدوار وارد. تأكّدي من الترطيب والراحة الكافية.'
              : 'Level 10.2 g/dL is slightly below normal range. Fatigue and dizziness are common. Ensure adequate rest and hydration.',
        ),
        const SizedBox(height: 10),
        _InsightBullet(
          icon: Icons.shield_outlined,
          color: AppColors.teal,
          title: isAr ? 'خلايا الدم البيضاء في النطاق الطبيعي' : 'WBC within normal range',
          body: isAr
              ? 'مستوى ٤.١ ×10³/µL ضمن النطاق الطبيعي — جهازكِ المناعي يعمل بشكل جيد خلال العلاج.'
              : 'Level 4.1 ×10³/µL is within normal range — your immune system is holding up well during treatment.',
        ),
        const SizedBox(height: 20),
        // Ask Yusr CTA
        _YusrSuggestionCard(isAr: isAr, ctx: ctx),
      ],
    );
  }
}

class _InsightBullet extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _InsightBullet(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
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
                const SizedBox(height: 4),
                Text(body,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _LabCard extends StatelessWidget {
  final LabResult lab;
  final bool isArabic;
  const _LabCard({required this.lab, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    final isAttention = lab.status == 'attention';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lab.name,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text('${lab.value} ${lab.unit}',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(lab.explanation,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAttention
                  ? AppColors.amberLight
                  : AppColors.tealLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isAttention
                  ? (isArabic ? 'قد يحتاج اهتماماً' : 'Needs attention')
                  : (isArabic ? 'طبيعي' : 'Normal'),
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAttention
                      ? AppColors.amber
                      : AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String text;
  const _AlertRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.amber, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(text,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.amberDark)),
        ],
      ),
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
          Text(isAr ? 'إضافة نتائج تحليل' : 'Add lab result',
              style: GoogleFonts.almarai(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          _SheetField(
              controller: _nameCtrl,
              label: isAr ? 'اسم التحليل' : 'Test name',
              hint: isAr ? 'الهيموجلوبين' : 'Hemoglobin',
              isArabic: isAr),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _SheetField(
                      controller: _valueCtrl,
                      label: isAr ? 'النتيجة' : 'Result',
                      hint: '10.2',
                      isArabic: isAr)),
              const SizedBox(width: 12),
              Expanded(
                  child: _SheetField(
                      controller: _unitCtrl,
                      label: isAr ? 'الوحدة' : 'Unit',
                      hint: 'g/dL',
                      isArabic: isAr)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_nameCtrl.text.trim().isEmpty) return;
              context.read<AppProvider>().addLabResult(LabResult(
                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
                    name: _nameCtrl.text.trim(),
                    value: _valueCtrl.text.trim(),
                    unit: _unitCtrl.text.trim(),
                    status: 'normal',
                    explanation: '',
                  ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: Text(isAr ? 'حفظ' : 'Save',
                style: GoogleFonts.almarai(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

// Purple pill FAB
class _FABPurple extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FABPurple({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Color(0x667C3AED),
                blurRadius: 12,
                offset: Offset(0, 4))
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}

// Section label
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text.toUpperCase(),
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.8)),
    );
  }
}

// Empty state
class _EmptyState extends StatelessWidget {
  final String heading;
  final String subtext;
  final String buttonLabel;
  final VoidCallback onTap;
  const _EmptyState(
      {required this.heading,
      required this.subtext,
      required this.buttonLabel,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(heading,
                style: GoogleFonts.almarai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtext,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                elevation: 0,
              ),
              child: Text(buttonLabel,
                  style: GoogleFonts.almarai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// Yusr suggestion card
class _YusrSuggestionCard extends StatelessWidget {
  final bool isAr;
  final BuildContext ctx;
  const _YusrSuggestionCard(
      {required this.isAr, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(ctx).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => const YusrOverlay(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: isAr
                ? BorderSide.none
                : const BorderSide(
                    color: AppColors.primary, width: 3),
            right: isAr
                ? const BorderSide(
                    color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isAr
                    ? 'لا تعرفين ماذا تعني نتيجة ما؟ يُسر تشرح لكِ.'
                    : 'Not sure what a result means? Yusr can explain.',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isAr ? 'اسألي يُسر ←' : 'Ask Yusr →',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// Care Team — Coming Soon card
class _CareTeamComingSoon extends StatelessWidget {
  final bool isAr;
  const _CareTeamComingSoon({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: Color(0xFFF5F3FF), shape: BoxShape.circle),
            child: const Icon(Icons.people_outline,
                color: Color(0xFFC4B5FD), size: 26),
          ),
          const SizedBox(height: 12),
          Text(
            isAr ? 'فريق الرعاية' : 'Care Team',
            style: GoogleFonts.almarai(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            isAr
                ? 'تواصل مباشر مع فريقكِ الطبي قادم قريباً.'
                : 'Direct connection to your care team — coming soon.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              isAr ? 'قريباً' : 'Coming soon',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
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
  const _SheetField(
      {required this.controller,
      required this.label,
      required this.hint,
      this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textAlign:
              isArabic ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.inter(
              fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 2)),
            filled: true,
            fillColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}
