import 'protocols.dart';

class UserSession {
  static final UserSession _instance = UserSession._();
  factory UserSession() => _instance;
  UserSession._();

  // ── Onboarding ────────────────────────────────────────────────────────────
  String name = 'there';
  String cancerType = 'Breast cancer';
  String treatmentPhase = 'In chemotherapy';
  int whoIndex = 0;

  // ── Protocol ─────────────────────────────────────────────────────────────
  BreastProtocol protocol = BreastProtocol.act;
  bool isTaxolPhase = false;   // AC-T only: true when in Taxol sub-phase
  int currentCycle = 2;
  int totalCycles = 8;         // AC: 4 cycles, then Taxol: 4 cycles (or 12 weekly)
  int dayInCycle = 5;          // 1-based day within current cycle

  // ── Computed phase ────────────────────────────────────────────────────────
  ChemoPhase get currentPhase => ProtocolResolver.resolve(
    protocol, dayInCycle, isTaxolPhase: isTaxolPhase);

  bool get isNadirWindow => currentPhase.isNadir;

  bool get isNadirApproaching {
    // Check if nadir starts within next 2 days
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

  String get symptomSummary {
    if (symptomScores.isEmpty) return 'no symptoms reported';
    final parts = symptomScores.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key.replaceAll("_", " ")} ${e.value.toInt()}/10')
        .toList();
    return parts.isEmpty ? 'no symptoms reported' : parts.join(', ');
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
