import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/services/api_service.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

  late SpeechToText _speechToText;
  final RxBool speechEnabled = false.obs;
  final RxString transcript = ''.obs;

  int _segmentStartIndex = 0;
  int attemptNumber = 1;
  final RxBool isUserListening = true.obs;

  SpeakController({required this.terms}) {
    // Initialize the list with a default value (0.0) for each term.
    termProgress.assignAll(List<double>.filled(terms.length, 0.0));
  }

  @override
  void onInit() {
    super.onInit();
    playIntroAudio();
    _initSpeech();
  }

  @override
  void onClose() {
    // Stop the speech recognizer when the controller is disposed.
    _speechToText.stop();
    isUserListening.value = false;
    super.onClose();
  }

  /// Plays the introductory audio.
  Future<void> playIntroAudio() async {
    await audioPlayer.play(AssetSource("sounds/mark_intro2.mp3"));
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

  /// Called when the user taps "start" to begin a new segment.
  Future<void> startListening() async {
    if (!speechEnabled.value) {
      print("Speech recognition not enabled or not initialized.");
      return;
    }
    // Mark the current transcript length to note the beginning of this segment.
    _segmentStartIndex = transcript.value.length;
    print("Segment started. Marker index: $_segmentStartIndex");

    // Start listening only when the user initiates.
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 2),
      localeId: "en_US",
    );
  }

  /// Called when the user taps "stop" to end the current segment.
  Future<void> stopListening() async {
    // Stop listening to speech.
    _speechToText.stop();

    // Extract the current segment from the transcript.
    String fullTranscript = transcript.value;
    String segmentTranscript = fullTranscript.substring(_segmentStartIndex);
    print("Full transcript: $fullTranscript");
    print("Segment transcript: $segmentTranscript");

    // Update the marker for future segments.
    _segmentStartIndex = fullTranscript.length;

    // Submit the review with the extracted segment.
    await submitReview(
        transcript: segmentTranscript, attemptNumber: attemptNumber);
    attemptNumber++;

    // Optionally clear the transcript for the next session.
    transcript.value = "";
  }

  /// Updates the transcript as speech is recognized.
  void _onSpeechResult(SpeechRecognitionResult result) {
    transcript.value = result.recognizedWords;
    print("Transcript: ${result.recognizedWords}");
    // No automatic reinitialization here: control is fully manual.
  }

  void _onStatus(String status) {
    print("Speech status: $status");
    // You can handle additional status updates if needed.
  }

  void _onSpeechError(SpeechRecognitionError error) {
    print("Speech error: ${error.errorMsg}, permanent: ${error.permanent}");
    if (error.permanent) {
      // Cancel and try reinitializing after a delay if the error is permanent.
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
    isLoading.value = true;
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

      print('Submitting review with terms: $termsData');
      print('Transcript: $transcript');
      print('Attempt number: $attemptNumber');

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
        await Future.delayed(const Duration(seconds: 2));
        // Trigger rebuild or update UI with feedback.
        await fetchReviewAudio();
        // down here to trigger rebuild of message once audio is fetched
        feedbackMessage.value = data['feedbackMessage'];
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
      final tempDir = await getTemporaryDirectory();
      final filePath = p.join(tempDir.path, 'review_audio.wav');
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      print("Error playing audio from bytes: $e");
    }
  }
}
