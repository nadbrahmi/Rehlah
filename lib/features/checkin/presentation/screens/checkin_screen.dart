import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';
import '../../../../core/services/supabase_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _session = UserSession();
  late List<ProtocolSymptom> _primarySymptoms;

  int? _moodIndex;
  bool? _interferenceAnswer;
  final Map<String, double> _scores = {};
  final TextEditingController _notesCtrl = TextEditingController();
  late final bool _isEditing;

  static const _moodEmojis = ['😣', '😔', '😐', '🙂', '😊'];
  static const _moodLabels = ['Awful', 'Low', 'Okay', 'Good', 'Great'];

  @override
  void initState() {
    super.initState();
    _isEditing = _session.checkedInToday;

    if (_session.isMonitoring) {
      _primarySymptoms = _session.isScanxietyPeriod
          ? MonitoringSymptomLibrary.scanxietySymptoms
          : MonitoringSymptomLibrary.standardSymptoms;
    } else {
      _primarySymptoms = _session.currentPhase.primarySymptoms;
    }
    for (final s in _primarySymptoms) {
      _scores[s.key] = 0.0;
    }

    if (_isEditing && _session.moodEmoji.isNotEmpty) {
      final idx = _moodEmojis.indexOf(_session.moodEmoji);
      if (idx >= 0) _moodIndex = idx;
      for (final key in _scores.keys) {
        final v = _session.symptomScores[key];
        if (v != null) _scores[key] = v;
      }
      _notesCtrl.text = _session.checkInNote;
      if (_session.interferenceAnswers.containsKey('general')) {
        _interferenceAnswer = _session.interferenceAnswers['general'];
      }
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _moodIndex != null;

  Color _scoreColor(double v) {
    if (v >= 7) return RColors.clay500;
    if (v >= 4) return RColors.saffron500;
    return RColors.sage500;
  }

  String _scoreLabel(double v) {
    if (v == 0) return 'None';
    if (v <= 3) return 'Mild';
    if (v <= 6) return 'Moderate';
    if (v <= 8) return 'Severe';
    return 'Worst';
  }

  String get _phaseLabel {
    if (_session.isMonitoring) {
      return _session.isScanxietyPeriod ? '⚡ Scan approaching' : '🎗️ Monitoring';
    }
    if (_session.isNadirWindow) return '⚠ Nadir · Day ${_session.dayInCycle}';
    if (_session.isNadirApproaching) return '⚡ Nadir soon · Day ${_session.dayInCycle}';
    return '${_session.protocol.name} · Day ${_session.dayInCycle}';
  }

  String get _greeting {
    final h = DateTime.now().hour;
    final n = _session.displayName;
    if (h < 12) return 'Good morning, $n';
    if (h < 17) return 'Good afternoon, $n';
    return 'Good evening, $n';
  }

  void _save() {
    _session.moodEmoji = _moodEmojis[_moodIndex!];
    _session.moodLabel = _moodLabels[_moodIndex!];
    _session.symptomScores = {
      for (final e in _scores.entries)
        if (e.value > 0) e.key: e.value,
    };
    _session.interferenceAnswers = _interferenceAnswer != null
        ? {'general': _interferenceAnswer!}
        : {};
    _session.hadsScores = {};
    _session.physicalActivity = null;
    _session.checkInNote = _notesCtrl.text.trim();
    _session.lastCheckIn = DateTime.now();
    _session.saveCheckIn();
    if (_session.supabasePatientId != null) {
      SupabaseService.saveCheckin(_session.supabasePatientId!, {
        'mood':            _moodEmojis[_moodIndex!],
        'mood_score':      _moodIndex,
        'symptom_scores':  _scores,
        'notes':           _notesCtrl.text.trim(),
      });
    }
    context.go('/checkin/success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _hero(),
              _sectionHead('How are you today?'),
              const SizedBox(height: 12),
              _moodPicker(),
              _sectionHead('Symptoms'),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Text('Rate each from 0 (none) to 10 (worst)',
                  style: TextStyle(fontSize: 11, color: RColors.sand500)),
              ),
              const SizedBox(height: 10),
              ..._primarySymptoms.map((s) => _sliderRow(
                    s.key, s.label, s.arabicLabel,
                  )),
              _interferenceSection(),
              _sectionHead('Notes'),
              const SizedBox(height: 10),
              _notesField(),
              const SizedBox(height: 24),
            ]),
          )),
          _footer(),
        ]),
      ),
    );
  }

  // ── Topbar ──────────────────────────────────────────────────────────────────

  Widget _topbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: RColors.surface, shape: BoxShape.circle,
              border: Border.all(color: RColors.sand200),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: RColors.sand700, size: 22),
          ),
        ),
        const Expanded(child: Center(child: Text('Check-in',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        GestureDetector(
          onTap: () => context.go('/'),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: RColors.surface, shape: BoxShape.circle,
              border: Border.all(color: RColors.sand200),
            ),
            child: const Icon(Icons.close_rounded,
                color: RColors.sand500, size: 18),
          ),
        ),
      ]),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────

  Widget _hero() {
    final isNadir = _session.isNadirWindow;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RColors.teal700, RColors.teal600],
        ),
        borderRadius: RRadius.xlBR,
      ),
      child: Stack(children: [
        Positioned(
          top: -70, right: -70,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isEditing ? 'Update today\'s check-in' : _greeting,
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.2, height: 1.2)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isNadir
                  ? RColors.clay500
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: RRadius.pillBR,
            ),
            child: Text(_phaseLabel,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.95))),
          ),
        ]),
      ]),
    );
  }

  // ── Section head ────────────────────────────────────────────────────────────

  Widget _sectionHead(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Text(label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10.5, letterSpacing: 1.4,
          fontWeight: FontWeight.w500, color: RColors.sand500)),
    );
  }

  // ── Mood picker ──────────────────────────────────────────────────────────────

  Widget _moodPicker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (i) {
          final sel = _moodIndex == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _moodIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? RColors.teal50 : Colors.transparent,
                borderRadius: RRadius.mdBR,
                border: Border.all(
                    color: sel ? RColors.teal200 : Colors.transparent),
              ),
              child: Column(children: [
                Text(_moodEmojis[i],
                  style: TextStyle(fontSize: sel ? 30 : 24)),
                const SizedBox(height: 4),
                Text(_moodLabels[i],
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w500,
                    color: sel ? RColors.teal700 : RColors.sand400)),
              ]),
            ),
          );
        }),
      ),
    );
  }

  // ── Slider row ───────────────────────────────────────────────────────────────

  Widget _sliderRow(String key, String label, String arabicLabel) {
    final val = _scores[key] ?? 0.0;
    final color = _scoreColor(val);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: RColors.sand950)),
              Align(
                alignment: Alignment.centerRight,
                child: Text(arabicLabel,
                  style: const TextStyle(fontSize: 11, color: RColors.plum500))),
            ],
          )),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: val == 0
                  ? RColors.sand100
                  : color.withValues(alpha: 0.12),
              borderRadius: RRadius.pillBR,
            ),
            child: Text(
              val == 0 ? 'None' : '${val.round()} · ${_scoreLabel(val)}',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: val == 0 ? RColors.sand400 : color)),
          ),
        ]),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: color,
            inactiveTrackColor: RColors.sand200,
            thumbColor: val == 0 ? RColors.sand300 : color,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            overlayColor: color.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: val,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (v) {
              if (v != val) HapticFeedback.selectionClick();
              setState(() => _scores[key] = v);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 9, color: RColors.sand400)),
              Text('5', style: TextStyle(fontSize: 9, color: RColors.sand400)),
              Text('10', style: TextStyle(fontSize: 9, color: RColors.sand400)),
            ],
          ),
        ),
      ]),
    );
  }

  // ── Interference question ────────────────────────────────────────────────────

  Widget _interferenceSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Does this affect your daily activities today?',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: RColors.sand950),
          ),
          const SizedBox(height: 2),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'هل يمنعكِ هذا من ممارسة أنشطتكِ العادية اليوم؟',
              style: TextStyle(fontSize: 11, color: RColors.plum500),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _answerChip('No', false),
              const SizedBox(width: 8),
              _answerChip('Yes', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _answerChip(String label, bool value) {
    final sel = _interferenceAnswer == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _interferenceAnswer = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? RColors.teal50 : RColors.sand100,
          borderRadius: RRadius.pillBR,
          border: Border.all(color: sel ? RColors.teal200 : RColors.sand200),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: sel ? RColors.teal700 : RColors.sand500)),
      ),
    );
  }

  // ── Notes field ─────────────────────────────────────────────────────────────

  Widget _notesField() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: TextField(
        controller: _notesCtrl,
        maxLines: 3,
        style: const TextStyle(fontSize: 13, color: RColors.sand900, height: 1.5),
        decoration: const InputDecoration(
          hintText: 'Anything else on your mind...',
          hintStyle: TextStyle(fontSize: 13, color: RColors.sand400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14),
        ),
      ),
    );
  }

  // ── Submit footer ────────────────────────────────────────────────────────────

  Widget _footer() {
    return Container(
      decoration: const BoxDecoration(
        color: RColors.surface,
        border: Border(top: BorderSide(color: RColors.sand200, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: GestureDetector(
        onTap: _canSubmit ? _save : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: _canSubmit ? RColors.teal700 : RColors.sand200,
            borderRadius: RRadius.pillBR,
          ),
          child: Center(child: Text(_isEditing ? 'Update check-in' : 'Log check-in',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: _canSubmit ? Colors.white : RColors.sand400))),
        ),
      ),
    );
  }
}
