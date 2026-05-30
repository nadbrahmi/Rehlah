import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'protocols.dart';

// ── Check-in record ───────────────────────────────────────────────────────────
class CheckInRecord {
  final DateTime date;
  final String moodEmoji;
  final String moodLabel;
  final Map<String, double> symptomScores;
  final Map<String, bool> interferenceAnswers;
  final String note;
  final int dayInCycle;
  final int cycle;
  final String? physicalActivity; // 'none' | 'light' | 'moderate'
  final Map<String, int> hadsScores; // hads_tense/worry/panic/relaxed: 0–3

  const CheckInRecord({
    required this.date,
    required this.moodEmoji,
    required this.moodLabel,
    required this.symptomScores,
    required this.interferenceAnswers,
    required this.note,
    required this.dayInCycle,
    required this.cycle,
    this.physicalActivity,
    this.hadsScores = const {},
  });

  // HADS anxiety subscale score (0–12); -1 if not measured
  int get hadsAnxietyScore {
    if (hadsScores.isEmpty) return -1;
    final t = hadsScores['hads_tense'] ?? 0;
    final w = hadsScores['hads_worry'] ?? 0;
    final p = hadsScores['hads_panic'] ?? 0;
    final rel = hadsScores['hads_relaxed'] ?? 3; // reverse-scored
    return t + w + p + (3 - rel);
  }

  String get hadsAnxietyLevel {
    final s = hadsAnxietyScore;
    if (s < 0) return 'not_measured';
    if (s <= 4) return 'low';
    if (s <= 7) return 'moderate';
    return 'high';
  }

  bool get hasInterferenceToday =>
      interferenceAnswers.values.any((v) => v == true);

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
  String _name = 'Nadia';
  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }
  String language = 'en'; // 'en' | 'ar'
  String cancerType = 'Breast cancer · Grade II · ER+/PR+';
  String treatmentPhase = 'In chemotherapy';
  int whoIndex = 0;

  // ── Protocol ─────────────────────────────────────────────────────────────
  BreastProtocol protocol = BreastProtocol.act;
  bool isTaxolPhase = true;
  int currentCycle = 5;
  int totalCycles = 8;
  int dayInCycle = 4;

  // ── Supabase patient link ─────────────────────────────────────────────────
  String? supabasePatientId;
  DateTime? cycleStartDate;

  // ── Local persistence keys ─────────────────────────────────────────────────
  static const _kVitalsCache    = 'rehlah_vitals';
  static const _kCycleCache     = 'rehlah_cycle';
  static const _kMedsStateCache = 'rehlah_meds_state';

  Future<void> _saveVitalsCache() async {
    if (supabasePatientId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kVitalsCache,
          jsonEncode(_vitals.map((v) => v.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> loadVitalsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kVitalsCache);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      _vitals.clear();
      for (final item in list) {
        final v = VitalRecord.fromJson(item as Map<String, dynamic>);
        if (v != null) _vitals.add(v);
      }
    } catch (_) {}
  }

  Future<void> _saveCycleDataCache() async {
    if (supabasePatientId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kCycleCache, jsonEncode({
        'menstrual_status': _menstrualStatus,
        'last_period_date': _lastPeriodDate?.toIso8601String(),
        'cycle_length':     _cycleLength,
      }));
    } catch (_) {}
  }

  Future<void> loadCycleDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCycleCache);
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _menstrualStatus = (data['menstrual_status'] as String?) ?? 'unknown';
      final lpd = data['last_period_date'] as String?;
      _lastPeriodDate = lpd != null ? DateTime.tryParse(lpd) : null;
      _cycleLength = (data['cycle_length'] as int?) ?? 28;
    } catch (_) {}
  }

  // ── Medication state persistence ─────────────────────────────────────────
  // Persists today's taken map + adherence counts (adherence only for Supabase
  // users so we don't collide with demo simulation data).
  void _saveMedsState() {
    SharedPreferences.getInstance().then((prefs) {
      final data = <String, dynamic>{
        'day':   DateTime.now().day,
        'taken': Map<String, dynamic>.from(_medsTakenToday),
      };
      if (supabasePatientId != null) {
        data['adherence'] = Map<String, dynamic>.from(
            _medsAdherenceCount.map((k, v) => MapEntry(k, v)));
      }
      prefs.setString(_kMedsStateCache, jsonEncode(data));
    });
  }

  Future<void> loadMedsStateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kMedsStateCache);
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final savedDay = (data['day'] as num?)?.toInt();
      final today = DateTime.now().day;
      if (savedDay == today) {
        _medsLastResetDay = today;
        final taken = data['taken'] as Map<String, dynamic>? ?? {};
        _medsTakenToday.clear();
        taken.forEach((k, v) => _medsTakenToday[k] = v as String?);
      }
      if (supabasePatientId != null && data.containsKey('adherence')) {
        final adherence = data['adherence'] as Map<String, dynamic>? ?? {};
        _medsAdherenceCount.clear();
        adherence.forEach((k, v) =>
            _medsAdherenceCount[k] = (v as num).toInt());
      }
      notifyListeners();
    } catch (_) {}
  }

  /// Converts raw Supabase checkin rows into typed [CheckInRecord] objects
  /// and loads them into [_history] so streak/mood strip/FAB colour work
  /// correctly after a restart.
  void initCheckInHistoryTyped(List<Map<String, dynamic>> rows) {
    _history.clear();
    const moodLabels = ['Awful', 'Low', 'Okay', 'Good', 'Great'];
    for (final row in rows.reversed) {
      final createdAt = row['created_at'] as String?;
      if (createdAt == null) continue;
      // Convert to local time so checkedInToday (which uses DateTime.now())
      // compares correctly regardless of the Supabase server timezone.
      final date = DateTime.tryParse(createdAt)?.toLocal();
      if (date == null) continue;
      final scoreIdx = (row['mood_score'] as int?) ?? 2;
      final rawScores =
          (row['symptom_scores'] as Map<String, dynamic>?) ?? {};
      _history.add(CheckInRecord(
        date: date,
        moodEmoji: (row['mood'] as String?) ?? '😐',
        moodLabel: scoreIdx >= 0 && scoreIdx < moodLabels.length
            ? moodLabels[scoreIdx] : 'Okay',
        symptomScores: rawScores.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
        interferenceAnswers: {},
        note: (row['notes'] as String?) ?? '',
        dayInCycle: 0,
        cycle: 0,
      ));
    }
    if (_history.isNotEmpty) {
      lastCheckIn = _history.last.date;
      // Restore today's check-in state so the home screen and check-in
      // pre-fill work correctly after a browser refresh or cold start.
      final latest = _history.last;
      final now = DateTime.now();
      if (latest.date.year == now.year &&
          latest.date.month == now.month &&
          latest.date.day == now.day) {
        moodEmoji     = latest.moodEmoji;
        moodLabel     = latest.moodLabel;
        symptomScores = Map.from(latest.symptomScores);
        checkInNote   = latest.note;
      }
    }
  }

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
  Map<String, bool> interferenceAnswers = {};
  String checkInNote = '';
  DateTime? lastCheckIn;
  String? physicalActivity;
  Map<String, int> hadsScores = {};

  // ── Check-in history (last 30 entries) ───────────────────────────────────
  final List<CheckInRecord> _history = [];

  List<CheckInRecord> get history => List.unmodifiable(_history);

  // ── Rebuild counter (increments on each check-in save) ───────────────────
  int _saveCount = 0;
  int get saveCount => _saveCount;

  Future<void> saveCheckIn() async {
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
      interferenceAnswers: Map<String, bool>.from(interferenceAnswers),
      note: checkInNote,
      dayInCycle: dayInCycle,
      cycle: currentCycle,
      physicalActivity: physicalActivity,
      hadsScores: Map.from(hadsScores),
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

  bool get hasCheckedInToday => checkedInToday;

  // ── Check-in history (Supabase-fetched, last 14 rows) ─────────────────────
  List<Map<String, dynamic>> _checkinHistory = [];

  List<Map<String, dynamic>> get checkinHistory =>
      List.unmodifiable(_checkinHistory);

  void initCheckinHistoryFromData(List<Map<String, dynamic>> rows) {
    _checkinHistory = [...rows];
  }

  void initDefaultCheckinHistory() {
    if (_checkinHistory.isNotEmpty) return;
    initCheckinHistoryFromData(MockData.checkinHistory);
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
      _saveMedsState(); // persist the day reset so reload knows it's a new day
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
    _saveMedsState(); // persist immediately after marking taken
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
    if (isMonitoring) {
      if (treatmentEndDate != null) filled++;
    } else {
      filled++; // non-monitoring gets credit for phase alone
    }
    if (history.isNotEmpty) filled++; // first check-in required for 100%
    return ((filled / total) * 100).round().clamp(0, 100);
  }

  List<String> get profileMissingFields {
    final missing = <String>[];
    if (name.isEmpty || name == 'there') missing.add('Your name');
    if (isMonitoring && treatmentEndDate == null) missing.add('Treatment end date');
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

  int medAdherencePct(String medId) {
    return ((_medsAdherenceCount[medId] ?? 0) / 14 * 100).round().clamp(0, 100);
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

  String _menstrualStatus = 'unknown';
  String get menstrualStatus => _menstrualStatus;
  set menstrualStatus(String v) { _menstrualStatus = v; _saveCycleDataCache(); }

  DateTime? _lastPeriodDate;
  DateTime? get lastPeriodDate => _lastPeriodDate;
  set lastPeriodDate(DateTime? v) { _lastPeriodDate = v; _saveCycleDataCache(); }

  int _cycleLength = 28;
  int get cycleLength => _cycleLength;
  set cycleLength(int v) { _cycleLength = v; _saveCycleDataCache(); }
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

  static const _scanAppointmentKeywords = [
    'mammogram', 'mri', 'ultrasound', 'scan', 'ct ', 'pet ',
    'imaging', 'radiology', 'x-ray', 'biopsy', 'echo',
  ];

  bool get isScanxietyPeriod {
    if (!isMonitoring) return false;
    final nextApt = upcomingAppointments
        .where((a) {
          final title = a.title.toLowerCase();
          return _scanAppointmentKeywords.any((k) => title.contains(k));
        })
        .firstOrNull;
    if (nextApt == null) return false;
    return nextApt.daysUntil <= 14;
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

  // ── Appointments ──────────────────────────────────────────────────────────
  final List<Appointment> _appointments = [];
  bool _appointmentsInitialized = false;

  List<Appointment> get appointments {
    final sorted = [..._appointments]
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return List.unmodifiable(sorted);
  }

  List<Appointment> get upcomingAppointments =>
      appointments.where((a) => !a.isPast).toList();

  List<Appointment> get pastAppointments =>
      appointments.where((a) => a.isPast).toList();

  void initDefaultAppointments() {
    if (_appointmentsInitialized) return;
    _appointmentsInitialized = true;
    final now = DateTime.now();
    if (isMonitoring) {
      _appointments.addAll([
        Appointment(
          id: 'mon1', title: 'Annual mammogram',
          doctorName: 'Radiology Dept', location: 'Breast Imaging Centre',
          dateTime: now.add(const Duration(days: 11))
              .copyWith(hour: 9, minute: 0, second: 0)),
        Appointment(
          id: 'mon2', title: 'Oncology surveillance review',
          doctorName: 'Dr. Sarah Chen', location: 'Oncology Clinic',
          dateTime: now.add(const Duration(days: 32))
              .copyWith(hour: 10, minute: 30, second: 0)),
        Appointment(
          id: 'mon3', title: 'Oncology surveillance review',
          doctorName: 'Dr. Sarah Chen', location: 'Oncology Clinic',
          dateTime: now.subtract(const Duration(days: 180))
              .copyWith(hour: 10, minute: 30, second: 0),
          isPast: true),
      ]);
    } else {
      _appointments.addAll([
        Appointment(
          id: 'apt1', title: 'Consultation oncologie · Dr. Ben Abid',
          doctorName: 'Dr. Ben Abid', location: 'Oncologie ambulatoire',
          dateTime: now.add(const Duration(days: 2))
              .copyWith(hour: 10, minute: 0, second: 0)),
        Appointment(
          id: 'apt2', title: 'Chemo session #6',
          doctorName: '', location: 'Infusion Suite B',
          dateTime: now.add(const Duration(days: 17))
              .copyWith(hour: 9, minute: 0, second: 0)),
        Appointment(
          id: 'apt3', title: 'Chemo session #5',
          doctorName: '', location: 'Infusion Suite B',
          dateTime: now.subtract(const Duration(days: 4))
              .copyWith(hour: 9, minute: 0, second: 0),
          isPast: true),
      ]);
    }
  }

  void addAppointment(Appointment apt) {
    _appointments.removeWhere((a) => a.id == apt.id);
    _appointments.add(apt);
    _saveCount++;
    notifyListeners();
  }

  void removeAppointment(String id) {
    _appointments.removeWhere((a) => a.id == id);
    _saveCount++;
    notifyListeners();
  }

  void markAppointmentPast(String id) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      final a = _appointments[idx];
      _appointments[idx] = Appointment(
        id: a.id, title: a.title, doctorName: a.doctorName,
        location: a.location, dateTime: a.dateTime, isPast: true);
      _saveCount++;
      notifyListeners();
    }
  }

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

  /// Populate labs from Supabase rows (each row has nested `lab_metrics` list).
  /// Marks as initialized so initDefaultLabs() won't run afterward.
  void initLabsFromData(List<Map<String, dynamic>> labRows) {
    _labsInitialized = true;
    for (final row in labRows) {
      final dateStr = row['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      final metricsRaw = row['lab_metrics'] as List<dynamic>? ?? [];
      final metrics = metricsRaw.map((m) {
        final map = m as Map<String, dynamic>;
        return LabMetric(
          name:          map['name']  as String? ?? '',
          value:         (map['value']          as num?)?.toDouble() ?? 0,
          unit:          map['unit']  as String? ?? '',
          normalMin:     (map['normal_min']      as num?)?.toDouble() ?? 0,
          normalMax:     (map['normal_max']      as num?)?.toDouble() ?? 100,
          previousValue: (map['previous_value']  as num?)?.toDouble(),
        );
      }).toList();

      _labs.add(LabResult(
        id:        row['id']         as String? ?? 'lab_${_labs.length}',
        panelName: row['panel_name'] as String? ?? 'Lab Results',
        date:      date,
        metrics:   metrics,
        aiSummary: row['ai_summary'] as String?,
      ));
    }
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

  /// Populate medications from Supabase rows. Marks as initialized so
  /// initDefaultMedications() won't run afterward.
  void initMedicationsFromData(List<Map<String, dynamic>> meds) {
    _medsInitialized = true;
    for (final m in meds) {
      _medications.add(Medication(
        id: m['id'] as String? ?? 'med_${_medications.length}',
        name: m['name'] as String? ?? '',
        dose: m['dose'] as String? ?? '',
        frequency: m['frequency'] as String? ?? 'Daily',
        emoji: m['emoji'] as String? ?? '💊',
        category: m['category'] as String? ?? 'chemo',
        totalSupply: m['total_supply'] as int?,
      ));
    }
  }

  /// Populate appointments from Supabase rows. Marks as initialized so
  /// initDefaultAppointments() won't run afterward.
  void initAppointmentsFromData(List<Map<String, dynamic>> apts) {
    _appointmentsInitialized = true;
    for (final a in apts) {
      final dtStr = a['date_time'] as String?;
      if (dtStr == null) continue;
      final dt = DateTime.tryParse(dtStr);
      if (dt == null) continue;
      _appointments.add(Appointment(
        id: a['id'] as String? ?? 'apt_${_appointments.length}',
        title: a['title'] as String? ?? 'Appointment',
        doctorName: a['doctor_name'] as String? ?? '',
        location: a['location'] as String? ?? '',
        dateTime: dt,
        isPast: dt.isBefore(DateTime.now()),
      ));
    }
  }

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
        const Medication(id: 'med2', name: 'Vitamin D 1000 IU',
          dose: '1 capsule', frequency: 'Daily · With food',
          emoji: '🌤️', category: 'supplement'),
        const Medication(id: 'med3', name: 'Calcium 500mg',
          dose: '1 tablet', frequency: 'Twice daily',
          emoji: '🦴', category: 'supplement'),
      ]);
    } else {
      _medications.addAll([
        const Medication(id: 'med1', name: 'Ondansétron 8mg',
          dose: '1 tablet', frequency: 'Before each infusion',
          emoji: '💊', category: 'antiemetic'),
        const Medication(id: 'med2', name: 'Paclitaxel premedication',
          dose: 'IV protocol', frequency: 'Infusion day',
          emoji: '💉', category: 'chemo'),
        const Medication(id: 'med3', name: 'Ibuprofen 400mg',
          dose: '1 tablet', frequency: 'As needed · Joint pain',
          emoji: '🩹', category: 'analgesic'),
      ]);
      for (var i = 0; i < 13; i++) { medsAdherenceSimulate('med1'); } // 93%
      for (var i = 0; i < 14; i++) { medsAdherenceSimulate('med2'); } // 100%
      for (var i = 0; i < 9;  i++) { medsAdherenceSimulate('med3'); } // 64%
    }
    // Restore today's taken state from prefs (fire-and-forget; notifies on load)
    loadMedsStateFromPrefs();
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
        orElse: () => const Medication(id: '', name: '', dose: '',
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
        orElse: () => const Medication(id: '', name: '', dose: '',
            frequency: '', emoji: ''));
    if (rem == null) return null;
    return (rem / med.dosesPerDay.toDouble()).floor();
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

  // ── Vitals ────────────────────────────────────────────────────────────────
  final List<VitalRecord> _vitals = [];

  List<VitalRecord> get vitals => List.unmodifiable(_vitals);

  VitalRecord? get latestVital =>
      _vitals.isEmpty ? null : _vitals.last;

  double? get latestTemperature => latestVital?.temperatureCelsius;

  bool get hasFeverToday {
    final temp = latestTemperature;
    return temp != null && temp >= 38.0;
  }

  bool get hasHighAlertToday {
    final now = DateTime.now();
    return _vitals.any((v) =>
        v.recordedAt.year  == now.year &&
        v.recordedAt.month == now.month &&
        v.recordedAt.day   == now.day &&
        v.worstFlag == VitalFlag.high);
  }

  /// Populate vitals from Supabase rows (newest-first, converted via fromSupabase).
  /// Replaces any locally cached data and refreshes the prefs cache.
  void initVitalsFromData(List<Map<String, dynamic>> rows) {
    _vitals.clear();
    for (final row in rows.reversed) { // oldest-first in _vitals
      final v = VitalRecord.fromSupabase(row);
      if (v != null) _vitals.add(v);
    }
    _saveVitalsCache(); // refresh local cache for offline recovery
    notifyListeners();
  }

  void recordVital(VitalRecord record) {
    _vitals.add(record);
    _saveVitalsCache();
    _saveCount++;
    notifyListeners();
  }

  void reset() {
    name = '';
    cancerType = '';
    treatmentPhase = '';
    _appointments.clear();
    _appointmentsInitialized = false;
    _medications.clear();
    _medsInitialized = false;
    _medsTakenToday.clear();
    _medsAdherenceCount.clear();
    _labs.clear();
    _labsInitialized = false;
    _history.clear();
    _controls.clear();
    _vitals.clear();
    treatmentEndDate = null;
    menstrualStatus = 'unknown';
    lastPeriodDate = null;
    _checkinHistory.clear();
    notifyListeners();
  }
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

// ── Vital alert flag ──────────────────────────────────────────────────────────
enum VitalFlag { normal, moderate, high }

// ── Vital record ──────────────────────────────────────────────────────────────
class VitalRecord {
  final String? id;
  final DateTime recordedAt;
  final double? weightKg;
  final int? systolicBp;
  final int? diastolicBp;
  final int? heartRateBpm;
  final double? temperatureCelsius;
  final int? spo2Pct;
  final double? glucoseMmol;
  final int? cycleDay;
  final String? phase;

  const VitalRecord({
    this.id,
    required this.recordedAt,
    this.weightKg,
    this.systolicBp,
    this.diastolicBp,
    this.heartRateBpm,
    this.temperatureCelsius,
    this.spo2Pct,
    this.glucoseMmol,
    this.cycleDay,
    this.phase,
  });

  // ── Alert thresholds ────────────────────────────────────────────────────────

  VitalFlag get tempFlag {
    final t = temperatureCelsius;
    if (t == null) return VitalFlag.normal;
    if (t >= 38.0) return VitalFlag.high;
    if (t >= 37.5) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  VitalFlag get bpFlag {
    final s = systolicBp; final d = diastolicBp;
    if (s == null && d == null) return VitalFlag.normal;
    if ((s != null && (s > 160 || s < 90)) || (d != null && d > 100)) return VitalFlag.high;
    if ((s != null && s >= 140) || (d != null && d >= 90)) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  VitalFlag get hrFlag {
    final hr = heartRateBpm;
    if (hr == null) return VitalFlag.normal;
    if (hr > 100 || hr < 50) return VitalFlag.high;
    if (hr >= 90) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  VitalFlag get spo2Flag {
    final s = spo2Pct;
    if (s == null) return VitalFlag.normal;
    if (s < 94) return VitalFlag.high;
    if (s <= 95) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  VitalFlag get glucoseFlag {
    final g = glucoseMmol;
    if (g == null) return VitalFlag.normal;
    if (g > 11.0 || g < 3.9) return VitalFlag.high;
    if (g >= 8.0) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  // Worst flag excluding weight (weight comparison requires previous record context)
  VitalFlag get worstFlag {
    final flags = [tempFlag, bpFlag, hrFlag, spo2Flag, glucoseFlag];
    if (flags.any((f) => f == VitalFlag.high))     return VitalFlag.high;
    if (flags.any((f) => f == VitalFlag.moderate)) return VitalFlag.moderate;
    return VitalFlag.normal;
  }

  bool get isFever     => temperatureCelsius != null && temperatureCelsius! >= 38.0;
  bool get isHighFever => temperatureCelsius != null && temperatureCelsius! >= 38.5;
  bool get isLowTemp   => temperatureCelsius != null && temperatureCelsius! < 36.0;

  Map<String, dynamic> toJson() => {
    'at':   recordedAt.toIso8601String(),
    'wt':   weightKg,
    'sbp':  systolicBp,
    'dbp':  diastolicBp,
    'hr':   heartRateBpm,
    'temp': temperatureCelsius,
    'o2':   spo2Pct,
    'glu':  glucoseMmol,
    'cd':   cycleDay,
    'ph':   phase,
    if (id != null) 'id': id,
  };

  static VitalRecord? fromJson(Map<String, dynamic> j) {
    try {
      return VitalRecord(
        id:                 j['id'] as String?,
        recordedAt:         DateTime.parse(j['at'] as String),
        weightKg:           (j['wt']   as num?)?.toDouble(),
        systolicBp:         (j['sbp']  as num?)?.toInt(),
        diastolicBp:        (j['dbp']  as num?)?.toInt(),
        heartRateBpm:       (j['hr']   as num?)?.toInt(),
        temperatureCelsius: (j['temp'] as num?)?.toDouble(),
        spo2Pct:            (j['o2']   as num?)?.toInt(),
        glucoseMmol:        (j['glu']  as num?)?.toDouble(),
        cycleDay:           (j['cd']   as num?)?.toInt(),
        phase:              j['ph'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static VitalRecord? fromSupabase(Map<String, dynamic> row) {
    try {
      return VitalRecord(
        id:                 row['id']             as String?,
        recordedAt:         DateTime.parse(row['created_at'] as String).toLocal(),
        weightKg:           (row['weight_kg']     as num?)?.toDouble(),
        systolicBp:         (row['systolic_bp']   as num?)?.toInt(),
        diastolicBp:        (row['diastolic_bp']  as num?)?.toInt(),
        heartRateBpm:       (row['heart_rate_bpm'] as num?)?.toInt(),
        temperatureCelsius: (row['temperature_c'] as num?)?.toDouble(),
        spo2Pct:            (row['spo2_pct']      as num?)?.toInt(),
        glucoseMmol:        (row['glucose_mmol']  as num?)?.toDouble(),
        cycleDay:           (row['cycle_day']     as num?)?.toInt(),
        phase:              row['phase']           as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
