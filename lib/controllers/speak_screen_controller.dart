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
    audioPlayer.dispose();

    super.onClose();
  }

  void resetValues() {
    // Stop any audio currently playing.
    if (isAudioPlaying.value) {
      audioPlayer.stop();
    }

    // Stop speech recognition.
    _speechToText.stop();

    // Reset all reactive variables.
    terms.clear();
    termProgress.clear();
    feedbackMessage.value = '';
    reviewAudioBytes.value = Uint8List(0);
    transcript.value = '';
    conversationHistory.clear();
    sessionId.value = '';
    updatedTerms.clear();

    // Reset counters and flags.
    attemptNumber = 1;
    _hasSubmitted = false;
    isLoading.value = false;
    isAudioPlaying.value = false;
  }

  /// Plays the introductory audio and marks the controller as currently playing.
  Future<void> playIntroAudio() async {
    try {
      isAudioPlaying.value = true;
      feedbackMessage.value =
          "Whew! okay, here we go. Think of this like a quick brain check-in. You’ve got THREE terms. You hit record. You talk it out. That’s it. Go with your gut and let’s see what you know.";
      await audioPlayer.play(AssetSource("sounds/echo_intro.wav"));
    } catch (e) {
      isAudioPlaying.value = false;
      rethrow;
    }
  }

  /// Plays the closing audio.
  Future<void> playClosingAudio() async {
    try {
      isAudioPlaying.value = true;
      await audioPlayer.play(AssetSource("sounds/echo_outro_2.wav"));
    } catch (e) {
      isAudioPlaying.value = false;
      rethrow;
    }
  }

  /// Plays fallback silence audio when no speech is detected.
  Future<void> playSilenceAudio() async {
    try {
      isAudioPlaying.value = true;
      await audioPlayer.play(AssetSource("sounds/echo_silence.wav"));
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
    await _speechToText.stop();

    // Wait a short moment to allow any pending final results to be processed
    await Future.delayed(const Duration(milliseconds: 300));

    // If no speech was detected and _onSpeechResult wasn’t triggered,
    // trigger the fallback silence audio.
    if (transcript.value.trim().isEmpty && !_hasSubmitted) {
      _hasSubmitted = true;
      await playSilenceAudio();
      feedbackMessage.value =
          "Uhhh... you there? I didn’t hear ANYTHING, let’s try that again!";
      isLoading.value = false;
      transcript.value = "";
    }
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
        feedbackMessage.value =
            "Hey that was AWESOME! I mean, look at you go, you’re really soaking this stuff up. Honestly, just keep going like this and we’re gonna make some SERIOUS progress.";
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

      // Build terms list with scores based on progress.
      final List<Map<String, dynamic>> termsData = [];
      for (var i = 0; i < terms.length; i++) {
        final score = (termProgress[i] * 100)
            .round(); // Convert back to 0–100 scale for api service call
        termsData.add({'term': terms[i], 'score': score});
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
          final score = updated[i]['score'];
          termProgress[i] = (score / 100).clamp(0.0, 1.0);
          // 0-1 scale for progress bar
        }

        // Optionally delay to allow audio generation to finish.
        await Future.delayed(const Duration(seconds: 2));
        await fetchReviewAudio();
        final original = data['feedbackMessage'] as String;
        final cleaned = original.replaceAll(RegExp(r'\[.*?\]'), '').trim();
        feedbackMessage.value = cleaned;

        conversationHistory
            .add({'role': 'tutor', 'message': data['feedbackMessage']});

        // Check if all returned terms are "100".
        bool allMastered = updated.every((element) => element['score'] == 100);

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
