import 'package:flutter/material.dart';

class InstructionText extends StatelessWidget {
  const InstructionText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          'Align your question within the frame',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
