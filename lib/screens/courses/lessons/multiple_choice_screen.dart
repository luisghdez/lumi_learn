import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/options_list.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/question_card.dart';

class MultipleChoiceScreen extends StatelessWidget {
  final Question question;
  final String backgroundImage;

  final ValueNotifier<int> _selectedOption = ValueNotifier<int>(-1);

  MultipleChoiceScreen({
    required this.question,
    required this.backgroundImage,
  });

  void _submitAnswer(BuildContext context) {
    if (_selectedOption.value != -1) {
      final selectedAnswer = question.options[_selectedOption.value];
      final controller = Get.find<CourseController>();

      controller.submitAnswerForQuestion(
        question: question,
        selectedAnswer: selectedAnswer,
        context: context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option before submitting'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // Top section: background, gradient, question card, astronaut
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
                // Question card
                Positioned(
                  left: 16,
                  top: MediaQuery.of(context).padding.top + 60,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: QuestionCard(questionText: question.questionText),
                  ),
                ),
                // Astronaut image
                Positioned(
                  bottom: 0,
                  right: 1,
                  child: Image.asset(
                    'assets/astronaut/pointing.png',
                    width: 140,
                  ),
                ),
              ],
            ),
          ),
          // Bottom section: options and next button
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 12, 12, 12),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: OptionsList(
                      options: question.options,
                      selectedOption: _selectedOption,
                    ),
                  ),
                  // Wrap the NextButton with a ValueListenableBuilder
                  ValueListenableBuilder<int>(
                    valueListenable: _selectedOption,
                    builder: (context, value, child) {
                      return NextButton(
                        onPressed:
                            value != -1 ? () => _submitAnswer(context) : null,
                      );
                    },
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
