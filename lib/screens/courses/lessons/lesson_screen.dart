import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibra_app/screens/courses/lessons/lesson_result_screen.dart';

class LessonScreen extends StatefulWidget {
  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _selectedOption = -1;
  final List<String> _options = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
  ];

  void _submitAnswer() {
    if (_selectedOption != -1) {
      // Handle answer submission logic here
      print('Selected option: ${_options[_selectedOption]}');
    }

    Get.to(() => LessonResultScreen());
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
              'Question goes here',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20.0),
            ..._options.asMap().entries.map((entry) {
              int idx = entry.key;
              String text = entry.value;
              return RadioListTile(
                title: Text(text),
                value: idx,
                groupValue: _selectedOption,
                onChanged: (int? value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
              );
            }).toList(),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
