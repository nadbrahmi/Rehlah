import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

// ─── AI Health Assistant Screen ────────────────────────────────────────────────
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _input = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;
  Timer? _typingTimer;
  late final AnimationController _pulseCtrl;

  // ── Quick suggestion chips ───────────────────────────────────────
  final List<_Suggestion> _suggestions = const [
    _Suggestion('What do my lab results mean?', Icons.science_rounded),
    _Suggestion('Side effects of chemo?', Icons.medication_rounded),
    _Suggestion('Tips for nausea?', Icons.sick_rounded),
    _Suggestion('When to call my doctor?', Icons.phone_rounded),
    _Suggestion('What is nadir?', Icons.help_rounded),
    _Suggestion('Managing fatigue tips', Icons.battery_charging_full_rounded),
    _Suggestion('Foods good during treatment', Icons.restaurant_rounded),
    _Suggestion('Infection warning signs', Icons.warning_rounded),
  ];

  // ── AI Knowledge Base ────────────────────────────────────────────
  final Map<String, _AIKnowledge> _knowledge = {
    'nausea': _AIKnowledge(
      response: "Here are the most effective strategies to manage treatment-related nausea:\n\n**Timing matters:**\n• Take anti-nausea medications 30–60 min before meals, not after\n• Eat small meals every 2–3 hours rather than large ones\n\n**Food choices:**\n• BRAT diet helps: Bananas, Rice, Applesauce, Toast\n• Cold or room-temperature foods cause less odor-triggered nausea\n• Ginger tea or ginger candies are clinically shown to help\n• Avoid greasy, spicy, or very sweet foods\n\n**Lifestyle:**\n• Sit upright for 30 minutes after eating\n• Fresh air and cool environments help\n• Distraction (TV, music, conversation) reduces perceived nausea\n\n⚠️ **Call your team if:** nausea leads to vomiting for more than 24 hours or you can't keep fluids down.",
      keywords: ['nausea', 'vomit', 'sick', 'queasy'],
      icon: Icons.sick_rounded,
      color: AppColors.info,
    ),
    'fatigue': _AIKnowledge(
      response: "Cancer-related fatigue is different from regular tiredness — it doesn't fully improve with rest. Here's what helps:\n\n**Conserve energy:**\n• Prioritize your activities — do the most important things first\n• Take short rest periods (20–30 min) rather than long naps\n• Accept help when offered — this is not giving up\n\n**Stay gently active:**\n• Even a 10-minute walk can reduce fatigue by 30% in studies\n• Yoga and stretching are excellent options\n• Avoid complete bed rest — it actually worsens fatigue\n\n**Nutrition:**\n• Iron-rich foods help if you're anemic (spinach, lentils, lean red meat)\n• Stay hydrated — dehydration amplifies fatigue significantly\n• Small frequent meals maintain stable energy\n\n**Track patterns:**\n• Log your energy in check-ins to spot your peak hours\n• Plan demanding tasks during your best energy windows",
      keywords: ['tired', 'fatigue', 'exhausted', 'energy', 'weak'],
      icon: Icons.battery_2_bar_rounded,
      color: Color(0xFFF59E0B),
    ),
    'labs': _AIKnowledge(
      response: "Great question! Here are the key blood values you'll track during cancer treatment:\n\n**CBC (Complete Blood Count):**\n• **WBC** (White Blood Cells): Your infection fighters. Low WBC = neutropenia = higher infection risk\n• **ANC** (Absolute Neutrophil Count): The most important infection-risk marker. Below 1.0 is concerning; below 0.5 is critical\n• **RBC & Hemoglobin**: Carry oxygen. Low = anemia → fatigue, shortness of breath\n• **Platelets**: Enable clotting. Low = bleeding/bruising risk\n\n**Metabolic Panel:**\n• **Creatinine**: Kidney function — important since many chemo drugs are processed by kidneys\n• **ALT/AST**: Liver function — some drugs affect the liver\n\n**Tumor Markers:**\n• These (like CA 15-3, CEA) measure cancer-related proteins\n• Declining markers = treatment is working 🎉\n• They should be interpreted alongside scans, never alone\n\nTap 'Lab Tracker' to see your personal values with AI analysis.",
      keywords: ['lab', 'blood', 'results', 'cbc', 'wbc', 'hemoglobin', 'markers', 'tumor'],
      icon: Icons.science_rounded,
      color: AppColors.accent,
    ),
    'nadir': _AIKnowledge(
      response: "**Nadir** is the period when your blood counts hit their lowest point after chemotherapy. Here's what you need to know:\n\n**When it happens:**\n• Usually 7–14 days after your chemo infusion\n• The exact timing depends on your specific regimen\n\n**Why it matters:**\n• Your WBC and ANC are at their lowest → highest infection risk\n• Platelets may be low → bruising/bleeding risk\n• You may feel more fatigued than usual\n\n**During nadir — protect yourself:**\n• 🚿 Wash hands frequently, especially before eating\n• 👥 Avoid large crowds and people who are sick\n• 🌡️ Check your temperature daily — fever (≥38°C/100.4°F) = call your team immediately\n• 🥗 Avoid raw/undercooked foods (neutropenic diet)\n• 🚫 No live vaccines during this window\n\n**Good news:** After nadir, your counts rebound and you'll feel better — typically by days 18–21.",
      keywords: ['nadir', 'lowest', 'counts drop', 'infection risk'],
      icon: Icons.warning_rounded,
      color: AppColors.danger,
    ),
    'doctor': _AIKnowledge(
      response: "**Call your care team immediately for these red flag symptoms:**\n\n🌡️ **Fever ≥38°C (100.4°F)** — even without other symptoms. This is the #1 reason to call immediately during treatment.\n\n🩸 **Unusual bleeding** — heavy or prolonged, or spontaneous bruising\n\n😮‍💨 **Severe shortness of breath** at rest or with minimal activity\n\n💔 **Chest pain** of any kind\n\n🤮 **Vomiting 24+ hours** or inability to keep fluids down\n\n🚽 **Bloody stool or urine**\n\n⚡ **Severe pain (7+ out of 10)** not controlled by your current medications\n\n🧠 **Confusion, dizziness, or sudden weakness**\n\n**Urgent but can wait a few hours:**\n• New rash or skin reaction\n• Mouth sores preventing eating\n• Swelling or redness at infusion site\n• New tingling/numbness\n\nYour care team would always rather you call than wait. When in doubt — call.",
      keywords: ['doctor', 'call', 'emergency', 'when', 'worried', 'concern'],
      icon: Icons.phone_rounded,
      color: AppColors.danger,
    ),
    'side effects': _AIKnowledge(
      response: "Chemotherapy side effects vary by your specific regimen, but common ones include:\n\n**Hair loss (alopecia):**\n• Usually starts 2–3 weeks after first cycle\n• Temporary in most cases — grows back after treatment\n• Cold caps can reduce hair loss for some regimens\n\n**Nausea and vomiting:**\n• Modern anti-nausea drugs are very effective — don't suffer in silence\n• Tell your team if your current regimen isn't controlling it\n\n**Peripheral neuropathy:**\n• Tingling, numbness, or pain in hands/feet\n• Common with certain drugs (taxanes, platinum agents)\n• Report early — dose adjustments may help prevent worsening\n\n**Mouth sores (mucositis):**\n• Rinse with saltwater or baking soda solution\n• Avoid alcohol-based mouthwashes\n• Soft foods and cold fluids help\n\n**Cognitive changes ('chemo brain'):**\n• Memory and concentration issues — very real and common\n• Puzzles, social engagement, and sleep help\n\nWhat specific side effect are you experiencing? I can give more targeted advice.",
      keywords: ['side effects', 'chemo', 'hair loss', 'neuropathy', 'brain fog'],
      icon: Icons.medication_rounded,
      color: AppColors.primary,
    ),
    'food': _AIKnowledge(
      response: "Nutrition during cancer treatment is very important for recovery and tolerance:\n\n**Best foods during treatment:**\n• 🥩 **Lean protein** (chicken, fish, eggs, legumes) — helps repair tissue and immune function\n• 🥦 **Colorful vegetables** — antioxidants support recovery (cook them during low counts to reduce infection risk)\n• 🍌 **Easy-to-digest carbs** (banana, rice, toast, oatmeal) — especially good for nausea days\n• 🥑 **Healthy fats** (avocado, nuts, olive oil) — calorie-dense for maintaining weight\n• 💧 **Fluids** — water, broth, herbal teas, electrolyte drinks\n\n**Foods to limit or avoid:**\n• Raw/undercooked meat, fish, eggs (during low counts)\n• Unpasteurized products (soft cheeses, raw milk)\n• Alcohol — interferes with treatment and liver function\n• High sugar ultra-processed foods\n\n**Practical tips:**\n• Eat your largest meal when you feel best (often morning)\n• Keep easy snacks accessible for low-energy days\n• Don't force yourself to eat — small amounts more often\n• If losing weight, mention it — nutritional support options exist",
      keywords: ['food', 'eat', 'nutrition', 'diet', 'meal'],
      icon: Icons.restaurant_rounded,
      color: AppColors.accent,
    ),
  };

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    // Initial greeting
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _addAIMessage(_buildGreeting());
    });
  }

  String _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    return "👋 $greeting! I'm your AI Health Assistant.\n\nI'm here to help you understand your treatment, lab values, manage side effects, and answer any health questions — anytime, day or night.\n\nI can explain your blood counts, give evidence-based tips for symptoms, tell you when to contact your care team, and more.\n\n**What would you like to know?** You can type a question or tap a suggestion below.";
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: false, timestamp: DateTime.now()));
    });
    _scrollToBottom();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _input.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate AI thinking delay
    final delay = 800 + Random().nextInt(1200);
    _typingTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      final response = _generateResponse(text);
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
  }

  String _generateResponse(String input) {
    final t = input.toLowerCase();

    // Match knowledge base
    for (final entry in _knowledge.entries) {
      if (entry.value.keywords.any((k) => t.contains(k))) {
        return entry.value.response;
      }
    }

    // Pattern matching fallbacks
    if (t.contains('pain') || t.contains('hurt')) {
      return "Pain management is important during treatment. Here are guidelines:\n\n**Mild pain (1-3/10):**\n• Acetaminophen (Tylenol) is usually safe — check with your team\n• Avoid NSAIDs (aspirin, ibuprofen) during low platelet periods\n\n**Moderate pain (4-6/10):**\n• Contact your care team — they can prescribe appropriate relief\n• Don't \"push through\" moderate pain — it affects your quality of life\n\n**Severe pain (7+/10):**\n• Call your care team immediately or go to urgent care\n• You should not be experiencing uncontrolled severe pain\n\nPain descriptions that help your doctor: location, type (stabbing/burning/aching), what makes it better or worse, and when it started.";
    }

    if (t.contains('scan') || t.contains('anxiety') || t.contains('scanxiety') || t.contains('scared') || t.contains('anxious') || t.contains('nervous')) {
      return "Scanxiety — the anxiety around imaging results — is incredibly common and completely valid. Here are evidence-based strategies:\n\n**Before the scan:**\n• Write down your questions for the doctor — preparation reduces anxiety\n• Plan something enjoyable for scan day and the day after\n• Bring a supportive person if allowed\n\n**Managing the wait:**\n• Limit \"googling\" symptoms — it almost always increases anxiety\n• Use the 4-7-8 breathing technique: inhale 4 counts, hold 7, exhale 8\n• Physical activity is the best anti-anxiety tool — even a short walk\n\n**Reframing:**\n• Scans are tools helping your team adjust treatment — they're on your side\n• You're already doing the hardest part by being in treatment\n\n**If anxiety is severe:**\n• Talk to your oncologist — short-term anxiety medication can help\n• Ask about a referral to an oncology social worker or psychologist\n• Your emotional health matters as much as your physical health 💜";
    }

    if (t.contains('hair') || t.contains('alopecia')) {
      return "Hair loss is one of the most emotionally difficult side effects for many patients. Here's what to know:\n\n**When it happens:**\n• Usually 2–3 weeks after first chemo cycle\n• Often starts suddenly — coming out in the shower or on the pillow\n\n**Managing it:**\n• Many people cut their hair short before it falls out — gives a sense of control\n• Cold caps (scalp cooling) reduce hair loss for some regimens — ask your team if you're a candidate\n• Head coverings, wigs, scarves, and hats are all valid choices\n\n**The good news:**\n• Hair almost always grows back after treatment ends\n• It often grows back differently at first (sometimes curly!) then returns to normal\n• Many people find they feel stronger for having gone through it\n\nYour feelings about hair loss are completely valid — there's no right or wrong way to feel about it. Consider connecting with others in the Community section who've shared this experience.";
    }

    if (t.contains('sleep') || t.contains('insomnia')) {
      return "Sleep disruption during cancer treatment is extremely common. Here's what helps:\n\n**Sleep hygiene:**\n• Keep a consistent sleep and wake time — even on weekends\n• Cool, dark, quiet room is ideal\n• Avoid screens 1 hour before bed (blue light disrupts melatonin)\n\n**If steroids are causing insomnia:**\n• Take them earlier in the day if your regimen allows\n• Talk to your oncology team — adjusting timing can help significantly\n\n**Natural aids:**\n• Melatonin (0.5–3mg) is generally safe — ask your team first\n• Chamomile tea, magnesium (glycinate form), and lavender aromatherapy\n• Progressive muscle relaxation before bed\n\n**When to ask for help:**\n• If insomnia lasts more than 2 weeks\n• If it's significantly affecting your quality of life\n• Cognitive Behavioral Therapy for Insomnia (CBT-I) is the most effective long-term treatment";
    }

    if (t.contains('hello') || t.contains('hi') || t.contains('hey')) {
      return "Hello! 👋 Great to hear from you. I'm here and ready to help with any questions about your treatment, symptoms, lab values, or anything related to your cancer journey.\n\nYou can ask me about side effects, what your blood counts mean, when to call your doctor, nutrition tips, managing anxiety — anything at all.\n\nWhat's on your mind today?";
    }

    if (t.contains('thank') || t.contains('thanks')) {
      return "You're so welcome! 💜 It's my honor to support you through this journey. Please don't hesitate to come back anytime — day or night — with questions, concerns, or just to talk through what you're experiencing.\n\nYou're not alone in this. Keep going — you're doing amazing.";
    }

    // Default intelligent response
    return "Thank you for your question. While I want to give you the most helpful answer, I want to make sure I understand correctly.\n\nCould you share a bit more detail about:\n• What specific symptom or topic you're asking about?\n• How long you've been experiencing it (if symptom-related)?\n• Is this something new or ongoing?\n\nAlternatively, here are some topics I can help with right now:\n• Lab values and blood counts\n• Side effect management (nausea, fatigue, pain, etc.)\n• When to contact your care team\n• Nutrition during treatment\n• Managing anxiety and emotional wellbeing\n\nYou can also tap one of the suggestion chips below to get started!";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
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
    _scrollCtrl.dispose();
    _input.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primaryDark, size: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.info],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Health Assistant',
                            style: GoogleFonts.inter(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Row(
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accent, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text('Always available • Cancer-care trained',
                                style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: AppColors.primaryDark, size: 18),
                  ),
                ],
              ),
            ),

            // ── Messages ───────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _TypingIndicator(ctrl: _pulseCtrl);
                  }
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),

            // ── Suggestion chips ────────────────────────────────────────
            if (!_isTyping && _messages.length <= 2)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final s = _suggestions[i];
                    return GestureDetector(
                      onTap: () => _sendMessage(s.text),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(s.icon, size: 13, color: AppColors.primaryDark),
                            const SizedBox(width: 5),
                            Text(s.text,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),

            // ── Input bar ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _input,
                        focusNode: _focusNode,
                        maxLines: 3,
                        minLines: 1,
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Ask anything about your health...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (v) => _sendMessage(v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_input.text),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.info],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.3),
                            blurRadius: 12, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Message Bubble ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(message.text,
                    style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.primarySurface, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.primaryDark, size: 15),
            ),
          ],
        ),
      );
    }

    // AI message with markdown-style bold
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.info]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: _FormattedText(text: message.text),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Formatted Text (pseudo-markdown) ─────────────────────────────────────────
class _FormattedText extends StatelessWidget {
  final String text;
  const _FormattedText({required this.text});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('**') && line.endsWith('**') && line.length > 4) {
          // Header bold
          final content = line.substring(2, line.length - 2);
          return Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(content, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
          );
        }
        if (line.isEmpty) return const SizedBox(height: 4);
        // Handle inline bold (**text**)
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: _InlineBoldText(line),
        );
      }).toList(),
    );
  }
}

class _InlineBoldText extends StatelessWidget {
  final String text;
  const _InlineBoldText(this.text);

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    if (parts.length <= 1) {
      return Text(text,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45));
    }
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontSize: 13,
          fontWeight: i.isOdd ? FontWeight.w700 : FontWeight.w400,
          color: i.isOdd ? AppColors.textPrimary : AppColors.textSecondary,
          height: 1.45,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  final AnimationController ctrl;
  const _TypingIndicator({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.info]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: List.generate(3, (i) => _Dot(ctrl: ctrl, delay: i * 0.2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  const _Dot({required this.ctrl, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = (ctrl.value + delay) % 1.0;
        final scale = 0.5 + sin(t * pi) * 0.5;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.4 + scale * 0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  const _ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class _Suggestion {
  final String text;
  final IconData icon;
  const _Suggestion(this.text, this.icon);
}

class _AIKnowledge {
  final String response;
  final List<String> keywords;
  final IconData icon;
  final Color color;
  const _AIKnowledge({required this.response, required this.keywords, required this.icon, required this.color});
}
