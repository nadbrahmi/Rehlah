import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // State
  UserJourney? _journey;
  List<CheckIn> _checkIns = [];
  List<Medication> _medications = [];
  List<Appointment> _appointments = [];
  List<MedLog> _medLogs = [];
  bool _onboardingComplete = false;
  bool _isLoading = false;
  int _currentNavIndex = 0;
  bool _isDemoMode = false;

  // Getters
  UserJourney? get journey => _journey;
  List<CheckIn> get checkIns => _checkIns;
  List<Medication> get medications => _medications;
  List<Appointment> get appointments => _appointments;
  List<MedLog> get medLogs => _medLogs;
  bool get onboardingComplete => _onboardingComplete;
  bool get isLoading => _isLoading;
  int get currentNavIndex => _currentNavIndex;
  bool get isDemoMode => _isDemoMode;

  // Per-medication daily helpers
  bool isMedTakenToday(String medId) {
    final today = DateTime.now();
    return _medLogs.any((l) =>
        l.medId == medId &&
        l.date.year == today.year &&
        l.date.month == today.month &&
        l.date.day == today.day &&
        l.isTaken);
  }

  List<MedLog> medLogsForDate(DateTime date) => _medLogs
      .where((l) =>
          l.date.year == date.year &&
          l.date.month == date.month &&
          l.date.day == date.day)
      .toList();

  double medAdherenceRate({int days = 14}) {
    if (_medications.isEmpty) return 0.0;
    final activeMeds = _medications.where((m) => m.isActive).toList();
    if (activeMeds.isEmpty) return 0.0;
    int total = 0, taken = 0;
    for (int i = 0; i < days; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      final logs = medLogsForDate(d);
      for (final med in activeMeds) {
        total++;
        if (logs.any((l) => l.medId == med.id && l.isTaken)) taken++;
      }
    }
    return total == 0 ? 0.0 : (taken / total).clamp(0.0, 1.0);
  }

  bool get hasCheckedInToday {
    final today = DateTime.now();
    return _checkIns.any((c) =>
        c.date.year == today.year &&
        c.date.month == today.month &&
        c.date.day == today.day);
  }

  CheckIn? get todayCheckIn {
    final today = DateTime.now();
    try {
      return _checkIns.firstWhere((c) =>
          c.date.year == today.year &&
          c.date.month == today.month &&
          c.date.day == today.day);
    } catch (e) {
      return null;
    }
  }

  List<CheckIn> get recentCheckIns {
    final sorted = List<CheckIn>.from(_checkIns)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(14).toList();
  }

  int get checkInStreak {
    int streak = 0;
    DateTime current = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = current.subtract(Duration(days: i));
      final hasCheckIn = _checkIns.any((c) =>
          c.date.year == day.year &&
          c.date.month == day.month &&
          c.date.day == day.day);
      if (hasCheckIn) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  double get averageMood {
    if (_checkIns.isEmpty) return 3.0;
    final recent = recentCheckIns;
    if (recent.isEmpty) return 3.0;
    return recent.map((c) => c.moodScore).reduce((a, b) => a + b) / recent.length;
  }

  double get checkInRate {
    if (_checkIns.isEmpty) return 0.0;
    final daysTracking = journey?.treatmentStartDate != null
        ? DateTime.now().difference(journey!.treatmentStartDate!).inDays + 1
        : 30;
    final days = daysTracking.clamp(1, 30);
    final checkins = _checkIns.where((c) =>
        c.date.isAfter(DateTime.now().subtract(Duration(days: days)))).length;
    return (checkins / days).clamp(0.0, 1.0);
  }

  Appointment? get nextAppointment {
    final upcoming = _appointments
        .where((a) => a.dateTime.isAfter(DateTime.now()) && !a.isCompleted)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  // Initialize
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _prefs = await SharedPreferences.getInstance();
    await _loadData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadData() async {
    _onboardingComplete = _prefs?.getBool('onboarding_complete') ?? false;
    _isDemoMode = _prefs?.getBool('demo_mode') ?? false;

    final journeyJson = _prefs?.getString('journey');
    if (journeyJson != null) {
      _journey = UserJourney.fromMap(json.decode(journeyJson));
    }

    final checkInsJson = _prefs?.getString('check_ins');
    if (checkInsJson != null) {
      final list = json.decode(checkInsJson) as List;
      _checkIns = list.map((m) => CheckIn.fromMap(m)).toList();
    }

    final medsJson = _prefs?.getString('medications');
    if (medsJson != null) {
      final list = json.decode(medsJson) as List;
      _medications = list.map((m) => Medication.fromMap(m)).toList();
    } else {
      _medications = _defaultMedications();
    }

    final medLogsJson = _prefs?.getString('med_logs');
    if (medLogsJson != null) {
      final list = json.decode(medLogsJson) as List;
      _medLogs = list.map((m) => MedLog.fromMap(m)).toList();
    }

    final apptJson = _prefs?.getString('appointments');
    if (apptJson != null) {
      final list = json.decode(apptJson) as List;
      _appointments = list.map((m) => Appointment.fromMap(m)).toList();
    } else {
      _appointments = _defaultAppointments();
    }
  }

  List<Medication> _defaultMedications() => [
        Medication(
          id: 'med_1',
          name: 'Tamoxifen 20mg',
          dosage: '20mg',
          frequency: 'Daily Morning',
        ),
        Medication(
          id: 'med_2',
          name: 'Vitamin D 1000 IU',
          dosage: '1000 IU',
          frequency: 'Daily Morning',
        ),
        Medication(
          id: 'med_3',
          name: 'Pain Relief 500mg',
          dosage: '500mg',
          frequency: 'As needed',
        ),
      ];

  List<Appointment> _defaultAppointments() => [
        Appointment(
          id: 'appt_1',
          title: 'Oncologist Visit',
          doctorName: 'Dr. Sarah Chen',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          location: '789 Care Lane, Medical Center',
          type: 'oncologist',
        ),
        Appointment(
          id: 'appt_2',
          title: 'Blood Work Review',
          doctorName: 'Dr. Maria Rodriguez',
          dateTime: DateTime.now().add(const Duration(days: 7)),
          location: 'Lab Center, Floor 2',
          type: 'lab',
        ),
      ];

  // ─── DEMO MODE ────────────────────────────────────────────────────────────
  Future<void> activateDemoMode() async {
    _isDemoMode = true;
    _onboardingComplete = true;

    // Demo journey
    _journey = UserJourney(
      id: 'demo_journey',
      name: 'Sarah',
      cancerType: 'Breast Cancer',
      stage: 'Stage II',
      treatmentPhase: 'Weekly Chemo',
      diagnosisDate: DateTime.now().subtract(const Duration(days: 90)),
      treatmentStartDate: DateTime.now().subtract(const Duration(days: 60)),
      isPatient: true,
    );

    // Demo check-ins — 14 days of data
    _checkIns = List.generate(14, (i) {
      final daysAgo = 13 - i;
      return CheckIn(
        id: 'demo_ci_$i',
        date: DateTime.now().subtract(Duration(days: daysAgo)),
        moodScore: [3, 4, 3, 5, 4, 3, 4, 3, 4, 4, 3, 5, 4, 4][i],
        painScore: [3, 2, 3, 2, 2, 3, 2, 3, 2, 2, 3, 2, 2, 2][i],
        fatigueScore: [4, 3, 4, 3, 3, 4, 3, 4, 3, 3, 4, 3, 3, 3][i],
        nauseaScore: [2, 2, 3, 2, 1, 2, 2, 3, 2, 1, 2, 2, 2, 1][i],
        appetiteScore: [3, 3, 2, 3, 4, 3, 3, 2, 3, 4, 3, 3, 4, 4][i],
        sleepScore: [3, 4, 3, 4, 4, 3, 4, 3, 4, 4, 3, 4, 4, 5][i],
        medicationsTaken: i != 5,
        waterGlasses: [5, 6, 4, 7, 8, 5, 6, 5, 7, 8, 6, 7, 8, 8][i],
        activitiesAble: i % 3 != 2,
        symptoms: i % 4 == 0 ? ['Fatigue', 'Nausea'] : (i % 4 == 1 ? ['Fatigue'] : []),
        notes: i == 13 ? 'Feeling a bit better today 💜' : '',
      );
    });

    // Demo medications
    _medications = [
      Medication(id: 'demo_med_1', name: 'Tamoxifen 20mg', dosage: '20mg', frequency: 'Daily Morning'),
      Medication(id: 'demo_med_2', name: 'Ondansetron 4mg', dosage: '4mg', frequency: 'As needed (nausea)'),
      Medication(id: 'demo_med_3', name: 'Vitamin D 1000 IU', dosage: '1000 IU', frequency: 'Daily Morning'),
      Medication(id: 'demo_med_4', name: 'Metoclopramide 10mg', dosage: '10mg', frequency: 'Before meals'),
    ];

    // Demo appointments
    _appointments = [
      Appointment(
        id: 'demo_appt_1',
        title: 'Chemo Session #7',
        doctorName: 'Dr. Sarah Chen',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        location: 'City Cancer Center, Room 4B',
        type: 'chemo',
      ),
      Appointment(
        id: 'demo_appt_2',
        title: 'Oncologist Review',
        doctorName: 'Dr. Aisha Patel',
        dateTime: DateTime.now().add(const Duration(days: 5)),
        location: 'Oncology Clinic, Floor 3',
        type: 'oncologist',
      ),
      Appointment(
        id: 'demo_appt_3',
        title: 'Blood Work Panel',
        doctorName: 'Dr. Maria Rodriguez',
        dateTime: DateTime.now().add(const Duration(days: 10)),
        location: 'Lab Center, Floor 2',
        type: 'lab',
      ),
    ];

    await _prefs?.setBool('demo_mode', true);
    await _prefs?.setBool('onboarding_complete', true);
    notifyListeners();
  }

  Future<void> exitDemoMode() async {
    _isDemoMode = false;
    _onboardingComplete = false;
    _journey = null;
    _checkIns = [];
    _medications = _defaultMedications();
    _appointments = _defaultAppointments();
    await _prefs?.setBool('demo_mode', false);
    await _prefs?.setBool('onboarding_complete', false);
    await _prefs?.remove('journey');
    await _prefs?.remove('check_ins');
    notifyListeners();
  }

  // ─── ACTIONS ──────────────────────────────────────────────────────────────
  Future<void> saveJourney(UserJourney journey) async {
    _journey = journey;
    _onboardingComplete = true;
    await _prefs?.setString('journey', json.encode(journey.toMap()));
    await _prefs?.setBool('onboarding_complete', true);
    notifyListeners();
  }

  Future<void> saveCheckIn(CheckIn checkIn) async {
    _checkIns.removeWhere((c) =>
        c.date.year == checkIn.date.year &&
        c.date.month == checkIn.date.month &&
        c.date.day == checkIn.date.day);
    _checkIns.add(checkIn);
    await _prefs?.setString(
        'check_ins', json.encode(_checkIns.map((c) => c.toMap()).toList()));
    notifyListeners();
  }

  Future<void> logMedTaken(String medId, {bool taken = true}) async {
    final today = DateTime.now();
    _medLogs.removeWhere((l) =>
        l.medId == medId &&
        l.date.year == today.year &&
        l.date.month == today.month &&
        l.date.day == today.day);
    _medLogs.add(MedLog(
      medId: medId,
      date: today,
      takenAt: taken ? today : null,
    ));
    await _prefs?.setString(
        'med_logs', json.encode(_medLogs.map((l) => l.toMap()).toList()));
    notifyListeners();
  }

  Future<void> addMedication(Medication med) async {
    _medications.add(med);
    await _prefs?.setString(
        'medications', json.encode(_medications.map((m) => m.toMap()).toList()));
    notifyListeners();
  }

  Future<void> removeMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
    await _prefs?.setString(
        'medications', json.encode(_medications.map((m) => m.toMap()).toList()));
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appt) async {
    _appointments.add(appt);
    await _prefs?.setString('appointments',
        json.encode(_appointments.map((a) => a.toMap()).toList()));
    notifyListeners();
  }

  Future<void> completeAppointment(String id) async {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _appointments[idx].isCompleted = true;
      await _prefs?.setString('appointments',
          json.encode(_appointments.map((a) => a.toMap()).toList()));
      notifyListeners();
    }
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  Future<void> resetJourney() async {
    _isDemoMode = false;
    _journey = null;
    _onboardingComplete = false;
    _checkIns = [];
    _medications = _defaultMedications();
    _appointments = _defaultAppointments();
    await _prefs?.remove('journey');
    await _prefs?.remove('check_ins');
    await _prefs?.setBool('onboarding_complete', false);
    await _prefs?.setBool('demo_mode', false);
    notifyListeners();
  }

  // Journey milestones based on treatment phase
  List<Milestone> getMilestones() {
    final phase = journey?.treatmentPhase ?? '';
    return [
      Milestone(
        id: 'm1',
        title: 'Initial Consultation',
        description: 'First appointment with oncologist',
        phase: 'Diagnosis & Planning',
        isCompleted: true,
      ),
      Milestone(
        id: 'm2',
        title: 'Treatment Plan Confirmed',
        description: 'Review pathology and confirm treatment',
        phase: 'Diagnosis & Planning',
        isCompleted: true,
      ),
      Milestone(
        id: 'm3',
        title: 'First Treatment Session',
        description: 'Beginning of active treatment',
        phase: 'Weekly Treatment (Chemo)',
        isCompleted: phase != 'Diagnosis & Planning' && phase != 'Pre-Treatment (Planning)',
        isCurrent: phase == 'Weekly Treatment (Chemo)',
      ),
      Milestone(
        id: 'm4',
        title: 'Mid-Treatment Scan',
        description: 'Imaging to check progress',
        phase: 'Weekly Treatment (Chemo)',
        isCompleted: false,
        isCurrent: false,
      ),
      Milestone(
        id: 'm5',
        title: 'Final Treatment Session',
        description: 'Completing active treatment phase',
        phase: 'Recovery',
        isCompleted: false,
      ),
      Milestone(
        id: 'm6',
        title: 'Recovery & Follow-up',
        description: 'Post-treatment care and monitoring',
        phase: 'Survivorship',
        isCompleted: false,
      ),
    ];
  }
}
