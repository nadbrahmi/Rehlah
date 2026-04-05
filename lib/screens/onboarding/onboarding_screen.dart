import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  String _whoIsThis = 'patient';
  String _name = '';
  String _cancerType = '';
  String _stage = '';
  String _treatmentPhase = '';
  DateTime? _treatmentStartDate;
  bool _isLoading = false;

  final _nameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get _canContinue {
    switch (_currentPage) {
      case 0: return _whoIsThis.isNotEmpty;
      case 1: return _name.length >= 2;
      case 2: return _cancerType.isNotEmpty;
      case 3: return _stage.isNotEmpty;
      case 4: return _treatmentPhase.isNotEmpty;
      default: return false;
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    final journey = UserJourney(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _name,
      cancerType: _cancerType,
      stage: _stage,
      treatmentPhase: _treatmentPhase,
      treatmentStartDate: _treatmentStartDate,
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _currentPage == 0
              ? () => Navigator.pop(context)
              : _prevPage,
        ),
        title: Text(
          'Set Up Your Journey',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 3,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_currentPage + 1} of 5',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const Spacer(),
                Text(
                  'Help us personalize your experience',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _WhoPage(selected: _whoIsThis, onSelect: (v) => setState(() => _whoIsThis = v)),
                _NamePage(controller: _nameController, onChanged: (v) => setState(() => _name = v)),
                _CancerTypePage(selected: _cancerType, onSelect: (v) => setState(() => _cancerType = v)),
                _StagePage(selected: _stage, onSelect: (v) => setState(() => _stage = v)),
                _PhasePage(selected: _treatmentPhase, onSelect: (v) => setState(() => _treatmentPhase = v)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: PurpleGradientButton(
              label: _currentPage < 4 ? 'Continue' : "Let's Get Started",
              icon: _currentPage < 4 ? Icons.arrow_forward_rounded : Icons.check_rounded,
              onTap: _canContinue ? _nextPage : () {},
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhoPage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _WhoPage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Who is this for?',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('This helps us personalize your experience',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          _OptionCard(
            icon: Icons.person_rounded,
            title: "I'm the patient",
            subtitle: 'Track my own treatment journey',
            isSelected: selected == 'patient',
            onTap: () => onSelect('patient'),
          ),
          const SizedBox(height: 12),
          _OptionCard(
            icon: Icons.favorite_rounded,
            title: "I'm a caregiver",
            subtitle: 'Help a loved one track their journey',
            isSelected: selected == 'caregiver',
            onTap: () => onSelect('caregiver'),
          ),
        ],
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NamePage({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about you',
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text("We'll use this to personalize your dashboard",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          const Text('Full name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(
              hintText: 'e.g. Sarah Johnson',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: AppColors.accent, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your data stays on this device until you create an account.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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

class _CancerTypePage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CancerTypePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1. What type of cancer?',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Select the cancer type',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ...cancerTypes.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OptionCard(
                  title: type,
                  isSelected: selected == type,
                  onTap: () => onSelect(type),
                  compact: true,
                ),
              )),
        ],
      ),
    );
  }
}

class _StagePage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _StagePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('2. What stage?',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Select the cancer stage',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ...cancerStages.map((stage) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OptionCard(
                  title: stage,
                  isSelected: selected == stage,
                  onTap: () => onSelect(stage),
                  compact: true,
                ),
              )),
        ],
      ),
    );
  }
}

class _PhasePage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _PhasePage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('3. Current treatment phase?',
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Select your current phase',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ...treatmentPhases.map((phase) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OptionCard(
                  title: phase,
                  isSelected: selected == phase,
                  onTap: () => onSelect(phase),
                  compact: true,
                ),
              )),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  const _OptionCard({
    required this.title,
    this.subtitle,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
