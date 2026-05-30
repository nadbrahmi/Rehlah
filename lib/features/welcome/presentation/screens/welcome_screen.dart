import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/rehlah_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/invite_codes.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/user_session.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _codeController = TextEditingController();
  bool _showCodeInput = false;
  String? _errorMessage;
  InviteProfile? _validatedProfile;
  Map<String, dynamic>? _supabaseData;
  bool _isValidating = false;
  bool _isApplying = false;
  late String _language;
  int _validationEpoch = 0;

  @override
  void initState() {
    super.initState();
    _language = UserSession().language;
  }

  void _setLanguage(String lang) {
    setState(() => _language = lang);
    UserSession().language = lang;
  }

  @override
  void dispose() { _codeController.dispose(); super.dispose(); }

  bool get _hasValidCode => _validatedProfile != null || _supabaseData != null;

  Future<void> _validateCode(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;
    final epoch = ++_validationEpoch;
    setState(() {
      _isValidating = true;
      _errorMessage = null;
      _supabaseData = null;
      _validatedProfile = null;
    });

    if (SupabaseService.isAvailable) {
      final data = await SupabaseService.validateInviteCode(trimmed);
      if (!mounted || epoch != _validationEpoch) return;
      if (data != null) {
        setState(() { _isValidating = false; _supabaseData = data; });
        return;
      }
    }

    if (!mounted || epoch != _validationEpoch) return;
    final profile = InviteCodes.validate(trimmed);
    setState(() {
      _isValidating = false;
      _validatedProfile = profile;
      _errorMessage = profile == null
          ? 'Code not recognised. Check with your care team or set up manually.'
          : null;
    });
  }

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
      SharedPreferences.getInstance()
          .then((p) => p.setString('rehlah_patient_id', patientId));
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
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20,
              MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: RColors.sand200,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('I\'M A CAREGIVER', style: RText.eyebrow),
            const SizedBox(height: 8),
            Text('Enter the code shared by your patient.', style: RText.bodyMuted),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: RText.body.copyWith(fontSize: 16, letterSpacing: 1.5),
              decoration: InputDecoration(
                hintText: 'CARE-XXXXX',
                hintStyle: RText.small.copyWith(
                  color: RColors.sand400, letterSpacing: 1),
                filled: true, fillColor: RColors.sand50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: RColors.sand200, width: 0.5)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: RColors.sand200, width: 0.5)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: RColors.teal200, width: 1.5)),
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
                decoration: const BoxDecoration(
                  color: RColors.teal700,
                  borderRadius: RRadius.pillBR,
                  boxShadow: RShadow.shadow2),
                child: const Center(child: Text('Connect',
                  style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w500, color: Colors.white))))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.sand50,
      body: Stack(children: [
        Positioned(top: -80, right: -60,
          child: Container(width: 240, height: 240,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                RColors.teal200.withValues(alpha: 0.18), Colors.transparent])))),
        Positioned(bottom: 80, left: -40,
          child: Container(width: 180, height: 180,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                RColors.saffron300.withValues(alpha: 0.12), Colors.transparent])))),

        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                _languagePicker(),
                const SizedBox(height: 28),

                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment(-0.6, -0.8), end: Alignment(1, 1),
                      colors: [RColors.teal200, RColors.teal500,
                               RColors.teal600, RColors.teal700]),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8), width: 0.5),
                    boxShadow: RShadow.shadow3,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                    size: 30, color: Colors.white),
                ),
                const SizedBox(height: 18),

                Text('Rehlah',
                  style: RText.h1.copyWith(fontWeight: FontWeight.w300)),
                const SizedBox(height: 4),
                Text('رحلة · Your journey',
                  style: RText.body.copyWith(
                    color: RColors.sand700, fontWeight: FontWeight.w300)),
                const SizedBox(height: 8),
                Text(
                  'A companion for every step\nof your cancer journey',
                  textAlign: TextAlign.center,
                  style: RText.bodyMuted.copyWith(
                    fontWeight: FontWeight.w300, height: 1.6)),

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
                  const Expanded(child: Divider(
                    color: RColors.sand200, thickness: 0.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or',
                      style: RText.small.copyWith(color: RColors.sand400, fontSize: 12))),
                  const Expanded(child: Divider(
                    color: RColors.sand200, thickness: 0.5)),
                ]),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _setupManually,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: RColors.surface,
                      borderRadius: RRadius.mdBR,
                      boxShadow: RShadow.shadow1,
                      border: Border.all(color: RColors.sand200, width: 0.5)),
                    child: Column(children: [
                      Text('Set up manually',
                        style: RText.body.copyWith(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('Fill in your own information',
                        style: RText.small.copyWith(
                          color: RColors.sand400, fontWeight: FontWeight.w300)),
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
                      color: RColors.teal50,
                      borderRadius: RRadius.mdBR,
                      border: Border.all(
                        color: RColors.teal200.withValues(alpha: 0.5), width: 0.5)),
                    child: Column(children: [
                      Text('I\'m a caregiver',
                        style: RText.body.copyWith(
                          fontWeight: FontWeight.w500, color: RColors.teal700)),
                      const SizedBox(height: 2),
                      Text('Enter the code shared by your patient',
                        style: RText.small.copyWith(
                          color: RColors.teal600.withValues(alpha: 0.7),
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
                      style: RText.bodyMuted.copyWith(fontWeight: FontWeight.w300))),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  '🔒 Your data stays yours. Rehlah never sells your health information.',
                  textAlign: TextAlign.center,
                  style: RText.small.copyWith(
                    color: RColors.sand400, fontWeight: FontWeight.w300,
                    height: 1.6)),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _languagePicker() {
    return Row(children: [
      Expanded(
        child: GestureDetector(
          onTap: () => _setLanguage('en'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: _language == 'en' ? RColors.teal700 : RColors.surface,
              borderRadius: RRadius.mdBR,
              border: Border.all(
                color: _language == 'en' ? RColors.teal700 : RColors.sand200),
            ),
            child: Center(
              child: Text('English',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _language == 'en' ? Colors.white : RColors.sand700)),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: () => _setLanguage('ar'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: _language == 'ar' ? RColors.teal700 : RColors.surface,
              borderRadius: RRadius.mdBR,
              border: Border.all(
                color: _language == 'ar' ? RColors.teal700 : RColors.sand200),
            ),
            child: Center(
              child: Text('العربية',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _language == 'ar' ? Colors.white : RColors.sand700)),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildCodePrompt() {
    return GestureDetector(
      onTap: () => setState(() => _showCodeInput = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [RColors.teal600, RColors.teal700],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: RRadius.mdBR,
          boxShadow: RShadow.shadow2,
        ),
        child: Column(children: [
          const Text('I have an invite code',
            style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 2),
          Text('From my care team or hospital',
            style: RText.small.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
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
              const Icon(Icons.arrow_back_ios_new_rounded, size: 13,
                color: RColors.sand400),
              const SizedBox(width: 4),
              Text('Back', style: RText.small.copyWith(color: RColors.sand700)),
            ]),
          ),
          const Spacer(),
        ]),
        const SizedBox(height: 12),

        Text('ENTER YOUR INVITE CODE', style: RText.eyebrow),
        const SizedBox(height: 8),

        TextField(
          controller: _codeController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: RText.body.copyWith(fontSize: 15, letterSpacing: 0.05,
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
            hintStyle: RText.small.copyWith(
              color: RColors.sand400, fontWeight: FontWeight.w300, letterSpacing: 0),
            filled: true,
            fillColor: RColors.surface,
            suffixIcon: _isValidating
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: RColors.teal700)))
                : _hasValidCode
                    ? const Icon(Icons.check_circle_rounded,
                        color: RColors.teal600, size: 20)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: RColors.sand200, width: 0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: RColors.sand200, width: 0.5)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _hasValidCode ? RColors.teal600 : RColors.teal200,
                width: 1.5)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: RColors.clay500.withValues(alpha: 0.5), width: 1)),
          ),
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(_errorMessage!,
            style: RText.small.copyWith(
              color: RColors.clay500, fontWeight: FontWeight.w300,
              height: 1.5)),
        ],

        if (_hasValidCode) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: RColors.teal50,
              borderRadius: RRadius.mdBR,
              border: Border.all(
                color: RColors.teal200.withValues(alpha: 0.5), width: 0.5)),
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
                    style: RText.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    _supabaseData != null
                      ? '${_supabaseData!['diagnosis'] ?? 'Breast cancer'} · '
                        'Cycle ${_supabaseData!['cycle_number']} of '
                        '${_supabaseData!['total_cycles']}'
                      : _validatedProfile!.scenarioLabel,
                    style: RText.small.copyWith(
                      color: RColors.teal700, height: 1.4)),
                ],
              )),
              const Icon(Icons.check_circle_rounded,
                color: RColors.teal600, size: 22),
            ]),
          ),
        ],

        const SizedBox(height: 16),

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
                  ? RColors.teal700
                  : RColors.teal200,
              borderRadius: RRadius.mdBR,
              boxShadow: _hasValidCode && !_isApplying ? RShadow.shadow2 : null),
            child: _isApplying
              ? const Center(child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)))
              : const Center(child: Text('Continue with code →',
                  style: TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w500, color: Colors.white))),
          ),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: () => _showTestCodes(context),
          child: Center(child: Text('View test codes ↗',
            style: RText.small.copyWith(
              color: RColors.sand400.withValues(alpha: 0.7),
              decoration: TextDecoration.underline,
              decorationColor: RColors.sand400.withValues(alpha: 0.4)))),
        ),
      ],
    );
  }

  void _showTestCodes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: RColors.sand200,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('TEST CODES', style: RText.eyebrow),
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
                  color: RColors.sand50,
                  borderRadius: RRadius.smBR,
                  border: Border.all(color: RColors.sand200, width: 0.5)),
                child: Row(children: [
                  Text(p.scenarioEmoji,
                    style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.code,
                        style: RText.body.copyWith(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: RColors.teal700)),
                      Text(p.scenarioLabel,
                        style: RText.small.copyWith(
                          color: RColors.sand700, fontWeight: FontWeight.w300)),
                    ],
                  )),
                  const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: RColors.sand400),
                ]),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
