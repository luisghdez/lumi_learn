import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:lumi_learn_app/application/models/chat_sender.dart';
import 'package:lumi_learn_app/application/models/message_model.dart';
import 'package:lumi_learn_app/application/controllers/tutor_controller.dart';
import 'package:lumi_learn_app/widgets/base_screen_container.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/tutor_header.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/chat_bubble.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/chat_input_area.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/tutor_drawer.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/aiScanner/ai_scanner_main.dart';
import 'package:lumi_learn_app/widgets/no_swipe_route.dart';
import 'package:lottie/lottie.dart';

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

  // GetX workers to clean up reactive listeners
  Worker? _messagesWorker;
  Worker? _activeThreadWorker;
  Worker? _loadingMoreWorker;

  final List<String> _suggestions = [
    "What is Newton’s First Law?",
    "Explain the Doppler effect",
    "What is E = mc²?",
  ];

  // ---- Smart-scroll state ----
  bool _suppressAutoScroll = false; // true right after switching threads

  // ---- Lazy-load anchor state ----
  double? _preLoadMaxScrollExtent;
  bool _awaitingLoadMoreApply = false;

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

      _handleScannedInput(widget.initialArgs);

      // Listen for scrolls to trigger lazy loading when nearing the top (older end)
      _scrollController.addListener(_onScroll);

      // Animate subtly to the bottom as new messages stream in
      // ONLY if we're already near the bottom and not right after a thread switch.
      _messagesWorker = ever(_tutorController.messages, (_) {
        if (!mounted || _suppressAutoScroll) return;
        if (_isNearBottom) {
          _animateToBottom(durationMs: 120); // gentle nudge
        }
      });

      // When switching threads, do NOT animate or jump — just render latest.
      _activeThreadWorker = ever(_tutorController.activeThread, (_) {
        _suppressAutoScroll = true; // prevent one-frame auto-scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _suppressAutoScroll = false;
        });
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
    _messagesWorker?.dispose();
    _activeThreadWorker?.dispose();
    _loadingMoreWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScannedInput(Map<String, dynamic>? args) {
    if (args != null && mounted) {
      if (args['type'] == 'image') {
        final List<String> paths = List<String>.from(args['paths']);
        for (var path in paths) {
          // TODO: Handle image upload to a new thread
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

  void _onScroll() {
    if (!_scrollController.hasClients || !_tutorController.hasActiveThread) {
      return;
    }
    final position = _scrollController.position;
    const threshold = 160.0; // begin prefetching slightly before the edge
    final isNearTop = (position.maxScrollExtent - position.pixels) <= threshold;

    if (isNearTop &&
        _tutorController.hasMoreMessages.value &&
        !_tutorController.isLoadingMoreMessages.value) {
      _preLoadMaxScrollExtent = position.maxScrollExtent;
      _awaitingLoadMoreApply = true;
      _tutorController.loadMoreMessages();
    }
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
    // in case the user was scrolled up browsing history.
    _animateToBottom(durationMs: 150);
  }

  Future<void> _handleScannerPressed() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar(
          "Camera Error",
          "No camera available on this device",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      // Navigate to scanner
      await Navigator.of(context).push(
        NoSwipePageRoute(
          builder: (_) => AiScannerMain(
            cameras: cameras,
            existingThreadId: _tutorController.activeThread.value?.threadId,
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        "Camera Error",
        "Failed to open camera: $e",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: GestureDetector(
        onTap: () {
          final currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusScope.of(context).unfocus();
          }
        },
        child: Scaffold(
          endDrawer: const LumiDrawer(),
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: BaseScreenContainer(
            includeSafeArea: true,
            enableScroll: false,
            onRefresh: null,
            builder: (context) => AnimatedPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              duration: const Duration(milliseconds: 0), // Fast animation
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
                        if (widget.courseTitle != null ||
                            widget.courseId != null) {
                          return ListView.builder(
                            controller: _scrollController,
                            reverse: true,
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
                              Icon(Icons.chat_bubble_outline,
                                  color: Colors.white54, size: 64),
                              SizedBox(height: 16),
                              Text(
                                'Select a chat from the menu\nor start a new conversation',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: _tutorController.messages.length + 1,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            itemBuilder: (context, index) {
                              // Show loading moon as the first item (bottom of reversed list)
                              if (index == 0) {
                                return Obx(() {
                                  final showMoon =
                                      _tutorController.showLoadingMoon.value;
                                  return AnimatedOpacity(
                                    opacity: showMoon ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: showMoon
                                        ? Curves.easeIn
                                        : Curves.easeOut,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      height: showMoon ? 64 : 0,
                                      curve: showMoon
                                          ? Curves.easeIn
                                          : Curves.easeOut,
                                      child: showMoon
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: Transform.translate(
                                                offset: const Offset(-16, 0),
                                                child: const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 8, bottom: 8),
                                                  child: SizedBox(
                                                    height: 64,
                                                    width: 64,
                                                    child: _ThinkingMoon(),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  );
                                });
                              }

                              // Adjust index for messages (subtract 1 for the moon slot)
                              final messageIndex = index - 1;
                              final reversedIndex =
                                  _tutorController.messages.length -
                                      1 -
                                      messageIndex;
                              final message =
                                  _tutorController.messages[reversedIndex];
                              return SizedBox(
                                width: double
                                    .infinity, // ✅ This ensures full width for proper alignment
                                child: ChatBubble(
                                  message: message.content,
                                  sender: message.role == MessageRole.user
                                      ? ChatSender.user
                                      : ChatSender.tutor,
                                  sources: message.sources,
                                  isStreaming: message.isStreaming,
                                  image: message.image,
                                ),
                              );
                            },
                          ),
                          if (_tutorController.isLoadingMoreMessages.value)
                            Positioned(
                              top: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                  ChatInputArea(
                    suggestions: _suggestions,
                    onSend: _handleSend,
                    onImagePicked: (imageFile) {
                      print('Image picked: ${imageFile.path}');
                      _animateToBottom();
                    },
                    onFilePicked: (file) {
                      print('File picked: ${file.path}');
                      _animateToBottom();
                    },
                    onScannerPressed: _handleScannerPressed,
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

class _ThinkingMoon extends StatelessWidget {
  const _ThinkingMoon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Lottie.asset(
        'assets/videos/moon.json',
        repeat: true,
        animate: true,
        fit: BoxFit.contain,
      ),
    );
  }
}
