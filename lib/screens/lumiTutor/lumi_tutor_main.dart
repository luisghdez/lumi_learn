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
  final String? courseId; // Optional courseId parameter
  final String?
      courseTitle; // Optional course title for header when no thread exists

  const LumiTutorMain({
    Key? key,
    this.initialArgs,
    this.courseId,
    this.courseTitle,
  }) : super(key: key);

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

  // ---- Smart-scroll state ----
  bool _suppressAutoScroll = false; // true right after switching threads

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    // With reverse:true, "bottom" is minScrollExtent (usually 0).
    return (position.pixels - position.minScrollExtent).abs() < 80.0;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Get.find<NavigationController>().hideNavBar();
      _handleScannedInput(widget.initialArgs);

      // Animate subtly to the bottom as new messages stream in
      // ONLY if we're already near the bottom and not right after a thread switch.
      ever(_tutorController.messages, (_) {
        if (!mounted || _suppressAutoScroll) return;
        if (_isNearBottom) {
          _animateToBottom(durationMs: 120); // gentle nudge
        }
      });

      // When switching threads, do NOT animate or jump — just render latest.
      ever(_tutorController.activeThread, (_) {
        _suppressAutoScroll = true; // prevent one-frame auto-scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _suppressAutoScroll = false;
        });
      });

      // We intentionally do NOT auto-scroll on isLoadingMessages changes.
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
          // ignore: avoid_print
          print('Image uploaded: $path');
        }
      } else if (args['type'] == 'pdf') {
        // TODO: Handle PDF upload to active thread
        // ignore: avoid_print
        print('PDF uploaded: ${args['path']}');
      } else if (args['type'] == 'text' && args.containsKey('initialMessage')) {
        // Create a new thread with the initial message
        _tutorController.createThread(
          args['initialMessage'],
          courseId: widget.courseId,
        );
      }

      _animateToBottom();
    }
  }

  void _animateToBottom({int durationMs = 120}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController
              .position.minScrollExtent, // bottom with reverse:true
          duration: Duration(milliseconds: durationMs),
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

    // Ensure we stay pinned to the bottom after sending,
    // in case the user was scrolled up browsing history.
    _animateToBottom(durationMs: 150);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // dismiss keyboard on outside tap
        child: Scaffold(
          endDrawer: const LumiDrawer(),
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          body: BaseScreenContainer(
            includeSafeArea: true,
            enableScroll: false,
            onRefresh: null,
            builder: (context) => Padding(
              padding:
                  EdgeInsets.only(bottom: bottomInset), // avoids keyboard gap
              child: Column(
                children: [
                  Obx(() {
                    String? headerCourseTitle;
                    String? headerCourseId;
                    if (_tutorController.hasActiveThread) {
                      final t =
                          _tutorController.activeThread.value?.courseTitle;
                      headerCourseTitle =
                          (t == null || t.trim().isEmpty) ? null : t;
                      headerCourseId =
                          _tutorController.activeThread.value?.courseId;
                    } else {
                      headerCourseTitle = widget.courseTitle;
                      headerCourseId = widget.courseId;
                    }
                    return TutorHeader(
                      onMenuPressed: () => Scaffold.of(context).openEndDrawer(),
                      onCreateCourse: () =>
                          debugPrint("Create course from chat"),
                      onClearThread: () => _tutorController.clearActiveThread(),
                      courseTitle: headerCourseTitle,
                      courseId: headerCourseId,
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
                            reverse: true, // keep behavior consistent
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

                      // Main chat list
                      return ListView.builder(
                        controller: _scrollController,
                        reverse:
                            true, // show latest at "top" of the viewport (bottom visually)
                        itemCount: _tutorController.messages.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        itemBuilder: (context, index) {
                          final reversedIndex =
                              _tutorController.messages.length - 1 - index;
                          final message =
                              _tutorController.messages[reversedIndex];

                          return ChatBubble(
                            message: message.content,
                            sender: message.role == MessageRole.user
                                ? ChatSender.user
                                : ChatSender.tutor,
                            sources: message.sources,
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
                      // ignore: avoid_print
                      print('Image picked: ${imageFile.path}');
                      _animateToBottom();
                    },
                    onFilePicked: (file) {
                      // TODO: Handle file upload to active thread
                      // ignore: avoid_print
                      print('File picked: ${file.path}');
                      _animateToBottom();
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
