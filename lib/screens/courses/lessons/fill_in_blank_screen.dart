import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/models/question.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/next_button.dart';
import 'package:lumi_learn_app/screens/courses/lessons/widgets/speach_bubble.dart';
import 'package:lumi_learn_app/widgets/app_scaffold.dart';

class FillInBlankScreen extends StatefulWidget {
  final Question question;
  final Function() onSubmitAnswer;

  const FillInBlankScreen({
    Key? key,
    required this.question,
    required this.onSubmitAnswer,
  }) : super(key: key);

  @override
  _FillInBlankScreenState createState() => _FillInBlankScreenState();
}

class _FillInBlankScreenState extends State<FillInBlankScreen> {
  final ValueNotifier<int> _selectedOption = ValueNotifier<int>(-1);

  void _selectOption(int index) {
    setState(() {
      _selectedOption.value = index;
    });
  }

  void _submitAnswer(BuildContext context) {
    if (_selectedOption.value != -1) {
      print(
          'Selected option: ${widget.question.options[_selectedOption.value]}');
      widget.onSubmitAnswer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer.'),
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
            height: 200, // Fixed height for consistency
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: greyBorder, // Change to your preferred color
                  width: 1, // Adjust thickness as needed
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
                    child: SpeechBubble(text: widget.question.questionText),
                  ),
                ),

                // Astronaut Image
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Image.asset(
                    'assets/astronaut/thinking.png', // Ensure correct path
                    width: 150,
                    height: 140,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Options Bubbles
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children:
                    List.generate(widget.question.options.length, (index) {
                  final option = widget.question.options[index];
                  final isSelected = _selectedOption.value == index;

                  return GestureDetector(
                    onTap: () => _selectOption(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 30),
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
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          NextButton(
            onPressed: () => _submitAnswer(context),
          ),
        ],
      ),
    );
  }
}
