import 'dart:ui';
import 'package:flutter/material.dart';

class SpeechBubbleBlack extends StatelessWidget {
  final String text;
  final Color bubbleColor;
  final TextStyle textStyle;

  const SpeechBubbleBlack({
    Key? key,
    required this.text,
    this.bubbleColor = const Color.fromARGB(150, 0, 0, 0),
    this.textStyle = const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(
              12), // Clip the blur within the bubble shape
          child: BackdropFilter(
            filter:
                ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Adjust blur intensity
            child: CustomPaint(
              painter: _SpeechBubblePainter(
                  color: bubbleColor.withOpacity(0.5)), // Adjust transparency
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                margin: const EdgeInsets.only(
                    left: 10), // Avoid clipping the bubble tail
                child: Text(
                  text,
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final Color color;

  _SpeechBubblePainter({this.color = const Color.fromARGB(150, 0, 0, 0)});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBubble = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a rounded rectangle for the main bubble
    final bubbleRect = RRect.fromLTRBR(
      10,
      0,
      size.width,
      size.height,
      const Radius.circular(12),
    );

    canvas.drawRRect(bubbleRect, paintBubble);

    // Draw a little triangular “tail” on the left side
    final tailPath = Path();
    tailPath.moveTo(10, size.height * 0.5 - 8);
    tailPath.lineTo(0, size.height * 0.5);
    tailPath.lineTo(10, size.height * 0.5 + 8);
    tailPath.close();

    canvas.drawPath(tailPath, paintBubble);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
