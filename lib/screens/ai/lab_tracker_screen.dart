import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/lab_models.dart';
import '../../providers/lab_provider.dart';
import '../../theme/app_theme.dart';

// ─── Automated Lab Tracker Screen ─────────────────────────────────────────────
class LabTrackerScreen extends StatefulWidget {
  const LabTrackerScreen({super.key});
  @override
  State<LabTrackerScreen> createState() => _LabTrackerScreenState();
}

class _LabTrackerScreenState extends State<LabTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _selectedPanel = 'CBC';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LabProvider>(
      builder: (context, lab, _) {
        final patterns = lab.detectPatterns();
        final alertPatterns = patterns
            .where((p) => p.severity == LabZone.critical || p.severity == LabZone.red)
            .toList();
        final warningPatterns =
            patterns.where((p) => p.severity == LabZone.orange).toList();
        final goodPatterns =
            patterns.where((p) => p.severity == LabZone.green).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  lab: lab,
                  alertCount: alertPatterns.length,
                  onUpload: () => _showUploadSheet(context, lab),
                ),

                // Tabs
                Container(
                  color: AppColors.surface,
                  child: TabBar(
                    controller: _tab,
                    labelStyle: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w500),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textMuted,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    tabs: [
                      const Tab(text: 'Metrics'),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('AI Insights'),
                            if (alertPatterns.isNotEmpty) ...[
                              const SizedBox(width: 5),
                              Container(
                                width: 18, height: 18,
                                decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text('${alertPatterns.length}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Tab(text: 'Reports'),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _MetricsTab(
                          lab: lab,
                          selectedPanel: _selectedPanel,
                          onPanelChanged: (p) =>
                              setState(() => _selectedPanel = p)),
                      _AlertsTab(
                        alerts: alertPatterns,
                        warnings: warningPatterns,
                        good: goodPatterns,
                        lab: lab,
                        onUpload: () => _showUploadSheet(context, lab),
                      ),
                      _ReportsTab(
                          lab: lab,
                          onUpload: () => _showUploadSheet(context, lab)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showUploadSheet(context, lab),
            backgroundColor: AppColors.primaryDark,
            icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
            label: Text('Add Report',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  void _showUploadSheet(BuildContext context, LabProvider lab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: lab,
        child: const _UploadReportSheet(),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final LabProvider lab;
  final int alertCount;
  final VoidCallback onUpload;
  const _Header(
      {required this.lab, required this.alertCount, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final status = lab.overallStatus;
    final (statusLabel, statusColor, statusIcon, statusBg) = switch (status) {
      OverallLabStatus.good => (
          'All Values Stable',
          AppColors.accent,
          Icons.check_circle_rounded,
          AppColors.accentLight,
        ),
      OverallLabStatus.caution => (
          'Borderline Values — Monitor',
          AppColors.warning,
          Icons.warning_amber_rounded,
          AppColors.warningLight,
        ),
      OverallLabStatus.critical => (
          'Critical Values Detected',
          AppColors.danger,
          Icons.error_rounded,
          AppColors.dangerLight,
        ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryDark, size: 15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lab & Blood Tracker',
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: AppColors.accent, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'AI Monitoring Active · ${lab.reports.length} report${lab.reports.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onUpload,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.info]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Upload',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (lab.hasData) ...[
            const SizedBox(height: 12),
            // Overall status bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: statusColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(statusLabel,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: statusColor)),
                        Text(
                            '${lab.trackedMetrics.length} metrics tracked across ${lab.reports.length} reports',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  if (alertCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$alertCount critical',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Metrics Tab ──────────────────────────────────────────────────────────────
class _MetricsTab extends StatelessWidget {
  final LabProvider lab;
  final String selectedPanel;
  final ValueChanged<String> onPanelChanged;
  const _MetricsTab(
      {required this.lab,
      required this.selectedPanel,
      required this.onPanelChanged});

  @override
  Widget build(BuildContext context) {
    if (!lab.hasData) return _EmptyState(onUpload: () {});

    final panelMetrics = LabCatalog.byPanel(selectedPanel)
        .where((d) => lab.trackedMetrics.contains(d.key))
        .toList();

    return Column(
      children: [
        // Panel selector
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            children: LabCatalog.panels.map((p) {
              final sel = selectedPanel == p;
              // Count abnormal metrics in panel
              final abnormal = LabCatalog.byPanel(p).where((d) {
                final latest = lab.latestFor(d.key);
                if (latest == null) return false;
                return d.zoneFor(latest.value) != LabZone.green;
              }).length;

              return GestureDetector(
                onTap: () => onPanelChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? AppColors.primary : AppColors.border),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Text(p,
                          style: TextStyle(
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      if (abnormal > 0 && !sel) ...[
                        const SizedBox(width: 5),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text('$abnormal',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // Metric cards
        Expanded(
          child: panelMetrics.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.science_outlined,
                          size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 10),
                      Text('No $selectedPanel data yet',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        'Add a lab report to see $selectedPanel metrics',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: panelMetrics.length,
                  itemBuilder: (_, i) =>
                      _MetricChartCard(def: panelMetrics[i], lab: lab),
                ),
        ),
      ],
    );
  }
}

// ─── Metric Chart Card ────────────────────────────────────────────────────────
class _MetricChartCard extends StatefulWidget {
  final LabMetricDef def;
  final LabProvider lab;
  const _MetricChartCard({required this.def, required this.lab});

  @override
  State<_MetricChartCard> createState() => _MetricChartCardState();
}

class _MetricChartCardState extends State<_MetricChartCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final pts = widget.lab.timelineFor(widget.def.key);
    if (pts.isEmpty) return const SizedBox.shrink();

    final latest = pts.last.value;
    final prev = pts.length > 1 ? pts[pts.length - 2].value : latest;
    final zone = widget.def.zoneFor(latest);
    final zoneColor = _zoneColor(zone);
    final trendDelta = latest - prev;
    final trendIcon = _trendIcon(trendDelta);
    final trendColor = _trendColor(widget.def, latest, trendDelta);
    final statusLabel = _statusLabel(zone);

    // Percentage change text
    final pctChange = prev != 0 ? ((latest - prev) / prev * 100).abs() : 0.0;
    final pctText = pts.length > 1
        ? '${trendDelta >= 0 ? "+" : ""}${trendDelta.abs() >= 100 ? trendDelta.toStringAsFixed(0) : trendDelta.toStringAsFixed(1)} (${pctChange.toStringAsFixed(0)}%)'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: zone == LabZone.critical
                ? AppColors.danger.withValues(alpha: 0.4)
                : zone == LabZone.red
                    ? AppColors.danger.withValues(alpha: 0.2)
                    : AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                children: [
                  // Zone-first card: colored left border, plain-language sentence
                  // Raw number hidden — revealed via "See details"
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Zone color left border strip
                      Container(
                        width: 4,
                        height: 64,
                        decoration: BoxDecoration(
                          color: zoneColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(widget.def.shortName,
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1C1917))),
                                ),
                                _ZoneBadge(zone: zone, label: statusLabel),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Plain-language sentence (zone-first)
                            Text(
                              _plainLanguageSentence(widget.def, latest, zone),
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF78716C),
                                  height: 1.5),
                            ),
                            if (pts.length > 1 && pctText.isNotEmpty) ...[  
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(trendIcon, color: trendColor, size: 12),
                                  const SizedBox(width: 3),
                                  Text(pctText,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: trendColor,
                                          fontWeight: FontWeight.w600)),
                                  Text(' since last',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Sparkline
                  _ZoneLineChart(
                      pts: pts,
                      def: widget.def,
                      height: 58,
                      showDots: false),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                          '${pts.length} reading${pts.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      const Spacer(),
                      Text(
                          _expanded ? 'Hide details ↑' : 'See details →',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7C3AED))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded panel — reveals: value, range, trend + full chart
          if (_expanded) ...[
            Container(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Value + range reveal row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: zoneColor.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: zoneColor.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your value',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: AppColors.textMuted)),
                              Text('${_formatVal(latest)} ${widget.def.unit}',
                                  style: GoogleFonts.inter(
                                      fontSize: 22, fontWeight: FontWeight.w800,
                                      color: zoneColor)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppColors.divider),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Normal range',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: AppColors.textMuted)),
                              Text(
                                '${_formatVal(widget.def.normalMin)}–${_formatVal(widget.def.normalMax)} ${widget.def.unit}',
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Large chart
                  _ZoneLineChart(
                      pts: pts,
                      def: widget.def,
                      height: 170,
                      showDots: true),
                  const SizedBox(height: 12),

                  // Zone legend
                  _ZoneLegend(def: widget.def),
                  const SizedBox(height: 14),

                  // AI clinical note
                  _AINote(text: widget.def.aiContext),
                  const SizedBox(height: 14),

                  // Stats row
                  if (pts.length > 1) _StatsRow(pts: pts, def: widget.def),
                  if (pts.length > 1) const SizedBox(height: 14),

                  // All readings
                  Text('All Readings',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  ...pts.reversed.take(8).map((pt) {
                    final rpt = widget.lab.reports.firstWhere(
                        (r) => r.id == pt.reportId,
                        orElse: () => LabReport(
                            id: '',
                            date: pt.date,
                            reportName: '',
                            source: '',
                            entries: []));
                    final z = widget.def.zoneFor(pt.value);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _zoneColor(z).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _zoneColor(z).withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: _zoneColor(z),
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rpt.reportName.isNotEmpty
                                  ? rpt.reportName
                                  : _fmtDate(pt.date),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(_fmtDate(pt.date),
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textMuted)),
                          const SizedBox(width: 10),
                          Text(
                              '${_formatVal(pt.value)} ${widget.def.unit}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _zoneColor(z))),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatVal(double v) =>
      v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  String _fmtDate(DateTime d) =>
      '${d.month}/${d.day}/${d.year % 100}';
  int _daysBetween(DateTime a, DateTime b) =>
      b.difference(a).inDays.abs();

  IconData _trendIcon(double delta) {
    if (delta.abs() < 0.01) return Icons.trending_flat_rounded;
    return delta > 0
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
  }

  Color _trendColor(LabMetricDef d, double latest, double delta) {
    if (delta.abs() < 0.01) return AppColors.textMuted;
    if (d.lowerIsBetter) return delta < 0 ? AppColors.accent : AppColors.danger;
    if (latest < d.normalMin) return delta > 0 ? AppColors.accent : AppColors.warning;
    if (latest > d.normalMax) return delta < 0 ? AppColors.accent : AppColors.warning;
    return AppColors.accent;
  }

  String _statusLabel(LabZone z) => switch (z) {
        LabZone.green => 'Normal',
        LabZone.orange => 'Borderline',
        LabZone.red => 'Abnormal',
        LabZone.critical => 'Critical',
      };

  // Plain-language sentence for zone-first display (hides raw number)
  String _plainLanguageSentence(LabMetricDef def, double value, LabZone zone) {
    final name = def.name;
    switch (zone) {
      case LabZone.green:
        return '$name is within the normal range. No action needed.';
      case LabZone.orange:
        return '$name is slightly outside the normal range. Worth monitoring.';
      case LabZone.red:
        return '$name is outside the normal range. Discuss with your care team.';
      case LabZone.critical:
        return '$name is critically abnormal. Contact your care team today.';
    }
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final List<LabDataPoint> pts;
  final LabMetricDef def;
  const _StatsRow({required this.pts, required this.def});

  @override
  Widget build(BuildContext context) {
    final vals = pts.map((p) => p.value).toList();
    final mn = vals.reduce(min);
    final mx = vals.reduce(max);
    final avg = vals.reduce((a, b) => a + b) / vals.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatItem(label: 'Min', value: _fmt(mn), unit: def.unit,
              color: def.zoneFor(mn) == LabZone.green ? AppColors.accent : AppColors.danger),
          _divider(),
          _StatItem(label: 'Avg', value: _fmt(avg), unit: def.unit,
              color: def.zoneFor(avg) == LabZone.green ? AppColors.accent : AppColors.warning),
          _divider(),
          _StatItem(label: 'Max', value: _fmt(mx), unit: def.unit,
              color: def.zoneFor(mx) == LabZone.green ? AppColors.accent : AppColors.warning),
          _divider(),
          _StatItem(
            label: 'Trend',
            value: _trendLabel(),
            unit: '',
            color: _trendCol(),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 28, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 8));

  String _fmt(double v) => v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  String _trendLabel() {
    if (pts.length < 2) return 'N/A';
    final last3 = pts.length >= 3 ? pts.sublist(pts.length - 3) : pts;
    double sum = 0;
    for (int i = 1; i < last3.length; i++) {
      sum += last3[i].value - last3[i - 1].value;
    }
    final avg = sum / (last3.length - 1);
    if (avg.abs() < 0.1) return 'Stable';
    if (def.lowerIsBetter) {
      return avg < 0 ? '↓ Improving' : '↑ Rising';
    }
    if (pts.last.value < def.normalMin) return avg > 0 ? '↑ Recovering' : '↓ Declining';
    if (pts.last.value > def.normalMax) return avg < 0 ? '↓ Normalizing' : '↑ Rising';
    return avg > 0 ? '↑ Rising' : '↓ Falling';
  }

  Color _trendCol() {
    final t = _trendLabel();
    if (t.contains('Improving') || t.contains('Recovering') || t.contains('Normalizing')) {
      return AppColors.accent;
    }
    if (t.contains('Declining') || t.contains('Rising')) {
      return def.lowerIsBetter ? AppColors.warning : AppColors.danger;
    }
    return AppColors.textMuted;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          if (unit.isNotEmpty)
            Text(unit,
                style: const TextStyle(
                    fontSize: 8, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ─── Zone Line Chart ──────────────────────────────────────────────────────────
class _ZoneLineChart extends StatelessWidget {
  final List<LabDataPoint> pts;
  final LabMetricDef def;
  final double height;
  final bool showDots;

  const _ZoneLineChart(
      {required this.pts,
      required this.def,
      required this.height,
      required this.showDots});

  @override
  Widget build(BuildContext context) {
    if (pts.isEmpty) return const SizedBox.shrink();

    final allVals = pts.map((p) => p.value).toList()
      ..add(def.normalMin)
      ..add(def.normalMax);
    final rawMin = allVals.reduce(min);
    final rawMax = allVals.reduce(max);
    final padding = (rawMax - rawMin) * 0.22;
    final yMin = max(0.0, rawMin - padding);
    final yMax = rawMax + padding;
    final yRange = (yMax - yMin).clamp(0.001, double.infinity);

    final firstDay = pts.first.date;
    double xOf(DateTime d) => d.difference(firstDay).inDays.toDouble();
    final xMax = xOf(pts.last.date).clamp(1.0, double.infinity);

    final spots = pts.map((p) => FlSpot(xOf(p.date), p.value)).toList();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: xMax,
          minY: yMin,
          maxY: yMax,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: showDots,
            drawVerticalLine: false,
            horizontalInterval: yRange / 4,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.divider, strokeWidth: 0.8),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showDots,
                reservedSize: 38,
                interval: yRange / 4,
                getTitlesWidget: (v, _) => Text(
                  v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textMuted),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showDots && pts.length > 1,
                reservedSize: 22,
                getTitlesWidget: (v, meta) {
                  if (v == 0) {
                    final d = pts.first.date;
                    return Text('${d.month}/${d.day}',
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textMuted));
                  }
                  if ((v - xMax).abs() < 1) {
                    final d = pts.last.date;
                    return Text('${d.month}/${d.day}',
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.textMuted));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: _buildZoneBands(yMin, yMax),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: def.normalMin,
                color: AppColors.accent.withValues(alpha: 0.45),
                strokeWidth: 1.2,
                dashArray: [5, 4],
              ),
              HorizontalLine(
                y: def.normalMax,
                color: AppColors.accent.withValues(alpha: 0.45),
                strokeWidth: 1.2,
                dashArray: [5, 4],
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: pts.length > 2,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: showDots,
                getDotPainter: (spot, pct, bar, idx) {
                  final z = def.zoneFor(spot.y);
                  return FlDotCirclePainter(
                    radius: 5.5,
                    color: _zoneColor(z),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: showDots,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 10,
              getTooltipItems: (touchedSpots) => touchedSpots
                  .map((s) {
                    final z = def.zoneFor(s.y);
                    return LineTooltipItem(
                      '${s.y >= 100 ? s.y.toStringAsFixed(0) : s.y.toStringAsFixed(1)} ${def.unit}\n${_statusLabel(z)}',
                      TextStyle(
                        color: _zoneColor(z),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  List<HorizontalRangeAnnotation> _buildZoneBands(
      double yMin, double yMax) {
    final bands = <HorizontalRangeAnnotation>[];
    // Green (normal)
    bands.add(HorizontalRangeAnnotation(
      y1: def.normalMin,
      y2: def.normalMax,
      color: AppColors.accent.withValues(alpha: 0.09),
    ));
    // Orange low
    if (def.orangeLow != null) {
      bands.add(HorizontalRangeAnnotation(
        y1: def.orangeLow!,
        y2: def.normalMin,
        color: const Color(0xFFF59E0B).withValues(alpha: 0.09),
      ));
    }
    // Orange high
    if (def.orangeHigh != null) {
      bands.add(HorizontalRangeAnnotation(
        y1: def.normalMax,
        y2: def.orangeHigh!,
        color: const Color(0xFFF59E0B).withValues(alpha: 0.09),
      ));
    }
    // Red low
    if (def.redLow != null) {
      bands.add(HorizontalRangeAnnotation(
        y1: max(yMin, 0),
        y2: def.redLow!,
        color: AppColors.danger.withValues(alpha: 0.09),
      ));
    }
    // Red high
    if (def.redHigh != null) {
      bands.add(HorizontalRangeAnnotation(
        y1: def.redHigh!,
        y2: yMax,
        color: AppColors.danger.withValues(alpha: 0.09),
      ));
    }
    return bands;
  }

  String _statusLabel(LabZone z) => switch (z) {
        LabZone.green => 'Normal',
        LabZone.orange => 'Borderline',
        LabZone.red => 'Abnormal',
        LabZone.critical => 'Critical',
      };
}

// ─── Zone Legend ──────────────────────────────────────────────────────────────
class _ZoneLegend extends StatelessWidget {
  final LabMetricDef def;
  const _ZoneLegend({required this.def});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendDot(color: AppColors.accent, label: 'Normal'),
        const SizedBox(width: 10),
        _LegendDot(color: AppColors.warning, label: 'Borderline'),
        const SizedBox(width: 10),
        _LegendDot(color: AppColors.danger, label: 'Abnormal'),
        const Spacer(),
        Row(
          children: [
            Container(
              width: 18, height: 2,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 3),
            const Text('Normal range',
                style: TextStyle(
                    fontSize: 9, color: AppColors.textMuted)),
          ],
        ),
      ],
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
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Zone Badge ───────────────────────────────────────────────────────────────
class _ZoneBadge extends StatelessWidget {
  final LabZone zone;
  final String label;
  const _ZoneBadge({required this.zone, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = _zoneColor(zone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w800, color: c)),
    );
  }
}

// ─── AI Note ─────────────────────────────────────────────────────────────────
class _AINote extends StatelessWidget {
  final String text;
  const _AINote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark.withValues(alpha: 0.07),
            AppColors.info.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primaryDark.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.info]),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.45)),
          ),
        ],
      ),
    );
  }
}

// ─── AI Alerts Tab ────────────────────────────────────────────────────────────
class _AlertsTab extends StatelessWidget {
  final List<LabPattern> alerts;
  final List<LabPattern> warnings;
  final List<LabPattern> good;
  final LabProvider lab;
  final VoidCallback onUpload;

  const _AlertsTab({
    required this.alerts,
    required this.warnings,
    required this.good,
    required this.lab,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    if (!lab.hasData) return _EmptyState(onUpload: onUpload);

    final all = [...alerts, ...warnings, ...good];
    if (all.isEmpty) {
      return const Center(
          child: Text('No patterns detected yet',
              style: TextStyle(color: AppColors.textMuted)));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Summary chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (alerts.isNotEmpty)
              _SummaryChip(alerts.length, 'Critical/Abnormal', AppColors.danger,
                  Icons.error_rounded),
            if (warnings.isNotEmpty)
              _SummaryChip(warnings.length, 'Borderline', AppColors.warning,
                  Icons.warning_amber_rounded),
            if (good.isNotEmpty)
              _SummaryChip(good.length, 'Normal/Improving', AppColors.accent,
                  Icons.check_circle_rounded),
          ],
        ),
        const SizedBox(height: 16),

        // AI analysis header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primaryDark.withValues(alpha: 0.08),
              AppColors.info.withValues(alpha: 0.05),
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primaryDark.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.info]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Pattern Analysis',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark)),
                    Text(
                        '${lab.reports.length} reports analyzed · ${lab.trackedMetrics.length} metrics · patterns detected over time',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Critical section header
        if (alerts.isNotEmpty) ...[
          _SectionLabel('Requires Attention', AppColors.danger),
          const SizedBox(height: 8),
          ...alerts.map((p) => _PatternCard(pattern: p, lab: lab)),
          const SizedBox(height: 10),
        ],

        // Warning section
        if (warnings.isNotEmpty) ...[
          _SectionLabel('Monitor Closely', AppColors.warning),
          const SizedBox(height: 8),
          ...warnings.map((p) => _PatternCard(pattern: p, lab: lab)),
          const SizedBox(height: 10),
        ],

        // Good section
        if (good.isNotEmpty) ...[
          _SectionLabel('Normal / Improving', AppColors.accent),
          const SizedBox(height: 8),
          ...good.map((p) => _PatternCard(pattern: p, lab: lab)),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: color,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;
  const _SummaryChip(this.count, this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text('$count $label',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _PatternCard extends StatefulWidget {
  final LabPattern pattern;
  final LabProvider lab;
  const _PatternCard({required this.pattern, required this.lab});

  @override
  State<_PatternCard> createState() => _PatternCardState();
}

class _PatternCardState extends State<_PatternCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = _zoneColor(widget.pattern.severity);
    final def = LabCatalog.byKey(widget.pattern.metricKey);
    final pts = widget.lab.timelineFor(widget.pattern.metricKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.2)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_patternIcon(widget.pattern.type),
                            color: c, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(widget.pattern.title,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                      ),
                      _ZoneBadge(
                          zone: widget.pattern.severity,
                          label: _zoneLabel(widget.pattern.severity)),
                      const SizedBox(width: 6),
                      Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textMuted,
                          size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.pattern.description,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4),
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded ? null : TextOverflow.ellipsis),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            Container(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sparkline
                  if (pts.length >= 2 && def != null) ...[
                    _ZoneLineChart(
                        pts: pts.length > 6 ? pts.sublist(pts.length - 6) : pts,
                        def: def,
                        height: 60,
                        showDots: false),
                    const SizedBox(height: 10),
                  ],

                  // Recommendation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: c.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_rounded, color: c, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(widget.pattern.recommendation,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: c,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ),

                  // AI context
                  if (def != null) ...[
                    const SizedBox(height: 10),
                    _AINote(text: def.aiContext),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _patternIcon(PatternType t) => switch (t) {
        PatternType.criticalAlert => Icons.error_rounded,
        PatternType.rapidDecline => Icons.trending_down_rounded,
        PatternType.risingConcern => Icons.trending_up_rounded,
        PatternType.steadyImprovement => Icons.check_circle_rounded,
        PatternType.normalRestored => Icons.verified_rounded,
        PatternType.nadirDetected => Icons.change_circle_rounded,
        PatternType.stable => Icons.horizontal_rule_rounded,
      };

  String _zoneLabel(LabZone z) => switch (z) {
        LabZone.green => 'Good',
        LabZone.orange => 'Caution',
        LabZone.red => 'Alert',
        LabZone.critical => 'Critical',
      };
}

// ─── Reports Tab ──────────────────────────────────────────────────────────────
class _ReportsTab extends StatelessWidget {
  final LabProvider lab;
  final VoidCallback onUpload;
  const _ReportsTab({required this.lab, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    if (!lab.hasData) return _EmptyState(onUpload: onUpload);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: lab.reports.length,
      itemBuilder: (_, i) {
        final r = lab.reports[lab.reports.length - 1 - i];
        final abnormal = r.entries.where((e) {
          final def = LabCatalog.byKey(e.metricKey);
          if (def == null) return false;
          final z = def.zoneFor(e.value);
          return z != LabZone.green;
        }).length;
        final critical = r.entries.where((e) {
          final def = LabCatalog.byKey(e.metricKey);
          if (def == null) return false;
          return def.zoneFor(e.value) == LabZone.critical;
        }).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: critical > 0
                    ? AppColors.danger.withValues(alpha: 0.3)
                    : abnormal > 0
                        ? AppColors.warning.withValues(alpha: 0.2)
                        : AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_rounded,
                          color: AppColors.primaryDark, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.reportName,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          Text(
                              '${r.source} · ${r.date.day}/${r.date.month}/${r.date.year}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (critical > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$critical critical',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.danger)),
                          ),
                        if (abnormal > 0 && critical == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$abnormal flagged',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warning)),
                          ),
                        if (abnormal == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('All normal',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent)),
                          ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Report'),
                                content: const Text(
                                    'This will remove all values from this report from tracking.'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete',
                                          style: TextStyle(
                                              color: AppColors.danger))),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              context
                                  .read<LabProvider>()
                                  .deleteReport(r.id);
                            }
                          },
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.danger, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Values chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: r.entries.map((e) {
                    final def = LabCatalog.byKey(e.metricKey);
                    final z = def?.zoneFor(e.value) ?? LabZone.green;
                    final c = _zoneColor(z);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: c.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                  color: c, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text(
                            '${def?.shortName ?? e.metricKey.toUpperCase()}: ${e.value >= 100 ? e.value.toStringAsFixed(0) : e.value.toStringAsFixed(1)}',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: c),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Upload Report Sheet ──────────────────────────────────────────────────────
class _UploadReportSheet extends StatefulWidget {
  const _UploadReportSheet();
  @override
  State<_UploadReportSheet> createState() => _UploadReportSheetState();
}

class _UploadReportSheetState extends State<_UploadReportSheet> {
  final _nameCtrl = TextEditingController();
  final _sourceCtrl = TextEditingController(text: 'Hospital Lab');
  DateTime _reportDate = DateTime.now();

  final Map<String, TextEditingController> _valueCtrs = {};
  final Set<String> _selectedMetrics = {};
  String _activePanel = 'CBC';

  _UploadStep _step = _UploadStep.method;
  bool _isSaving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    for (final m in LabCatalog.all) {
      _valueCtrs[m.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sourceCtrl.dispose();
    for (final c in _valueCtrs.values) c.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _reportDate = d);
  }

  Future<void> _save() async {
    final lab = context.read<LabProvider>();
    setState(() => _isSaving = true);

    final entries = _selectedMetrics
        .map((key) {
          final txt = _valueCtrs[key]?.text.trim() ?? '';
          final v = double.tryParse(txt);
          if (v == null) return null;
          final def = LabCatalog.byKey(key)!;
          return LabEntry(metricKey: key, value: v, unit: def.unit);
        })
        .whereType<LabEntry>()
        .toList();

    if (entries.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter at least one value'),
          backgroundColor: AppColors.warning));
      return;
    }

    final report = LabReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _reportDate,
      reportName: _nameCtrl.text.trim().isEmpty
          ? 'Lab Report ${_reportDate.month}/${_reportDate.day}'
          : _nameCtrl.text.trim(),
      source: _sourceCtrl.text.trim().isEmpty
          ? 'Hospital Lab'
          : _sourceCtrl.text.trim(),
      entries: entries,
    );

    await lab.addReport(report);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _saved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _saved
            ? _buildSaved()
            : _step == _UploadStep.method
                ? _buildMethod()
                : _buildEntry(),
      ),
    );
  }

  Widget _buildSaved() {
    return Column(
      key: const ValueKey('saved'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.accent, Color(0xFF3D8B66)]),
              shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded,
              color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        Text('Report Added!',
            style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        const Text(
          'AI is now analyzing patterns across all your reports, detecting trends and flagging changes that need attention.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('View Updated Tracker'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMethod() {
    return Column(
      key: const ValueKey('method'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sheet handle
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.info]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.upload_file_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Lab Report',
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const Text(
                    'AI tracks values automatically across reports',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // How it works card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _HowItWorksStep(
                  num: '1',
                  text: 'Enter values from your printed or digital lab report'),
              const SizedBox(height: 8),
              _HowItWorksStep(
                  num: '2',
                  text: 'AI maps each value to normal ranges and flags anomalies'),
              const SizedBox(height: 8),
              _HowItWorksStep(
                  num: '3',
                  text: 'Trends across reports are tracked and suspicious patterns are detected'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Report Name (optional)',
            hintText: 'e.g. CBC Panel – Cycle 4',
            prefixIcon: Icon(Icons.label_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _sourceCtrl,
              decoration: const InputDecoration(
                labelText: 'Lab / Source',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: AppColors.primaryDark, size: 18),
                  const SizedBox(height: 2),
                  Text(
                      '${_reportDate.month}/${_reportDate.day}/${_reportDate.year % 100}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.primaryDark)),
                ],
              ),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => setState(() => _step = _UploadStep.entry),
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: const Text('Enter Lab Values'),
        ),
      ],
    );
  }

  Widget _buildEntry() {
    final panelMetrics = LabCatalog.byPanel(_activePanel);
    return Column(
      key: const ValueKey('entry'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _step = _UploadStep.method),
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryDark, size: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Enter Lab Values',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ),
          if (_selectedMetrics.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${_selectedMetrics.length} selected',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 14),

        // Hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.accent, size: 14),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tap a metric to select it, then enter its value. Only include values from your report.',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.accentDark,
                      height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Panel tabs
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: LabCatalog.panels.map((p) {
              final sel = _activePanel == p;
              return GestureDetector(
                onTap: () => setState(() => _activePanel = p),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: sel ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(p,
                      style: TextStyle(
                          color: sel ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Metric inputs
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.36),
          child: SingleChildScrollView(
            child: Column(
              children: panelMetrics.map((m) {
                final selected = _selectedMetrics.contains(m.key);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedMetrics.remove(m.key);
                      _valueCtrs[m.key]?.clear();
                    } else {
                      _selectedMetrics.add(m.key);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySurface
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: selected ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      // Checkbox
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border),
                        ),
                        child: selected
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 13)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.shortName,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textPrimary)),
                            Text(
                                'Normal: ${m.normalMin >= 100 ? m.normalMin.toStringAsFixed(0) : m.normalMin.toStringAsFixed(1)}–${m.normalMax >= 100 ? m.normalMax.toStringAsFixed(0) : m.normalMax.toStringAsFixed(1)} ${m.unit}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      if (selected)
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: _valueCtrs[m.key],
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            autofocus: _selectedMetrics.length == 1,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                            decoration: InputDecoration(
                              hintText: 'value',
                              hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primary),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _isSaving || _selectedMetrics.isEmpty ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.auto_awesome_rounded, size: 18),
          label: Text(_isSaving ? 'Saving...' : 'Save & Analyze with AI'),
        ),
      ],
    );
  }
}

// ─── How It Works Step ────────────────────────────────────────────────────────
class _HowItWorksStep extends StatelessWidget {
  final String num;
  final String text;
  const _HowItWorksStep({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Center(
            child: Text(num,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4)),
        ),
      ],
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.info]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.bloodtype_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text('No Lab Data Yet',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            const Text(
              'Each time you receive a lab report, upload the values here. AI will automatically track trends, detect nadir patterns, flag suspicious changes, and celebrate improvements.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.55),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('Add First Report'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
Color _zoneColor(LabZone z) => switch (z) {
      LabZone.green => AppColors.accent,
      LabZone.orange => AppColors.warning,
      LabZone.red => AppColors.danger,
      LabZone.critical => const Color(0xFFC0392B),
    };

enum _UploadStep { method, entry }
