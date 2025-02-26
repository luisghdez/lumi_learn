import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/audio_widget.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/options_list.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/speach_bubble_black.dart';

class SpeakScreen extends StatelessWidget {
  final Question question;
  final void Function() onSubmitAnswer;
  final ValueNotifier<int> _selectedOption = ValueNotifier<int>(-1);

  SpeakScreen({
    required this.question,
    required this.onSubmitAnswer,
  });

  void _submitAnswer(BuildContext context) {
    onSubmitAnswer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),
      body: SafeArea(
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
                      'assets/bg/red1bg.png',
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
                    bottom: 0,
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

            // -----------------------------
            // SPEAK ROW (Waveform + Mic)
            // -----------------------------
            // Container(
            //   // Just an example height; adjust to fit your layout
            //   height: 80,
            //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   decoration: BoxDecoration(
            //     color: Colors.black,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     children: [
            //       // Waveform placeholder – you can replace this
            //       // with your actual audio visualization widget
            //       Expanded(
            //         child: Container(
            //           // Center a mock waveform icon or animation
            //           alignment: Alignment.centerLeft,
            //           child: Text(
            //             'Audio Waveform',
            //             style: TextStyle(color: Colors.white54),
            //           ),
            //         ),
            //       ),
            //       // Microphone Icon Button
            //       IconButton(
            //         icon: const Icon(Icons.mic, color: Colors.white, size: 32),
            //         onPressed: () {
            //           // TODO: handle microphone tap
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            AudioWidget(),
            // -----------------------------
            // BOTTOM SECTION (Options + Next)
            // -----------------------------
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // If you want to show multiple-choice options
                    // you can keep the OptionsList. Otherwise remove it.
                    Expanded(
                      child: OptionsList(
                        options: question.options,
                        selectedOption: _selectedOption,
                      ),
                    ),
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
      ),
    );
  }
}
