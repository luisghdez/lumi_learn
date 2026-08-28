import 'dart:math';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/application/models/question.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/application/services/talk_to_lumi_realtime_service.dart';
import 'package:uuid/uuid.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/terms_deck.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/type_writer_speech_bubble.dart';

class SpeakScreen extends StatefulWidget {
  final Question question;
  const SpeakScreen({super.key, required this.question});

  @override
  State<SpeakScreen> createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen> {
  static const bool _realtimeTalkEnabled =
      bool.fromEnvironment('talk_to_lumi_realtime', defaultValue: false);
  final SpeakController speakController = Get.find<SpeakController>();
  final CourseController courseController = Get.find<CourseController>();
  TalkToLumiRealtimeService? _realtimeTalk;
  TalkRealtimeSession? _realtimeSession;
  StreamSubscription<TalkRealtimeEvent>? _realtimeEventsSubscription;
  StreamSubscription<TalkRealtimeConnectionState>? _realtimeStateSubscription;
  TalkRealtimeConnectionState _realtimeState = TalkRealtimeConnectionState.idle;
  String _liveTranscript = '';
  DateTime? _realtimeStartedAt;

  @override
  void initState() {
    super.initState();
    // Initialize controller with the question's terms and play intro audio.
    speakController.setTerms(widget.question.flashcards);
    speakController.playIntroAudio();
    if (_realtimeTalkEnabled) {
      _realtimeTalk = TalkToLumiRealtimeService();
      _realtimeEventsSubscription = _realtimeTalk!.events.listen(_handleRealtimeEvent);
      _realtimeStateSubscription = _realtimeTalk!.states.listen((state) {
        if (mounted) setState(() => _realtimeState = state);
      });
    }
  }

  @override
  void dispose() {
    // Reset all controller values when this screen is disposed.
    speakController.resetValues();
    _realtimeEventsSubscription?.cancel();
    _realtimeStateSubscription?.cancel();
    unawaited(_realtimeTalk?.dispose() ?? Future<void>.value());
    super.dispose();
  }

  void _handleRealtimeEvent(TalkRealtimeEvent event) {
    if (!mounted) return;
    if (event.type == 'conversation.item.input_audio_transcription.delta' &&
        event.transcript != null) {
      setState(() => _liveTranscript += event.transcript!);
    } else if (event.type ==
            'conversation.item.input_audio_transcription.completed' &&
        event.transcript != null) {
      setState(() => _liveTranscript = event.transcript!);
    } else if (event.type == 'error' && event.message != null) {
      Get.snackbar('Talk to Lumi unavailable', 'You can still use the regular recorder.');
    }
  }

  Future<void> _toggleRealtimeTalk() async {
    if (_realtimeSession != null) {
      await _finishRealtimeTalk();
      return;
    }
    final service = _realtimeTalk;
    if (service == null) return;
    final token = await speakController.authController.getIdToken();
    final lessonIndex = courseController.activeLessonIndex.value;
    final lessons = courseController.lessons;
    final lessonId = lessonIndex >= 0 && lessonIndex < lessons.length
        ? lessons[lessonIndex]['id'] as String?
        : null;
    final courseId = courseController.selectedCourseId.value;
    if (token == null || lessonId == null || courseId.isEmpty) {
      Get.snackbar('Talk to Lumi unavailable', 'Please reopen this lesson and try again.');
      return;
    }
    try {
      setState(() {
        _liveTranscript = '';
        _realtimeState = TalkRealtimeConnectionState.connecting;
      });
      final session = await service.connect(
        token: token,
        courseId: courseId,
        lessonId: lessonId,
      );
      if (!mounted) return;
      setState(() {
        _realtimeSession = session;
        _realtimeStartedAt = DateTime.now();
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _realtimeSession = null;
          _realtimeState = TalkRealtimeConnectionState.idle;
        });
      }
    }
  }

  Future<void> _finishRealtimeTalk() async {
    final session = _realtimeSession;
    final service = _realtimeTalk;
    if (session == null || service == null) return;
    final transcript = _liveTranscript.trim();
    if (transcript.isEmpty) {
      Get.snackbar('I didn’t hear that', 'Try talking for a moment, or use the regular recorder.');
      return;
    }
    final token = await speakController.authController.getIdToken();
    if (token == null) return;
    try {
      setState(() => _realtimeState = TalkRealtimeConnectionState.connecting);
      final durationMs = DateTime.now()
          .difference(_realtimeStartedAt ?? DateTime.now())
          .inMilliseconds;
      final response = await ApiService().assessTalkAttempt(
        token: token,
        attemptId: session.attemptId,
        transcript: transcript,
        turnId: const Uuid().v4(),
        durationMs: durationMs,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Talk assessment failed (${response.statusCode})');
      }
      final assessment = jsonDecode(response.body) as Map<String, dynamic>;
      speakController.applyTalkAssessment(
        focusTerm: assessment['termId'] as String,
        score: assessment['score'] as int,
        feedbackText: assessment['feedbackText'] as String,
        nextAction: assessment['nextAction'] as String,
      );
    } catch (_) {
      Get.snackbar('Review unavailable', 'Your live answer was not submitted. Please try again.');
    } finally {
      await service.disconnect();
      if (mounted) {
        setState(() {
          _realtimeSession = null;
          _realtimeState = TalkRealtimeConnectionState.idle;
          _realtimeStartedAt = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SpeakController speakController = Get.find<SpeakController>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final bool isTablet = screenWidth >= 768;
    final double rawTopPadding = isTablet
        ? MediaQuery.of(context).padding.top + 50
        : MediaQuery.of(context).padding.top - 50;
    final double topPadding = max(rawTopPadding, 16);

    final double textSize = isTablet ? 18.0 : 14.0;
    final double astronautSize = min(screenHeight * 0.25, 320.0);
    final double bubbleMaxHeight =
        isTablet ? screenHeight * 0.20 : screenHeight * 0.1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 0, 11, 59),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Main content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: topPadding + 16),

                    // Astronaut Image
                    Center(
                      child: Container(
                        width: astronautSize,
                        height: astronautSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.white30, width: 2),
                          image: const DecorationImage(
                            image: AssetImage('assets/astronaut/thinking.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Speech bubble
                    Obx(
                      () => TypewriterSpeechBubbleMessage(
                        key: ValueKey(speakController.feedbackMessage.value),
                        message: speakController.feedbackMessage.value.isEmpty
                            ? "Okay... press record and teach me like I forgot EVERYTHING, because I did!"
                            : speakController.feedbackMessage.value,
                        speed: const Duration(milliseconds: 70),
                        maxHeight: bubbleMaxHeight,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                        onFinished: () {},
                      ),
                    ),

                    const Spacer(),

                    // Terms deck
                    Obx(() {
                      return TermsDeck(
                        terms:
                            speakController.terms.map((fc) => fc.term).toList(),
                        progressList: speakController.termProgress,
                        currentTermIndex:
                            speakController.currentTermIndex.value,
                      );
                    }),

                    const SizedBox(height: 16),

                    // Record button
                    Center(
                      child: Obx(
                        () {
                          final recordingState =
                              speakController.recordingState.value;
                          final isStarting =
                              recordingState == SpeakRecordingState.starting;
                          final isLoading = isStarting ||
                              recordingState == SpeakRecordingState.stopping ||
                              recordingState == SpeakRecordingState.submitting;
                          final isSpeechUnavailable =
                              recordingState == SpeakRecordingState.error;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RecordButton(
                                onStartRecording:
                                    speakController.startListening,
                                onStopRecording: speakController.stopListening,
                                isRecording: recordingState ==
                                    SpeakRecordingState.listening,
                                isLoading: isLoading,
                                loadingLabel: isStarting
                                    ? 'Starting microphone…'
                                    : recordingState ==
                                            SpeakRecordingState.stopping
                                        ? 'Finishing up…'
                                        : 'Reviewing…',
                                isSpeechUnavailable: isSpeechUnavailable,
                                isDisabled:
                                    speakController.isAudioPlaying.value ||
                                        isLoading ||
                                        recordingState ==
                                            SpeakRecordingState.initializing ||
                                        isSpeechUnavailable,
                              ),
                              if (isSpeechUnavailable)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        speakController.openMicrophoneSettings,
                                    icon: const Icon(Icons.settings_outlined),
                                    label: const Text('Open Settings'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_realtimeTalkEnabled)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: OutlinedButton.icon(
                                    onPressed: isLoading ||
                                            speakController.isAudioPlaying.value ||
                                            _realtimeState ==
                                                TalkRealtimeConnectionState.connecting
                                        ? null
                                        : _toggleRealtimeTalk,
                                    icon: Icon(_realtimeSession == null
                                        ? Icons.graphic_eq
                                        : Icons.done_outline),
                                    label: Text(_realtimeSession == null
                                        ? 'Talk it through (beta)'
                                        : 'Finish live answer'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.lightBlueAccent,
                                      side: const BorderSide(
                                        color: Colors.lightBlueAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              if (_realtimeTalkEnabled &&
                                  _realtimeSession != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _liveTranscript.isEmpty
                                        ? 'Listening… explain it in your own words.'
                                        : _liveTranscript,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Skip button in its own positioned widget so it doesn't affect the main layout
            Positioned(
              top: topPadding,
              right: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    showSkipConfirmationDialog(context, courseController),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: textSize,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordButton extends StatelessWidget {
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final bool isRecording;
  final bool isLoading;
  final bool isDisabled;
  final bool isSpeechUnavailable;
  final String loadingLabel;

  const RecordButton({
    super.key,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.isRecording,
    required this.isLoading,
    required this.isDisabled,
    required this.isSpeechUnavailable,
    required this.loadingLabel,
  });

  void _toggleRecording() {
    if (isDisabled) return;

    if (isRecording) {
      onStopRecording();
    } else {
      onStartRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Visually fade out if disabled
    final double opacityValue = isDisabled ? 0.5 : 1.0;

    return GestureDetector(
      onTap: _toggleRecording,
      child: Opacity(
        opacity: opacityValue,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSpeechUnavailable
                    ? Colors.redAccent.withValues(alpha: 0.25)
                    : isDisabled
                        ? Colors.grey.withValues(alpha: 0.3)
                        : isLoading
                            ? Colors.white.withValues(alpha: 0.3)
                            : isRecording
                                ? Colors.redAccent.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.9),
              ),
              child: isLoading
                  ? const Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(greyBorder),
                          ),
                        ),
                        Icon(
                          Icons.mic_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    )
                  : Icon(
                      isSpeechUnavailable
                          ? Icons.mic_off_outlined
                          : isRecording
                              ? Icons.mic_off
                              : Icons.mic_outlined,
                      color: isSpeechUnavailable || isRecording
                          ? Colors.white
                          : Colors.black87,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              isSpeechUnavailable
                  ? "Speech unavailable"
                  : isDisabled
                      ? ""
                      : isLoading
                          ? loadingLabel
                          : (isRecording ? "Tap to stop" : "Tap to record"),
              style: const TextStyle(
                color: Color.fromARGB(129, 255, 255, 255),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showSkipConfirmationDialog(
    BuildContext context, CourseController courseController) {
  Get.dialog(
    Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 12, 12, 12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greyBorder, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Don't leave Lumi hanging!",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 20,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/astronaut/phone_sad.png',
                height: 220,
              ),
              const SizedBox(height: 16),
              const Text(
                "Studies show that teaching others can boost your understanding and memory by up to 90%",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    courseController.nextQuestion(); // Skip
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Skip Anyway',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
