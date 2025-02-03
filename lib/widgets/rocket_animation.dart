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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);

    _controller.addListener(() {
      if (!widget.isActive) return;

      final currentValue = _controller.value;
      if (currentValue % 0.03 < 0.01) {
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
    final orbitRadius = widget.planetRadius + 50;
    final rocketOffset = Offset(
      widget.planetCenter.dx + orbitRadius * cos(angle),
      widget.planetCenter.dy + orbitRadius * sin(angle),
    );
    _smokePuffs.add(_SmokePuff(position: rocketOffset));
  }

  void _updateSmokePuffs() {
    final now = DateTime.now();
    _smokePuffs.removeWhere(
        (puff) => now.difference(puff.creationTime).inSeconds >= 4);
  }

  double _scaleFor(double t) {
    if (t < 0.1) return 1.0 + 0.5 * (t / 0.1);
    return 1.5 - 1.1 * ((t - 0.1) / 0.9);
  }

  double _opacityFor(double t) {
    return t < 0.6 ? 1.0 : 1.0 - ((t - 0.6) / 0.4);
  }

  Color _colorFor(double t) {
    const startColor = Color(0xFF8A8A8A);
    const midColor = Color(0xFFD2D2D2);
    const endColor = Color(0x669E9E9E);
    return t < 0.1
        ? Color.lerp(startColor, midColor, t / 0.1)!
        : Color.lerp(midColor, endColor, (t - 0.1) / 0.9)!;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, _) {
        final angle = _rotation.value;
        final orbitRadius = widget.planetRadius + 50;
        final rocketX = widget.planetCenter.dx + orbitRadius * cos(angle);
        final rocketY = widget.planetCenter.dy + orbitRadius * sin(angle);

        return Stack(
          children: [
            CustomPaint(
              painter: _SmokePuffPainter(
                puffs: _smokePuffs,
                scaleFor: _scaleFor,
                opacityFor: _opacityFor,
                colorFor: _colorFor,
              ),
            ),
            Positioned(
              left: rocketX - 25,
              top: rocketY - 25,
              child: Transform.rotate(
                angle: angle + pi / 2,
                child: Image.asset(
                  'assets/astronaut/rocket.png',
                  width: 50,
                  height: 50,
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

  _SmokePuffPainter({
    required this.puffs,
    required this.scaleFor,
    required this.opacityFor,
    required this.colorFor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final paint = Paint()..style = PaintingStyle.fill;

    for (final puff in puffs) {
      final age = now.difference(puff.creationTime).inMilliseconds / 4000.0;
      if (age > 1.0) continue;

      final scale = scaleFor(age);
      final opacity = opacityFor(age);
      final color = colorFor(age).withOpacity(opacity);
      final radius = 7.0 * scale;

      paint.color = color;
      canvas.drawCircle(puff.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SmokePuffPainter oldDelegate) {
    return oldDelegate.puffs.length != puffs.length;
  }
}
