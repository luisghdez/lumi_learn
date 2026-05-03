import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

/// Galaxy image + drifting / twinkling stars that parallax with horizontal scroll.
/// Sits under [CourseLessonMapPainter]; keep map gradient slightly transparent at top
/// so this reads through near the status bar.
class CourseMapSkyBackground extends StatefulWidget {
  const CourseMapSkyBackground({
    super.key,
    required this.scrollController,
    required this.width,
    required this.height,
  });

  final ScrollController scrollController;
  final double width;
  final double height;

  @override
  State<CourseMapSkyBackground> createState() => _CourseMapSkyBackgroundState();
}

class _CourseMapSkyBackgroundState extends State<CourseMapSkyBackground>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;

  void _onScroll() {
    if (mounted) setState(() {});
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    setState(() => _elapsed = elapsed);
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant CourseMapSkyBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollX = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : 0.0;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DeepSpaceBackdropPainter(),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0.34,
                child: Image.asset(
                  'assets/images/milky_way.png',
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  alignment: Alignment(
                    (-0.88 + (scrollX * 0.00012).clamp(-0.35, 0.35))
                        .clamp(-1.0, 1.0),
                    -0.15,
                  ),
                ),
              ),
            ),
            CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _StargazingStarfieldPainter(
                width: widget.width,
                height: widget.height,
                scrollX: scrollX,
                elapsedSec: _elapsed.inMicroseconds / 1e6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mostly black with very soft colored airglow — stargazing night base.
class _DeepSpaceBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment(-0.85, -1),
        end: Alignment(0.9, 1.05),
        colors: [
          Color(0xFF030208),
          Color(0xFF05040c),
          Color(0xFF020306),
          Color(0xFF040810),
        ],
        stops: [0.0, 0.35, 0.72, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, base);

    final orbs = <({Offset c, double r, List<Color> colors})>[
      (
        c: Offset(w * 0.12, h * 0.18),
        r: w * 0.42,
        colors: [
          const Color(0xFF4c2f8f).withValues(alpha: 0.22),
          Colors.transparent,
        ],
      ),
      (
        c: Offset(w * 0.82, h * 0.22),
        r: w * 0.38,
        colors: [
          const Color(0xFF0d5c6e).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ),
      (
        c: Offset(w * 0.55, h * 0.08),
        r: w * 0.55,
        colors: [
          const Color(0xFF2a1a48).withValues(alpha: 0.14),
          Colors.transparent,
        ],
      ),
      (
        c: Offset(w * 0.35, h * 0.88),
        r: h * 0.45,
        colors: [
          const Color(0xFF1a4a6e).withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ),
      (
        c: Offset(w * 0.92, h * 0.65),
        r: w * 0.35,
        colors: [
          const Color(0xFF5c3b20).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ),
    ];

    final orbPaint = Paint()..style = PaintingStyle.fill;
    for (final o in orbs) {
      orbPaint.shader = RadialGradient(
        colors: o.colors,
      ).createShader(Rect.fromCircle(center: o.c, radius: o.r));
      canvas.drawCircle(o.c, o.r, orbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StargazingStarfieldPainter extends CustomPainter {
  _StargazingStarfieldPainter({
    required this.width,
    required this.height,
    required this.scrollX,
    required this.elapsedSec,
  });

  final double width;
  final double height;
  final double scrollX;
  final double elapsedSec;

  static Color _starTint(int i) {
    final t = _hash01(i * 91 + 17);
    if (t < 0.62) return Colors.white;
    if (t < 0.72) return const Color(0xFFd4e9ff); // cool blue-white
    if (t < 0.8) return const Color(0xFFfff4d6); // warm candle
    if (t < 0.88) return const Color(0xFFe8d4ff); // soft violet
    if (t < 0.94) return const Color(0xFFc8fff0); // mint star
    return const Color(0xFFffd6e8); // rose
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final area = w * h;
    final count = (area / 900).round().clamp(380, 980);

    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final u = _hash01(i * 13 + 7);
      final v = _hash01(i * 29 + 3);
      final depth = 0.12 + _hash01(i * 5) * 0.88;
      final parallax = 0.06 + depth * 0.28;
      var x = u * w - scrollX * parallax;
      x = x % w;
      if (x < 0) x += w;

      final drift = sin(elapsedSec * 0.28 + i * 0.27) * 2.2 * depth;
      final y = (v * h + drift).clamp(0.0, h);

      final phase = i * 0.71 + depth * 11;
      final twinkleSpeed = 1.6 + depth * 2.8 + _hash01(i * 41) * 1.4;
      final twinkle = 0.38 +
          0.62 *
              (0.5 + 0.5 * sin(elapsedSec * twinkleSpeed + phase));

      final tier = _hash01(i * 47);
      final tint = _starTint(i);

      if (tier < 0.52) {
        // Fine dust — many tiny silvery points
        final r = 0.18 + _hash01(i * 19) * 0.45;
        final a = (0.06 + depth * 0.22) * twinkle;
        paint.color = Colors.white.withValues(alpha: (a * 0.85).clamp(0.03, 0.55));
        canvas.drawCircle(Offset(x, y), r, paint);
      } else if (tier < 0.9) {
        // Mid field — brighter white / pastel jewels
        final r = 0.45 + _hash01(i * 23) * 1.05;
        final a = (0.18 + depth * 0.45) * twinkle;
        paint.color = tint.withValues(alpha: a.clamp(0.08, 0.92));
        canvas.drawCircle(Offset(x, y), r, paint);
      } else {
        // Bright “dream” stars — soft bloom + hot core
        final r = 1.05 + _hash01(i * 31) * 1.65;
        final aCore = (0.55 + 0.45 * twinkle).clamp(0.35, 1.0);
        final cx = Offset(x, y);

        canvas.save();
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        paint.color = tint.withValues(alpha: 0.28 * twinkle);
        canvas.drawCircle(cx, r * 2.4, paint);
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
        paint.color = Colors.white.withValues(alpha: 0.42 * twinkle);
        canvas.drawCircle(cx, r * 1.35, paint);
        paint.maskFilter = null;
        paint.color = Colors.white.withValues(alpha: aCore);
        canvas.drawCircle(cx, r * 0.55, paint);
        canvas.restore();
      }
    }
  }

  static double _hash01(int n) {
    var x = n * 1103515245 + 12345;
    x &= 0x7fffffff;
    return x / 0x7fffffff;
  }

  @override
  bool shouldRepaint(covariant _StargazingStarfieldPainter oldDelegate) {
    return oldDelegate.scrollX != scrollX ||
        (oldDelegate.elapsedSec - elapsedSec).abs() > 1e-6 ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}
