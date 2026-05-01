import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'protocols.dart';

// ── Check-in record ───────────────────────────────────────────────────────────
class CheckInRecord {
  final DateTime date;
  final String moodEmoji;
  final String moodLabel;
  final Map<String, double> symptomScores;
  final Map<String, String> interferenceAnswers;
  final String note;
  final int dayInCycle;
  final int cycle;

  const CheckInRecord({
    required this.date,
    required this.moodEmoji,
    required this.moodLabel,
    required this.symptomScores,
    required this.interferenceAnswers,
    required this.note,
    required this.dayInCycle,
    required this.cycle,
  });

  // Severity summary for display
  String get severitySummary {
    if (symptomScores.isEmpty) return 'No symptoms reported';
    final severe = symptomScores.entries.where((e) => e.value >= 7).length;
    final moderate = symptomScores.entries
        .where((e) => e.value >= 4 && e.value < 7).length;
    if (severe > 0) return '$severe severe symptom${severe > 1 ? 's' : ''}';
    if (moderate > 0) return '$moderate moderate symptom${moderate > 1 ? 's' : ''}';
    return 'Mild symptoms';
  }
}

// ── User session ──────────────────────────────────────────────────────────────
class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._();
  factory UserSession() => _instance;
  UserSession._();

  // ── Onboarding ────────────────────────────────────────────────────────────
  String _name = 'there';
  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }
  String cancerType = 'Breast cancer';
  String treatmentPhase = 'In chemotherapy';
  int whoIndex = 0;

  // ── Protocol ─────────────────────────────────────────────────────────────
  BreastProtocol protocol = BreastProtocol.act;
  bool isTaxolPhase = false;
  int currentCycle = 2;
  int totalCycles = 8;
  int dayInCycle = 7;

  // ── Computed phase ────────────────────────────────────────────────────────
  ChemoPhase get currentPhase => ProtocolResolver.resolve(
    protocol, dayInCycle, isTaxolPhase: isTaxolPhase);

  bool get isNadirWindow => currentPhase.isNadir;

  bool get isNadirApproaching {
    final nextPhase = ProtocolResolver.resolve(
      protocol, dayInCycle + 2, isTaxolPhase: isTaxolPhase);
    return !currentPhase.isNadir && nextPhase.isNadir;
  }

  String get phaseContext =>
      '${protocol.name} · Cycle $currentCycle of $totalCycles · '
      'Day $dayInCycle · ${currentPhase.name}'
      '${isNadirWindow ? " · NADIR WINDOW" : ""}';

  // ── Latest check-in ───────────────────────────────────────────────────────
  String moodEmoji = '';
  String moodLabel = '';
  Map<String, double> symptomScores = {};
  Map<String, String> interferenceAnswers = {};
  String checkInNote = '';
  DateTime? lastCheckIn;

  // ── Check-in history (last 30 entries) ───────────────────────────────────
  final List<CheckInRecord> _history = [];

  List<CheckInRecord> get history => List.unmodifiable(_history);

  // ── Rebuild counter (increments on each check-in save) ───────────────────
  int _saveCount = 0;
  int get saveCount => _saveCount;

  void saveCheckIn() {
    final emoji = moodEmoji.isNotEmpty ? moodEmoji : '😐';
    final label = moodLabel.isNotEmpty ? moodLabel : 'Okay';

    _history.removeWhere((r) =>
        r.date.year == DateTime.now().year &&
        r.date.month == DateTime.now().month &&
        r.date.day == DateTime.now().day);

    _history.add(CheckInRecord(
      date: DateTime.now(),
      moodEmoji: emoji,
      moodLabel: label,
      symptomScores: Map.from(symptomScores),
      interferenceAnswers: Map.from(interferenceAnswers),
      note: checkInNote,
      dayInCycle: dayInCycle,
      cycle: currentCycle,
    ));

    if (_history.length > 30) {
      _history.removeRange(0, _history.length - 30);
    }

    lastCheckIn = DateTime.now();
    _saveCount++;
  }

  /// Get last 7 days of check-ins (with gaps for missed days)
  List<DayMood> get last7Days {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final label = i == 6 ? 'Today' : _shortDay(day.weekday);
      final record = _history.where((r) =>
          r.date.year == day.year &&
          r.date.month == day.month &&
          r.date.day == day.day).firstOrNull;
      return DayMood(
        label: label,
        emoji: record?.moodEmoji ?? '',
        hasData: record != null,
      );
    });
  }

  String _shortDay(int weekday) {
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return days[weekday - 1];
  }

  /// Streak — consecutive days with check-ins
  int get streak {
    if (_history.isEmpty) return 0;
    int count = 0;
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      final hasEntry = _history.any((r) =>
          r.date.year == day.year &&
          r.date.month == day.month &&
          r.date.day == day.day);
      if (hasEntry) {
        count++;
      } else if (i > 0) {
        break; // Gap found
      }
    }
    return count;
  }

  bool get checkedInToday {
    if (lastCheckIn == null) return false;
    final now = DateTime.now();
    return lastCheckIn!.year == now.year &&
        lastCheckIn!.month == now.month &&
        lastCheckIn!.day == now.day;
  }

  // ── Medications ───────────────────────────────────────────────────────────
  // Key: med id, Value: time taken today (null = not taken)
  final Map<String, String?> _medsTakenToday = {};
  // Key: med id, Value: total days taken (for adherence)
  final Map<String, int> _medsAdherenceCount = {};
  // Track which day the meds were last reset
  int? _medsLastResetDay;

  void _resetMedsIfNewDay() {
    final today = DateTime.now().day;
    if (_medsLastResetDay != today) {
      _medsTakenToday.clear();
      _medsLastResetDay = today;
    }
  }

  bool isMedTaken(String medId) {
    _resetMedsIfNewDay();
    return _medsTakenToday.containsKey(medId);
  }

  String? medTakenAt(String medId) {
    _resetMedsIfNewDay();
    return _medsTakenToday[medId];
  }

  void markMedTaken(String medId) {
    _resetMedsIfNewDay();
    final time = DateFormat('h:mm a').format(DateTime.now());
    _medsTakenToday[medId] = time;
    _medsAdherenceCount[medId] = (_medsAdherenceCount[medId] ?? 0) + 1;
    _saveCount++;
    notifyListeners();
  }

  int get medsTakenTodayCount {
    _resetMedsIfNewDay();
    return _medsTakenToday.length;
  }

  // Track whether cycle/day were explicitly set by user
  bool cycleDaySetByUser = false;

  /// Profile completion % based on filled fields
  int get profileCompletionPct {
    int filled = 0;
    const total = 5;
    if (name.isNotEmpty && name != 'there') filled++;
    if (cancerType.isNotEmpty) filled++;
    if (treatmentPhase.isNotEmpty) filled++;
    if (treatmentPhase == 'In chemotherapy') {
      filled++; // protocol selected
    } else {
      filled++; // non-chemo gets credit too
    }
    if (history.isNotEmpty) filled++; // has checked in at least once
    return ((filled / total) * 100).round().clamp(0, 100);
  }

  List<String> get profileMissingFields {
    final missing = <String>[];
    if (name.isEmpty || name == 'there') missing.add('Your name');
    if (history.isEmpty) missing.add('First check-in');
    return missing;
  }
  int adherencePct(int totalMeds) {
    if (totalMeds == 0) return 0;
    final totalPossible = totalMeds * 14;
    final totalTaken = _medsAdherenceCount.values
        .fold(0, (sum, v) => sum + v);
    return ((totalTaken / totalPossible) * 100).round().clamp(0, 100);
  }
  String get symptomSummary {
    if (symptomScores.isEmpty) return 'no symptoms reported';
    final parts = symptomScores.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key.replaceAll("_", " ")} ${e.value.toInt()}/10')
        .toList();
    return parts.isEmpty ? 'no symptoms reported' : parts.join(', ');
  }

  // ── Monitoring & Surveillance ─────────────────────────────────────────────
  DateTime? treatmentEndDate;
  String menstrualStatus = 'unknown';
  DateTime? lastPeriodDate;
  int cycleLength = 28;
  final List<ControlRecord> _controls = [];

  List<ControlRecord> get controls => List.unmodifiable(_controls);

  void addControl(ControlRecord record) {
    _controls.removeWhere((c) => c.id == record.id);
    _controls.add(record);
    _controls.sort((a, b) => b.date.compareTo(a.date));
    _saveCount++;
    notifyListeners();
  }

  int get daysCancerFree {
    if (treatmentEndDate == null) return 0;
    return DateTime.now().difference(treatmentEndDate!).inDays;
  }

  // Next optimal MRI/Mammogram window — looks ahead up to 6 months
  // Best window is days 7-14 of cycle (follicular phase)
  DateTime? get nextOptimalWindowStart {
    if (menstrualStatus != 'regular') return null;
    if (lastPeriodDate == null) return null;
    final now = DateTime.now();
    final sixMonthsAhead = now.add(const Duration(days: 180));
    DateTime cycleStart = lastPeriodDate!;
    // Advance to current cycle
    while (cycleStart.add(Duration(days: cycleLength)).isBefore(now)) {
      cycleStart = cycleStart.add(Duration(days: cycleLength));
    }
    // Find the best window that is at least 2 weeks away (planning ahead)
    final planningStart = now.add(const Duration(days: 14));
    while (cycleStart.isBefore(sixMonthsAhead)) {
      final windowStart = cycleStart.add(const Duration(days: 6)); // day 7
      final windowEnd = cycleStart.add(const Duration(days: 13)); // day 14
      if (windowStart.isAfter(planningStart)) {
        return windowStart;
      }
      cycleStart = cycleStart.add(Duration(days: cycleLength));
    }
    return null;
  }

  DateTime? get nextOptimalWindowEnd {
    final start = nextOptimalWindowStart;
    if (start == null) return null;
    return start.add(const Duration(days: 7));
  }

  bool get isScanxietyPeriod {
    final next = nextControl;
    if (next?.nextScheduled == null) return false;
    return next!.nextScheduled!.difference(DateTime.now()).inDays <= 14;
  }

  ControlRecord? get nextControl {
    final upcoming = _controls
        .where((c) => c.nextScheduled != null &&
            c.nextScheduled!.isAfter(DateTime.now()))
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.nextScheduled!.compareTo(b.nextScheduled!));
    return upcoming.first;
  }

  ControlRecord? lastControlOfType(String type) {
    final filtered = _controls.where((c) => c.type == type).toList();
    if (filtered.isEmpty) return null;
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered.first;
  }

  bool get isMonitoring => treatmentPhase == 'Monitoring / surveillance';

  // ── Lab results ───────────────────────────────────────────────────────────
  final List<LabResult> _labs = [];
  bool _labsInitialized = false;

  List<LabResult> get labs {
    final sorted = [..._labs]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  void addLabResult(LabResult result) {
    _labs.removeWhere((l) => l.id == result.id);
    _labs.add(result);
    _saveCount++;
    notifyListeners();
  }

  void removeLabResult(String id) {
    _labs.removeWhere((l) => l.id == id);
    _saveCount++;
    notifyListeners();
  }

  void initDefaultLabs() {
    if (_labsInitialized) return;
    _labsInitialized = true;
    _labs.addAll([
      LabResult(
        id: 'cbc-1',
        panelName: 'CBC',
        date: DateTime.now().subtract(const Duration(days: 10)),
        metrics: [
          const LabMetric(name: 'Hemoglobin', value: 10.2, unit: 'g/dL',
            normalMin: 12, normalMax: 17.5, previousValue: 11.4),
          const LabMetric(name: 'WBC', value: 5.8, unit: '×10³/µL',
            normalMin: 4.5, normalMax: 11, previousValue: 6.1),
          const LabMetric(name: 'Platelets', value: 182, unit: '×10³/µL',
            normalMin: 150, normalMax: 400, previousValue: 195),
          const LabMetric(name: 'Neutrophils', value: 1.4, unit: '×10³/µL',
            normalMin: 1.8, normalMax: 7.7, previousValue: 2.1),
        ],
      ),
      LabResult(
        id: 'cbc-2',
        panelName: 'CBC',
        date: DateTime.now().subtract(const Duration(days: 24)),
        metrics: [
          const LabMetric(name: 'Hemoglobin', value: 11.4, unit: 'g/dL',
            normalMin: 12, normalMax: 17.5, previousValue: 12.1),
          const LabMetric(name: 'WBC', value: 6.1, unit: '×10³/µL',
            normalMin: 4.5, normalMax: 11, previousValue: 6.8),
          const LabMetric(name: 'Platelets', value: 195, unit: '×10³/µL',
            normalMin: 150, normalMax: 400, previousValue: 210),
          const LabMetric(name: 'Neutrophils', value: 2.1, unit: '×10³/µL',
            normalMin: 1.8, normalMax: 7.7, previousValue: 2.8),
        ],
      ),
    ]);
  }

  // ── Medications ───────────────────────────────────────────────────────────
  final List<Medication> _medications = [];
  bool _medsInitialized = false;

  List<Medication> get medications => List.unmodifiable(_medications);

  void initDefaultMedications() {
    if (_medsInitialized) return;
    _medsInitialized = true;
    if (isMonitoring) {
      // Use treatmentEndDate as Tamoxifen start if available
      final tamoxStart = treatmentEndDate ??
          DateTime.now().subtract(const Duration(days: 847));
      _medications.addAll([
        Medication(id: 'med1', name: 'Tamoxifen 20mg',
          dose: '1 tablet', frequency: 'Daily · Morning',
          emoji: '💊', category: 'hormone_therapy',
          startDate: tamoxStart,
          totalSupply: 30),
        Medication(id: 'med2', name: 'Vitamin D 1000 IU',
          dose: '1 capsule', frequency: 'Daily · With food',
          emoji: '🌤️', category: 'supplement'),
        Medication(id: 'med3', name: 'Calcium 500mg',
          dose: '1 tablet', frequency: 'Twice daily',
          emoji: '🦴', category: 'supplement'),
      ]);
    } else {
      _medications.addAll([
        Medication(id: 'med1', name: 'Tamoxifen 20mg',
          dose: '1 tablet', frequency: 'Daily',
          emoji: '💊', category: 'hormone_therapy',
          startDate: DateTime.now().subtract(const Duration(days: 30))),
        Medication(id: 'med2', name: 'Vitamin D 1000 IU',
          dose: '1 capsule', frequency: 'Daily',
          emoji: '🌤️', category: 'supplement'),
        Medication(id: 'med3', name: 'Pain Relief 500mg',
          dose: 'As needed', frequency: 'As needed',
          emoji: '🩹', category: 'symptomatic'),
      ]);
    }
  }

  // Hormone therapy streak — days since earliest hormone_therapy med start date
  Medication? get hormoneTherapyMed => _medications
      .where((m) => m.category == 'hormone_therapy' && m.startDate != null)
      .fold<Medication?>(null, (prev, m) =>
          prev == null || m.startDate!.isBefore(prev.startDate!)
              ? m : prev);

  int get hormoneTherapyDays {
    final med = hormoneTherapyMed;
    if (med?.startDate == null) return 0;
    return DateTime.now().difference(med!.startDate!).inDays;
  }

  // Milestone label for hormone therapy
  String? get hormoneTherapyMilestone {
    final days = hormoneTherapyDays;
    if (days >= 1825) return '5 years';   // 5yr — major milestone
    if (days >= 1460) return '4 years';
    if (days >= 1095) return '3 years';
    if (days >= 730)  return '2 years';
    if (days >= 365)  return '1 year';
    if (days >= 180)  return '6 months';
    if (days >= 90)   return '3 months';
    if (days >= 30)   return '1 month';
    return null;
  }

  // % progress toward recommended 5 years
  double get hormoneTherapyProgress =>
      (hormoneTherapyDays / 1825).clamp(0.0, 1.0);

  // Remaining doses for a medication (computed from pack size minus taken count)
  int? remainingDoses(String medId) {
    final med = _medications.firstWhere((m) => m.id == medId,
        orElse: () => Medication(id: '', name: '', dose: '',
            frequency: '', emoji: ''));
    if (med.totalSupply == null) return null;
    final taken = _medsAdherenceCount[medId] ?? 0;
    return (med.totalSupply! - taken).clamp(0, med.totalSupply!);
  }

  bool isMedRunningLow(String medId) {
    final rem = remainingDoses(medId);
    return rem != null && rem <= 7 && rem > 0;
  }

  bool isMedOutOfStock(String medId) {
    final rem = remainingDoses(medId);
    return rem != null && rem <= 0;
  }

  int? daysRemainingForMed(String medId) {
    final rem = remainingDoses(medId);
    final med = _medications.firstWhere((m) => m.id == medId,
        orElse: () => Medication(id: '', name: '', dose: '',
            frequency: '', emoji: ''));
    if (rem == null) return null;
    return (rem / med.dosesPerDay).floor();
  }

  // Medications running low or out of stock
  List<Medication> get medsRunningLow =>
      _medications.where((m) =>
          isMedRunningLow(m.id) || isMedOutOfStock(m.id)).toList();

  bool get hasRefillAlert => medsRunningLow.isNotEmpty;

  /// For demo/invite codes only — simulates doses taken without triggering UI
  void medsAdherenceSimulate(String medId) {
    _medsAdherenceCount[medId] = (_medsAdherenceCount[medId] ?? 0) + 1;
  }

  void addMedication(Medication med) {
    _medications.removeWhere((m) => m.id == med.id);
    _medications.add(med);
    _saveCount++;
    notifyListeners();
  }

  void removeMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    _medsAdherenceCount.remove(id);
    _medsTakenToday.remove(id);
    _saveCount++;
    notifyListeners();
  }

  void updateMedication(Medication med) {
    final idx = _medications.indexWhere((m) => m.id == med.id);
    if (idx >= 0) {
      _medications[idx] = med;
      _saveCount++;
      notifyListeners();
    }
  }

  // ── Greeting ─────────────────────────────────────────────────────────────
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get displayName => name.isEmpty ? 'there' : name;
}

class DayMood {
  final String label, emoji;
  final bool hasData;
  const DayMood({
    required this.label, required this.emoji, required this.hasData});
}

// ── Control record ────────────────────────────────────────────────────────────
class ControlRecord {
  final String id;
  final DateTime date;
  final String type; // 'mammogram', 'mri', 'ultrasound', 'oncology', 'gynecology', 'dexa', 'echo'
  final String result; // 'clear', 'follow_up', 'biopsy'
  final String? doctor;
  final String? location;
  final String? notes;
  final DateTime? nextScheduled;

  const ControlRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.result,
    this.doctor,
    this.location,
    this.notes,
    this.nextScheduled,
  });

  String get typeLabel {
    const labels = {
      'mammogram': 'Mammogram',
      'mri': 'MRI',
      'ultrasound': 'Ultrasound',
      'oncology': 'Oncology review',
      'gynecology': 'Gynecology review',
      'dexa': 'Bone density (DEXA)',
      'echo': 'Cardiac echo',
    };
    return labels[type] ?? type;
  }

  String get typeEmoji {
    const emojis = {
      'mammogram': '🎗️',
      'mri': '🧲',
      'ultrasound': '🔊',
      'oncology': '👨‍⚕️',
      'gynecology': '👩‍⚕️',
      'dexa': '🦴',
      'echo': '❤️',
    };
    return emojis[type] ?? '🏥';
  }

  String get resultLabel {
    const labels = {
      'clear': 'Clear ✓',
      'follow_up': 'Follow-up needed',
      'biopsy': 'Biopsy recommended',
    };
    return labels[result] ?? result;
  }

  Color get resultColor {
    switch (result) {
      case 'clear': return const Color(0xFF3DB87A);
      case 'follow_up': return const Color(0xFFE09060);
      case 'biopsy': return const Color(0xFFC04060);
      default: return const Color(0xFF6858A0);
    }
  }
}
