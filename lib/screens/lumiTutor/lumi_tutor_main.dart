import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/models/chat_sender.dart';
import 'package:lumi_learn_app/application/models/message_model.dart';
import 'package:lumi_learn_app/application/controllers/tutor_controller.dart';
import 'package:lumi_learn_app/widgets/base_screen_container.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/tutor_header.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/chat_bubble.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/chat_input_area.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/tutor_drawer.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';

class LumiTutorMain extends StatefulWidget {
  final Map<String, dynamic>? initialArgs;
  final String? courseId; // Add optional courseId parameter
  final String?
      courseTitle; // Optional course title for header when no thread exists

  const LumiTutorMain(
      {Key? key, this.initialArgs, this.courseId, this.courseTitle})
      : super(key: key);

  @override
  State<LumiTutorMain> createState() => _LumiTutorMainState();
}

class _LumiTutorMainState extends State<LumiTutorMain> {
  final ScrollController _scrollController = ScrollController();
  final TutorController _tutorController = Get.find<TutorController>();

  final List<String> _suggestions = [
    "What is Newton’s First Law?",
    "Explain the Doppler effect",
    "What is E = mc²?",
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<NavigationController>().hideNavBar();
      _handleScannedInput(widget.initialArgs);

      // Listen to messages changes to scroll to bottom
      ever(_tutorController.messages, (_) {
        if (mounted) {
          _scrollToBottom();
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<NavigationController>().showNavBar();
      }
    });
    super.dispose();
  }

  void _handleScannedInput(Map<String, dynamic>? args) {
    if (args != null && mounted) {
      if (args['type'] == 'image') {
        final List<String> paths = List<String>.from(args['paths']);
        for (var path in paths) {
          // TODO: Handle image upload to active thread
          print('Image uploaded: $path');
        }
      } else if (args['type'] == 'pdf') {
        // TODO: Handle PDF upload to active thread
        print('PDF uploaded: ${args['path']}');
      } else if (args['type'] == 'text' && args.containsKey('initialMessage')) {
        // Create a new thread with the initial message
        _tutorController.createThread(
          args['initialMessage'],
          courseId: widget.courseId,
        );
      }

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

    if (_tutorController.hasActiveThread) {
      // Send message to active thread
      _tutorController.sendMessage(message);
    } else {
      // Create new thread with this message
      _tutorController.createThread(
        message,
        courseId: widget.courseId,
      );
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context)
            .unfocus(), // ✅ dismiss keyboard on outside tap
        child: Scaffold(
          endDrawer: const LumiDrawer(),
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          body: BaseScreenContainer(
            includeSafeArea: true,
            enableScroll: false,
            onRefresh: null,
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: bottomInset), // ✅ avoids gap
              child: Column(
                children: [
                  Obx(() {
                    String? headerCourseTitle;
                    if (_tutorController.hasActiveThread) {
                      final t =
                          _tutorController.activeThread.value?.courseTitle;
                      headerCourseTitle =
                          (t == null || t.trim().isEmpty) ? null : t;
                    } else {
                      headerCourseTitle = widget.courseTitle;
                    }
                    return TutorHeader(
                      onMenuPressed: () => Scaffold.of(context).openEndDrawer(),
                      onCreateCourse: () => print("Create course from chat"),
                      onClearThread: () => _tutorController.clearActiveThread(),
                      courseTitle: headerCourseTitle,
                    );
                  }),
                  Expanded(
                    child: Obx(() {
                      if (_tutorController.isLoadingMessages.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (!_tutorController.hasActiveThread) {
                        // If opened from a course (title provided), show an empty chat area ready for first message
                        if (widget.courseTitle != null ||
                            widget.courseId != null) {
                          return ListView.builder(
                            controller: _scrollController,
                            itemCount: 0,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            itemBuilder: (context, index) =>
                                const SizedBox.shrink(),
                          );
                        }
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white54,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Select a chat from the menu\nor start a new conversation',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: _tutorController.messages.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemBuilder: (context, index) {
                          final message = _tutorController.messages[index];

                          return ChatBubble(
                            message: message.content,
                            sender: message.role == MessageRole.user
                                ? ChatSender.user
                                : ChatSender.tutor,
                          );
                        },
                      );
                    }),
                  ),
                  ChatInputArea(
                    suggestions: _suggestions,
                    onSend: _handleSend,
                    onImagePicked: (imageFile) {
                      // TODO: Handle image upload to active thread
                      print('Image picked: ${imageFile.path}');
                      _scrollToBottom();
                    },
                    onFilePicked: (file) {
                      // TODO: Handle file upload to active thread
                      print('File picked: ${file.path}');
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
