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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Just extra spacing
            SizedBox(height: MediaQuery.of(context).padding.top - 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      showSkipConfirmationDialog(context, courseController),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Large Circle Contact Avatar
            Center(
              child: Container(
                width: 250,
                height: 250,
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

            // Typewriter speech bubble
            Obx(
              () => TypewriterSpeechBubbleMessage(
                key: ValueKey(speakController.feedbackMessage.value),
                message: speakController.feedbackMessage.value.isEmpty
                    ? "Okay... press record and teach me like I forgot EVERYTHING, because I did!"
                    : speakController.feedbackMessage.value,
                speed: const Duration(milliseconds: 70),
                maxHeight: 130,
                onFinished: () {
                  // Optionally do something after the bubble finishes typing
                },
              ),
            ),
            const Spacer(),

            // The deck of terms. We'll pass in currentTermIndex so the top card is the current term:
            Obx(() {
              return TermsDeck(
                terms: speakController.terms
                    .map((flashcard) => flashcard.term)
                    .toList(),
                progressList: speakController.termProgress,
                currentTermIndex: speakController.currentTermIndex.value,
              );
            }),

            const SizedBox(height: 16),

            // The Record Button
            Center(
              child: Obx(
                () => RecordButton(
                  onStartRecording: speakController.startListening,
                  onStopRecording: () {
                    speakController.isLoading.value = true;
                    speakController.stopListening();
                  },
                  isLoading: speakController.isLoading.value,
                  // Disable if either audio is playing or isLoading
                  isDisabled: speakController.isAudioPlaying.value ||
                      speakController.isLoading.value,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
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
            // const SizedBox(height: 16),
            SizedBox(
              width: 0.75 * Get.width,
              child: const Text(
                "Don't leave Lumi hanging!",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 20,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Image.asset(
              'assets/astronaut/phone_sad.png',
              height: 220,
            ),
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
            const SizedBox(height: 14),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
