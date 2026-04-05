import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

// ─── AI Lab Analyzer Screen ───────────────────────────────────────────────────
class LabAnalyzerScreen extends StatefulWidget {
  const LabAnalyzerScreen({super.key});
  @override
  State<LabAnalyzerScreen> createState() => _LabAnalyzerScreenState();
}

class _LabAnalyzerScreenState extends State<LabAnalyzerScreen>
    with SingleTickerProviderStateMixin {
  _AnalyzerState _state = _AnalyzerState.idle;
  late final AnimationController _scanCtrl;
  double _scanProgress = 0.0;
  Timer? _scanTimer;
  _AnalysisResult? _result;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _state = _AnalyzerState.scanning;
      _scanProgress = 0.0;
    });

    // Simulate scanning progress
    _scanTimer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _scanProgress = (_scanProgress + 0.025).clamp(0.0, 1.0));
      if (_scanProgress >= 1.0) {
        t.cancel();
        _analyzeReport();
      }
    });
  }

  Future<void> _analyzeReport() async {
    setState(() => _state = _AnalyzerState.analyzing);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _result = _buildSampleResult();
      _state = _AnalyzerState.done;
    });
  }

  _AnalysisResult _buildSampleResult() {
    return _AnalysisResult(
      reportDate: DateTime.now().subtract(const Duration(days: 2)),
      reportType: 'Complete Blood Count + BMP Panel',
      overallStatus: _ResultStatus.needsAttention,
      summary: 'Your CBC shows signs of chemo-related myelosuppression — expected at this stage of treatment. WBC and ANC are low (nadir period). Hemoglobin is mildly reduced. Metabolic panel shows mild liver enzyme elevation, consistent with treatment effects.',
      values: [
        _ParsedValue(name: 'WBC', value: 2.8, unit: '×10³/µL', normalRange: '4.5–11.0', status: _ValueStatus.low, aiNote: 'Low — nadir period. Infection precautions recommended.'),
        _ParsedValue(name: 'ANC', value: 1.1, unit: '×10³/µL', normalRange: '1.5–8.0', status: _ValueStatus.low, aiNote: 'Below normal — moderate neutropenia. Avoid sick contacts.'),
        _ParsedValue(name: 'Hemoglobin', value: 10.8, unit: 'g/dL', normalRange: '12.0–17.5', status: _ValueStatus.low, aiNote: 'Mild anemia — common with chemotherapy. Monitor symptoms.'),
        _ParsedValue(name: 'Platelets', value: 142, unit: '×10³/µL', normalRange: '150–400', status: _ValueStatus.borderline, aiNote: 'Slightly below normal. Avoid cuts and aspirin.'),
        _ParsedValue(name: 'ALT (Liver)', value: 58, unit: 'U/L', normalRange: '7–56', status: _ValueStatus.high, aiNote: 'Mildly elevated. Avoid alcohol. Monitor next draw.'),
        _ParsedValue(name: 'Creatinine', value: 0.9, unit: 'mg/dL', normalRange: '0.6–1.2', status: _ValueStatus.normal, aiNote: 'Normal kidney function. Keep hydrated.'),
        _ParsedValue(name: 'Glucose', value: 112, unit: 'mg/dL', normalRange: '70–100', status: _ValueStatus.high, aiNote: 'Mildly elevated — likely steroid-related. Monitor for symptoms.'),
        _ParsedValue(name: 'Sodium', value: 138, unit: 'mEq/L', normalRange: '136–145', status: _ValueStatus.normal, aiNote: 'Normal electrolyte balance.'),
      ],
      recommendations: [
        _Recommendation(text: 'Take infection precautions — avoid crowds, wash hands frequently', priority: _RecPriority.high, icon: Icons.shield_rounded),
        _Recommendation(text: 'Check temperature daily — call team immediately if ≥38°C (100.4°F)', priority: _RecPriority.high, icon: Icons.thermostat_rounded),
        _Recommendation(text: 'Avoid aspirin/ibuprofen due to low platelets', priority: _RecPriority.medium, icon: Icons.no_meals_rounded),
        _Recommendation(text: 'Limit alcohol to protect liver during elevated ALT period', priority: _RecPriority.medium, icon: Icons.local_bar_rounded),
        _Recommendation(text: 'Rest when fatigued — mild anemia causes real tiredness', priority: _RecPriority.low, icon: Icons.bed_rounded),
        _Recommendation(text: 'Increase fluid intake to 8+ glasses daily for kidney protection', priority: _RecPriority.low, icon: Icons.water_drop_rounded),
      ],
      doctorAlert: 'Share with your oncologist: WBC 2.8 (low), ANC 1.1 (below threshold), ALT mildly elevated at 58.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (_state) {
          _AnalyzerState.idle => _IdleView(onCameraCapture: _startScan, onUpload: _startScan),
          _AnalyzerState.scanning => _ScanningView(progress: _scanProgress, ctrl: _scanCtrl),
          _AnalyzerState.analyzing => _AnalyzingView(ctrl: _scanCtrl),
          _AnalyzerState.done => _ResultView(
              result: _result!,
              onReset: () => setState(() { _state = _AnalyzerState.idle; _result = null; }),
            ),
        },
      ),
    );
  }
}

// ─── Idle / Upload View ────────────────────────────────────────────────────────
class _IdleView extends StatelessWidget {
  final VoidCallback onCameraCapture;
  final VoidCallback onUpload;
  const _IdleView({required this.onCameraCapture, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryDark, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Lab Analyzer',
                        style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text('Instant AI interpretation of lab reports',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                // AI Icon
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.info],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.35),
                        blurRadius: 30, offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text('AI Lab Report Analyzer',
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Text(
                  'Snap a photo or upload your lab report.\nAI will extract all values, compare to normal ranges, and give you a plain-language explanation instantly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 32),

                // Feature chips
                Wrap(
                  spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                  children: [
                    _FeatureChip(Icons.auto_awesome_rounded, 'Instant Analysis'),
                    _FeatureChip(Icons.translate_rounded, 'Plain Language'),
                    _FeatureChip(Icons.warning_amber_rounded, 'Alerts'),
                    _FeatureChip(Icons.medical_information_rounded, 'All Lab Types'),
                  ],
                ),

                const SizedBox(height: 40),

                // Upload options
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onCameraCapture,
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryDark, AppColors.info],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryDark.withValues(alpha: 0.35),
                                blurRadius: 16, offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt_rounded, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Take Photo', style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: onUpload,
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.upload_file_rounded, color: AppColors.primaryDark),
                              const SizedBox(width: 8),
                              Text('Upload PDF', style: GoogleFonts.inter(
                                  color: AppColors.primaryDark, fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, color: AppColors.info, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Your report is analyzed privately and never stored.',
                            style: TextStyle(fontSize: 11, color: AppColors.info)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(
              fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Scanning View ─────────────────────────────────────────────────────────────
class _ScanningView extends StatelessWidget {
  final double progress;
  final AnimationController ctrl;
  const _ScanningView({required this.progress, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final stages = [
      'Detecting document edges...',
      'Extracting text and numbers...',
      'Identifying lab values...',
      'Comparing to reference ranges...',
      'Generating AI insights...',
    ];
    final stageIdx = (progress * stages.length).clamp(0, stages.length - 1).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mock document with scan line
            Container(
              width: 220, height: 280,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    // Fake document lines
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 140, height: 10, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(height: 8),
                          Container(width: 100, height: 8, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(height: 16),
                          ...List.generate(8, (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              Container(width: 60 + (i % 3) * 20.0, height: 8, decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4))),
                              const Spacer(),
                              Container(width: 40, height: 8, decoration: BoxDecoration(
                                color: i % 3 == 0 ? AppColors.dangerLight : (i % 3 == 1 ? AppColors.accentLight : AppColors.divider),
                                borderRadius: BorderRadius.circular(4),
                              )),
                            ]),
                          )),
                        ],
                      ),
                    ),
                    // Animated scan line
                    AnimatedBuilder(
                      animation: ctrl,
                      builder: (_, __) {
                        final y = ctrl.value * 280;
                        return Positioned(
                          top: y,
                          left: 0, right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary.withValues(alpha: 0.8),
                                  AppColors.primary,
                                  AppColors.primary.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Scanning Report', style: GoogleFonts.inter(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(stages[stageIdx],
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

// ─── Analyzing View ───────────────────────────────────────────────────────────
class _AnalyzingView extends StatelessWidget {
  final AnimationController ctrl;
  const _AnalyzingView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Parsing extracted values',
      'Matching to reference databases',
      'Identifying clinical concerns',
      'Generating plain-language summary',
      'Creating personalized recommendations',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.info]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: AnimatedBuilder(
                animation: ctrl,
                builder: (_, child) => Transform.rotate(
                  angle: ctrl.value * 2 * pi,
                  child: child,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 24),
            Text('AI is Analyzing...', style: GoogleFonts.inter(
                fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Using medical knowledge to interpret your results',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 32),
            ...steps.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: AppColors.accent, size: 12),
                  ),
                  const SizedBox(width: 10),
                  Text(s, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Results View ─────────────────────────────────────────────────────────────
class _ResultView extends StatelessWidget {
  final _AnalysisResult result;
  final VoidCallback onReset;
  const _ResultView({required this.result, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (result.overallStatus) {
      _ResultStatus.good => AppColors.accent,
      _ResultStatus.needsAttention => AppColors.warning,
      _ResultStatus.urgent => AppColors.danger,
    };
    final statusLabel = switch (result.overallStatus) {
      _ResultStatus.good => 'Looking Good',
      _ResultStatus.needsAttention => 'Needs Attention',
      _ResultStatus.urgent => 'Urgent – Contact Team',
    };
    final statusIcon = switch (result.overallStatus) {
      _ResultStatus.good => Icons.check_circle_rounded,
      _ResultStatus.needsAttention => Icons.warning_amber_rounded,
      _ResultStatus.urgent => Icons.error_rounded,
    };

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryDark, size: 15),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('AI Analysis Results',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
              GestureDetector(
                onTap: onReset,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
                  child: Text('Scan New', style: TextStyle(
                      fontSize: 12, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall status card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: Icon(statusIcon, color: statusColor, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(statusLabel, style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.w800, color: statusColor)),
                            Text(result.reportType,
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            Text('Report date: ${result.reportDate.month}/${result.reportDate.day}/${result.reportDate.year}',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // AI Summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark.withValues(alpha: 0.08),
                        AppColors.info.withValues(alpha: 0.05)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryDark, size: 16),
                          const SizedBox(width: 6),
                          Text('AI Summary', style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(result.summary,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Values table
                Text('Extracted Values', style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                ...result.values.map((v) => _ValueRow(value: v)),

                const SizedBox(height: 16),

                // Recommendations
                Text('AI Recommendations', style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                ...result.recommendations.map((r) => _RecommendationCard(rec: r)),

                const SizedBox(height: 16),

                // Doctor alert
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services_rounded, color: AppColors.danger, size: 16),
                          const SizedBox(width: 6),
                          Text('Share with Your Oncologist', style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(result.doctorAlert,
                          style: TextStyle(fontSize: 12, color: AppColors.danger, height: 1.4)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  '⚕️ Disclaimer: This AI analysis is for educational purposes only. Always discuss lab results with your healthcare provider. Do not make medical decisions based solely on this analysis.',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  final _ParsedValue value;
  const _ValueRow({required this.value});

  @override
  Widget build(BuildContext context) {
    final c = switch (value.status) {
      _ValueStatus.normal => AppColors.accent,
      _ValueStatus.borderline => AppColors.warning,
      _ValueStatus.low => AppColors.info,
      _ValueStatus.high => AppColors.danger,
    };
    final label = switch (value.status) {
      _ValueStatus.normal => 'Normal',
      _ValueStatus.borderline => 'Borderline',
      _ValueStatus.low => 'Low',
      _ValueStatus.high => 'High',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value.name, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(value.aiNote,
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${value.value} ${value.unit}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(label, style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w800, color: c)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final _Recommendation rec;
  const _RecommendationCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final c = switch (rec.priority) {
      _RecPriority.high => AppColors.danger,
      _RecPriority.medium => AppColors.warning,
      _RecPriority.low => AppColors.accent,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(rec.icon, color: c, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(rec.text,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────
enum _AnalyzerState { idle, scanning, analyzing, done }
enum _ResultStatus { good, needsAttention, urgent }
enum _ValueStatus { normal, borderline, low, high }
enum _RecPriority { high, medium, low }

class _AnalysisResult {
  final DateTime reportDate;
  final String reportType;
  final _ResultStatus overallStatus;
  final String summary;
  final List<_ParsedValue> values;
  final List<_Recommendation> recommendations;
  final String doctorAlert;
  const _AnalysisResult({
    required this.reportDate, required this.reportType,
    required this.overallStatus, required this.summary,
    required this.values, required this.recommendations,
    required this.doctorAlert,
  });
}

class _ParsedValue {
  final String name, unit, normalRange, aiNote;
  final double value;
  final _ValueStatus status;
  const _ParsedValue({
    required this.name, required this.value, required this.unit,
    required this.normalRange, required this.status, required this.aiNote,
  });
}

class _Recommendation {
  final String text;
  final _RecPriority priority;
  final IconData icon;
  const _Recommendation({required this.text, required this.priority, required this.icon});
}
