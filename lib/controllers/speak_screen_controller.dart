import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/services/api_service.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SpeakController extends GetxController {
  final AuthController authController = Get.find();
  final CourseController courseController = Get.find();

  RxList<String> terms = <String>[].obs;
  final RxList<double> termProgress = <double>[].obs;

  final AudioPlayer audioPlayer = AudioPlayer();

  /// Track loading states to disable UI or show spinners, etc.
  final RxBool isLoading = false.obs;

  /// Track if any audio (intro or feedback) is currently playing
  /// so we can disable the record button.
  final RxBool isAudioPlaying = false.obs;

  final RxString sessionId = ''.obs;
  final RxList updatedTerms = <dynamic>[].obs;
  final RxString feedbackMessage = ''.obs;
  final Rx<Uint8List> reviewAudioBytes = Rx<Uint8List>(Uint8List(0));

  late SpeechToText _speechToText;
  final RxBool speechEnabled = false.obs;
  final RxString transcript = ''.obs;

  int attemptNumber = 1;
  bool _hasSubmitted = false; // Flag to prevent duplicate submissions
  final RxList<Map<String, String>> conversationHistory =
      <Map<String, String>>[].obs;

  SpeakController();

  @override
  void onInit() {
    super.onInit();
    _initSpeech();

    // Anytime audio finishes, set [isAudioPlaying] to false.
    audioPlayer.onPlayerComplete.listen((_) {
      isAudioPlaying.value = false;
    });
  }

  @override
  void onClose() {
    _speechToText.stop();
    super.onClose();
  }

  /// Plays the introductory audio and marks the controller as currently playing.
  Future<void> playIntroAudio() async {
    try {
      isAudioPlaying.value = true;
      await audioPlayer.play(AssetSource("sounds/mark_intro2.mp3"));
    } catch (e) {
      isAudioPlaying.value = false;
      rethrow;
    }
  }

  /// Plays the closing audio.
  Future<void> playClosingAudio() async {
    try {
      isAudioPlaying.value = true;
      await audioPlayer.play(AssetSource("sounds/mark_intro.mp3"));
    } catch (e) {
      isAudioPlaying.value = false;
      rethrow;
    }
  }

  /// Initialize the speech recognizer without starting to listen.
  Future<void> _initSpeech() async {
    try {
      _speechToText = SpeechToText();
      speechEnabled.value = await _speechToText.initialize(
        onStatus: _onStatus,
        onError: _onSpeechError,
      );
      if (speechEnabled.value) {
        print("Speech recognition initialized and ready.");
      } else {
        print("Speech recognition not enabled.");
      }
    } catch (e) {
      print("Error initializing speech recognizer: $e");
      speechEnabled.value = false;
    }
  }

  // This is your "fake" or "silent" pre-warm.
  Future<void> preWarmSpeechEngine() async {
    print("Pre-warming speech engine...");
    if (!speechEnabled.value) return;
    _speechToText.listen(
      onResult: (_) {},
      listenFor: const Duration(seconds: 1),
    );
    await Future.delayed(const Duration(seconds: 2));
    await _speechToText.stop();
  }

  /// Set or reset terms from outside.
  void setTerms(List<String> newTerms) {
    terms.value = newTerms;
    termProgress.assignAll(List<double>.filled(newTerms.length, 0.0));
  }

  /// Called when the user taps "start" to begin a new segment.
  Future<void> startListening() async {
    if (!speechEnabled.value) {
      print("Speech recognition not enabled or not initialized.");
      return;
    }

    transcript.value = "";
    _hasSubmitted = false;

    _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 2),
      localeId: "en_US",
    );
  }

  /// Called when the user taps "stop" to end the current segment.
  Future<void> stopListening() async {
    isLoading.value = true;
    _speechToText.stop();
  }

  /// Updates the transcript as speech is recognized.
  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    transcript.value = result.recognizedWords;
    if (result.finalResult && !_hasSubmitted) {
      _hasSubmitted = true;
      print("Transcript: ${result.recognizedWords}");
      print("attemptNumber: $attemptNumber");
      if (attemptNumber == 4) {
        // On 4th attempt: Play closing audio, wait for it to finish, then go to next question.
        await playClosingAudio();
        await audioPlayer.onPlayerComplete.first;
        courseController.nextQuestion();
      } else {
        // Otherwise, submit the transcript.
        await submitReview(
          transcript: transcript.value,
          attemptNumber: attemptNumber,
        );
      }
      attemptNumber++;
      transcript.value = "";
    }
  }

  void _onStatus(String status) {
    print("Speech status: $status");
  }

  void _onSpeechError(SpeechRecognitionError error) {
    print("Speech error: ${error.errorMsg}, permanent: ${error.permanent}");
    if (error.permanent) {
      _speechToText.cancel();
      Future.delayed(const Duration(seconds: 1), () {
        _initSpeech();
      });
    }
  }

  /// Submits a review to the backend.
  Future<void> submitReview({
    required String transcript,
    required int attemptNumber,
  }) async {
    try {
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

      // Add the current user transcript to the conversation history.
      conversationHistory.add({'role': 'user', 'message': transcript});

      // Submit review including conversation history.
      final response = await ApiService().submitReview(
        token: token,
        transcript: transcript,
        terms: termsData,
        attemptNumber: attemptNumber,
        conversationHistory: conversationHistory,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sessionId.value = data['sessionId'];
        updatedTerms.assignAll(data['updatedTerms']);
        print('Review submitted successfully: $data');

        final List<dynamic> updated = data['updatedTerms'];
        for (int i = 0; i < updated.length; i++) {
          final status = updated[i]['status'];
          if (status == 'mastered') {
            termProgress[i] = 1.0;
          } else if (status == 'needs_improvement') {
            double currentProgress = termProgress[i];
            // Randomize if the current progress is not between 40% (0.4) and 60% (0.6).
            if (currentProgress < 0.4 || currentProgress > 0.6) {
              final random = Random();
              termProgress[i] = 0.4 + random.nextDouble() * 0.2;
            }
          } else if (status == 'unattempted') {
            termProgress[i] = 0.0;
          }
        }

        // Optionally delay to allow audio generation to finish.
        await Future.delayed(const Duration(seconds: 2));
        await fetchReviewAudio();
        feedbackMessage.value = data['feedbackMessage'];
        conversationHistory
            .add({'role': 'tutor', 'message': data['feedbackMessage']});

        // Check if all returned terms are "mastered".
        bool allMastered =
            updated.every((element) => element['status'] == 'mastered');
        if (allMastered) {
          // Wait for the audio to finish playing, then trigger next question.
          await audioPlayer.onPlayerComplete.first;
          courseController.nextQuestion();
        }
      } else {
        print('Failed to submit review: ${response.statusCode}');
        Get.snackbar("Error", "Failed to submit audio.");
      }
    } catch (e) {
      print('Error submitting review: $e');
      Get.snackbar("Error", "Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviewAudio({int attempt = 1, int maxAttempts = 3}) async {
    print("Fetching review audio... Attempt: $attempt");
    try {
      if (sessionId.value.isEmpty) {
        print("No session id available");
        return;
      }
      final token = await authController.getIdToken();
      if (token == null) {
        print("No user token found.");
        return;
      }
      final response = await ApiService().getReviewAudio(
        token: token,
        sessionId: sessionId.value,
      );
      if (response.statusCode == 200) {
        print("Review audio fetched successfully.");
        await _playAudioFromBytes(response.bodyBytes);
      } else if (response.statusCode == 404 && attempt < maxAttempts) {
        print("Review audio not available yet (404), retrying...");
        await Future.delayed(const Duration(seconds: 1));
        await fetchReviewAudio(attempt: attempt + 1, maxAttempts: maxAttempts);
      } else {
        print("Failed to fetch review audio: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching review audio: $e");
    }
  }

  Future<void> _playAudioFromBytes(Uint8List bytes) async {
    try {
      isAudioPlaying.value = true;
      final tempDir = await getTemporaryDirectory();
      final filePath = p.join(tempDir.path, 'review_audio.wav');
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      isAudioPlaying.value = false;
      print("Error playing audio from bytes: $e");
    }
  }
}
