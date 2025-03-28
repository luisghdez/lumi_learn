import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/speach_bubble.dart';
import 'package:lumi_learn_app/widgets/app_scaffold.dart';

class FillInBlankScreen extends StatelessWidget {
  final Question question;
  final ValueNotifier<int> _selectedOption = ValueNotifier<int>(-1);

  FillInBlankScreen({
    Key? key,
    required this.question,
  }) : super(key: key);

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
    return AppScaffold(
      body: Column(
        children: [
          // Fixed-size header container
          Container(
            height: 200,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: greyBorder,
                  width: 1,
                ),
              ),
            ),
            child: Stack(
              children: [
                // Speech Bubble
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 220,
                    child: SpeechBubble(text: question.questionText),
                  ),
                ),
                // Astronaut Image
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Image.asset(
                    'assets/astronaut/thinking.png',
                    width: 170,
                    height: 140,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Options Bubbles
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ValueListenableBuilder<int>(
                  valueListenable: _selectedOption,
                  builder: (context, selected, _) {
                    return Wrap(
                      spacing: 4.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: List.generate(question.options.length, (index) {
                        final option = question.options[index];
                        final isSelected = selected == index;
                        return GestureDetector(
                          onTap: () => _selectedOption.value = index,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : greyBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
          // Wrap the NextButton with ValueListenableBuilder
          ValueListenableBuilder<int>(
            valueListenable: _selectedOption,
            builder: (context, selected, _) {
              return NextButton(
                onPressed: selected != -1 ? () => _submitAnswer(context) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
