import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTab = 0;
  String _filterCancerType = 'All';
  String _filterPhase = 'All';

  final List<String> _cancerTypes = ['All', 'Breast', 'Colorectal', 'Lymphoma', 'Lung', 'Prostate'];
  final List<String> _phases = ['All', 'Diagnosis', 'Chemo', 'Radiation', 'Surgery', 'Recovery'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Gradient Header ───────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Community',
                              style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 5),
                              Text('Safe Space',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('You are not alone on this journey 💜',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8))),
                    const SizedBox(height: 16),
                    // Tab selector inside header
                    Row(
                      children: [
                        _HeaderTab(label: 'Feed', index: 0, selected: _selectedTab,
                            onTap: () => setState(() => _selectedTab = 0)),
                        const SizedBox(width: 8),
                        _HeaderTab(label: 'Coaches', index: 1, selected: _selectedTab,
                            onTap: () => setState(() => _selectedTab = 1)),
                        const SizedBox(width: 8),
                        _HeaderTab(label: 'Mentors', index: 2, selected: _selectedTab,
                            onTap: () => setState(() => _selectedTab = 2)),
                        const SizedBox(width: 8),
                        _HeaderTab(label: 'Stories', index: 3, selected: _selectedTab,
                            onTap: () => setState(() => _selectedTab = 3)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Filter Chips (Community Feed only) ───────────────────────
          if (_selectedTab == 0) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(Icons.filter_list_rounded, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    ..._cancerTypes.map((t) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _FilterChip(
                            label: t,
                            isSelected: _filterCancerType == t,
                            onTap: () => setState(() => _filterCancerType = t),
                            color: AppColors.primary,
                          ),
                        )),
                    const SizedBox(width: 8),
                    const Text('|', style: TextStyle(color: AppColors.divider)),
                    const SizedBox(width: 8),
                    ..._phases.map((p) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _FilterChip(
                            label: p,
                            isSelected: _filterPhase == p,
                            onTap: () => setState(() => _filterPhase = p),
                            color: AppColors.primaryLight,
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],

          // ── Tab Content ───────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _CommunityFeedTab(
                    cancerFilter: _filterCancerType, phaseFilter: _filterPhase),
                _CoachesTab(),
                _MentorsTab(),
                _StoriesTab(),
              ],
            ),
          ),
        ],
      ),
      // Floating compose button
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showComposePost(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
              label: Text('Share', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }
}

// ─── Header Tab ───────────────────────────────────────────────────────────────
class _HeaderTab extends StatelessWidget {
  final String label;
  final int index;
  final int selected;
  final VoidCallback onTap;
  const _HeaderTab({required this.label, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.white)),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;
  const _FilterChip({required this.label, required this.isSelected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? color : AppColors.divider, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? color : AppColors.textSecondary)),
      ),
    );
  }
}

// ─── Community Feed Tab ───────────────────────────────────────────────────────
class _CommunityFeedTab extends StatelessWidget {
  final String cancerFilter;
  final String phaseFilter;

  _CommunityFeedTab({required this.cancerFilter, required this.phaseFilter});

  final List<_Post> _allPosts = [
    _Post(
      author: 'Sarah J.',
      initials: 'SJ',
      color: AppColors.primary,
      time: '2 hours ago',
      cancerType: 'Breast',
      phase: 'Chemo',
      content: 'Week 6 of chemo done! The fatigue is real, but staying positive. Anyone else find morning walks helpful? Even 10 minutes makes a difference for me. 💜',
      replies: 12,
      likes: 24,
      isVerifiedSurvivor: false,
    ),
    _Post(
      author: 'Michael R.',
      initials: 'MR',
      color: AppColors.accent,
      time: '5 hours ago',
      cancerType: 'Colorectal',
      phase: 'Recovery',
      content: 'Had my first post-treatment scan today. Waiting for results is the hardest part. Sending strength to everyone in this community 💜 — the scanxiety is very real.',
      replies: 5,
      likes: 38,
      isVerifiedSurvivor: false,
    ),
    _Post(
      author: 'Emma L.',
      initials: 'EL',
      color: AppColors.avatarBlue,
      time: '1 day ago',
      cancerType: 'Breast',
      phase: 'Recovery',
      content: 'Tip: The Rehla check-ins have been so helpful for my doctor visits. I can show my symptoms trend and have better conversations with my oncologist.',
      replies: 8,
      likes: 52,
      isVerifiedSurvivor: true,
    ),
    _Post(
      author: 'David K.',
      initials: 'DK',
      color: AppColors.avatarAmber,
      time: '2 days ago',
      cancerType: 'Lymphoma',
      phase: 'Chemo',
      content: 'Anyone experience extreme cold sensitivity from chemo? My fingers go numb when I touch anything cold. My oncologist says it\'s peripheral neuropathy. Has anyone found relief?',
      replies: 21,
      likes: 18,
      isVerifiedSurvivor: false,
    ),
    _Post(
      author: 'Lisa T.',
      initials: 'LT',
      color: AppColors.avatarRose,
      time: '3 days ago',
      cancerType: 'Lung',
      phase: 'Radiation',
      content: 'Week 3 of radiation complete. The fatigue accumulates but the team here and in this community keep me going. One session at a time. You are all warriors. 🌟',
      replies: 15,
      likes: 67,
      isVerifiedSurvivor: false,
    ),
    _Post(
      author: 'Priya M.',
      initials: 'PM',
      color: AppColors.avatarEmerald,
      time: '4 days ago',
      cancerType: 'Breast',
      phase: 'Diagnosis',
      content: 'Just got my diagnosis last week. Stage II breast cancer. I\'m scared but also grateful to have found communities like this. Any advice for someone just starting this journey?',
      replies: 34,
      likes: 89,
      isVerifiedSurvivor: false,
    ),
  ];

  List<_Post> get _filteredPosts {
    return _allPosts.where((p) {
      final matchesCancer = cancerFilter == 'All' || p.cancerType == cancerFilter;
      final matchesPhase = phaseFilter == 'All' || p.phase == phaseFilter;
      return matchesCancer && matchesPhase;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final posts = _filteredPosts;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        // Safety banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_rounded, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This is a peer support space. Content is not medical advice. Always consult your care team.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (posts.isEmpty) ...[
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text('No posts for this filter',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('Try a different cancer type or phase',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ] else
          ...posts.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostCard(post: p),
              )),
      ],
    );
  }
}

class _PostCard extends StatefulWidget {
  final _Post post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    return RehlaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: p.color.withValues(alpha: 0.15),
                child: Text(p.initials,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.color)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(p.author,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        if (p.isVerifiedSurvivor) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Survivor',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent)),
                          ),
                        ],
                      ],
                    ),
                    Text(p.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              // Cancer type + phase tags
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(p.cancerType,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: p.color)),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(p.phase,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Content
          Text(p.content,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 12),
          // Action row
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _liked = !_liked;
                  _likeCount += _liked ? 1 : -1;
                }),
                child: Row(
                  children: [
                    Icon(
                      _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: _liked ? AppColors.danger : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text('$_likeCount',
                        style: TextStyle(
                            fontSize: 12,
                            color: _liked ? AppColors.danger : AppColors.textMuted,
                            fontWeight: _liked ? FontWeight.w700 : FontWeight.w400)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('${p.replies} replies',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply feature coming soon 💬'), backgroundColor: AppColors.primary),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Reply',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Post {
  final String author, initials, time, content, cancerType, phase;
  final Color color;
  final int replies, likes;
  final bool isVerifiedSurvivor;

  _Post({
    required this.author,
    required this.initials,
    required this.color,
    required this.time,
    required this.content,
    required this.cancerType,
    required this.phase,
    required this.replies,
    required this.likes,
    this.isVerifiedSurvivor = false,
  });
}

// ─── Coaches Tab ──────────────────────────────────────────────────────────────
class _CoachesTab extends StatelessWidget {
  final List<_CoachCard> _coaches = const [
    _CoachCard(
      name: 'Maria Rodriguez',
      role: 'Oncology Life Coach',
      bio: 'Former nurse with 12 years in oncology. Specializes in helping patients navigate chemo and maintain quality of life.',
      rating: 4.9,
      reviews: 47,
      sessions: 230,
      initials: 'MR',
      color: AppColors.primary,
      specialties: ['Chemotherapy', 'Breast cancer', 'Anxiety management'],
      available: true,
    ),
    _CoachCard(
      name: 'Sarah Chen',
      role: 'Cancer Support Specialist',
      bio: 'Oncology social worker and coach. Focuses on the emotional and practical challenges of cancer treatment.',
      rating: 4.8,
      reviews: 89,
      sessions: 415,
      initials: 'SC',
      color: AppColors.accent,
      specialties: ['Lymphoma', 'Side effects', 'Mental health'],
      available: true,
    ),
    _CoachCard(
      name: 'James Wilson',
      role: 'Oncology Counselor',
      bio: 'Certified cancer coach who survived Hodgkin\'s lymphoma. Now helps others navigate what he experienced firsthand.',
      rating: 4.7,
      reviews: 31,
      sessions: 120,
      initials: 'JW',
      color: AppColors.info,
      specialties: ['Radiation', 'Surgery prep', 'Family support'],
      available: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'All coaches are certified oncology professionals. Sessions are not a substitute for medical care.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._coaches.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RehlaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: c.color.withValues(alpha: 0.15),
                              child: Text(c.initials,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.color)),
                            ),
                            if (c.available)
                              Positioned(
                                bottom: 2, right: 2,
                                child: Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              Text(c.role,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFF4B63E), size: 14),
                                  const SizedBox(width: 3),
                                  Text('${c.rating} (${c.reviews})',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.people_rounded, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 3),
                                  Text('${c.sessions} sessions',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(c.bio,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: c.specialties.map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: c.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(s, style: TextStyle(fontSize: 11, color: c.color, fontWeight: FontWeight.w600)),
                          )).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Viewing ${c.name}\'s profile...'), backgroundColor: AppColors.primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                            ),
                            child: const Text('View Profile'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: c.available
                                ? () => ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Booking session with ${c.name}... 📅'), backgroundColor: c.color),
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              backgroundColor: c.available ? c.color : AppColors.divider,
                            ),
                            child: Text(c.available ? 'Book Session' : 'Unavailable'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _CoachCard {
  final String name, role, bio, initials;
  final Color color;
  final double rating;
  final int reviews, sessions;
  final List<String> specialties;
  final bool available;

  const _CoachCard({
    required this.name,
    required this.role,
    required this.bio,
    required this.rating,
    required this.reviews,
    required this.sessions,
    required this.initials,
    required this.color,
    required this.specialties,
    required this.available,
  });
}

// ─── Mentors Tab ──────────────────────────────────────────────────────────────
class _MentorsTab extends StatelessWidget {
  final List<_Mentor> _mentors = const [
    _Mentor(
      name: 'Jennifer K.',
      type: 'Breast Cancer Survivor',
      detail: '3 years post-treatment · Stage II',
      story: 'I was terrified when diagnosed at 38 with two young kids. Chemo was brutal but I got through it. Happy to talk to anyone going through similar.',
      initials: 'JK',
      color: AppColors.primary,
      tags: ['Stage II', 'Chemo veteran', 'Working mom', 'Breast'],
    ),
    _Mentor(
      name: 'Robert M.',
      type: 'Colorectal Cancer Survivor',
      detail: '5 years post-treatment · Stage III',
      story: 'Surgery + chemo for 6 months. The mental game was harder than the physical. Now I mentor others because it\'s the most meaningful thing I do.',
      initials: 'RM',
      color: AppColors.info,
      tags: ['Surgery', 'Recovery', 'Active lifestyle', 'Colorectal'],
    ),
    _Mentor(
      name: 'Lisa T.',
      type: 'Lymphoma Survivor',
      detail: '2 years post-treatment',
      story: 'Immunotherapy changed everything for me. I know how overwhelming the treatment options can feel. Here to help navigate it all.',
      initials: 'LT',
      color: AppColors.accent,
      tags: ['Immunotherapy', 'Mental health', 'Lymphoma'],
    ),
    _Mentor(
      name: 'Ahmed S.',
      type: 'Lung Cancer Survivor',
      detail: '4 years post-treatment · Stage II',
      story: 'Never smoked a day in my life and got lung cancer at 52. The shock was immense. But I\'m here, thriving. Peer support saved my sanity.',
      initials: 'AS',
      color: const Color(0xFFE74C8C),
      tags: ['Radiation', 'Lung', 'Non-smoker', 'Recovery'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.people_rounded, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Peer mentors are volunteer cancer survivors. Connect for peer support — not medical advice.',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._mentors.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: RehlaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: m.color.withValues(alpha: 0.15),
                          child: Text(m.initials,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: m.color)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              Text(m.type,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              Text(m.detail,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: AppColors.accent, size: 12),
                              SizedBox(width: 3),
                              Text('Survivor',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: m.color.withValues(alpha: 0.12)),
                      ),
                      child: Text(
                        '"${m.story}"',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: m.tags.map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: m.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(t, style: TextStyle(fontSize: 11, color: m.color)),
                          )).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showConnectMentor(context, m.name, m.type),
                        icon: const Icon(Icons.handshake_rounded, size: 16),
                        label: const Text('Connect with this Mentor'),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _Mentor {
  final String name, type, detail, story, initials;
  final Color color;
  final List<String> tags;

  const _Mentor({
    required this.name,
    required this.type,
    required this.detail,
    required this.story,
    required this.initials,
    required this.color,
    required this.tags,
  });
}

// ─── Stories Tab ─────────────────────────────────────────────────────────────
class _StoriesTab extends StatelessWidget {
  final List<_Story> _stories = const [
    _Story(
      title: 'From Diagnosis to Marathon: My Comeback Story',
      author: 'Jennifer K.',
      initials: 'JK',
      color: AppColors.primary,
      cancerType: 'Breast Cancer',
      duration: '8 min read',
      excerpt: 'When Dr. Chen sat me down and said "It\'s breast cancer," my world stopped. Fast forward three years — I just crossed the finish line of my first 5K. Here\'s everything that happened in between...',
      tags: ['Survivor', 'Inspiration', 'Recovery'],
      readCount: 1240,
    ),
    _Story(
      title: 'What Nobody Tells You About the Mental Health Side of Chemo',
      author: 'David K.',
      initials: 'DK',
      color: Color(0xFFF59E0B),
      cancerType: 'Lymphoma',
      duration: '6 min read',
      excerpt: 'Everyone prepares you for hair loss and nausea. Nobody prepares you for the anxiety that comes with every blood test, the grief for your pre-cancer self, or the strange guilt of having a "treatable" cancer...',
      tags: ['Mental Health', 'Chemo', 'Honest'],
      readCount: 2890,
    ),
    _Story(
      title: 'How I Talked to My Kids About Cancer (At Ages 5 and 8)',
      author: 'Sarah J.',
      initials: 'SJ',
      color: Color(0xFFE74C8C),
      cancerType: 'Breast Cancer',
      duration: '5 min read',
      excerpt: 'My daughter thought cancer was contagious. My son thought I was going to die. Getting this conversation right was the hardest thing I\'ve ever done — and some of what worked might surprise you...',
      tags: ['Family', 'Kids', 'Communication'],
      readCount: 4500,
    ),
    _Story(
      title: 'Finding Gratitude in the Worst Year of My Life',
      author: 'Lisa T.',
      initials: 'LT',
      color: AppColors.accent,
      cancerType: 'Lymphoma',
      duration: '7 min read',
      excerpt: 'I know "cancer was a gift" is a cliché that many find offensive — and I get that. But for me, facing mortality reshuffled everything I thought mattered. Here is what actually changed...',
      tags: ['Gratitude', 'Survivorship', 'Life Lessons'],
      readCount: 3200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'Real stories from real patients. Read, be inspired, share your own.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ..._stories.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => _showStory(context, s),
                child: RehlaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Story header gradient
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              s.color.withValues(alpha: 0.15),
                              s.color.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(Icons.menu_book_rounded, color: s.color, size: 36),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(s.title,
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.3)),
                      const SizedBox(height: 8),
                      Text(
                        s.excerpt,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: s.color.withValues(alpha: 0.15),
                            child: Text(s.initials,
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: s.color)),
                          ),
                          const SizedBox(width: 6),
                          Text(s.author,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(s.cancerType,
                                style: TextStyle(fontSize: 9, color: s.color, fontWeight: FontWeight.w600)),
                          ),
                          const Spacer(),
                          const Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text(s.duration,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(width: 8),
                          const Icon(Icons.remove_red_eye_rounded, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text('${s.readCount}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: s.tags.map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                            )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _Story {
  final String title, author, initials, cancerType, duration, excerpt;
  final Color color;
  final List<String> tags;
  final int readCount;

  const _Story({
    required this.title,
    required this.author,
    required this.initials,
    required this.cancerType,
    required this.duration,
    required this.excerpt,
    required this.color,
    required this.tags,
    required this.readCount,
  });
}

// ─── Helper Functions ─────────────────────────────────────────────────────────
void _showConnectMentor(BuildContext context, String name, String type) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Connect with $name',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(type, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          const Text(
            'Send a connection request. Once accepted, you\'ll be able to message each other through our secure peer support platform.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connection request sent to $name! 💜'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send Connection Request'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Maybe Later')),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

void _showComposePost(BuildContext context) {
  final controller = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16, left: 150),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            Text('Share with the Community',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Your experience can help someone feel less alone.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind today? A tip, a milestone, or just how you\'re feeling...',
                hintStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text('Anonymous posting is available on the full release.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post shared with the community! 💜'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: const Text('Share Post'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

void _showStory(BuildContext context, _Story story) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20, left: 150),
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [story.color.withValues(alpha: 0.2), story.color.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Icon(Icons.menu_book_rounded, color: story.color, size: 52)),
            ),
            const SizedBox(height: 20),
            Text(story.title,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3)),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: story.color.withValues(alpha: 0.15),
                  child: Text(story.initials,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: story.color)),
                ),
                const SizedBox(width: 8),
                Text(story.author, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Spacer(),
                Text(story.duration, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 16),
            Text(story.excerpt,
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.7)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: story.color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: story.color.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_stories_rounded, color: story.color, size: 28),
                  const SizedBox(height: 8),
                  Text('Full story coming in the next app update.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: story.color, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Thank you for being part of this community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close')),
          ],
        ),
      ),
    ),
  );
}
