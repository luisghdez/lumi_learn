import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add this
import 'package:lumi_learn_app/controllers/speak_screen_controller.dart';
import 'package:lumi_learn_app/models/question.dart';
// import 'package:lumi_learn_app/screens/courses/lessons/widgets/audio_widget.dart';
// import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
// import 'package:lumi_learn_app/screens/courses/lessons/widgets/speach_bubble_black.dart';

class SpeakScreen extends StatelessWidget {
  SpeakScreen({
    Key? key,
    required this.question,
    required this.backgroundImage,
    required this.onSubmitAnswer,
  }) : super(key: key);

  final Question question;
  final void Function() onSubmitAnswer;
  final String backgroundImage;

  /// GetX: put the controller so it lives for this screen
  final SpeakController speakController = Get.put(SpeakController());

  void _submitAnswer(BuildContext context) {
    onSubmitAnswer();
  }

  @override
  Widget build(BuildContext context) {
    // For demonstration, let's trigger fetch from backend
    // when this screen first builds
    speakController.fetchDataFromBackend();

    print("SpeakScreen: ${question.options}");
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
            SizedBox(height: MediaQuery.of(context).padding.top - 25),

            // Large Circle Contact Avatar
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                        .withOpacity(0.1), // Simulated soft light background
                    border: Border.all(color: Colors.white30, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/astronaut/thinking.png'),
                      fit: BoxFit.cover,
                    )),
                child: backgroundImage.isEmpty
                    ? const Icon(Icons.person, size: 60, color: Colors.white70)
                    : null,
              ),
            ),
            const SpeechBubbleMessage(
              message:
                  "Hi there! I'm Lumi, your space buddy. Let's review what you just learned!",
            ),

            const Spacer(),

            // Wrap each TermMasteryItem in an Obx so it rebuilds when the Rx changes
            Obx(() => TermMasteryItem(
                  term: 'Black Holes',
                  progress: speakController.blackHoleProgress.value,
                )),
            Obx(() => TermMasteryItem(
                  term: 'Event Horizon',
                  progress: speakController.eventHorizonProgress.value,
                )),
            Obx(() => TermMasteryItem(
                  term: 'Gravitational Waves',
                  progress: speakController.gravitationalWavesProgress.value,
                )),

            const SizedBox(height: 16),

            Center(
              child: RecordButton(
                onStartRecording: speakController.startRecording,
                onStopRecording: speakController.stopRecording,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordButton extends StatefulWidget {
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  const RecordButton({
    Key? key,
    required this.onStartRecording,
    required this.onStopRecording,
  }) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool isRecording = false;

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
    });

    if (isRecording) {
      widget.onStartRecording();
    } else {
      widget.onStopRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleRecording,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRecording
                ? Colors.redAccent.withOpacity(0.5)
                : Colors.white.withOpacity(0.9),
          ),
          child: Icon(
            isRecording ? Icons.mic_off : Icons.mic_outlined,
            color: isRecording ? Colors.white : Colors.black87,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(isRecording ? "Tap to stop" : "Tap to record",
            style: const TextStyle(
              color: Color.fromARGB(129, 255, 255, 255),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
      ]),
    );
  }
}

class TermMasteryItem extends StatelessWidget {
  final String term;
  final double progress;

  const TermMasteryItem({
    Key? key,
    required this.term,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMastered = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMastered
              ? const Color.fromARGB(99, 255, 217, 0)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
            child: Icon(
              isMastered ? Icons.star_border : Icons.psychology,
              color: isMastered
                  ? const Color.fromARGB(255, 181, 154, 0)
                  : Colors.white70,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Term + Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      term,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: isMastered
                            ? const Color(0x33FFD700)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isMastered ? Icons.check : null,
                            size: isMastered ? 16 : 0,
                            color: isMastered
                                ? const Color.fromARGB(255, 181, 154, 0)
                                : Colors.transparent,
                          ),
                          if (isMastered) const SizedBox(width: 4),
                          Text(
                            isMastered
                                ? 'Mastered'
                                : '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              color: isMastered
                                  ? const Color(0xFFFFD700)
                                  : const Color.fromARGB(129, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 5,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, animatedProgress, child) {
                        return LinearProgressIndicator(
                          value: animatedProgress,
                          backgroundColor:
                              const Color.fromARGB(113, 158, 158, 158),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isMastered
                                ? const Color.fromARGB(255, 225, 191, 0)
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpeechBubbleMessage extends StatelessWidget {
  final String message;

  const SpeechBubbleMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
