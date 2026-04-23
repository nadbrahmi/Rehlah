import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TreatmentPhase {
  diagnosis,
  chemo,
  immunotherapy,
  chemoImmuno,
  radiation,
  surgery,
  recovery,
  postTreatment,
  hormonal,
  unknown,
}

enum UserRole { patient, caregiver }

class Medication {
  final String id;
  final String name;
  final String dose;
  final String frequency;
  final String time;
  final bool isAsNeeded;
  bool isTaken;
  String? takenAt;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.frequency,
    this.time = '',
    this.isAsNeeded = false,
    this.isTaken = false,
    this.takenAt,
  });
}

class Appointment {
  final String id;
  final String title;
  final String doctor;
  final DateTime dateTime;
  final bool isToday;

  Appointment({
    required this.id,
    required this.title,
    required this.doctor,
    required this.dateTime,
    this.isToday = false,
  });
}

class LabResult {
  final String id;
  final String name;
  final String value;
  final String unit;
  final String status; // 'normal', 'attention', 'critical'
  final String explanation;

  LabResult({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.explanation,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class CircleMessage {
  final String author;
  final String initials;
  final String text;
  final String time;
  Map<String, int> reactions;

  CircleMessage({
    required this.author,
    required this.initials,
    required this.text,
    required this.time,
    Map<String, int>? reactions,
  }) : reactions = reactions ?? {'💜': 0, '🤝': 0, '💡': 0, '🙏': 0, '✨': 0};
}

class AppProvider extends ChangeNotifier {
  // ── Navigation ──────────────────────────────────────────────────────────
  int currentTabIndex = 0;
  int careTabIndex = 0; // 0=meds 1=appointments 2=labs

  // ── Language ─────────────────────────────────────────────────────────────
  bool isArabic = false; // true = Arabic (RTL), false = English (LTR)

  // ── Mode ────────────────────────────────────────────────────────────────
  bool isDemoMode = true;
  bool onboardingDone = false;

  // ── User data ────────────────────────────────────────────────────────────
  String userName = 'Sarah';
  String userFullName = 'Sarah Al Mansoori';
  UserRole userRole = UserRole.patient;
  String cancerType = 'Breast Cancer';
  TreatmentPhase treatmentPhase = TreatmentPhase.chemo;
  String treatmentPhaseLabel = 'Chemotherapy';
  String treatmentTypeLabel = 'Chemo only';
  String diseaseStage = 'Stage II';
  DateTime? diagnosisDate = DateTime(2025, 10, 1);
  DateTime? treatmentStartDate = DateTime(2026, 1, 1);
  int currentCycle = 2;
  int currentDay = 7;
  int totalDays = 21;

  // ── Check-in ─────────────────────────────────────────────────────────────
  bool checkedInToday = false;
  String todayMood = '';
  List<String> todayChallenges = [];

  // ── Yusr overlay ─────────────────────────────────────────────────────────
  bool yusrOverlayOpen = false;

  // ── Medications ──────────────────────────────────────────────────────────
  late List<Medication> medications;

  // ── Appointments ─────────────────────────────────────────────────────────
  late List<Appointment> appointments;

  // ── Labs ─────────────────────────────────────────────────────────────────
  late List<LabResult> labs;

  // ── Chat ─────────────────────────────────────────────────────────────────
  List<ChatMessage> chatMessages = [];

  // ── Circle ───────────────────────────────────────────────────────────────
  late List<CircleMessage> circleMessages;

  AppProvider() {
    _loadDemoData();
    _loadPrefs();
  }

  void _loadDemoData() {
    medications = [
      Medication(
        id: 'm1',
        name: 'Tamoxifen',
        dose: '20mg',
        frequency: 'Once daily',
        time: '08:00',
        isTaken: false,
      ),
      Medication(
        id: 'm2',
        name: 'Vitamin D',
        dose: '1000IU',
        frequency: 'Once daily',
        time: '08:00',
        isTaken: true,
        takenAt: '08:00',
      ),
      Medication(
        id: 'm3',
        name: 'Ondansetron',
        dose: '8mg',
        frequency: 'As needed',
        isAsNeeded: true,
      ),
    ];

    final now = DateTime.now();
    appointments = [
      Appointment(
        id: 'a1',
        title: 'Chemo Session 7',
        doctor: 'Dr. Sarah Chen · 9:00 AM',
        dateTime: DateTime(now.year, now.month, now.day + 1, 9, 0),
        isToday: false,
      ),
      Appointment(
        id: 'a2',
        title: 'Oncology Review',
        doctor: 'Dr. Rima Fadel · 9:00 AM',
        dateTime: DateTime(now.year, now.month, now.day + 5, 9, 0),
      ),
    ];

    labs = [
      LabResult(
        id: 'l1',
        name: 'Hemoglobin',
        value: '10.2',
        unit: 'g/dL',
        status: 'attention',
        explanation: 'Slightly below normal range. May cause fatigue.',
      ),
      LabResult(
        id: 'l2',
        name: 'White Blood Cells',
        value: '4.1',
        unit: '×10³/µL',
        status: 'normal',
        explanation: 'Within normal range.',
      ),
    ];

    circleMessages = [
      CircleMessage(
        author: 'Sara J.',
        initials: 'S',
        text: 'The fatigue is real but I am trying to walk every morning 💜',
        time: '2 hours ago',
        reactions: {'💜': 5, '🤝': 2, '💡': 0, '🙏': 1, '✨': 3},
      ),
      CircleMessage(
        author: 'Mona A.',
        initials: 'M',
        text: 'Today\'s session was tough but it is done. One breath at a time.',
        time: '3 hours ago',
        reactions: {'💜': 8, '🤝': 4, '💡': 1, '🙏': 2, '✨': 1},
      ),
      CircleMessage(
        author: 'Noura M.',
        initials: 'N',
        text: 'I ate a full meal today for the first time in a week! Small progress is still progress 🎉',
        time: '5 hours ago',
        reactions: {'💜': 12, '🤝': 3, '💡': 0, '🙏': 5, '✨': 7},
      ),
    ];

    chatMessages = [
      ChatMessage(
        text: 'Good morning, Sarah 💜 I am here with you. Whatever you are going through right now — the fear, the side effects, the hard questions — you do not have to face it alone.',
        isUser: false,
        time: DateTime.now(),
      ),
    ];
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    onboardingDone = prefs.getBool('onboarding_done') ?? false;
    isDemoMode = prefs.getBool('demo_mode') ?? true;
    isArabic = prefs.getBool('is_arabic') ?? true;
    notifyListeners();
  }

  void setLanguage(bool arabic) async {
    isArabic = arabic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_arabic', arabic);
    notifyListeners();
  }

  void setTab(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  void openYusrOverlay() {
    yusrOverlayOpen = true;
    notifyListeners();
  }

  void closeYusrOverlay() {
    yusrOverlayOpen = false;
    notifyListeners();
  }

  void setCareTab(int index) {
    careTabIndex = index;
    notifyListeners();
  }

  void completeOnboarding({
    required String name,
    required String cancerTypeVal,
    required String phaseLabel,
    required String phaseTypeLabel,
    String? stage,
    DateTime? diagDate,
    DateTime? startDate,
    bool? languageIsArabic,
  }) async {
    if (languageIsArabic != null) {
      isArabic = languageIsArabic;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_arabic', languageIsArabic);
    }
    userName = name.split(' ').first;
    userFullName = name;
    cancerType = cancerTypeVal;
    treatmentPhaseLabel = phaseLabel;
    treatmentTypeLabel = phaseTypeLabel;
    if (stage != null) diseaseStage = stage;
    diagnosisDate = diagDate;
    treatmentStartDate = startDate;
    onboardingDone = true;
    isDemoMode = false;
    checkedInToday = false;
    medications = [];
    appointments = [];
    labs = [];
    circleMessages = [];
    chatMessages = [
      ChatMessage(
        text:
            'أهلاً، أنا يُسر. يمكنكِ سؤالي عن أعراضكِ أو أدويتكِ أو أي شيء يشغل بالكِ. لستُ طبيبةً لكنني هنا دائماً.',
        isUser: false,
        time: DateTime.now(),
      ),
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setBool('demo_mode', false);
    notifyListeners();
  }

  void updateTreatmentPhase(String phase) {
    treatmentPhaseLabel = phase;
    notifyListeners();
  }

  void enterDemoMode() {
    isDemoMode = true;
    onboardingDone = true;
    notifyListeners();
  }

  void exitDemoMode() async {
    isDemoMode = false;
    onboardingDone = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('demo_mode', false);
    await prefs.setBool('onboarding_done', false);
    notifyListeners();
  }

  void takeMedication(String id) {
    final med = medications.firstWhere((m) => m.id == id);
    med.isTaken = true;
    med.takenAt = '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
    notifyListeners();
  }

  void addMedication(Medication med) {
    medications.add(med);
    notifyListeners();
  }

  void addAppointment(Appointment appt) {
    appointments.add(appt);
    notifyListeners();
  }

  void addLabResult(LabResult lab) {
    labs.add(lab);
    notifyListeners();
  }

  void completeCheckin(String mood, List<String> challenges) {
    checkedInToday = true;
    todayMood = mood;
    todayChallenges = challenges;
    notifyListeners();
  }

  void sendChatMessage(String text) {
    chatMessages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 800), () {
      chatMessages.add(ChatMessage(
        text: _getYusrResponse(text),
        isUser: false,
        time: DateTime.now(),
      ));
      notifyListeners();
    });
  }

  String _getYusrResponse(String userText) {
    final lower = userText.toLowerCase();
    if (isArabic) {
      if (lower.contains('غثيان') || lower.contains('nausea')) {
        return 'الغثيان شعور صعب ومؤلم. تناول مضادات الغثيان بانتظام يساعد كثيراً. حاولي تناول وجبات صغيرة ومتكررة وتجنبي الروائح القوية. إذا استمر، تحدثي مع فريقكِ الطبي.';
      } else if (lower.contains('إرهاق') || lower.contains('تعب') || lower.contains('fatigue')) {
        return 'الإرهاق من أكثر الأعراض شيوعاً خلال العلاج. الراحة مهمة جداً — لا تشعري بالذنب. حاولي النوم بانتظام وطلب المساعدة عند الحاجة. جسمكِ يعمل بجد الآن.';
      } else if (lower.contains('تحليل') || lower.contains('نتيجة')) {
        return 'نتائج التحاليل قد تبدو مربكة. أنصحكِ بمناقشة كل نتيجة مع طبيبكِ المعالج — هو الأقدر على تفسيرها في سياق حالتكِ. يمكنني مساعدتكِ في تحضير أسئلتكِ للزيارة القادمة.';
      } else if (lower.contains('كيميائي') || lower.contains('علاج') || lower.contains('chemo')) {
        return 'العلاج الكيميائي تجربة صعبة لكن كثيرات تجاوزنها. كل جلسة تعبرينها هي خطوة للأمام. هل تريدين معرفة ما يمكن توقعه بعد كل جلسة؟';
      } else if (lower.contains('طبيب') || lower.contains('زيارة')) {
        return 'التحضير للزيارة الطبية يساعد على الاستفادة القصوى منها. أنصحكِ بكتابة أسئلتكِ مسبقاً، وذكر أي أعراض جديدة، والسؤال عن الخطوات القادمة.';
      } else {
        return 'شكراً لمشاركتي ما تشعرين به. أنا هنا دائماً للاستماع. تذكري أن كل خطوة صغيرة تخطينها هي إنجاز. هل تريدين التحدث أكثر عن هذا؟';
      }
    } else {
      if (lower.contains('nausea') || lower.contains('sick')) {
        return 'Nausea can be really tough. Taking anti-nausea medication regularly helps a lot. Try eating small, frequent meals and avoid strong smells. If it continues, speak with your medical team.';
      } else if (lower.contains('fatigue') || lower.contains('tired') || lower.contains('exhausted')) {
        return 'Fatigue is one of the most common symptoms during treatment. Rest is very important — don\'t feel guilty about it. Try to sleep regularly and ask for help when needed. Your body is working hard right now.';
      } else if (lower.contains('lab') || lower.contains('result') || lower.contains('test')) {
        return 'Lab results can feel overwhelming. I\'d recommend discussing each result with your oncologist — they can best interpret it in the context of your specific situation. I can help you prepare questions for your next visit.';
      } else if (lower.contains('chemo') || lower.contains('treatment') || lower.contains('therapy')) {
        return 'Chemotherapy is a tough experience, but many women have gotten through it. Every session you complete is a step forward. Would you like to know what to expect after each session?';
      } else if (lower.contains('doctor') || lower.contains('appointment') || lower.contains('visit')) {
        return 'Preparing for your medical visit helps you get the most out of it. I\'d suggest writing your questions in advance, noting any new symptoms, and asking about upcoming steps in your treatment.';
      } else if (lower.contains('sleep') || lower.contains('insomnia')) {
        return 'Sleep difficulties are common during treatment. Try keeping a consistent sleep schedule, avoiding screens before bed, and creating a calm environment. Let your doctor know if it\'s affecting your recovery.';
      } else {
        return 'Thank you for sharing how you\'re feeling. I\'m always here to listen. Remember that every small step you take is an achievement. Would you like to talk more about this?';
      }
    }
  }

  void addCircleMessage(String text) {
    circleMessages.insert(
      0,
      CircleMessage(
        author: userName,
        initials: userName.isNotEmpty ? userName[0] : 'أ',
        text: text,
        time: 'الآن',
      ),
    );
    notifyListeners();
  }

  void addReaction(int msgIndex, String emoji) {
    circleMessages[msgIndex].reactions[emoji] =
        (circleMessages[msgIndex].reactions[emoji] ?? 0) + 1;
    notifyListeners();
  }

  bool get isNadirWindow => currentDay >= 6 && currentDay <= 15;
  bool get isChemoUser =>
      treatmentPhase == TreatmentPhase.chemo ||
      treatmentPhase == TreatmentPhase.chemoImmuno;

  String get pendingMedsCount {
    final pending = medications.where((m) => !m.isTaken && !m.isAsNeeded).length;
    if (isArabic) return pending > 0 ? '$pending بانتظار' : 'كل شيء ✓';
    return pending > 0 ? '$pending pending' : 'All good ✓';
  }

  String get nextAppointmentLabel {
    if (appointments.isEmpty) return isArabic ? 'لا مواعيد' : 'No appointments';
    final next = appointments.first;
    final diff = next.dateTime.difference(DateTime.now()).inDays;
    if (isArabic) {
      if (diff == 0) return 'اليوم';
      if (diff == 1) return 'غداً';
      return 'خلال $diff أيام';
    } else {
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Tomorrow';
      return 'in $diff days';
    }
  }

  String get labStatusLabel {
    if (labs.isEmpty) return isArabic ? 'لم تُضاف' : 'Not added';
    final hasAttention = labs.any((l) => l.status == 'attention');
    if (isArabic) return hasAttention ? 'تحتاج اهتماماً' : 'مستقرة ✓';
    return hasAttention ? 'Needs attention' : 'Stable ✓';
  }

  bool get labStatusNormal => !labs.any((l) => l.status == 'attention');
}
