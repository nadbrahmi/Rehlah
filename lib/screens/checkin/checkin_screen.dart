import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import 'voice_checkin_screen.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  bool _isQuickMode = true;

  // Physical scores
  int _moodScore = 3;
  int _painScore = 1;
  int _fatigueScore = 2;
  int _nauseaScore = 1;
  int _appetiteScore = 3;
  int _sleepScore = 3;
  bool _medicationsTaken = false;
  int _waterGlasses = 4;
  bool _activitiesAble = true;

  // Emotional scores
  int _emotionalScore = 3;
  String? _topConcern;

  final _notesCtrl = TextEditingController();
  final _foodCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _isComplete = false;

  static const _concerns = ['Pain', 'Fatigue', 'Nausea', 'Anxiety', 'Sleep', 'Appetite', 'Isolation', 'Fear of recurrence'];
  static const _emotionEmojis = ['', '😰', '😟', '😐', '🙂', '💪'];
  static const _emotionLabels = ['', 'Overwhelmed', 'Anxious', 'Okay', 'Hopeful', 'Strong'];
  static const _emotionColors = [
    Colors.transparent, AppColors.danger, AppColors.warning,
    AppColors.info, AppColors.accent, AppColors.primary,
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    _foodCtrl.dispose();
    super.dispose();
  }

  int get _completedSections {
    int n = 0;
    if (_moodScore > 0) n++;
    if (_painScore > 0 || _fatigueScore > 0 || _nauseaScore > 0) n++;
    if (_medicationsTaken || _waterGlasses > 0) n++;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    if (_isComplete) {
      return _CompletionView(
        moodScore: _moodScore,
        emotionalScore: _emotionalScore,
        onGoHome: () {
          context.read<AppProvider>().setNavIndex(0);
          setState(() => _isComplete = false);
        },
      );
    }
    return _isQuickMode ? _buildQuick() : _buildFull();
  }

  // ─── QUICK MODE ───────────────────────────────────────────────────────────────
  Widget _buildQuick() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader(quick: true)),

          // Step 1 – Mood
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _StepLabel(step: '1', label: 'How\'s your overall mood?'),
                const SizedBox(height: 14),
                MoodEmojiSelector(
                  selectedMood: _moodScore,
                  onSelect: (v) => setState(() => _moodScore = v),
                ),
              ]),
            ),
          ),

          // Step 2 – Emotional wellbeing
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _StepLabel(step: '2', label: 'Emotionally, I feel…'),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(5, (i) {
                    final idx = i + 1;
                    final sel = _emotionalScore == idx;
                    final col = _emotionColors[idx];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _emotionalScore = idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel ? col : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: sel ? col : AppColors.border, width: sel ? 2 : 1),
                            boxShadow: sel ? [BoxShadow(color: col.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(_emotionEmojis[idx], style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(_emotionLabels[idx],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : AppColors.textMuted)),
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
              ]),
            ),
          ),

          // Step 3 – Medications per-med check-off
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Consumer<AppProvider>(builder: (context, app, _) {
                final meds = app.medications.where((m) => m.isActive).toList();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _StepLabel(step: '3', label: 'Medications taken today?'),
                  const SizedBox(height: 14),
                  if (meds.isEmpty)
                    Row(children: [
                      Expanded(child: _MedTapCard(taken: true, selected: _medicationsTaken, onTap: () => setState(() => _medicationsTaken = true))),
                      const SizedBox(width: 12),
                      Expanded(child: _MedTapCard(taken: false, selected: !_medicationsTaken, onTap: () => setState(() => _medicationsTaken = false))),
                    ])
                  else
                    Column(
                      children: meds.map((med) {
                        final taken = app.isMedTakenToday(med.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              app.logMedTaken(med.id, taken: !taken);
                              // Keep the boolean flag in sync
                              setState(() {
                                _medicationsTaken = meds
                                    .where((m) => app.isMedTakenToday(m.id))
                                    .length == meds.length;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: taken ? AppColors.accentLight : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: taken ? AppColors.accent : AppColors.border,
                                    width: taken ? 1.5 : 1),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: taken ? AppColors.accent : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    taken ? Icons.check_rounded : Icons.medication_outlined,
                                    color: taken ? Colors.white : AppColors.primary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                    Text(med.name,
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                                            color: taken ? AppColors.accentDark : AppColors.textPrimary)),
                                    Text('${med.dosage} · ${med.frequency}',
                                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ]),
                                ),
                                Text(taken ? 'Taken ✓' : 'Tap to mark',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                        color: taken ? AppColors.accentDark : AppColors.textMuted)),
                              ]),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ]);
              }),
            ),
          ),

          // Top concern
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text('Biggest concern today? (optional)',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _concerns.map((c) {
                    final sel = _topConcern == c;
                    return GestureDetector(
                      onTap: () => setState(() => _topConcern = sel ? null : c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                          boxShadow: sel ? AppShadows.card : [],
                        ),
                        child: Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ),

          // Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(children: [
                PurpleGradientButton(
                  label: 'Save Quick Check-In',
                  icon: Icons.bolt_rounded,
                  onTap: _submitQuick,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => _isQuickMode = false),
                  child: Center(
                    child: Text('Add more detail (full check-in)',
                        style: const TextStyle(fontSize: 13, color: AppColors.primary,
                            fontWeight: FontWeight.w600, decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary)),
                  ),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─── FULL MODE ────────────────────────────────────────────────────────────────
  Widget _buildFull() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(quick: false)),

          // Mood
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Overall Mood', icon: Icons.sentiment_satisfied_alt_rounded),
                const SizedBox(height: 14),
                MoodEmojiSelector(selectedMood: _moodScore, onSelect: (v) => setState(() => _moodScore = v)),
              ]),
            ),
          ),

          // Emotional wellbeing
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Emotional Wellbeing', icon: Icons.favorite_border_rounded),
                const SizedBox(height: 6),
                const Text('Beyond physical symptoms — how are you really feeling?',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 14),
                Row(
                  children: List.generate(5, (i) {
                    final idx = i + 1;
                    final sel = _emotionalScore == idx;
                    final col = _emotionColors[idx];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _emotionalScore = idx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: sel ? col : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: sel ? col : AppColors.border, width: sel ? 2 : 1),
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(_emotionEmojis[idx], style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(_emotionLabels[idx],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : AppColors.textMuted)),
                          ]),
                        ),
                      ),
                    );
                  }),
                ),
                if (_emotionalScore <= 2) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.support_agent_rounded, color: AppColors.danger, size: 18),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('If you\'re struggling emotionally, your care team can help. You\'re not alone. 💜',
                            style: TextStyle(fontSize: 12, color: AppColors.danger, height: 1.4)),
                      ),
                    ]),
                  ),
                ],
              ]),
            ),
          ),

          // Symptoms
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Symptom Levels', icon: Icons.monitor_heart_rounded),
                const SizedBox(height: 14),
                ScoreSlider(label: 'Pain', value: _painScore, onChanged: (v) => setState(() => _painScore = v),
                    activeColor: AppColors.pain, icon: Icons.report_problem_rounded,
                    labels: const ['None', 'Mild', 'Moderate', 'Severe', 'Extreme']),
                const SizedBox(height: 12),
                ScoreSlider(label: 'Fatigue', value: _fatigueScore, onChanged: (v) => setState(() => _fatigueScore = v),
                    activeColor: AppColors.fatigue, icon: Icons.battery_2_bar_rounded,
                    labels: const ['None', 'Mild', 'Moderate', 'High', 'Extreme']),
                const SizedBox(height: 12),
                ScoreSlider(label: 'Nausea', value: _nauseaScore, onChanged: (v) => setState(() => _nauseaScore = v),
                    activeColor: AppColors.nausea, icon: Icons.sick_rounded,
                    labels: const ['None', 'Mild', 'Moderate', 'Strong', 'Severe']),
                const SizedBox(height: 12),
                ScoreSlider(label: 'Appetite', value: _appetiteScore, onChanged: (v) => setState(() => _appetiteScore = v),
                    activeColor: AppColors.appetite, icon: Icons.restaurant_rounded,
                    labels: const ['None', 'Poor', 'Low', 'Moderate', 'Good']),
                const SizedBox(height: 12),
                ScoreSlider(label: 'Sleep Quality', value: _sleepScore, onChanged: (v) => setState(() => _sleepScore = v),
                    activeColor: AppColors.sleep, icon: Icons.bedtime_rounded,
                    labels: const ['Poor', 'Light', 'Fair', 'Good', 'Great']),
              ]),
            ),
          ),

          // Medications & water
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Consumer<AppProvider>(builder: (context, appP, _) {
                final meds = appP.medications.where((m) => m.isActive).toList();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionHeader(title: 'Medications & Hydration', icon: Icons.medication_liquid_rounded),
                  const SizedBox(height: 14),
                  if (meds.isEmpty)
                    RehlaCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Medications Taken', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text("Did you take all today's medications?", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ])),
                        Transform.scale(
                          scale: 0.9,
                          child: Switch(
                            value: _medicationsTaken,
                            onChanged: (v) => setState(() => _medicationsTaken = v),
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: AppColors.divider,
                          ),
                        ),
                      ]),
                    )
                  else
                    RehlaCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(9)),
                            child: const Icon(Icons.medication_rounded, color: AppColors.primary, size: 17),
                          ),
                          const SizedBox(width: 10),
                          Text('Mark medications taken',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ]),
                        const SizedBox(height: 12),
                        ...meds.map((med) {
                          final taken = appP.isMedTakenToday(med.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () {
                                appP.logMedTaken(med.id, taken: !taken);
                                setState(() {
                                  _medicationsTaken = meds
                                      .where((m) => appP.isMedTakenToday(m.id))
                                      .length == meds.length;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: taken ? AppColors.accentLight : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: taken ? AppColors.accent : AppColors.border,
                                      width: taken ? 1.5 : 1),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 24, height: 24,
                                    decoration: BoxDecoration(
                                      color: taken ? AppColors.accent : AppColors.primarySurface,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Icon(taken ? Icons.check_rounded : Icons.circle_outlined,
                                        color: taken ? Colors.white : AppColors.primary, size: 14),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text('${med.name} · ${med.dosage}',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                                            color: taken ? AppColors.accentDark : AppColors.textPrimary)),
                                  ),
                                  Text(taken ? 'Taken ✓' : 'Tap',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                          color: taken ? AppColors.accentDark : AppColors.textMuted)),
                                ]),
                              ),
                            ),
                          );
                        }),
                      ]),
                    ),
                const SizedBox(height: 12),
                RehlaCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.water_drop_rounded, color: AppColors.info, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Water Intake', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('Target: 8 glasses per day', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ])),
                    ]),
                    const SizedBox(height: 14),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _WaterBtn(icon: Icons.remove_rounded, onTap: () { if (_waterGlasses > 0) setState(() => _waterGlasses--); }),
                      const SizedBox(width: 16),
                      Column(children: [
                        Row(children: List.generate(8, (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: i < _waterGlasses ? AppColors.info : AppColors.infoLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.water_drop_rounded, size: 14,
                                color: i < _waterGlasses ? Colors.white : AppColors.info.withValues(alpha: 0.3)),
                          ),
                        ))),
                        const SizedBox(height: 6),
                        Text('$_waterGlasses of 8 glasses',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.info)),
                      ]),
                      const SizedBox(width: 16),
                      _WaterBtn(icon: Icons.add_rounded, onTap: () { if (_waterGlasses < 12) setState(() => _waterGlasses++); }, isAdd: true),
                    ]),
                  ]),
                ),
                ]);
              }),
            ),
          ),

          // Activities
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: RehlaCard(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.directions_walk_rounded, color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Light Activities', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text('Were you able to do light activities today?', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ])),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: _activitiesAble,
                      onChanged: (v) => setState(() => _activitiesAble = v),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.accent,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: AppColors.divider,
                    ),
                  ),
                ]),
              ),
            ),
          ),

          // Notes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Notes', icon: Icons.sticky_note_2_rounded),
                const SizedBox(height: 14),
                TextField(
                  controller: _notesCtrl, maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'How are you really feeling? Any concerns to share with your care team…',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 14, right: 8, top: 12),
                      child: Icon(Icons.note_alt_rounded, color: AppColors.primary, size: 20),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _foodCtrl, maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'What did you eat today? (optional)',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 14, right: 8, top: 12),
                      child: Icon(Icons.restaurant_menu_rounded, color: AppColors.accent, size: 20),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
              ]),
            ),
          ),

          // Submit
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(children: [
                PurpleGradientButton(
                  label: 'Complete Check-In',
                  icon: Icons.check_circle_rounded,
                  onTap: _submitFull,
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => _isQuickMode = true),
                  child: const Center(
                    child: Text('Switch to quick mode',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted, decoration: TextDecoration.underline,
                            decorationColor: AppColors.textMuted)),
                  ),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─── Shared header ────────────────────────────────────────────────────────────
  Widget _buildHeader({required bool quick}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(quick ? Icons.bolt_rounded : Icons.edit_note_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Text(quick ? 'Quick Check-In' : 'Full Check-In',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              // Mode toggle badge
              GestureDetector(
                onTap: () => setState(() => _isQuickMode = !quick),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(quick ? Icons.tune_rounded : Icons.bolt_rounded, color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(quick ? 'Full mode' : 'Quick mode',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            Text(quick ? 'How are you today?' : 'Full daily check-in',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
            const SizedBox(height: 4),
            Text(
              quick ? '3 taps — mood, emotions, meds. That\'s it.' : 'Take your time — this helps your care team.',
              style: const TextStyle(fontSize: 13, color: AppColors.textOnDarkMuted),
            ),
            const SizedBox(height: 14),
            // AI Voice Check-In Banner
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceCheckInScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Try AI Voice Check-In',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          Text('Just talk — AI extracts everything',
                              style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                  ],
                ),
              ),
            ),
            if (!quick) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _completedSections / 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 5,
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  // ─── Submit helpers ───────────────────────────────────────────────────────────
  List<String> _getSymptoms() {
    final s = <String>[];
    if (_painScore >= 3) s.add('Pain');
    if (_fatigueScore >= 3) s.add('Fatigue');
    if (_nauseaScore >= 3) s.add('Nausea');
    if (_appetiteScore <= 2) s.add('Poor appetite');
    if (_emotionalScore <= 2) s.add('Emotional distress');
    if (_topConcern != null && !s.contains(_topConcern)) s.add(_topConcern!);
    return s;
  }

  Future<void> _submitQuick() async {
    setState(() => _isSubmitting = true);
    final checkIn = CheckIn(
      id: 'ci_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      moodScore: _moodScore,
      painScore: _topConcern == 'Pain' ? 3 : 1,
      fatigueScore: _topConcern == 'Fatigue' ? 3 : 2,
      nauseaScore: _topConcern == 'Nausea' ? 3 : 1,
      appetiteScore: _topConcern == 'Appetite' ? 2 : 3,
      sleepScore: _topConcern == 'Sleep' ? 2 : 3,
      medicationsTaken: _medicationsTaken,
      waterGlasses: 4,
      notes: [
        if (_topConcern != null) 'Main concern: $_topConcern',
        if (_emotionalScore <= 2) 'Feeling ${_emotionLabels[_emotionalScore].toLowerCase()} today',
      ].join('. ').nullIfEmpty,
      activitiesAble: true,
      symptoms: _getSymptoms(),
    );
    await context.read<AppProvider>().saveCheckIn(checkIn);
    setState(() { _isSubmitting = false; _isComplete = true; });
  }

  Future<void> _submitFull() async {
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
      medicationsTaken: _medicationsTaken,
      waterGlasses: _waterGlasses,
      notes: [
        if (_notesCtrl.text.isNotEmpty) _notesCtrl.text,
        if (_emotionalScore <= 2) 'Emotional: ${_emotionLabels[_emotionalScore]}',
      ].join(' | ').nullIfEmpty,
      foodNotes: _foodCtrl.text.isEmpty ? null : _foodCtrl.text,
      activitiesAble: _activitiesAble,
      symptoms: _getSymptoms(),
    );
    await context.read<AppProvider>().saveCheckIn(checkIn);
    setState(() { _isSubmitting = false; _isComplete = true; });
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

// ─── Step Label ───────────────────────────────────────────────────────────────
class _StepLabel extends StatelessWidget {
  final String step;
  final String label;
  const _StepLabel({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 26, height: 26,
        decoration: BoxDecoration(gradient: AppColors.cardGradient, shape: BoxShape.circle),
        child: Center(child: Text(step, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
      ),
      const SizedBox(width: 10),
      Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]);
  }
}

// ─── Med Tap Card ─────────────────────────────────────────────────────────────
class _MedTapCard extends StatelessWidget {
  final bool taken;
  final bool selected;
  final VoidCallback onTap;
  const _MedTapCard({required this.taken, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final col = taken ? AppColors.accent : AppColors.danger;
    final bgCol = taken ? AppColors.accentLight : AppColors.dangerLight;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? col : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? col : AppColors.border, width: 2),
          boxShadow: selected ? [BoxShadow(color: col.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Column(children: [
          Icon(taken ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: selected ? Colors.white : col, size: 28),
          const SizedBox(height: 6),
          Text(taken ? 'Yes, all taken' : 'Missed / partial',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textSecondary)),
        ]),
      ),
    );
  }
}

// ─── Water Button ─────────────────────────────────────────────────────────────
class _WaterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isAdd;
  const _WaterBtn({required this.icon, required this.onTap, this.isAdd = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isAdd ? AppColors.info.withValues(alpha: 0.1) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isAdd ? AppColors.info.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Icon(icon, color: isAdd ? AppColors.info : AppColors.textSecondary, size: 22),
      ),
    );
  }
}

// ─── Completion View ──────────────────────────────────────────────────────────
class _CompletionView extends StatelessWidget {
  final int moodScore;
  final int emotionalScore;
  final VoidCallback onGoHome;
  const _CompletionView({required this.moodScore, required this.emotionalScore, required this.onGoHome});

  @override
  Widget build(BuildContext context) {
    final moodEmoji = ['', '😞', '😔', '😐', '🙂', '😊'][moodScore.clamp(1, 5)];
    final showSupport = emotionalScore <= 2;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            Text('Check-In Complete! $moodEmoji',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            const Text('Your data has been saved. Your care team can see this.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            // AI message
            RehlaCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3E8FA), Color(0xFFEDD8F7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    moodScore >= 4
                        ? 'Great mood today! Your resilience is a real strength. 💜'
                        : moodScore <= 2
                            ? 'Tough day noted. Tracking it helps your team support you better. You\'re not alone.'
                            : 'Thanks for checking in. Consistent tracking helps your team make better decisions.',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ),
              ]),
            ),
            if (showSupport) ...[
              const SizedBox(height: 12),
              RehlaCard(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.support_agent_rounded, color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Your emotional wellbeing matters. Talk to your counsellor or call a support line.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 28),
            PurpleGradientButton(label: 'Back to Home', icon: Icons.home_rounded, onTap: onGoHome),
          ]),
        ),
      ),
    );
  }
}
