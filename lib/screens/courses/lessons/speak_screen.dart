import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/terms_deck.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/type_writer_speech_bubble.dart';

class SpeakScreen extends StatefulWidget {
  final Question question;
  const SpeakScreen({Key? key, required this.question}) : super(key: key);

  @override
  _SpeakScreenState createState() => _SpeakScreenState();
}

class _SpeakScreenState extends State<SpeakScreen> {
  final SpeakController speakController = Get.find<SpeakController>();
  final CourseController courseController = Get.find<CourseController>();

  @override
  void initState() {
    super.initState();
    // Initialize controller with the question's terms and play intro audio.
    speakController.setTerms(widget.question.flashcards);
    speakController.playIntroAudio();
  }

  @override
  void dispose() {
    // Reset all controller values when this screen is disposed.
    speakController.resetValues();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SpeakController speakController = Get.find<SpeakController>();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double topPadding = isTablet
        ? MediaQuery.of(context).padding.top + 50
        : MediaQuery.of(context).padding.top - 50;

    final double textSize = isTablet ? 18.0 : 14.0;
    final double astronautSize = isTablet ? 320.0 : 250.0;

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: topPadding),

                // Skip button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          showSkipConfirmationDialog(context, courseController),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: textSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Astronaut Image
                Center(
                  child: Container(
                    width: astronautSize,
                    height: astronautSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
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
                    maxHeight: isTablet ? 160 : 130,
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
                    terms: speakController.terms.map((fc) => fc.term).toList(),
                    progressList: speakController.termProgress,
                    currentTermIndex: speakController.currentTermIndex.value,
                  );
                }),

                const SizedBox(height: 16),

                // Record button
                Center(
                  child: Obx(
                    () => RecordButton(
                      onStartRecording: speakController.startListening,
                      onStopRecording: () {
                        speakController.isLoading.value = true;
                        speakController.stopListening();
                      },
                      isLoading: speakController.isLoading.value,
                      isDisabled: speakController.isAudioPlaying.value ||
                          speakController.isLoading.value,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecordButton extends StatefulWidget {
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final bool isLoading;
  final bool isDisabled;

  const RecordButton({
    Key? key,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.isLoading,
    required this.isDisabled,
  }) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool isRecording = false;

  void _toggleRecording() {
    if (widget.isDisabled) return;

    if (isRecording) {
      widget.onStopRecording();
      setState(() {
        isRecording = false;
      });
    } else {
      setState(() {
        isRecording = true;
      });
      widget.onStartRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Visually fade out if disabled
    final double opacityValue = widget.isDisabled ? 0.5 : 1.0;

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
                color: widget.isDisabled
                    ? Colors.grey.withOpacity(0.3)
                    : widget.isLoading
                        ? Colors.white.withOpacity(0.3)
                        : isRecording
                            ? Colors.redAccent.withOpacity(0.5)
                            : Colors.white.withOpacity(0.9),
              ),
              child: widget.isLoading
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
                      isRecording ? Icons.mic_off : Icons.mic_outlined,
                      color: isRecording ? Colors.white : Colors.black87,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isDisabled
                  ? ""
                  : widget.isLoading
                      ? "Loading..."
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
