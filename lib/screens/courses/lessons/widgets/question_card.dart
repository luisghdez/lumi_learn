import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String questionText;

  const QuestionCard({Key? key, required this.questionText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        questionText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
