import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ONBOARDING SCREEN — 5-Step Conversational Flow
// "This is not a form. This is a conversation."
// Each step feels like a caring person asking a gentle question.
// ═══════════════════════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final AnimationController _dotAnim;

  // Form data
  String _whoIsThis = 'patient';
  String _name = '';
  String _cancerType = '';
  String _stage = '';
  String _treatmentPhase = '';
  DateTime? _diagnosisDate;
  DateTime? _treatmentStartDate;
  bool _isLoading = false;

  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dotAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _dotAnim.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _dotAnim.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool get _canContinue {
    switch (_currentPage) {
      case 0: return _whoIsThis.isNotEmpty;
      case 1: return _name.length >= 2;
      case 2: return _cancerType.isNotEmpty;
      case 3: return _treatmentPhase.isNotEmpty; // phase required, stage optional
      case 4: return true; // dates step — always optional, can continue
      default: return false;
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    final journey = UserJourney(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _name,
      cancerType: _cancerType,
      stage: _stage.isNotEmpty ? _stage : 'Unknown',
      treatmentPhase: _treatmentPhase,
      treatmentStartDate: _treatmentStartDate ?? _diagnosisDate ?? DateTime.now(),
      isPatient: _whoIsThis == 'patient',
    );
    await context.read<AppProvider>().saveJourney(journey);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/journey_created');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar with back, dots, skip ─────────────────────────────
            _TopBar(
              currentPage: _currentPage,
              onBack: _currentPage == 0
                  ? () => Navigator.pop(context)
                  : _prevPage,
              onSkip: _currentPage < 2
                  ? () {
                      // Skip to last page
                      _pageController.animateToPage(
                        4,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
            ),

            // ── Page content ───────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WhoPage(
                    selected: _whoIsThis,
                    onSelect: (v) => setState(() => _whoIsThis = v),
                  ),
                  _NamePage(
                    controller: _nameController,
                    whoIsThis: _whoIsThis,
                    onChanged: (v) => setState(() => _name = v),
                  ),
                  _CancerTypePage(
                    selected: _cancerType,
                    onSelect: (v) => setState(() => _cancerType = v),
                  ),
                  _StageAndPhasePage(
                    selectedStage: _stage,
                    selectedPhase: _treatmentPhase,
                    onStageSelect: (v) => setState(() => _stage = v),
                    onPhaseSelect: (v) => setState(() => _treatmentPhase = v),
                    name: _name.isNotEmpty ? _name.split(' ').first : 'you',
                  ),
                  _DatesPage(
                    diagnosisDate: _diagnosisDate,
                    treatmentStartDate: _treatmentStartDate,
                    onDiagnosisSelected: (d) => setState(() => _diagnosisDate = d),
                    onTreatmentStartSelected: (d) => setState(() => _treatmentStartDate = d),
                    name: _name.isNotEmpty ? _name.split(' ').first : 'you',
                  ),
                ],
              ),
            ),

            // ── CTA button ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: AnimatedOpacity(
                opacity: _canContinue ? 1.0 : 0.45,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canContinue ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _currentPage < 4 ? 'Continue →' : 'Begin My Journey →',
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar with Progress Dots ────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback onBack;
  final VoidCallback? onSkip;

  const _TopBar({
    required this.currentPage,
    required this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primarySurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(8),
            ),
          ),

          // Dots — 5 total
          const Spacer(),
          Row(
            children: List.generate(5, (i) {
              final isActive = i == currentPage;
              final isPast = i < currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : isPast
                          ? AppColors.primaryLight
                          : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const Spacer(),

          // Skip button (only on early steps)
          if (onSkip != null)
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF78716C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox(width: 56),
        ],
      ),
    );
  }
}

// ── Step 1: Who is this for? ──────────────────────────────────────────────────
class _WhoPage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _WhoPage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Let's make\nRehlah yours.",
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1917),
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Who will be using the app?',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFF78716C),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),

          // Patient option
          _RoleCard(
            emoji: '💜',
            title: 'I am a patient',
            subtitle: "I'm going through treatment",
            isSelected: selected == 'patient',
            onTap: () => onSelect('patient'),
          ),
          const SizedBox(height: 12),

          // Caregiver option
          _RoleCard(
            emoji: '🤝',
            title: 'I am a caregiver',
            subtitle: "I'm supporting someone I love",
            isSelected: selected == 'caregiver',
            onTap: () => onSelect('caregiver'),
          ),

          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              'Both roles are equal here. Rehlah is built for patients and caregivers alike.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Name ──────────────────────────────────────────────────────────────
class _NamePage extends StatefulWidget {
  final TextEditingController controller;
  final String whoIsThis;
  final ValueChanged<String> onChanged;

  const _NamePage({
    required this.controller,
    required this.whoIsThis,
    required this.onChanged,
  });

  @override
  State<_NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<_NamePage> with SingleTickerProviderStateMixin {
  late final AnimationController _greetingCtrl;
  late final Animation<double> _greetingFade;
  String _liveNamePreview = '';

  @override
  void initState() {
    super.initState();
    _greetingCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _greetingFade = CurvedAnimation(parent: _greetingCtrl, curve: Curves.easeOut);
    _liveNamePreview = widget.controller.text;
    if (_liveNamePreview.length >= 2) _greetingCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _greetingCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    widget.onChanged(v);
    setState(() => _liveNamePreview = v);
    if (v.length >= 2 && !_greetingCtrl.isCompleted) {
      _greetingCtrl.forward();
    } else if (v.length < 2) {
      _greetingCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPatient = widget.whoIsThis == 'patient';
    final firstName = _liveNamePreview.trim().split(' ').first;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What should\nwe call you?',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1917),
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isPatient
                ? 'Just your first name is enough.'
                : 'So Rehlah feels like it was made just for you.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFF78716C),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 36),
          TextField(
            controller: widget.controller,
            onChanged: _onChanged,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: isPatient ? 'Your first name' : 'e.g. Ahmad',
              hintStyle: GoogleFonts.inter(
                fontSize: 22,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // ── Live name preview — "Hi Sara 💜" ─────────────────────────────
          FadeTransition(
            opacity: _greetingFade,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEEE0F9), Color(0xFFF5E8F8)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                firstName.isNotEmpty ? 'Hi $firstName 💜' : '',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your data stays on this device. No account required.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Cancer Type ───────────────────────────────────────────────────────
class _CancerTypePage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CancerTypePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What type of\ncancer is it?',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1917),
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This helps us show you the most relevant guidance.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFF78716C),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),
          ...cancerTypes.map((type) {
            final emoji = _cancerEmoji(type);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CompactOptionCard(
                emoji: emoji,
                title: type,
                isSelected: selected == type,
                onTap: () => onSelect(type),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _cancerEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'breast cancer': return '🎀';
      case 'lung cancer': return '🫁';
      case 'colorectal cancer': return '🔵';
      case 'prostate cancer': return '💙';
      case 'blood / hematologic': return '🩸';
      case 'lymphoma': return '🟣';
      case 'thyroid cancer': return '🦋';
      case 'skin cancer': return '🌞';
      default: return '💜';
    }
  }
}

// ── Step 4: Stage & Treatment Phase (Combined per UX spec) ───────────────────
class _StageAndPhasePage extends StatelessWidget {
  final String selectedStage;
  final String selectedPhase;
  final ValueChanged<String> onStageSelect;
  final ValueChanged<String> onPhaseSelect;
  final String name;

  const _StageAndPhasePage({
    required this.selectedStage,
    required this.selectedPhase,
    required this.onStageSelect,
    required this.onPhaseSelect,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you\nin your journey?',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1917),
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Take your time — both are optional to update later.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFF78716C),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 24),

          // Stage section
          Text(
            'What stage is your cancer?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 10),
          // Stage tiles in a 2x2 grid + "Not sure" below
          Row(
            children: [
              _StageTile(label: 'Stage I', isSelected: selectedStage == 'Stage I', onTap: () => onStageSelect('Stage I')),
              const SizedBox(width: 8),
              _StageTile(label: 'Stage II', isSelected: selectedStage == 'Stage II', onTap: () => onStageSelect('Stage II')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StageTile(label: 'Stage III', isSelected: selectedStage == 'Stage III', onTap: () => onStageSelect('Stage III')),
              const SizedBox(width: 8),
              _StageTile(label: 'Stage IV', isSelected: selectedStage == 'Stage IV', onTap: () => onStageSelect('Stage IV')),
            ],
          ),
          const SizedBox(height: 8),
          // Not sure link
          GestureDetector(
            onTap: () => onStageSelect('Not sure'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: selectedStage == 'Not sure' ? AppColors.primarySurface : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedStage == 'Not sure' ? AppColors.primary : AppColors.divider,
                  width: selectedStage == 'Not sure' ? 1.5 : 1,
                ),
              ),
              child: Text(
                'Not sure yet — I\'ll add this later',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: selectedStage == 'Not sure' ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF3E8F5)),
          const SizedBox(height: 20),

          // Phase section
          Text(
            'What phase of treatment are you in?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 10),
          // Phase tiles — icon grid (3x2)
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            children: _phases.map((p) {
              final isSelected = selectedPhase == p.$1;
              return GestureDetector(
                onTap: () => onPhaseSelect(p.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(p.$2, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 6),
                      Text(
                        p.$1,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          // Phase description
          if (selectedPhase.isNotEmpty) ...[
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                _phaseDescription(selectedPhase),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static const _phases = [
    ('Diagnosis & Planning', '🔬'),
    ('Chemotherapy', '💊'),
    ('Radiation', '☢️'),
    ('Surgery', '🏥'),
    ('Recovery', '🌱'),
    ('Immunotherapy', '💉'),
  ];

  String _phaseDescription(String phase) {
    switch (phase) {
      case 'Diagnosis & Planning': return 'Meeting your care team and getting your full picture';
      case 'Chemotherapy': return 'Treatment sessions to destroy or shrink cancer cells';
      case 'Radiation': return 'Targeted radiation to treat the tumour area';
      case 'Surgery': return 'Surgical procedure to remove or treat cancer';
      case 'Recovery': return 'Rest and healing after active treatment';
      case 'Immunotherapy': return 'Building your immune system to fight cancer';
      default: return '';
    }
  }
}

class _StageTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _StageTile({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 5: Dates (Optional) ──────────────────────────────────────────────────
class _DatesPage extends StatelessWidget {
  final DateTime? diagnosisDate;
  final DateTime? treatmentStartDate;
  final ValueChanged<DateTime> onDiagnosisSelected;
  final ValueChanged<DateTime> onTreatmentStartSelected;
  final String name;

  const _DatesPage({
    required this.diagnosisDate,
    required this.treatmentStartDate,
    required this.onDiagnosisSelected,
    required this.onTreatmentStartSelected,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Two last things —\nboth are optional.',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1917),
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'These dates help us personalise your milestones.\nSkip them if you\'re not sure yet.',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: const Color(0xFF78716C),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),

          // Diagnosis date
          Text(
            '📅  When were you diagnosed?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _DatePicker(
            label: 'Optional  ·  e.g. March 15, 2026',
            selectedDate: diagnosisDate,
            onSelected: onDiagnosisSelected,
          ),

          const SizedBox(height: 20),

          // Treatment start date
          Text(
            '💊  When did treatment start?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _DatePicker(
            label: 'Optional  ·  e.g. April 1, 2026',
            selectedDate: treatmentStartDate,
            onSelected: onTreatmentStartSelected,
          ),

          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💜', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Even without dates, Rehlah will track your journey from today. You can always add these later in settings.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelected;

  const _DatePicker({
    required this.label,
    required this.selectedDate,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 730)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (date != null) onSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selectedDate != null ? AppColors.primary : AppColors.border,
            width: selectedDate != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: selectedDate != null ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontWeight: selectedDate != null ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            Text(
              selectedDate != null ? '✓' : 'Tap to set',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: selectedDate != null ? AppColors.success : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compact Option Card ───────────────────────────────────────────────────────
class _CompactOptionCard extends StatelessWidget {
  final String title;
  final String? emoji;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactOptionCard({
    required this.title,
    this.emoji,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data constants ────────────────────────────────────────────────────────────
const cancerTypes = [
  'Breast Cancer',
  'Lung Cancer',
  'Colorectal Cancer',
  'Prostate Cancer',
  'Blood / Hematologic',
  'Lymphoma',
  'Thyroid Cancer',
  'Skin Cancer',
  'Ovarian Cancer',
  'Cervical Cancer',
  'Other',
];

const cancerStages = [
  'Stage 0',
  'Stage I',
  'Stage II',
  'Stage III',
  'Stage IV',
  'Unknown',
];

const treatmentPhases = [
  'Diagnosis & Planning',
  'Pre-Treatment (Planning)',
  'Weekly Treatment (Chemo)',
  'Daily Treatment (Radiation)',
  'Surgery Recovery',
  'Immunotherapy',
  'Post-Treatment Monitoring',
  'Palliative Care',
];
