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
    // ignore: avoid_print
    print('✅ saveCheckIn called — history length: ${_history.length}, emoji: $emoji');
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

  // ── Symptom summary ───────────────────────────────────────────────────────
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

class DayMood {
  final String label, emoji;
  final bool hasData;
  const DayMood({
    required this.label, required this.emoji, required this.hasData});
}
