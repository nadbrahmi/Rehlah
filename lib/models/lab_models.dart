// ─── Lab Report & Metric Models ───────────────────────────────────────────────

// A single uploaded lab report
class LabReport {
  final String id;
  final DateTime date;
  final String reportName; // e.g. "CBC Panel – Jan 15"
  final String source;     // "Hospital Lab", "Quest Diagnostics", etc.
  final List<LabEntry> entries;

  LabReport({
    required this.id,
    required this.date,
    required this.reportName,
    required this.source,
    required this.entries,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'reportName': reportName,
        'source': source,
        'entries': entries.map((e) => e.toMap()).toList(),
      };

  factory LabReport.fromMap(Map<String, dynamic> m) => LabReport(
        id: m['id'] ?? '',
        date: DateTime.parse(m['date']),
        reportName: m['reportName'] ?? '',
        source: m['source'] ?? '',
        entries: (m['entries'] as List? ?? []).map((e) => LabEntry.fromMap(e)).toList(),
      );
}

// One measurement within a lab report
class LabEntry {
  final String metricKey;  // canonical key e.g. "wbc", "hemoglobin", "ca153"
  final double value;
  final String unit;

  LabEntry({required this.metricKey, required this.value, required this.unit});

  Map<String, dynamic> toMap() => {'metricKey': metricKey, 'value': value, 'unit': unit};
  factory LabEntry.fromMap(Map<String, dynamic> m) => LabEntry(
        metricKey: m['metricKey'] ?? '',
        value: (m['value'] as num).toDouble(),
        unit: m['unit'] ?? '',
      );
}

// One data point on a metric's timeline
class LabDataPoint {
  final DateTime date;
  final double value;
  final String reportId;

  LabDataPoint({required this.date, required this.value, required this.reportId});
}

// Severity zone for a data point
enum LabZone { green, orange, red, critical }

// AI-detected pattern type
enum PatternType {
  steadyImprovement,
  rapidDecline,
  criticalAlert,
  nadirDetected,
  normalRestored,
  risingConcern,
  stable,
}

class LabPattern {
  final PatternType type;
  final String metricKey;
  final String title;
  final String description;
  final String recommendation;
  final LabZone severity;

  const LabPattern({
    required this.type,
    required this.metricKey,
    required this.title,
    required this.description,
    required this.recommendation,
    required this.severity,
  });
}

// Static metric definitions – normal ranges, zones, metadata
class LabMetricDef {
  final String key;
  final String name;
  final String shortName;
  final String unit;
  final String panel;      // "CBC", "Metabolic", "Tumor Markers"
  final double normalMin;
  final double normalMax;
  final double? orangeLow;  // borderline low
  final double? orangeHigh; // borderline high
  final double? redLow;     // dangerous low
  final double? redHigh;    // dangerous high
  final bool lowerIsBetter; // true for tumor markers
  final String aiContext;   // clinical description

  const LabMetricDef({
    required this.key,
    required this.name,
    required this.shortName,
    required this.unit,
    required this.panel,
    required this.normalMin,
    required this.normalMax,
    this.orangeLow,
    this.orangeHigh,
    this.redLow,
    this.redHigh,
    this.lowerIsBetter = false,
    required this.aiContext,
  });

  LabZone zoneFor(double v) {
    if (redLow != null && v <= redLow!) return LabZone.critical;
    if (redHigh != null && v >= redHigh!) return LabZone.critical;
    if (orangeLow != null && v < normalMin && v > (redLow ?? double.negativeInfinity)) return LabZone.orange;
    if (orangeHigh != null && v > normalMax && v < (redHigh ?? double.infinity)) return LabZone.orange;
    if (v < normalMin || v > normalMax) return LabZone.red;
    return LabZone.green;
  }
}

// ─── Canonical Metric Catalog ──────────────────────────────────────────────────
class LabCatalog {
  static const List<LabMetricDef> all = [
    // CBC
    LabMetricDef(key: 'wbc', name: 'White Blood Cells', shortName: 'WBC',
        unit: '×10³/µL', panel: 'CBC', normalMin: 4.5, normalMax: 11.0,
        orangeLow: 3.0, redLow: 2.0,
        aiContext: 'Infection-fighting cells. Low WBC (neutropenia) means high infection risk during chemo nadir.'),
    LabMetricDef(key: 'anc', name: 'Abs. Neutrophil Count', shortName: 'ANC',
        unit: '×10³/µL', panel: 'CBC', normalMin: 1.5, normalMax: 8.0,
        orangeLow: 1.0, redLow: 0.5,
        aiContext: 'Most critical infection-risk marker. ANC <0.5 = severe neutropenia. Report fever ≥38°C immediately.'),
    LabMetricDef(key: 'rbc', name: 'Red Blood Cells', shortName: 'RBC',
        unit: '×10⁶/µL', panel: 'CBC', normalMin: 3.8, normalMax: 5.2,
        orangeLow: 3.2, redLow: 2.5,
        aiContext: 'Oxygen carriers. Low RBC = anemia → fatigue, breathlessness.'),
    LabMetricDef(key: 'hemoglobin', name: 'Hemoglobin', shortName: 'Hgb',
        unit: 'g/dL', panel: 'CBC', normalMin: 12.0, normalMax: 17.5,
        orangeLow: 10.0, redLow: 8.0,
        aiContext: 'Hemoglobin carries oxygen. Levels <10 g/dL may require intervention. Monitor fatigue closely.'),
    LabMetricDef(key: 'platelets', name: 'Platelets', shortName: 'PLT',
        unit: '×10³/µL', panel: 'CBC', normalMin: 150, normalMax: 400,
        orangeLow: 75, redLow: 50,
        aiContext: 'Clotting cells. Low platelets = bleeding risk. Avoid NSAIDs. Report unusual bruising.'),
    LabMetricDef(key: 'hematocrit', name: 'Hematocrit', shortName: 'Hct',
        unit: '%', panel: 'CBC', normalMin: 36, normalMax: 52,
        orangeLow: 30, redLow: 24,
        aiContext: 'Percentage of blood volume that is red cells. Closely follows hemoglobin trends.'),
    // Metabolic
    LabMetricDef(key: 'creatinine', name: 'Creatinine', shortName: 'Creat',
        unit: 'mg/dL', panel: 'Metabolic', normalMin: 0.6, normalMax: 1.2,
        orangeHigh: 1.5, redHigh: 2.0,
        aiContext: 'Kidney function. Elevated creatinine may require dose adjustments of chemo drugs.'),
    LabMetricDef(key: 'alt', name: 'Liver ALT', shortName: 'ALT',
        unit: 'U/L', panel: 'Metabolic', normalMin: 7, normalMax: 56,
        orangeHigh: 120, redHigh: 200,
        aiContext: 'Liver enzyme. Elevated after some chemo drugs. Limit alcohol. Monitor trajectory.'),
    LabMetricDef(key: 'ast', name: 'Liver AST', shortName: 'AST',
        unit: 'U/L', panel: 'Metabolic', normalMin: 10, normalMax: 40,
        orangeHigh: 80, redHigh: 120,
        aiContext: 'Another liver enzyme. Rising AST alongside ALT needs urgent review.'),
    LabMetricDef(key: 'bilirubin', name: 'Total Bilirubin', shortName: 'Bili',
        unit: 'mg/dL', panel: 'Metabolic', normalMin: 0.2, normalMax: 1.2,
        orangeHigh: 2.0, redHigh: 3.0,
        aiContext: 'Bile pigment. High bilirubin causes jaundice. May indicate liver or bile duct issues.'),
    LabMetricDef(key: 'glucose', name: 'Blood Glucose', shortName: 'Gluc',
        unit: 'mg/dL', panel: 'Metabolic', normalMin: 70, normalMax: 100,
        orangeHigh: 140, redHigh: 250, redLow: 60,
        aiContext: 'May be elevated by corticosteroids in chemo regimens. Monitor for diabetic symptoms.'),
    LabMetricDef(key: 'sodium', name: 'Sodium', shortName: 'Na',
        unit: 'mEq/L', panel: 'Metabolic', normalMin: 136, normalMax: 145,
        orangeLow: 130, redLow: 125,
        aiContext: 'Electrolyte balance. Low sodium often from vomiting/poor intake. Stay well hydrated.'),
    LabMetricDef(key: 'potassium', name: 'Potassium', shortName: 'K',
        unit: 'mEq/L', panel: 'Metabolic', normalMin: 3.5, normalMax: 5.0,
        orangeLow: 3.0, redLow: 2.5, orangeHigh: 5.5, redHigh: 6.0,
        aiContext: 'Critical electrolyte. Low potassium causes muscle weakness and heart rhythm issues.'),
    // Tumor Markers
    LabMetricDef(key: 'ca153', name: 'Cancer Antigen 15-3', shortName: 'CA 15-3',
        unit: 'U/mL', panel: 'Tumor Markers', normalMin: 0, normalMax: 31,
        orangeHigh: 50, redHigh: 80,
        lowerIsBetter: true,
        aiContext: 'Breast cancer marker. Declining = strong treatment response. Never interpret alone without imaging.'),
    LabMetricDef(key: 'cea', name: 'Carcinoembryonic Ag', shortName: 'CEA',
        unit: 'ng/mL', panel: 'Tumor Markers', normalMin: 0, normalMax: 3,
        orangeHigh: 6, redHigh: 10,
        lowerIsBetter: true,
        aiContext: 'Colorectal/breast marker. Steady decline = positive response. Single readings less useful than trend.'),
    LabMetricDef(key: 'ca125', name: 'Cancer Antigen 125', shortName: 'CA-125',
        unit: 'U/mL', panel: 'Tumor Markers', normalMin: 0, normalMax: 35,
        orangeHigh: 65, redHigh: 100,
        lowerIsBetter: true,
        aiContext: 'Ovarian cancer marker. Track trend over treatment cycles, not individual values.'),
    LabMetricDef(key: 'psa', name: 'PSA', shortName: 'PSA',
        unit: 'ng/mL', panel: 'Tumor Markers', normalMin: 0, normalMax: 4,
        orangeHigh: 10, redHigh: 20,
        lowerIsBetter: true,
        aiContext: 'Prostate cancer marker. Rapid doubling is more significant than absolute value.'),
  ];

  static LabMetricDef? byKey(String key) {
    try { return all.firstWhere((d) => d.key == key); } catch (_) { return null; }
  }

  static List<LabMetricDef> byPanel(String panel) =>
      all.where((d) => d.panel == panel).toList();

  static const List<String> panels = ['CBC', 'Metabolic', 'Tumor Markers'];

  // Common aliases for AI parsing
  static const Map<String, String> aliases = {
    'white blood cell': 'wbc', 'white blood cells': 'wbc',
    'neutrophil': 'anc', 'absolute neutrophil': 'anc', 'anc': 'anc',
    'red blood cell': 'rbc', 'red blood cells': 'rbc',
    'hgb': 'hemoglobin', 'haemoglobin': 'hemoglobin', 'hb': 'hemoglobin',
    'plt': 'platelets', 'thrombocytes': 'platelets',
    'hct': 'hematocrit',
    'creat': 'creatinine', 'cr': 'creatinine',
    'sgpt': 'alt', 'liver alt': 'alt',
    'sgot': 'ast', 'liver ast': 'ast',
    'bili': 'bilirubin', 'total bilirubin': 'bilirubin',
    'gluc': 'glucose', 'blood sugar': 'glucose', 'fbs': 'glucose',
    'na': 'sodium',
    'k': 'potassium',
    'ca15-3': 'ca153', 'ca 15-3': 'ca153', 'cancer antigen 15': 'ca153',
    'carcinoembryonic': 'cea',
    'ca-125': 'ca125', 'cancer antigen 125': 'ca125',
  };

  static String? resolveAlias(String raw) {
    final lower = raw.toLowerCase().trim();
    return aliases[lower] ?? (all.any((d) => d.key == lower) ? lower : null);
  }
}
