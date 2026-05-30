import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../theme/rehlah_theme.dart';
import '../../../../../core/utils/user_session.dart';

class CheckInHistoryScreen extends StatelessWidget {
  const CheckInHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    // Newest first
    final entries = session.history.reversed.toList();

    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(context),
          Expanded(
            child: entries.isEmpty
                ? _empty(context)
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                        16, 8, 16,
                        120 + MediaQuery.of(context).padding.bottom),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => _card(context, entries[i]),
                  ),
          ),
          _footer(context, session),
        ]),
      ),
    );
  }

  Widget _topbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: RColors.surface, shape: BoxShape.circle,
              border: Border.all(color: RColors.sand200)),
            child: const Icon(Icons.chevron_left_rounded,
                color: RColors.sand700, size: 22),
          ),
        ),
        const Expanded(child: Center(
          child: Text('Journal',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                letterSpacing: -0.2)),
        )),
        const SizedBox(width: 36),
      ]),
    );
  }

  Widget _card(BuildContext context, CheckInRecord r) {
    final now = DateTime.now();
    final isToday = r.date.year == now.year &&
        r.date.month == now.month &&
        r.date.day == now.day;
    final isYesterday = r.date.year == now.year &&
        r.date.month == now.month &&
        r.date.day == now.day - 1;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today · ${DateFormat('h:mm a').format(r.date)}';
    } else if (isYesterday) {
      dateLabel = 'Yesterday · ${DateFormat('d MMM').format(r.date)}';
    } else {
      dateLabel = DateFormat('EEE, d MMM').format(r.date);
    }

    final symptoms = r.symptomScores.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GestureDetector(
      onTap: isToday ? () => context.push('/checkin') : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: RColors.surface,
          borderRadius: RRadius.mdBR,
          border: Border.all(
            color: isToday ? RColors.teal200 : RColors.sand200,
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(dateLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isToday ? RColors.teal700 : RColors.sand500)),
            const Spacer(),
            if (isToday)
              const Text('Edit →',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                    color: RColors.teal700)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text(r.moodEmoji,
              style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.moodLabel,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600, color: RColors.sand900)),
              if (symptoms.isNotEmpty)
                Text(
                  symptoms.take(3).map((e) =>
                    '${_symLabel(e.key)} ${e.value.toInt()}/10').join(' · '),
                  style: const TextStyle(fontSize: 11, color: RColors.sand500,
                      height: 1.4)),
            ]),
          ]),
          if (r.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r.note,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: RColors.sand500,
                  height: 1.4, fontStyle: FontStyle.italic)),
          ],
          if (symptoms.isEmpty && r.note.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('No symptoms reported',
                style: TextStyle(fontSize: 11, color: RColors.sand400)),
            ),
        ]),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📋', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 12),
        const Text('No check-ins yet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: RColors.sand700)),
        const SizedBox(height: 6),
        const Text('Your daily logs will appear here',
          style: TextStyle(fontSize: 13, color: RColors.sand400)),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => context.push('/checkin'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              color: RColors.teal700, borderRadius: RRadius.pillBR),
            child: const Text('Check in now',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: Colors.white)),
          ),
        ),
      ]),
    );
  }

  Widget _footer(BuildContext context, UserSession session) {
    final doneToday = session.checkedInToday;
    return Container(
      decoration: const BoxDecoration(
        color: RColors.surface,
        border: Border(top: BorderSide(color: RColors.sand200, width: 0.5))),
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: GestureDetector(
        onTap: () => context.push('/checkin'),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: doneToday ? RColors.teal100 : RColors.teal700,
            borderRadius: RRadius.pillBR),
          child: Center(
            child: Text(
              doneToday ? 'Update today\'s check-in' : 'Check in now',
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: doneToday ? RColors.teal700 : Colors.white))),
        ),
      ),
    );
  }

  String _symLabel(String key) {
    const map = {
      'fatigue': 'Fatigue',
      'pain': 'Pain',
      'nausea': 'Nausea',
      'fever': 'Fever',
      'scan_anxiety': 'Anxiety',
      'sleep': 'Sleep',
      'appetite': 'Appetite',
      'mood': 'Mood',
    };
    return map[key] ?? key[0].toUpperCase() + key.substring(1);
  }
}
