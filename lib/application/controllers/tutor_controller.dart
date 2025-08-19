import 'dart:convert';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/models/thread_model.dart';
import 'package:lumi_learn_app/application/models/message_model.dart';
import 'package:lumi_learn_app/application/services/tutor_service.dart';

class TutorController extends GetxController {
  static TutorController instance = Get.find();

  final TutorService _tutorService = TutorService();
  final AuthController _authController = AuthController.instance;

  // Observable state
  RxList<Thread> threads = <Thread>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = false.obs;
  RxString errorMessage = ''.obs;

  // Active thread and messages
  Rxn<Thread> activeThread = Rxn<Thread>();
  RxList<Message> messages = <Message>[].obs;
  RxBool isLoadingMessages = false.obs;
  RxBool isOpeningFromCourse = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchThreads();
  }

  Future<void> fetchThreads() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await _authController.getIdToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        isLoading.value = false;
        return;
      }

      final response = await _tutorService.getThreads(token: token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final threadsResponse = ThreadsResponse.fromJson(data);

        threads.value = threadsResponse.threads;
        hasMore.value = threadsResponse.hasMore;
      } else {
        errorMessage.value = 'Failed to fetch threads: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching threads: $e';
      print('Error fetching threads: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createThread(String initialMessage, {String? courseId}) async {
    try {
      final token = await _authController.getIdToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        return;
      }

      final response = await _tutorService.createThread(
        token: token,
        initialMessage: initialMessage,
        courseId: courseId,
      );

      if (response.statusCode == 201) {
        // Refresh threads after creating a new one
        await fetchThreads();
      } else {
        errorMessage.value = 'Failed to create thread: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error creating thread: $e';
      print('Error creating thread: $e');
    }
  }

  Future<void> sendMessage(String message) async {
    if (activeThread.value == null) {
      errorMessage.value = 'No active thread';
      return;
    }

    try {
      final token = await _authController.getIdToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        return;
      }

      // Optimistically append the user message
      final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
      messages.add(
        Message(
          messageId: tempId,
          role: MessageRole.user,
          content: message,
          timestamp: DateTime.now(),
        ),
      );

      // Placeholder assistant message that we will stream-update
      final String assistantTempId = '${tempId}_assistant';
      messages.add(
        Message(
          messageId: assistantTempId,
          role: MessageRole.assistant,
          content: '',
          timestamp: DateTime.now(),
        ),
      );

      final stream = _tutorService.sendMessageStream(
        token: token,
        threadId: activeThread.value!.threadId,
        message: message,
        courseId: activeThread.value!.courseId,
      );

      String accumulated = '';
      await for (final event in stream) {
        final type = event['type'] as String?;
        if (type == 'delta') {
          final delta = (event['delta'] as String?) ?? '';
          if (delta.isEmpty) continue;
          accumulated += delta;
          // Update the last assistant message content progressively
          final int index = messages.lastIndexWhere((m) =>
              m.messageId == assistantTempId &&
              m.role == MessageRole.assistant);
          if (index != -1) {
            messages[index] = Message(
              messageId: assistantTempId,
              role: MessageRole.assistant,
              content: accumulated,
              timestamp: DateTime.now(),
            );
            messages.refresh();
          }
        } else if (type == 'message') {
          // Final persisted message: replace the placeholder with real one
          try {
            final persisted = Message.fromJson(event);
            final int index = messages.lastIndexWhere((m) =>
                m.messageId == assistantTempId &&
                m.role == MessageRole.assistant);
            if (index != -1) {
              messages[index] = persisted;
              messages.refresh();
            } else {
              messages.add(persisted);
            }
          } catch (_) {
            // ignore parse issues
          }
        } else if (type == 'error' || type == 'http_error') {
          errorMessage.value = 'Failed to send message';
        } else if (type == 'done') {
          // Stream finished
        }
      }
    } catch (e) {
      errorMessage.value = 'Error sending message: $e';
      print('Error sending message: $e');
    }
  }

  Future<void> refreshThreads() async {
    await fetchThreads();
  }

  void clearError() {
    errorMessage.value = '';
  }

  Thread? getThreadById(String threadId) {
    try {
      return threads.firstWhere((thread) => thread.threadId == threadId);
    } catch (e) {
      return null;
    }
  }

  List<Thread> getSortedThreads() {
    final sortedThreads = List<Thread>.from(threads);
    sortedThreads.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return sortedThreads;
  }

  Future<void> setActiveThread(Thread thread) async {
    await fetchThreadMessages(thread.threadId);
    activeThread.value = thread;
  }

  Future<void> fetchThreadMessages(String threadId) async {
    if (isLoadingMessages.value) return;

    isLoadingMessages.value = true;
    errorMessage.value = '';

    try {
      final token = await _authController.getIdToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        isLoadingMessages.value = false;
        return;
      }

      final response = await _tutorService.getThreadMessages(
        token: token,
        threadId: threadId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messagesResponse = ThreadMessagesResponse.fromJson(data);

        messages.value = messagesResponse.messages;
      } else {
        errorMessage.value = 'Failed to fetch messages: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching messages: $e';
      print('Error fetching messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void clearActiveThread() {
    activeThread.value = null;
    messages.clear();
  }

  bool get hasActiveThread => activeThread.value != null;

  /// Open tutor for a specific course.
  /// - Calls GET /courses/:courseId/messages
  /// - If 200: sets active thread (by matching threadId from response if present)
  ///           and loads messages
  /// - If 404: clears active thread and leaves messages empty (UI shows empty chat)
  Future<void> openTutorForCourse({
    required String courseId,
    String? courseTitle,
  }) async {
    if (isOpeningFromCourse.value) return;
    isOpeningFromCourse.value = true;
    errorMessage.value = '';

    try {
      final token = await _authController.getIdToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        return;
      }

      final response = await _tutorService.getCourseMessages(
        token: token,
        courseId: courseId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Expecting shape compatible with ThreadMessagesResponse
        final messagesResponse = ThreadMessagesResponse.fromJson(data);
        messages.value = messagesResponse.messages;

        // Try to find corresponding thread in current list and set it active
        final thread = getThreadById(messagesResponse.threadId);
        if (thread != null) {
          // If existing thread lacks title but we have one, create a copy with title
          if ((thread.courseTitle == null ||
                  thread.courseTitle!.trim().isEmpty) &&
              courseTitle != null &&
              courseTitle.trim().isNotEmpty) {
            activeThread.value = Thread(
              threadId: thread.threadId,
              initialMessage: thread.initialMessage,
              lastMessageAt: thread.lastMessageAt,
              messageCount: thread.messageCount,
              courseId: thread.courseId ?? courseId,
              courseTitle: courseTitle,
            );
          } else {
            activeThread.value = thread;
          }
        } else {
          // If not found, synthesize a minimal thread model so header can show course title if provided
          activeThread.value = Thread(
            threadId: messagesResponse.threadId,
            initialMessage: messagesResponse.messages.isNotEmpty
                ? messagesResponse.messages.first.content
                : '',
            lastMessageAt: messagesResponse.messages.isNotEmpty
                ? messagesResponse.messages.last.timestamp
                : DateTime.now(),
            messageCount: messagesResponse.messages.length,
            courseId: courseId,
            courseTitle: (courseTitle != null && courseTitle.trim().isNotEmpty)
                ? courseTitle
                : null,
          );
        }
      } else if (response.statusCode == 404) {
        // No thread exists yet for this course
        clearActiveThread();
      } else {
        errorMessage.value =
            'Failed to open tutor for course: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error opening tutor for course: $e';
      print('Error opening tutor for course: $e');
    } finally {
      isOpeningFromCourse.value = false;
    }
  }
}
