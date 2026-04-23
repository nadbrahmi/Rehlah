import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';
import '../main_screen.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      final l = AppLocalizations(isArabic: isAr);
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ScreenHeader(
                  title: l.tabConnect,
                  subtitle: isAr
                      ? 'أنتِ لستِ وحدكِ في هذه الرحلة'
                      : 'You are not alone on this journey',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Section 1 — Coach
                    _CoachCard(isArabic: isAr),
                    const SizedBox(height: 16),
                    // Section 2 — Circle
                    _CircleCard(provider: provider, isArabic: isAr),
                    const SizedBox(height: 16),
                    // Section 3 — Stories
                    _StoriesSection(isArabic: isAr),
                    const SizedBox(height: 16),
                    // Section 4 — UAE Resources
                    _UAEResourcesSection(isArabic: isAr),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        isAr
                            ? 'رحلة يُسر هنا معكِ في كل خطوة'
                            : 'Rehlah is with you every step of the way',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Coach Card ────────────────────────────────────────────────────────────────
class _CoachCard extends StatelessWidget {
  final bool isArabic;
  const _CoachCard({this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'مرشدتكِ الشخصية' : 'Your personal coach',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary,
                child: Text(
                  isArabic ? 'هـ' : 'H',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'هيسة' : 'Haessa',
                      style: GoogleFonts.almarai(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      isArabic
                          ? 'ناجية من سرطان الثدي · أنهت علاجها ٢٠٢٤'
                          : 'Breast cancer survivor · Completed treatment 2024',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isArabic ? 'ردّت قبل ساعتين' : 'Replied 2 hours ago',
                      style:
                          GoogleFonts.inter(fontSize: 12, color: AppColors.teal),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'أتطوّع لأن أحداً ساعدني في أصعب أيامي.'
                : 'I volunteer because someone helped me through my hardest days.',
            style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showMessageSheet(context, isArabic),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isArabic ? 'راسليها' : 'Message her',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    isArabic ? 'عرض الملف' : 'View profile',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMessageSheet(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Directionality(
        textDirection:
            isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'راسلي هيسة' : 'Message Haessa',
                style: GoogleFonts.almarai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextField(
                textAlign:
                    isArabic ? TextAlign.right : TextAlign.left,
                maxLines: 4,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: isArabic
                      ? 'اكتبي رسالتكِ هنا...'
                      : 'Write your message here...',
                  hintStyle: GoogleFonts.inter(
                      color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Text(
                  isArabic ? 'إرسال' : 'Send',
                  style: GoogleFonts.almarai(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Circle Card ───────────────────────────────────────────────────────────────
class _CircleCard extends StatelessWidget {
  final AppProvider provider;
  final bool isArabic;
  const _CircleCard({required this.provider, this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'دائرتكِ' : 'Your circle',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                isArabic ? 'دائرة الدورة الثانية' : 'Cycle 2 Circle',
                style: GoogleFonts.almarai(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  isArabic ? '١٠ عضوات' : '10 members',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (provider.circleMessages.isNotEmpty) ...[
            Text(
              '${provider.circleMessages.first.author}: ${provider.circleMessages.first.text}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            Text(
              provider.circleMessages.first.time,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => Directionality(
                          textDirection: isArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: _CircleScreen(isArabic: isArabic),
                        )),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isArabic ? 'افتحي الدائرة' : 'Open circle',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circle Screen ─────────────────────────────────────────────────────────────
class _CircleScreen extends StatefulWidget {
  final bool isArabic;
  const _CircleScreen({this.isArabic = true});

  @override
  State<_CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends State<_CircleScreen> {
  final _ctrl = TextEditingController();
  int _charCount = 0;

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    return Consumer<AppProvider>(builder: (_, provider, __) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'دائرة الدورة الثانية' : 'Cycle 2 Circle',
                style: GoogleFonts.almarai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              Text(
                isAr ? '١٠ عضوات' : '10 members',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          leading: IconButton(
            icon: Icon(
                isAr
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios,
                color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Disclaimer
            Container(
              width: double.infinity,
              color: AppColors.amberLight,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                isAr
                    ? 'هذه مساحة دعم عاطفي فقط. لا نصائح طبية. المشاركة طوعية.'
                    : 'This is an emotional support space only. No medical advice. Participation is voluntary.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.amberDark),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: true,
                itemCount: provider.circleMessages.length,
                itemBuilder: (_, i) => _CircleMessageTile(
                  message: provider.circleMessages[i],
                  onReact: (emoji) => provider.addReaction(i, emoji),
                ),
              ),
            ),
            // Input bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$_charCount/280',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          textAlign:
                              isAr ? TextAlign.right : TextAlign.left,
                          maxLength: 280,
                          onChanged: (v) =>
                              setState(() => _charCount = v.length),
                          style: GoogleFonts.inter(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: isAr
                                ? 'شاركي شيئاً...'
                                : 'Share something...',
                            hintStyle: GoogleFonts.inter(
                                color: AppColors.textSecondary),
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                    color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2)),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (_ctrl.text.trim().isNotEmpty) {
                            provider
                                .addCircleMessage(_ctrl.text.trim());
                            _ctrl.clear();
                            setState(() => _charCount = 0);
                          }
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle),
                          child: Icon(
                            isAr
                                ? Icons.arrow_back_ios_new
                                : Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CircleMessageTile extends StatelessWidget {
  final CircleMessage message;
  final ValueChanged<String> onReact;
  const _CircleMessageTile(
      {required this.message, required this.onReact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(message.initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(message.author,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(width: 6),
                    Text(message.time,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 4)
                    ],
                  ),
                  child: Text(message.text,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: message.reactions.entries.map((e) {
                    final count = e.value;
                    return GestureDetector(
                      onTap: () => onReact(e.key),
                      child: Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text('${e.key} $count',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stories Section ───────────────────────────────────────────────────────────
class _StoriesSection extends StatelessWidget {
  final bool isArabic;
  const _StoriesSection({this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    final stories = isArabic
        ? [
            (
              'نورة م.',
              'سرطان الثدي',
              'في الأسبوع السادس من العلاج كنت أعتقد أنني لن أتحمّل. ثم...',
              '٣ دقائق'
            ),
            (
              'منى ع.',
              'سرطان عنق الرحم',
              'أصعب ما في الأمر لم يكن الألم بل الانتظار بين...',
              '٤ دقائق'
            ),
          ]
        : [
            (
              'Noura M.',
              'Breast cancer',
              'In week six of treatment I thought I couldn\'t bear it. Then...',
              '3 min'
            ),
            (
              'Mona A.',
              'Cervical cancer',
              'The hardest part wasn\'t the pain, but waiting between...',
              '4 min'
            ),
          ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isArabic ? 'قصص ناجيات' : 'Survivor stories',
              style: GoogleFonts.almarai(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            Text(
              isArabic ? 'عرض الكل' : 'View all',
              style:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: stories.map((s) {
            return Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => Directionality(
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: _StoryScreen(
                                author: s.$1,
                                tag: s.$2,
                                preview: s.$3,
                                isArabic: isArabic),
                          )),
                ),
                child: Container(
                  margin:
                      EdgeInsets.only(left: stories.indexOf(s) == 0 ? 8 : 0),
                  decoration: cardDecoration(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$1,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(s.$2,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.primary)),
                      ),
                      const SizedBox(height: 8),
                      Text(s.$3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Text(s.$4,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            isArabic
                ? 'هل تريدين مشاركة قصتكِ؟'
                : 'Would you like to share your story?',
            style:
                GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _StoryScreen extends StatelessWidget {
  final String author;
  final String tag;
  final String preview;
  final bool isArabic;
  const _StoryScreen(
      {required this.author,
      required this.tag,
      required this.preview,
      this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    final sections = isArabic
        ? [
            (
              'اللحظة الأولى',
              'في اللحظة التي سمعتُ فيها التشخيص، شعرتُ بأن الأرض انزلقت من تحت قدميّ. لكن مع مرور الوقت، بدأتُ أتعلم كيف أعيش يوماً بيوم.'
            ),
            (
              'أصعب يوم',
              'كانت جلسة العلاج الثالثة الأصعب على الإطلاق. الغثيان والإرهاق وصل لذروته، لكنني تذكرتُ سببي في المقاومة وقررتُ المضي قدماً.'
            ),
            (
              'ما ساعدني',
              'الدعم العائلي كان لا يُقدّر. وكذلك التحدث مع نساء مررن بنفس التجربة — أدركتُ أنني لستُ وحدي.'
            ),
            (
              'رسالتي لكِ',
              'اليوم أكتب إليكِ من مكان الامتنان والأمل. هذا الطريق صعب، لكنكِ لستِ وحدكِ. كل يوم تعبرينه هو انتصار.'
            ),
          ]
        : [
            (
              'The first moment',
              'When I heard the diagnosis, I felt the ground slip from under my feet. But as time passed, I began to learn how to live one day at a time.'
            ),
            (
              'The hardest day',
              'The third treatment session was the hardest of all. The nausea and fatigue peaked, but I remembered my reason to fight and chose to keep going.'
            ),
            (
              'What helped me',
              'Family support was invaluable. So was talking to women who had been through the same experience — I realized I was not alone.'
            ),
            (
              'My message to you',
              'Today I write to you from a place of gratitude and hope. This path is hard, but you are not alone. Every day you get through is a victory.'
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(
              isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(author,
                style: GoogleFonts.almarai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: Text(tag,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.primary)),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: sections.length,
        separatorBuilder: (_, __) => Container(
          height: 1,
          color: AppColors.primaryLight,
          margin: const EdgeInsets.symmetric(vertical: 20),
        ),
        itemBuilder: (_, i) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sections[i].$1,
                style: GoogleFonts.almarai(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 10),
            Text(sections[i].$2,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    height: 1.7)),
          ],
        ),
      ),
    );
  }
}

// ── UAE Resources ─────────────────────────────────────────────────────────────
class _UAEResourcesSection extends StatelessWidget {
  final bool isArabic;
  const _UAEResourcesSection({this.isArabic = true});

  @override
  Widget build(BuildContext context) {
    final resources = isArabic
        ? [
            (
              '🏥',
              'مستشفى توام للأورام',
              'العين · ٩٧١-٣-٧٦٧-٨٨٨٨+',
              'tel:+97137678888'
            ),
            (
              '🎗️',
              'جمعية الإمارات للسرطان',
              'دبي · ٩٧١-٤-٣٣٨-٨٧٤٧+',
              'tel:+97143388747'
            ),
            (
              '💛',
              'مؤسسة الجليلة',
              'منح دعم المرضى',
              'https://jaf.org.ae'
            ),
            (
              '📞',
              'خط دعم هيئة الصحة دبي',
              '٨٠٠ DHA (٣٤٢) · ٢٤/٧',
              'tel:+971800342'
            ),
            (
              '🎀',
              'القافلة الوردية',
              'دعم سرطان الثدي في الإمارات',
              'https://pinkcaravan.ae'
            ),
          ]
        : [
            (
              '🏥',
              'Tawam Oncology Hospital',
              'Al Ain · +971-3-767-8888',
              'tel:+97137678888'
            ),
            (
              '🎗️',
              'Emirates Cancer Society',
              'Dubai · +971-4-338-8747',
              'tel:+97143388747'
            ),
            (
              '💛',
              'Al Jalila Foundation',
              'Patient support grants',
              'https://jaf.org.ae'
            ),
            (
              '📞',
              'Dubai Health Authority Helpline',
              '800 DHA (342) · 24/7',
              'tel:+971800342'
            ),
            (
              '🎀',
              'Pink Caravan',
              'Breast cancer support in UAE',
              'https://pinkcaravan.ae'
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'الدعم في الإمارات' : 'Support in UAE',
          style: GoogleFonts.almarai(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: cardDecoration(),
          child: Column(
            children: List.generate(resources.length, (i) {
              final r = resources[i];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      try {
                        launchUrl(Uri.parse(r.$4));
                      } catch (_) {}
                    },
                    borderRadius: i == 0
                        ? const BorderRadius.vertical(
                            top: Radius.circular(16))
                        : i == resources.length - 1
                            ? const BorderRadius.vertical(
                                bottom: Radius.circular(16))
                            : BorderRadius.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text(r.$1,
                                    style:
                                        const TextStyle(fontSize: 16))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(r.$2,
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                                Text(r.$3,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Icon(
                            isArabic
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < resources.length - 1)
                    const Divider(
                        height: 1, indent: 64, color: AppColors.border),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
