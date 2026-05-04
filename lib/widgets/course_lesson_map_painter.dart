import 'dart:math';

import 'package:flutter/material.dart';

import 'package:lumi_learn_app/widgets/course_lesson_map_layout.dart';

Rect _boundsForPoints(List<Offset> pts) {
  if (pts.isEmpty) return Rect.zero;
  var minX = pts.first.dx;
  var maxX = pts.first.dx;
  var minY = pts.first.dy;
  var maxY = pts.first.dy;
  for (final p in pts) {
    minX = min(minX, p.dx);
    maxX = max(maxX, p.dx);
    minY = min(minY, p.dy);
    maxY = max(maxY, p.dy);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

/// Scrolls with the lesson row: deep space gradient, soft nebula tied to each
/// planet, a dim “full route”, and a bright path for the unlocked / current leg.
class CourseLessonMapPainter extends CustomPainter {
  CourseLessonMapPainter({
    required this.lessonCount,
    required this.screenHeight,
    required this.nextLessonIndex,
    this.minPlanetTop = 0,
  });

  final int lessonCount;
  final double screenHeight;
  /// First index not yet completed; path is highlighted through this node.
  final int nextLessonIndex;
  /// Keeps route / nodes aligned with [CourseLessonMapLayout] when pushed down.
  final double minPlanetTop;

  static Path _smoothRoute(List<Offset> points) {
    if (points.isEmpty) return Path();
    if (points.length == 1) {
      return Path()..addOval(Rect.fromCircle(center: points.first, radius: 2));
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      final len = max(1e-6, sqrt(dx * dx + dy * dy));
      final nx = -dy / len;
      final ny = dx / len;
      final bend = 48.0 * (i.isEven ? 1 : -1);
      final c = mid + Offset(nx * bend, ny * bend);
      path.quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
    }
    return path;
  }

  List<Offset> _centers(int count, double h) {
    return List.generate(
      count,
      (i) => CourseLessonMapLayout.planetCenter(
            i,
            h,
            minPlanetTop: minPlanetTop,
          ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final rect = Offset.zero & size;

    // --- Neutral dark veil (lets stargazing / galaxy show through — avoid
    //    saturated teal & blue washes that hid the starfield). ---
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF020203).withValues(alpha: 0.38),
          const Color(0xFF050508).withValues(alpha: 0.52),
          const Color(0xFF030305).withValues(alpha: 0.58),
          const Color(0xFF06060a).withValues(alpha: 0.62),
        ],
        stops: const [0.0, 0.22, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, base);

    // --- Hint of warm dust (very low alpha, not green/teal) ---
    final dust = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-0.85, 0.1),
        end: Alignment(0.75, 0.65),
        colors: [
          const Color(0xFF2a2435).withValues(alpha: 0.07),
          const Color(0xFF18141c).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, dust);

    // --- Bottom read legibility only (neutral, no cyan “horizon”) ---
    final floorDim = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF010102).withValues(alpha: 0.45),
        ],
        stops: const [0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, floorDim);

    if (lessonCount == 0) return;

    final centers = _centers(lessonCount, screenHeight);
    final fullPath = _smoothRoute(centers);

    // --- Soft “terrain” glow under each node (follows planet Y) ---
    for (var i = 0; i < centers.length; i++) {
      final c = centers[i];
      final unlocked = i <= nextLessonIndex;
      final r = CourseLessonMapLayout.planetSize * 1.35;
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            (unlocked
                    ? const Color(0xFFc8d8ec)
                    : const Color(0xFF4a5058))
                .withValues(alpha: unlocked ? 0.22 : 0.1),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, glowPaint);
    }

    // --- Constellation specks (deterministic from index) ---
    final speck = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < lessonCount; i++) {
      final cx = CourseLessonMapLayout.planetLeftX(i) +
          CourseLessonMapLayout.planetSize / 2;
      final cy = CourseLessonMapLayout.planetTopY(
            i,
            screenHeight,
            minPlanetTop: minPlanetTop,
          ) +
          CourseLessonMapLayout.planetSize / 2;
      for (var k = 0; k < 8; k++) {
        final t = (i * 17 + k * 13) % 1000 / 1000.0;
        final angle = t * pi * 2;
        final dist = 55 + (i * 11 + k * 7) % 45;
        final px = cx + cos(angle) * dist;
        final py = cy + sin(angle) * dist * 0.85;
        if (px < 0 || px > w || py < 0 || py > h) continue;
        final a = 0.08 + (k % 3) * 0.06;
        speck.color = Colors.white.withValues(alpha: a);
        canvas.drawCircle(Offset(px, py), 1.1 + (k % 2) * 0.6, speck);
      }
    }

    // --- Full route (locked / future tone) ---
    canvas.drawPath(
      fullPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      fullPath,
      Paint()
        ..color = const Color(0xFF2a3555).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // --- Unlocked leg of the journey ---
    final litEnd = min(nextLessonIndex, lessonCount - 1);
    if (litEnd >= 0) {
      final litPoints = centers.sublist(0, litEnd + 1);
      if (litPoints.length >= 2) {
        final litPath = _smoothRoute(litPoints);
        canvas.save();
        canvas.drawPath(
          litPath,
          Paint()
            ..color = const Color(0xFFe8ecf5).withValues(alpha: 0.28)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 14
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        canvas.restore();

        final litBounds = _boundsForPoints(litPoints).inflate(24);
        final routePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = const LinearGradient(
            colors: [
              Color(0xFFf0d4a8),
              Color(0xFFd8dce8),
              Color(0xFFd4c6e8),
            ],
            stops: [0.0, 0.55, 1.0],
          ).createShader(litBounds);
        canvas.drawPath(litPath, routePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CourseLessonMapPainter oldDelegate) {
    return oldDelegate.lessonCount != lessonCount ||
        oldDelegate.screenHeight != screenHeight ||
        oldDelegate.nextLessonIndex != nextLessonIndex ||
        oldDelegate.minPlanetTop != minPlanetTop;
  }
}
