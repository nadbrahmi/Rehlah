import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final PageController _page = PageController();
  int _step = 0;

  // T2 state
  int? _selectedMoodIndex;
  final List<String> _challenges = [];
  final _noteCtrl = TextEditingController();

  // T3 state
  double _fatigue = 5;
  double _pain = 3;
  double _nausea = 4;
  double _sleep = 6;
  double _water = 4;
  bool _tookMeds = true;

  void _next() {
    if (_step == 0) {
      _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _step = 1);
    } else {
      _finish();
    }
  }

  void _finish() {
    final provider = context.read<AppProvider>();
    final isAr = provider.isArabic;
    final moodLabels = isAr
        ? ['صعب جداً', 'صعب', 'عادي', 'جيد', 'ممتاز']
        : ['Very hard', 'Hard', 'Okay', 'Good', 'Great'];
    final mood =
        _selectedMoodIndex != null ? moodLabels[_selectedMoodIndex!] : (isAr ? 'عادي' : 'Okay');
    provider.completeCheckin(mood, List.from(_challenges));
    _page.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _step = 2);
  }

  // Determine highest symptom for insight card
  String _topSymptom() {
    final scores = {
      'fatigue': _fatigue,
      'nausea': _nausea,
      'pain': _pain,
    };
    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAr = provider.isArabic;
    // Hide bottom nav: full-screen scaffold with no navigation
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: PageView(
            controller: _page,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildT2(isAr),
              _buildT3(isAr),
              _buildT4(isAr),
            ],
          ),
        ),
      ),
    );
  }

  // ── T2 — Quick check-in ───────────────────────────────────────────────────
  Widget _buildT2(bool isAr) {
    final l = AppLocalizations(isArabic: isAr);
    final moods = [
      ('😔', l.moodLabels[0]),
      ('😕', l.moodLabels[1]),
      ('😐', l.moodLabels[2]),
      ('🙂', l.moodLabels[3]),
      ('😊', l.moodLabels[4]),
    ];
    final challengeOptions = isAr
        ? ['الإرهاق', 'الغثيان', 'الألم', 'ضعف النوم', 'قلة الشهية', 'القلق']
        : ['Fatigue', 'Nausea', 'Pain', 'Poor sleep', 'Low appetite', 'Anxiety'];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button + progress
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const Spacer(),
              _ProgressDots(step: 0, total: 2),
              const Spacer(),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l.checkinMoodLabel,
            style: GoogleFonts.almarai(
                fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 28),

          // Mood emojis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(moods.length, (i) {
              final selected = _selectedMoodIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedMoodIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.elasticOut,
                  width: selected ? 60 : 48,
                  height: selected ? 60 : 48,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryLight : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(moods[i].$1, style: TextStyle(fontSize: selected ? 36 : 28)),
                  ),
                ),
              );
            }),
          ),
          if (_selectedMoodIndex != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  moods[_selectedMoodIndex!].$2,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Challenges
          Text(
            l.checkinChallenges,
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: challengeOptions.map((c) {
              final sel = _challenges.contains(c);
              return GestureDetector(
                onTap: () => setState(() {
                  sel ? _challenges.remove(c) : _challenges.add(c);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryLight : AppColors.surface,
                    border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: sel ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Optional note
          TextField(
            controller: _noteCtrl,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: l.checkinNoteHint,
              hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedMoodIndex != null ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _selectedMoodIndex != null ? AppColors.primary : AppColors.border,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: Text(
                isAr ? 'متابعة' : 'Continue',
                style: GoogleFonts.almarai(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── T3 — Detailed check-in ────────────────────────────────────────────────
  Widget _buildT3(bool isAr) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _page.previousPage(
                      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  setState(() => _step = 0);
                },
                child: Icon(
                  isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const Spacer(),
              _ProgressDots(step: 1, total: 2),
              const Spacer(),
              const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            isAr ? 'تفاصيل إضافية (اختياري)' : 'Additional details (optional)',
            style: GoogleFonts.almarai(
                fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _SliderRow(
                    isAr ? 'الإرهاق' : 'Fatigue',
                    _fatigue,
                    0,
                    10,
                    (v) => setState(() => _fatigue = v)),
                _SliderRow(
                    isAr ? 'الألم' : 'Pain', _pain, 0, 10, (v) => setState(() => _pain = v)),
                _SliderRow(
                    isAr ? 'الغثيان' : 'Nausea',
                    _nausea,
                    0,
                    10,
                    (v) => setState(() => _nausea = v)),
                _SliderRow(
                    isAr ? 'النوم' : 'Sleep',
                    _sleep,
                    0,
                    10,
                    (v) => setState(() => _sleep = v)),
                _SliderRow(
                    isAr ? 'شرب الماء (أكواب)' : 'Water (cups)',
                    _water,
                    0,
                    8,
                    (v) => setState(() => _water = v)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? 'تناولتِ أدويتي اليوم' : 'Took my medications today',
                      style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
                    ),
                    Switch(
                      value: _tookMeds,
                      onChanged: (v) => setState(() => _tookMeds = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _finish,
            child: Center(
              child: Text(
                isAr ? 'تخطّي' : 'Skip',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _finish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: Text(
                isAr ? 'أنهي التسجيل' : 'Complete check-in',
                style: GoogleFonts.almarai(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── T4 — Success ─────────────────────────────────────────────────────────
  Widget _buildT4(bool isAr) {
    return _SuccessScreen(isArabic: isAr, topSymptom: _topSymptom());
  }
}

// ── Success Screen ────────────────────────────────────────────────────────────
class _SuccessScreen extends StatefulWidget {
  final bool isArabic;
  final String topSymptom;
  const _SuccessScreen({this.isArabic = false, required this.topSymptom});

  @override
  State<_SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<_SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = Tween(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _insightTitle(String symptom, bool isAr) {
    switch (symptom) {
      case 'fatigue':
        return isAr ? 'الإرهاق مرتفع اليوم' : 'Fatigue is high today';
      case 'nausea':
        return isAr ? 'الغثيان مرتفع اليوم' : 'Nausea is elevated today';
      case 'pain':
        return isAr ? 'الألم مرتفع اليوم' : 'Pain is elevated today';
      default:
        return isAr ? 'ملاحظة لهذا اليوم' : 'Insight for today';
    }
  }

  String _insightBody(String symptom, bool isAr) {
    switch (symptom) {
      case 'fatigue':
        return isAr
            ? 'الإرهاق شائع في اليوم ٧. حاولي الراحة الآن — حتى قيلولة قصيرة ٢٠ دقيقة تساعد على التعافي.'
            : 'Fatigue is common on Day 7. Try to rest now — even a 20-minute nap can help recovery.';
      case 'nausea':
        return isAr
            ? 'الغثيان شائع في منتصف الدورة. الوجبات الصغيرة المتكررة والزنجبيل قد يساعدان.'
            : 'Nausea is common mid-cycle. Small frequent meals and ginger may help.';
      case 'pain':
        return isAr
            ? 'إذا كان الألم شديداً أو مفاجئاً، تواصلي مع فريقكِ الطبي.'
            : 'If pain is severe or sudden, contact your care team.';
      default:
        return isAr
            ? 'استمري في تسجيل حالكِ يومياً لمتابعة تطورك.'
            : 'Keep logging daily to track your progress.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (_, provider, __) {
      final isAr = widget.isArabic || provider.isArabic;
      return Scaffold(
        backgroundColor: AppColors.teal,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      isAr
                          ? 'شكراً لكِ، ${provider.userName} ✓'
                          : 'Thank you, ${provider.userName} ✓',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.almarai(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr
                          ? 'كل يوم تسجّلين فيه هو خطوة للأمام.'
                          : 'Every day you check in is a step forward.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: 32),

                    // Insight card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isAr ? 'رؤية لهذا اليوم' : 'Today\'s insight',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _insightTitle(widget.topSymptom, isAr),
                            style: GoogleFonts.almarai(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _insightBody(widget.topSymptom, isAr),
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      isAr
                          ? 'العودة للرئيسية خلال ٥ ثوانٍ...'
                          : 'Returning to home in 5 seconds...',
                      style: TextStyle(
                          fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _ProgressDots extends StatelessWidget {
  final int step;
  final int total;
  const _ProgressDots({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          total,
          (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == step ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == step ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  const _SliderRow(this.label, this.value, this.min, this.max, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primary,
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: max.toInt(),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              value.toInt().toString(),
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
