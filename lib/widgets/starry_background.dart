import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum ShootingStarDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
  topLeftToBottomRight,
  topRightToBottomLeft,
  bottomLeftToTopRight,
  bottomRightToTopLeft,
}

class GalaxyBackground extends StatefulWidget {
  const GalaxyBackground({Key? key}) : super(key: key);

  @override
  _GalaxyBackgroundState createState() => _GalaxyBackgroundState();
}

class _GalaxyBackgroundState extends State<GalaxyBackground>
    with SingleTickerProviderStateMixin {
  final List<ShootingStar> shootingStars = [];
  final Random random = Random();
  late Ticker _ticker;
  Duration _lastTick = Duration.zero;
  Timer? _shootingStarTimer;

  @override
  void initState() {
    super.initState();
    _ticker = this.createTicker(_onTick)..start();
    _startShootingStars();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shootingStarTimer?.cancel();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final deltaTime = (elapsed - _lastTick).inMilliseconds / 1000.0;
    _lastTick = elapsed;

    setState(() {
      for (var star in List<ShootingStar>.from(shootingStars)) {
        star.position += star.velocity * deltaTime;
        star.opacity -= 0.005;

        if (star.opacity <= 0 ||
            star.position.dx < -100 ||
            star.position.dx > MediaQuery.of(context).size.width + 100 ||
            star.position.dy < -100 ||
            star.position.dy > MediaQuery.of(context).size.height + 100) {
          shootingStars.remove(star);
        }
      }
    });
  }

  void _startShootingStars() {
    _scheduleNextShootingStar();
  }

  void _scheduleNextShootingStar() {
    final nextInterval = Duration(milliseconds: 2000 + random.nextInt(10000));
    _shootingStarTimer = Timer(nextInterval, () {
      const numberOfStars = 1; // Spawn 1 star
      for (int i = 0; i < numberOfStars; i++) {
        _addShootingStar();
      }
      _scheduleNextShootingStar(); // Schedule the next shooting star(s)
    });
  }

  void _addShootingStar() {
    final screenSize = MediaQuery.of(context).size;
    final direction = ShootingStarDirection
        .values[random.nextInt(ShootingStarDirection.values.length)];

    Offset startPosition;
    Offset velocity;
    double size;
    double trailLength;
    Color color;

    switch (direction) {
      case ShootingStarDirection.leftToRight:
        startPosition =
            Offset(-50, random.nextDouble() * screenSize.height * 0.5);
        velocity = Offset(
            random.nextDouble() * 200 + 300, random.nextDouble() * 100 + 150);
        break;
      case ShootingStarDirection.rightToLeft:
        startPosition = Offset(screenSize.width + 50,
            random.nextDouble() * screenSize.height * 0.5);
        velocity = Offset(-(random.nextDouble() * 200 + 300),
            random.nextDouble() * 100 + 150);
        break;
      case ShootingStarDirection.topToBottom:
        startPosition = Offset(random.nextDouble() * screenSize.width, -50);
        velocity = Offset(
            random.nextDouble() * 100 + 150, random.nextDouble() * 200 + 300);
        break;
      case ShootingStarDirection.bottomToTop:
        startPosition = Offset(
            random.nextDouble() * screenSize.width, screenSize.height + 50);
        velocity = Offset(random.nextDouble() * 100 + 150,
            -(random.nextDouble() * 200 + 300));
        break;
      case ShootingStarDirection.topLeftToBottomRight:
        startPosition = Offset(-50, -50);
        velocity = Offset(
            random.nextDouble() * 200 + 300, random.nextDouble() * 200 + 300);
        break;
      case ShootingStarDirection.topRightToBottomLeft:
        startPosition = Offset(screenSize.width + 50, -50);
        velocity = Offset(-(random.nextDouble() * 200 + 300),
            random.nextDouble() * 200 + 300);
        break;
      case ShootingStarDirection.bottomLeftToTopRight:
        startPosition = Offset(-50, screenSize.height + 50);
        velocity = Offset(random.nextDouble() * 200 + 300,
            -(random.nextDouble() * 200 + 300));
        break;
      case ShootingStarDirection.bottomRightToTopLeft:
        startPosition = Offset(screenSize.width + 50, screenSize.height + 50);
        velocity = Offset(-(random.nextDouble() * 200 + 300),
            -(random.nextDouble() * 200 + 300));
        break;
    }

    size = 3.0 + random.nextDouble() * 2.0; // Size between 3.0 and 5.0
    trailLength =
        100.0 + random.nextDouble() * 50.0; // Trail length between 100 and 150

    // Optional: Randomize colors
    List<Color> possibleColors = [
      Colors.white,
      // Colors.blueAccent,
      // Colors.yellowAccent,
      // Colors.orangeAccent,
      // Colors.purpleAccent,
    ];
    color = possibleColors[random.nextInt(possibleColors.length)];

    final shootingStar = ShootingStar(
      position: startPosition,
      velocity: velocity,
      opacity: 1.0,
      size: size,
      trailLength: trailLength,
      color: color,
    );

    setState(() {
      shootingStars.add(shootingStar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Milky Way Background Image (Rendered First)
        Positioned.fill(
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              'assets/images/milky_way.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Custom Painted Shooting Stars (Rendered on Top)
        Positioned.fill(
          child: CustomPaint(
            painter: _GalaxyPainter(
              shootingStars: shootingStars,
            ),
          ),
        ),
      ],
    );
  }
}

class ShootingStar {
  Offset position;
  Offset velocity; // Pixels per second
  double opacity;
  double size;
  double trailLength;
  Color color;

  ShootingStar({
    required this.position,
    required this.velocity,
    required this.opacity,
    required this.size,
    required this.trailLength,
    required this.color,
  });
}

class _GalaxyPainter extends CustomPainter {
  final List<ShootingStar> shootingStars;

  _GalaxyPainter({
    required this.shootingStars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in shootingStars) {
      // Draw the trail with a gradient
      final trailPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.center,
          end: Alignment(
            -star.velocity.dx.sign,
            -star.velocity.dy.sign,
          ),
          colors: [
            star.color.withOpacity(star.opacity),
            star.color.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromPoints(
            star.position,
            star.position -
                (star.velocity / star.velocity.distance) * star.trailLength,
          ),
        )
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        star.position,
        star.position -
            (star.velocity / star.velocity.distance) * star.trailLength,
        trailPaint,
      );

      // Draw the glowing core using a radial gradient
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            star.color.withOpacity(star.opacity),
            star.color.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromCircle(center: star.position, radius: star.size),
        )
        ..blendMode = BlendMode.srcOver;

      canvas.drawCircle(star.position, star.size, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) {
    return true; // Always repaint to reflect changes
  }
}
