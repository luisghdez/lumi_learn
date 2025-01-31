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

  /// Each puff stores:
  ///  - position: where it spawned
  ///  - birthTime: in 0..1, when it was spawned within the controller cycle
  final List<_SmokePuff> _smokePuffs = [];

  @override
  void initState() {
    super.initState();
    // The controller goes from 0..1 in 4 seconds, repeating infinitely.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // continuously spin

    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);

    _controller.addListener(() {
      // Only spawn smoke if the rocket is active
      if (!widget.isActive) return;

      final currentValue = _controller.value; // 0..1

      // Condition to spawn new puff, e.g. every ~0.03 of the cycle
      // This is just a trick: (value % 0.03 < 0.01) means roughly every 3% of the cycle
      if (currentValue % 0.03 < 0.01) {
        _addSmokePuff(currentValue);
      }

      _updateSmokePuffs(currentValue);
    });
  }

  @override
  void didUpdateWidget(covariant RocketAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start or stop the animation if isActive changed
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

  /// Spawns a new puff at the rocket's position
  void _addSmokePuff(double currentValue) {
    // Calculate rocket's position (where we place the puff)
    final angle = _rotation.value;
    final orbitRadius = widget.planetRadius + 50;
    final rocketOffset = Offset(
      widget.planetCenter.dx + orbitRadius * cos(angle),
      widget.planetCenter.dy + orbitRadius * sin(angle),
    );

    _smokePuffs.add(_SmokePuff(
      position: rocketOffset,
      birthTime: currentValue, // 0..1
    ));
  }

  /// Remove puffs older than 1 cycle, otherwise animate them
  void _updateSmokePuffs(double currentValue) {
    _smokePuffs.removeWhere((puff) {
      var localT = currentValue - puff.birthTime;
      // if negative, wrap around
      if (localT < 0) localT += 1.0;
      return localT > 1.0; // if older than 1 cycle, remove
    });
  }

  /// Our keyframe logic for each puff, given 0..1 localT
  /// (similar to your SASS: 0%->10%->60%->100%)
  double _scaleFor(double t) {
    // 0..0.1 => scale 1..1.5
    if (t < 0.1) {
      final ratio = t / 0.1; // 0..1
      return 1.0 + 0.5 * ratio; // 1..1.5
    }
    // 0.1..1 => scale 1.5..0.4
    final ratio = (t - 0.1) / 0.9; // 0..1
    return 1.5 - 1.1 * ratio; // 1.5->0.4
  }

  double _opacityFor(double t) {
    // 0..0.6 => opacity = 1
    if (t < 0.6) {
      return 1.0;
    }
    // 0.6..1 => fade out to 0
    final ratio = (t - 0.6) / 0.4; // 0..1
    return 1.0 - ratio; // 1->0
  }

  /// If you want color transitions:
  /// (like startColor=darkBlue => midColor=lightBlue => endColor=grey)
  Color _colorFor(double t) {
    // For simplicity, here's a 2-step approach:
    // 0..0.1 => darkBlue->lightBlue
    // 0.1..1 => lightBlue->grey
    const startColor = Color.fromARGB(255, 138, 138, 138); // dark-ish blue
    const midColor = Color.fromARGB(255, 210, 210, 210); // your #3498db
    const endColor = Color.fromARGB(44, 158, 158, 158);

    if (t < 0.1) {
      final ratio = t / 0.1;
      return Color.lerp(startColor, midColor, ratio) ?? startColor;
    } else {
      final ratio = (t - 0.1) / 0.9;
      return Color.lerp(midColor, endColor, ratio) ?? endColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        // Calculate rocket position
        final angle = _rotation.value;
        final orbitRadius = widget.planetRadius + 50;
        final rocketX = widget.planetCenter.dx + orbitRadius * cos(angle);
        final rocketY = widget.planetCenter.dy + orbitRadius * sin(angle);

        return Stack(
          children: [
            // 1) All the puffs so far
            for (var puff in _smokePuffs) _buildSmokePuff(puff),

            // 2) The rocket itself
            Positioned(
              left: rocketX - 25,
              top: rocketY - 25,
              child: Transform.rotate(
                angle: angle + pi / 2, // keep rocket horizontally oriented
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

  Widget _buildSmokePuff(_SmokePuff puff) {
    // localT = how far along from birthTime..(birthTime+1) in 0..1
    double localT = _controller.value - puff.birthTime;
    if (localT < 0) localT += 1.0; // handle wrap

    final s = _scaleFor(localT);
    final a = _opacityFor(localT);
    final c = _colorFor(localT);
    final size = 14.0; // base puff size

    return Positioned(
      left: puff.position.dx - (size / 2),
      top: puff.position.dy - (size / 2),
      child: Transform.scale(
        scale: s,
        child: Opacity(
          opacity: a,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmokePuff {
  final Offset position;
  final double birthTime; // in 0..1
  _SmokePuff({required this.position, required this.birthTime});
}
