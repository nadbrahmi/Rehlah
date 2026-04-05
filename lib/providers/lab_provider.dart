import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lab_models.dart';

// ─── Overall Lab Status ───────────────────────────────────────────────────────
enum OverallLabStatus { good, caution, critical }

// ─── Lab Provider ─────────────────────────────────────────────────────────────
class LabProvider extends ChangeNotifier {
  static const _storageKey = 'rehla_lab_reports_v2';

  SharedPreferences? _prefs;
  List<LabReport> _reports = [];

  // ── Public getters ────────────────────────────────────────────────────────
  List<LabReport> get reports => List.unmodifiable(_reports);
  bool get hasData => _reports.isNotEmpty;

  /// All metric keys that have at least one data point
  List<String> get trackedMetrics {
    final keys = <String>{};
    for (final r in _reports) {
      for (final e in r.entries) {
        keys.add(e.metricKey);
      }
    }
    return keys.toList();
  }

  /// Chronological data points for a single metric
  List<LabDataPoint> timelineFor(String key) {
    final pts = <LabDataPoint>[];
    for (final r in _reports) {
      for (final e in r.entries) {
        if (e.metricKey == key) {
          pts.add(LabDataPoint(date: r.date, value: e.value, reportId: r.id));
        }
      }
    }
    pts.sort((a, b) => a.date.compareTo(b.date));
    return pts;
  }

  /// Latest value for a metric
  LabDataPoint? latestFor(String key) {
    final pts = timelineFor(key);
    return pts.isEmpty ? null : pts.last;
  }

  /// Worst zone across all currently tracked metrics
  OverallLabStatus get overallStatus {
    bool hasCritical = false;
    bool hasOrange = false;
    for (final key in trackedMetrics) {
      final latest = latestFor(key);
      if (latest == null) continue;
      final def = LabCatalog.byKey(key);
      if (def == null) continue;
      final z = def.zoneFor(latest.value);
      if (z == LabZone.critical || z == LabZone.red) hasCritical = true;
      if (z == LabZone.orange) hasOrange = true;
    }
    if (hasCritical) return OverallLabStatus.critical;
    if (hasOrange) return OverallLabStatus.caution;
    return OverallLabStatus.good;
  }

  // ── Initialization ────────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    final raw = _prefs?.getString(_storageKey);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      _reports = list.map((m) => LabReport.fromMap(m as Map<String, dynamic>)).toList();
      _reports.sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      _reports = [];
    }
  }

  Future<void> _persist() async {
    final encoded = jsonEncode(_reports.map((r) => r.toMap()).toList());
    await _prefs?.setString(_storageKey, encoded);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────
  Future<void> addReport(LabReport report) async {
    _reports.removeWhere((r) => r.id == report.id);
    _reports.add(report);
    _reports.sort((a, b) => a.date.compareTo(b.date));
    await _persist();
    notifyListeners();
  }

  Future<void> deleteReport(String id) async {
    _reports.removeWhere((r) => r.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _reports.clear();
    await _prefs?.remove(_storageKey);
    notifyListeners();
  }

  // ── AI Pattern Detection ──────────────────────────────────────────────────
  /// Runs pattern detection across all tracked metrics and returns insights
  List<LabPattern> detectPatterns() {
    final patterns = <LabPattern>[];
    for (final key in trackedMetrics) {
      final def = LabCatalog.byKey(key);
      if (def == null) continue;
      final pts = timelineFor(key);
      if (pts.isEmpty) continue;

      final pattern = _analyzeMetric(def, pts);
      if (pattern != null) patterns.add(pattern);
    }

    // Sort: critical first, then red, orange, green
    patterns.sort((a, b) {
      const order = {
        LabZone.critical: 0,
        LabZone.red: 1,
        LabZone.orange: 2,
        LabZone.green: 3,
      };
      return (order[a.severity] ?? 4).compareTo(order[b.severity] ?? 4);
    });

    return patterns;
  }

  LabPattern? _analyzeMetric(LabMetricDef def, List<LabDataPoint> pts) {
    final latest = pts.last.value;
    final currentZone = def.zoneFor(latest);

    // ── Single reading ────────────────────────────────────────────────────
    if (pts.length == 1) {
      return switch (currentZone) {
        LabZone.critical => LabPattern(
            type: PatternType.criticalAlert,
            metricKey: def.key,
            title: '${def.shortName} — Critical Value',
            description:
                '${def.shortName} is at ${_fmt(latest)} ${def.unit}, which is in the critical range (normal: ${_fmt(def.normalMin)}–${_fmt(def.normalMax)} ${def.unit}). Immediate medical attention may be needed.',
            recommendation: _criticalRec(def),
            severity: LabZone.critical),
        LabZone.red => LabPattern(
            type: PatternType.criticalAlert,
            metricKey: def.key,
            title: '${def.shortName} — Abnormal',
            description:
                '${def.shortName} is at ${_fmt(latest)} ${def.unit}, outside the normal range of ${_fmt(def.normalMin)}–${_fmt(def.normalMax)} ${def.unit}.',
            recommendation: 'Discuss this result with your care team at your next visit.',
            severity: LabZone.red),
        LabZone.orange => LabPattern(
            type: PatternType.risingConcern,
            metricKey: def.key,
            title: '${def.shortName} — Borderline',
            description:
                '${def.shortName} is at ${_fmt(latest)} ${def.unit}, which is borderline. Normal range: ${_fmt(def.normalMin)}–${_fmt(def.normalMax)} ${def.unit}.',
            recommendation: 'Monitor at the next lab draw. Stay well hydrated and follow care team guidance.',
            severity: LabZone.orange),
        _ => LabPattern(
            type: PatternType.stable,
            metricKey: def.key,
            title: '${def.shortName} — Normal',
            description:
                '${def.shortName} is ${_fmt(latest)} ${def.unit}, within normal range (${_fmt(def.normalMin)}–${_fmt(def.normalMax)} ${def.unit}).',
            recommendation: def.aiContext,
            severity: LabZone.green),
      };
    }

    // ── Multi-reading analysis ────────────────────────────────────────────
    final prev = pts[pts.length - 2].value;
    final prevZone = def.zoneFor(prev);
    final delta = latest - prev;
    final pctChange = prev != 0 ? (delta / prev).abs() * 100 : 0.0;

    // Critical regardless of trend
    if (currentZone == LabZone.critical) {
      return LabPattern(
        type: PatternType.criticalAlert,
        metricKey: def.key,
        title: '${def.shortName} — Critical: Immediate Action',
        description:
            '${def.shortName} has reached ${_fmt(latest)} ${def.unit}. This is in the critical range. ${delta < 0 ? "Down ${_fmt(delta.abs())} from last reading." : "Up ${_fmt(delta.abs())} from last reading."}',
        recommendation: _criticalRec(def),
        severity: LabZone.critical,
      );
    }

    // Rapid decline (≥20% drop and currently abnormal/borderline)
    if (!def.lowerIsBetter && delta < 0 && pctChange >= 20 &&
        (currentZone == LabZone.red || currentZone == LabZone.orange)) {
      return LabPattern(
        type: PatternType.rapidDecline,
        metricKey: def.key,
        title: '${def.shortName} — Rapid Decline',
        description:
            '${def.shortName} dropped ${_fmt(pctChange.toDouble())}% from ${_fmt(prev)} to ${_fmt(latest)} ${def.unit}. This rapid fall warrants attention.',
        recommendation: 'Report any new symptoms — especially fever, unusual fatigue, or bleeding — to your care team today.',
        severity: LabZone.red,
      );
    }

    // Rising concern for tumor markers
    if (def.lowerIsBetter && delta > 0 && pctChange >= 15 &&
        (currentZone == LabZone.orange || currentZone == LabZone.red)) {
      return LabPattern(
        type: PatternType.risingConcern,
        metricKey: def.key,
        title: '${def.shortName} — Rising Trend',
        description:
            '${def.shortName} has risen ${_fmt(pctChange.toDouble())}% to ${_fmt(latest)} ${def.unit}. An upward trend in ${def.shortName} should be reviewed with your oncologist.',
        recommendation: 'Do not interpret this alone. Discuss the trend with your oncologist alongside any recent imaging.',
        severity: LabZone.orange,
      );
    }

    // Nadir detection (CBC metrics) — lowest point after consecutive drops, now recovering
    if (!def.lowerIsBetter && pts.length >= 3) {
      final twoBack = pts[pts.length - 3].value;
      if (prev <= twoBack && prev <= latest && prev < def.normalMin) {
        return LabPattern(
          type: PatternType.nadirDetected,
          metricKey: def.key,
          title: '${def.shortName} — Nadir Recovery Detected',
          description:
              '${def.shortName} reached a low of ${_fmt(prev)} ${def.unit} and is now recovering to ${_fmt(latest)} ${def.unit}. This nadir pattern is common after chemotherapy.',
          recommendation: 'Continue monitoring at each draw. Infection precautions remain important until values normalize. Recovery is underway.',
          severity: LabZone.orange,
        );
      }
    }

    // Returned to normal from abnormal
    if (currentZone == LabZone.green &&
        (prevZone == LabZone.red || prevZone == LabZone.orange || prevZone == LabZone.critical)) {
      return LabPattern(
        type: PatternType.normalRestored,
        metricKey: def.key,
        title: '${def.shortName} — Back to Normal!',
        description:
            '${def.shortName} has returned to normal range at ${_fmt(latest)} ${def.unit}, up from ${_fmt(prev)} ${def.unit}. Great progress!',
        recommendation: 'Continue current treatment plan. Keep tracking to confirm the trend holds.',
        severity: LabZone.green,
      );
    }

    // Tumor marker improvement
    if (def.lowerIsBetter && delta < 0 && pctChange >= 10) {
      return LabPattern(
        type: PatternType.steadyImprovement,
        metricKey: def.key,
        title: '${def.shortName} — Positive Response',
        description:
            '${def.shortName} has decreased ${_fmt(pctChange.toDouble())}% from ${_fmt(prev)} to ${_fmt(latest)} ${def.unit}. This declining trend suggests treatment response.',
        recommendation:
            'Continue your treatment plan. This trend, confirmed over multiple readings, is a positive indicator.',
        severity: LabZone.green,
      );
    }

    // Consistent improvement across 3+ readings
    if (pts.length >= 3 && !def.lowerIsBetter) {
      final improving = _isMonotonicallyImproving(def, pts.sublist(pts.length - 3));
      if (improving && currentZone == LabZone.green) {
        return LabPattern(
          type: PatternType.steadyImprovement,
          metricKey: def.key,
          title: '${def.shortName} — Steady Improvement',
          description:
              '${def.shortName} has improved consistently over the last 3 readings: ${pts.sublist(pts.length - 3).map((p) => _fmt(p.value)).join(" → ")} ${def.unit}.',
          recommendation: 'Excellent progress. Continue your current regimen and maintain regular lab checks.',
          severity: LabZone.green,
        );
      }
    }

    // Stable in abnormal range (no change but still bad)
    if ((currentZone == LabZone.red || currentZone == LabZone.orange) && pctChange < 5) {
      return LabPattern(
        type: PatternType.stable,
        metricKey: def.key,
        title: '${def.shortName} — Persistently Abnormal',
        description:
            '${def.shortName} has been in the ${_zoneLabel(currentZone).toLowerCase()} range for the last ${pts.length} readings. Current: ${_fmt(latest)} ${def.unit}.',
        recommendation: 'Discuss with your care team. Persistent abnormality may require treatment adjustment.',
        severity: currentZone,
      );
    }

    // Currently in green zone — report as normal
    if (currentZone == LabZone.green) {
      return LabPattern(
        type: PatternType.stable,
        metricKey: def.key,
        title: '${def.shortName} — Normal Range',
        description:
            '${def.shortName} is stable at ${_fmt(latest)} ${def.unit} (normal: ${_fmt(def.normalMin)}–${_fmt(def.normalMax)} ${def.unit}).',
        recommendation: def.aiContext,
        severity: LabZone.green,
      );
    }

    return null;
  }

  bool _isMonotonicallyImproving(LabMetricDef def, List<LabDataPoint> pts) {
    // "Improving" means moving toward normal range
    final target = (def.normalMin + def.normalMax) / 2;
    for (int i = 1; i < pts.length; i++) {
      final prevDist = (pts[i - 1].value - target).abs();
      final currDist = (pts[i].value - target).abs();
      if (currDist > prevDist + 0.1) return false;
    }
    return true;
  }

  String _criticalRec(LabMetricDef def) {
    return switch (def.key) {
      'anc' =>
        'ANC in critical range — severe neutropenia. If you have a fever ≥38°C (100.4°F), go to the ER immediately. Avoid crowded places.',
      'wbc' =>
        'Very low WBC. Wash hands frequently. Avoid sick contacts. Report any fever to your oncology team right away.',
      'platelets' =>
        'Critically low platelets — high bleeding risk. Avoid NSAIDs, falls, and cuts. Report any bruising or unusual bleeding immediately.',
      'hemoglobin' =>
        'Very low hemoglobin. You may need a transfusion. Report extreme fatigue, shortness of breath, or chest pain to your care team.',
      'creatinine' =>
        'Critical creatinine — possible acute kidney injury. Ensure adequate fluid intake. Your oncologist may need to adjust chemotherapy doses.',
      'potassium' =>
        'Critical potassium level — risk of dangerous heart rhythm. Go to emergency care if you feel palpitations, muscle weakness, or cramping.',
      _ =>
        'This value is in the critical range. Contact your oncology care team today or proceed to your nearest emergency department.',
    };
  }

  String _fmt(double v) => v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  String _zoneLabel(LabZone z) => switch (z) {
        LabZone.green => 'Normal',
        LabZone.orange => 'Borderline',
        LabZone.red => 'Abnormal',
        LabZone.critical => 'Critical',
      };

  // ── Demo / Seed Data ──────────────────────────────────────────────────────
  /// Seeds 6 realistic reports spanning 8 weeks of chemo treatment
  Future<void> seedDemoData() async {
    if (_reports.isNotEmpty) return;
    final rng = Random(42);
    final now = DateTime.now();

    // Baseline — 8 weeks ago (pre-chemo)
    final t0 = now.subtract(const Duration(days: 56));

    final demoReports = [
      // Week 0 — baseline (mostly normal, slightly elevated CA 15-3)
      _buildReport('Baseline CBC & Metabolic', 'Oncology Clinic', t0, {
        'wbc': 6.8, 'anc': 3.5, 'rbc': 4.2, 'hemoglobin': 13.1,
        'platelets': 245, 'hematocrit': 40.0,
        'creatinine': 0.9, 'alt': 32, 'ast': 28, 'glucose': 88,
        'sodium': 140, 'potassium': 4.0,
        'ca153': 48.0, 'cea': 5.2,
      }),

      // Week 2 — cycle 1 chemo nadir approaching
      _buildReport('Cycle 1 – Week 2', 'Hospital Lab', t0.add(const Duration(days: 14)), {
        'wbc': 3.2, 'anc': 1.2, 'rbc': 3.9, 'hemoglobin': 11.8,
        'platelets': 140, 'hematocrit': 36.0,
        'creatinine': 1.0, 'alt': 45, 'ast': 38, 'glucose': 95,
        'sodium': 138, 'potassium': 3.7,
        'ca153': 38.5, 'cea': 4.0,
      }),

      // Week 3 — nadir (lowest CBC)
      _buildReport('Cycle 1 – Nadir', 'Hospital Lab', t0.add(const Duration(days: 21)), {
        'wbc': 1.8, 'anc': 0.7, 'rbc': 3.4, 'hemoglobin': 9.6,
        'platelets': 62, 'hematocrit': 29.0,
        'creatinine': 1.1, 'alt': 68, 'ast': 52, 'glucose': 105,
        'sodium': 136, 'potassium': 3.3,
        'ca153': 31.0, 'cea': 3.2,
      }),

      // Week 5 — recovery
      _buildReport('Cycle 1 – Recovery', 'Oncology Clinic', t0.add(const Duration(days: 35)), {
        'wbc': 4.1, 'anc': 2.0, 'rbc': 3.8, 'hemoglobin': 11.2,
        'platelets': 128, 'hematocrit': 34.0,
        'creatinine': 0.95, 'alt': 48, 'ast': 40, 'glucose': 92,
        'sodium': 139, 'potassium': 3.8,
        'ca153': 24.5, 'cea': 2.8,
      }),

      // Week 7 — pre-cycle 2
      _buildReport('Pre-Cycle 2 Panel', 'Quest Diagnostics', t0.add(const Duration(days: 49)), {
        'wbc': 5.6, 'anc': 2.8, 'rbc': 4.0, 'hemoglobin': 12.3,
        'platelets': 175, 'hematocrit': 37.5,
        'creatinine': 0.88, 'alt': 38, 'ast': 32, 'glucose': 91,
        'sodium': 141, 'potassium': 4.1,
        'ca153': 19.2, 'cea': 2.2,
      }),

      // Current — week 8, cycle 2 starting, slight concern
      _buildReport('Current – Cycle 2 Day 3', 'Hospital Lab', t0.add(const Duration(days: 56)), {
        'wbc': 4.9, 'anc': 2.4, 'rbc': 3.9, 'hemoglobin': 11.9,
        'platelets': 162, 'hematocrit': 36.8,
        'creatinine': 0.92, 'alt': 42, 'ast': 35, 'glucose': 118,
        'sodium': 140, 'potassium': 3.6,
        'ca153': 17.0, 'cea': 1.8,
      }),
    ];

    for (final r in demoReports) {
      _reports.add(r);
    }
    _reports.sort((a, b) => a.date.compareTo(b.date));
    await _persist();
    notifyListeners();
  }

  LabReport _buildReport(String name, String source, DateTime date,
      Map<String, double> values) {
    final entries = values.entries.map((e) {
      final def = LabCatalog.byKey(e.key);
      return LabEntry(
          metricKey: e.key, value: e.value, unit: def?.unit ?? '');
    }).toList();
    return LabReport(
      id: 'demo_${date.millisecondsSinceEpoch}',
      date: date,
      reportName: name,
      source: source,
      entries: entries,
    );
  }
}
