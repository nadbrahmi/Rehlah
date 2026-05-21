import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';

enum _TrendDir { better, same, worse }

class _TrendRow {
  final String label;
  final _TrendDir dir;
  const _TrendRow(this.label, this.dir);
}

class CheckInSuccessScreen extends StatelessWidget {
  const CheckInSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    final history = session.history;
    final streak = session.streak;
    final now = session.lastCheckIn ?? DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final trendRows = _buildTrendRows(history);

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(children: [
            const Spacer(),

            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: RColors.sage100,
                border: Border.all(color: RColors.sage300, width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.check_rounded, color: RColors.sage700, size: 32),
              ),
            ),
            const SizedBox(height: 20),
            Text('Check-in logged',
                style: RText.h2.copyWith(fontWeight: FontWeight.w300)),
            const SizedBox(height: 6),
            Text(
              'Logged at $timeStr · Your care team can see this.',
              style: RText.small.copyWith(color: RColors.sand500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            if (streak > 0) _streakPill(streak),
            const SizedBox(height: 28),

            if (trendRows.isNotEmpty)
              _trendCard(trendRows)
            else
              _firstEntryCard(),

            const Spacer(),

            GestureDetector(
              onTap: () => _showNoteSheet(context, session),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: RColors.surface,
                  borderRadius: RRadius.pillBR,
                  border: Border.all(color: RColors.sand200),
                  boxShadow: RShadow.shadow1,
                ),
                child: Center(
                  child: Text('Add a note',
                      style: RText.body.copyWith(color: RColors.sand700)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => context.go('/'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: const BoxDecoration(
                  color: RColors.teal700,
                  borderRadius: RRadius.pillBR,
                  boxShadow: RShadow.shadow2,
                ),
                child: Center(
                  child: Text('Done',
                      style: RText.body.copyWith(
                          color: RColors.surface,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _streakPill(int streak) {
    final label = streak == 1
        ? '🌱 First check-in'
        : streak >= 30
            ? '🏆 $streak days'
            : '🔥 $streak-day streak';
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
          color: RColors.sage100, borderRadius: RRadius.pillBR),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6, height: 6,
          decoration: const BoxDecoration(
              color: RColors.sage500, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: RText.small.copyWith(
                color: RColors.sage700, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _trendCard(List<_TrendRow> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.lgBR,
        boxShadow: RShadow.shadow2,
      ),
      child: Column(children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(child: Text(row.label, style: RText.body)),
              _trendChip(row.dir),
            ]),
          ),
      ]),
    );
  }

  Widget _trendChip(_TrendDir dir) {
    final (icon, label, color) = switch (dir) {
      _TrendDir.better => (Icons.arrow_downward_rounded, 'better', RColors.sage700),
      _TrendDir.same   => (Icons.arrow_forward_rounded,  'same',   RColors.sand500),
      _TrendDir.worse  => (Icons.arrow_upward_rounded,   'worse',  RColors.clay700),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(label,
          style: RText.small.copyWith(color: color, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _firstEntryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RColors.teal50,
        borderRadius: RRadius.lgBR,
        border: Border.all(color: RColors.teal100),
      ),
      child: Row(children: [
        const Text('✦', style: TextStyle(color: RColors.teal700, fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Great start. Each check-in builds a picture your care team can act on.',
            style: RText.body.copyWith(color: RColors.teal900),
          ),
        ),
      ]),
    );
  }

  List<_TrendRow> _buildTrendRows(List<CheckInRecord> history) {
    if (history.length < 2) return [];
    final today = history.last.symptomScores;
    final prev = history[history.length - 2].symptomScores;

    final orderedKeys = [
      ...today.keys,
      ...prev.keys.where((k) => !today.containsKey(k)),
    ];
    if (orderedKeys.isEmpty) return [];

    return orderedKeys.take(4).map((key) {
      final todayVal = today[key] ?? 0.0;
      final prevVal = prev[key] ?? 0.0;
      final dir = todayVal < prevVal - 0.5
          ? _TrendDir.better
          : todayVal > prevVal + 0.5
              ? _TrendDir.worse
              : _TrendDir.same;
      return _TrendRow(_labelForKey(key), dir);
    }).toList();
  }

  String _labelForKey(String key) {
    const labels = {
      'nausea': 'Nausea', 'fatigue': 'Fatigue', 'pain': 'Pain',
      'mood': 'Mood', 'energy': 'Energy', 'anxiety': 'Anxiety',
      'sleep': 'Sleep', 'appetite': 'Appetite', 'mouth_sores': 'Mouth sores',
      'joint_pain': 'Joint pain', 'fever': 'Fever',
      'breathlessness': 'Breathlessness', 'cognitive_fog': 'Brain fog',
      'hot_flashes': 'Hot flashes', 'neuropathy': 'Neuropathy',
      'vomiting': 'Vomiting',
    };
    if (labels.containsKey(key)) return labels[key]!;
    final parts = key.split('_');
    return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join(' ');
  }

  void _showNoteSheet(BuildContext context, UserSession session) {
    final ctrl = TextEditingController(text: session.checkInNote);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 4,
            decoration: const BoxDecoration(
                color: RColors.sand300, borderRadius: RRadius.pillBR),
          ),
          const SizedBox(height: 20),
          Text('Add a note', style: RText.h3),
          const SizedBox(height: 4),
          Text('Appears verbatim in your doctor-ready report.',
              style: RText.small, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            maxLines: 5,
            autofocus: true,
            style: RText.body,
            decoration: InputDecoration(
              hintText: 'Anything on your mind...',
              hintStyle: RText.body.copyWith(color: RColors.sand400),
              filled: true,
              fillColor: RColors.sand50,
              contentPadding: const EdgeInsets.all(14),
              border: const OutlineInputBorder(
                  borderRadius: RRadius.mdBR,
                  borderSide: BorderSide(color: RColors.sand200)),
              enabledBorder: const OutlineInputBorder(
                  borderRadius: RRadius.mdBR,
                  borderSide: BorderSide(color: RColors.sand200)),
              focusedBorder: const OutlineInputBorder(
                  borderRadius: RRadius.mdBR,
                  borderSide: BorderSide(color: RColors.teal700, width: 1.5)),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              session.checkInNote = ctrl.text.trim();
              Navigator.pop(ctx);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                  color: RColors.teal700, borderRadius: RRadius.pillBR),
              child: Center(
                child: Text('Save note',
                    style: RText.body.copyWith(
                        color: RColors.surface,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
