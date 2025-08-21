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
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = false.obs;
  RxString errorMessage = ''.obs;
  RxnString nextCursor = RxnString();

  // Active thread and messages
  Rxn<Thread> activeThread = Rxn<Thread>();
  RxList<Message> messages = <Message>[].obs;
  RxBool isLoadingMessages = false.obs;
  RxBool isLoadingMoreMessages = false.obs;
  RxBool hasMoreMessages = false.obs;
  RxnString nextMessageCursor = RxnString();
  RxInt totalMessageCount = 0.obs;
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

      final response = await _tutorService.getThreads(
        token: token,
        limit: 10,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final threadsResponse = ThreadsResponse.fromJson(data);

        threads.value = threadsResponse.threads;
        hasMore.value = threadsResponse.hasMore;
        nextCursor.value = threadsResponse.nextCursor;
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

      // Create a temporary thread to show messages immediately
      final String tempThreadId =
          'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempThread = Thread(
        threadId: tempThreadId,
        initialMessage: initialMessage,
        lastMessageAt: DateTime.now(),
        messageCount: 0,
        courseId: courseId,
        courseTitle: null,
      );
      activeThread.value = tempThread;

      // Optimistically add user message to current messages
      final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
      messages.add(
        Message(
          messageId: tempId,
          role: MessageRole.user,
          content: initialMessage,
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

      final stream = _tutorService.createThreadStream(
        token: token,
        initialMessage: initialMessage,
        courseId: courseId,
      );

      String accumulated = '';
      Thread? newThread;
      List<Map<String, dynamic>>? sources;

      await for (final event in stream) {
        final type = event['type'] as String?;

        if (type == 'start') {
          // Stream started, sources might be included
          sources = event['sources'] != null
              ? List<Map<String, dynamic>>.from(event['sources'])
              : null;
        } else if (type == 'delta') {
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
              sources: sources,
            );
            messages.refresh();
          }
        } else if (type == 'thread') {
          // Thread created, update active thread
          try {
            newThread = Thread.fromJson(event);
            activeThread.value = newThread;
          } catch (_) {
            // ignore parse issues
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
          errorMessage.value = 'Failed to create thread';
          // Remove the placeholder messages on error
          messages.removeWhere(
              (m) => m.messageId == tempId || m.messageId == assistantTempId);
          messages.refresh();
          // Clear the temporary thread
          activeThread.value = null;
        } else if (type == 'done') {
          // Stream finished
        }
      }

      // If we got a new thread, add it to the threads list and refresh
      if (newThread != null) {
        threads.insert(0, newThread);
        threads.refresh();
        // Reset pagination state since we have a new thread
        hasMore.value = false;
        nextCursor.value = null;
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
      List<Map<String, dynamic>>? sources;
      await for (final event in stream) {
        final type = event['type'] as String?;
        if (type == 'start') {
          // Stream started, sources might be included
          sources = event['sources'] != null
              ? List<Map<String, dynamic>>.from(event['sources'])
              : null;
        } else if (type == 'delta') {
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
              sources: sources,
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
    // Reset pagination state when refreshing
    nextCursor.value = null;
    hasMore.value = false;
    await fetchThreads();
  }

  Future<void> loadMoreThreads() async {
    if (isLoadingMore.value || !hasMore.value || nextCursor.value == null)
      return;

    isLoadingMore.value = true;
    errorMessage.value = '';

    try {
      final token = await _authController.getIdToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        isLoadingMore.value = false;
        return;
      }

      final response = await _tutorService.getThreads(
        token: token,
        limit: 10,
        cursor: nextCursor.value,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final threadsResponse = ThreadsResponse.fromJson(data);

        // Append new threads to existing list
        threads.addAll(threadsResponse.threads);
        hasMore.value = threadsResponse.hasMore;
        nextCursor.value = threadsResponse.nextCursor;
      } else {
        errorMessage.value =
            'Failed to load more threads: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error loading more threads: $e';
      print('Error loading more threads: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  void clearThreads() {
    threads.clear();
    hasMore.value = false;
    nextCursor.value = null;
    errorMessage.value = '';
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMoreMessages.value ||
        !hasMoreMessages.value ||
        nextMessageCursor.value == null) {
      return;
    }

    isLoadingMoreMessages.value = true;
    errorMessage.value = '';

    try {
      final token = await _authController.getIdToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        isLoadingMoreMessages.value = false;
        return;
      }

      final response = await _tutorService.getThreadMessages(
        token: token,
        threadId: activeThread.value!.threadId,
        limit: 10,
        cursor: nextMessageCursor.value,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messagesResponse = ThreadMessagesResponse.fromJson(data);

        // Prepend new messages to existing list (since messages are in reverse chronological order)
        messages.insertAll(0, messagesResponse.messages);
        hasMoreMessages.value = messagesResponse.hasMore;
        nextMessageCursor.value = messagesResponse.nextCursor;
      } else {
        errorMessage.value =
            'Failed to load more messages: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error loading more messages: $e';
      print('Error loading more messages: $e');
    } finally {
      isLoadingMoreMessages.value = false;
    }
  }

  Future<void> refreshMessages() async {
    if (activeThread.value == null) return;

    // Reset pagination state
    hasMoreMessages.value = false;
    nextMessageCursor.value = null;
    totalMessageCount.value = 0;

    // Reload messages
    await fetchThreadMessages(activeThread.value!.threadId);
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
        limit: 10,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messagesResponse = ThreadMessagesResponse.fromJson(data);

        messages.value = messagesResponse.messages;
        hasMoreMessages.value = messagesResponse.hasMore;
        nextMessageCursor.value = messagesResponse.nextCursor;
        totalMessageCount.value = messagesResponse.totalCount ?? 0;
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
    hasMoreMessages.value = false;
    nextMessageCursor.value = null;
    totalMessageCount.value = 0;
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
        limit: 10,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Expecting shape compatible with ThreadMessagesResponse
        final messagesResponse = ThreadMessagesResponse.fromJson(data);
        messages.value = messagesResponse.messages;
        hasMoreMessages.value = messagesResponse.hasMore;
        nextMessageCursor.value = messagesResponse.nextCursor;
        totalMessageCount.value = messagesResponse.totalCount ?? 0;

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
