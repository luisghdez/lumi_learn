// rocket_animation.dart
import 'dart:math';
import 'package:flutter/material.dart';

class RocketAnimation extends StatefulWidget {
  /// The center of the selected planet, in the local coordinates
  /// of the scrollable Stack where it will be rendered.
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
    )..repeat(); // continuously spin

    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);

    _controller.addListener(() {
      if (!widget.isActive) return;

      // (Optional) Spawn new puffs every so often
      if (_controller.value % 0.03 < 0.01) {
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
    // "Orbit" radius from planet center
    final orbitRadius = widget.planetRadius + 50;

    // Get rocket’s center
    final rocketOffset = Offset(
      widget.planetCenter.dx + orbitRadius * cos(angle),
      widget.planetCenter.dy + orbitRadius * sin(angle),
    );

    _smokePuffs.add(
      _SmokePuff(
        position: rocketOffset,
        opacity: 1.0,
      ),
    );
  }

  void _updateSmokePuffs() {
    for (var puff in _smokePuffs) {
      puff.opacity -= 0.02;
    }
    _smokePuffs.removeWhere((p) => p.opacity <= 0);
  }

  @override
  Widget build(BuildContext context) {
    // If not active, hide
    if (!widget.isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        final angle = _rotation.value;
        final orbitRadius = widget.planetRadius + 50;
        final rocketX = widget.planetCenter.dx + orbitRadius * cos(angle);
        final rocketY = widget.planetCenter.dy + orbitRadius * sin(angle);

        return Stack(
          children: [
            // Smoke puffs
            for (var puff in _smokePuffs)
              Positioned(
                left: puff.position.dx,
                top: puff.position.dy,
                child: Opacity(
                  opacity: puff.opacity,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

            // The rocket
            Positioned(
              left: rocketX - 25, // half rocket width if rocket is 50x50
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
  Offset position;
  double opacity;
  _SmokePuff({required this.position, required this.opacity});
}
