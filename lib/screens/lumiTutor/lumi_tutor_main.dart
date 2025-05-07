import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/widgets/base_screen_container.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/tutor_header.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/chat_bubble.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/chat_input_area.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/tutor_drawer.dart';

class LumiTutorMain extends StatefulWidget {
  const LumiTutorMain({Key? key}) : super(key: key);

  @override
  State<LumiTutorMain> createState() => _LumiTutorMainState();
}

class _LumiTutorMainState extends State<LumiTutorMain> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Hi! I'm LumiTutor. How can I help you today?",
      "sender": ChatSender.tutor,
    }
  ];

  final List<String> _suggestions = [
    "What is Newton’s First Law?",
    "Explain the Doppler effect",
    "What is E = mc²?",
  ];

  void _handleSend(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"text": message, "sender": ChatSender.user});
      _messages.add({
        "text": "🧠 (Pretend GPT is responding here...)",
        "sender": ChatSender.tutor,
      });
    });

    Future.delayed(const Duration(milliseconds: 300), () {
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
      drawer: const LumiDrawer(), // 👈 new sidebar drawer
      backgroundColor: Colors.black,
      body: BaseScreenContainer(
        includeSafeArea: true,
        enableScroll: false,
        onRefresh: null,
        builder: (context) => Column(
          children: [
            // ───── Header ─────
            TutorHeader(
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
              onCreateCourse: () => print("Create course from chat"),
            ),

            // ───── Chat Area ─────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return ChatBubble(
                    message: msg["text"],
                    sender: msg["sender"],
                  );
                },
              ),
            ),

            // ───── Input + Suggestions ─────
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 62,
              ),
              child: ChatInputArea(
                suggestions: _suggestions,
                onSend: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
