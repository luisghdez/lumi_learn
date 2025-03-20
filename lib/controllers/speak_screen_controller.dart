import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/services/api_service.dart';
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
    // Assumes your mark_intro.mp3 is in your assets folder and declared in pubspec.yaml
    await audioPlayer.play(AssetSource("sounds/mark_intro2.mp3"));
  }

  Future<void> _initSpeech() async {
    try {
      _speechToText = SpeechToText();
      speechEnabled.value = await _speechToText.initialize(
        onStatus: _onStatus,
        onError: (error) => print('Speech error: $error'),
      );
      // rm await or add
      _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(minutes: 2),
        localeId: "en_US",
      );
      print("Speech enabled: ${speechEnabled.value}");
    } catch (e) {
      print("Error initializing speech recognizer: $e");
      speechEnabled.value = false;
    }
  }

  /// Called when the user taps "start" for a new segment.
  Future<void> startListening() async {
    // Mark the current index in the transcript.
    _segmentStartIndex = transcript.value.length;
    print("Segment started. Marker index: $_segmentStartIndex");
  }

  /// Called when the user taps "stop" for the current segment.
  Future<void> stopListening() async {
    // Get the complete transcript
    String fullTranscript = transcript.value;
    // Extract only the words after the marker.
    String segmentTranscript = '';
    if (fullTranscript.length >= _segmentStartIndex) {
      segmentTranscript = fullTranscript.substring(_segmentStartIndex);
    }
    print("Segment transcript: $segmentTranscript");

    // Update marker to the current end if you plan to continue without resetting.
    _segmentStartIndex = fullTranscript.length;
    await submitReview(
        transcript: segmentTranscript, attemptNumber: attemptNumber);
    attemptNumber++;
  }

  void _startListening() {
    // You can also set 'pauseFor' here if the API supports it.
    print("Starting listening.. agaiaaaaan.");
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 2),
      localeId: "en_US",
    );
  }

  void _onStatus(String status) {
    print("Speech status: $status");
    // If the recognizer stops and the user still wants to listen, restart.
    if (isUserListening.value) {
      print("Restarting listening due to inactivity...");
      // Delay briefly if needed to ensure a smooth restart.
      Future.delayed(const Duration(milliseconds: 500), () {
        _startListening();
      });
    }
  }

  /// This callback continuously updates the transcript as the user speaks.
  void _onSpeechResult(SpeechRecognitionResult result) {
    transcript.value = result.recognizedWords;
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
        // Immediately attempt to fetch the review audio.
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
        // Instead of using playBytes, write to a file and play it.
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
      // Ensure you use the proper file extension (e.g., .wav, .mp3) as per your audio format.
      final filePath = p.join(tempDir.path, 'review_audio.wav');
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      print("Error playing audio from bytes: $e");
    }
  }
}
