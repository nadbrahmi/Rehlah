import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import 'voice_checkin_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DAILY CHECK-IN SCREEN — Step-by-Step Full-Screen Flow
// Step 1: Mood selector (5 large emojis, 56px)
// Step 2: Symptom sliders (one at a time)
// Step 3: Medication intake (Yes / Partially / Skip)
// Step 4: Water intake selector
// Step 5: Optional voice note + Submit
// After completion: teal celebration card (#0D9488) auto-dismiss 3 s or tap
// ═══════════════════════════════════════════════════════════════════════════════

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  // Flow state
  bool _showInterstitial = true;
  int _currentStep = 0; // 0–4
  bool _isComplete = false;
  bool _isSubmitting = false;

  // Step 1: Mood
  int _moodScore = 0; // 0 = unset

  // Step 2: Symptoms (shown one at a time)
  int _symptomIndex = 0;
  int _painScore = 1;
  int _fatigueScore = 1;
  int _nauseaScore = 1;
  int _appetiteScore = 3;
  int _sleepScore = 3;

  // Step 3: Medication
  String _medStatus = ''; // 'yes' | 'partially' | 'skip'

  // Step 4: Water
  int _waterGlasses = 4;

  // Step 5: Notes
  final _notesCtrl = TextEditingController();

  static const _moodEmojis  = ['😫', '😔', '😐', '🙂', '😊'];
  static const _moodLabels  = ['Rough', 'Low', 'Okay', 'Good', 'Great'];
  static const _moodColors  = [
    Color(0xFFDC2626),
    Color(0xFFD97706),
    Color(0xFF2563EB),
    Color(0xFF22C55E),
    Color(0xFF0D9488),
  ];

  static const _symptoms = [
    _SymptomDef('Pain',          Icons.report_problem_rounded, Color(0xFFDC2626)),
    _SymptomDef('Fatigue',       Icons.battery_2_bar_rounded,  Color(0xFFD97706)),
    _SymptomDef('Nausea',        Icons.sick_rounded,           Color(0xFF2563EB)),
    _SymptomDef('Appetite',      Icons.restaurant_rounded,     Color(0xFF22C55E)),
    _SymptomDef('Sleep Quality', Icons.bedtime_rounded,        Color(0xFF7C3AED)),
  ];

  int get _symptomValue {
    switch (_symptomIndex) {
      case 0: return _painScore;
      case 1: return _fatigueScore;
      case 2: return _nauseaScore;
      case 3: return _appetiteScore;
      case 4: return _sleepScore;
      default: return 1;
    }
  }

  void _setSymptomValue(int v) {
    setState(() {
      switch (_symptomIndex) {
        case 0: _painScore = v; break;
        case 1: _fatigueScore = v; break;
        case 2: _nauseaScore = v; break;
        case 3: _appetiteScore = v; break;
        case 4: _sleepScore = v; break;
      }
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    switch (_currentStep) {
      case 0: return _moodScore > 0;
      case 1: return true; // symptoms always have defaults
      case 2: return _medStatus.isNotEmpty;
      case 3: return true;
      case 4: return true;
      default: return false;
    }
  }

  void _nextStep() {
    if (_currentStep == 1 && _symptomIndex < _symptoms.length - 1) {
      // Advance through symptoms
      setState(() => _symptomIndex++);
      return;
    }
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
        if (_currentStep == 1) _symptomIndex = 0;
      });
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep == 1 && _symptomIndex > 0) {
      setState(() => _symptomIndex--);
      return;
    }
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        if (_currentStep == 1) _symptomIndex = _symptoms.length - 1;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final checkIn = CheckIn(
      id: 'ci_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      moodScore: _moodScore,
      painScore: _painScore,
      fatigueScore: _fatigueScore,
      nauseaScore: _nauseaScore,
      appetiteScore: _appetiteScore,
      sleepScore: _sleepScore,
      medicationsTaken: _medStatus == 'yes',
      waterGlasses: _waterGlasses,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      activitiesAble: true,
      symptoms: _buildSymptoms(),
    );
    await context.read<AppProvider>().saveCheckIn(checkIn);
    if (mounted) {
      setState(() { _isSubmitting = false; _isComplete = true; });
    }
  }

  List<String> _buildSymptoms() {
    final s = <String>[];
    if (_painScore >= 3)      s.add('Pain');
    if (_fatigueScore >= 3)   s.add('Fatigue');
    if (_nauseaScore >= 3)    s.add('Nausea');
    if (_appetiteScore <= 2)  s.add('Poor appetite');
    return s;
  }

  // Progress: symptom sub-steps count as part of step 1
  double get _progressValue {
    if (_currentStep == 0) return 0.15;
    if (_currentStep == 1) return 0.15 + 0.35 * (_symptomIndex + 1) / _symptoms.length;
    return 0.15 + 0.35 + (_currentStep - 1) * 0.17;
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return _CelebrationCard(
        moodScore: _moodScore,
        onDismiss: () {
          context.read<AppProvider>().setNavIndex(0);
          setState(() { _isComplete = false; _currentStep = 0; _showInterstitial = true; });
        },
      );
    }
    if (_showInterstitial) {
      return _Interstitial(onContinue: () => setState(() => _showInterstitial = false));
    }
    return _buildStep();
  }

  Widget _buildStep() {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: back + progress + skip ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _prevStep,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF7C3AED), size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressValue,
                        backgroundColor: const Color(0xFFEDE9FE),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VoiceCheckInScreen())),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.mic_rounded,
                          color: Color(0xFF7C3AED), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Step content (fills remaining space) ─────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _stepContent(),
              ),
            ),

            // ── Continue button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  AnimatedOpacity(
                    opacity: _canAdvance ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canAdvance ? _nextStep : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text(
                                _currentStep == 4 ? 'Save Check-In →' : 'Continue →',
                                style: GoogleFonts.inter(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  if (_currentStep < 4) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => _nextStep(),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xFF78716C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepContent() {
    switch (_currentStep) {
      case 0: return _moodStep();
      case 1: return _symptomStep();
      case 2: return _medStep();
      case 3: return _waterStep();
      case 4: return _notesStep();
      default: return const SizedBox.shrink();
    }
  }

  // ── Step 1: Mood ─────────────────────────────────────────────────────────────
  Widget _moodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you\nfeeling today?',
          style: GoogleFonts.inter(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1917), height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'There are no wrong answers.',
          style: GoogleFonts.inter(
            fontSize: 18, color: const Color(0xFF78716C), height: 1.7),
        ),
        const SizedBox(height: 40),
        // 5 large emoji selectors
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final isSelected = _moodScore == i + 1;
            final col = _moodColors[i];
            return GestureDetector(
              onTap: () => setState(() => _moodScore = i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56, height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? col.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: col, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _moodEmojis[i],
                      style: TextStyle(fontSize: isSelected ? 40 : 34),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _moodLabels[i],
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? col : const Color(0xFF78716C),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 40),
        if (_moodScore > 0) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _moodColors[_moodScore - 1].withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _moodColors[_moodScore - 1].withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text(
                  _moodEmojis[_moodScore - 1],
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _moodScore >= 4
                        ? 'That\'s really good to hear. 💜'
                        : _moodScore == 3
                            ? 'Thank you for being honest.'
                            : 'That takes courage to share. We\'re here. 💜',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF1C1917),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Step 2: Symptoms (one at a time) ─────────────────────────────────────────
  Widget _symptomStep() {
    final sym = _symptoms[_symptomIndex];
    final totalSubs = _symptoms.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-progress dots
        Row(
          children: List.generate(totalSubs, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 6),
              width: i == _symptomIndex ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i <= _symptomIndex
                    ? sym.color
                    : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: sym.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(sym.icon, color: sym.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                sym.name,
                style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1917), height: 1.3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _symptomSubtext(sym.name),
          style: GoogleFonts.inter(
            fontSize: 18, color: const Color(0xFF78716C), height: 1.7),
        ),
        const SizedBox(height: 40),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: sym.color,
            inactiveTrackColor: sym.color.withValues(alpha: 0.15),
            thumbColor: sym.color,
            overlayColor: sym.color.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: _symptomValue.toDouble(),
            min: 1, max: 5, divisions: 4,
            onChanged: (v) => _setSymptomValue(v.round()),
          ),
        ),

        // Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _symptomLabels(sym.name).map((l) =>
              Text(l, style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF78716C)))).toList(),
          ),
        ),
        const SizedBox(height: 32),

        // Current value pill
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: sym.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: sym.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              _symptomValueLabel(sym.name, _symptomValue),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: sym.color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _symptomSubtext(String name) {
    switch (name) {
      case 'Pain':          return 'Rate your physical pain level today.';
      case 'Fatigue':       return 'How tired are you feeling?';
      case 'Nausea':        return 'Any stomach discomfort or nausea?';
      case 'Appetite':      return 'How is your appetite today?';
      case 'Sleep Quality': return 'How did you sleep last night?';
      default:              return 'Rate your level.';
    }
  }

  List<String> _symptomLabels(String name) {
    switch (name) {
      case 'Appetite':      return ['Poor', 'Low', 'Fair', 'Good', 'Great'];
      case 'Sleep Quality': return ['Poor', 'Light', 'Fair', 'Good', 'Great'];
      default:              return ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'];
    }
  }

  String _symptomValueLabel(String name, int v) {
    return _symptomLabels(name)[v - 1];
  }

  // ── Step 3: Medication ────────────────────────────────────────────────────────
  Widget _medStep() {
    return Consumer<AppProvider>(builder: (context, app, _) {
      final meds = app.medications.where((m) => m.isActive).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Did you take\nyour medications?',
            style: GoogleFonts.inter(
              fontSize: 26, fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1917), height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            meds.isEmpty
                ? 'Be honest — it helps your care team.'
                : 'You have ${meds.length} medication${meds.length == 1 ? '' : 's'} tracked.',
            style: GoogleFonts.inter(
                fontSize: 18, color: const Color(0xFF78716C), height: 1.7),
          ),
          const SizedBox(height: 40),

          if (meds.isNotEmpty) ...[
            // Show med list
            ...meds.map((med) {
              final taken = app.isMedTakenToday(med.id);
              return GestureDetector(
                onTap: () {
                  app.logMedTaken(med.id, taken: !taken);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: taken
                        ? const Color(0xFFEDE9FE)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: taken
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFFE5E7EB),
                      width: taken ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: taken
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        taken ? Icons.check_rounded : Icons.medication_outlined,
                        color: taken ? Colors.white : const Color(0xFF7C3AED),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(med.name,
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w600,
                                color: const Color(0xFF1C1917))),
                        Text('${med.dosage} · ${med.frequency}',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: const Color(0xFF78716C))),
                      ]),
                    ),
                    Text(
                      taken ? 'Taken ✓' : 'Tap to mark',
                      style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: taken
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF78716C)),
                    ),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Yes / Partially / Skip buttons
          _MedOption(
            label: 'Yes, all taken',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF0D9488),
            selected: _medStatus == 'yes',
            onTap: () => setState(() => _medStatus = 'yes'),
          ),
          const SizedBox(height: 10),
          _MedOption(
            label: 'Partially taken',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFFD97706),
            selected: _medStatus == 'partially',
            onTap: () => setState(() => _medStatus = 'partially'),
          ),
          const SizedBox(height: 10),
          _MedOption(
            label: "Missed today",
            icon: Icons.remove_circle_outline_rounded,
            color: const Color(0xFF78716C),
            selected: _medStatus == 'skip',
            onTap: () => setState(() => _medStatus = 'skip'),
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  // ── Step 4: Water intake ──────────────────────────────────────────────────────
  Widget _waterStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Water intake\ntoday?',
          style: GoogleFonts.inter(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1917), height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Target: 8 glasses per day. Small sips count.',
          style: GoogleFonts.inter(
              fontSize: 18, color: const Color(0xFF78716C), height: 1.7),
        ),
        const SizedBox(height: 48),

        // 8-glass visual grid
        Center(
          child: Wrap(
            spacing: 10, runSpacing: 10,
            children: List.generate(8, (i) {
              final filled = i < _waterGlasses;
              return GestureDetector(
                onTap: () => setState(() => _waterGlasses = i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52, height: 64,
                  decoration: BoxDecoration(
                    color: filled
                        ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: filled
                          ? const Color(0xFF2563EB).withValues(alpha: 0.4)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        color: filled
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFD1D5DB),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${i + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: filled
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 32),

        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '$_waterGlasses of 8 glasses',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // +/- buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _WaterAdjBtn(
              icon: Icons.remove_rounded,
              onTap: () {
                if (_waterGlasses > 0) setState(() => _waterGlasses--);
              },
            ),
            const SizedBox(width: 32),
            _WaterAdjBtn(
              icon: Icons.add_rounded,
              onTap: () {
                if (_waterGlasses < 12) setState(() => _waterGlasses++);
              },
              isPrimary: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Step 5: Optional notes + submit ──────────────────────────────────────────
  Widget _notesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anything else\nyou want to note?',
          style: GoogleFonts.inter(
            fontSize: 26, fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1917), height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Optional. A single word is enough.',
          style: GoogleFonts.inter(
              fontSize: 18, color: const Color(0xFF78716C), height: 1.7),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _notesCtrl,
          maxLines: 4,
          style: GoogleFonts.inter(
              fontSize: 16, color: const Color(0xFF1C1917), height: 1.7),
          decoration: InputDecoration(
            hintText: 'How are you really feeling? A symptom, a worry, or just "okay"…',
            hintStyle: GoogleFonts.inter(
                fontSize: 15, color: const Color(0xFFD6D3D1), height: 1.7),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEDD8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEDD8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Voice option
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const VoiceCheckInScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.mic_rounded, color: Color(0xFF7C3AED), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Or use voice check-in instead',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF7C3AED), size: 14),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Symptom definition ───────────────────────────────────────────────────────
class _SymptomDef {
  final String name;
  final IconData icon;
  final Color color;
  const _SymptomDef(this.name, this.icon, this.color);
}

// ─── Medication option button ─────────────────────────────────────────────────
class _MedOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _MedOption({
    required this.label, required this.icon,
    required this.color, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : const Color(0xFF78716C), size: 24),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : const Color(0xFF1C1917),
              ),
            ),
            const Spacer(),
            if (selected)
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 13),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Water adjust button ──────────────────────────────────────────────────────
class _WaterAdjBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  const _WaterAdjBtn({required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: isPrimary
              ? const Color(0xFF2563EB).withValues(alpha: 0.10)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          icon,
          color: isPrimary ? const Color(0xFF2563EB) : const Color(0xFF78716C),
          size: 24,
        ),
      ),
    );
  }
}

// ─── Pre-check-in interstitial ────────────────────────────────────────────────
class _Interstitial extends StatefulWidget {
  final VoidCallback onContinue;
  const _Interstitial({required this.onContinue});

  @override
  State<_Interstitial> createState() => _InterstitialState();
}

class _InterstitialState extends State<_Interstitial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _timer = Timer(const Duration(milliseconds: 2500), widget.onContinue);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: widget.onContinue,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: Color(0xFF7C3AED), size: 42),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Just a few questions\nabout today.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 26, fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1917), height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'There are no wrong answers.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18, color: const Color(0xFF78716C), height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Takes about 2 minutes.',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: const Color(0xFFA8A29E)),
                    ),
                    const SizedBox(height: 56),
                    Text(
                      'Tap anywhere to begin',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFFD6D3D1)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Teal celebration card (auto-dismiss 3s or tap) ──────────────────────────
class _CelebrationCard extends StatefulWidget {
  final int moodScore;
  final VoidCallback onDismiss;
  const _CelebrationCard({required this.moodScore, required this.onDismiss});

  @override
  State<_CelebrationCard> createState() => _CelebrationCardState();
}

class _CelebrationCardState extends State<_CelebrationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _timer = Timer(const Duration(seconds: 3), widget.onDismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodEmojis = ['', '😫', '😔', '😐', '🙂', '😊'];
    final emoji = moodEmojis[widget.moodScore.clamp(1, 5)];
    final name = context.read<AppProvider>().journey?.name.split(' ').first ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D9488),
      body: SafeArea(
        child: GestureDetector(
          onTap: widget.onDismiss,
          behavior: HitTestBehavior.opaque,
          child: FadeTransition(
            opacity: _fade,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 24),
                      Text(
                        name.isNotEmpty
                            ? 'Check-in saved,\n$name 💜'
                            : 'Check-in saved 💜',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.w700,
                          color: Colors.white, height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.moodScore >= 4
                            ? 'Great mood today. Keep going.'
                            : widget.moodScore <= 2
                                ? 'Tracking it on hard days helps\nyour team support you better.'
                                : 'Consistent tracking makes a\nreal difference.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Tap to continue',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
