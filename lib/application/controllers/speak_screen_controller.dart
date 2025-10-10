import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/models/question.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SpeakController extends GetxController {
  final AuthController authController = Get.find();
  final CourseController courseController = Get.find();

  RxList<Flashcard> terms = <Flashcard>[].obs;
  // Progress for each term, on a 0–1 scale.
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

  // New field for storing the definition of the current focus term.
  final RxString focusDefinition = ''.obs;

  // Attempt counter for the current term.
  int attemptNumber = 1;
  bool _hasSubmitted = false; // Flag to prevent duplicate submissions

  final RxList<Map<String, String>> conversationHistory =
      <Map<String, String>>[].obs;

  // Current term index.
  RxInt currentTermIndex = 0.obs;

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

  /// Resets all controller values, including current term and attempt number.
  void resetValues() {
    if (isAudioPlaying.value) {
      audioPlayer.stop();
    }
    _speechToText.stop();

    terms.clear();
    termProgress.clear();
    feedbackMessage.value = '';
    reviewAudioBytes.value = Uint8List(0);
    transcript.value = '';
    conversationHistory.clear();
    sessionId.value = '';
    updatedTerms.clear();

    attemptNumber = 1;
    currentTermIndex.value = 0;
    _hasSubmitted = false;
    isLoading.value = false;
    isAudioPlaying.value = false;
  }

  /// Plays the introductory audio and marks the controller as currently playing.
  Future<void> playIntroAudio() async {
    try {
      isAudioPlaying.value = true;
      feedbackMessage.value =
          "Okay... press record and teach me like I forgot EVERYTHING, because I did!";
      await audioPlayer.play(AssetSource("sounds/echo_intro_4.wav"));
      isAudioPlaying.value = false;
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
      // Wait for the audio to complete.
      await audioPlayer.onPlayerComplete.first;
      isAudioPlaying.value = false;
    } catch (e) {
      isAudioPlaying.value = false;
      rethrow;
    }
  }

  /// Plays the alternative closing audio.
  Future<void> playClosingAudio2() async {
    try {
      isAudioPlaying.value = true;
      // Replace "sounds/echo_outro_2_alt.wav" with your alternative asset's path.
      await audioPlayer.play(AssetSource("sounds/echo_outro_3.wav"));
      // Optionally, wait for the audio to complete.
      await audioPlayer.onPlayerComplete.first;
      isAudioPlaying.value = false;
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
    await Future.delayed(const Duration(seconds: 1));
    await _speechToText.stop();
  }

  /// Sets terms from outside and resets term progress, current term index, and attempt number.
  void setTerms(List<Flashcard> newTerms) {
    terms.value = newTerms;
    termProgress.assignAll(List<double>.filled(newTerms.length, 0.0));
    currentTermIndex.value = 0;
    attemptNumber = 1;
  }

  /// Sets the definition for the current focus term.
  void setFocusDefinition(String definition) {
    focusDefinition.value = definition;
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

    // Allow time for any final speech recognition result.
    await Future.delayed(const Duration(milliseconds: 300));

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
      print("Attempt number for current term: $attemptNumber");

      // Submit the transcript for the current term.
      await submitReview(
        transcript: transcript.value,
      );

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

  Future<void> submitReview({
    required String transcript,
  }) async {
    try {
      final token = await authController.getIdToken();
      if (token == null) {
        print('No user token found.');
        isLoading.value = false;
        return;
      }

      final int currentIndex = currentTermIndex.value;

      // Build the full terms data for the API call.
      final List<Map<String, dynamic>> termsData = [];
      for (var i = 0; i < terms.length; i++) {
        final score = (termProgress[i] * 100).round(); // convert to 0–100 scale
        // Use terms[i].term to extract the string value.
        termsData.add({'term': terms[i].term, 'score': score});
      }

      // Add the user transcript to the conversation history.
      conversationHistory.add({'role': 'user', 'message': transcript});

      print("transcript: $transcript");
      // Use the term property for logging
      print("for term: ${terms[currentIndex].term}");

      // Submit the review including focusTerm and focusDefinition.
      final response = await ApiService().submitReview(
        token: token,
        transcript: transcript,
        focusTerm: terms[currentIndex].term,
        focusDefinition: terms[currentIndex].definition,
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

        // Optionally delay to let the audio be generated.
        await Future.delayed(const Duration(seconds: 2));
        await fetchReviewAudio();

        // Set feedback message as provided by the API.
        final original = data['feedbackMessage'] as String;
        final cleaned = original.replaceAll(RegExp(r'\[.*?\]'), '').trim();
        feedbackMessage.value = cleaned;

        conversationHistory
            .add({'role': 'tutor', 'message': data['feedbackMessage']});

        attemptNumber++;

        if (termProgress[currentIndex] >= 1.0 || attemptNumber > 3) {
          if (currentIndex < terms.length - 1) {
            currentTermIndex.value++;
            attemptNumber = 1;
            // Clear conversation history for the new term
            conversationHistory.clear();
          } else {
            print("all terms gone through");
            bool allPerfect = termProgress.every((score) => score == 1.0);

            if (allPerfect) {
              // All terms are perfect – play the first closing audio.
              feedbackMessage.value =
                  "Hey that was AWESOME! I mean, look at you go, you're really soaking this stuff up. Honestly, just keep going like this and we're gonna make some SERIOUS progress.";
              await playClosingAudio();
            } else {
              // Not all terms are perfect – play the alternative closing audio.
              feedbackMessage.value =
                  "Sooo close! You nailed most of it, but a few slipped by. Flashcards are your secret weapon—go give 'em a spin!";
              await playClosingAudio2();
            }
            // await audioPlayer.onPlayerComplete.first;
            // After the closing audio finishes, proceed to the next question.
            print("Closing audio finished, calling nextQuestion");
            courseController.nextQuestion();
          }
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
