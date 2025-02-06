import 'package:flutter/material.dart';
import 'package:lumi_learn_app/models/question.dart';

class MultipleChoiceScreen extends StatelessWidget {
  final Question question;
  final void Function() onSubmitAnswer;
  final ValueNotifier<int> _selectedOption = ValueNotifier<int>(-1);

  MultipleChoiceScreen({
    required this.question,
    required this.onSubmitAnswer,
  });

  void _submitAnswer(BuildContext context) {
    if (_selectedOption.value != -1) {
      print('Selected option: ${question.options[_selectedOption.value]}');
      onSubmitAnswer();
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top section: background, gradient, question card, astronaut
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: Stack(
                children: [
                  // 1) Background image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/bg/red1bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 2) Gradient overlay
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

                  // 3) Question card, pinned to the left side
                  Positioned(
                    left: 16,
                    top: 60, // Adjust as needed
                    child: Container(
                      width:
                          MediaQuery.of(context).size.width * 0.70, // Optional
                      child: _buildQuestionCard(),
                    ),
                  ),

                  // 4) Astronaut image, bigger, at bottom right
                  Positioned(
                    bottom: 0,
                    right: 16,
                    child: Image.asset(
                      'assets/astronaut/pointing.png',
                      width: 120, // Make astronaut bigger
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _buildOptionsList()),
                    _buildSubmitButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Question card widget
  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        question.questionText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Options list
  Widget _buildOptionsList() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedOption,
      builder: (context, selected, _) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 16.0),
          itemCount: question.options.length,
          itemBuilder: (context, index) {
            final optionText = question.options[index];
            final isSelected = selected == index;
            return GestureDetector(
              onTap: () => _selectedOption.value = index,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(122, 0, 0, 0),
                  borderRadius: BorderRadius.circular(36.0),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white,
                          width: 1,
                        )
                      : Border.all(
                          color: const Color.fromARGB(81, 158, 158, 158),
                        ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          isSelected ? Colors.white : const Color(0xFF4A4A4A),
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, ...
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optionText,
                        style: const TextStyle(
                          color: Color.fromARGB(221, 244, 244, 244),
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Submit button
  Widget _buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _submitAnswer(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Next Question',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
