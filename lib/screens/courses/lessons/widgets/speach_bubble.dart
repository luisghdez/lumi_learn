import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final Color bubbleColor;
  final TextStyle textStyle;

  const SpeechBubble({
    Key? key,
    required this.text,
    this.bubbleColor = Colors.white,
    // align text in center of bubble
    this.textStyle = const TextStyle(color: Colors.black),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubblePainter(color: bubbleColor),
      child: Container(
        // Extra height on the left to avoid clipping the bubble tail
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Text(
          text,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final Color color;
  _SpeechBubblePainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBubble = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a rounded rectangle for the main bubble
    final bubbleRect = RRect.fromLTRBR(
      10, // left inset (space for the tail)
      0,
      size.width,
      size.height,
      const Radius.circular(12),
    );

    canvas.drawRRect(bubbleRect, paintBubble);

    // Draw a little triangular “tail” on the left side
    final tailPath = Path();
    // near middle-left
    tailPath.moveTo(10, size.height * 0.5 - 8);
    tailPath.lineTo(0, size.height * 0.5);
    tailPath.lineTo(10, size.height * 0.5 + 8);
    tailPath.close();

    canvas.drawPath(tailPath, paintBubble);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
