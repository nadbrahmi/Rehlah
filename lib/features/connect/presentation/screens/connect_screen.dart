import 'package:flutter/material.dart';
import '../../../../theme/rehlah_theme.dart';
import '../../../../core/utils/user_session.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  int _tabIndex = 0;
  final _tabs = ['Feed', 'Mentors', 'Coaches', 'Stories'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.sand50,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          _topbar(),
          _tabBar(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: _tabIndex == 0 ? _feedTab()
                : _tabIndex == 1 ? _mentorsTab()
                : _tabIndex == 2 ? _coachesTab()
                : _storiesTab(),
          )),
        ]),
      ),
    );
  }

  // ── Topbar ───────────────────────────────────────────────────────────────────

  Widget _topbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(children: [
        const SizedBox(width: 36),
        const Expanded(child: Center(child: Text('Connect',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              letterSpacing: -0.2)))),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: RColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: RColors.sand200),
            ),
            child: const Icon(Icons.search_rounded, color: RColors.sand700, size: 20),
          ),
        ),
      ]),
    );
  }

  // ── Tab bar ──────────────────────────────────────────────────────────────────

  Widget _tabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(children: _tabs.asMap().entries.map((e) {
        final active = e.key == _tabIndex;
        return GestureDetector(
          onTap: () => setState(() => _tabIndex = e.key),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: active ? RColors.teal700 : RColors.surface,
              borderRadius: RRadius.pillBR,
              border: Border.all(
                color: active ? RColors.teal700 : RColors.sand200),
            ),
            child: Text(e.value,
              style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w500,
                color: active ? Colors.white : RColors.sand700)),
          ),
        );
      }).toList()),
    );
  }

  // ── Feed tab ─────────────────────────────────────────────────────────────────

  Widget _feedTab() {
    final session = UserSession();
    final matchedMentor = _mentors.first;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _plumHero(matchedMentor, session),
      _sectionHead('Stories from survivors', cta: 'See all'),
      const SizedBox(height: 8),
      ..._stories.map((s) => _storyRow(s)),
      _sectionHead('Mentors near you', cta: 'See all'),
      const SizedBox(height: 8),
      ..._mentors.take(2).map((m) => _mentorRow(m)),
      const SizedBox(height: 24),
    ]);
  }

  Widget _plumHero(_MentorData m, UserSession session) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RColors.plum700, RColors.plum500],
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
          Text('Mentor of the week',
            style: TextStyle(
              fontSize: 10.5, letterSpacing: 1.4, fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 6),
          Text(m.heroLine,
            style: const TextStyle(
              fontSize: 19, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.2, height: 1.25)),
          const SizedBox(height: 6),
          Text(m.heroSub,
            style: TextStyle(
              fontSize: 12.5, color: Colors.white.withValues(alpha: 0.78),
              height: 1.5)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: RColors.saffron500,
                borderRadius: RRadius.pillBR,
              ),
              child: const Text('Request a chat',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600,
                    color: RColors.sand950)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _sectionHead(String label, {String? cta}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Text(label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5, letterSpacing: 1.4,
            fontWeight: FontWeight.w500, color: RColors.sand500)),
        if (cta != null) ...[
          const Spacer(),
          Text(cta,
            style: const TextStyle(fontSize: 12, color: RColors.teal700,
                fontWeight: FontWeight.w500)),
        ],
      ]),
    );
  }

  Widget _storyRow(_StoryData s) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: s.thumbBg, borderRadius: RRadius.smBR),
          child: Center(child: Text(s.glyph,
            style: TextStyle(fontSize: 18, color: s.thumbFg,
                fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('4 min read',
            style: TextStyle(fontSize: 10, color: RColors.sand400)),
          const SizedBox(height: 2),
          Text(s.title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: RColors.sand950)),
          const SizedBox(height: 2),
          Text(s.author,
            style: const TextStyle(fontSize: 11, color: RColors.sand500)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: RColors.sand300, size: 18),
      ]),
    );
  }

  Widget _mentorRow(_MentorData m) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: m.avBg, shape: BoxShape.circle),
          child: Center(child: Text(m.av,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: m.avFg))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: RColors.sand950)),
          const SizedBox(height: 2),
          Text(m.sub,
            style: const TextStyle(fontSize: 11, color: RColors.sand500)),
          const SizedBox(height: 6),
          Row(children: m.tags.map((t) => Container(
            margin: const EdgeInsets.only(right: 5),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: RColors.sand100, borderRadius: RRadius.pillBR),
            child: Text(t,
              style: const TextStyle(fontSize: 10, color: RColors.sand700)),
          )).toList()),
        ])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          height: 24,
          decoration: BoxDecoration(
            color: RColors.sage100, borderRadius: RRadius.pillBR),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 5, height: 5,
              decoration: const BoxDecoration(
                color: RColors.sage500, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            const Text('Available',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500,
                  color: RColors.sage700, height: 1)),
          ]),
        ),
      ]),
    );
  }

  // ── Mentors tab ───────────────────────────────────────────────────────────────

  Widget _mentorsTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHead('All mentors'),
      const SizedBox(height: 8),
      ..._mentors.map((m) => _mentorRow(m)),
      const SizedBox(height: 24),
    ]);
  }

  // ── Coaches tab ───────────────────────────────────────────────────────────────

  Widget _coachesTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RColors.teal50,
          borderRadius: RRadius.mdBR,
          border: Border.all(color: RColors.teal200),
        ),
        child: const Text(
          'All coaches are verified healthcare professionals. First consultation is free.',
          style: TextStyle(fontSize: 12, color: RColors.teal700, height: 1.5)),
      ),
      _sectionHead('Verified professionals'),
      const SizedBox(height: 8),
      ..._coaches.map((c) => _coachCard(c)),
      const SizedBox(height: 24),
    ]);
  }

  Widget _coachCard(_CoachData c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RColors.surface,
        borderRadius: RRadius.mdBR,
        border: Border.all(color: RColors.sand200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: c.avBg, shape: BoxShape.circle),
            child: Center(child: Text(c.av,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.avFg))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: RColors.sand950)),
            const SizedBox(height: 2),
            Text(c.specialty,
              style: const TextStyle(fontSize: 11, color: RColors.sand500)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: RColors.sky100, borderRadius: RRadius.pillBR),
              child: const Text('✓ Verified professional',
                style: TextStyle(fontSize: 10, color: RColors.sky500,
                    fontWeight: FontWeight.w500)),
            ),
          ])),
        ]),
        const SizedBox(height: 10),
        Text(c.description,
          style: const TextStyle(fontSize: 12, color: RColors.sand700, height: 1.5)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Container(
            height: 36,
            decoration: const BoxDecoration(
              color: RColors.teal700, borderRadius: RRadius.pillBR),
            child: const Center(child: Text('Book free consult',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: Colors.white))),
          )),
          const SizedBox(width: 8),
          Expanded(child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: RColors.sand100, borderRadius: RRadius.pillBR,
              border: Border.all(color: RColors.sand200)),
            child: const Center(child: Text('View profile',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: RColors.sand700))),
          )),
        ]),
      ]),
    );
  }

  // ── Stories tab ───────────────────────────────────────────────────────────────

  Widget _storiesTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHead('Survivor stories'),
      const SizedBox(height: 8),
      ..._stories.map((s) => _storyRow(s)),
      const SizedBox(height: 24),
    ]);
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _MentorData {
  final String av, name, sub, heroLine, heroSub;
  final Color avBg, avFg;
  final List<String> tags;
  const _MentorData({
    required this.av, required this.name, required this.sub,
    required this.heroLine, required this.heroSub,
    required this.avBg, required this.avFg, required this.tags,
  });
}

class _StoryData {
  final String glyph, title, author;
  final Color thumbBg, thumbFg;
  const _StoryData({
    required this.glyph, required this.title, required this.author,
    required this.thumbBg, required this.thumbFg,
  });
}

class _CoachData {
  final String av, name, specialty, description;
  final Color avBg, avFg;
  const _CoachData({
    required this.av, required this.name, required this.specialty,
    required this.description, required this.avBg, required this.avFg,
  });
}

const _mentors = [
  _MentorData(
    av: 'H', name: 'Huda Al-Mansouri', sub: 'Survivor · 3 yrs · breast cancer',
    heroLine: 'Huda walked your exact cycle.',
    heroSub: 'Survivor of 3 years. Available this week.',
    avBg: RColors.saffron300, avFg: RColors.saffron700,
    tags: ['Fatigue', 'Work'],
  ),
  _MentorData(
    av: 'M', name: 'Mira Al-Hammadi', sub: 'Survivor · 6 yrs · stage II',
    heroLine: 'Mira knows the Taxol fatigue.',
    heroSub: 'Six years cancer-free. Ready to listen.',
    avBg: RColors.sage300, avFg: RColors.sage700,
    tags: ['Motherhood', 'Nutrition'],
  ),
  _MentorData(
    av: 'R', name: 'Rania Al-Ahmad', sub: 'Survivor · 4 yrs · AC-T',
    heroLine: 'Rania went through AC-T twice.',
    heroSub: 'Happy to share what helped her.',
    avBg: RColors.teal100, avFg: RColors.teal700,
    tags: ['Nausea', 'Chemo'],
  ),
];

const _stories = [
  _StoryData(
    glyph: 'M', title: 'What I wish I knew in cycle 1',
    author: 'Um Mohammed · 42 · Abu Dhabi',
    thumbBg: RColors.saffron100, thumbFg: RColors.saffron700,
  ),
  _StoryData(
    glyph: 'N', title: 'Coping with hair changes',
    author: 'Noura · 35 · Al Ain',
    thumbBg: RColors.sage100, thumbFg: RColors.sage700,
  ),
  _StoryData(
    glyph: 'H', title: 'Returning to work after treatment',
    author: 'Hind · 47 · Dubai',
    thumbBg: RColors.teal50, thumbFg: RColors.teal700,
  ),
];

const _coaches = [
  _CoachData(
    av: 'A', name: 'Dr. Amira Hassan',
    specialty: 'Clinical Psychologist · Dubai',
    description: 'Specialises in cancer-related anxiety, grief, and adjustment.',
    avBg: RColors.teal50, avFg: RColors.teal700,
  ),
  _CoachData(
    av: 'N', name: 'Nour R.',
    specialty: 'Oncology Dietitian · Abu Dhabi',
    description: 'Helping patients eat and recover well during and after treatment.',
    avBg: RColors.sage100, avFg: RColors.sage700,
  ),
  _CoachData(
    av: 'M', name: 'Mohammed A.',
    specialty: 'Physiotherapist · Dubai',
    description: 'Movement therapy for joint pain, fatigue, and post-treatment recovery.',
    avBg: RColors.sky100, avFg: RColors.sky500,
  ),
];
