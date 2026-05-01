import 'protocols.dart';
import 'user_session.dart';
import 'caregiver_session.dart';

// ── Caregiver Code Database ───────────────────────────────────────────────────
// Each caregiver code links to a patient profile.
// Format: CARE-[PATIENT_CODE]
// ─────────────────────────────────────────────────────────────────────────────

class CaregiverCode {
  final String code;
  final String patientName;
  final String patientPhase;
  final String scenarioLabel;
  final String scenarioEmoji;
  // Which patient invite code to load when caregiver connects
  final String linkedPatientCode;

  const CaregiverCode({
    required this.code,
    required this.patientName,
    required this.patientPhase,
    required this.scenarioLabel,
    required this.scenarioEmoji,
    required this.linkedPatientCode,
  });
}

// ── Invite Code Database ──────────────────────────────────────────────────────
// Hard-coded for now — will be replaced with API call when care team 
// integration is built.
//
// Format: REHLAH-[PROTOCOL]-[SCENARIO]
// ─────────────────────────────────────────────────────────────────────────────

class InviteProfile {
  final String code;
  final String name;
  final String cancerType;
  final String treatmentPhase;
  final BreastProtocol protocol;
  final bool isTaxolPhase;
  final int currentCycle;
  final int totalCycles;
  final int dayInCycle;
  final String scenarioLabel; // shown on code entry screen
  final String scenarioEmoji;

  const InviteProfile({
    required this.code,
    required this.name,
    required this.cancerType,
    required this.treatmentPhase,
    required this.protocol,
    this.isTaxolPhase = false,
    required this.currentCycle,
    required this.totalCycles,
    required this.dayInCycle,
    required this.scenarioLabel,
    required this.scenarioEmoji,
  });
}

class InviteCodes {
  static const _codes = <String, InviteProfile>{

    // ── AC-T Protocol ─────────────────────────────────────────────────────
    'REHLAH-ACT-001': InviteProfile(
      code: 'REHLAH-ACT-001',
      name: 'Nadia',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.act,
      currentCycle: 2, totalCycles: 8, dayInCycle: 5,
      scenarioLabel: 'AC-T · Cycle 2 · Day 5 · Peak nausea window',
      scenarioEmoji: '🌊',
    ),

    'REHLAH-ACT-002': InviteProfile(
      code: 'REHLAH-ACT-002',
      name: 'Nadia',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.act,
      currentCycle: 2, totalCycles: 8, dayInCycle: 10,
      scenarioLabel: 'AC-T · Cycle 2 · Day 10 · Nadir window ⚠',
      scenarioEmoji: '⚠️',
    ),

    'REHLAH-ACT-003': InviteProfile(
      code: 'REHLAH-ACT-003',
      name: 'Nadia',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.act,
      currentCycle: 5, totalCycles: 8, dayInCycle: 4,
      isTaxolPhase: true,
      scenarioLabel: 'AC-T (Taxol phase) · Cycle 5 · Day 4 · Joint pain peak',
      scenarioEmoji: '🦴',
    ),

    // ── TC Protocol ──────────────────────────────────────────────────────
    'REHLAH-TC-001': InviteProfile(
      code: 'REHLAH-TC-001',
      name: 'Sarah',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.tc,
      currentCycle: 3, totalCycles: 6, dayInCycle: 5,
      scenarioLabel: 'TC · Cycle 3 · Day 5 · Fluid & pain window',
      scenarioEmoji: '💧',
    ),

    'REHLAH-TC-002': InviteProfile(
      code: 'REHLAH-TC-002',
      name: 'Sarah',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.tc,
      currentCycle: 3, totalCycles: 6, dayInCycle: 10,
      scenarioLabel: 'TC · Cycle 3 · Day 10 · Nadir window ⚠',
      scenarioEmoji: '⚠️',
    ),

    // ── CMF Protocol ─────────────────────────────────────────────────────
    'REHLAH-CMF-001': InviteProfile(
      code: 'REHLAH-CMF-001',
      name: 'Layla',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.cmf,
      currentCycle: 1, totalCycles: 6, dayInCycle: 3,
      scenarioLabel: 'CMF · Cycle 1 · Day 3 · Post-infusion',
      scenarioEmoji: '💊',
    ),

    'REHLAH-CMF-002': InviteProfile(
      code: 'REHLAH-CMF-002',
      name: 'Layla',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.cmf,
      currentCycle: 2, totalCycles: 6, dayInCycle: 14,
      scenarioLabel: 'CMF · Cycle 2 · Day 14 · Nadir window ⚠',
      scenarioEmoji: '⚠️',
    ),

    // ── Recovery scenario ─────────────────────────────────────────────────
    'REHLAH-REC-001': InviteProfile(
      code: 'REHLAH-REC-001',
      name: 'Amira',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.act,
      currentCycle: 4, totalCycles: 8, dayInCycle: 18,
      scenarioLabel: 'AC-T · Cycle 4 · Day 18 · Recovery week',
      scenarioEmoji: '🌿',
    ),

    // ── Monitoring scenario ───────────────────────────────────────────────
    'REHLAH-MON-001': InviteProfile(
      code: 'REHLAH-MON-001',
      name: 'Amira',
      cancerType: 'Breast cancer',
      treatmentPhase: 'Monitoring / surveillance',
      protocol: BreastProtocol.act,
      currentCycle: 8, totalCycles: 8, dayInCycle: 1,
      scenarioLabel: 'Monitoring · 847 days cancer-free · Regular cycles',
      scenarioEmoji: '🎗️',
    ),
    'DEMO': InviteProfile(
      code: 'DEMO',
      name: 'Demo Patient',
      cancerType: 'Breast cancer',
      treatmentPhase: 'In chemotherapy',
      protocol: BreastProtocol.act,
      currentCycle: 2, totalCycles: 8, dayInCycle: 7,
      scenarioLabel: 'AC-T · Cycle 2 · Day 7 · Nadir approaching',
      scenarioEmoji: '🎯',
    ),
  };

  /// Returns the profile for a given code (case-insensitive), or null if invalid.
  static InviteProfile? validate(String code) {
    return _codes[code.trim().toUpperCase()];
  }

  /// Load a validated profile into UserSession.
  static void apply(InviteProfile profile) {
    final s = UserSession();
    s.name = profile.name;
    s.cancerType = profile.cancerType;
    s.treatmentPhase = profile.treatmentPhase;
    s.protocol = profile.protocol;
    s.isTaxolPhase = profile.isTaxolPhase;
    s.currentCycle = profile.currentCycle;
    s.totalCycles = profile.totalCycles;
    s.dayInCycle = profile.dayInCycle;
    s.cycleDaySetByUser = true;
    // Set monitoring fields for monitoring phase
    if (profile.treatmentPhase == 'Monitoring / surveillance') {
      s.treatmentEndDate = DateTime.now().subtract(const Duration(days: 847));
      s.menstrualStatus = 'regular';
      s.lastPeriodDate = DateTime.now().subtract(const Duration(days: 10));
      s.cycleLength = 28;
    }
    // Init default medications based on phase
    s.initDefaultMedications();
    s.initDefaultLabs();
    s.initDefaultAppointments();
    // Simulate 25 doses of Tamoxifen taken (pack of 30 → 5 remaining → low)
    if (s.isMonitoring) {
      for (int i = 0; i < 25; i++) {
        s.medsAdherenceSimulate('med1');
      }
    }
  }

  /// All available codes (for dev/debug display)
  static List<InviteProfile> get all => _codes.values.toList();

  // ── Caregiver codes ────────────────────────────────────────────────────────
  static const _caregiverCodes = <String, CaregiverCode>{
    'CARE-NADIA': CaregiverCode(
      code: 'CARE-NADIA',
      patientName: 'Nadia',
      patientPhase: 'In chemotherapy',
      scenarioLabel: 'Nadia · AC-T · Cycle 2 · Day 10',
      scenarioEmoji: '💜',
      linkedPatientCode: 'REHLAH-ACT-002',
    ),
    'CARE-AMIRA': CaregiverCode(
      code: 'CARE-AMIRA',
      patientName: 'Amira',
      patientPhase: 'Monitoring / surveillance',
      scenarioLabel: 'Amira · 847 days cancer-free',
      scenarioEmoji: '🎗️',
      linkedPatientCode: 'REHLAH-MON-001',
    ),
  };

  static CaregiverCode? validateCaregiverCode(String code) =>
      _caregiverCodes[code.trim().toUpperCase()];

  static void applyAsCaregiver(CaregiverCode careCode) {
    // Load the linked patient's session data
    final patientProfile = validate(careCode.linkedPatientCode);
    if (patientProfile != null) apply(patientProfile);

    // Mark this session as caregiver mode
    CaregiverSession().linkAsCaregiver(
      patientName: careCode.patientName,
      patientPhase: careCode.patientPhase,
      code: careCode.code,
    );
  }

  // Generate a caregiver code from a patient code (simple prefix for demo)
  static String generateCaregiverCode(String patientName) {
    return 'CARE-${patientName.toUpperCase().replaceAll(' ', '')}';
  }
}
