import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/services/api_service.dart';

class SpeakController extends GetxController {
  final AuthController authController = Get.find();

  final List<String> terms;
  // Track progress by index: each term has its progress stored in a list.
  final RxList<double> termProgress = <double>[].obs;
  final AudioPlayer audioPlayer = AudioPlayer();

  final RxBool isLoading = false.obs;
  final RxString sessionId = ''.obs;
  final RxList updatedTerms = <dynamic>[].obs;
  final RxString feedbackMessage = ''.obs;
  final Rx<Uint8List> reviewAudioBytes = Rx<Uint8List>(Uint8List(0));

  SpeakController({required this.terms}) {
    // Initialize the list with a default value (0.0) for each term.
    termProgress.assignAll(List<double>.filled(terms.length, 0.0));

    // For our expected 3 terms, set custom initial values.
    termProgress[0] = 0.0;
    termProgress[1] = 0.0;
    termProgress[2] = 0.0;

    print(
        "SpeakController initialized with terms: $terms and progress: $termProgress");
  }

  @override
  void onInit() {
    super.onInit();
    playIntroAudio();
  }

  /// Plays the introductory audio.
  Future<void> playIntroAudio() async {
    // Assumes your mark_intro.mp3 is in your assets folder and declared in pubspec.yaml
    await audioPlayer.play(AssetSource("sounds/mark_intro2.mp3"));
  }

  /// When recording starts, simulate marking the first term as mastered.
  void startRecording() {
    if (termProgress.isNotEmpty) {
      termProgress[0] = 1.0;
    }
    print("Recording started, term at index 0 mastered");
  }

  void stopRecording() {
    print("Recording stopped");
  }

  /// Example method to simulate a backend update.
  Future<void> fetchDataFromBackend() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      // if (terms.length > 1) {
      //   termProgress[1] = 0.8;
      // }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  /// Submits a review to the backend.
  /// After receiving the JSON response, updates term progress and immediately tries to retrieve the feedback audio.
  Future<void> submitReview({
    required String transcript,
    required int attemptNumber,
  }) async {
    print('Submitting review...');
    isLoading.value = true;
    try {
      final authController = Get.find<AuthController>();
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        isLoading.value = false;
        return;
      }

      // Build terms list with statuses based on progress.
      final List<Map<String, String>> termsData = [];
      for (var i = 0; i < terms.length; i++) {
        final progress = termProgress[i];
        String status;
        if (progress >= 1.0) {
          status = "mastered";
        } else if (progress < 0.5) {
          status = "needs_improvement";
        } else {
          status = "unattempted";
        }
        termsData.add({'term': terms[i], 'status': status});
      }

      final response = await ApiService().submitReview(
        token: token,
        transcript: transcript,
        terms: termsData,
        attemptNumber: attemptNumber,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sessionId.value = data['sessionId'];
        updatedTerms.assignAll(data['updatedTerms']);
        feedbackMessage.value = data['feedbackMessage'];
        print('Review submitted successfully: $data');

        // Update termProgress based on the JSON response.
        final List<dynamic> updated = data['updatedTerms'];
        for (int i = 0; i < updated.length; i++) {
          final status = updated[i]['status'];
          if (status == 'mastered') {
            termProgress[i] = 1.0;
          } else if (status == 'needs_improvement') {
            termProgress[i] = 0.45;
          } else if (status == 'unattempted') {
            termProgress[i] = 0.0;
          }
        }

        // Optionally delay a bit to allow audio generation to finish.
        await Future.delayed(const Duration(milliseconds: 500));
        // Immediately attempt to fetch the review audio.
        await fetchReviewAudio();
      } else {
        print('Failed to submit review: ${response.statusCode}');
        Get.snackbar("Error", "Failed to submit review.",
            backgroundColor: const Color(0xFFFF0000),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      print('Error submitting review: $e');
      Get.snackbar("Error", "Something went wrong. Please try again.",
          backgroundColor: const Color(0xFFFF0000),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isLoading.value = false;
    }
  }

  /// Retrieves the AI feedback audio for the given review session.
  Future<void> fetchReviewAudio() async {
    print("Fetching review audio...");
    isLoading.value = true;
    try {
      if (sessionId.value.isEmpty) {
        print("No session id available");
        isLoading.value = false;
        return;
      }
      final authController = Get.find<AuthController>();
      final token = await authController.getIdToken();
      if (token == null) {
        print("No user token found.");
        isLoading.value = false;
        return;
      }

      final response = await ApiService().getReviewAudio(
        token: token,
        sessionId: sessionId.value,
      );

      if (response.statusCode == 200) {
        reviewAudioBytes.value = response.bodyBytes;
        print("Review audio fetched successfully.");
      } else {
        print("Failed to fetch review audio: ${response.statusCode}");
        Get.snackbar("Error", "Failed to fetch review audio.",
            backgroundColor: const Color(0xFFFF0000),
            colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      print("Error fetching review audio: $e");
      Get.snackbar("Error", "Something went wrong. Please try again.",
          backgroundColor: const Color(0xFFFF0000),
          colorText: const Color(0xFFFFFFFF));
    } finally {
      isLoading.value = false;
    }
  }
}
