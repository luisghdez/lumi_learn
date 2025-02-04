import 'dart:math';

import 'package:flutter/material.dart';

class StarPainter extends CustomPainter {
  final int starCount;
  final List<Offset> starOffsets;
  final List<double> starSizes;
  final Random _random = Random();

  StarPainter({this.starCount = 100})
      : starOffsets = List.generate(
          starCount,
          (_) => Offset(
            Random().nextDouble(),
            Random().nextDouble(),
          ),
        ),
        starSizes = List.generate(
          starCount,
          (_) => Random().nextDouble(),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);

    for (int i = 0; i < starCount; i++) {
      final dx = starOffsets[i].dx * size.width;
      final dy = starOffsets[i].dy * size.height;
      final radius = starSizes[i];
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
