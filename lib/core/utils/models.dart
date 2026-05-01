// ── Rehlah · Data Models ──────────────────────────────────────────────────────

enum MoodLevel { hard, low, okay, good, great }

extension MoodEmoji on MoodLevel {
  String get emoji {
    switch (this) {
      case MoodLevel.hard: return '😔';
      case MoodLevel.low: return '😕';
      case MoodLevel.okay: return '😐';
      case MoodLevel.good: return '🙂';
      case MoodLevel.great: return '😊';
    }
  }
  String get label {
    switch (this) {
      case MoodLevel.hard: return 'Hard';
      case MoodLevel.low: return 'Low';
      case MoodLevel.okay: return 'Okay';
      case MoodLevel.good: return 'Good';
      case MoodLevel.great: return 'Great';
    }
  }
}

class DailyCheckIn {
  final DateTime date;
  final MoodLevel mood;
  final List<String> symptoms;
  final Map<String, int> symptomScores; // fatigue/pain/nausea/fever/mood 0–10
  final String? note;

  const DailyCheckIn({
    required this.date,
    required this.mood,
    required this.symptoms,
    required this.symptomScores,
    this.note,
  });

  factory DailyCheckIn.empty() => DailyCheckIn(
    date: DateTime.now(),
    mood: MoodLevel.okay,
    symptoms: [],
    symptomScores: {},
  );
}

class LabResult {
  final String id;
  final String panelName; // "CBC", "Metabolic", "Tumour"
  final DateTime date;
  final List<LabMetric> metrics;
  final String? aiSummary;

  const LabResult({
    required this.id, required this.panelName,
    required this.date, required this.metrics, this.aiSummary,
  });
}

class LabMetric {
  final String name;
  final double value;
  final String unit;
  final double normalMin;
  final double normalMax;
  final double? previousValue;

  const LabMetric({
    required this.name, required this.value, required this.unit,
    required this.normalMin, required this.normalMax, this.previousValue,
  });

  bool get isLow => value < normalMin;
  bool get isHigh => value > normalMax;
  bool get isNormal => !isLow && !isHigh;

  double? get trend => previousValue != null ? value - previousValue! : null;
}

class Medication {
  final String id;
  final String name;
  final String dose;
  final String frequency;
  final String emoji;
  final String category;
  final String? notes;
  final DateTime? startDate;
  final int? totalSupply; // total doses in pack (e.g. 30 tablets)

  const Medication({
    required this.id, required this.name, required this.dose,
    required this.frequency, required this.emoji,
    this.category = 'other', this.notes, this.startDate,
    this.totalSupply,
  });

  // Doses per day derived from frequency string
  int get dosesPerDay {
    final f = frequency.toLowerCase();
    if (f.contains('twice') || f.contains('2x') || f.contains('two')) return 2;
    if (f.contains('three') || f.contains('3x')) return 3;
    return 1;
  }
}

class Appointment {
  final String id;
  final String title;
  final String doctorName;
  final String location;
  final DateTime dateTime;
  final bool isPast;

  const Appointment({
    required this.id, required this.title, required this.doctorName,
    required this.location, required this.dateTime, this.isPast = false,
  });

  int get daysUntil => dateTime.difference(DateTime.now()).inDays;
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text, required this.isUser, required this.timestamp,
  });
}

class UserProfile {
  final String name;
  final String cancerType;
  final String stage;
  final String treatmentPhase;
  final DateTime treatmentStarted;
  final int totalCycles;
  final int currentCycle;
  final int currentDayInCycle;

  const UserProfile({
    required this.name,
    required this.cancerType,
    this.stage = '',
    required this.treatmentPhase,
    required this.treatmentStarted,
    required this.totalCycles,
    required this.currentCycle,
    required this.currentDayInCycle,
  });

  static UserProfile get sample => UserProfile(
    name: 'Nadia',
    cancerType: 'Breast cancer',
    stage: 'Stage II',
    treatmentPhase: 'Chemotherapy',
    treatmentStarted: DateTime(2026, 3, 4),
    totalCycles: 12,
    currentCycle: 6,
    currentDayInCycle: 7,
  );

  bool get isNadirWindow =>
      currentDayInCycle >= 8 && currentDayInCycle <= 14;
}

// ── App configuration — single source of truth ───────────────────────────────
class AppConfig {
  static const treatmentPhases = [
    ('Just diagnosed',          '🌱'),
    ('Awaiting treatment plan', '📋'),
    ('In chemotherapy',         '💊'),
    ('In radiotherapy',         '⚡'),
    ('Post-surgery recovery',   '🌿'),
    ('Monitoring / surveillance','🎗️'),
  ];

  static const cancerTypes = [
    'Breast cancer',
    'Lung cancer',
    'Colorectal cancer',
    'Prostate cancer',
    'Cervical cancer',
    'Ovarian cancer',
    'Lymphoma',
    'Leukaemia',
    'Other',
  ];

  static List<String> get phaseNames =>
      treatmentPhases.map((p) => p.$1).toList();

  static String emojiForPhase(String phase) =>
      treatmentPhases.firstWhere(
        (p) => p.$1 == phase,
        orElse: () => (phase, '💜')).$2;
}


abstract class MockData {
  static final profile = UserProfile.sample;

  static final labs = [
    LabResult(
      id: 'cbc-apr20',
      panelName: 'CBC',
      date: DateTime(2026, 4, 20),
      aiSummary: 'WBC stable. Hemoglobin dip expected at week 6. '
          'Rest and iron-rich foods. Mention at Apr 28 appointment.',
      metrics: const [
        LabMetric(name: 'Hemoglobin', value: 10.2, unit: 'g/dL',
            normalMin: 12, normalMax: 17.5, previousValue: 11.4),
        LabMetric(name: 'WBC', value: 5.8, unit: '×10³/µL',
            normalMin: 4.5, normalMax: 11, previousValue: 6.1),
        LabMetric(name: 'Platelets', value: 182, unit: '×10³/µL',
            normalMin: 150, normalMax: 400, previousValue: 195),
      ],
    ),
    LabResult(
      id: 'cbc-apr6',
      panelName: 'CBC',
      date: DateTime(2026, 4, 6),
      metrics: const [
        LabMetric(name: 'Hemoglobin', value: 11.4, unit: 'g/dL',
            normalMin: 12, normalMax: 17.5, previousValue: 12.1),
        LabMetric(name: 'WBC', value: 6.1, unit: '×10³/µL',
            normalMin: 4.5, normalMax: 11, previousValue: 6.8),
        LabMetric(name: 'Platelets', value: 195, unit: '×10³/µL',
            normalMin: 150, normalMax: 400, previousValue: 210),
      ],
    ),
  ];

  static final appointments = [
    Appointment(
      id: 'apt1', title: 'Oncology follow-up',
      doctorName: 'Dr. Sarah Chen', location: 'Oncology Clinic',
      dateTime: DateTime.now().add(const Duration(days: 4))
          .copyWith(hour: 10, minute: 30, second: 0),
    ),
    Appointment(
      id: 'apt2', title: 'Chemo session #7',
      doctorName: '', location: 'Infusion Suite B',
      dateTime: DateTime.now().add(const Duration(days: 11))
          .copyWith(hour: 9, minute: 0, second: 0),
    ),
    Appointment(
      id: 'apt3', title: 'Chemo session #6',
      doctorName: '', location: 'Infusion Suite B',
      dateTime: DateTime.now().subtract(const Duration(days: 10))
          .copyWith(hour: 9, minute: 0, second: 0),
      isPast: true,
    ),
  ];

  static final moodHistory = [
    (day: 'Sat', mood: MoodLevel.hard),
    (day: 'Sun', mood: MoodLevel.low),
    (day: 'Mon', mood: MoodLevel.okay),
    (day: 'Tue', mood: MoodLevel.low),
    (day: 'Wed', mood: MoodLevel.okay),
    (day: 'Thu', mood: MoodLevel.good),
    (day: 'Today', mood: MoodLevel.okay),
  ];

  static const symptoms = [
    'Fatigue', 'Pain', 'Nausea', 'Anxiety',
    'Poor sleep', 'Appetite', 'Isolation',
  ];
}
