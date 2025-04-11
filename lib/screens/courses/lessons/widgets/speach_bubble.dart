import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final Color bubbleColor;
  final TextStyle? textStyle;
  final bool isTablet;

  const SpeechBubble({
    Key? key,
    required this.text,
    this.bubbleColor = Colors.white,
    this.textStyle,
    this.isTablet = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fontSize = isTablet ? 20.0 : 14.0;
    final double horizontalPadding = isTablet ? 24.0 : 16.0;
    final double verticalPadding = isTablet ? 20.0 : 16.0;

    return CustomPaint(
      painter: _SpeechBubblePainter(color: bubbleColor),
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Text(
          text,
          style: textStyle ??
              TextStyle(
                color: Colors.black,
                fontSize: fontSize,
              ),
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

    final bubbleRect = RRect.fromLTRBR(
      10,
      0,
      size.width,
      size.height,
      const Radius.circular(12),
    );

    canvas.drawRRect(bubbleRect, paintBubble);

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
