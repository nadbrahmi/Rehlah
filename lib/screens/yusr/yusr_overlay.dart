import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _focusNode = FocusNode();
  bool _showCrisis = false;
  bool _isTyping = false;

  final _crisisKeywordsEn = [
    'suicide', 'self-harm', 'want to die', 'end my life', "don't want to live"
  ];
  final _crisisKeywordsAr = [
    'انتحار', 'إيذاء', 'لا أريد أن أكمل', 'أريد أن أموت', 'لا أريد العيش'
  ];

  bool _checkCrisis(String text, bool isArabic) {
    final kw = isArabic ? _crisisKeywordsAr : _crisisKeywordsEn;
    return kw.any((k) => text.toLowerCase().contains(k));
  }

  void _send(bool isAr) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    if (_checkCrisis(text, isAr)) setState(() => _showCrisis = true);
    context.read<AppProvider>().sendChatMessage(text);
    _ctrl.clear();
    setState(() => _isTyping = false);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isAr = provider.isArabic;
      // ignore: unused_local_variable
      final l = AppLocalizations(isArabic: isAr);

      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              _YusrHeader(isAr: isAr),

              // ── Messages area ────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  itemCount: provider.chatMessages.length,
                  itemBuilder: (_, i) {
                    final msg = provider.chatMessages[i];
                    final showChips =
                        i == 0 && !msg.isUser && provider.chatMessages.length == 1;
                    return Column(
                      children: [
                        _MessageBubble(message: msg),
                        if (showChips)
                          _PromptChips(
                            isArabic: isAr,
                            onChipTap: (t) {
                              _ctrl.text = t;
                              _send(isAr);
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),

              // ── Crisis banner ────────────────────────────────────────
              if (_showCrisis)
                _CrisisCard(
                  isArabic: isAr,
                  onDismiss: () => setState(() => _showCrisis = false),
                ),

              // ── Disclaimer ───────────────────────────────────────────
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 11, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      isAr ? 'هذا ليس نصيحة طبية' : 'Not medical advice · Private & secure',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textTertiary,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),

              // ── Input bar ────────────────────────────────────────────
              Container(
                color: AppColors.surface,
                padding: EdgeInsets.only(
                  left: 20, right: 20,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isTyping
                                ? AppColors.primary
                                : AppColors.border,
                            width: _isTyping ? 1.5 : 1,
                          ),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focusNode,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          maxLines: 4,
                          minLines: 1,
                          onSubmitted: (_) => _send(isAr),
                          onChanged: (v) =>
                              setState(() => _isTyping = v.isNotEmpty),
                          style: GoogleFonts.inter(
                              fontSize: 15, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: isAr
                                ? 'اسأليني أي شيء...'
                                : 'Ask anything about your health...',
                            hintStyle: GoogleFonts.inter(
                                fontSize: 14, color: AppColors.textTertiary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _send(isAr),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: _isTyping
                              ? const LinearGradient(
                                  colors: [AppColors.primaryMid, AppColors.gradEnd],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _isTyping ? null : AppColors.border,
                          shape: BoxShape.circle,
                          boxShadow: _isTyping ? shadowPurple(opacity: 0.28) : [],
                        ),
                        child: Icon(
                          isAr ? Icons.arrow_back_ios_new_rounded : Icons.send_rounded,
                          color: _isTyping ? Colors.white : AppColors.textTertiary,
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
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Header
// ─────────────────────────────────────────────────────────────────────────────
class _YusrHeader extends StatelessWidget {
  final bool isAr;
  const _YusrHeader({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: shadowSm,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20, right: 20, bottom: 14,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                isAr ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Yusr avatar
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryMid, AppColors.gradEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: shadowPurple(opacity: 0.2),
            ),
            child: Center(
              child: Text('Y',
                  style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'يُسر' : 'Yusr',
                  style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                          color: Color(0xFF10B981), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Message Bubble
// ─────────────────────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryMid, AppColors.gradEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('Y',
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            decoration: BoxDecoration(
              gradient: isUser
                  ? const LinearGradient(
                      colors: [AppColors.primaryMid, AppColors.gradEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isUser ? null : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              border: isUser
                  ? null
                  : Border.all(color: AppColors.border),
              boxShadow: isUser ? shadowPurple(opacity: 0.15) : shadowSm,
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.5),
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Prompt Chips
// ─────────────────────────────────────────────────────────────────────────────
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
      padding: const EdgeInsets.only(bottom: 20, top: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: prompts.map((p) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChipTap(p);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.primaryBorder),
                borderRadius: BorderRadius.circular(22),
                boxShadow: shadowSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 12, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(p,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Crisis Card
// ─────────────────────────────────────────────────────────────────────────────
class _CrisisCard extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onDismiss;
  const _CrisisCard({required this.isArabic, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redBorder),
        boxShadow: shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: AppColors.emergencyRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: AppColors.emergencyRed, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isArabic ? 'يُسر هنا معكِ.' : 'Yusr is here with you.',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.emergencyRed),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Icon(Icons.close_rounded,
                    size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? 'إذا كنتِ تمرين بلحظة صعبة، يمكنكِ التواصل مع:'
                : 'If you\'re going through a difficult moment, you can also reach:',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.redBorder),
            ),
            child: Text(
              isArabic
                  ? '800 4673 — خط دعم الأزمات النفسية'
                  : '800 4673 — Mental Health Crisis Line (UAE)',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: AppColors.emergencyRed),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isArabic ? 'أو اتصلي بـ 998 للطوارئ' : 'Or call 998 for emergency services',
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
