import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme.dart';
import '../../l10n/app_localizations.dart';

class YusrOverlay extends StatefulWidget {
  const YusrOverlay({super.key});

  @override
  State<YusrOverlay> createState() => _YusrOverlayState();
}

class _YusrOverlayState extends State<YusrOverlay> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showCrisis = false;

  final _crisisKeywordsEn = ['suicide', 'self-harm', 'want to die', 'end my life', "don't want to live"];
  final _crisisKeywordsAr = ['انتحار', 'إيذاء', 'لا أريد أن أكمل', 'أريد أن أموت', 'لا أريد العيش'];

  bool _checkCrisis(String text, bool isArabic) {
    final keywords = isArabic ? _crisisKeywordsAr : _crisisKeywordsEn;
    return keywords.any((kw) => text.toLowerCase().contains(kw));
  }

  void _send(bool isArabic) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final isCrisis = _checkCrisis(text, isArabic);
    if (isCrisis) setState(() => _showCrisis = true);
    context.read<AppProvider>().sendChatMessage(text);
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      final l = AppLocalizations(isArabic: isAr);

      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('Y',
                              style: GoogleFonts.almarai(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.tabYusr,
                              style: GoogleFonts.almarai(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          Text(
                            isAr ? 'دائماً هنا · لستُ طبيبة' : 'Always here · Not a doctor',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: provider.chatMessages.length,
                    itemBuilder: (_, i) {
                      final msg = provider.chatMessages[i];
                      final isFirst = i == 0 && !msg.isUser;
                      return Column(
                        children: [
                          _MessageBubble(message: msg),
                          if (isFirst && provider.chatMessages.length == 1)
                            _PromptChips(
                              isArabic: isAr,
                              onChipTap: (text) {
                                _ctrl.text = text;
                                _send(isAr);
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Crisis card
                if (_showCrisis)
                  _CrisisCard(
                    isArabic: isAr,
                    onDismiss: () => setState(() => _showCrisis = false),
                  ),

                // Disclaimer
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Text(
                    isAr
                        ? 'هذا ليس نصيحة طبية'
                        : 'This is not medical advice',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic),
                  ),
                ),

                // Input bar
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          onSubmitted: (_) => _send(isAr),
                          style: GoogleFonts.inter(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: isAr
                                ? 'اسأليني أي شيء يخصّ صحتكِ...'
                                : 'Ask anything about your health...',
                            hintStyle:
                                GoogleFonts.inter(color: AppColors.textSecondary),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2)),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _send(isAr),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: Icon(
                            isAr ? Icons.arrow_back_ios_new : Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: Center(
                child: Text('Y',
                    style: GoogleFonts.almarai(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                  fontSize: 15,
                  color: isUser ? Colors.white : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptChips extends StatelessWidget {
  final bool isArabic;
  final ValueChanged<String> onChipTap;
  const _PromptChips({required this.isArabic, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    final prompts = isArabic
        ? [
            'ماذا تعني نتائج تحاليلي؟',
            'آثار جانبية للعلاج الكيميائي؟',
            'كيف أستعدّ لزيارتي؟',
            'أشعر بالقلق اليوم.',
          ]
        : [
            'What do my lab results mean?',
            'Side effects of chemo?',
            'How do I prepare for my visit?',
            'I am feeling anxious today.',
          ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: prompts.map((p) {
          return GestureDetector(
            onTap: () => onChipTap(p),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(p,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSecondary)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CrisisCard extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onDismiss;
  const _CrisisCard({required this.isArabic, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: isArabic
              ? const BorderSide(color: Color(0xFFDC2626), width: 4)
              : BorderSide.none,
          left: !isArabic
              ? const BorderSide(color: Color(0xFFDC2626), width: 4)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isArabic
                      ? 'إذا كنتِ تمرين بلحظة صعبة، يُسر هنا — ولكن يمكنكِ أيضاً التواصل مع:'
                      : 'If you\'re going through a difficult moment, Yusr is here — but you can also reach:',
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic ? '800 4673 — خط دعم الأزمات النفسية' : '800 4673 — Mental Health Crisis Line (UAE)',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFDC2626)),
          ),
          const SizedBox(height: 4),
          Text(
            isArabic ? 'أو اتصلي بـ 998 للطوارئ' : 'Or call 998 for emergency services',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
