import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import '../main_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // O0 – Language
  bool _selectedArabic = true;

  // O1 – Role
  UserRole _selectedRole = UserRole.patient;

  // O2 – Name
  final _nameController = TextEditingController();

  // O3 – Cancer type
  String? _selectedCancerType;

  // O4 – Treatment phase
  String? _selectedPhase;
  String? _selectedPhaseDetail;

  // O5 – Optional details
  String? _selectedStage;
  DateTime? _diagDate;
  DateTime? _startDate;

  // Total pages = 6 (O0 through O5) + welcome transition (O6)
  static const int _totalSteps = 6;

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  AppLocalizations get _l10n => AppLocalizations(isArabic: _selectedArabic);

  void _nextPage() {
    if (_currentPage < _totalSteps) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _selectLanguage(bool arabic) {
    setState(() => _selectedArabic = arabic);
    // Propagate immediately so the rest of onboarding & app use the right lang.
    context.read<AppProvider>().setLanguage(arabic);
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _selectedArabic;
    return L10nProvider(
      isArabic: isArabic,
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _buildO0(), // Language selection
                _buildO1(), // Role
                _buildO2(), // Name
                _buildO3(), // Cancer type
                _buildO4(), // Treatment phase
                _buildO5(), // Optional details
                _buildO6(), // Welcome transition
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── O0 — Language Selection ───────────────────────────────────────────────
  Widget _buildO0() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // App icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                ),
                child: const Center(child: Text('💜', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 28),
              // Bilingual title
              Text(
                'اختاري لغتك',
                style: GoogleFonts.almarai(
                    fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Choose your language',
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Language cards
              Row(
                children: [
                  _LanguageCard(
                    label: 'العربية',
                    sublabel: 'Arabic',
                    flag: '🇦🇪',
                    selected: _selectedArabic,
                    onTap: () => _selectLanguage(true),
                  ),
                  const SizedBox(width: 16),
                  _LanguageCard(
                    label: 'English',
                    sublabel: 'الإنجليزية',
                    flag: '🇬🇧',
                    selected: !_selectedArabic,
                    onTap: () => _selectLanguage(false),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Hint (bilingual)
              Text(
                'يمكنكِ تغيير اللغة لاحقاً من الإعدادات\nYou can change the language later in settings',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: Text(
                    _selectedArabic ? 'متابعة ←' : 'Continue →',
                    style: GoogleFonts.almarai(
                        fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── O1 — Who ─────────────────────────────────────────────────────────────
  Widget _buildO1() {
    final l = _l10n;
    return _OnboardingPage(
      step: 1,
      totalSteps: _totalSteps,
      isArabic: _selectedArabic,
      onBack: _prevPage,
      child: Column(
        children: [
          Text(l.o1Title,
              style: GoogleFonts.almarai(
                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          Row(
            children: [
              _RoleCard(
                label: l.o1Patient,
                icon: '🌸',
                selected: _selectedRole == UserRole.patient,
                onTap: () => setState(() => _selectedRole = UserRole.patient),
              ),
              const SizedBox(width: 16),
              _RoleCard(
                label: l.o1Caregiver,
                icon: '🤝',
                selected: _selectedRole == UserRole.caregiver,
                onTap: () => setState(() => _selectedRole = UserRole.caregiver),
              ),
            ],
          ),
          if (_selectedRole == UserRole.caregiver) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l.o1CaregiverSoon,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(l.o1Privacy,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
          const Spacer(),
          _NextButton(label: l.onbNext, onTap: _nextPage),
        ],
      ),
    );
  }

  // ── O2 — Name ─────────────────────────────────────────────────────────────
  Widget _buildO2() {
    final l = _l10n;
    return _OnboardingPage(
      step: 2,
      totalSteps: _totalSteps,
      isArabic: _selectedArabic,
      onBack: _prevPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.o2Title,
              style: GoogleFonts.almarai(
                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            textAlign: _selectedArabic ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.almarai(fontSize: 18, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: l.o2Hint,
              hintStyle: GoogleFonts.almarai(color: AppColors.textSecondary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const Spacer(),
          _NextButton(
            label: l.onbContinue,
            onTap: () {
              if (_nameController.text.trim().isNotEmpty) _nextPage();
            },
          ),
        ],
      ),
    );
  }

  // ── O3 — Cancer type ──────────────────────────────────────────────────────
  Widget _buildO3() {
    final l = _l10n;
    final types = l.cancerTypes;
    return _OnboardingPage(
      step: 3,
      totalSteps: _totalSteps,
      isArabic: _selectedArabic,
      onBack: _prevPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.o3Title,
              style: GoogleFonts.almarai(
                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: types.map((type) {
                final selected = _selectedCancerType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCancerType = type),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryLight : AppColors.surface,
                      border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: selected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(type,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: selected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _NextButton(onTap: _selectedCancerType != null ? _nextPage : null, label: l.onbNext),
        ],
      ),
    );
  }

  // ── O4 — Treatment phase ──────────────────────────────────────────────────
  Widget _buildO4() {
    final l = _l10n;
    final phases = l.phases;
    // Detect which phases have follow-ups (index 1 = Chemo, index 6 = Post-treatment)
    final chemoPhase = phases[1];
    final postPhase = phases[6];
    return _OnboardingPage(
      step: 4,
      totalSteps: _totalSteps,
      isArabic: _selectedArabic,
      onBack: _prevPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.o4Title,
              style: GoogleFonts.almarai(
                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ...phases.map((phase) {
                  final selected = _selectedPhase == phase;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedPhase = phase;
                      _selectedPhaseDetail = null;
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryLight : AppColors.surface,
                        border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                            width: selected ? 2 : 1),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: selected
                            ? []
                            : [
                                const BoxShadow(
                                    color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1))
                              ],
                      ),
                      child: Text(phase,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              color: selected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                    ),
                  );
                }),
                // Chemo follow-up
                if (_selectedPhase == chemoPhase) ...[
                  const SizedBox(height: 8),
                  Text(l.o4ChemoType,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _DetailChip(l.o4ChemoOnly, _selectedPhaseDetail == l.o4ChemoOnly,
                          () => setState(() => _selectedPhaseDetail = l.o4ChemoOnly)),
                      const SizedBox(width: 10),
                      _DetailChip(l.o4ChemoImmuno, _selectedPhaseDetail == l.o4ChemoImmuno,
                          () => setState(() => _selectedPhaseDetail = l.o4ChemoImmuno)),
                    ],
                  ),
                ],
                // Post-treatment follow-up
                if (_selectedPhase == postPhase) ...[
                  const SizedBox(height: 8),
                  Text(
                    _selectedArabic ? 'هل تتناولين علاجاً هرمونياً؟' : 'Are you on hormonal therapy?',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _DetailChip(
                          _selectedArabic ? 'نعم' : 'Yes',
                          _selectedPhaseDetail == (_selectedArabic ? 'نعم' : 'Yes'),
                          () => setState(() =>
                              _selectedPhaseDetail = _selectedArabic ? 'نعم' : 'Yes')),
                      const SizedBox(width: 10),
                      _DetailChip(
                          _selectedArabic ? 'لا' : 'No',
                          _selectedPhaseDetail == (_selectedArabic ? 'لا' : 'No'),
                          () => setState(
                              () => _selectedPhaseDetail = _selectedArabic ? 'لا' : 'No')),
                    ],
                  ),
                ],
              ],
            ),
          ),
          _NextButton(onTap: _selectedPhase != null ? _nextPage : null, label: l.onbNext),
        ],
      ),
    );
  }

  // ── O5 — Optional details ─────────────────────────────────────────────────
  Widget _buildO5() {
    final l = _l10n;
    final stages = l.stages;
    return _OnboardingPage(
      step: 5,
      totalSteps: _totalSteps,
      isArabic: _selectedArabic,
      onBack: _prevPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.o5Title,
              style: GoogleFonts.almarai(
                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            _selectedArabic
                ? 'تساعدنا على تقديم دعم أدق — يمكنكِ تخطّيها الآن وإضافتها لاحقاً'
                : 'Helps us provide more personalised support — you can skip and add later',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _SectionLabel(l.o5Stage),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: stages
                .map((s) => GestureDetector(
                      onTap: () => setState(() => _selectedStage = s),
                      child: Chip(
                        label: Text(s,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: _selectedStage == s
                                    ? AppColors.primary
                                    : AppColors.textPrimary)),
                        backgroundColor:
                            _selectedStage == s ? AppColors.primaryLight : AppColors.surface,
                        side: BorderSide(
                            color: _selectedStage == s ? AppColors.primary : AppColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          _SectionLabel(l.o5DiagDate),
          const SizedBox(height: 8),
          _DatePickerRow(
            value: _diagDate,
            onChanged: (d) => setState(() => _diagDate = d),
            hint: _selectedArabic ? 'اختاري التاريخ' : 'Select date',
            isArabic: _selectedArabic,
          ),
          const SizedBox(height: 16),
          _SectionLabel(l.o5StartDate),
          const SizedBox(height: 8),
          _DatePickerRow(
            value: _startDate,
            onChanged: (d) => setState(() => _startDate = d),
            hint: _selectedArabic ? 'اختاري التاريخ' : 'Select date',
            isArabic: _selectedArabic,
          ),
          const Spacer(),
          Center(
            child: TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                _selectedArabic ? 'تخطّي — سأضيف لاحقاً' : 'Skip — I\'ll add later',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _NextButton(
            label: _selectedArabic ? 'ابدئي رحلتكِ' : 'Start my journey',
            onTap: _finishOnboarding,
          ),
        ],
      ),
    );
  }

  void _finishOnboarding() {
    final provider = context.read<AppProvider>();
    final defaultName = _selectedArabic ? 'صديقتي' : 'Friend';
    final defaultType = _selectedArabic ? 'غير محدد' : 'Not specified';
    provider.completeOnboarding(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : defaultName,
      cancerTypeVal: _selectedCancerType ?? defaultType,
      phaseLabel: _selectedPhase ?? defaultType,
      phaseTypeLabel: _selectedPhaseDetail ?? _selectedPhase ?? defaultType,
      stage: _selectedStage,
      diagDate: _diagDate,
      startDate: _startDate,
      languageIsArabic: _selectedArabic,
    );
    _nextPage();
  }

  // ── O6 — Welcome transition ───────────────────────────────────────────────
  Widget _buildO6() {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (_selectedArabic ? 'صديقتي' : 'Friend');
    return _WelcomeTransition(userName: name, isArabic: _selectedArabic);
  }
}

// ── Language card ─────────────────────────────────────────────────────────────
class _LanguageCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String flag;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageCard({
    required this.label,
    required this.sublabel,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2.5 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
                : [const BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.almarai(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (selected) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Selected',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Welcome transition ────────────────────────────────────────────────────────
class _WelcomeTransition extends StatefulWidget {
  final String userName;
  final bool isArabic;
  const _WelcomeTransition({required this.userName, required this.isArabic});

  @override
  State<_WelcomeTransition> createState() => _WelcomeTransitionState();
}

class _WelcomeTransitionState extends State<_WelcomeTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (_) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💜', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 24),
                Text(
                  isAr ? 'أهلاً بكِ، ${widget.userName}' : 'Welcome, ${widget.userName}!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  isAr
                      ? 'رحلة يُسر جاهزة لمرافقتكِ.'
                      : 'Rehlah is ready to be with you every step of the way.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final int step;
  final int totalSteps;
  final bool isArabic;
  final Widget child;
  final VoidCallback? onBack;
  const _OnboardingPage({
    required this.step,
    required this.totalSteps,
    required this.isArabic,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + progress row
          Row(
            children: [
              if (onBack != null)
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const Spacer(),
              // Dots — steps 1–5 (skip O0 lang screen which has no dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalSteps, (i) {
                  final active = i == step - 1;
                  final done = i < step - 1;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : done
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const Spacer(),
              // Step label
              Text(
                isArabic ? '$step/$totalSteps' : '$step/$totalSteps',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 10),
              Text(label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.almarai(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.primary : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DetailChip(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary));
}

class _DatePickerRow extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String hint;
  final bool isArabic;
  const _DatePickerRow(
      {required this.value,
      required this.onChanged,
      required this.hint,
      required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2018),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border:
              Border.all(color: value != null ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(
              value != null
                  ? '${value!.day}/${value!.month}/${value!.year}'
                  : hint,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: value != null ? AppColors.textPrimary : AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _NextButton({this.label = 'التالي', this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: onTap != null ? AppColors.primary : AppColors.border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
        ),
        child: Text(label,
            style: GoogleFonts.almarai(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
