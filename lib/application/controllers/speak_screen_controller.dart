import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
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
import 'package:permission_handler/permission_handler.dart';

enum SpeakRecordingState {
  initializing,
  ready,
  starting,
  listening,
  stopping,
  submitting,
  error,
}

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

  late final SpeechToText _speechToText;
  final RxBool speechEnabled = false.obs;
  final Rx<SpeakRecordingState> recordingState =
      SpeakRecordingState.initializing.obs;
  final RxString transcript = ''.obs;

  // New field for storing the definition of the current focus term.
  final RxString focusDefinition = ''.obs;

  // Attempt counter for the current term.
  int attemptNumber = 1;
  bool _hasSubmitted = false; // Flag to prevent duplicate submissions

  // Temporary, privacy-safe diagnostics for investigating the Speak flow.
  // Never add transcript, auth-token, or lesson-content values to these logs.
  String? _diagnosticSessionId;
  Stopwatch? _diagnosticStopwatch;
  int _diagnosticSequence = 0;
  Timer? _listeningStartTimeout;

  final RxList<Map<String, String>> conversationHistory =
      <Map<String, String>>[].obs;

  // Current term index.
  RxInt currentTermIndex = 0.obs;

  SpeakController();

  @override
  void onInit() {
    super.onInit();
    _trace('controller_initialized');
    _speechToText = SpeechToText();
    _initSpeech();

    // Anytime audio finishes, set [isAudioPlaying] to false.
    audioPlayer.onPlayerComplete.listen((_) {
      isAudioPlaying.value = false;
    });
  }

  @override
  void onClose() {
    _trace('controller_closed');
    _listeningStartTimeout?.cancel();
    _speechToText.stop();
    audioPlayer.dispose();
    super.onClose();
  }

  /// Resets all controller values, including current term and attempt number.
  void resetValues() {
    _trace('reset_requested', details: {
      'isLoading': isLoading.value,
      'isAudioPlaying': isAudioPlaying.value,
    });
    if (isAudioPlaying.value) {
      audioPlayer.stop();
    }
    _speechToText.stop();
    _listeningStartTimeout?.cancel();

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
    _setRecordingState(
      speechEnabled.value
          ? SpeakRecordingState.ready
          : SpeakRecordingState.initializing,
    );
  }

  /// Plays the introductory audio and marks the controller as currently playing.
  Future<void> playIntroAudio() async {
    try {
      isAudioPlaying.value = true;
      feedbackMessage.value =
          "Okay... press record and teach me like I forgot EVERYTHING, because I did!";
      await audioPlayer.play(AssetSource("sounds/echo_intro_4.wav"));
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
    _setRecordingState(SpeakRecordingState.initializing);
    _trace('speech_initialize_requested');
    try {
      speechEnabled.value = await _speechToText.initialize(
        onStatus: _onStatus,
        onError: _onSpeechError,
      );
      _setRecordingState(
        speechEnabled.value
            ? SpeakRecordingState.ready
            : SpeakRecordingState.error,
      );
      if (speechEnabled.value) {
        _trace('speech_initialize_completed', details: {'available': true});
      } else {
        _trace('speech_initialize_completed', details: {'available': false});
      }
    } catch (e) {
      _trace('speech_initialize_failed', details: {'error': e.toString()});
      speechEnabled.value = false;
      _setRecordingState(SpeakRecordingState.error);
      feedbackMessage.value = _speechUnavailableMessage;
    }
  }

  // This is your "fake" or "silent" pre-warm.
  Future<void> preWarmSpeechEngine() async {
    _trace('speech_prewarm_requested');
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
    if (recordingState.value != SpeakRecordingState.ready) {
      _trace('listen_start_blocked', details: {
        'reason': 'invalid_state',
        'state': recordingState.value.name,
      });
      return;
    }

    _beginDiagnosticSession();
    _trace('listen_start_requested', details: {
      'speechEnabled': speechEnabled.value,
    });
    if (!speechEnabled.value) {
      _trace('listen_start_blocked', details: {'reason': 'speech_unavailable'});
      _setRecordingState(SpeakRecordingState.error);
      feedbackMessage.value = _speechUnavailableMessage;
      return;
    }

    transcript.value = "";
    _hasSubmitted = false;
    _setRecordingState(SpeakRecordingState.starting);
    _listeningStartTimeout?.cancel();
    _listeningStartTimeout = Timer(const Duration(seconds: 4), () {
      if (recordingState.value == SpeakRecordingState.starting) {
        _trace('listen_start_timed_out');
        _handleSpeechUnavailable();
      }
    });

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(minutes: 2),
        localeId: "en_US",
      );
      _trace('listen_start_completed', details: {
        'isListening': _speechToText.isListening,
      });
    } catch (e) {
      _trace('listen_start_failed', details: {'error': e.toString()});
      _handleSpeechUnavailable();
    }
  }

  /// Called when the user taps "stop" to end the current segment.
  Future<void> stopListening() async {
    if (recordingState.value != SpeakRecordingState.listening) {
      _trace('listen_stop_blocked', details: {
        'reason': 'invalid_state',
        'state': recordingState.value.name,
      });
      return;
    }

    _trace('listen_stop_requested', details: {
      'isListening': _speechToText.isListening,
      'transcriptLength': transcript.value.length,
    });
    isLoading.value = true;
    _setRecordingState(SpeakRecordingState.stopping);
    try {
      await _speechToText.stop();
      _trace('listen_stop_completed', details: {
        'isListening': _speechToText.isListening,
      });
    } catch (e) {
      _trace('listen_stop_failed', details: {'error': e.toString()});
      _handleSpeechUnavailable();
      return;
    }

    // Allow time for any final speech recognition result.
    await Future.delayed(const Duration(milliseconds: 300));

    if (transcript.value.trim().isEmpty && !_hasSubmitted) {
      _hasSubmitted = true;
      _trace('silence_fallback_started');
      await playSilenceAudio();
      feedbackMessage.value =
          "I didn’t hear an explanation that time. Try speaking a little closer to your microphone.";
      isLoading.value = false;
      transcript.value = "";
      _setRecordingState(SpeakRecordingState.ready);
      _trace('silence_fallback_completed');
    }
  }

  /// Updates the transcript as speech is recognized.
  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    transcript.value = result.recognizedWords;
    _trace('speech_result_received', details: {
      'isFinal': result.finalResult,
      'transcriptLength': result.recognizedWords.length,
    });

    if (result.finalResult && !_hasSubmitted) {
      _hasSubmitted = true;
      isLoading.value = true;
      _setRecordingState(SpeakRecordingState.submitting);
      _trace('speech_final_result_accepted', details: {
        'attemptNumber': attemptNumber,
      });

      // Submit the transcript for the current term.
      await submitReview(
        transcript: transcript.value,
      );

      transcript.value = "";
    }
  }

  void _onStatus(String status) {
    _trace('speech_status_changed', details: {'status': status});
    if (status == 'listening' &&
        recordingState.value == SpeakRecordingState.starting) {
      _setRecordingState(SpeakRecordingState.listening);
    }

    if ((status == 'done' || status == 'notListening') &&
        recordingState.value == SpeakRecordingState.listening) {
      _setRecordingState(SpeakRecordingState.ready);
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    _trace('speech_error', details: {
      'message': error.errorMsg,
      'permanent': error.permanent,
    });
    if (error.permanent) {
      _speechToText.cancel();
      _handleSpeechUnavailable();
    }
  }

  Future<void> submitReview({
    required String transcript,
  }) async {
    final requestStopwatch = Stopwatch()..start();
    _trace('review_submit_requested', details: {
      'transcriptLength': transcript.length,
      'attemptNumber': attemptNumber,
    });
    try {
      final token = await authController.getIdToken();
      if (token == null) {
        _trace('review_submit_blocked',
            details: {'reason': 'missing_auth_token'});
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

      _trace('review_submit_response', details: {
        'statusCode': response.statusCode,
        'durationMs': requestStopwatch.elapsedMilliseconds,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sessionId.value = data['sessionId'];

        updatedTerms.assignAll(data['updatedTerms']);
        _trace('review_submit_succeeded');

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
            _trace('review_terms_completed');
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
            _trace('review_closing_audio_completed');
            courseController.nextQuestion();
          }
        }
      } else {
        _trace('review_submit_failed', details: {
          'statusCode': response.statusCode,
        });
        Get.snackbar("Error", "Failed to submit audio.");
      }
    } catch (e) {
      _trace('review_submit_exception', details: {
        'error': e.toString(),
        'durationMs': requestStopwatch.elapsedMilliseconds,
      });
      final timedOut = e is TimeoutException;
      feedbackMessage.value = timedOut
          ? "That took too long. Your explanation wasn't submitted—please try again."
          : "I hit a snag with that explanation. Please try again.";
      Get.snackbar(
        timedOut ? "Review timed out" : "Review unavailable",
        timedOut
            ? "Please check your connection and try again."
            : "Please try recording your explanation again.",
      );
    } finally {
      isLoading.value = false;
      if (recordingState.value == SpeakRecordingState.submitting) {
        _setRecordingState(SpeakRecordingState.ready);
      }
      _trace('review_submit_finished', details: {
        'durationMs': requestStopwatch.elapsedMilliseconds,
      });
    }
  }

  Future<void> fetchReviewAudio({int attempt = 1, int maxAttempts = 3}) async {
    final requestStopwatch = Stopwatch()..start();
    _trace('review_audio_requested', details: {'attempt': attempt});
    try {
      if (sessionId.value.isEmpty) {
        _trace('review_audio_blocked',
            details: {'reason': 'missing_session_id'});
        return;
      }
      final token = await authController.getIdToken();
      if (token == null) {
        _trace('review_audio_blocked',
            details: {'reason': 'missing_auth_token'});
        return;
      }
      final response = await ApiService().getReviewAudio(
        token: token,
        sessionId: sessionId.value,
      );
      _trace('review_audio_response', details: {
        'attempt': attempt,
        'statusCode': response.statusCode,
        'durationMs': requestStopwatch.elapsedMilliseconds,
      });
      if (response.statusCode == 200) {
        _trace('review_audio_succeeded', details: {'attempt': attempt});
        await _playAudioFromBytes(response.bodyBytes);
      } else if (response.statusCode == 404 && attempt < maxAttempts) {
        _trace('review_audio_retry_scheduled', details: {'attempt': attempt});
        await Future.delayed(const Duration(seconds: 1));
        await fetchReviewAudio(attempt: attempt + 1, maxAttempts: maxAttempts);
      } else {
        _trace('review_audio_failed', details: {
          'attempt': attempt,
          'statusCode': response.statusCode,
        });
        _showAudioUnavailableMessage();
      }
    } catch (e) {
      _trace('review_audio_exception', details: {
        'attempt': attempt,
        'error': e.toString(),
        'durationMs': requestStopwatch.elapsedMilliseconds,
      });
      if (attempt < maxAttempts) {
        _trace('review_audio_retry_scheduled', details: {
          'attempt': attempt,
          'reason': 'request_exception',
        });
        await Future.delayed(const Duration(seconds: 1));
        await fetchReviewAudio(attempt: attempt + 1, maxAttempts: maxAttempts);
      } else {
        _showAudioUnavailableMessage();
      }
    }
  }

  Future<void> _playAudioFromBytes(Uint8List bytes) async {
    _trace('feedback_audio_play_requested',
        details: {'byteLength': bytes.length});
    try {
      isAudioPlaying.value = true;
      final tempDir = await getTemporaryDirectory();
      final filePath = p.join(tempDir.path, 'review_audio.mp3');
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await audioPlayer.play(DeviceFileSource(filePath));
      _trace('feedback_audio_play_started');
    } catch (e) {
      isAudioPlaying.value = false;
      _trace('feedback_audio_play_failed', details: {'error': e.toString()});
    }
  }

  void _beginDiagnosticSession() {
    _diagnosticSequence++;
    _diagnosticSessionId = 's$_diagnosticSequence';
    _diagnosticStopwatch = Stopwatch()..start();
    _trace('diagnostic_session_started');
  }

  void _trace(String event, {Map<String, Object?> details = const {}}) {
    final elapsedMs = _diagnosticStopwatch?.elapsedMilliseconds;
    final fields = <String, Object?>{
      'event': event,
      'session': _diagnosticSessionId ?? 'none',
      if (elapsedMs != null) 'elapsedMs': elapsedMs,
      ...details,
    };
    debugPrint('[SpeakDiagnostics] $fields');
  }

  static const _speechUnavailableMessage =
      "Lumi needs microphone access to hear your explanation. Turn on Microphone and Speech Recognition in Settings, then reopen Lumi.";

  void _handleSpeechUnavailable() {
    _listeningStartTimeout?.cancel();
    speechEnabled.value = false;
    isLoading.value = false;
    _setRecordingState(SpeakRecordingState.error);
    feedbackMessage.value = _speechUnavailableMessage;
  }

  void _setRecordingState(SpeakRecordingState nextState) {
    if (recordingState.value == nextState) return;
    final previousState = recordingState.value;
    if (previousState == SpeakRecordingState.starting &&
        nextState != SpeakRecordingState.starting) {
      _listeningStartTimeout?.cancel();
    }
    recordingState.value = nextState;
    _trace('recording_state_changed', details: {
      'from': previousState.name,
      'to': nextState.name,
    });
  }

  Future<void> openMicrophoneSettings() async {
    _trace('microphone_settings_requested');
    final opened = await openAppSettings();
    if (!opened) {
      Get.snackbar(
        'Settings unavailable',
        'Open Settings and allow Lumi to use the Microphone and Speech Recognition.',
      );
    }
  }

  void _showAudioUnavailableMessage() {
    Get.snackbar(
      "Audio unavailable",
      "Your written feedback is still available. Continue when you're ready.",
    );
  }
}
