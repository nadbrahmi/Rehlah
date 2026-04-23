// lib/l10n/app_localizations.dart
// Bilingual (Arabic / English) string table for Rehlah.
// Usage: context.l10n.someKey  (via extension below)

import 'package:flutter/material.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class AppLocalizations {
  final bool isArabic;
  const AppLocalizations({required this.isArabic});

  static AppLocalizations of(BuildContext context) {
    // Resolved via InheritedWidget further below; fallback to Arabic.
    final inherited = context.dependOnInheritedWidgetOfExactType<_L10nInherited>();
    return inherited?.l10n ?? const AppLocalizations(isArabic: true);
  }

  // ── App meta ───────────────────────────────────────────────────────────────
  String get appName => isArabic ? 'رحلة يُسر' : 'Rehlah';
  String get appTagline => isArabic ? 'دعمٌ بين المواعيد' : 'Support between appointments';
  String get appSubtitle => isArabic
      ? 'رفيقتكِ في رحلة علاج السرطان'
      : 'Your companion on the cancer treatment journey';

  // ── Demo banner ────────────────────────────────────────────────────────────
  String get demoBanner => isArabic ? 'وضع العرض التجريبي — بيانات Sarah' : 'Demo mode — Sarah\'s data';
  String get demoExit => isArabic ? 'خروج' : 'Exit';

  // ── Welcome screen ─────────────────────────────────────────────────────────
  String get welcomeHeadline => isArabic
      ? 'رحلتكِ نحو الشفاء، بدعمٍ يومي'
      : 'Your healing journey, with daily support';
  String get welcomeSubtext => isArabic
      ? 'تتبّعي أعراضكِ، وتواصلي مع فريقكِ، واحصلي على دعم يُسر الذكي — كل ذلك بسريّة تامة.'
      : 'Track your symptoms, connect with your team, and get Yusr AI support — all in complete privacy.';
  String get welcomeCta => isArabic ? 'ابدئي رحلتكِ ←' : 'Start your journey →';
  String get welcomeDemo => isArabic ? 'تجربة النسخة التجريبية' : 'Try demo mode';
  String get trustPrivacy => isArabic ? 'خصوصية تامة' : 'Full privacy';
  String get trustArabic => isArabic ? 'عربي أولاً' : 'Arabic-first';
  String get trustUAE => isArabic ? 'موارد الإمارات' : 'UAE resources';
  String get trustDataOnDevice => isArabic ? 'بياناتكِ على جهازكِ فقط' : 'Your data stays on your device';
  String get trustClinical => isArabic ? 'مراجعة سريرية' : 'Clinically reviewed';
  String get trustSecure => isArabic ? 'آمن ومشفّر' : 'Secure & encrypted';
  String get featureTrack => isArabic ? 'تتبّع الأعراض' : 'Symptom tracking';
  String get featureMeds => isArabic ? 'تذكير الأدوية' : 'Medication reminders';
  String get featureAI => isArabic ? 'دعم يُسر الذكي' : 'Yusr AI support';
  String get featureCommunity => isArabic ? 'مجتمع المريضات' : 'Patient community';

  // ── Onboarding — Language select (O0) ─────────────────────────────────────
  String get langSelectTitle => isArabic ? 'اختاري لغتك' : 'Choose your language';
  String get langArabic => 'العربية';
  String get langEnglish => 'English';
  String get langHint => isArabic
      ? 'يمكنكِ تغيير اللغة لاحقاً من الإعدادات'
      : 'You can change the language later in settings';

  // ── Onboarding steps ───────────────────────────────────────────────────────
  String get onbStep => isArabic ? 'الخطوة' : 'Step';
  String get onbOf => isArabic ? 'من' : 'of';
  String get onbNext => isArabic ? 'التالي' : 'Next';
  String get onbContinue => isArabic ? 'متابعة' : 'Continue';
  String get onbBack => isArabic ? 'رجوع' : 'Back';
  String get onbSkip => isArabic ? 'تخطي' : 'Skip';

  // O1 – Role
  String get o1Title => isArabic ? 'هذا التطبيق لـ...' : 'This app is for...';
  String get o1Patient => isArabic ? 'أنا المريضة' : 'I am the patient';
  String get o1Caregiver => isArabic ? 'أنا مقدّمة الرعاية' : 'I am a caregiver';
  String get o1CaregiverSoon => isArabic
      ? 'ميزة مقدّمي الرعاية قادمة قريباً — ابدئي كمريضة الآن'
      : 'Caregiver features coming soon — start as a patient for now';
  String get o1Privacy => isArabic
      ? 'بياناتكِ تبقى على جهازكِ فقط. لا نشاركها مع أحد.'
      : 'Your data stays on your device only. We never share it.';

  // O2 – Name
  String get o2Title => isArabic ? 'كيف نناديكِ؟' : 'What should we call you?';
  String get o2Hint => isArabic ? 'اسمكِ' : 'Your name';

  // O3 – Cancer type
  String get o3Title => isArabic ? 'ما نوع السرطان؟' : 'What type of cancer?';
  List<String> get cancerTypes => isArabic
      ? ['سرطان الثدي', 'سرطان المبيض', 'سرطان عنق الرحم', 'سرطان القولون',
         'سرطان الرئة', 'اللوكيميا', 'الليمفوما', 'نوع آخر']
      : ['Breast cancer', 'Ovarian cancer', 'Cervical cancer', 'Colon cancer',
         'Lung cancer', 'Leukemia', 'Lymphoma', 'Other'];

  // O4 – Treatment phase
  String get o4Title => isArabic ? 'ما مرحلة علاجكِ؟' : 'What is your treatment phase?';
  List<String> get phases => isArabic
      ? ['التشخيص', 'العلاج الكيميائي', 'العلاج المناعي', 'العلاج الإشعاعي',
         'الجراحة', 'التعافي', 'مرحلة ما بعد العلاج', 'لست متأكدة']
      : ['Diagnosis', 'Chemotherapy', 'Immunotherapy', 'Radiation therapy',
         'Surgery', 'Recovery', 'Post-treatment', 'Not sure'];
  String get o4ChemoType => isArabic ? 'نوع العلاج الكيميائي' : 'Chemo type';
  String get o4ChemoOnly => isArabic ? 'كيميائي فقط' : 'Chemo only';
  String get o4ChemoImmuno => isArabic ? 'كيميائي + مناعي' : 'Chemo + Immuno';
  String get o4Cycle => isArabic ? 'رقم الدورة الحالية' : 'Current cycle number';

  // O5 – Optional details
  String get o5Title => isArabic ? 'تفاصيل اختيارية' : 'Optional details';
  String get o5Stage => isArabic ? 'مرحلة المرض (اختياري)' : 'Disease stage (optional)';
  String get o5DiagDate => isArabic ? 'تاريخ التشخيص (اختياري)' : 'Diagnosis date (optional)';
  String get o5StartDate => isArabic ? 'تاريخ بدء العلاج (اختياري)' : 'Treatment start date (optional)';
  String get o5Skip => isArabic ? 'تخطي هذه الخطوة' : 'Skip this step';
  List<String> get stages => isArabic
      ? ['المرحلة الأولى', 'المرحلة الثانية', 'المرحلة الثالثة', 'المرحلة الرابعة', 'غير محدد']
      : ['Stage I', 'Stage II', 'Stage III', 'Stage IV', 'Not specified'];

  // O6 – Welcome transition
  String get o6Welcome => isArabic ? 'أهلاً' : 'Welcome';
  String get o6Ready => isArabic ? 'أنتِ جاهزة!' : "You're all set!";
  String get o6SubText => isArabic
      ? 'رحلتكِ تبدأ الآن. نحن هنا في كل خطوة.'
      : 'Your journey starts now. We\'re here every step of the way.';
  String get o6Cta => isArabic ? 'ابدئي ←' : 'Get started →';

  // ── Tab labels ─────────────────────────────────────────────────────────────
  String get tabToday => isArabic ? 'الرئيسية' : 'Home';
  String get tabJourney => isArabic ? 'رحلتي' : 'Journey';
  String get tabCare => isArabic ? 'رعايتي' : 'Care';
  String get tabHealth => isArabic ? 'صحتي' : 'My Health';
  String get tabConnect => isArabic ? 'مجتمعي' : 'Community';
  String get tabYusr => isArabic ? 'يُسر' : 'Yusr';

  // ── Today tab ──────────────────────────────────────────────────────────────
  String get todayGoodMorning => isArabic ? 'صباح الخير،' : 'Good morning,';
  String get todayGoodEvening => isArabic ? 'مساء الخير،' : 'Good evening,';
  String get todayHowAreYou => isArabic ? 'كيف تشعرين اليوم؟' : 'How are you feeling today?';
  String get todayCheckinCta => isArabic ? 'تسجيل الحال' : 'Check in';
  String get todayCheckedIn => isArabic ? 'سجّلتِ حالكِ اليوم ✓' : 'Checked in today ✓';
  String get todayMoodLabel => isArabic ? 'المزاج:' : 'Mood:';
  String get todayChallengesLabel => isArabic ? 'تحديات:' : 'Challenges:';
  String get todayNadirTitle => isArabic ? 'تنبيه: نافذة النادير' : 'Alert: Nadir Window';
  String get todayNadirBody => isArabic
      ? 'أنتِ في فترة انخفاض الخلايا المناعية. احرصي على تجنّب الحشود والنظافة الجيدة.'
      : 'You are in your immune low period. Avoid crowds and maintain good hygiene.';
  String get todayJourneyTitle => isArabic ? 'رحلتكِ' : 'Your Journey';
  String get todayJourneyDay => isArabic ? 'اليوم' : 'Day';
  String get todayCycleOf => isArabic ? 'دورة' : 'Cycle';
  String get todayMeds => isArabic ? 'الأدوية' : 'Medications';
  String get todayAppointments => isArabic ? 'المواعيد' : 'Appointments';
  String get todayLabs => isArabic ? 'التحاليل' : 'Labs';
  String get todayYusrPrompt => isArabic ? 'يُسر هنا لمساعدتكِ' : 'Yusr is here to help';
  String get todayAskYusr => isArabic ? 'اسألي يُسر' : 'Ask Yusr';
  String get todayRecentChanges => isArabic ? 'آخر المستجدات' : 'Recent updates';

  // ── Care tab ───────────────────────────────────────────────────────────────
  String get careMeds => isArabic ? 'الأدوية' : 'Medications';
  String get careAppts => isArabic ? 'المواعيد' : 'Appointments';
  String get careLabs => isArabic ? 'التحاليل' : 'Labs';
  String get careAddMed => isArabic ? 'إضافة دواء' : 'Add medication';
  String get careAddAppt => isArabic ? 'إضافة موعد' : 'Add appointment';
  String get careAddLab => isArabic ? 'إضافة نتيجة' : 'Add result';
  String get careTaken => isArabic ? 'تمّ الأخذ ✓' : 'Taken ✓';
  String get careTake => isArabic ? 'أخذتُه' : 'Mark taken';
  String get careAsNeeded => isArabic ? 'عند الحاجة' : 'As needed';
  String get careEmptyMeds => isArabic ? 'لم تُضاف أدوية بعد' : 'No medications added yet';
  String get careEmptyAppts => isArabic ? 'لا مواعيد مجدولة' : 'No appointments scheduled';
  String get careEmptyLabs => isArabic ? 'لا نتائج مضافة' : 'No results added';
  String get careNormal => isArabic ? 'طبيعي' : 'Normal';
  String get careAttention => isArabic ? 'يحتاج اهتماماً' : 'Needs attention';
  String get careCritical => isArabic ? 'حرج' : 'Critical';
  String get careMedName => isArabic ? 'اسم الدواء' : 'Medication name';
  String get careDose => isArabic ? 'الجرعة' : 'Dose';
  String get careFrequency => isArabic ? 'التكرار' : 'Frequency';
  String get careTime => isArabic ? 'الوقت' : 'Time';
  String get careDoctor => isArabic ? 'الطبيب' : 'Doctor';
  String get careLocation => isArabic ? 'المكان' : 'Location';
  String get careAdd => isArabic ? 'إضافة' : 'Add';
  String get careCancel => isArabic ? 'إلغاء' : 'Cancel';

  // ── Health tab ─────────────────────────────────────────────────────────────
  String get healthTitle => isArabic ? 'صحتي' : 'My Health';
  String get healthPhase => isArabic ? 'مرحلة العلاج' : 'Treatment Phase';
  String get healthCycle => isArabic ? 'الدورة' : 'Cycle';
  String get healthDay => isArabic ? 'اليوم' : 'Day';
  String get healthSymptoms => isArabic ? 'الأعراض الشائعة' : 'Common Symptoms';
  String get healthContactWhen => isArabic ? 'متى تتصلين بفريقكِ الطبي؟' : 'When to contact your team?';
  String get healthDisclaimer => isArabic
      ? 'هذه المعلومات عامة. استشيري طبيبكِ دائماً لتقييم حالتكِ.'
      : 'This is general information. Always consult your doctor for your personal situation.';
  String get healthNadir => isArabic ? 'نافذة النادير' : 'Nadir Window';
  String get healthNadirAlert => isArabic
      ? 'الخلايا المناعية في أدنى مستوياتها. كوني حذرة من الإصابات.'
      : 'Immune cells at their lowest. Be extra careful about infections.';
  String get healthCompleted => isArabic ? 'مكتمل' : 'Completed';
  String get healthToday => isArabic ? 'اليوم' : 'Today';
  String get healthPeak => isArabic ? 'ذروة' : 'Peak';
  String get healthUpcoming => isArabic ? 'قادم' : 'Upcoming';

  // ── Connect tab ────────────────────────────────────────────────────────────
  String get connectTitle => isArabic ? 'تواصلي' : 'Connect';
  String get connectCoach => isArabic ? 'المرشدة الصحية' : 'Health Coach';
  String get connectSchedule => isArabic ? 'جدولة جلسة' : 'Schedule a session';
  String get connectCircle => isArabic ? 'دائرة المريضات' : 'Patient Circle';
  String get connectCircleJoin => isArabic ? 'انضمّي للمجموعة' : 'Join the group';
  String get connectStories => isArabic ? 'قصص الأمل' : 'Stories of hope';
  String get connectUAEResources => isArabic ? 'موارد الإمارات' : 'UAE resources';
  String get connectShareStory => isArabic ? 'شاركي قصتكِ' : 'Share your story';
  String get connectReact => isArabic ? 'ردّ الفعل' : 'React';
  String get connectSend => isArabic ? 'إرسال' : 'Send';
  String get connectTypeMessage => isArabic ? 'اكتبي رسالة...' : 'Type a message...';

  // ── Yusr tab ───────────────────────────────────────────────────────────────
  String get yusrTitle => isArabic ? 'يُسر' : 'Yusr';
  String get yusrSubtitle => isArabic ? 'رفيقتكِ الذكية' : 'Your AI companion';
  String get yusrDisclaimer => isArabic
      ? 'يُسر ليست بديلاً عن الطبيب. للطوارئ اتصلي بـ 998'
      : 'Yusr is not a substitute for a doctor. For emergencies call 998';
  String get yusrTypeHint => isArabic ? 'اكتبي سؤالكِ...' : 'Type your question...';
  String get yusrSend => isArabic ? 'إرسال' : 'Send';
  String get yusrCrisisTitle => isArabic ? 'هل تحتاجين مساعدة فورية؟' : 'Do you need immediate help?';
  String get yusrCall998 => isArabic ? 'اتصلي بـ 998' : 'Call 998';
  String get yusrGreeting => isArabic
      ? 'أهلاً، أنا يُسر. يمكنكِ سؤالي عن أعراضكِ أو أدويتكِ أو أي شيء يشغل بالكِ. لستُ طبيبةً لكنني هنا دائماً.'
      : 'Hello, I\'m Yusr. You can ask me about your symptoms, medications, or anything on your mind. I\'m not a doctor, but I\'m always here for you.';
  List<String> get yusrPromptChips => isArabic
      ? ['ما هي آثار العلاج الكيميائي؟', 'كيف أتعامل مع الغثيان؟', 'متى أتصل بالطبيب؟', 'نصائح للنوم']
      : ['What are chemo side effects?', 'How to manage nausea?', 'When to call my doctor?', 'Sleep tips'];

  // ── Profile screen ─────────────────────────────────────────────────────────
  String get profileTitle => isArabic ? 'الملف الشخصي' : 'Profile';
  String get profileJourney => isArabic ? 'رحلتكِ' : 'Your Journey';
  String get profileCompletion => isArabic ? 'اكتمال الملف' : 'Profile completion';
  String get profileEditInfo => isArabic ? 'تعديل المعلومات' : 'Edit information';
  String get profileCancerType => isArabic ? 'نوع السرطان' : 'Cancer type';
  String get profilePhase => isArabic ? 'مرحلة العلاج' : 'Treatment phase';
  String get profileStage => isArabic ? 'المرحلة' : 'Stage';
  String get profileDiagDate => isArabic ? 'تاريخ التشخيص' : 'Diagnosis date';
  String get profileSettings => isArabic ? 'الإعدادات' : 'Settings';
  String get profileLanguage => isArabic ? 'اللغة' : 'Language';
  String get profileFontSize => isArabic ? 'حجم الخط' : 'Font size';
  String get profileNotifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get profilePrivacy => isArabic ? 'الخصوصية والبيانات' : 'Privacy & Data';
  String get profileExportData => isArabic ? 'تصدير بياناتي' : 'Export my data';
  String get profileDeleteData => isArabic ? 'حذف جميع البيانات' : 'Delete all data';
  String get profileDeleteConfirm => isArabic
      ? 'هل أنتِ متأكدة؟ سيتم حذف جميع بياناتكِ نهائياً.'
      : 'Are you sure? All your data will be permanently deleted.';
  String get profileDelete => isArabic ? 'حذف' : 'Delete';
  String get profileCancel => isArabic ? 'إلغاء' : 'Cancel';
  String get profileSave => isArabic ? 'حفظ' : 'Save';
  String get profileDaysTracked => isArabic ? 'أيام التتبع' : 'Days tracked';
  String get profileCheckIns => isArabic ? 'تسجيلات الحال' : 'Check-ins';
  String get profileMoodAvg => isArabic ? 'متوسط المزاج' : 'Avg mood';

  // ── Check-in ───────────────────────────────────────────────────────────────
  String get checkinTitle => isArabic ? 'كيف حالكِ؟' : 'How are you?';
  String get checkinQuick => isArabic ? 'تسجيل سريع' : 'Quick check-in';
  String get checkinDetailed => isArabic ? 'تسجيل مفصّل' : 'Detailed check-in';
  String get checkinMoodLabel => isArabic ? 'كيف تشعرين الآن؟' : 'How are you feeling right now?';
  String get checkinChallenges => isArabic ? 'ما الذي واجهتِه اليوم؟' : 'What have you faced today?';
  String get checkinNote => isArabic ? 'ملاحظة اختيارية' : 'Optional note';
  String get checkinNoteHint => isArabic ? 'أي شيء تودّين إضافته...' : 'Anything you\'d like to add...';
  String get checkinSave => isArabic ? 'حفظ' : 'Save';
  String get checkinDone => isArabic ? 'تمّ التسجيل ✓' : 'Check-in complete ✓';
  String get checkinSuccessTitle => isArabic ? 'شكراً على مشاركتكِ 💜' : 'Thank you for sharing 💜';
  String get checkinSuccessBody => isArabic
      ? 'تسجيل حالكِ يساعدنا على تقديم دعم أفضل.'
      : 'Checking in helps us provide better support for you.';
  List<String> get moodEmojis => ['😔', '😟', '😐', '🙂', '😊'];
  List<String> get moodLabels => isArabic
      ? ['صعب جداً', 'صعب', 'عادي', 'جيد', 'ممتاز']
      : ['Very hard', 'Hard', 'Okay', 'Good', 'Great'];
  List<String> get challengeChips => isArabic
      ? ['إرهاق', 'غثيان', 'ألم', 'قلق', 'صعوبة في النوم', 'فقدان شهية', 'صداع', 'دوار']
      : ['Fatigue', 'Nausea', 'Pain', 'Anxiety', 'Sleep trouble', 'Poor appetite', 'Headache', 'Dizziness'];

  // ── General ────────────────────────────────────────────────────────────────
  String get ok => isArabic ? 'حسناً' : 'OK';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get viewAll => isArabic ? 'عرض الكل' : 'View all';
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get error => isArabic ? 'حدث خطأ' : 'An error occurred';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get noData => isArabic ? 'لا توجد بيانات' : 'No data';
  String get pending => isArabic ? 'بانتظار' : 'pending';
  String get allGood => isArabic ? 'كل شيء ✓' : 'All good ✓';
  String get today => isArabic ? 'اليوم' : 'Today';
  String get tomorrow => isArabic ? 'غداً' : 'Tomorrow';
  String daysFromNow(int d) => isArabic ? 'خلال $d أيام' : 'in $d days';
  String dayOf(int d) => isArabic ? 'اليوم $d' : 'Day $d';
  String cycleNum(int n) => isArabic ? 'الدورة $n' : 'Cycle $n';

  // Language display name for settings toggle
  String get currentLanguageName => isArabic ? 'العربية' : 'English';
  String get otherLanguageName => isArabic ? 'English' : 'العربية';
  String get switchLanguage => isArabic ? 'Switch to English' : 'التبديل إلى العربية';
}

// ── InheritedWidget to propagate l10n ─────────────────────────────────────────
class L10nProvider extends StatelessWidget {
  final bool isArabic;
  final Widget child;
  const L10nProvider({super.key, required this.isArabic, required this.child});

  @override
  Widget build(BuildContext context) {
    return _L10nInherited(
      l10n: AppLocalizations(isArabic: isArabic),
      child: child,
    );
  }
}

class _L10nInherited extends InheritedWidget {
  final AppLocalizations l10n;
  const _L10nInherited({required this.l10n, required super.child});

  @override
  bool updateShouldNotify(_L10nInherited old) => old.l10n.isArabic != l10n.isArabic;
}
