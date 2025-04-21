import 'package:flutter/material.dart';
import 'package:lumi_learn_app/utils/latex_text.dart';

class QuestionCard extends StatelessWidget {
  final String questionText;
  final bool isTablet;

  const QuestionCard({
    required this.questionText,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = isTablet ? 32.0 : 16.0;
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SmartText(
        questionText,
        style: TextStyle(color: Colors.white, fontSize: isTablet ? 20 : 14),
        align: TextAlign.center,
      ),
    );
  }
}
