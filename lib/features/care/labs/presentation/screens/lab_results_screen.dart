import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../theme/rehlah_theme.dart';
import '../../../../../core/utils/models.dart';
import '../../../../../core/utils/user_session.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});
  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  final _session = UserSession();

  @override
  void initState() {
    super.initState();
    _session.initDefaultLabs();
  }

  @override
  Widget build(BuildContext context) {
    final labs   = _session.labs;
    final latest = labs.isNotEmpty ? labs.first : null;

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(context),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: latest == null
                ? _emptyState()
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const SizedBox(height: 4),
                    _hero(latest),
                    _aiSummary(latest),
                    _sectionHead('All metrics'),
                    const SizedBox(height: 8),
                    ...latest.metrics.map((m) => _metricRow(m)),
                    const SizedBox(height: 12),
                    _viewHistoryBtn(context),
                    const SizedBox(height: 24),
                  ]),
          )),
        ]),
      ),
    );
  }

  // ── Topbar ──────────────────────────────────────────────────────────────────

  Widget _topbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        _iconBtn(Icons.chevron_left_rounded,
            onTap: () => context.canPop() ? context.pop() : context.go('/')),
        const Expanded(child: Center(child: Text('Lab results',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        _iconBtn(Icons.add_rounded, onTap: _showAddLabSheet),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: RColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: RColors.sand200),
        ),
        child: Icon(icon, color: RColors.sand700, size: 20),
      ),
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────────

  Widget _hero(LabResult latest) {
    final inRange = latest.metrics.where((m) => m.isNormal).length;
    final low     = latest.metrics.where((m) => m.isLow).length;
    final high    = latest.metrics.where((m) => m.isHigh).length;

    final headline = low == 0 && high == 0 ? 'All in range'
        : low > 0 && high > 0 ? 'Some values off'
        : low > 0 ? 'Some values low'
        : 'Some values high';

    final dateStr = DateFormat('d MMM').format(latest.date);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RColors.teal700, RColors.teal600],
        ),
        borderRadius: RRadius.xlBR,
      ),
      child: Stack(children: [
        Positioned(
          top: -70, right: -70,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Last drawn · $dateStr',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 4),
          Text(headline,
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.2)),
          const SizedBox(height: 12),
          Row(children: [
            _chip('$inRange', 'in range', RColors.sage500, Colors.white),
            const SizedBox(width: 8),
            if (low > 0) ...[
              _chip('$low', 'low', RColors.saffron500, RColors.sand950),
              const SizedBox(width: 8),
            ],
            if (high > 0)
              _chip('$high', 'high', RColors.clay500, Colors.white),
          ]),
        ]),
      ]),
    );
  }

  Widget _chip(String num, String label, Color bg, Color fgNum) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: RRadius.mdBR,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(num,
          style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700,
            color: fgNum, height: 1)),
        const SizedBox(height: 2),
        Text(label,
          style: TextStyle(
            fontSize: 10.5, letterSpacing: 0.06,
            color: fgNum.withValues(alpha: fgNum == RColors.sand950 ? 0.7 : 0.75))),
      ]),
    );
  }

  // ── AI summary ────────────────────────────────────────────────────────────────

  Widget _aiSummary(LabResult latest) {
    final abnormal = latest.metrics.where((m) => !m.isNormal).toList();
    final low      = abnormal.where((m) => m.isLow).toList();
    final high     = abnormal.where((m) => m.isHigh).toList();

    String line1, line2;
    if (abnormal.isEmpty) {
      line1 = 'All your values are within the expected range for this point in your cycle. Keep it up.';
      line2 = 'Your care team will review these results at your next visit.';
    } else {
      final lowStr  = low.map((m) => m.name).join(', ');
      final highStr = high.map((m) => m.name).join(', ');
      line1 = low.isNotEmpty
          ? '$lowStr ${low.length == 1 ? 'is' : 'are'} slightly low — common at this point in the cycle and within what your team expects.'
          : '$highStr ${high.length == 1 ? 'is' : 'are'} mildly elevated. Worth mentioning at your next appointment.';
      line2 = (low.isNotEmpty && high.isNotEmpty)
          ? '$highStr ${high.length == 1 ? 'is' : 'are'} also mildly elevated. Worth mentioning at your next appointment.'
          : 'Your other values look stable and in range for this phase.';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.teal50,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.teal200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(
              color: RColors.teal700, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 13)),
          const SizedBox(width: 8),
          const Text('Rehlah summary',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4,
              fontWeight: FontWeight.w500, color: RColors.teal700)),
        ]),
        const SizedBox(height: 10),
        Text(line1,
          style: const TextStyle(
            fontSize: 13, color: RColors.sand700, height: 1.5)),
        const SizedBox(height: 6),
        Text(line2,
          style: const TextStyle(
            fontSize: 13, color: RColors.sand700, height: 1.5)),
      ]),
    );
  }

  // ── Section head ─────────────────────────────────────────────────────────────

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, letterSpacing: 1.4,
          fontWeight: FontWeight.w500, color: RColors.sand500)),
    );
  }

  // ── Metric row ────────────────────────────────────────────────────────────────

  Widget _metricRow(LabMetric m) {
    final color = m.isLow ? RColors.clay500
        : m.isHigh ? RColors.clay700
        : RColors.teal600;

    // Map value to 0–1 position on bar
    double pos;
    if (m.value <= m.normalMin) {
      pos = (0.15 * (m.value / m.normalMin)).clamp(0.0, 0.14);
    } else if (m.value >= m.normalMax) {
      pos = (0.85 + 0.15 * (m.value - m.normalMax) / (m.normalMax * 0.3)).clamp(0.86, 1.0);
    } else {
      pos = 0.15 + 0.70 * (m.value - m.normalMin) / (m.normalMax - m.normalMin);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Text(m.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: RColors.sand950)),
        ),
        Expanded(
          flex: 4,
          child: LayoutBuilder(builder: (_, constraints) {
            return SizedBox(
              height: 22,
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: RRadius.pillBR,
                    gradient: const LinearGradient(colors: [
                      RColors.clay300,
                      RColors.sand200,
                      RColors.sage300,
                      RColors.sand200,
                      RColors.clay300,
                    ], stops: [0.0, 0.15, 0.5, 0.85, 1.0]),
                  ),
                ),
                Positioned(
                  left: (constraints.maxWidth * pos - 5).clamp(0.0, constraints.maxWidth - 10),
                  child: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(
                          color: color.withValues(alpha: 0.3), blurRadius: 4)],
                    ),
                  ),
                ),
              ]),
            );
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('${m.value}',
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()])),
            const SizedBox(width: 2),
            Text(m.unit,
              style: const TextStyle(fontSize: 10, color: RColors.sand500)),
          ]),
        ),
      ]),
    );
  }

  // ── View history button ───────────────────────────────────────────────────────

  Widget _viewHistoryBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => context.push('/care/labs/history'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: RColors.surface,
            borderRadius: RRadius.pillBR,
            border: Border.all(color: RColors.sand200),
          ),
          child: const Center(child: Text('View full history',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                color: RColors.sand900))),
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────────

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 60),
        Container(
          width: 56, height: 56,
          decoration: const BoxDecoration(
            color: RColors.sky100, borderRadius: RRadius.mdBR),
          child: const Center(child: Text('🧪',
            style: TextStyle(fontSize: 26)))),
        const SizedBox(height: 16),
        const Text('No lab results yet',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: RColors.sand950)),
        const SizedBox(height: 8),
        const Text(
          'Log your CBC, metabolic panel, or tumour markers to track trends.',
          style: TextStyle(fontSize: 13, color: RColors.sand700, height: 1.5),
          textAlign: TextAlign.center),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _showAddLabSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              color: RColors.teal700, borderRadius: RRadius.pillBR),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_rounded, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text('Add first result',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                    color: Colors.white)),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Add lab bottom sheet ──────────────────────────────────────────────────────

  void _showAddLabSheet() {
    const panels = [
      ('CBC', [
        ('Hemoglobin', 'g/dL', 12.0, 17.5),
        ('WBC', '×10³/µL', 4.5, 11.0),
        ('Platelets', '×10³/µL', 150.0, 400.0),
        ('Neutrophils', '×10³/µL', 1.8, 7.7),
        ('Lymphocytes', '×10³/µL', 1.0, 4.8),
      ]),
      ('Metabolic', [
        ('Creatinine', 'mg/dL', 0.5, 1.1),
        ('ALT', 'U/L', 7.0, 56.0),
        ('AST', 'U/L', 10.0, 40.0),
        ('Albumin', 'g/dL', 3.4, 5.4),
        ('Sodium', 'mEq/L', 136.0, 145.0),
      ]),
      ('Tumour markers', [
        ('CA15-3', 'U/mL', 0.0, 30.0),
        ('CEA', 'ng/mL', 0.0, 3.0),
        ('CA125', 'U/mL', 0.0, 35.0),
      ]),
      ('Hormones', [
        ('Estradiol', 'pg/mL', 0.0, 400.0),
        ('FSH', 'mIU/mL', 2.0, 20.0),
        ('LH', 'mIU/mL', 2.0, 15.0),
        ('TSH', 'mIU/L', 0.4, 4.0),
      ]),
    ];

    String selectedPanel = 'CBC';
    DateTime selectedDate = DateTime.now();
    final controllers = <String, TextEditingController>{};
    for (final panel in panels) {
      for (final metric in panel.$2) {
        controllers[metric.$1] = TextEditingController();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final currentPanel =
              panels.firstWhere((p) => p.$1 == selectedPanel);
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20,
                MediaQuery.of(context).viewInsets.bottom + 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                          color: RColors.sand200,
                          borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 12),
                  const Text('ADD LAB RESULT',
                    style: TextStyle(
                      fontSize: 10.5, letterSpacing: 1.4,
                      fontWeight: FontWeight.w500, color: RColors.sand500)),
                  const SizedBox(height: 12),
                  // Date
                  GestureDetector(
                    onTap: () async {
                      final p = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(
                            const Duration(days: 365)),
                        lastDate: DateTime.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: RColors.teal700)),
                          child: child!),
                      );
                      if (p != null) setS(() => selectedDate = p);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: RColors.sand50,
                        borderRadius: RRadius.mdBR,
                        border: Border.all(color: RColors.teal200)),
                      child: Row(children: [
                        const Text('📅', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Text(DateFormat('d MMMM yyyy').format(selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: RColors.teal700)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Panel selector
                  const Text('Panel type',
                    style: TextStyle(fontSize: 12, color: RColors.sand500)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: panels.map((p) {
                      final sel = selectedPanel == p.$1;
                      return GestureDetector(
                        onTap: () => setS(() => selectedPanel = p.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? RColors.teal50 : RColors.sand100,
                            borderRadius: RRadius.pillBR,
                            border: Border.all(
                                color: sel ? RColors.teal200 : Colors.transparent)),
                          child: Text(p.$1,
                            style: TextStyle(
                              fontSize: 12,
                              color: sel ? RColors.teal700 : RColors.sand700,
                              fontWeight: sel ? FontWeight.w600 : FontWeight.w400))),
                      );
                    }).toList()),
                  const SizedBox(height: 12),
                  // Values
                  const Text('Values',
                    style: TextStyle(fontSize: 12, color: RColors.sand500)),
                  const SizedBox(height: 6),
                  ...currentPanel.$2.map((metric) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Expanded(flex: 2, child: Text(
                        '${metric.$1} (${metric.$4})',
                        style: const TextStyle(
                            fontSize: 12, color: RColors.sand500))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(
                        controller: controllers[metric.$1],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '—',
                          hintStyle: const TextStyle(color: RColors.sand400),
                          filled: true, fillColor: RColors.sand50,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: RColors.sand200)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: RColors.sand200)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: RColors.teal200, width: 1.5))),
                      )),
                      const SizedBox(width: 6),
                      SizedBox(width: 40, child: Text(metric.$2,
                        style: const TextStyle(
                            fontSize: 10, color: RColors.sand400))),
                    ]),
                  )),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      final metrics = <LabMetric>[];
                      for (final metric in currentPanel.$2) {
                        final text =
                            controllers[metric.$1]?.text.trim() ?? '';
                        if (text.isEmpty) continue;
                        final value = double.tryParse(text);
                        if (value == null) continue;
                        final prev = _session.labs
                            .where((l) => l.panelName == selectedPanel)
                            .expand((l) => l.metrics)
                            .where((m) => m.name == metric.$1)
                            .firstOrNull?.value;
                        metrics.add(LabMetric(
                          name: metric.$1, value: value,
                          unit: metric.$2,
                          normalMin: metric.$3, normalMax: metric.$4,
                          previousValue: prev,
                        ));
                      }
                      if (metrics.isEmpty) {
                        Navigator.pop(context);
                        return;
                      }
                      _session.addLabResult(LabResult(
                        id: '${selectedPanel.toLowerCase()}-${DateTime.now().millisecondsSinceEpoch}',
                        panelName: selectedPanel,
                        date: selectedDate,
                        metrics: metrics,
                      ));
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: const BoxDecoration(
                        color: RColors.teal700, borderRadius: RRadius.pillBR),
                      child: const Center(child: Text('Save result',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}

// ── Lab History Screen ────────────────────────────────────────────────────────

class LabHistoryScreen extends StatefulWidget {
  const LabHistoryScreen({super.key});
  @override
  State<LabHistoryScreen> createState() => _LabHistoryScreenState();
}

class _LabHistoryScreenState extends State<LabHistoryScreen> {
  final _session = UserSession();
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _session.initDefaultLabs();
  }

  List<LabResult> get _filtered {
    final all = _session.labs;
    if (_filter == 'All') return all;
    return all.where((l) => l.panelName == _filter).toList();
  }

  List<String> get _panelNames {
    final names = _session.labs.map((l) => l.panelName).toSet().toList();
    return ['All', ...names];
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(context),
          // Filter pills
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              itemCount: _panelNames.length,
              itemBuilder: (_, i) {
                final name = _panelNames[i];
                final sel = _filter == name;
                return GestureDetector(
                  onTap: () => setState(() => _filter = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel ? RColors.teal700 : RColors.surface,
                      borderRadius: RRadius.pillBR,
                      border: Border.all(
                          color: sel ? RColors.teal700 : RColors.sand200),
                    ),
                    child: Text(name,
                      style: TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : RColors.sand700)),
                  ),
                );
              },
            ),
          ),
          Expanded(child: rows.isEmpty
              ? _emptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _sectionHead('Chronological'),
                    const SizedBox(height: 8),
                    ...rows.map(_historyRow),
                    const SizedBox(height: 24),
                  ]),
                )),
        ]),
      ),
    );
  }

  Widget _topbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        _iconBtn(Icons.chevron_left_rounded,
            onTap: () => context.canPop() ? context.pop() : context.go('/care/labs')),
        const Expanded(child: Center(child: Text('Lab history',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        _iconBtn(Icons.add_rounded,
            onTap: () => context.canPop() ? context.pop() : context.go('/care/labs')),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: RColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: RColors.sand200),
        ),
        child: Icon(icon, color: RColors.sand700, size: 20),
      ),
    );
  }

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, letterSpacing: 1.4,
          fontWeight: FontWeight.w500, color: RColors.sand500)),
    );
  }

  Widget _historyRow(LabResult lab) {
    final allNormal = lab.metrics.every((m) => m.isNormal);
    final anyHigh = lab.metrics.any((m) => m.isHigh);
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${lab.date.day} ${months[lab.date.month - 1]} ${lab.date.year}';

    final (pillLabel, pillBg, pillFg) = allNormal
        ? ('In range', RColors.sage100, RColors.sage700)
        : anyHigh
            ? ('Review', RColors.clay100, RColors.clay700)
            : ('Low values', RColors.saffron100, RColors.saffron700);

    final (iconBg, iconFg) = allNormal
        ? (RColors.sage100, RColors.sage700)
        : anyHigh
            ? (RColors.clay100, RColors.clay700)
            : (RColors.saffron100, RColors.saffron700);

    final normalCount = lab.metrics.where((m) => m.isNormal).length;
    final total = lab.metrics.length;

    return GestureDetector(
      onTap: () => context.push('/care/labs'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.sand200),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: RRadius.smBR),
            child: Icon(Icons.science_outlined, color: iconFg, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lab.panelName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: RColors.sand950)),
            const SizedBox(height: 2),
            Text('$dateStr · $normalCount of $total in range',
              style: const TextStyle(fontSize: 11, color: RColors.sand500,
                  height: 1.3)),
          ])),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            height: 24,
            decoration: BoxDecoration(color: pillBg, borderRadius: RRadius.pillBR),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5,
                decoration: BoxDecoration(color: pillFg, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(pillLabel,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500,
                    color: pillFg, height: 1.0)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 60),
        Container(
          width: 56, height: 56,
          decoration: const BoxDecoration(
              color: RColors.sky100, borderRadius: RRadius.mdBR),
          child: const Center(child: Text('🧪',
            style: TextStyle(fontSize: 26)))),
        const SizedBox(height: 16),
        Text(_filter == 'All' ? 'No lab history yet' : 'No $_filter results',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: RColors.sand950)),
        const SizedBox(height: 8),
        const Text('Results you log will appear here.',
          style: TextStyle(fontSize: 13, color: RColors.sand700),
          textAlign: TextAlign.center),
      ]),
    ));
  }
}

class AddLabScreen extends StatelessWidget {
  const AddLabScreen({super.key});
  @override
  Widget build(BuildContext context) {
    context.go('/care/labs');
    return const SizedBox.shrink();
  }
}
