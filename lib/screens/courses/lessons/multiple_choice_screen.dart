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
    print('Selected option: ${question.options[_selectedOption.value]}');
    onSubmitAnswer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiple Choice Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.questionText,
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            ValueListenableBuilder<int>(
              valueListenable: _selectedOption,
              builder: (context, selected, _) {
                return Column(
                  children: question.options.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String text = entry.value;
                    return RadioListTile(
                      title: Text(text),
                      value: idx,
                      groupValue: selected,
                      onChanged: (int? value) {
                        if (value != null) {
                          _selectedOption.value = value;
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _submitAnswer(context),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
