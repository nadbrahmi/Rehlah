import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/models.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hi Nadia. I'm here whenever you need me — ask anything about your treatment or how you're feeling. 💜",
      isUser: false,
      timestamp: DateTime(2026, 4, 24, 9, 41),
    ),
    ChatMessage(
      text: 'What does low hemoglobin mean?',
      isUser: true,
      timestamp: DateTime(2026, 4, 24, 9, 51),
    ),
    ChatMessage(
      text: 'Low hemoglobin means your blood carries less oxygen — causing tiredness, breathlessness, or dizziness. During chemo this is very common. Rest when your body asks. That\'s not weakness — it\'s wisdom. 💜',
      isUser: false,
      timestamp: DateTime(2026, 4, 24, 9, 51),
    ),
  ];
  bool _isTyping = false;

  final _suggestions = [
    'Tips for fatigue',
    'When to call doctor',
    'Nausea help',
    'What is nadir?',
  ];

  void _send(String text) async {
    if (text.trim().isEmpty) return;
    final msg = text.trim();
    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: msg, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });
    _scroll();
    // Simulate AI response (replace with actual Anthropic API call)
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: "I understand you're asking about \"$msg\". This is a great question for your care journey. For specific medical advice, always consult your oncology team — but I'm here to help you understand and prepare. 💜",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scroll();
  }

  void _scroll() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : context.go('/'),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppColors.text2),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryMid, width: 0.5),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                      size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rehlah AI',
                        style: TextStyle(fontFamily: 'Inter',
                          fontSize: 14, fontWeight: FontWeight.w500,
                          color: AppColors.text1)),
                      Text('Here for you',
                        style: TextStyle(fontFamily: 'Inter',
                          fontSize: 11, color: AppColors.teal)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isTyping && i == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[i]);
              },
            ),
          ),
          // Suggestions
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              itemCount: _suggestions.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _send(_suggestions[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.fullBR,
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(_suggestions[i],
                    style: const TextStyle(fontFamily: 'Inter',
                      fontSize: 12, color: AppColors.primary)),
                ),
              ),
            ),
          ),
          // Input
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            padding: EdgeInsets.fromLTRB(
              16, 9, 16, 12 + MediaQuery.of(context).padding.bottom),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontFamily: 'Inter',
                      fontSize: 13, color: AppColors.text1),
                    decoration: InputDecoration(
                      hintText: 'Ask anything…',
                      hintStyle: const TextStyle(color: AppColors.text3),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.fullBR,
                        borderSide: const BorderSide(
                          color: AppColors.border, width: 0.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.fullBR,
                        borderSide: const BorderSide(
                          color: AppColors.border, width: 0.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.fullBR,
                        borderSide: const BorderSide(
                          color: AppColors.primaryMid, width: 1),
                      ),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 7),
                GestureDetector(
                  onTap: () => _send(_controller.text),
                  child: Container(
                    width: 34, height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded,
                      size: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: msg.isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: msg.isUser
                      ? const Radius.circular(14)
                      : const Radius.circular(3),
                  bottomRight: msg.isUser
                      ? const Radius.circular(3)
                      : const Radius.circular(14),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(msg.text,
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  height: 1.6,
                  color: msg.isUser ? Colors.white : AppColors.text1,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontFamily: 'Inter',
                fontSize: 10, color: AppColors.text3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), topRight: Radius.circular(14),
                bottomLeft: Radius.circular(3), bottomRight: Radius.circular(14),
              ),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 3),
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.text3, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
