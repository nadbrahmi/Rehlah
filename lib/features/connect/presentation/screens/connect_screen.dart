import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/utils/user_session.dart';
import '../../../../core/utils/protocols.dart';

// ── Data models ───────────────────────────────────────────────────────────────
class _Mentor {
  final String initials, name, status, protocol, quote;
  final Color avBg, avColor;
  final List<String> matchPhaseKeys;
  final bool arabicSpeaker;

  const _Mentor({
    required this.initials, required this.name, required this.status,
    required this.protocol, required this.quote,
    required this.avBg, required this.avColor,
    required this.matchPhaseKeys, this.arabicSpeaker = false,
  });
}

class _Coach {
  final String initials, name, specialty, location, description, verified;
  final Color avBg, avColor;
  final List<String> matchPhaseKeys;
  final String? whyNow; // phase-specific reason shown in For You tab

  const _Coach({
    required this.initials, required this.name, required this.specialty,
    required this.location, required this.description, required this.verified,
    required this.avBg, required this.avColor,
    required this.matchPhaseKeys, this.whyNow,
  });
}

// ── Mentor & Coach database ───────────────────────────────────────────────────
const _mentors = [
  _Mentor(
    initials: 'LM', name: 'Lena M.', status: 'Survivor · 4 years free',
    protocol: 'AC-T · Breast · Dubai',
    quote: 'Week 6 nadir nearly broke me. Here\'s what got me through it.',
    avBg: Color(0xFFFBF4E0), avColor: Color(0xFFC49030),
    matchPhaseKeys: ['Nadir window', 'Peak nausea window', 'Infusion day'],
  ),
  _Mentor(
    initials: 'JK', name: 'James K.', status: 'Survivor · 2 years free',
    protocol: 'TC · Colorectal · Abu Dhabi',
    quote: 'Went through chemo twice. Happy to share what helped me.',
    avBg: Color(0xFFEDE8F8), avColor: Color(0xFF7B5CC4),
    matchPhaseKeys: ['Recovery week', 'Nadir window'],
  ),
  _Mentor(
    initials: 'RA', name: 'Rania A.', status: 'Survivor · 6 years free',
    protocol: 'AC-T · Breast · متحدثة عربية',
    quote: 'أنا هنا لأدعمك بالعربي والإنجليزي. لستِ وحدكِ في هذه الرحلة.',
    avBg: Color(0xFFEAF8F0), avColor: Color(0xFF3DB87A),
    matchPhaseKeys: ['Nadir window', 'Peak nausea window', 'Joint pain peak',
                     'Infusion day', 'Recovery week'],
    arabicSpeaker: true,
  ),
  _Mentor(
    initials: 'SR', name: 'Sara R.', status: 'Survivor · 2 years free',
    protocol: 'CMF · Breast · Sharjah',
    quote: 'I finished chemo. Here\'s what no one told me about recovery.',
    avBg: Color(0xFFFEF0F3), avColor: Color(0xFFC04060),
    matchPhaseKeys: ['Recovery week', 'Post-infusion week'],
  ),
];

const _coaches = [
  _Coach(
    initials: 'DA', name: 'Dr. Amira Hassan',
    specialty: 'Clinical Psychologist · Dubai',
    location: 'Dubai',
    description: 'Specialises in cancer-related anxiety, grief, and adjustment.',
    verified: '✓ Verified professional',
    avBg: Color(0xFFEDE8F8), avColor: Color(0xFF7B5CC4),
    matchPhaseKeys: ['Nadir window', 'Peak nausea window', 'Infusion day',
                     'Recovery week'],
    whyNow: 'Nadir and peak nausea often bring heightened anxiety. '
        'A session can help you prepare mentally and emotionally.',
  ),
  _Coach(
    initials: 'NR', name: 'Nour R.',
    specialty: 'Oncology Dietitian · Abu Dhabi',
    location: 'Abu Dhabi',
    description: 'Helping patients eat and recover well during chemotherapy.',
    verified: '✓ Verified professional',
    avBg: Color(0xFFEAF8F0), avColor: Color(0xFF3DB87A),
    matchPhaseKeys: ['Peak nausea window', 'Nadir window', 'Fluid & pain window',
                     'Post-infusion week', 'Infusion day'],
    whyNow: 'Nausea and appetite loss are highest right now. '
        'A dietitian can help you find foods that are tolerable and nourishing.',
  ),
  _Coach(
    initials: 'MA', name: 'Mohammed A.',
    specialty: 'Physiotherapist · Dubai',
    location: 'Dubai',
    description: 'Movement therapy for joint pain, fatigue, and post-chemo recovery.',
    verified: '✓ Verified professional',
    avBg: Color(0xFFE8F2F8), avColor: Color(0xFF4A8EC0),
    matchPhaseKeys: ['Joint pain peak', 'Recovery week', 'Fluid & pain window'],
    whyNow: 'Joint and muscle pain peaks in the days after Taxol. '
        'Gentle guided movement can significantly reduce discomfort.',
  ),
];

// ── Phase matching logic ──────────────────────────────────────────────────────
class _PhaseMatch {
  static String _currentPhaseName() => UserSession().currentPhase.name;

  static List<_Mentor> matchedMentors() {
    final phase = _currentPhaseName();
    final matched = _mentors
        .where((m) => m.matchPhaseKeys.contains(phase))
        .toList();
    return matched.isEmpty
        ? _mentors.take(2).cast<_Mentor>().toList()
        : matched;
  }

  static List<_Coach> matchedCoaches() {
    final phase = _currentPhaseName();
    final matched = _coaches
        .where((c) => c.matchPhaseKeys.contains(phase))
        .toList();
    return matched.isEmpty
        ? _coaches.take(2).cast<_Coach>().toList()
        : matched;
  }

  static String matchBadge(_Mentor m) {
    final phase = _currentPhaseName();
    if (m.matchPhaseKeys.contains(phase)) {
      if (phase.toLowerCase().contains('nadir')) return 'Has been through nadir';
      if (phase.toLowerCase().contains('nausea')) return 'Knows peak nausea week';
      if (phase.toLowerCase().contains('recovery')) return 'In recovery themselves';
      if (phase.toLowerCase().contains('joint')) return 'Experienced Taxol pain';
      return 'Matched to your phase';
    }
    return 'Same cancer type';
  }

  static String coachBadge(_Coach c) {
    final phase = _currentPhaseName();
    if (phase.toLowerCase().contains('nadir')) return 'Relevant for nadir';
    if (phase.toLowerCase().contains('nausea')) return 'Relevant for nausea';
    if (phase.toLowerCase().contains('joint')) return 'Relevant for joint pain';
    if (phase.toLowerCase().contains('recovery')) return 'Relevant for recovery';
    return 'Relevant for your phase';
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────
class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  int _tabIndex = 0;
  final _tabs = ['For You', 'Community', 'Support', 'Resources'];

  @override
  Widget build(BuildContext context) {
    final session = UserSession();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(children: [
        Positioned(top: -40, right: -20,
          child: Container(width: 150, height: 150,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.primary.withOpacity(0.07), Colors.transparent])))),
        SafeArea(child: Column(children: [
          AppHeader(
            title: 'Your |community',
            subtitle: 'Coaches, mentors and peers — all in one place',
          ),
          // Safe space badge
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.07),
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: AppColors.teal.withOpacity(0.18), width: 0.5)),
                child: Text('✓ Safe space · Moderated',
                  style: AppText.caption.copyWith(
                    color: AppColors.teal, fontWeight: FontWeight.w500,
                    fontSize: 10))),
            ]),
          ),
          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.asMap().entries.map((e) {
                  final active = e.key == _tabIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _tabIndex = e.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primaryLight : AppColors.surface,
                        borderRadius: AppRadius.fullBR,
                        border: Border.all(
                          color: active ? AppColors.primaryMid : AppColors.border,
                          width: 0.5)),
                      child: Text(e.value,
                        style: AppText.caption.copyWith(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: active ? AppColors.primary : AppColors.text2)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: _tabIndex == 0 ? _buildForYou(session)
                  : _tabIndex == 1 ? _buildCommunity()
                  : _tabIndex == 2 ? _buildSupport()
                  : _buildResources(),
            ),
          ),
        ])),
      ]),
    );
  }

  // ── Tab 0: For You ────────────────────────────────────────────────────────
  Widget _buildForYou(UserSession session) {
    final phase = session.currentPhase;
    final isNadir = session.isNadirWindow;
    final isNadirApproaching = session.isNadirApproaching;
    final matchedMentors = _PhaseMatch.matchedMentors();
    final matchedCoaches = _PhaseMatch.matchedCoaches();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 10),

      // Phase context banner
      Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isNadir
              ? AppColors.peach.withOpacity(0.06)
              : isNadirApproaching
                  ? AppColors.gold.withOpacity(0.06)
                  : AppColors.primary.withOpacity(0.05),
          borderRadius: AppRadius.mdBR,
          border: Border.all(
            color: isNadir
                ? AppColors.peach.withOpacity(0.2)
                : isNadirApproaching
                    ? AppColors.gold.withOpacity(0.2)
                    : AppColors.primaryMid,
            width: 0.5)),
        child: Row(children: [
          Text(
            isNadir ? '⚠' : isNadirApproaching ? '⚡' : '💜',
            style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isNadir
                    ? 'You\'re in your nadir window'
                    : isNadirApproaching
                        ? 'Nadir window approaching'
                        : '${session.protocol.name} · ${phase.name}',
                style: AppText.bodySemibold.copyWith(
                  fontSize: 13,
                  color: isNadir ? AppColors.peach
                      : isNadirApproaching ? AppColors.gold
                      : AppColors.primary)),
              const SizedBox(height: 2),
              Text(
                isNadir
                    ? 'These mentors and coaches have been through exactly this.'
                    : isNadirApproaching
                        ? 'Connect with someone who knows what\'s coming.'
                        : 'People matched to your current phase.',
                style: AppText.bodySecondary.copyWith(fontSize: 12)),
            ],
          )),
        ]),
      ),

      // Matched mentors
      const SectionLabel('Mentors for your phase'),
      ...matchedMentors.take(2).map((m) => _buildMentorCard(m, showBadge: true)),

      // Matched coaches
      const SectionLabel('Coaches for right now'),
      ...matchedCoaches.take(2).map((c) => _buildCoachCard(c, showWhyNow: true)),

      // Weekly prompt
      _buildWeeklyPrompt(),
      const SizedBox(height: 24),
    ]);
  }

  // ── Tab 1: Community ──────────────────────────────────────────────────────
  Widget _buildCommunity() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      // Moderation note
      Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.04),
          borderRadius: AppRadius.mdBR,
          border: Border.all(
            color: AppColors.teal.withOpacity(0.13), width: 0.5)),
        child: Text(
          '🛡️ Peer support only. Always consult your care team for medical advice.',
          style: AppText.caption.copyWith(
            color: AppColors.teal.withOpacity(0.65), fontSize: 10,
            height: 1.5))),
      const SizedBox(height: 8),
      _buildWeeklyPrompt(),
      _buildPost('SJ', AppColors.primaryLight, AppColors.primary,
          'Sarah J.', '2 hours ago · Breast · Week 6',
          'Week 6 done! Morning walks really help — even 10 minutes makes a difference. 🌸',
          24, 12, true),
      _buildPost('MR', AppColors.blueLight, AppColors.blue,
          'Michael R.', '5 hours ago · Colorectal',
          'Waiting for scan results is the hardest part. Sending strength 💜 — the scanxiety is very real.',
          38, 5, false),
      _buildPost('LA', AppColors.tealLight, AppColors.teal,
          'Layla A.', 'Yesterday · Breast · Nadir week',
          'Day 10 of nadir. Keeping temperature log twice a day as instructed. Day by day.',
          19, 8, false),
      const SizedBox(height: 24),
    ]);
  }

  // ── Tab 2: Support (all mentors + all coaches) ───────────────────────────
  Widget _buildSupport() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.primaryMid, width: 0.5)),
        child: Text(
          '💜 Mentors are fellow patients and survivors. '
          'Coaches are verified healthcare professionals. '
          'First consultation with any coach is free.',
          style: AppText.caption.copyWith(
            color: AppColors.primary, fontSize: 11, height: 1.5))),

      // All mentors
      const SectionLabel('Mentors — patients & survivors'),
      ..._mentors.map((m) => _buildMentorCard(m, showBadge: true)),

      // All coaches
      const SectionLabel('Coaches — verified professionals'),
      Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: AppColors.blue.withOpacity(0.05),
          borderRadius: AppRadius.mdBR,
          border: Border.all(
            color: AppColors.blue.withOpacity(0.15), width: 0.5)),
        child: Text(
          '✓ All coaches are verified healthcare professionals.',
          style: AppText.caption.copyWith(
            color: AppColors.blue, fontSize: 11))),
      ..._coaches.map((c) => _buildCoachCard(c, showWhyNow: false)),
      const SizedBox(height: 24),
    ]);
  }

  // ── Tab 3: Resources ──────────────────────────────────────────────────────
  Widget _buildResources() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Crisis line — always first
      Container(
        margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.primaryMid, width: 0.5)),
        child: Column(children: [
          Text('Need support right now?',
            style: AppText.bodySemibold.copyWith(color: AppColors.primary)),
          const SizedBox(height: 6),
          Text('800 4673',
            style: AppText.statNumber.copyWith(
              color: AppColors.primary, fontSize: 24)),
          const SizedBox(height: 4),
          Text('Available 24/7 · Free to call · UAE MOHAP Hope Line',
            style: AppText.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center),
        ]),
      ),

      // UAE support organisations
      const SectionLabel('Support in the UAE'),
      ...[
        ('🏥', 'Tawam Hospital', 'Abu Dhabi · Oncology'),
        ('🎗️', 'Emirates Cancer Society', 'Support & awareness'),
        ('🏥', 'Al Jalila Foundation', 'Dubai · Research'),
        ('🩷', 'Pink Caravan', 'Breast cancer UAE'),
      ].map((s) => Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 7),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBR,
          border: Border.all(color: AppColors.border, width: 0.5)),
        child: Row(children: [
          Text(s.$1, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.$2, style: AppText.bodySemibold),
              Text(s.$3, style: AppText.bodySecondary),
            ],
          )),
          Icon(Icons.arrow_forward_ios_rounded,
            size: 12, color: AppColors.text3),
        ]),
      )),

      // Stories
      const SectionLabel('Survivor stories'),
      _buildStoryCard(),
      const SizedBox(height: 24),
    ]);
  }

  // ── Shared widgets ────────────────────────────────────────────────────────
  Widget _buildMentorCard(_Mentor m, {required bool showBadge}) {
    final badge = showBadge ? _PhaseMatch.matchBadge(m) : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: m.avBg, shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5)),
          child: Center(child: Text(m.initials,
            style: TextStyle(fontFamily: 'Inter', fontSize: 14,
              fontWeight: FontWeight.w500, color: m.avColor)))),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.08),
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: AppColors.teal.withOpacity(0.2), width: 0.5)),
                child: Text('🟢 $badge',
                  style: AppText.caption.copyWith(
                    fontSize: 10, color: AppColors.teal,
                    fontWeight: FontWeight.w600))),
            ],
            Text(m.name, style: AppText.bodySemibold),
            Text(m.status, style: AppText.bodySemibold.copyWith(
              color: m.avColor, fontSize: 11)),
            Text(m.protocol, style: AppText.caption.copyWith(fontSize: 11)),
            const SizedBox(height: 6),
            Text('"${m.quote}"',
              style: AppText.bodySecondary.copyWith(
                fontSize: 12, fontStyle: FontStyle.italic),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: m.avColor.withOpacity(0.10),
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: m.avColor.withOpacity(0.2), width: 0.5)),
                child: Text('Message · Free',
                  style: AppText.caption.copyWith(
                    color: m.avColor, fontWeight: FontWeight.w500,
                    fontSize: 11))),
              if (m.arabicSpeaker) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background2,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.border, width: 0.5)),
                  child: Text('🌍 عربي',
                    style: AppText.caption.copyWith(fontSize: 11))),
              ],
            ]),
          ],
        )),
      ]),
    );
  }

  Widget _buildCoachCard(_Coach c, {required bool showWhyNow}) {
    final badge = showWhyNow ? _PhaseMatch.coachBadge(c) : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: c.avBg, shape: BoxShape.circle),
            child: Center(child: Text(c.initials,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                fontWeight: FontWeight.w500, color: c.avColor)))),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.07),
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(
                      color: AppColors.primaryMid, width: 0.5)),
                  child: Text('⚡ $badge',
                    style: AppText.caption.copyWith(
                      fontSize: 10, color: AppColors.primary,
                      fontWeight: FontWeight.w600))),
              ],
              Text(c.name, style: AppText.bodySemibold),
              Text(c.specialty, style: AppText.caption),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blueLight,
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: AppColors.blue.withOpacity(0.18), width: 0.5)),
                child: Text(c.verified,
                  style: AppText.caption.copyWith(
                    color: AppColors.blue, fontSize: 9,
                    fontWeight: FontWeight.w500))),
            ],
          )),
        ]),
        const SizedBox(height: 8),
        Text(c.description, style: AppText.bodySecondary),
        // Why now — only in For You tab
        if (showWhyNow && c.whyNow != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.04),
              borderRadius: AppRadius.smBR,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.12), width: 0.5)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💡', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(child: Text('Why now: ${c.whyNow}',
                style: AppText.caption.copyWith(
                  fontSize: 11, color: AppColors.primary,
                  height: 1.5))),
            ]),
          ),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.mdBR,
              border: Border.all(color: AppColors.primaryMid, width: 0.5)),
            child: Center(child: Text('Book free consult',
              style: AppText.caption.copyWith(
                color: AppColors.primary, fontWeight: FontWeight.w500))))),
          const SizedBox(width: 6),
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.mdBR,
              border: Border.all(color: AppColors.border, width: 0.5)),
            child: Center(child: Text('View profile',
              style: AppText.caption.copyWith(
                color: AppColors.text2, fontWeight: FontWeight.w500))))),
        ]),
      ]),
    );
  }

  Widget _buildWeeklyPrompt() {
    final phase = UserSession().currentPhase;
    final isNadir = UserSession().isNadirWindow;

    final prompts = {
      'nadir': '"What\'s one small thing that helped you through a hard day?"',
      'Peak nausea window': '"What food or drink actually worked for you this week?"',
      'Recovery week': '"What\'s one thing your body can do today that it couldn\'t last week?"',
      'Taxol infusion': '"What helped you mentally prepare for treatment day?"',
      'default': '"What\'s one small thing that helped you through a hard day?"',
    };

    final prompt = isNadir
        ? prompts['nadir']!
        : prompts[phase.name] ?? prompts['default']!;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.06),
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.blue.withOpacity(0.15), width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('✦ THIS WEEK\'S PROMPT',
          style: AppText.label.copyWith(color: AppColors.blue)),
        const SizedBox(height: 5),
        Text(prompt,
          style: AppText.body.copyWith(color: AppColors.text1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.09),
            borderRadius: AppRadius.fullBR,
            border: Border.all(
              color: AppColors.blue.withOpacity(0.18), width: 0.5)),
          child: Text('+ Share your answer',
            style: AppText.caption.copyWith(
              color: AppColors.blue, fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _buildPost(String initials, Color avBg, Color avColor,
      String name, String info, String text, int likes, int replies,
      bool liked) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 30, height: 30,
            decoration: BoxDecoration(color: avBg, shape: BoxShape.circle),
            child: Center(child: Text(initials,
              style: TextStyle(fontFamily: 'Inter', fontSize: 11,
                fontWeight: FontWeight.w500, color: avColor)))),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: AppText.bodySemibold),
            Text(info, style: AppText.caption.copyWith(fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 9),
        Text(text, style: AppText.bodySecondary),
        const SizedBox(height: 9),
        Row(children: [
          _reactBtn('💜 $likes', liked),
          const SizedBox(width: 6),
          _reactBtn('🤝 Me too', false),
          const Spacer(),
          Text('$replies replies',
            style: AppText.caption.copyWith(fontSize: 10)),
        ]),
      ]),
    );
  }

  Widget _reactBtn(String label, bool active) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: active ? AppColors.primaryLight : AppColors.background,
      borderRadius: AppRadius.fullBR,
      border: Border.all(
        color: active ? AppColors.primaryMid : AppColors.border, width: 0.5)),
    child: Text(label, style: AppText.caption.copyWith(
      fontSize: 11,
      color: active ? AppColors.primary : AppColors.text2)));

  Widget _buildStoryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdBR,
        border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 52,
          decoration: BoxDecoration(
            color: AppColors.goldLight,
            borderRadius: const BorderRadius.only(
              topLeft: AppRadius.md, topRight: AppRadius.md)),
          child: const Center(child: Text('🌟',
            style: TextStyle(fontSize: 22)))),
        Padding(padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: AppRadius.fullBR),
                child: Text('Featured',
                  style: AppText.caption.copyWith(
                    color: AppColors.gold, fontWeight: FontWeight.w600,
                    fontSize: 10))),
              Text('6 min read',
                style: AppText.caption.copyWith(fontSize: 10)),
            ]),
            const SizedBox(height: 6),
            Text('I finished chemo. Here\'s what no one told me.',
              style: AppText.bodySemibold.copyWith(fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              'After 12 sessions, I thought the hard part was over. '
              'I was wrong — and I was so grateful.',
              style: AppText.bodySecondary,
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              Container(width: 24, height: 24,
                decoration: BoxDecoration(
                  color: AppColors.goldLight, shape: BoxShape.circle),
                child: Center(child: Text('SR',
                  style: AppText.caption.copyWith(
                    fontSize: 9, fontWeight: FontWeight.w500,
                    color: AppColors.gold)))),
              const SizedBox(width: 7),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sara R.', style: AppText.caption),
                Text('Breast cancer survivor · 2 years free',
                  style: AppText.caption.copyWith(fontSize: 9)),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: AppRadius.fullBR,
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.2), width: 0.5)),
                child: Text('Read →',
                  style: AppText.caption.copyWith(
                    color: AppColors.gold, fontWeight: FontWeight.w500))),
            ]),
          ])),
      ]),
    );
  }
}
