import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

// ─── AI Voice Check-In Screen ─────────────────────────────────────────────────
class VoiceCheckInScreen extends StatefulWidget {
  const VoiceCheckInScreen({super.key});
  @override
  State<VoiceCheckInScreen> createState() => _VoiceCheckInScreenState();
}

class _VoiceCheckInScreenState extends State<VoiceCheckInScreen>
    with TickerProviderStateMixin {

  // ── State ───────────────────────────────────────────────────────
  _VoicePhase _phase = _VoicePhase.idle;
  int _questionIndex = 0;
  final List<_VoiceAnswer> _answers = [];
  String _currentTranscript = '';
  String _aiResponse = '';
  bool _isProcessing = false;
  Timer? _simulationTimer;
  Timer? _pulseTimer;
  double _pulseScale = 1.0;

  late final AnimationController _waveController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim; // used in initState for fade-in timing

  // ── Extracted symptom scores (AI fills these) ───────────────────
  int _mood = 3, _pain = 1, _fatigue = 2, _nausea = 1, _appetite = 3, _sleep = 3;
  bool _meds = true;
  int _water = 4;
  String _extractedNotes = '';

  // ── Conversation questions ───────────────────────────────────────
  final List<_AIQuestion> _questions = const [
    _AIQuestion(
      id: 'mood',
      prompt: 'Hi! Let\'s start with how you\'re feeling overall today. On a scale of 1 to 5, or just tell me in your own words — how is your mood?',
      hint: 'e.g. "I feel okay, about a 3" or "Pretty good today!"',
      icon: Icons.sentiment_satisfied_alt_rounded,
      color: AppColors.primary,
    ),
    _AIQuestion(
      id: 'pain',
      prompt: 'Got it. Are you experiencing any pain today? If so, how would you describe it — mild, moderate, or severe?',
      hint: 'e.g. "Some mild pain, maybe a 2" or "No pain today"',
      icon: Icons.healing_rounded,
      color: Color(0xFFFF6B6B),
    ),
    _AIQuestion(
      id: 'fatigue',
      prompt: 'How is your energy level? Treatment fatigue is very common — how would you rate your fatigue today?',
      hint: 'e.g. "Quite tired, a 4" or "Actually feeling okay today"',
      icon: Icons.battery_2_bar_rounded,
      color: Color(0xFFF59E0B),
    ),
    _AIQuestion(
      id: 'nausea',
      prompt: 'Any nausea or stomach issues? Did you manage to eat today?',
      hint: 'e.g. "A little nausea this morning" or "No nausea, ate well"',
      icon: Icons.sick_rounded,
      color: AppColors.info,
    ),
    _AIQuestion(
      id: 'meds_water',
      prompt: 'Did you take all your medications today? And roughly how many glasses of water have you had?',
      hint: 'e.g. "Yes, took my meds. About 5 glasses of water"',
      icon: Icons.medication_rounded,
      color: AppColors.accent,
    ),
    _AIQuestion(
      id: 'sleep',
      prompt: 'How did you sleep last night? Good sleep is so important during treatment.',
      hint: 'e.g. "Slept pretty well, maybe 7 hours" or "Rough night"',
      icon: Icons.bedtime_rounded,
      color: AppColors.primaryDark,
    ),
    _AIQuestion(
      id: 'anything_else',
      prompt: 'Almost done! Is there anything else you want me to note — a new symptom, something to ask your doctor, or just how you\'re feeling?',
      hint: 'e.g. "I have a doctor visit Thursday, want to ask about the rash"',
      icon: Icons.notes_rounded,
      color: AppColors.primary,
    ),
  ];

  // ── Simulated transcripts (what the "user" says) ─────────────────
  final List<String> _simulatedResponses = const [
    'I\'m feeling pretty good today, maybe a 4 out of 5. A bit tired but positive.',
    'Just some mild pain in my shoulder, maybe a 2. Nothing too bad.',
    'Fatigue is around a 3 today. I managed a short walk this morning.',
    'A little nausea after breakfast but it passed. I ate lunch fine.',
    'Yes took all my medications. Had about 5 glasses of water so far.',
    'Slept okay, woke up once but went back to sleep. About 6 hours.',
    'Feeling a bit anxious about my next scan next week. Want to ask my doctor about the tingling in my fingers.',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fadeController.dispose();
    _simulationTimer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  // ── Start voice session ──────────────────────────────────────────
  void _startListening() {
    setState(() {
      _phase = _VoicePhase.listening;
      _currentTranscript = '';
      _pulseScale = 1.0;
    });
    _startPulse();
    // Simulate speech-to-text: typewriter effect
    final response = _simulatedResponses[_questionIndex];
    int charIdx = 0;
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 45), (t) {
      if (!mounted) { t.cancel(); return; }
      if (charIdx < response.length) {
        setState(() => _currentTranscript = response.substring(0, ++charIdx));
      } else {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 600), _processAnswer);
      }
    });
  }

  void _startPulse() {
    _pulseTimer?.cancel();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted && _phase == _VoicePhase.listening) {
        setState(() => _pulseScale = _pulseScale == 1.0 ? 1.18 : 1.0);
      }
    });
  }

  // ── AI processes the answer ──────────────────────────────────────
  Future<void> _processAnswer() async {
    _pulseTimer?.cancel();
    setState(() { _phase = _VoicePhase.processing; _isProcessing = true; });
    await Future.delayed(const Duration(milliseconds: 1100));

    // Extract scores from simulated transcript
    _extractScoresFromAnswer(_questionIndex, _currentTranscript);

    // Build a contextual AI response
    final aiReply = _buildAIReply(_questionIndex, _currentTranscript);
    _answers.add(_VoiceAnswer(
      questionId: _questions[_questionIndex].id,
      transcript: _currentTranscript,
      aiReply: aiReply,
    ));

    setState(() {
      _aiResponse = aiReply;
      _isProcessing = false;
      _phase = _VoicePhase.aiReplying;
    });

    // Auto-advance after showing AI reply
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
        _phase = _VoicePhase.question;
        _currentTranscript = '';
        _aiResponse = '';
      });
    } else {
      _showSummary();
    }
  }

  // ── Extract symptom scores from answer text ──────────────────────
  void _extractScoresFromAnswer(int idx, String text) {
    final t = text.toLowerCase();
    switch (_questions[idx].id) {
      case 'mood':
        if (t.contains('4') || t.contains('great') || t.contains('good')) _mood = 4;
        else if (t.contains('5') || t.contains('amazing') || t.contains('excellent')) _mood = 5;
        else if (t.contains('2') || t.contains('bad') || t.contains('rough')) _mood = 2;
        else if (t.contains('1') || t.contains('terrible')) _mood = 1;
        else _mood = 3;
        break;
      case 'pain':
        if (t.contains('no pain') || t.contains('none')) { _pain = 0; }
        else if (t.contains('mild') || t.contains('2') || t.contains('little')) _pain = 2;
        else if (t.contains('moderate') || t.contains('3')) _pain = 3;
        else if (t.contains('severe') || t.contains('4') || t.contains('bad')) _pain = 4;
        else if (t.contains('5') || t.contains('unbearable')) _pain = 5;
        else _pain = 1;
        break;
      case 'fatigue':
        if (t.contains('3') || t.contains('okay') || t.contains('moderate')) _fatigue = 3;
        else if (t.contains('4') || t.contains('quite tired') || t.contains('very tired')) _fatigue = 4;
        else if (t.contains('5') || t.contains('exhausted')) _fatigue = 5;
        else if (t.contains('1') || t.contains('fine') || t.contains('great energy')) _fatigue = 1;
        else _fatigue = 2;
        break;
      case 'nausea':
        if (t.contains('no nausea') || t.contains('none')) _nausea = 0;
        else if (t.contains('little') || t.contains('mild') || t.contains('bit')) _nausea = 2;
        else if (t.contains('moderate') || t.contains('3')) _nausea = 3;
        else if (t.contains('severe') || t.contains('vomit')) _nausea = 4;
        else _nausea = 1;
        if (t.contains('ate well') || t.contains('ate fine') || t.contains('lunch')) _appetite = 4;
        else if (t.contains('couldn\'t eat') || t.contains('no appetite')) _appetite = 1;
        break;
      case 'meds_water':
        _meds = !(t.contains('no') && t.contains('med'));
        final waterMatch = RegExp(r'(\d+)\s*(glass|cup)').firstMatch(t);
        if (waterMatch != null) {
          _water = int.tryParse(waterMatch.group(1) ?? '4') ?? 4;
        } else if (t.contains('5')) _water = 5;
        else if (t.contains('6')) _water = 6;
        else if (t.contains('8')) _water = 8;
        break;
      case 'sleep':
        if (t.contains('7') || t.contains('well') || t.contains('good')) _sleep = 4;
        else if (t.contains('8') || t.contains('great') || t.contains('long')) _sleep = 5;
        else if (t.contains('rough') || t.contains('bad') || t.contains('poor')) _sleep = 2;
        else if (t.contains('6')) _sleep = 3;
        else _sleep = 3;
        break;
      case 'anything_else':
        _extractedNotes = _currentTranscript;
        break;
    }
  }

  // ── Build contextual AI reply ────────────────────────────────────
  String _buildAIReply(int idx, String text) {
    final t = text.toLowerCase();
    switch (_questions[idx].id) {
      case 'mood':
        if (t.contains('4') || t.contains('good') || t.contains('positive')) {
          return 'That\'s wonderful to hear! A positive mood is genuinely powerful during treatment. Let\'s keep that going 💜';
        }
        return 'Thank you for sharing. Every day is different — you\'re doing great by checking in.';
      case 'pain':
        if (t.contains('no pain') || t.contains('nothing')) {
          return 'Great news — no pain today! That\'s something to celebrate. Let me know if that changes.';
        }
        if (t.contains('mild') || t.contains('2')) {
          return 'Mild pain is common and manageable. If it increases, definitely flag it for your care team.';
        }
        return 'I\'ve noted your pain level. If pain reaches a 4 or 5, please contact your care team.';
      case 'fatigue':
        if (t.contains('walk') || t.contains('exercise')) {
          return 'Amazing — a morning walk is exactly right. Exercise during chemo is one of the best things you can do for fatigue. Keep it up!';
        }
        return 'Fatigue is one of the most common treatment side effects. Rest when you need to, but gentle movement helps too.';
      case 'nausea':
        if (t.contains('passed') || t.contains('fine') || t.contains('no nausea')) {
          return 'Good to hear it passed! Taking anti-nausea meds before meals (not after) can help prevent it next time.';
        }
        return 'I\'ve noted the nausea. Make sure to take your anti-nausea medication as prescribed and stay hydrated.';
      case 'meds_water':
        if (t.contains('yes') || t.contains('took')) {
          return 'Perfect — medication consistency is so important for treatment effectiveness. Keep it up! 💊';
        }
        return 'Don\'t worry — I\'ve made a note. Try to set a reminder so you don\'t miss future doses.';
      case 'sleep':
        if (t.contains('well') || t.contains('7') || t.contains('8')) {
          return 'Good sleep! That helps your body recover and repair. Keep protecting your sleep routine.';
        }
        return 'Sleep disruption is common during treatment. Mention it to your doctor — there are options that can help.';
      case 'anything_else':
        if (t.contains('scan') || t.contains('doctor') || t.contains('ask')) {
          return 'I\'ve noted that for your upcoming appointment. Scanxiety is very real — it\'s okay to feel anxious. Your care team can help prepare you.';
        }
        return 'All noted! Your check-in is complete. I\'ll summarize everything so you can review or share with your care team.';
      default:
        return 'Understood, thank you for sharing that.';
    }
  }

  // ── Show summary after all questions ────────────────────────────
  void _showSummary() {
    setState(() => _phase = _VoicePhase.summary);
  }

  // ── Submit to provider ───────────────────────────────────────────
  Future<void> _submitCheckIn(BuildContext context) async {
    final provider = context.read<AppProvider>();
    final symptoms = <String>[];
    if (_pain >= 3) symptoms.add('Moderate pain');
    if (_fatigue >= 3) symptoms.add('Fatigue');
    if (_nausea >= 2) symptoms.add('Nausea');
    if (_sleep <= 2) symptoms.add('Poor sleep');

    final checkIn = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      moodScore: _mood.clamp(1, 5),
      painScore: _pain.clamp(1, 5),
      fatigueScore: _fatigue.clamp(1, 5),
      nauseaScore: _nausea.clamp(1, 5),
      appetiteScore: _appetite.clamp(1, 5),
      sleepScore: _sleep.clamp(1, 5),
      medicationsTaken: _meds,
      waterGlasses: _water,
      notes: _extractedNotes.isNotEmpty ? _extractedNotes : 'Voice check-in completed via AI',
      activitiesAble: true,
      symptoms: symptoms,
    );

    await provider.saveCheckIn(checkIn);
    if (!mounted) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    nav.pop();
    messenger.showSnackBar(const SnackBar(
      content: Text('AI check-in saved! Great job taking care of yourself 💜'),
      backgroundColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0533),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _phase == _VoicePhase.summary
              ? _SummaryView(
                  answers: _answers,
                  mood: _mood, pain: _pain, fatigue: _fatigue,
                  nausea: _nausea, appetite: _appetite, sleep: _sleep,
                  meds: _meds, water: _water, notes: _extractedNotes,
                  onSubmit: () => _submitCheckIn(context),
                  onDiscard: () => Navigator.pop(context),
                )
              : _ConversationView(
                  phase: _phase,
                  questionIndex: _questionIndex,
                  questions: _questions,
                  transcript: _currentTranscript,
                  aiResponse: _aiResponse,
                  isProcessing: _isProcessing,
                  pulseScale: _pulseScale,
                  waveController: _waveController,
                  answers: _answers,
                  onStart: _startListening,
                  onClose: () => Navigator.pop(context),
                ),
        ),
      ),
    );
  }
}

// ─── Conversation View ────────────────────────────────────────────────────────
class _ConversationView extends StatelessWidget {
  final _VoicePhase phase;
  final int questionIndex;
  final List<_AIQuestion> questions;
  final String transcript;
  final String aiResponse;
  final bool isProcessing;
  final double pulseScale;
  final AnimationController waveController;
  final List<_VoiceAnswer> answers;
  final VoidCallback onStart;
  final VoidCallback onClose;

  const _ConversationView({
    required this.phase, required this.questionIndex, required this.questions,
    required this.transcript, required this.aiResponse, required this.isProcessing,
    required this.pulseScale, required this.waveController, required this.answers,
    required this.onStart, required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final q = questions[questionIndex];
    final progress = (questionIndex + (phase == _VoicePhase.aiReplying ? 1 : 0)) / questions.length;

    return Column(
      children: [
        // ── Top bar ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Voice Check-In',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Question ${questionIndex + 1} of ${questions.length}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: q.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: q.color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: q.color, size: 12),
                    const SizedBox(width: 4),
                    Text('AI', style: TextStyle(color: q.color, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Progress bar ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(q.color),
              minHeight: 3,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Conversation history ──────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // Past Q&A
              ...answers.map((a) {
                final qi = questions.indexWhere((q) => q.id == a.questionId);
                if (qi < 0) return const SizedBox.shrink();
                return Column(
                  children: [
                    _AiBubble(text: questions[qi].prompt, color: questions[qi].color),
                    const SizedBox(height: 8),
                    _UserBubble(text: a.transcript),
                    const SizedBox(height: 8),
                    _AiBubble(text: a.aiReply, color: questions[qi].color, isReply: true),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              // Current question
              if (phase != _VoicePhase.idle)
                _AiBubble(text: q.prompt, color: q.color),

              const SizedBox(height: 12),

              // Listening / transcript
              if (phase == _VoicePhase.listening && transcript.isNotEmpty)
                _UserBubble(text: transcript, isLive: true),

              // Processing
              if (isProcessing) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: q.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: q.color),
                          ),
                          const SizedBox(width: 8),
                          Text('AI is analyzing...', style: TextStyle(color: q.color, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // AI reply
              if (phase == _VoicePhase.aiReplying && aiResponse.isNotEmpty) ...[
                const SizedBox(height: 8),
                _AiBubble(text: aiResponse, color: q.color, isReply: true),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),

        // ── Mic button area ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A0533).withValues(alpha: 0),
                const Color(0xFF1A0533),
              ],
            ),
          ),
          child: Column(
            children: [
              // Hint text
              if (phase == _VoicePhase.question || phase == _VoicePhase.idle)
                Text(
                  q.hint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                ),
              if (phase == _VoicePhase.listening)
                Text(
                  'Listening... speak naturally',
                  style: TextStyle(fontSize: 13, color: q.color, fontWeight: FontWeight.w500),
                ),
              if (phase == _VoicePhase.aiReplying)
                Text(
                  'Next question coming up...',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                ),

              const SizedBox(height: 16),

              // Mic button
              if (phase == _VoicePhase.question || phase == _VoicePhase.idle)
                GestureDetector(
                  onTap: onStart,
                  child: _MicButton(color: q.color, isActive: false),
                )
              else if (phase == _VoicePhase.listening)
                AnimatedScale(
                  scale: pulseScale,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: _MicButton(color: q.color, isActive: true, waveController: waveController),
                )
              else
                _MicButton(color: q.color, isActive: false, disabled: true),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Mic Button ───────────────────────────────────────────────────────────────
class _MicButton extends StatelessWidget {
  final Color color;
  final bool isActive;
  final bool disabled;
  final AnimationController? waveController;

  const _MicButton({required this.color, required this.isActive, this.disabled = false, this.waveController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isActive && waveController != null) ...[
          AnimatedBuilder(
            animation: waveController!,
            builder: (_, __) => Container(
              width: 90 + sin(waveController!.value * 2 * pi) * 10,
              height: 90 + sin(waveController!.value * 2 * pi) * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: waveController!,
            builder: (_, __) => Container(
              width: 110 + sin(waveController!.value * 2 * pi + 1) * 12,
              height: 110 + sin(waveController!.value * 2 * pi + 1) * 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
              ),
            ),
          ),
        ],
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: disabled
                  ? [Colors.grey.withValues(alpha: 0.3), Colors.grey.withValues(alpha: 0.2)]
                  : [color, color.withValues(alpha: 0.75)],
            ),
            shape: BoxShape.circle,
            boxShadow: disabled ? [] : [
              BoxShadow(
                color: color.withValues(alpha: isActive ? 0.6 : 0.35),
                blurRadius: isActive ? 24 : 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            isActive ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: disabled ? Colors.grey : Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}

// ─── Chat Bubbles ─────────────────────────────────────────────────────────────
class _AiBubble extends StatelessWidget {
  final String text;
  final Color color;
  final bool isReply;
  const _AiBubble({required this.text, required this.color, this.isReply = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
            shape: BoxShape.circle,
          ),
          child: Icon(isReply ? Icons.auto_awesome_rounded : Icons.smart_toy_rounded,
              color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Text(text, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.4)),
          ),
        ),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final bool isLive;
  const _UserBubble({required this.text, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isLive ? 0.08 : 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              border: isLive ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(text, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9), height: 1.4)),
                ),
                if (isLive) ...[
                  const SizedBox(width: 6),
                  _BlinkingCursor(),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white70, size: 14),
        ),
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}
class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Opacity(opacity: _c.value, child: Container(width: 2, height: 14, color: Colors.white70)),
  );
}

// ─── Summary View ─────────────────────────────────────────────────────────────
class _SummaryView extends StatelessWidget {
  final List<_VoiceAnswer> answers;
  final int mood, pain, fatigue, nausea, appetite, sleep, water;
  final bool meds;
  final String notes;
  final VoidCallback onSubmit;
  final VoidCallback onDiscard;

  const _SummaryView({
    required this.answers, required this.mood, required this.pain,
    required this.fatigue, required this.nausea, required this.appetite,
    required this.sleep, required this.meds, required this.water,
    required this.notes, required this.onSubmit, required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricRow('Mood', mood, Icons.sentiment_satisfied_alt_rounded, AppColors.primary),
      _MetricRow('Pain', pain, Icons.healing_rounded, const Color(0xFFFF6B6B)),
      _MetricRow('Fatigue', fatigue, Icons.battery_2_bar_rounded, const Color(0xFFF59E0B)),
      _MetricRow('Nausea', nausea, Icons.sick_rounded, AppColors.info),
      _MetricRow('Appetite', appetite, Icons.restaurant_rounded, AppColors.accent),
      _MetricRow('Sleep', sleep, Icons.bedtime_rounded, AppColors.primaryDark),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('AI Check-In Complete',
                    style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              GestureDetector(
                onTap: onDiscard,
                child: Text('Discard', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: metrics.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: m.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(m.icon, color: m.color, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Text(m.label,
                              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Row(
                            children: List.generate(5, (i) => Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: Container(
                                width: 20, height: 8,
                                decoration: BoxDecoration(
                                  color: i < m.score
                                      ? m.color
                                      : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            )),
                          ),
                          const SizedBox(width: 8),
                          Text('${m.score}/5', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: m.color)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // Meds & water row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (meds ? AppColors.accent : AppColors.danger).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.medication_rounded, color: meds ? AppColors.accent : AppColors.danger, size: 20),
                            const SizedBox(width: 8),
                            Text('Meds: ${meds ? "✓ Taken" : "✗ Missed"}',
                                style: TextStyle(color: meds ? AppColors.accent : AppColors.danger,
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.water_drop_rounded, color: AppColors.info, size: 20),
                            const SizedBox(width: 8),
                            Text('$water glasses',
                                style: const TextStyle(color: AppColors.info, fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // AI notes
                if (notes.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 14),
                            SizedBox(width: 6),
                            Text('AI Notes', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(notes, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7), height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // AI insight
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.info.withValues(alpha: 0.15), AppColors.primary.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.insights_rounded, color: AppColors.info, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _buildInsightText(),
                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // ── Bottom buttons ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              GestureDetector(
                onTap: onSubmit,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.info],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Save Check-In', style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onDiscard,
                child: Text('Discard & Exit', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildInsightText() {
    final insights = <String>[];
    if (mood >= 4) insights.add('Your mood is positive today — that resilience matters 💜');
    if (pain >= 3) insights.add('Pain level noted — flag this for your care team at next visit.');
    if (fatigue >= 4) insights.add('High fatigue detected. Consider resting more and gentle walks only.');
    if (!meds) insights.add('Medication missed today — try to take it as soon as possible.');
    if (water < 5) insights.add('Below hydration target — try to drink more water today.');
    if (sleep <= 2) insights.add('Poor sleep noted — mention this to your doctor.');
    if (insights.isEmpty) return 'Everything looks stable today. Keep up the great work tracking your health!';
    return insights.join(' ');
  }
}

class _MetricRow {
  final String label;
  final int score;
  final IconData icon;
  final Color color;
  const _MetricRow(this.label, this.score, this.icon, this.color);
}

// ─── Models ───────────────────────────────────────────────────────────────────
enum _VoicePhase { idle, question, listening, processing, aiReplying, summary }

class _AIQuestion {
  final String id, prompt, hint;
  final IconData icon;
  final Color color;
  const _AIQuestion({required this.id, required this.prompt, required this.hint, required this.icon, required this.color});
}

class _VoiceAnswer {
  final String questionId, transcript, aiReply;
  const _VoiceAnswer({required this.questionId, required this.transcript, required this.aiReply});
}
