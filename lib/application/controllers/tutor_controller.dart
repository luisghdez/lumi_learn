import 'dart:convert';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/models/thread_model.dart';
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

  Future<void> createThread(String initialMessage) async {
    try {
      final token = await _authController.getIdToken();
      if (token == null) {
        errorMessage.value = 'Authentication required';
        return;
      }

      final response = await _tutorService.createThread(
        token: token,
        initialMessage: initialMessage,
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
}
