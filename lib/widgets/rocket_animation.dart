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
    with TickerProviderStateMixin {
  // Controller for orbit (rotation) - used primarily to trigger rebuilds each frame
  late AnimationController _orbitController;
  late Animation<double> _rotation;

  // Controller for scaling rocket in/out
  late AnimationController _scaleController;
  late Animation<double> _rocketScale;

  final List<_SmokePuff> _smokePuffs = [];

  // Scale factor for orbit radius
  final double orbitScaleFactor = 0.6;

  @override
  void initState() {
    super.initState();

    // ---- ORBIT CONTROLLER ----
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(_orbitController);

    // We only do .repeat() below if rocket is actually visible at start
    // or once scale is done growing in.

    // ---- SCALE CONTROLLER ----
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rocketScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // If the widget is initially active, show rocket at full scale & orbit
    if (widget.isActive) {
      _scaleController.value = 1.0;
      _orbitController.repeat();
    }

    // Once rocket is fully shrunk, *don't* clear puffs — let them fade
    // But do stop the orbit (no reason to keep rotating an invisible rocket).
    _scaleController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        // Rocket scale=0 => not visible
        // _orbitController.stop();
        // NOTE: We don't clear puffs so they can keep fading out
      } else if (status == AnimationStatus.completed) {
        // Rocket scale=1 => fully visible
        if (!_orbitController.isAnimating && widget.isActive) {
          _orbitController.repeat();
        }
      }
    });

    // Each orbit tick triggers new frames
    _orbitController.addListener(() {
      // We always call setState so that smoke puffs will fade with time
      setState(() {
        // If rocket is scaled out or not active, skip creating new puffs
        if (widget.isActive && _rocketScale.value > 0) {
          _maybeCreateSmokePuff();
        }
        _updateSmokePuffs();
      });
    });
  }

  @override
  void didUpdateWidget(covariant RocketAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If we just became active => scale in
    if (widget.isActive && !oldWidget.isActive) {
      _scaleController.forward();
    }
    // If we just became inactive => scale out
    else if (!widget.isActive && oldWidget.isActive) {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Generate a smoke puff occasionally
  void _maybeCreateSmokePuff() {
    final currentValue = _orbitController.value;
    // Add a puff every ~1/40 of a rotation
    if (currentValue % (1 / 40) < 0.01) {
      final angle = _rotation.value;
      final orbitRadius = widget.planetRadius + (50 * orbitScaleFactor);
      final rocketOffset = Offset(
        widget.planetCenter.dx + orbitRadius * cos(angle),
        widget.planetCenter.dy + orbitRadius * sin(angle),
      );
      _smokePuffs.add(_SmokePuff(position: rocketOffset));
    }
  }

  /// Remove puffs older than 4s (or 2.5s — up to you),
  /// so the user sees them fade out.
  void _updateSmokePuffs() {
    final now = DateTime.now();
    _smokePuffs.removeWhere(
      (puff) => now.difference(puff.creationTime).inSeconds >= 4,
    );
  }

  // SMOKE ANIMATIONS (unchanged from your original)
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
    return AnimatedBuilder(
      animation: Listenable.merge([_orbitController, _scaleController]),
      builder: (context, child) {
        final angle = _rotation.value;
        final rocketScale = _rocketScale.value;
        final orbitRadius = widget.planetRadius + 50 * orbitScaleFactor;

        // If rocket is scaled out AND no more puffs, we can hide everything
        if (rocketScale == 0.0 && _smokePuffs.isEmpty) {
          return const SizedBox.shrink();
        }

        // Calculate rocket position in the orbit
        final rocketX = widget.planetCenter.dx + orbitRadius * cos(angle);
        final rocketY = widget.planetCenter.dy + orbitRadius * sin(angle);

        return Stack(
          children: [
            // SMOKE LAYER
            CustomPaint(
              painter: _SmokePuffPainter(
                puffs: _smokePuffs,
                scaleFor: _scaleFor,
                opacityFor: _opacityFor,
                colorFor: _colorFor,
                scaleFactor: orbitScaleFactor,
              ),
            ),
            // ROCKET (scaled 0..1)
            Positioned(
              left: rocketX - 15, // half of 30
              top: rocketY - 15,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(angle + pi / 2) // point rocket "outward"
                  ..scale(rocketScale),
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

// Your original smoke puff model
class _SmokePuff {
  final Offset position;
  final DateTime creationTime = DateTime.now();

  _SmokePuff({required this.position});
}

// Same painter as before, using scaleFor() & opacityFor() to animate
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
      final age = now.difference(puff.creationTime).inMilliseconds / 2500.0;
      if (age > 1.0) continue; // puff fully faded

      final s = scaleFor(age);
      final opacity = opacityFor(age);
      final color = colorFor(age).withOpacity(opacity);
      final radius = 7.0 * scaleFactor * s;

      paint.color = color;
      canvas.drawCircle(puff.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SmokePuffPainter oldDelegate) {
    return oldDelegate.puffs.length != puffs.length;
  }
}
