import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/audio_widget.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/speach_bubble_black.dart';

class SpeakScreen extends StatelessWidget {
  final Question question;
  final void Function() onSubmitAnswer;
  final ValueNotifier<int> _selectedOption = ValueNotifier<int>(-1);
  final String backgroundImage;

  SpeakScreen({
    required this.question,
    required this.backgroundImage,
    required this.onSubmitAnswer,
  });

  void _submitAnswer(BuildContext context) {
    onSubmitAnswer();
  }

  @override
  Widget build(BuildContext context) {
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
            const TermMasteryItem(term: 'Black Holes', progress: 0.45),
            const TermMasteryItem(term: 'Event Horizon', progress: 0.2),
            const TermMasteryItem(term: 'Gravitational Waves', progress: 0.75),
            const SizedBox(height: 16),
            Center(
              child: RecordButton(
                onStartRecording: () {
                  // TODO: Handle recording logic start here
                  print("Recording started");
                },
                onStopRecording: () {
                  // TODO: Handle recording stop logic here
                  print("Recording stopped");
                },
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
  final double progress; // e.g., 0.45 for 45%

  const TermMasteryItem({
    Key? key,
    required this.term,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Brain Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
            child: const Icon(
              Icons.psychology, // Brain-like icon
              color: Colors.white70,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Term name & progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color.fromARGB(89, 255, 255, 255),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 5,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, animatedProgress, child) {
                        return LinearProgressIndicator(
                          value: animatedProgress,
                          backgroundColor:
                              const Color.fromARGB(113, 158, 158, 158),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color.fromARGB(255, 255, 255, 255),
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
