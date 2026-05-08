import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/invite_codes.dart';
import '../../../../core/services/supabase_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _codeController = TextEditingController();
  bool _showCodeInput = false;
  String? _errorMessage;
  InviteProfile? _validatedProfile;   // demo / hardcoded codes
  Map<String, dynamic>? _supabaseData; // real patient from Supabase
  bool _isValidating = false;
  bool _isApplying = false;

  @override
  void dispose() { _codeController.dispose(); super.dispose(); }

  bool get _hasValidCode => _validatedProfile != null || _supabaseData != null;

  // ── Validation: Supabase first, demo codes as fallback ───────────────────
  Future<void> _validateCode(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;
    setState(() {
      _isValidating = true;
      _errorMessage = null;
      _supabaseData = null;
      _validatedProfile = null;
    });

    // 1. Try Supabase (real patient)
    if (SupabaseService.isAvailable) {
      final data = await SupabaseService.validateInviteCode(trimmed);
      if (!mounted) return;
      // Guard against stale result if user kept typing
      if (_codeController.text.trim().toUpperCase() == trimmed && data != null) {
        setState(() { _isValidating = false; _supabaseData = data; });
        return;
      }
    }

    // 2. Fallback: demo invite codes (always work offline)
    if (!mounted) return;
    final profile = InviteCodes.validate(trimmed);
    setState(() {
      _isValidating = false;
      _validatedProfile = profile;
      _errorMessage = profile == null
          ? 'Code not recognised. Check with your care team or set up manually.'
          : null;
    });
  }

  // ── Continue button ───────────────────────────────────────────────────────
  Future<void> _continueWithCode() async {
    if (_isApplying) return;
    if (_supabaseData != null) {
      await _applySupabaseData(_supabaseData!);
    } else if (_validatedProfile != null) {
      InviteCodes.apply(_validatedProfile!);
      if (mounted) context.go('/');
    }
  }

  Future<void> _applySupabaseData(Map<String, dynamic> data) async {
    setState(() => _isApplying = true);
    try {
      await SupabaseService.applyPatientToSession(data);

      final patientId = data['id'] as String;
      // Persist for session recovery on next launch
      SharedPreferences.getInstance()
          .then((p) => p.setString('rehlah_patient_id', patientId));
      // Mark code as used — fire-and-forget
      SupabaseService.activatePatient(patientId); // ignore: unawaited_futures

      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  void _setupManually() => context.go('/onboarding');

  void _loadDemo() {
    final profile = InviteCodes.validate('DEMO');
    if (profile != null) {
      InviteCodes.apply(profile);
      context.go('/');
    }
  }

  void _showCaregiverEntry() {
    final ctrl = TextEditingController();
    String? error;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20,
              MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.border,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('I\'M A CAREGIVER',
              style: AppText.label.copyWith(fontSize: 10)),
            const SizedBox(height: 8),
            Text('Enter the code shared by your patient.',
              style: AppText.bodySecondary),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 16,
                letterSpacing: 1.5, color: AppColors.text1),
              decoration: InputDecoration(
                hintText: 'CARE-XXXXX',
                hintStyle: TextStyle(
                  color: AppColors.text3, letterSpacing: 1),
                filled: true, fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.border, width: 0.5)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.border, width: 0.5)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.primaryMid, width: 1.5)),
                errorText: error),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                final code = ctrl.text.trim().toUpperCase();
                final careCode = InviteCodes.validateCaregiverCode(code);
                if (careCode == null) {
                  setS(() => error =
                      'Code not recognised. Ask your patient for their caregiver code.');
                } else {
                  InviteCodes.applyAsCaregiver(careCode);
                  Navigator.pop(context);
                  context.go('/caregiver');
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: AppRadius.fullBR,
                  boxShadow: [BoxShadow(
                    color: AppColors.teal.withOpacity(0.25),
                    blurRadius: 10, offset: const Offset(0, 3))]),
                child: const Center(child: Text('Connect',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                    fontWeight: FontWeight.w500, color: Colors.white))))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        Positioned(top: -80, right: -60,
          child: Container(width: 240, height: 240,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withOpacity(0.13), Colors.transparent])))),
        Positioned(bottom: 80, left: -40,
          child: Container(width: 180, height: 180,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.teal.withOpacity(0.09), Colors.transparent])))),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment(-0.6, -0.8), end: Alignment(1, 1),
                      colors: [Color(0xFFDDD4F5), Color(0xFFCCC0EC),
                               Color(0xFFD8CCEE), Color(0xFFE8D4E0)]),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8), width: 0.5),
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.22),
                      blurRadius: 32, offset: const Offset(0, 12))],
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                    size: 30, color: AppColors.primary),
                ),
                const SizedBox(height: 18),

                const Text('Rehlah',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 30,
                    fontWeight: FontWeight.w300, color: AppColors.text1,
                    letterSpacing: 0.02)),
                const SizedBox(height: 4),
                const Text('رحلة · Your journey',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                    color: AppColors.text2, fontWeight: FontWeight.w300)),
                const SizedBox(height: 8),
                const Text(
                  'A companion for every step\nof your cancer journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                    color: AppColors.text3, fontWeight: FontWeight.w300,
                    height: 1.6)),

                const SizedBox(height: 40),

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 280),
                  crossFadeState: _showCodeInput
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: _buildCodePrompt(),
                  secondChild: _buildCodeInput(),
                ),

                const SizedBox(height: 20),

                Row(children: [
                  Expanded(child: Divider(
                    color: AppColors.border, thickness: 0.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: AppColors.text3))),
                  Expanded(child: Divider(
                    color: AppColors.border, thickness: 0.5)),
                ]),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _setupManually,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.border, width: 0.5)),
                    child: Column(children: [
                      const Text('Set up manually',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text1)),
                      const SizedBox(height: 2),
                      Text('Fill in your own information',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                          color: AppColors.text3,
                          fontWeight: FontWeight.w300)),
                    ]),
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: _showCaregiverEntry,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: AppColors.teal.withOpacity(0.2), width: 0.5)),
                    child: Column(children: [
                      Text('I\'m a caregiver',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.teal)),
                      const SizedBox(height: 2),
                      Text('Enter the code shared by your patient',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                          color: AppColors.teal.withOpacity(0.6),
                          fontWeight: FontWeight.w300)),
                    ]),
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: _loadDemo,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: Text('Explore with sample data →',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13,
                        color: AppColors.text3,
                        fontWeight: FontWeight.w300))),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  '🔒 Your data stays yours. Rehlah never sells your health information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                    color: AppColors.text3, fontWeight: FontWeight.w300,
                    height: 1.6)),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCodePrompt() {
    return GestureDetector(
      onTap: () => setState(() => _showCodeInput = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          const Text('I have an invite code',
            style: TextStyle(fontFamily: 'Inter', fontSize: 15,
              fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 2),
          Text('From my care team or hospital',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              color: Colors.white.withOpacity(0.65),
              fontWeight: FontWeight.w300)),
        ]),
      ),
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          GestureDetector(
            onTap: () => setState(() {
              _showCodeInput = false;
              _validatedProfile = null;
              _supabaseData = null;
              _errorMessage = null;
              _codeController.clear();
            }),
            child: Row(children: [
              Icon(Icons.arrow_back_ios_new_rounded, size: 13,
                color: AppColors.text2.withOpacity(0.4)),
              const SizedBox(width: 4),
              Text('Back', style: TextStyle(fontFamily: 'Inter',
                fontSize: 12, color: AppColors.text2)),
            ]),
          ),
          const Spacer(),
        ]),
        const SizedBox(height: 12),

        Text('ENTER YOUR INVITE CODE',
          style: TextStyle(fontFamily: 'Inter', fontSize: 10,
            fontWeight: FontWeight.w600, letterSpacing: 0.07,
            color: AppColors.text3)),
        const SizedBox(height: 8),

        TextField(
          controller: _codeController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 15,
            letterSpacing: 0.05, color: AppColors.text1,
            fontWeight: FontWeight.w500),
          onChanged: (v) {
            setState(() {
              _validatedProfile = null;
              _supabaseData = null;
              _errorMessage = null;
            });
            if (v.trim().length >= 4) _validateCode(v);
          },
          onSubmitted: _validateCode,
          decoration: InputDecoration(
            hintText: 'e.g. REHLAH-ACT-001 or ABC-1234',
            hintStyle: const TextStyle(color: AppColors.text3,
              fontWeight: FontWeight.w300, letterSpacing: 0),
            filled: true,
            fillColor: AppColors.surface,
            suffixIcon: _isValidating
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary)))
                : _hasValidCode
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.teal, size: 20)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColors.border, width: 0.5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: _hasValidCode
                    ? AppColors.teal
                    : AppColors.primaryMid,
                width: 1.5)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: AppColors.rose.withOpacity(0.5), width: 1)),
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(_errorMessage!,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
              color: AppColors.rose, fontWeight: FontWeight.w300,
              height: 1.5)),
        ],

        // ── Validated profile preview ──────────────────────────────────────
        if (_hasValidCode) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.teal.withOpacity(0.25), width: 0.5)),
            child: Row(children: [
              Text(
                _supabaseData != null ? '🏥' : _validatedProfile!.scenarioEmoji,
                style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${_supabaseData?['name'] ?? _validatedProfile!.name}',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppColors.text1)),
                  const SizedBox(height: 2),
                  Text(
                    _supabaseData != null
                      ? '${_supabaseData!['diagnosis'] ?? 'Breast cancer'} · '
                        'Cycle ${_supabaseData!['cycle_number']} of '
                        '${_supabaseData!['total_cycles']}'
                      : _validatedProfile!.scenarioLabel,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                      color: AppColors.teal, fontWeight: FontWeight.w400,
                      height: 1.4)),
                ],
              )),
              const Icon(Icons.check_circle_rounded,
                color: AppColors.teal, size: 22),
            ]),
          ),
        ],

        const SizedBox(height: 16),

        // ── Continue button ────────────────────────────────────────────────
        GestureDetector(
          onTap: _hasValidCode && !_isApplying
              ? () => _continueWithCode()
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _hasValidCode && !_isApplying
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(13),
              boxShadow: _hasValidCode && !_isApplying ? [BoxShadow(
                color: AppColors.primary.withOpacity(0.30),
                blurRadius: 14, offset: const Offset(0, 4))] : null),
            child: _isApplying
              ? const Center(child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)))
              : const Center(child: Text('Continue with code →',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                    fontWeight: FontWeight.w500, color: Colors.white))),
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: () => _showTestCodes(context),
          child: Center(child: Text('View test codes ↗',
            style: TextStyle(fontFamily: 'Inter', fontSize: 11,
              color: AppColors.text3.withOpacity(0.6),
              decoration: TextDecoration.underline,
              decorationColor: AppColors.text3.withOpacity(0.4)))),
        ),
      ],
    );
  }

  void _showTestCodes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('TEST CODES', style: TextStyle(fontFamily: 'Inter',
              fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 0.08, color: AppColors.text3)),
            const SizedBox(height: 12),
            ...InviteCodes.all.map((p) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _codeController.text = p.code;
                _validateCode(p.code);
                setState(() => _showCodeInput = true);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.5)),
                child: Row(children: [
                  Text(p.scenarioEmoji,
                    style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.code,
                        style: const TextStyle(fontFamily: 'Inter',
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                      Text(p.scenarioLabel,
                        style: const TextStyle(fontFamily: 'Inter',
                          fontSize: 11, color: AppColors.text2,
                          fontWeight: FontWeight.w300)),
                    ],
                  )),
                  const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.text3),
                ]),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
