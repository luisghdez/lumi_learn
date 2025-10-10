import 'dart:math';
import 'package:flutter/material.dart';

class _PiePainter extends CustomPainter {
  final double knownFraction;
  final Color knownColor;
  final Color unknownColor;

  _PiePainter({
    required this.knownFraction,
    required this.knownColor,
    required this.unknownColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 16.0;
    final rect = Offset.zero & size;
    final startAngle = -pi / 2; // start at top
    final knownSweep = 2 * pi * knownFraction;
    final unknownSweep = 2 * pi * (1 - knownFraction);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // draw unknown first (so it shows as the "back")
    paint.color = unknownColor.withOpacity(.7);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle + knownSweep,
      unknownSweep,
      false,
      paint,
    );

    // draw known
    paint.color = knownColor.withOpacity(.7);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      knownSweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.knownFraction != knownFraction;
}

class AnimatedPieChart extends StatefulWidget {
  final double knownFraction;
  final Color knownColor;
  final Color unknownColor;
  final Duration duration;

  const AnimatedPieChart({
    Key? key,
    required this.knownFraction,
    required this.knownColor,
    required this.unknownColor,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.knownFraction != widget.knownFraction) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _PiePainter(
            knownFraction: widget.knownFraction * _animation.value,
            knownColor: widget.knownColor,
            unknownColor: widget.unknownColor,
          ),
        );
      },
    );
  }
} 