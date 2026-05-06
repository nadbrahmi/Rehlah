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

// Also expose under the old name so app_router.dart import doesn't break
typedef CheckInSlidersScreen = CheckInScreen;

class _CheckInScreenState extends State<CheckInScreen> {
  final _session = UserSession();
  late ChemoPhase _phase;
  late List<ProtocolSymptom> _symptoms;

  int _step = 0;
  MoodLevel _mood = MoodLevel.okay;
  bool _moodSelected = false;
  final Map<String, String> _symptomAnswers = {};
  final Map<String, bool> _interferenceAnswers = {};
  String _note = '';
  final Set<String> _medsTakenInCheckin = {};
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
        cycleDay: 0,
        cycleDayEnd: 999,
        phaseNote: 'Every check-in helps your care team track your wellbeing.',
        primarySymptoms: _symptoms,
        watchSymptoms: [],
      );
    } else {
      _phase = _session.currentPhase;
      _symptoms = _phase.primarySymptoms;
    }
  }

  // ── Step mapping ───────────────────────────────────────────────
  bool get _isGreeting => _step == 0;
  bool get _isSymptom  => _step >= 1 && _step <= _symptoms.length;
  int  get _wo         => _phase.watchSymptoms.isNotEmpty ? 1 : 0;
  bool get _isWatchScreen =>
      _phase.watchSymptoms.isNotEmpty && _step == _symptoms.length + 1;
  bool get _isMood => _step == _symptoms.length + 1 + _wo;
  bool get _isMeds => _step == _symptoms.length + 2 + _wo;
  bool get _isNote => false; // note combined with mood screen
  int  get _totalDots => _symptoms.length + 2 + _wo;

  ProtocolSymptom? get _currentSymptom =>
      _isSymptom ? _symptoms[_step - 1] : null;

  bool get _showingInterference {
    final s = _currentSymptom;
    if (s == null) return false;
    return _symptomAnswers[s.key] == 'significant' &&
        s.interferenceQuestion != null;
  }

  void _next() {
    if (_isMeds) { _save(); return; }
    setState(() => _step++);
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
    else context.go('/');
  }

  // FIX: async save, null-safe lastCheckIn, await saveCheckIn()
  Future<void> _save() async {
    _session.moodEmoji = _mood.emoji;
    _session.moodLabel = _mood.label;
    _session.symptomScores = {
      for (final e in _symptomAnswers.entries)
        e.key: _scores[e.value] ?? 1.0,
    };
    _session.interferenceAnswers = _interferenceAnswers;
    if (_note.isNotEmpty) _session.checkInNote = _note;
    _session.lastCheckIn = DateTime.now();

    debugPrint('[CheckIn] saved: ${_session.lastCheckIn?.toIso8601String()}');
    await _session.saveCheckIn();
    debugPrint('[CheckIn] hasCheckedInToday: ${_session.hasCheckedInToday}');

    if (mounted) context.go('/checkin/success');
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: Column(children: [
          _buildTopBar(),
          Expanded(child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: FadeTransition(opacity: anim, child: child)),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: _buildCurrentStep()),
          )),
        ]),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 0),
      child: Row(children: [
        // Back button
        GestureDetector(
          onTap: _back,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEDE9E3)),
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
            child: _isGreeting
                ? const SizedBox.shrink()
                : const Center(child: Text('←',
                    style: TextStyle(fontSize: 18, color: Color(0xFF2C2C2C)))))),
        const SizedBox(width: 12),
        // Progress dots
        Expanded(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_totalDots, (i) {
            final active = i == _step - 1;
            final done = i < _step - 1;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: active ? 20 : 7, height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF6B9E78)
                    : done
                        ? const Color(0xFF6B9E78).withOpacity(0.35)
                        : const Color(0xFFEDE9E3),
                borderRadius: BorderRadius.circular(4)));
          }))),
        const SizedBox(width: 12),
        // Phase label (top right)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDE9E3)),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06), blurRadius: 6)]),
          child: Text('AR',
            style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12,
              fontWeight: FontWeight.w600, color: Color(0xFF7A7A7A)))),
      ]),
    );
  }

  Widget _buildCurrentStep() {
    if (_isGreeting)    return _buildGreeting();
    if (_isSymptom)     return _buildSymptomStep(_currentSymptom!);
    if (_isWatchScreen) return _buildWatchScreen();
    if (_isMood)        return _buildMoodStep();
    if (_isMeds)        return _buildMedsStep();
    return _buildGreeting();
  }

  // ── S1: Greeting ─────────────────────────────────────────────────
  Widget _buildGreeting() {
    final name = _session.displayName;
    final streak = _session.streak;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const SizedBox(height: 12),
          Text(_phaseIcon(), style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text('Sabah el kheir, $name',
            style: const TextStyle(fontFamily: 'Fraunces',
              fontSize: 34, fontWeight: FontWeight.w400,
              color: Color(0xFF2C2C2C), height: 1.2),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(_greetingContext(),
            style: const TextStyle(fontFamily: 'DM Sans',
              fontSize: 15, color: Color(0xFF7A7A7A)),
            textAlign: TextAlign.center),
          const SizedBox(height: 12),
          // Phase pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF6E3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0D080))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_session.isNadirWindow ? '⚠️' : '🌿',
                style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(_phasePillLabel(),
                style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12,
                  fontWeight: FontWeight.w600, color: Color(0xFF9A7000))),
            ])),
          const SizedBox(height: 16),
          Text('This will take about 60 seconds —\nyour care team is listening.',
            style: const TextStyle(fontFamily: 'DM Sans',
              fontSize: 14, color: Color(0xFF7A7A7A), height: 1.65),
            textAlign: TextAlign.center),
          const SizedBox(height: 28),
          _primaryBtn('Start my check-in →', _next),
          if (streak > 1) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEDE9E3)),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.07), blurRadius: 8)]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text('$streak-day streak — keep it up!',
                  style: const TextStyle(fontFamily: 'DM Sans',
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: Color(0xFF2C2C2C))),
              ])),
          ],
        ]),
      ),
    );
  }

  String _phaseIcon() {
    if (_session.isMonitoring) return '🎗️';
    if (_session.isNadirWindow) return '🌡️';
    if (_session.isNadirApproaching) return '⚡';
    return '🌿';
  }

  String _greetingContext() {
    if (_session.isMonitoring)
      return '${_session.daysCancerFree} days cancer-free · Monitoring';
    return 'Day ${_session.dayInCycle} of your ${_session.protocol.name} cycle';
  }

  String _phasePillLabel() {
    if (_session.isMonitoring)
      return _session.isScanxietyPeriod ? 'Scan approaching' : 'Monitoring & surveillance';
    if (_session.isNadirWindow)
      return 'Nadir window · Days 6–14';
    return '${_session.protocol.name} · Day ${_session.dayInCycle}';
  }

  Color _phaseColor() {
    if (_session.isMonitoring) return AppColors.teal;
    if (_session.isNadirWindow) return AppColors.peach;
    return AppColors.primary;
  }

  // ── S2–5: Symptom step ────────────────────────────────────────────
  Widget _buildSymptomStep(ProtocolSymptom s) {
    final answer = _symptomAnswers[s.key];
    final showInterference = answer == 'significant' && s.interferenceQuestion != null;
    final hasInterferenceAnswer = !showInterference || _interferenceAnswers.containsKey(s.key);
    final canContinue = answer != null && hasInterferenceAnswer;
    final isUrgent = answer == 'significant' && s.isUrgent;
    final defs = _answersFor(s);

    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Tag
          Text(s.label.toUpperCase(),
            style: const TextStyle(fontFamily: 'DM Sans', fontSize: 11,
              fontWeight: FontWeight.w700, color: Color(0xFF6B9E78),
              letterSpacing: 0.08)),
          const SizedBox(height: 10),
          // Question — Fraunces serif
          Text(_symptomQuestion(s),
            style: const TextStyle(fontFamily: 'Fraunces', fontSize: 26,
              fontWeight: FontWeight.w400, color: Color(0xFF2C2C2C), height: 1.3)),
          const SizedBox(height: 24),
          // Option cards — flex:1 equivalent
          ...List.generate(defs.length, (i) => Padding(
            padding: EdgeInsets.only(bottom: i < defs.length - 1 ? 12 : 0),
            child: _ocard(defs[i][0], s, answer, defs[i][1], defs[i][2], defs[i][3]))),
          // Interference question
          if (showInterference) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE9E3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.interferenceQuestion!,
                  style: const TextStyle(fontFamily: 'DM Sans', fontSize: 14,
                    fontWeight: FontWeight.w500, color: Color(0xFF2C2C2C))),
                const SizedBox(height: 10),
                Row(children: [
                  _interferenceBtn(s.key, true, 'Yes'),
                  const SizedBox(width: 8),
                  _interferenceBtn(s.key, false, 'No'),
                ]),
              ])),
          ],
          // Urgent warning
          if (isUrgent && s.urgentMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFEECEC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD4876A).withOpacity(0.4))),
              child: Row(children: [
                const Text('🚨', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(child: Text(s.urgentMessage!,
                  style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12,
                    fontWeight: FontWeight.w500, color: Color(0xFFD4876A), height: 1.5))),
              ])),
          ],
          const SizedBox(height: 32),
        ]),
      )),
      // Bottom actions
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(children: [
          _primaryBtn('Continue →', canContinue ? _next : null),
          const SizedBox(height: 10),
          _skipRow(),
        ])),
    ]);
  }

  // ── Option card (ocard in HTML) ────────────────────────────────────
  Widget _ocard(String val, ProtocolSymptom s, String? current,
      String emoji, String label, String sub) {
    final sel = current == val;
    final Color border, bg, textColor;
    switch (val) {
      case 'none':
        border = sel ? const Color(0xFF6B9E78) : const Color(0xFFEDE9E3);
        bg = sel ? const Color(0xFFEAF3EC) : Colors.white;
        textColor = sel ? const Color(0xFF6B9E78) : const Color(0xFF2C2C2C);
        break;
      case 'mild':
        border = sel ? const Color(0xFFE8B84B) : const Color(0xFFEDE9E3);
        bg = sel ? const Color(0xFFFDF6E3) : Colors.white;
        textColor = sel ? const Color(0xFFE8B84B) : const Color(0xFF2C2C2C);
        break;
      default: // significant
        border = sel ? const Color(0xFFD4876A) : const Color(0xFFEDE9E3);
        bg = sel ? const Color(0xFFFAF0EB) : Colors.white;
        textColor = sel ? const Color(0xFFD4876A) : const Color(0xFF2C2C2C);
    }

    return GestureDetector(
      onTap: () => setState(() {
        _symptomAnswers[s.key] = val;
        if (val != 'significant') _interferenceAnswers.remove(s.key);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 2),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontFamily: 'DM Sans',
              fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(height: 3),
            Text(sub, style: const TextStyle(fontFamily: 'DM Sans',
              fontSize: 12.5, color: Color(0xFF7A7A7A))),
          ])),
          // Check circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 26, height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sel ? border : Colors.white,
              border: Border.all(color: sel ? border : const Color(0xFFEDE9E3), width: 2)),
            child: sel
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null),
        ]),
      ),
    );
  }

  Widget _interferenceBtn(String key, bool value, String label) {
    final sel = _interferenceAnswers[key] == value;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _interferenceAnswers[key] = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFEAF3EC) : const Color(0xFFF5F3F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? const Color(0xFF6B9E78) : const Color(0xFFEDE9E3))),
        child: Center(child: Text(label,
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 13,
            fontWeight: FontWeight.w500,
            color: sel ? const Color(0xFF6B9E78) : const Color(0xFF7A7A7A)))))));
  }

  // ── Watch screen ──────────────────────────────────────────────────
  Widget _buildWatchScreen() {
    final watches = _phase.watchSymptoms;
    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('WATCH FOR TODAY',
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 11,
              fontWeight: FontWeight.w700, color: Color(0xFFD4876A),
              letterSpacing: 0.08)),
          const SizedBox(height: 10),
          const Text('Signs that need\nimmediate attention',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 26,
              fontWeight: FontWeight.w400, color: Color(0xFF2C2C2C), height: 1.3)),
          const SizedBox(height: 24),
          ...watches.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: w.isUrgent
                    ? const Color(0xFFFEECEC) : const Color(0xFFFDF6E3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: w.isUrgent
                      ? const Color(0xFFD4876A).withOpacity(0.3)
                      : const Color(0xFFE8B84B).withOpacity(0.3))),
              child: Row(children: [
                Text(w.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w.label, style: TextStyle(fontFamily: 'DM Sans',
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: w.isUrgent
                        ? const Color(0xFFD4876A) : const Color(0xFFE8B84B))),
                  if (w.urgentMessage != null) ...[
                    const SizedBox(height: 3),
                    Text(w.urgentMessage!, style: const TextStyle(
                      fontFamily: 'DM Sans', fontSize: 12,
                      color: Color(0xFF7A7A7A), height: 1.5)),
                  ],
                ])),
              ]),
            ))),
          const SizedBox(height: 16),
        ]),
      )),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(children: [
          _primaryBtn('I understand — continue →', _next),
          const SizedBox(height: 10),
          _skipRow(),
        ])),
    ]);
  }

  // ── S5: Mood + Note (combined like HTML) ─────────────────────────
  Widget _buildMoodStep() {
    final noteCtrl = TextEditingController(text: _note);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('MOOD',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 11,
            fontWeight: FontWeight.w700, color: Color(0xFF6B9E78),
            letterSpacing: 0.08)),
        const SizedBox(height: 10),
        const Text('How are you feeling\nemotionally?',
          style: TextStyle(fontFamily: 'Fraunces', fontSize: 26,
            fontWeight: FontWeight.w400, color: Color(0xFF2C2C2C), height: 1.3)),
        const SizedBox(height: 20),
        // Mood row — 5 cards like HTML .mood-row
        Row(children: MoodLevel.values.map((m) {
          final sel = m == _mood && _moodSelected;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() { _mood = m; _moodSelected = true; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: m != MoodLevel.great ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFF0EEF9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel
                      ? const Color(0xFF9B8EC4) : const Color(0xFFEDE9E3),
                  width: 2),
                boxShadow: [BoxShadow(
                  color: sel
                      ? const Color(0xFF9B8EC4).withOpacity(0.22)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: sel ? 20 : 10)]),
              child: Column(children: [
                Text(m.emoji,
                  style: TextStyle(fontSize: sel ? 28 : 22)),
                const SizedBox(height: 6),
                Text(m.label, style: TextStyle(fontFamily: 'DM Sans',
                  fontSize: 10,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel
                      ? const Color(0xFF9B8EC4) : const Color(0xFF7A7A7A))),
              ]),
            )));
        }).toList()),
        const SizedBox(height: 20),
        // Note on same screen
        const Text("What\'s on your mind? (optional)",
          style: TextStyle(fontFamily: 'DM Sans',
            fontSize: 12, color: Color(0xFF7A7A7A))),
        const SizedBox(height: 8),
        Expanded(child: TextField(
          controller: noteCtrl,
          maxLines: null, expands: true,
          textAlignVertical: TextAlignVertical.top,
          onChanged: (v) => _note = v,
          style: const TextStyle(fontFamily: 'DM Sans',
            fontSize: 14, color: Color(0xFF2C2C2C), height: 1.6),
          decoration: InputDecoration(
            hintText: 'You can share anything here...',
            hintStyle: const TextStyle(fontFamily: 'DM Sans',
              fontSize: 14, color: Color(0xFFB0A890)),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEDE9E3), width: 1.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEDE9E3), width: 1.5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF9B8EC4), width: 2))),
        )),
        const SizedBox(height: 16),
        _primaryBtn('Continue →', _moodSelected ? _next : null),
        const SizedBox(height: 10),
        _skipRow(),
      ]),
    );
  }

  // ── S6: Medications ───────────────────────────────────────────────
  Widget _buildMedsStep() {
    final meds = _session.medications;
    final allDone = meds.isNotEmpty &&
        meds.every((m) => _medsTakenInCheckin.contains(m.id));

    return Column(children: [
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MEDICATIONS',
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 11,
              fontWeight: FontWeight.w700, color: Color(0xFF6B9E78),
              letterSpacing: 0.08)),
          const SizedBox(height: 10),
          const Text('Did you take your\nmedications today? 💊',
            style: TextStyle(fontFamily: 'Fraunces', fontSize: 26,
              fontWeight: FontWeight.w400, color: Color(0xFF2C2C2C), height: 1.3)),
          const SizedBox(height: 24),
          if (meds.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDE9E3))),
              child: const Text('No medications on record.',
                style: TextStyle(fontFamily: 'DM Sans',
                  fontSize: 13, color: Color(0xFF7A7A7A))))
          else
            // med-list
            Column(children: meds.map((med) {
              final taken = _medsTakenInCheckin.contains(med.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() {
                    if (taken) _medsTakenInCheckin.remove(med.id);
                    else {
                      _medsTakenInCheckin.add(med.id);
                      _session.markMedTaken(med.id);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: taken ? const Color(0xFFEAF3EC) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: taken
                            ? const Color(0xFF6B9E78) : const Color(0xFFEDE9E3),
                        width: taken ? 2 : 2),
                      boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.06), blurRadius: 10)]),
                    child: Row(children: [
                      // Circle check
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: taken
                              ? const Color(0xFF6B9E78) : Colors.white,
                          border: Border.all(
                            color: taken
                                ? const Color(0xFF6B9E78)
                                : const Color(0xFFEDE9E3),
                            width: 2)),
                        child: taken
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : null),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(med.name, style: TextStyle(
                          fontFamily: 'DM Sans', fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: taken
                              ? const Color(0xFF6B9E78)
                              : const Color(0xFF2C2C2C))),
                        const SizedBox(height: 2),
                        Text('${med.dose} · ${med.frequency}',
                          style: const TextStyle(fontFamily: 'DM Sans',
                            fontSize: 12, color: Color(0xFF7A7A7A))),
                      ])),
                      Text(med.emoji,
                        style: const TextStyle(fontSize: 22)),
                    ]),
                  ),
                ),
              );
            }).toList()),
          const SizedBox(height: 4),
          // All taken dashed button
          GestureDetector(
            onTap: () => setState(() {
              for (final m in meds) {
                if (!_medsTakenInCheckin.contains(m.id)) {
                  _medsTakenInCheckin.add(m.id);
                  _session.markMedTaken(m.id);
                }
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity, height: 46,
              decoration: BoxDecoration(
                color: allDone ? const Color(0xFFEAF3EC) : Colors.transparent,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: const Color(0xFF6B9E78), width: 1.5,
                  style: allDone ? BorderStyle.solid : BorderStyle.solid)),
              child: Center(child: Text(
                allDone ? '✓ All medications confirmed!' : '✓ All taken today',
                style: const TextStyle(fontFamily: 'DM Sans',
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: Color(0xFF6B9E78)))))),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _next,
            child: Center(child: Text("Couldn\'t take one? Skip",
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12,
                color: Color(0xFF7A7A7A),
                decoration: TextDecoration.underline)))),
          const SizedBox(height: 32),
        ]),
      )),
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(children: [
          _primaryBtn('Done →', _save),
          const SizedBox(height: 10),
          _skipRow(saveLabel: 'Save & exit'),
        ])),
    ]);
  }

  // ── Symptom question text ─────────────────────────────────────────
  String _symptomQuestion(ProtocolSymptom s) {
    const map = {
      'fever': 'Any fever or chills today?',
      'fatigue': "How\'s your energy today?",
      'energy': "How\'s your energy today?",
      'nausea': 'Any nausea or stomach discomfort?',
      'vomiting': 'Any vomiting today?',
      'pain': 'Any pain today?',
      'joint_pain': 'Any joint or muscle pain?',
      'neuropathy': 'Any tingling or numbness?',
      'mouth_sores': 'Any mouth sores today?',
      'appetite': "How\'s your appetite?",
      'breathlessness': 'Any breathlessness today?',
      'infection': 'Any signs of infection?',
      'fluid_retention': 'Any swelling or fluid retention?',
      'anxiety': 'How is your anxiety today?',
      'sleep': "How did you sleep last night?",
      'hot_flashes': 'Any hot flashes today?',
      'night_sweats': 'Any night sweats?',
      'cognitive_fog': 'Any brain fog today?',
      'palpitations': 'Any heart palpitations?',
      'constipation': 'Any constipation today?',
      'diarrhea': 'Any diarrhoea today?',
      'hair_loss': 'How is your hair loss today?',
    };
    return map[s.key] ?? 'How is your ${s.label.toLowerCase()} today?';
  }

  // ── _answersFor — symptom-specific scales ─────────────────────────
  List<List<String>> _answersFor(ProtocolSymptom s) {
    switch (s.key) {
      case 'fever': return [['none','🌡️','Normal','No fever today'],['mild','🤒','Low-grade','Below 38°C'],['significant','🔴','High 38°C+','Call your team now']];
      case 'fatigue': case 'energy': return [['none','🌟','Good energy','Feeling strong today'],['mild','🌿','A bit tired','Managing okay'],['significant','🌑','Exhausted','Really struggling today']];
      case 'nausea': return [['none','😊','None','Stomach feels fine'],['mild','🌊','Mild','Some discomfort'],['significant','🤢','Strong','Hard to eat or drink']];
      case 'vomiting': return [['none','✅','None','No vomiting today'],['mild','😟','1–2 times','A couple of episodes'],['significant','🤢','3+ times','Multiple — contact team']];
      case 'pain': return [['none','✨','No pain','Feeling comfortable'],['mild','💛','Mild pain','Manageable'],['significant','🔴','Strong pain','Needs attention']];
      case 'mood': return [['none','😊','Good','Feeling okay emotionally'],['mild','😐','So-so','Up and down today'],['significant','😔','Low or anxious','Struggling emotionally']];
      case 'anxiety': return [['none','😌','Calm','Not feeling anxious'],['mild','😟','Some worry','A bit on edge'],['significant','😰','Very anxious','Hard to manage']];
      case 'sleep': return [['none','😴','Slept well','Good night rest'],['mild','🌙','Disturbed','Woke up during the night'],['significant','👁️','Barely slept','Very poor sleep']];
      case 'joint_pain': return [['none','✅','No pain','Joints feel fine'],['mild','🦴','Mild ache','Sore but moving okay'],['significant','😔','Strong pain','Affecting movement']];
      case 'breathlessness': return [['none','🫁','Breathing fine','No breathlessness'],['mild','😤','With effort','Short of breath with activity'],['significant','🔴','At rest','Even resting — call team']];
      case 'infection': return [['none','✅','No signs','No redness or swelling'],['mild','👀','Some redness','Mild — watching it'],['significant','🔴','Concerned','Warm or spreading — call team']];
      case 'mouth_sores': return [['none','✅','None','Mouth feels fine'],['mild','👄','Mild sores','Some discomfort, can eat'],['significant','😔','Painful','Hard to eat or speak']];
      case 'appetite': return [['none','🍽️','Good appetite','Eating normally'],['mild','😟','Reduced','Eating less than usual'],['significant','🚫','Cannot eat','Very little or nothing today']];
      case 'hot_flashes': return [['none','✅','None','No hot flashes today'],['mild','🌡️','Mild','A few, not disruptive'],['significant','🔥','Frequent','Frequent and intense']];
      case 'neuropathy': return [['none','✅','None','No tingling or numbness'],['mild','🤲','Mild tingling','Manageable'],['significant','😔','Affecting me','Affecting hands or feet']];
      case 'cognitive_fog': return [['none','🧠','Clear','Thinking clearly'],['mild','☁️','Some fog','Occasional forgetfulness'],['significant','😵','Hard to focus','Struggling to concentrate']];
      case 'fluid_retention': case 'swelling': return [['none','✅','No swelling','Feels normal'],['mild','💧','Mild','Some puffiness'],['significant','😔','Noticeable','Tight shoes or visible swelling']];
      case 'palpitations': return [['none','❤️','Normal','Heart feels fine'],['mild','💓','Occasional','Rare flutter'],['significant','🔴','Concerning','Persistent — call team']];
      case 'night_sweats': return [['none','✅','None','Slept without sweating'],['mild','💧','Mild','Some sweating'],['significant','😔','Severe','Woke up drenched']];
      case 'hair_loss': return [['none','✅','None','No hair loss'],['mild','💇','Some loss','Thinning noticed'],['significant','😔','Significant','Noticeable patches']];
      case 'constipation': return [['none','✅','None','Normal today'],['mild','😟','Mild','Some discomfort'],['significant','😔','Significant','No movement 2+ days']];
      case 'diarrhea': return [['none','✅','None','Normal today'],['mild','😟','Mild','A couple of times'],['significant','😔','Frequent','4+ times — contact team']];
      default: return [['none','✅','None','Not a concern today'],['mild','😐','Mild','Noticeable but manageable'],['significant','😔','Significant','Affecting my day']];
    }
  }

  // ── Bottom row: Skip · Save & exit ───────────────────────────────
  Widget _skipRow({String saveLabel = 'Save & exit'}) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
        onTap: _next,
        child: const Text('Skip this step',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 12,
            color: Color(0xFF7A7A7A),
            decoration: TextDecoration.underline))),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('·', style: TextStyle(color: Color(0xFFCCC9C2)))),
      GestureDetector(
        onTap: _savePartial,
        child: Text(saveLabel,
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 12,
            color: Color(0xFF7A7A7A),
            decoration: TextDecoration.underline))),
    ]);
  }

  // ── Partial save ──────────────────────────────────────────────────
  Future<void> _savePartial() async {
    _session.symptomScores = {
      for (final e in _symptomAnswers.entries)
        e.key: _scores[e.value] ?? 1.0,
    };
    _session.interferenceAnswers = _interferenceAnswers;
    if (_moodSelected) {
      _session.moodEmoji = _mood.emoji;
      _session.moodLabel = _mood.label;
    }
    if (_note.isNotEmpty) _session.checkInNote = _note;
    _session.lastCheckIn = DateTime.now();
    await _session.saveCheckIn();
    if (mounted) context.go('/checkin/success');
  }

  // ── Primary button ────────────────────────────────────────────────
  Widget _primaryBtn(String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity, height: 54,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF6B9E78) : const Color(0xFFC5D3C7),
          borderRadius: BorderRadius.circular(27),
          boxShadow: enabled ? [BoxShadow(
            color: const Color(0xFF6B9E78).withOpacity(0.32),
            blurRadius: 22, offset: const Offset(0, 8))] : []),
        child: Center(child: Text(label,
          style: const TextStyle(fontFamily: 'DM Sans', fontSize: 16,
            fontWeight: FontWeight.w600, color: Colors.white))),
      ),
    );
  }
}