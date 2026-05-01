import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/shared_widgets.dart';
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
    final labs = _session.labs;
    final latest = labs.isNotEmpty ? labs.first : null;
    final hasIssue = latest?.metrics.any((m) => !m.isNormal) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [

          // Header
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => context.go('/care'),
                child: Row(children: [
                  Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                    color: AppColors.text2.withOpacity(0.4)),
                  const SizedBox(width: 4),
                  Text('Care hub', style: AppText.caption.copyWith(
                    color: AppColors.text2, fontSize: 11)),
                ]),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(text: TextSpan(style: AppText.displayTitle,
                    children: const [
                      TextSpan(text: 'Lab '),
                      TextSpan(text: 'results',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    ])),
                  GestureDetector(
                    onTap: () => _showAddLabSheet(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.fullBR),
                      child: Row(children: [
                        const Icon(Icons.add_rounded,
                          size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('Add result',
                          style: AppText.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ),
                ]),
              Text('${labs.length} result${labs.length != 1 ? 's' : ''} logged',
                style: AppText.bodySecondary),
            ]),
          )),

          // Latest result hero
          if (latest != null)
            SliverToBoxAdapter(child: HeroCard(
              gradientColors: hasIssue
                  ? [const Color(0xFFEAC8B0), const Color(0xFFCCC0EC),
                     const Color(0xFFEAC8B0)]
                  : null,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                HeroPill('Latest · ${latest.panelName}'),
                Text(DateFormat('d MMMM yyyy').format(latest.date),
                  style: AppText.statNumber.copyWith(fontSize: 20)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text(
                    hasIssue
                        ? '${latest.metrics.where((m) => !m.isNormal).length} value${latest.metrics.where((m) => !m.isNormal).length != 1 ? 's' : ''} outside normal range'
                        : 'All values within normal range ✓',
                    style: AppText.bodySecondary)),
                ]),
                const SizedBox(height: 10),
                Wrap(spacing: 6, runSpacing: 6,
                  children: latest.metrics.map((m) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: m.isLow
                          ? AppColors.peach.withOpacity(0.18)
                          : m.isHigh
                              ? AppColors.rose.withOpacity(0.18)
                              : Colors.white.withOpacity(0.4),
                      borderRadius: AppRadius.fullBR),
                    child: Text(
                      '${m.name} ${m.value}${m.isLow ? ' ↓' : m.isHigh ? ' ↑' : ' ✓'}',
                      style: AppText.caption.copyWith(
                        fontSize: 11,
                        color: m.isLow
                            ? AppColors.peach
                            : m.isHigh
                                ? AppColors.rose
                                : AppColors.text1,
                        fontWeight: FontWeight.w500)))).toList()),
              ]),
            )),

          // Empty state
          if (labs.isEmpty)
            SliverToBoxAdapter(child: Container(
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mdBR,
                border: Border.all(color: AppColors.border, width: 0.5)),
              child: Column(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: AppRadius.mdBR),
                  child: const Center(child: Text('🧪',
                    style: TextStyle(fontSize: 26)))),
                const SizedBox(height: 16),
                Text('No lab results yet',
                  style: AppText.bodySemibold.copyWith(fontSize: 15)),
                const SizedBox(height: 8),
                Text(
                  'Log your CBC, metabolic panel, or tumour markers to track trends over time and correlate with your symptoms.',
                  style: AppText.bodySecondary.copyWith(fontSize: 13),
                  textAlign: TextAlign.center),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _showAddLabSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.fullBR,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 12, offset: const Offset(0, 4))]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.add_rounded,
                        size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Add first result',
                        style: AppText.bodySemibold.copyWith(
                          color: Colors.white, fontSize: 13)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Values appear in your doctor-ready prep report',
                  style: AppText.caption.copyWith(
                    color: AppColors.text3, fontSize: 11)),
              ]),
            )),

          // Metric evolution panels
          if (labs.length >= 2) ...[
            SliverToBoxAdapter(child: const SectionLabel('Value trends')),
            SliverToBoxAdapter(child: _buildMetricEvolution(labs)),
          ],

          // History
          if (labs.isNotEmpty) ...[
            SliverToBoxAdapter(child: const SectionLabel('All results')),
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _buildLabCard(labs[i]),
              childCount: labs.length,
            )),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }

  Widget _buildLabCard(LabResult lab) {
    final issues = lab.metrics.where((m) => !m.isNormal).toList();
    final isLatest = _session.labs.isNotEmpty &&
        lab.id == _session.labs.first.id;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: issues.isNotEmpty
              ? AppColors.peach.withOpacity(0.25)
              : AppColors.border,
          width: 0.5)),
      child: Column(children: [
        // Card header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: issues.isNotEmpty
                    ? AppColors.peachLight : AppColors.tealLight,
                borderRadius: AppRadius.smBR),
              child: Center(child: Text(
                issues.isNotEmpty ? '⚠' : '✓',
                style: const TextStyle(fontSize: 16)))),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(lab.panelName,
                    style: AppText.bodySemibold),
                  if (isLatest) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.fullBR),
                      child: Text('Latest',
                        style: AppText.caption.copyWith(
                          color: AppColors.primary,
                          fontSize: 9))),
                  ],
                ]),
                Text(DateFormat('d MMM yyyy').format(lab.date),
                  style: AppText.bodySecondary.copyWith(fontSize: 12)),
              ],
            )),
            // Delete button
            GestureDetector(
              onTap: () => _confirmDelete(lab),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.text3))),
          ]),
        ),
        // Metrics
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Column(children: lab.metrics.map((m) =>
            _buildMetricRow(m)).toList()),
        ),
      ]),
    );
  }

  Widget _buildMetricEvolution(List<LabResult> labs) {
    // Group all metrics by name across all results of the same panel
    final metricHistory = <String, List<(DateTime, LabMetric)>>{};

    for (final lab in labs) {
      for (final m in lab.metrics) {
        metricHistory.putIfAbsent(m.name, () => []);
        metricHistory[m.name]!.add((lab.date, m));
      }
    }

    // Only show metrics that appear in more than one result
    final tracked = metricHistory.entries
        .where((e) => e.value.length >= 1)
        .toList()
      ..sort((a, b) {
        // Put abnormal values first
        final aLatest = a.value.last.$2;
        final bLatest = b.value.last.$2;
        if (!aLatest.isNormal && bLatest.isNormal) return -1;
        if (aLatest.isNormal && !bLatest.isNormal) return 1;
        return 0;
      });

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Column(
        children: tracked.map((e) =>
            _buildMetricTrendCard(e.key, e.value)).toList(),
      ),
    );
  }

  Widget _buildMetricTrendCard(
      String name, List<(DateTime, LabMetric)> history) {
    // Sort oldest to newest
    final sorted = [...history]
        ..sort((a, b) => a.$1.compareTo(b.$1));
    final latest = sorted.last.$2;
    final values = sorted.map((e) => e.$2.value).toList();
    final dates = sorted.map((e) => e.$1).toList();

    // Trend direction
    String trend = '→ Stable';
    Color trendColor = AppColors.text3;
    if (values.length >= 2) {
      final diff = values.last - values.first;
      final pct = (diff / values.first * 100).abs();
      if (pct > 5) {
        if (diff > 0) {
          trend = '↑ Increasing';
          trendColor = latest.isHigh ? AppColors.rose : AppColors.teal;
        } else {
          trend = '↓ Declining';
          trendColor = latest.isLow ? AppColors.rose : AppColors.teal;
        }
      }
    }

    final statusColor = latest.isLow ? AppColors.peach
        : latest.isHigh ? AppColors.rose
        : AppColors.teal;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(
          color: latest.isNormal
              ? AppColors.border
              : statusColor.withOpacity(0.25),
          width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Container(width: 5, height: 5,
            decoration: BoxDecoration(
              color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(name,
            style: AppText.bodySemibold.copyWith(fontSize: 13))),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: AppRadius.fullBR),
            child: Text(
              latest.isLow ? '↓ Low'
                  : latest.isHigh ? '↑ High' : '✓ Normal',
              style: AppText.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600, fontSize: 10))),
          const SizedBox(width: 6),
          // Trend
          Text(trend, style: AppText.caption.copyWith(
            color: trendColor, fontSize: 10)),
        ]),
        const SizedBox(height: 10),

        // Sparkline + values row
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          // Value history dots
          Expanded(child: SizedBox(
            height: 60,
            child: CustomPaint(
              painter: _SparklinePainter(
                values: values,
                normalMin: latest.normalMin,
                normalMax: latest.normalMax,
                color: statusColor),
              child: const SizedBox.expand()),
          )),
          const SizedBox(width: 12),
          // Latest value
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(latest.value.toString(),
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 18,
                fontWeight: FontWeight.w700,
                color: statusColor)),
            Text(latest.unit,
              style: AppText.caption.copyWith(fontSize: 10)),
          ]),
        ]),

        const SizedBox(height: 6),
        // Date labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (dates.isNotEmpty)
              Text(DateFormat('d MMM').format(dates.first),
                style: AppText.caption.copyWith(fontSize: 9,
                  color: AppColors.text3)),
            Text('Normal: ${latest.normalMin}–${latest.normalMax} ${latest.unit}',
              style: AppText.caption.copyWith(fontSize: 9,
                color: AppColors.text3)),
            if (dates.length > 1)
              Text(DateFormat('d MMM').format(dates.last),
                style: AppText.caption.copyWith(fontSize: 9,
                  color: AppColors.text3)),
          ],
        ),

        // Value history chips
        if (sorted.length > 1) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sorted.map((e) {
                final m = e.$2;
                final c = m.isLow ? AppColors.peach
                    : m.isHigh ? AppColors.rose
                    : AppColors.teal;
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.07),
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(
                      color: c.withOpacity(0.2), width: 0.5)),
                  child: Column(children: [
                    Text('${m.value}',
                      style: AppText.caption.copyWith(
                        color: c, fontWeight: FontWeight.w600,
                        fontSize: 11)),
                    Text(DateFormat('d/M').format(e.$1),
                      style: AppText.caption.copyWith(
                        fontSize: 9, color: AppColors.text3)),
                  ]),
                );
              }).toList(),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildMetricRow(LabMetric m) {
    final color = m.isLow ? AppColors.peach
        : m.isHigh ? AppColors.rose
        : AppColors.teal;
    final status = m.isLow ? '↓ Low' : m.isHigh ? '↑ High' : '✓';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(width: 5, height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(m.name,
          style: AppText.bodySecondary.copyWith(fontSize: 12))),
        Text('${m.value} ${m.unit}',
          style: AppText.bodySemibold.copyWith(fontSize: 12)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: AppRadius.fullBR),
          child: Text(status,
            style: AppText.caption.copyWith(
              color: color, fontSize: 10,
              fontWeight: FontWeight.w600))),
        if (m.trend != null) ...[
          const SizedBox(width: 6),
          Text(
            '${m.trend! >= 0 ? '↑' : '↓'} ${m.trend!.abs().toStringAsFixed(1)}',
            style: AppText.caption.copyWith(
              fontSize: 10,
              color: m.trend! >= 0
                  ? AppColors.teal : AppColors.rose)),
        ],
      ]),
    );
  }

  // ── Add lab sheet ─────────────────────────────────────────────────────────
  void _showAddLabSheet() {
    // Panel templates with common metrics and normal ranges
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
    // Controllers for each metric value
    final controllers = <String, TextEditingController>{};
    for (final panel in panels) {
      for (final metric in panel.$2) {
        controllers[metric.$1] = TextEditingController();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) {
          final currentPanel = panels.firstWhere(
              (p) => p.$1 == selectedPanel);

          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20,
                MediaQuery.of(context).viewInsets.bottom + 32),
            child: SingleChildScrollView(child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 12),
                Text('ADD LAB RESULT',
                  style: AppText.label.copyWith(fontSize: 10)),
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
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primary)),
                        child: child!),
                    );
                    if (p != null) setS(() => selectedDate = p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.mdBR,
                      border: Border.all(
                        color: AppColors.primaryMid, width: 0.5)),
                    child: Row(children: [
                      const Text('📅', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Text(DateFormat('d MMMM yyyy').format(selectedDate),
                        style: AppText.bodySemibold.copyWith(
                          color: AppColors.primary)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),

                // Panel selector
                Text('Panel type', style: AppText.bodySecondary),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6,
                  children: panels.map((p) {
                    final sel = selectedPanel == p.$1;
                    return GestureDetector(
                      onTap: () => setS(() => selectedPanel = p.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primaryLight : AppColors.background2,
                          borderRadius: AppRadius.fullBR,
                          border: Border.all(
                            color: sel
                                ? AppColors.primaryMid : Colors.transparent,
                            width: 0.5)),
                        child: Text(p.$1, style: AppText.caption.copyWith(
                          color: sel ? AppColors.primary : AppColors.text2,
                          fontWeight: sel
                              ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 12))));
                  }).toList()),
                const SizedBox(height: 12),

                // Metrics input
                Text('Values', style: AppText.bodySecondary),
                const SizedBox(height: 6),
                ...currentPanel.$2.map((metric) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Expanded(flex: 2, child: Text(
                      '${metric.$1} (${metric.$4})',
                      style: AppText.bodySecondary.copyWith(fontSize: 12))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(
                      controller: controllers[metric.$1],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                      style: const TextStyle(fontFamily: 'Inter',
                        fontSize: 13, color: AppColors.text1),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '—',
                        hintStyle: const TextStyle(color: AppColors.text3),
                        filled: true, fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.border, width: 0.5)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.border, width: 0.5)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primaryMid, width: 1.5))),
                    )),
                    const SizedBox(width: 6),
                    SizedBox(width: 40, child: Text(metric.$2,
                      style: AppText.caption.copyWith(
                        fontSize: 10, color: AppColors.text3))),
                  ]),
                )),

                const SizedBox(height: 16),

                // Save button
                GestureDetector(
                  onTap: () {
                    final metrics = <LabMetric>[];
                    for (final metric in currentPanel.$2) {
                      final text = controllers[metric.$1]?.text.trim() ?? '';
                      if (text.isEmpty) continue;
                      final value = double.tryParse(text);
                      if (value == null) continue;
                      // Find previous value
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
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppRadius.fullBR,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10, offset: const Offset(0, 3))]),
                    child: const Center(child: Text('Save result',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                        fontWeight: FontWeight.w500, color: Colors.white)))),
                ),
              ],
            )),
          );
        },
      ),
    );
  }

  void _confirmDelete(LabResult lab) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete result?',
          style: AppText.sectionHeading.copyWith(fontSize: 15)),
        content: Text(
          '${lab.panelName} from ${DateFormat('d MMM yyyy').format(lab.date)} will be removed.',
          style: AppText.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
              style: TextStyle(color: AppColors.text2))),
          TextButton(
            onPressed: () {
              _session.removeLabResult(lab.id);
              setState(() {});
              Navigator.pop(context);
            },
            child: Text('Delete',
              style: TextStyle(color: AppColors.rose,
                fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

// ── Sparkline painter ────────────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final double normalMin, normalMax;
  final Color color;

  _SparklinePainter({
    required this.values,
    required this.normalMin,
    required this.normalMax,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // Use tight padding — just 15% of the actual value spread
    final valMin = values.reduce((a, b) => a < b ? a : b);
    final valMax = values.reduce((a, b) => a > b ? a : b);
    final spread = (valMax - valMin).abs();

    // Ensure we always show normal range context but keep values visible
    final padding = spread < 0.5 ? 1.0 : spread * 0.4;
    final minVal = [valMin - padding, normalMin * 0.85].reduce((a, b) => a < b ? a : b);
    final maxVal = [valMax + padding, normalMax * 1.1].reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    if (range == 0) return;

    double toY(double v) =>
        size.height - ((v - minVal) / range) * size.height;

    // Draw normal range band
    final bandPaint = Paint()
      ..color = AppColors.teal.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    final bandTop = toY(normalMax).clamp(0.0, size.height);
    final bandBottom = toY(normalMin).clamp(0.0, size.height);
    canvas.drawRect(
      Rect.fromLTRB(0, bandTop, size.width, bandBottom),
      bandPaint);

    // Draw normal range lines
    final linePaint = Paint()
      ..color = AppColors.teal.withOpacity(0.25)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(0, bandTop), Offset(size.width, bandTop), linePaint);
    canvas.drawLine(Offset(0, bandBottom), Offset(size.width, bandBottom), linePaint);

    if (values.length == 1) {
      // Single dot
      final x = size.width / 2;
      final y = toY(values[0]);
      canvas.drawCircle(Offset(x, y), 4,
          Paint()..color = color..style = PaintingStyle.fill);
      return;
    }

    // Draw sparkline
    final stepX = size.width / (values.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = toY(values[i]);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Smooth curve
        final prevX = (i - 1) * stepX;
        final prevY = toY(values[i - 1]);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill
    canvas.drawPath(fillPath, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill);

    // Line
    canvas.drawPath(path, Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Dots
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = toY(values[i]);
      canvas.drawCircle(Offset(x, y), 3,
          Paint()..color = color..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(x, y), 3,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values;
}
class LabHistoryScreen extends StatelessWidget {
  const LabHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    context.go('/care/labs');
    return const SizedBox.shrink();
  }
}

// ── Add lab screen ────────────────────────────────────────────────────────────
class AddLabScreen extends StatelessWidget {
  const AddLabScreen({super.key});
  @override
  Widget build(BuildContext context) {
    context.go('/care/labs');
    return const SizedBox.shrink();
  }
}
