import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/models.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _session = UserSession();
  late ChemoPhase _phase;
  late List<ProtocolSymptom> _symptoms;

  // Steps: 0=greeting, 1..N=symptom, N+1=watchSymptoms (if any), then mood, note
  int _step = 0;
  MoodLevel _mood = MoodLevel.okay;
  bool _moodSelected = false;
  final Map<String, String> _symptomAnswers = {}; // key → 'none'|'mild'|'significant'
  final Map<String, bool> _interferenceAnswers = {}; // key → yes/no
  String _note = '';

  static const _scores = {'none': 1.0, 'mild': 4.0, 'significant': 7.0};

  @override
  void initState() {
    super.initState();
    if (_session.isMonitoring) {
      _symptoms = _session.isScanxietyPeriod
          ? MonitoringSymptomLibrary.scanxietySymptoms
          : MonitoringSymptomLibrary.standardSymptoms;
      _phase = ChemoPhase(
        name: 'Monitoring & surveillance',
        description: 'Post-treatment monitoring',
        cycleDay: 0, cycleDayEnd: 999,
        phaseNote: 'Every check-in helps your care team track your wellbeing.',
        primarySymptoms: _symptoms,
        watchSymptoms: [],
      );
    } else {
      _phase = _session.currentPhase;
      _symptoms = _phase.primarySymptoms;
    }
  }

  // ── Step mapping ──────────────────────────────────────────────────────────
  bool get _isGreeting => _step == 0;
  bool get _isSymptom => _step >= 1 && _step <= _symptoms.length;
  bool get _isWatchScreen =>
      _phase.watchSymptoms.isNotEmpty &&
      _step == _symptoms.length + 1;
  bool get _isMood {
    final offset = _phase.watchSymptoms.isNotEmpty ? 1 : 0;
    return _step == _symptoms.length + 1 + offset;
  }
  bool get _isNote {
    final offset = _phase.watchSymptoms.isNotEmpty ? 1 : 0;
    return _step == _symptoms.length + 2 + offset;
  }

  int get _totalDots {
    final offset = _phase.watchSymptoms.isNotEmpty ? 1 : 0;
    return _symptoms.length + 2 + offset; // symptoms + watch? + mood + note
  }

  ProtocolSymptom? get _currentSymptom =>
      _isSymptom ? _symptoms[_step - 1] : null;

  // Is current symptom showing interference follow-up?
  bool get _showingInterference {
    final s = _currentSymptom;
    if (s == null) return false;
    return _symptomAnswers[s.key] == 'significant' &&
        s.interferenceQuestion != null;
  }

  void _next() {
    if (_isNote) { _save(); return; }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
    else context.go('/');
  }

  void _save() {
    _session.moodEmoji = _mood.emoji;
    _session.moodLabel = _mood.label;
    _session.symptomScores = {
      for (final e in _symptomAnswers.entries)
        e.key: _scores[e.value] ?? 1.0,
    };
    _session.interferenceAnswers = _interferenceAnswers;
    if (_note.isNotEmpty) _session.checkInNote = _note;
    _session.lastCheckIn = DateTime.now();
    _session.saveCheckIn();
    context.go('/checkin/success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2),
      body: SafeArea(
        child: Column(children: [
          _buildTopBar(),
          Expanded(child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero).animate(CurvedAnimation(
                  parent: anim, curve: Curves.easeOut)),
              child: FadeTransition(opacity: anim, child: child)),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: _buildCurrentStep()),
          )),
        ]),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: _back,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEDE9E3)),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 14, color: Color(0xFF2C2C2C)))),
        const SizedBox(width: 12),
        Expanded(child: _isGreeting
          ? const SizedBox.shrink()
          : Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalDots, (i) {
              final active = i == _step - 1;
              final done = i < _step - 1;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: active ? 18 : 7, height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active ? _phaseColor()
                      : done ? _phaseColor().withOpacity(0.35)
                      : const Color(0xFFEDE9E3),
                  borderRadius: BorderRadius.circular(4)));
            }))),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _phaseColor().withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _phaseColor().withOpacity(0.25), width: 0.5)),
          child: Text(_phasePillLabel(),
            style: TextStyle(fontFamily: 'Inter', fontSize: 10,
              fontWeight: FontWeight.w600, color: _phaseColor()))),
      ]),
    );
  }

  Color _phaseColor() {
    if (_session.isMonitoring) return AppColors.teal;
    if (_session.isNadirWindow) return AppColors.peach;
    if (_session.isNadirApproaching) return AppColors.gold;
    return AppColors.primary;
  }

  String _phasePillLabel() {
    if (_session.isMonitoring)
      return _session.isScanxietyPeriod ? '⚡ Scan approaching' : '🎗️ Monitoring';
    if (_session.isNadirWindow)
      return '⚠ Nadir · Day ${_session.dayInCycle}';
    return '${_session.protocol.name} · Day ${_session.dayInCycle}';
  }

  Widget _buildCurrentStep() {
    if (_isGreeting) return _buildGreeting();
    if (_isSymptom) return _buildSymptomStep(_currentSymptom!);
    if (_isWatchScreen) return _buildWatchScreen();
    if (_isMood) return _buildMoodStep();
    if (_isNote) return _buildNoteStep();
    return _buildGreeting();
  }

  // ── Greeting ───────────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    final name = _session.displayName;
    final streak = _session.streak;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
      child: Column(children: [
        const Spacer(),
        Text(_phaseIcon(), style: const TextStyle(fontSize: 56)),
        const SizedBox(height: 20),
        Text('Sabah el kheir,\n$name',
          style: const TextStyle(fontFamily: 'Inter',
            fontSize: 28, fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C), height: 1.2),
          textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(_greetingContext(),
          style: const TextStyle(fontFamily: 'Inter',
            fontSize: 14, color: Color(0xFF7A7A7A)),
          textAlign: TextAlign.center),
        const SizedBox(height: 14),
        if (_session.isNadirWindow || _session.isScanxietyPeriod)
          _buildGreetingAlert(),
        const SizedBox(height: 14),
        Text(
          'This will take about 60 seconds —\nyour care team is listening.',
          style: const TextStyle(fontFamily: 'Inter',
            fontSize: 13, color: Color(0xFF7A7A7A), height: 1.65),
          textAlign: TextAlign.center),
        if (streak > 1) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEDE9E3)),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('🔥', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 7),
              Text('$streak-day streak — keep it up!',
                style: const TextStyle(fontFamily: 'Inter',
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: Color(0xFF2C2C2C))),
            ])),
        ],
        const SizedBox(height: 16),
      ]),
    )),
    Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: _primaryBtn('Start my check-in →', _next),
      ]),
    );
  }

  Widget _buildGreetingAlert() {
    final isNadir = _session.isNadirWindow;
    final color = isNadir ? AppColors.peach : AppColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(isNadir ? '⚠' : '⚡', style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 7),
        Flexible(child: Text(
          isNadir
              ? 'Nadir — monitor temperature twice daily'
              : 'Scan approaching — how you feel matters',
          style: TextStyle(fontFamily: 'Inter', fontSize: 12,
            color: color, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center)),
      ]),
    );
  }

  String _phaseIcon() {
    if (_session.isMonitoring) return '🎗️';
    if (_session.isNadirWindow) return '🌡️';
    if (_session.isNadirApproaching) return '⚡';
    final name = _phase.name.toLowerCase();
    if (name.contains('nausea') || name.contains('infusion')) return '🌿';
    if (name.contains('nadir')) return '🌡️';
    if (name.contains('recovery')) return '🌱';
    if (name.contains('taxol') || name.contains('joint')) return '💊';
    return '💜';
  }

  String _greetingContext() {
    if (_session.isMonitoring)
      return '${_session.daysCancerFree} days cancer-free\nMonitoring & surveillance';
    return '${_session.protocol.name} · Cycle ${_session.currentCycle} · Day ${_session.dayInCycle}';
  }

  // ── Symptom step ───────────────────────────────────────────────────────────
  Widget _buildSymptomStep(ProtocolSymptom s) {
    final answer = _symptomAnswers[s.key];
    final showInterference = answer == 'significant' && s.interferenceQuestion != null;
    final hasInterferenceAnswer = !showInterference || _interferenceAnswers.containsKey(s.key);
    final canContinue = answer != null && hasInterferenceAnswer;
    final isUrgentSignificant = answer == 'significant' && s.isUrgent;

    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Tag
        Text(s.label.toUpperCase(),
          style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
            fontWeight: FontWeight.w700, color: Color(0xFF6B9E78),
            letterSpacing: 0.08)),
        const SizedBox(height: 8),
        // Question
        Text(_symptomQuestion(s),
          style: const TextStyle(fontFamily: 'Inter',
            fontSize: 24, fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C), height: 1.3)),
        const SizedBox(height: 20),

        // Answer cards — symptom-specific scale
        _answerCard(_answersFor(s)[0].$1, s, answer, _answersFor(s)[0].$2, _answersFor(s)[0].$3, _answersFor(s)[0].$4),
        const SizedBox(height: 8),
        _answerCard(_answersFor(s)[1].$1, s, answer, _answersFor(s)[1].$2, _answersFor(s)[1].$3, _answersFor(s)[1].$4),
        const SizedBox(height: 8),
        _answerCard(_answersFor(s)[2].$1, s, answer, _answersFor(s)[2].$2, _answersFor(s)[2].$3, _answersFor(s)[2].$4),

        // Interference follow-up
        if (showInterference) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDE9E3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.interferenceQuestion!,
                style: const TextStyle(fontFamily: 'Inter',
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: Color(0xFF2C2C2C))),
              const SizedBox(height: 10),
              Row(children: [
                _interferenceBtn(s.key, true, 'Yes'),
                const SizedBox(width: 8),
                _interferenceBtn(s.key, false, 'No'),
              ]),
            ])),
        ],

        // Urgent warning
        if (isUrgentSignificant && s.urgentMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.roseLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.rose.withOpacity(0.3))),
            child: Row(children: [
              const Text('🚨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(child: Text(s.urgentMessage!,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  fontWeight: FontWeight.w500, color: AppColors.rose,
                  height: 1.5))),
            ])),
        ],

        // Tip for mild/significant
        if (answer != null && answer != 'none' && s.tip != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDE9E3))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💡', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 7),
              Expanded(child: Text(s.tip!,
                style: const TextStyle(fontFamily: 'Inter',
                  fontSize: 12, color: Color(0xFF7A7A7A), height: 1.5))),
            ])),
        ],

        const SizedBox(height: 16),
      ]),
    )),
    Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      child: _primaryBtn('Continue →', canContinue ? _next : null),
    ),
  ]);
  }

  Widget _answerCard(String val, ProtocolSymptom s, String? current,
      String emoji, String label, String sub) {
    final sel = current == val;
    final Color selColor;
    final Color selBg;
    switch (val) {
      case 'none':        selColor = const Color(0xFF6B9E78); selBg = const Color(0xFFEAF3EC); break;
      case 'mild':        selColor = const Color(0xFFE8B84B); selBg = const Color(0xFFFDF6E3); break;
      case 'significant': selColor = const Color(0xFFD4876A); selBg = const Color(0xFFFAF0EB); break;
      default:            selColor = AppColors.primary; selBg = AppColors.primaryLight;
    }

    return GestureDetector(
      onTap: () => setState(() {
        _symptomAnswers[s.key] = val;
        if (val != 'significant') _interferenceAnswers.remove(s.key);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: sel ? selBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sel ? selColor : const Color(0xFFEDE9E3),
            width: sel ? 2 : 1.5),
          boxShadow: [BoxShadow(
            color: sel
                ? selColor.withOpacity(0.12)
                : Colors.black.withOpacity(0.05),
            blurRadius: sel ? 6 : 8)]),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(label, style: TextStyle(fontFamily: 'Inter',
              fontSize: 14, fontWeight: FontWeight.w600,
              color: sel ? selColor : const Color(0xFF2C2C2C))),
            const SizedBox(height: 1),
            Text(sub, style: const TextStyle(fontFamily: 'Inter',
              fontSize: 12, color: Color(0xFF7A7A7A))),
          ])),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sel ? selColor : Colors.white,
              border: Border.all(
                color: sel ? selColor : const Color(0xFFDDD9D0), width: 2)),
            child: sel
                ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                : null),
        ]),
      ),
    );
  }

  Widget _interferenceBtn(String key, bool value, String label) {
    final current = _interferenceAnswers[key];
    final sel = current == value;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _interferenceAnswers[key] = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: sel ? AppColors.primaryLight : const Color(0xFFF5F3F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? AppColors.primaryMid : const Color(0xFFEDE9E3),
            width: sel ? 1.5 : 1)),
        child: Center(child: Text(label,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13,
            fontWeight: FontWeight.w500,
            color: sel ? AppColors.primary : const Color(0xFF7A7A7A))))),
    ));
  }


  static List<(String, String, String, String)> _answersFor(ProtocolSymptom s) {
    switch (s.key) {
      case 'fever': return [('none','🌡️','Normal','No fever'),('mild','🤒','Low-grade','Below 38C'),('significant','🔴','High 38C+','Call team now')];
      case 'fatigue': case 'energy': return [('none','⚡','Good energy','Feeling fine'),('mild','😴','Tired','Low energy'),('significant','🛋️','Exhausted','Hard to move')];
      case 'nausea': return [('none','✅','None','Stomach fine'),('mild','😟','Some nausea','Can still eat'),('significant','🤢','Strong nausea','Cannot eat')];
      case 'mood': return [('none','😊','Good','Feeling okay'),('mild','😐','So-so','Up and down'),('significant','😔','Low or anxious','Struggling')];
      case 'anxiety': return [('none','😌','Calm','Not anxious'),('mild','😟','Some worry','On edge'),('significant','😰','Very anxious','Hard to manage')];
      case 'sleep': return [('none','😴','Slept well','Good rest'),('mild','🌙','Disturbed','Woke up'),('significant','👁️','Barely slept','Very poor')];
      case 'pain': return [('none','✅','No pain','Comfortable'),('mild','😟','Mild pain','Manageable'),('significant','😔','Strong pain','Hard to ignore')];
      case 'joint_pain': return [('none','✅','No pain','Joints fine'),('mild','🦴','Mild ache','Sore but moving'),('significant','😔','Strong pain','Affecting movement')];
      case 'breathlessness': return [('none','🫁','Breathing fine','No breathlessness'),('mild','😤','With effort','Short of breath'),('significant','🔴','At rest','Call team now')];
      case 'infection': return [('none','✅','No signs','No redness'),('mild','👀','Some redness','Watching it'),('significant','🔴','Concerned','Call team')];
      case 'mouth_sores': return [('none','✅','None','Mouth fine'),('mild','👄','Mild sores','Can eat'),('significant','😔','Painful','Hard to eat')];
      case 'appetite': return [('none','🍽️','Good appetite','Eating normally'),('mild','😟','Reduced','Eating less'),('significant','🚫','Cannot eat','Nothing today')];
      case 'hot_flashes': return [('none','✅','None','No hot flashes'),('mild','🌡️','Mild','A few'),('significant','🔥','Frequent','Intense')];
      case 'neuropathy': return [('none','✅','None','No tingling'),('mild','🤲','Mild tingling','Manageable'),('significant','😔','Affecting me','Hands/feet affected')];
      case 'cognitive_fog': return [('none','🧠','Clear','Thinking clearly'),('mild','☁️','Some fog','Forgetful'),('significant','😵','Hard to focus','Cannot concentrate')];
      case 'fluid_retention': case 'swelling': return [('none','✅','No swelling','Normal'),('mild','💧','Mild','Puffiness'),('significant','😔','Noticeable','Visible swelling')];
      case 'palpitations': return [('none','❤️','Normal','Heart fine'),('mild','💓','Occasional','Rare flutter'),('significant','🔴','Concerning','Call team')];
      case 'night_sweats': return [('none','✅','None','No sweating'),('mild','💧','Mild','Some sweating'),('significant','😔','Severe','Woke drenched')];
      case 'vomiting': return [('none','✅','None','No vomiting'),('mild','😟','1-2 times','A couple of episodes'),('significant','🤢','3+ times','Multiple - contact team')];
      case 'hair_loss': return [('none','✅','None','No hair loss'),('mild','💇','Some loss','Thinning noticed'),('significant','😔','Significant','Noticeable patches')];
      case 'skin_nails': return [('none','✅','None','Skin and nails fine'),('mild','💅','Mild changes','Some dryness or discoloration'),('significant','😔','Significant','Painful or affecting daily life')];
      case 'constipation': return [('none','✅','None','Normal today'),('mild','😟','Mild','Some discomfort'),('significant','😔','Significant','No movement 2+ days')];
      case 'diarrhea': return [('none','✅','None','Normal today'),('mild','😟','Mild','A couple of times'),('significant','😔','Frequent','4+ times - contact team')];
      case 'vaginal_discomfort': return [('none','✅','None','No discomfort'),('mild','😟','Mild','Some dryness or irritation'),('significant','😔','Significant','Affecting daily life')];
      case 'weight': return [('none','✅','Stable','No change noticed'),('mild','😟','Some change','Slight gain or loss'),('significant','😔','Noticeable change','Worth discussing with team')];
      default: return [('none','✅','None','Not a concern'),('mild','😐','Mild','Manageable'),('significant','😔','Significant','Affecting my day')];
    }
  }

  String _symptomQuestion(ProtocolSymptom s) {
    const map = {
      'fever':            'Any fever or chills today?',
      'fatigue':          "How's your energy today?",
      'nausea':           'Any nausea or stomach discomfort?',
      'vomiting':         'Any vomiting today?',
      'pain':             'Any pain today?',
      'joint_pain':       'Any joint or muscle pain?',
      'neuropathy':       'Any tingling or numbness?',
      'mouth_sores':      'Any mouth sores today?',
      'appetite':         "How's your appetite?",
      'breathlessness':   'Any breathlessness today?',
      'infection':        'Any signs of infection?',
      'fluid_retention':  'Any swelling or fluid retention?',
      'anxiety':          'How is your anxiety today?',
      'mood':             "How are you feeling emotionally?",
      'sleep':            "How did you sleep last night?",
      'hot_flashes':      'Any hot flashes today?',
      'night_sweats':     'Any night sweats?',
      'cognitive_fog':    'Any brain fog today?',
      'body_image':       'How are you feeling about your body?',
      'vaginal_discomfort':'Any vaginal discomfort today?',
      'weight_changes':   'Any concerns about your weight?',
      'energy':           "How's your energy level?",
      'palpitations':     'Any heart palpitations or chest discomfort?',
      'constipation':     'Any constipation today?',
      'diarrhea':         'Any diarrhoea today?',
      'swelling':         'Any swelling in legs or ankles?',
    };
    return map[s.key] ?? 'How is your ${s.label.toLowerCase()} today?';
  }

  // ── Watch symptoms screen ──────────────────────────────────────────────────
  Widget _buildWatchScreen() {
    final watches = _phase.watchSymptoms;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('WATCH FOR TODAY',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
            fontWeight: FontWeight.w700, color: Color(0xFFD4876A),
            letterSpacing: 0.08)),
        const SizedBox(height: 8),
        const Text('Signs that need\nimmediate attention',
          style: TextStyle(fontFamily: 'Inter',
            fontSize: 24, fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C), height: 1.3)),
        const SizedBox(height: 6),
        Text('These are phase-specific warnings for ${_phase.name}.',
          style: const TextStyle(fontFamily: 'Inter',
            fontSize: 13, color: Color(0xFF7A7A7A))),
        const SizedBox(height: 20),
        Expanded(child: ListView.separated(
          itemCount: watches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final w = watches[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: w.isUrgent
                    ? AppColors.roseLight : AppColors.peachLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: w.isUrgent
                      ? AppColors.rose.withOpacity(0.25)
                      : AppColors.peach.withOpacity(0.25))),
              child: Row(children: [
                Text(w.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.label, style: TextStyle(fontFamily: 'Inter',
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: w.isUrgent ? AppColors.rose : AppColors.peach)),
                  if (w.urgentMessage != null) ...[
                    const SizedBox(height: 3),
                    Text(w.urgentMessage!,
                      style: const TextStyle(fontFamily: 'Inter',
                        fontSize: 12, color: Color(0xFF7A7A7A), height: 1.5)),
                  ],
                ])),
              ]),
            );
          },
        )),
        _primaryBtn('I understand — continue →', _next),
      ]),
    );
  }

  // ── Mood step ──────────────────────────────────────────────────────────────
  Widget _buildMoodStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('OVERALL MOOD',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
            fontWeight: FontWeight.w700, color: Color(0xFF6B9E78),
            letterSpacing: 0.08)),
        const SizedBox(height: 8),
        const Text('How are you feeling\nemotionally today?',
          style: TextStyle(fontFamily: 'Inter',
            fontSize: 24, fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C), height: 1.3)),
        const SizedBox(height: 28),
        Expanded(child: Center(child: Row(
          children: MoodLevel.values.map((m) {
            final sel = m == _mood && _moodSelected;
            return Expanded(child: GestureDetector(
              onTap: () => setState(() { _mood = m; _moodSelected = true; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(right: m != MoodLevel.great ? 7 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFFF0EEF9) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? const Color(0xFF9B8EC4) : const Color(0xFFEDE9E3),
                    width: sel ? 2 : 1.5),
                  boxShadow: [BoxShadow(
                    color: sel
                        ? const Color(0xFF9B8EC4).withOpacity(0.18)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: sel ? 14 : 6)]),
                child: Column(children: [
                  Text(m.emoji, style: TextStyle(fontSize: sel ? 26 : 22)),
                  const SizedBox(height: 5),
                  Text(m.label, style: TextStyle(fontFamily: 'Inter',
                    fontSize: 9, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? const Color(0xFF9B8EC4) : const Color(0xFF7A7A7A))),
                ]),
              ),
            ));
          }).toList(),
        ))),
        _primaryBtn('Continue →', _moodSelected ? _next : null),
      ]),
    );
  }

  // ── Note step ──────────────────────────────────────────────────────────────
  Widget _buildNoteStep() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR WORDS',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
            fontWeight: FontWeight.w700, color: Color(0xFF6B9E78),
            letterSpacing: 0.08)),
        const SizedBox(height: 8),
        const Text('Anything on\nyour mind today?',
          style: TextStyle(fontFamily: 'Inter',
            fontSize: 24, fontWeight: FontWeight.w300,
            color: Color(0xFF2C2C2C), height: 1.3)),
        const SizedBox(height: 6),
        const Text('Optional — your words appear verbatim\nin your doctor\'s report.',
          style: TextStyle(fontFamily: 'Inter',
            fontSize: 13, color: Color(0xFF7A7A7A), height: 1.5)),
        const SizedBox(height: 16),
        Expanded(child: TextField(
          maxLines: null, expands: true,
          textAlignVertical: TextAlignVertical.top,
          onChanged: (v) => _note = v,
          style: const TextStyle(fontFamily: 'Inter',
            fontSize: 15, color: Color(0xFF2C2C2C), height: 1.65),
          decoration: InputDecoration(
            hintText: 'You can share anything here...',
            hintStyle: const TextStyle(fontFamily: 'Inter',
              fontSize: 15, color: Color(0xFFB0A890)),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEDE9E3), width: 1.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEDE9E3), width: 1.5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF9B8EC4), width: 2))),
        )),
        const SizedBox(height: 14),
        _primaryBtn('Save check-in ✓', _save),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _save,
          child: const Center(child: Text('Skip — nothing to add',
            style: TextStyle(fontFamily: 'Inter',
              fontSize: 13, color: Color(0xFF7A7A7A),
              decoration: TextDecoration.underline)))),
      ]),
    );
  }

  // ── Primary button ─────────────────────────────────────────────────────────
  Widget _primaryBtn(String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF6B9E78) : const Color(0xFFC5D3C7),
          borderRadius: BorderRadius.circular(26),
          boxShadow: enabled ? [BoxShadow(
            color: const Color(0xFF6B9E78).withOpacity(0.30),
            blurRadius: 16, offset: const Offset(0, 5))] : []),
        child: Center(child: Text(label,
          style: const TextStyle(fontFamily: 'Inter',
            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white))),
      ),
    );
  }
}
