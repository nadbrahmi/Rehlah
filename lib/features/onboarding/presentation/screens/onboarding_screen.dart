import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0; // 0=welcome, 1=who, 2=name, 3=type, 4=phase, 5=notifs, 6=done

  // Selections
  int _whoIndex = 0;
  final _nameController = TextEditingController();
  int _typeIndex = 0;
  int _phaseIndex = 2;
  final Set<int> _notifSelected = {0, 1};

  void _next() {
    if (_page < 6) {
      setState(() => _page++);
      _pageController.animateToPage(_page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.go('/');
    }
  }

  void _back() {
    if (_page > 0) {
      setState(() => _page--);
      _pageController.animateToPage(_page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildOrbs(),
          SafeArea(
            child: Column(
              children: [
                if (_page > 0 && _page < 6) _buildProgressDots(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWelcome(),
                      _buildWho(),
                      _buildName(),
                      _buildCancerType(),
                      _buildPhase(),
                      _buildNotifications(),
                      _buildCelebration(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbs() {
    return Stack(children: [
      Positioned(top: -70, right: -50,
        child: Container(width: 220, height: 220,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.primary.withOpacity(0.13), Colors.transparent])))),
      Positioned(bottom: 100, left: -30,
        child: Container(width: 160, height: 160,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.teal.withOpacity(0.08), Colors.transparent])))),
    ]);
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final stepPage = i + 1; // pages 1–5
          final isDone = _page > stepPage;
          final isActive = _page == stepPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: isActive ? 20 : (isDone ? 12 : 6),
            height: 4,
            decoration: BoxDecoration(
              color: isDone ? AppColors.teal
                  : isActive ? AppColors.primary
                  : AppColors.primary.withOpacity(0.13),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }

  // ── Page 0: Welcome ──────────────────────────────────────────────────────
  Widget _buildWelcome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(children: [
        const SizedBox(height: 20),
        // Logo
        Container(
          width: 76, height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment(-0.6, -0.8), end: Alignment(1, 1),
              colors: [Color(0xFFDDD4F5), Color(0xFFCCC0EC),
                       Color(0xFFD8CCEE), Color(0xFFE8D4E0)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 0.5),
            boxShadow: [BoxShadow(
              color: AppColors.primary.withOpacity(0.22),
              blurRadius: 28, offset: const Offset(0, 10))],
          ),
          child: const Icon(Icons.auto_awesome_rounded,
            size: 28, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text('Rehlah',
          style: TextStyle(fontFamily: 'Inter', fontSize: 28,
            fontWeight: FontWeight.w300, color: AppColors.text1,
            letterSpacing: 0.02)),
        const SizedBox(height: 3),
        Text('رحلة · Your journey',
          style: TextStyle(fontFamily: 'Inter', fontSize: 15,
            color: AppColors.text2, fontWeight: FontWeight.w300,
            letterSpacing: 0.05)),
        const SizedBox(height: 8),
        Text('A companion for every step\nof your cancer journey',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13,
            color: AppColors.text3, fontWeight: FontWeight.w300,
            height: 1.6)),
        const SizedBox(height: 24),
        // Feature pills
        _featurePill(Icons.auto_awesome_rounded, AppColors.primaryLight,
            AppColors.primary, 'AI companion', 'that understands oncology'),
        const SizedBox(height: 8),
        _featurePill(Icons.check_circle_outline_rounded, AppColors.tealLight,
            AppColors.teal, 'Track', 'symptoms, meds & appointments'),
        const SizedBox(height: 8),
        _featurePill(Icons.people_outline_rounded, AppColors.peachLight,
            AppColors.peach, 'Community', 'of patients & survivors'),
        const SizedBox(height: 20),
        // Ghost button
        GestureDetector(
          onTap: _next,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Center(child: Text('Explore with sample data',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                color: AppColors.text3))),
          ),
        ),
        const SizedBox(height: 10),
        Text('🔒 Your data stays yours. We never sell your health information.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
            color: AppColors.text3, fontWeight: FontWeight.w300, height: 1.6)),
        const SizedBox(height: 16),
        _primaryButton('Get started', _next),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _featurePill(IconData icon, Color bg, Color color,
      String bold, String rest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        Container(width: 26, height: 26,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, size: 13, color: color)),
        const SizedBox(width: 10),
        RichText(text: TextSpan(
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
            color: AppColors.text2, fontWeight: FontWeight.w300),
          children: [
            TextSpan(text: bold,
              style: const TextStyle(fontWeight: FontWeight.w500,
                color: AppColors.text1)),
            TextSpan(text: ' $rest'),
          ],
        )),
      ]),
    );
  }

  // ── Page 1: Who ──────────────────────────────────────────────────────────
  Widget _buildWho() {
    final options = [
      ('🧑‍⚕️', AppColors.primaryLight, 'I\'m a patient',
          'Diagnosed with or undergoing treatment'),
      ('🤝', AppColors.peachLight, 'I\'m a caregiver',
          'Supporting a loved one through their journey'),
      ('🌟', AppColors.tealLight, 'I\'m a survivor',
          'Cancer-free and in the monitoring phase'),
    ];
    return _stepScaffold(
      stepLabel: 'Step 1 of 5',
      title: 'Who is\n',
      titleBold: 'using Rehlah?',
      subtitle: 'This helps us personalise your experience from the start.',
      body: Column(children: options.asMap().entries.map((e) {
        final sel = _whoIndex == e.key;
        return GestureDetector(
          onTap: () => setState(() => _whoIndex = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary.withOpacity(0.06) : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? AppColors.primaryMid : AppColors.border,
                width: 0.5),
            ),
            child: Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(
                  color: e.value.$2, borderRadius: BorderRadius.circular(11)),
                child: Center(child: Text(e.value.$1,
                  style: const TextStyle(fontSize: 18)))),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.value.$3,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: sel ? AppColors.primary : AppColors.text1)),
                  Text(e.value.$4,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                      color: AppColors.text2, fontWeight: FontWeight.w300)),
                ],
              )),
              Container(width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.border,
                    width: 1.5)),
                child: sel ? const Icon(Icons.check_rounded,
                  size: 10, color: Colors.white) : null),
            ]),
          ),
        );
      }).toList()),
      onContinue: _next,
      onBack: _back,
    );
  }

  // ── Page 2: Name ──────────────────────────────────────────────────────────
  Widget _buildName() {
    return _stepScaffold(
      stepLabel: 'Step 2 of 5',
      title: 'What should\nwe ',
      titleBold: 'call you?',
      subtitle: 'First name only is fine. You\'re in control of what you share.',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('YOUR NAME',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.07,
            color: AppColors.text3)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          autofocus: false,
          style: const TextStyle(fontFamily: 'Inter',
            fontSize: 15, color: AppColors.text1),
          decoration: InputDecoration(
            hintText: 'First name',
            hintStyle: const TextStyle(color: AppColors.text3),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: AppColors.primaryMid, width: 1)),
          ),
        ),
        const SizedBox(height: 8),
        Text('No last name or email needed right now.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
            color: AppColors.text3, fontWeight: FontWeight.w300)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.teal.withOpacity(0.18), width: 0.5),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🔒', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Your name is only used within the app. We never share it externally.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                color: AppColors.teal, fontWeight: FontWeight.w300,
                height: 1.5))),
          ]),
        ),
      ]),
      onContinue: _next,
      onBack: _back,
    );
  }

  // ── Page 3: Cancer Type ──────────────────────────────────────────────────
  Widget _buildCancerType() {
    final types = [
      ('🎀', 'Breast'), ('🫁', 'Lung'), ('🫀', 'Colorectal'),
      ('🩸', 'Leukemia'), ('💜', 'Lymphoma'), ('✦', 'Other'),
    ];
    return _stepScaffold(
      stepLabel: 'Step 3 of 5',
      title: 'What type of\n',
      titleBold: 'cancer?',
      subtitle: 'This helps us surface the most relevant content for you.',
      body: Column(children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.2,
          children: types.asMap().entries.map((e) {
            final sel = _typeIndex == e.key;
            return GestureDetector(
              onTap: () => setState(() => _typeIndex = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary.withOpacity(0.07) : AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: sel ? AppColors.primaryMid : AppColors.border,
                    width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(e.value.$1, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(e.value.$2,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: sel ? AppColors.primary : AppColors.text2)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Text('Don\'t see yours? Choose Other — you can specify later.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
            color: AppColors.text3, fontWeight: FontWeight.w300)),
      ]),
      onContinue: _next,
      onBack: _back,
    );
  }

  // ── Page 4: Treatment Phase ───────────────────────────────────────────────
  Widget _buildPhase() {
    final phases = [
      'Just diagnosed', 'Awaiting treatment plan', 'In chemotherapy',
      'In radiotherapy', 'Post-surgery recovery', 'Monitoring / surveillance',
    ];
    return _stepScaffold(
      stepLabel: 'Step 4 of 5',
      title: 'Where are you\nin your ',
      titleBold: 'journey?',
      subtitle: 'There\'s no wrong answer.',
      body: Column(children: phases.asMap().entries.map((e) {
        final sel = _phaseIndex == e.key;
        return GestureDetector(
          onTap: () => setState(() => _phaseIndex = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary.withOpacity(0.07) : AppColors.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: sel ? AppColors.primaryMid : AppColors.border,
                width: 0.5),
            ),
            child: Row(children: [
              Container(width: 7, height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? AppColors.primary : AppColors.border)),
              const SizedBox(width: 10),
              Text(e.value,
                style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                  fontWeight: sel ? FontWeight.w500 : FontWeight.w400,
                  color: sel ? AppColors.primary : AppColors.text2)),
              if (sel) ...[
                const Spacer(),
                Text('✓', style: TextStyle(color: AppColors.primary, fontSize: 14)),
              ],
            ]),
          ),
        );
      }).toList()),
      onContinue: _next,
      onBack: _back,
      showSkip: true,
      skipLabel: 'Prefer not to say',
    );
  }

  // ── Page 5: Notifications ─────────────────────────────────────────────────
  Widget _buildNotifications() {
    final notifs = [
      (Icons.notifications_outlined, AppColors.primaryLight, AppColors.primary,
          'Daily check-in reminder', 'A gentle nudge each morning'),
      (Icons.medication_outlined, AppColors.tealLight, AppColors.teal,
          'Medication reminders', 'Never miss a dose'),
      (Icons.calendar_month_outlined, AppColors.peachLight, AppColors.peach,
          'Appointment alerts', 'Reminders 24 hours before'),
    ];
    return _stepScaffold(
      stepLabel: 'Step 5 of 5',
      title: 'One last\n',
      titleBold: 'thing, Nadia',
      subtitle: 'Gentle reminders help you stay consistent.',
      body: Column(children: [
        ...notifs.asMap().entries.map((e) {
          final sel = _notifSelected.contains(e.key);
          return GestureDetector(
            onTap: () => setState(() {
              if (sel) _notifSelected.remove(e.key);
              else _notifSelected.add(e.key);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary.withOpacity(0.06) : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.primaryMid : AppColors.border,
                  width: 0.5),
              ),
              child: Row(children: [
                Container(width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: e.value.$2, borderRadius: BorderRadius.circular(11)),
                  child: Icon(e.value.$1, size: 17, color: e.value.$3)),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.value.$4,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: sel ? AppColors.primary : AppColors.text1)),
                    Text(e.value.$5,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 11,
                        color: AppColors.text2, fontWeight: FontWeight.w300)),
                  ],
                )),
                Container(width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.border,
                      width: 1.5)),
                  child: sel ? const Icon(Icons.check_rounded,
                    size: 10, color: Colors.white) : null),
              ]),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text('You can change these anytime in Settings.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', fontSize: 11,
            color: AppColors.text3, fontWeight: FontWeight.w300)),
      ]),
      onContinue: _next,
      onBack: _back,
      showSkip: true,
      skipLabel: 'Maybe later',
      primaryLabel: 'Enable notifications',
    );
  }

  // ── Page 6: Celebration ──────────────────────────────────────────────────
  Widget _buildCelebration() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppColors.teal.withOpacity(0.18),
              AppColors.primary.withOpacity(0.10),
            ]),
            border: Border.all(
              color: AppColors.teal.withOpacity(0.28), width: 1.5),
            boxShadow: [BoxShadow(
              color: AppColors.teal.withOpacity(0.12), blurRadius: 28)],
          ),
          child: const Center(child: Text('🌿',
            style: TextStyle(fontSize: 30))),
        ),
        const SizedBox(height: 20),
        const Text('Your journey is ready,',
          style: TextStyle(fontFamily: 'Inter', fontSize: 15,
            fontWeight: FontWeight.w300, color: AppColors.text2)),
        const SizedBox(height: 4),
        const Text('Nadia',
          style: TextStyle(fontFamily: 'Inter', fontSize: 26,
            fontWeight: FontWeight.w700, color: AppColors.primary,
            letterSpacing: -0.5)),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Everything is personalised for your breast cancer journey. We\'re here every step of the way.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w300, color: AppColors.text2, height: 1.7),
          ),
        ),
        const SizedBox(height: 28),
        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(children: [
            _celebStat('12', 'Weeks planned'),
            const SizedBox(width: 8),
            _celebStat('3', 'Meds to add'),
            const SizedBox(width: 8),
            _celebStat('💜', 'Community'),
          ]),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3DB87A), Color(0xFF2A9060)]),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [BoxShadow(
                  color: AppColors.teal.withOpacity(0.3),
                  blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Center(child: Text('Go to my dashboard',
                style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                  fontWeight: FontWeight.w500, color: Colors.white))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _celebStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(fontFamily: 'Inter',
            fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.text1)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Inter',
            fontSize: 9, color: AppColors.text3,
            letterSpacing: 0.04), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  // ── Shared step scaffold ─────────────────────────────────────────────────
  Widget _stepScaffold({
    required String stepLabel,
    required String title,
    required String titleBold,
    required String subtitle,
    required Widget body,
    required VoidCallback onContinue,
    required VoidCallback onBack,
    bool showSkip = false,
    String skipLabel = 'Skip',
    String primaryLabel = 'Continue',
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: onBack,
          child: Row(children: [
            Icon(Icons.arrow_back_ios_new_rounded, size: 15,
              color: AppColors.text2.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text('Back', style: TextStyle(fontFamily: 'Inter',
              fontSize: 12, color: AppColors.text2)),
          ]),
        ),
        const SizedBox(height: 14),
        Text(stepLabel.toUpperCase(),
          style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
            fontWeight: FontWeight.w600, letterSpacing: 0.07,
            color: AppColors.text3)),
        const SizedBox(height: 8),
        RichText(text: TextSpan(
          style: const TextStyle(fontFamily: 'Inter', fontSize: 22,
            fontWeight: FontWeight.w300, color: AppColors.text1,
            letterSpacing: -0.3, height: 1.2),
          children: [
            TextSpan(text: title),
            TextSpan(text: titleBold,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        )),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(fontFamily: 'Inter',
          fontSize: 13, color: AppColors.text2,
          fontWeight: FontWeight.w300, height: 1.6)),
        const SizedBox(height: 18),
        body,
        const SizedBox(height: 20),
        _primaryButton(primaryLabel, onContinue),
        if (showSkip) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onContinue,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(child: Text(skipLabel,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                  color: AppColors.text3))),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Center(child: Text(label,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 15,
            fontWeight: FontWeight.w500, color: Colors.white))),
      ),
    );
  }
}
