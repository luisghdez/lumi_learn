import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/models/chat_sender.dart';
import 'package:lumi_learn_app/widgets/base_screen_container.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/tutor_header.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/chat_bubble.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/chat_input_area.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/tutor_drawer.dart';
import 'package:lumi_learn_app/controllers/navigation_controller.dart';

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

  @override
  void initState() {
    super.initState();

    // Hide bottom nav bar when this screen is opened
    Get.find<NavigationController>().hideNavBar();

    _handleScannedInput();
  }

  @override
  void dispose() {
    // Show bottom nav bar again when leaving
    Get.find<NavigationController>().showNavBar();
    super.dispose();
  }

  void _handleScannedInput() {
    final args = Get.arguments;
    if (args != null && mounted) {
      if (args['type'] == 'image') {
        final List<String> paths = List<String>.from(args['paths']);
        for (var path in paths) {
          _messages.add({
            "image": path,
            "sender": ChatSender.user,
          });
        }
      } else if (args['type'] == 'pdf') {
        _messages.add({
          "text": "📎 Sent a scanned PDF:\n${args['path']}",
          "sender": ChatSender.user,
        });
      }

      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"text": message, "sender": ChatSender.user});
      _messages.add({
        "text": "🧠 (Pretend GPT is responding here...)",
        "sender": ChatSender.tutor,
      });
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const LumiDrawer(),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true, // important for keyboard

      body: BaseScreenContainer(
        includeSafeArea: true,
        enableScroll: false,
        onRefresh: null,
        builder: (context) => Column(
          children: [
            TutorHeader(
              onMenuPressed: () => Scaffold.of(context).openDrawer(),
              onCreateCourse: () => print("Create course from chat"),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemBuilder: (context, index) {
                  final msg = _messages[index];

                  if (msg.containsKey("image")) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(msg["image"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }

                  return ChatBubble(
                    message: msg["text"],
                    sender: msg["sender"] ?? ChatSender.tutor,
                  );
                },
              ),
            ),
              ChatInputArea(
                suggestions: _suggestions,
                onSend: _handleSend,
            )
          ],
        ),
      ),
    );
  }
}
