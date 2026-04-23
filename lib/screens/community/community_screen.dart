import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import '../main_screen.dart';
import '../yusr/yusr_overlay.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      final l = AppLocalizations(isArabic: isAr);
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: l.tabConnect,
                  subtitle: isAr
                      ? 'تواصلي مع من يفهمن ما تمرين به'
                      : 'Connect with those who understand',
                ),
                // Tab bar
                Container(
                  color: AppColors.surface,
                  child: TabBar(
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2,
                    labelStyle: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                    unselectedLabelStyle:
                        GoogleFonts.inter(fontSize: 14),
                    tabs: [
                      Tab(text: isAr ? 'التغذية' : 'Feed'),
                      Tab(text: isAr ? 'القصص' : 'Stories'),
                      Tab(text: isAr ? 'المدربون' : 'Coaches'),
                      Tab(text: isAr ? 'المرشدون' : 'Mentors'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _FeedTab(isAr: isAr),
                      _StoriesTab(isAr: isAr),
                      _CoachesTab(isAr: isAr),
                      _MentorsTab(isAr: isAr),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ── Feed Tab ──────────────────────────────────────────────────────────────────
class _FeedTab extends StatelessWidget {
  final bool isAr;
  const _FeedTab({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          // Circle messages
          ...provider.circleMessages
              .map((msg) => _CircleMessageTile(msg: msg, isAr: isAr, provider: provider)),

          const SizedBox(height: 8),
          // Add message field
          _AddMessageField(isAr: isAr),
          const SizedBox(height: 20),

          // Yusr suggestion at bottom of feed
          _YusrSuggestionCard(isAr: isAr),
          const SizedBox(height: 16),
        ],
      );
    });
  }
}

class _CircleMessageTile extends StatelessWidget {
  final CircleMessage msg;
  final bool isAr;
  final AppProvider provider;
  const _CircleMessageTile(
      {required this.msg, required this.isAr, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  msg.initials,
                  style: GoogleFonts.almarai(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(msg.author,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              Text(msg.time,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(msg.text,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 12),
          // Reactions
          Row(
            children: msg.reactions.entries.map((e) {
              final idx = provider.circleMessages.indexOf(msg);
              return GestureDetector(
                onTap: () => idx >= 0 ? provider.addReaction(idx, e.key) : null,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: e.value > 0
                        ? AppColors.primaryLight
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${e.key} ${e.value}',
                    style:
                        GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AddMessageField extends StatefulWidget {
  final bool isAr;
  const _AddMessageField({required this.isAr});

  @override
  State<_AddMessageField> createState() => _AddMessageFieldState();
}

class _AddMessageFieldState extends State<_AddMessageField> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            textAlign: widget.isAr ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: widget.isAr
                  ? 'شاركي تجربتكِ مع الدائرة...'
                  : 'Share with your circle...',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            final text = _ctrl.text.trim();
            if (text.isEmpty) return;
            context.read<AppProvider>().addCircleMessage(text);
            _ctrl.clear();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: Icon(
              widget.isAr ? Icons.arrow_back_ios_new : Icons.send_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stories Tab ───────────────────────────────────────────────────────────────
class _StoriesTab extends StatelessWidget {
  final bool isAr;
  const _StoriesTab({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final stories = isAr
        ? [
            ('هيفاء، ٣٤', 'سرطان الثدي، المرحلة الثانية', 'ثلاث سنوات بعد العلاج', '💜'),
            ('مريم، ٤٢', 'سرطان عنق الرحم', 'سنة واحدة بعد العلاج', '🌟'),
            ('فاطمة، ٢٩', 'سرطان المبيض', 'خمس سنوات بعد العلاج', '✨'),
            ('نورة، ٥١', 'سرطان القولون', 'سنتان بعد العلاج', '🌸'),
          ]
        : [
            ('Hessa, 34', 'Breast cancer, Stage II', '3 years post-treatment', '💜'),
            ('Mariam, 42', 'Cervical cancer', '1 year post-treatment', '🌟'),
            ('Fatima, 29', 'Ovarian cancer', '5 years post-treatment', '✨'),
            ('Noura, 51', 'Colorectal cancer', '2 years post-treatment', '🌸'),
          ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Text(
          isAr
              ? 'قصص ناجيات يلهمن الأمل'
              : 'Stories from survivors who inspire hope',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        ...stories.map((s) => _StoryCard(
              name: s.$1,
              type: s.$2,
              postTreatment: s.$3,
              emoji: s.$4,
              isAr: isAr,
            )),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String name;
  final String type;
  final String postTreatment;
  final String emoji;
  final bool isAr;
  const _StoryCard({
    required this.name,
    required this.type,
    required this.postTreatment,
    required this.emoji,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(type,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.tealLight,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(postTreatment,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.teal)),
                ),
              ],
            ),
          ),
          Icon(
            isAr ? Icons.chevron_left : Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ── Coaches Tab ───────────────────────────────────────────────────────────────
class _CoachesTab extends StatelessWidget {
  final bool isAr;
  const _CoachesTab({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final coaches = [
      _CoachData(
        initials: 'AA',
        nameEn: 'Dr. Aisha Al Mansoori',
        nameAr: 'د. عائشة المنصوري',
        titleEn: 'Oncology Wellness Coach',
        titleAr: 'مدربة صحة السرطان',
        specialtyEn: 'Chemotherapy support · Mindfulness',
        specialtyAr: 'دعم العلاج الكيميائي · اليقظة الذهنية',
        languagesEn: 'Arabic · English',
        languagesAr: 'العربية · الإنجليزية',
        color: const Color(0xFFE0E7FF),
        textColor: const Color(0xFF4338CA),
      ),
      _CoachData(
        initials: 'FH',
        nameEn: 'Fatima Hassan',
        nameAr: 'فاطمة حسن',
        titleEn: 'Cancer Rehabilitation Specialist',
        titleAr: 'أخصائية تأهيل السرطان',
        specialtyEn: 'Nutrition · Physical recovery',
        specialtyAr: 'التغذية · التعافي الجسدي',
        languagesEn: 'Arabic · English · French',
        languagesAr: 'العربية · الإنجليزية · الفرنسية',
        color: const Color(0xFFF0FDFA),
        textColor: AppColors.teal,
      ),
      _CoachData(
        initials: 'SH',
        nameEn: 'Sara Al Hamdan',
        nameAr: 'سارة الحمدان',
        titleEn: 'Psychological Support Coach',
        titleAr: 'مدربة الدعم النفسي',
        specialtyEn: 'Emotional wellbeing · Anxiety',
        specialtyAr: 'الرفاه العاطفي · القلق',
        languagesEn: 'Arabic · English',
        languagesAr: 'العربية · الإنجليزية',
        color: const Color(0xFFF5F3FF),
        textColor: AppColors.primary,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: coaches
          .map((c) => _CoachCard(coach: c, isAr: isAr))
          .toList(),
    );
  }
}

class _CoachData {
  final String initials;
  final String nameEn;
  final String nameAr;
  final String titleEn;
  final String titleAr;
  final String specialtyEn;
  final String specialtyAr;
  final String languagesEn;
  final String languagesAr;
  final Color color;
  final Color textColor;

  const _CoachData({
    required this.initials,
    required this.nameEn,
    required this.nameAr,
    required this.titleEn,
    required this.titleAr,
    required this.specialtyEn,
    required this.specialtyAr,
    required this.languagesEn,
    required this.languagesAr,
    required this.color,
    required this.textColor,
  });
}

class _CoachCard extends StatelessWidget {
  final _CoachData coach;
  final bool isAr;
  const _CoachCard({required this.coach, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: coach.color,
                child: Text(
                  coach.initials,
                  style: GoogleFonts.almarai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: coach.textColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? coach.nameAr : coach.nameEn,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr ? coach.titleAr : coach.titleEn,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
              Icons.star_outline,
              isAr ? coach.specialtyAr : coach.specialtyEn),
          const SizedBox(height: 6),
          _InfoRow(
              Icons.language,
              isAr ? coach.languagesAr : coach.languagesEn),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => _showRequestOverlay(context, isAr,
                isAr ? coach.nameAr : coach.nameEn),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              isAr ? 'طلب التواصل' : 'Request Connection',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestOverlay(BuildContext context, bool isAr, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestSheet(isAr: isAr, name: name),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

// ── Mentors Tab ───────────────────────────────────────────────────────────────
class _MentorsTab extends StatelessWidget {
  final bool isAr;
  const _MentorsTab({required this.isAr});

  @override
  Widget build(BuildContext context) {
    final mentors = [
      _MentorData(
        initials: 'H',
        nameEn: 'Hessa',
        nameAr: 'هيساء',
        cancerTypeEn: 'Breast Cancer',
        cancerTypeAr: 'سرطان الثدي',
        yearsPostEn: '4 years post-treatment',
        yearsPostAr: '٤ سنوات بعد العلاج',
        quoteEn:
            'The hardest part was not the treatment — it was feeling alone. You are not alone.',
        quoteAr:
            'الجزء الأصعب لم يكن العلاج — بل الشعور بالوحدة. أنتِ لستِ وحدكِ.',
        languagesEn: 'Arabic · English',
        languagesAr: 'العربية · الإنجليزية',
      ),
      _MentorData(
        initials: 'M',
        nameEn: 'Mona',
        nameAr: 'منى',
        cancerTypeEn: 'Cervical Cancer',
        cancerTypeAr: 'سرطان عنق الرحم',
        yearsPostEn: '2 years post-treatment',
        yearsPostAr: 'سنتان بعد العلاج',
        quoteEn:
            'Every side effect I had, I wish someone had warned me. I am here to be that person for you.',
        quoteAr:
            'كل أعراض جانبية مررتُ بها، كنتُ أتمنى لو كان هناك من ينبّهني. أنا هنا لأكون ذلك الشخص لكِ.',
        languagesEn: 'Arabic',
        languagesAr: 'العربية',
      ),
      _MentorData(
        initials: 'N',
        nameEn: 'Noura',
        nameAr: 'نورة',
        cancerTypeEn: 'Ovarian Cancer',
        cancerTypeAr: 'سرطان المبيض',
        yearsPostEn: '6 years post-treatment',
        yearsPostAr: '٦ سنوات بعد العلاج',
        quoteEn: 'Life after treatment is possible and beautiful.',
        quoteAr: 'الحياة بعد العلاج ممكنة وجميلة.',
        languagesEn: 'Arabic · English · Urdu',
        languagesAr: 'العربية · الإنجليزية · الأردية',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: mentors
          .map((m) => _MentorCard(mentor: m, isAr: isAr))
          .toList(),
    );
  }
}

class _MentorData {
  final String initials;
  final String nameEn;
  final String nameAr;
  final String cancerTypeEn;
  final String cancerTypeAr;
  final String yearsPostEn;
  final String yearsPostAr;
  final String quoteEn;
  final String quoteAr;
  final String languagesEn;
  final String languagesAr;

  const _MentorData({
    required this.initials,
    required this.nameEn,
    required this.nameAr,
    required this.cancerTypeEn,
    required this.cancerTypeAr,
    required this.yearsPostEn,
    required this.yearsPostAr,
    required this.quoteEn,
    required this.quoteAr,
    required this.languagesEn,
    required this.languagesAr,
  });
}

class _MentorCard extends StatelessWidget {
  final _MentorData mentor;
  final bool isAr;
  const _MentorCard({required this.mentor, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  mentor.initials,
                  style: GoogleFonts.almarai(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? mentor.nameAr : mentor.nameEn,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr ? mentor.cancerTypeAr : mentor.cancerTypeEn,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.tealLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  isAr ? mentor.yearsPostAr : mentor.yearsPostEn,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Quote
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('"',
                    style:
                        TextStyle(fontSize: 28, color: AppColors.primary)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isAr ? mentor.quoteAr : mentor.quoteEn,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontStyle: FontStyle.italic,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(Icons.language,
              isAr ? mentor.languagesAr : mentor.languagesEn),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => _showRequestOverlay(context, isAr,
                isAr ? mentor.nameAr : mentor.nameEn),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              isAr ? 'طلب التواصل' : 'Request Connection',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestOverlay(BuildContext context, bool isAr, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestSheet(isAr: isAr, name: name),
    );
  }
}

// ── Request Connection Sheet ──────────────────────────────────────────────────
class _RequestSheet extends StatefulWidget {
  final bool isAr;
  final String name;
  const _RequestSheet({required this.isAr, required this.name});

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  final _ctrl = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _submitted
            ? _ConfirmationView(isAr: isAr)
            : _RequestFormView(
                isAr: isAr,
                name: widget.name,
                ctrl: _ctrl,
                onSubmit: () => setState(() => _submitted = true),
              ),
      ),
    );
  }
}

class _RequestFormView extends StatelessWidget {
  final bool isAr;
  final String name;
  final TextEditingController ctrl;
  final VoidCallback onSubmit;
  const _RequestFormView({
    required this.isAr,
    required this.name,
    required this.ctrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr
              ? 'طلب التواصل مع $name'
              : 'Request connection with $name',
          style: GoogleFonts.almarai(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          isAr
              ? 'أخبريها باختصار لماذا تودّين التواصل'
              : 'Tell her briefly why you would like to connect',
          style:
              GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: ctrl,
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          maxLines: 3,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: isAr
                ? 'مثلاً: أمر بعلاج مشابه وأريد نصيحتكِ...'
                : 'e.g. I am going through similar treatment and would love your advice...',
            hintStyle:
                GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: Text(
              isAr ? 'إرسال الطلب' : 'Send Request',
              style: GoogleFonts.almarai(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationView extends StatelessWidget {
  final bool isAr;
  const _ConfirmationView({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
              color: AppColors.tealLight, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: AppColors.teal, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          isAr ? 'تم إرسال الطلب ✓' : 'Request sent ✓',
          style: GoogleFonts.almarai(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.teal),
        ),
        const SizedBox(height: 10),
        Text(
          isAr
              ? 'ستتلقّين رداً خلال ٤٨ ساعة.'
              : 'You will hear back within 48 hours.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            isAr ? 'إغلاق' : 'Close',
            style: GoogleFonts.inter(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Yusr Suggestion Card ──────────────────────────────────────────────────────
class _YusrSuggestionCard extends StatelessWidget {
  final bool isAr;
  const _YusrSuggestionCard({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) => const YusrOverlay(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: isAr
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary, width: 3),
            right: isAr
                ? const BorderSide(color: AppColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isAr
                    ? 'هل تودّين التحدث عن ما تشعرين به؟ يُسر تستمع.'
                    : 'Would you like to talk about how you feel? Yusr is listening.',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isAr ? 'تحدثي مع يُسر ←' : 'Chat with Yusr →',
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
