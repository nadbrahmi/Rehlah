import 'protocols.dart';
import 'user_session.dart';

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
    // Simulate 25 doses of Tamoxifen taken (pack of 30 → 5 remaining → low)
    if (s.isMonitoring) {
      for (int i = 0; i < 25; i++) {
        s.medsAdherenceSimulate('med1');
      }
    }
  }

  /// All available codes (for dev/debug display)
  static List<InviteProfile> get all => _codes.values.toList();
}
