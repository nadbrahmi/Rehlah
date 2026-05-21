import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/rehlah_theme.dart';
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
      text: "Hi, I'm Rehlah AI — here for you whenever you need me. Ask anything about your treatment, symptoms, or how you're feeling.",
      isUser: false,
      timestamp: DateTime(2026, 4, 24, 9, 41),
    ),
    ChatMessage(
      text: 'What does low hemoglobin mean?',
      isUser: true,
      timestamp: DateTime(2026, 4, 24, 9, 51),
    ),
    ChatMessage(
      text: "Low hemoglobin means your blood carries less oxygen — causing tiredness, breathlessness, or dizziness. During chemo this is very common. Rest when your body asks. That's not weakness — it's wisdom.",
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
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: 'I understand you\'re asking about "$msg". This is a great question for your care journey. For specific medical advice, always consult your oncology team — but I\'m here to help you understand and prepare.',
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
      backgroundColor: RColors.sand50,
      body: Column(children: [
        SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: RColors.surface,
              border: Border(bottom: BorderSide(color: RColors.sand200, width: 0.5)),
            ),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.canPop() ? context.pop() : context.go('/'),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: RColors.sand500),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  color: RColors.teal700,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                  size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ask Rehlah', style: RText.body.copyWith(
                  fontWeight: FontWeight.w700, fontSize: 14, height: 1.1)),
                Text('Not a substitute for your doctor', style: RText.small.copyWith(
                  color: RColors.sand500, fontSize: 10)),
              ]),
            ]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, i) {
              if (_isTyping && i == _messages.length) return _buildTypingIndicator();
              return _buildMessage(_messages[i]);
            },
          ),
        ),
        // Suggestion chips
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
                  color: RColors.surface,
                  borderRadius: RRadius.pillBR,
                  border: Border.all(color: RColors.teal200, width: 0.5),
                ),
                child: Text(_suggestions[i],
                  style: RText.small.copyWith(color: RColors.teal700)),
              ),
            ),
          ),
        ),
        // Input bar
        Container(
          decoration: const BoxDecoration(
            color: RColors.surface,
            border: Border(top: BorderSide(color: RColors.sand200, width: 0.5)),
          ),
          padding: EdgeInsets.fromLTRB(
            16, 9, 16, 12 + MediaQuery.of(context).padding.bottom),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: RText.body.copyWith(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ask anything…',
                  hintStyle: RText.body.copyWith(color: RColors.sand400, fontSize: 13),
                  filled: true,
                  fillColor: RColors.sand50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                  border: OutlineInputBorder(
                    borderRadius: RRadius.pillBR,
                    borderSide: const BorderSide(color: RColors.sand200, width: 0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: RRadius.pillBR,
                    borderSide: const BorderSide(color: RColors.sand200, width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: RRadius.pillBR,
                    borderSide: const BorderSide(color: RColors.teal500, width: 1)),
                ),
                onSubmitted: _send,
              ),
            ),
            const SizedBox(width: 7),
            GestureDetector(
              onTap: () => _send(_controller.text),
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  color: RColors.teal700, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, size: 15, color: RColors.surface),
              ),
            ),
          ]),
        ),
      ]),
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
                color: msg.isUser ? RColors.teal700 : RColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: RRadius.md,
                  topRight: RRadius.md,
                  bottomLeft: msg.isUser ? RRadius.md : RRadius.xs,
                  bottomRight: msg.isUser ? RRadius.xs : RRadius.md,
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: RColors.sand200, width: 0.5),
              ),
              child: Text(msg.text,
                style: RText.body.copyWith(
                  fontSize: 13,
                  height: 1.6,
                  color: msg.isUser ? RColors.surface : RColors.sand900,
                  fontWeight: FontWeight.w400,
                )),
            ),
            const SizedBox(height: 3),
            Text(
              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
              style: RText.small.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: RColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: RRadius.md, topRight: RRadius.md,
              bottomLeft: RRadius.xs, bottomRight: RRadius.md,
            ),
            border: Border.all(color: RColors.sand200, width: 0.5),
          ),
          child: Row(children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: RColors.sand400, shape: BoxShape.circle)),
            ],
          ]),
        ),
      ]),
    );
  }
}
