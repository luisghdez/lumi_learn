import 'dart:math';
import 'package:flutter/material.dart';

class RocketAnimation extends StatefulWidget {
  final Offset planetCenter;
  final double planetRadius;
  final bool isActive;

  const RocketAnimation({
    Key? key,
    required this.planetCenter,
    required this.planetRadius,
    required this.isActive,
  }) : super(key: key);

  @override
  _RocketAnimationState createState() => _RocketAnimationState();
}

class _RocketAnimationState extends State<RocketAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  final List<_SmokePuff> _smokePuffs = [];

  // Scaling factor to make everything smaller (0.6 scales 50px -> 30px)
  final double scaleFactor = 0.6;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);

    _controller.addListener(() {
      if (!widget.isActive) return;
      final currentValue = _controller.value;
      // Add a smoke puff roughly every 1/30 of an orbit:
      if (currentValue % (1 / 30) < 0.01) {
        _addSmokePuff();
      }
      _updateSmokePuffs();
    });
  }

  @override
  void didUpdateWidget(covariant RocketAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _smokePuffs.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSmokePuff() {
    final angle = _rotation.value;
    // Adjusted orbit radius: previously (planetRadius + 50), now scaled down.
    final orbitRadius = widget.planetRadius + (50 * scaleFactor);
    final rocketOffset = Offset(
      widget.planetCenter.dx + orbitRadius * cos(angle),
      widget.planetCenter.dy + orbitRadius * sin(angle),
    );
    _smokePuffs.add(_SmokePuff(position: rocketOffset));
  }

  void _updateSmokePuffs() {
    final now = DateTime.now();
    // Remove puffs older than 4 seconds
    _smokePuffs.removeWhere(
        (puff) => now.difference(puff.creationTime).inSeconds >= 4);
  }

  /// Emulates the CSS keyframes for scaling:
  /// 0% → scale(1), 10% → scale(1.5), 60%-100% → scale(0.4)
  double _scaleFor(double t) {
    if (t < 0.1) {
      final fraction = t / 0.1;
      return 1.0 + 0.5 * fraction;
    } else if (t < 0.6) {
      final fraction = (t - 0.1) / 0.5;
      return 1.5 + (0.4 - 1.5) * fraction;
    } else {
      return 0.4;
    }
  }

  /// Emulates the CSS opacity transition:
  /// 0%-10% full opacity, then fading out until 60%
  double _opacityFor(double t) {
    if (t < 0.1) {
      return 1.0;
    } else if (t < 0.6) {
      final fraction = (t - 0.1) / 0.5;
      return 1.0 - fraction;
    } else {
      return 0.0;
    }
  }

  /// Emulates the CSS color transition:
  /// 0% → darken(#3498db, 60%) ~ #1F5173, 10% → #3498db, 60%+ → grey
  Color _colorFor(double t) {
    const darkGrey = Color(0xFF555555);
    const midGrey = Color(0xFFAAAAAA);
    const lightGrey = Color(0xFFDDDDDD);

    if (t < 0.1) {
      final fraction = t / 0.1;
      return Color.lerp(darkGrey, midGrey, fraction)!;
    } else if (t < 0.6) {
      final fraction = (t - 0.1) / 0.5;
      return Color.lerp(midGrey, lightGrey, fraction)!;
    } else {
      return lightGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, _) {
        final angle = _rotation.value;
        // Adjusted orbit radius with scaling applied.
        final orbitRadius = widget.planetRadius + (50 * scaleFactor);
        final rocketX = widget.planetCenter.dx + orbitRadius * cos(angle);
        final rocketY = widget.planetCenter.dy + orbitRadius * sin(angle);

        return Stack(
          children: [
            // Draw all smoke puffs
            CustomPaint(
              painter: _SmokePuffPainter(
                puffs: _smokePuffs,
                scaleFor: _scaleFor,
                opacityFor: _opacityFor,
                colorFor: _colorFor,
                scaleFactor: scaleFactor,
              ),
            ),
            // Rocket positioned with adjusted size and offset (30x30, so half is 15)
            Positioned(
              left: rocketX - (30 / 2),
              top: rocketY - (30 / 2),
              child: Transform.rotate(
                angle:
                    angle + pi / 2, // Rotate so the rocket nose points upward
                child: Image.asset(
                  'assets/astronaut/rocket.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmokePuff {
  final Offset position;
  final DateTime creationTime = DateTime.now();

  _SmokePuff({required this.position});
}

class _SmokePuffPainter extends CustomPainter {
  final List<_SmokePuff> puffs;
  final double Function(double) scaleFor;
  final double Function(double) opacityFor;
  final Color Function(double) colorFor;
  final double scaleFactor;

  _SmokePuffPainter({
    required this.puffs,
    required this.scaleFor,
    required this.opacityFor,
    required this.colorFor,
    required this.scaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final paint = Paint()..style = PaintingStyle.fill;

    for (final puff in puffs) {
      // Age from 0.0 to 1.0 over the lifetime (4 seconds)
      final age = now.difference(puff.creationTime).inMilliseconds / 2500.0;
      if (age > 1.0) continue;

      final scale = scaleFor(age);
      final opacity = opacityFor(age);
      final color = colorFor(age).withOpacity(opacity);
      // Adjusted smoke puff radius (base 7.0 scaled down)
      final radius = 7.0 * scaleFactor * scale;

      paint.color = color;
      canvas.drawCircle(puff.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SmokePuffPainter oldDelegate) {
    // Repaint if the number of puffs changes.
    return oldDelegate.puffs.length != puffs.length;
  }
}
