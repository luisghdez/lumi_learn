import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/speach_bubble.dart';
import 'package:lumi_learn_app/utils/latex_text.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double horizontalPadding = isTablet ? 48.0 : 16.0;
    final double fontSize = isTablet ? 20.0 : 16.0;
    final double optionVerticalPadding = isTablet ? 20.0 : 14.0;
    final double optionHorizontalPadding = isTablet ? 36.0 : 16.0;
    final double astronautSize = isTablet ? 270.0 : 170.0;
    final double astronautHeight = isTablet ? 200.0 : 140.0;
    final double bubbleWidth = isTablet ? 380.0 : 220.0;

    return AppScaffold(
      body: Column(
        children: [
          // Header section
          Container(
            height: isTablet ? 300 : 200,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: greyBorder,
                  width: 1,
                ),
              ),
            ),
            child: isTablet
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset(
                          'assets/astronaut/thinking.png',
                          width: astronautSize,
                          height: astronautHeight,
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: SpeechBubble(
                              text: question.questionText,
                              isTablet: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Image.asset(
                          'assets/astronaut/thinking.png',
                          width: astronautSize,
                          height: astronautHeight,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: bubbleWidth,
                          child: SpeechBubble(
                            text: question.questionText,
                            isTablet: false,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 30),

          // Options section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedOption,
                builder: (context, selected, _) {
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 12.0,
                    alignment: WrapAlignment.center,
                    children: List.generate(question.options.length, (index) {
                      final option = question.options[index];
                      final isSelected = selected == index;

                      return GestureDetector(
                        onTap: () => _selectedOption.value = index,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: optionVerticalPadding,
                            horizontal: optionHorizontalPadding,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? Colors.white : greyBorder,
                              width: 1,
                            ),
                          ),
                          child: SmartText(
                            option,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                            align: TextAlign.start, // or center, as needed
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Next button
          ValueListenableBuilder<int>(
            valueListenable: _selectedOption,
            builder: (context, selected, _) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isTablet ? 24.0 : 16.0,
                ),
                child: NextButton(
                  onPressed:
                      selected != -1 ? () => _submitAnswer(context) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
