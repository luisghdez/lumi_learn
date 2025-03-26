import 'package:flutter/material.dart';
import 'dart:math';

class XPChartBox extends StatelessWidget {
  const XPChartBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: CustomPaint(
        painter: _XPChartPainter(),
        child: Container(),
      ),
    );
  }
}

class _XPChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    final paintLine1 = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintLine2 = Paint()
      ..color = const Color(0xFFB388FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dashPaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1;

    const days = ['M', 'T', 'W', 'T', 'F'];

    final double chartHeight = size.height - 30;
    final double chartWidth = size.width;

    // Draw grid lines
    for (int i = 0; i <= 5; i++) {
      double y = chartHeight * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), paintGrid);
    }

    // Fake data points
    final line1Points = [20, 35, 60, 30, 55]; // grey
    final line2Points = [10, 40, 65, 50, 55]; // purple

    Path path1 = Path();
    Path path2 = Path();

    for (int i = 0; i < line1Points.length; i++) {
      double x = (chartWidth / (line1Points.length - 1)) * i;
      double y1 = chartHeight - (line1Points[i] / 100) * chartHeight;
      double y2 = chartHeight - (line2Points[i] / 100) * chartHeight;

      if (i == 0) {
        path1.moveTo(x, y1);
        path2.moveTo(x, y2);
      } else {
        path1.lineTo(x, y1);
        path2.lineTo(x, y2);
      }
    }

    canvas.drawPath(path1, paintLine1);
    canvas.drawPath(path2, paintLine2);

    // Draw white dot at W (index 2)
    final double dotX = (chartWidth / 4) * 2;
    final double dotY = chartHeight - (line2Points[2] / 100) * chartHeight;
    canvas.drawCircle(Offset(dotX, dotY), 4, dotPaint);

    // Draw dashed vertical line at W
    const dashHeight = 5;
    double dashY = 0;
    while (dashY < chartHeight) {
      canvas.drawLine(
        Offset(dotX, dashY),
        Offset(dotX, dashY + dashHeight),
        dashPaint,
      );
      dashY += 8;
    }

    // Draw bottom labels
    final textStyle = TextStyle(color: Colors.white54, fontSize: 12);
    final textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    for (int i = 0; i < days.length; i++) {
      final x = (chartWidth / (days.length - 1)) * i;
      textPainter.text = TextSpan(text: days[i], style: textStyle);
      textPainter.layout(minWidth: 0, maxWidth: 20);
      textPainter.paint(
          canvas, Offset(x - textPainter.width / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
