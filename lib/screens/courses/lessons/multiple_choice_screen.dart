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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double horizontalPadding = isTablet ? 48.0 : 16.0;
    final double maxContentWidth = isTablet ? 800.0 : double.infinity;
    final double astronautSize = isTablet ? 250 : 140;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          // Top section: background, gradient, question card, astronaut
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
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
                child: Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Question card
                          Flexible(
                            flex: 3,
                            child: QuestionCard(
                              questionText: question.questionText,
                              isTablet: isTablet,
                            ),
                          ),

                          Align(
                            alignment: Alignment.bottomRight,
                            child: Image.asset(
                              'assets/astronaut/pointing.png',
                              width: astronautSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom section: options and next button
          Expanded(
            child: Container(
              color: const Color.fromARGB(255, 12, 12, 12),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: OptionsList(
                          options: question.options,
                          selectedOption: _selectedOption,
                          isTablet: isTablet,
                        ),
                      ),
                      ValueListenableBuilder<int>(
                        valueListenable: _selectedOption,
                        builder: (context, value, child) {
                          return NextButton(
                            onPressed: value != -1
                                ? () => _submitAnswer(context)
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
