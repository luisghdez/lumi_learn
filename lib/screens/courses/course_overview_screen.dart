import 'dart:math'; // For sine & pi
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibra_app/screens/courses/lessons/lesson_screen.dart';
import 'package:vibra_app/widgets/starry_app_scaffold.dart';

class CourseOverviewScreen extends StatelessWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wave parameters
    final double amplitude = 180.0; // Height of the wave
    final double frequency = pi / 3; // Controls the wave frequency
    final screenHeight = MediaQuery.of(context).size.height;

    return StarryAppScaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            // Make it wide enough so we can scroll through all lessons
            // width: totalWidth,
            height: screenHeight,

            child: Stack(
              children: [
                // 1) Starry background (fills entire Container)
                Positioned.fill(
                  child: CustomPaint(
                    painter: StarPainter(starCount: 500),
                  ),
                ),

                // 2) The row with wave-translated planets on top
                Center(
                  // Center the row vertically
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(20, (index) {
                      // Calculate the vertical offset using a sine wave
                      final offsetY =
                          -amplitude * sin(index * frequency + pi / 2);

                      return Transform.translate(
                        offset: Offset(0, offsetY),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => LessonScreen());
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Planet circle
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/planets/red1.png',
                                      width: 100.0,
                                      height: 100.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                // Label
                                Text(
                                  'Lesson ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final int starCount;
  final List<Offset> starOffsets;
  final List<double> starSizes;
  final Random _random = Random();

  StarPainter({this.starCount = 100})
      : starOffsets = List.generate(
          starCount,
          (_) => Offset(
            // Normalized 0..1, will multiply by size in paint()
            Random().nextDouble(),
            Random().nextDouble(),
          ),
        ),
        starSizes = List.generate(
          starCount,
          (_) => Random().nextDouble(), // + 1 star radius
        );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);

    // Draw each star
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
