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
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // -----------------------------
          // TOP SECTION (Astronaut + Bubble)
          // -----------------------------
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(255, 12, 12, 12),
                        ],
                      ),
                    ),
                  ),
                ),
                // Astronaut
                Positioned(
                  bottom: -15,
                  left: 5,
                  child: Image.asset(
                    'assets/astronaut/standing.png',
                    width: 100,
                  ),
                ),
                // Speech bubble near the astronaut
                Positioned(
                  bottom: 100,
                  left: 100,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: SpeechBubbleBlack(
                      text: question.questionText,
                      bubbleColor: const Color.fromARGB(150, 0, 0, 0),
                      textStyle: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AudioWidget(),
          // -----------------------------
          // BOTTOM SECTION  (Next)
          // -----------------------------
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NextButton(
                    onPressed: () => _submitAnswer(context),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // “I can’t speak right now” action
                      },
                      child: const Text(
                        'I cant speak right now',
                        style: TextStyle(
                          color: Color.fromARGB(255, 193, 193, 193),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
