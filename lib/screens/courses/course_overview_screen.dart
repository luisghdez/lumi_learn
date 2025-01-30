import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vibra_app/screens/courses/lessons/lesson_screen.dart';
import 'package:vibra_app/widgets/starry_app_scaffold.dart';
import 'package:vibra_app/controllers/course_controller.dart';

class CourseOverviewScreen extends StatefulWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  _CourseOverviewScreenState createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  final CourseController courseController = Get.put(CourseController());
  bool _isPanelVisible = false;
  int? _selectedLessonIndex;

  // Initialize StarPainter once
  final StarPainter _starPainter = StarPainter(starCount: 500);

  void _onPlanetTap(int index) {
    setState(() {
      _isPanelVisible = true;
      _selectedLessonIndex = index;
    });
  }

  void _closePanel() {
    setState(() {
      _isPanelVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double amplitude = 180.0;
    final double frequency = pi / 3;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final totalWidth = 20 * 200.0; // Adjust based on item count and spacing

    return StarryAppScaffold(
      body: Stack(
        children: [
          // Horizontally scrollable content (stars and planets)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              height: screenHeight,
              child: Stack(
                children: [
                  // Starry background (inside the scrollable area)
                  Positioned.fill(
                    child: CustomPaint(
                      painter:
                          _starPainter, // Use the pre-initialized StarPainter
                    ),
                  ),
                  // Planets
                  ...List.generate(20, (index) {
                    final offsetY = amplitude * sin(index * frequency + pi / 2);
                    final xPosition = index * 200.0; // Horizontal spacing

                    return Positioned(
                      left: xPosition,
                      top: screenHeight / 2 -
                          offsetY -
                          60, // Centered vertically
                      child: GestureDetector(
                        onTap: () {
                          _onPlanetTap(index);
                          courseController.setSelectedLesson(index);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                            Text(
                              'Lesson ${index + 1}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Bottom Panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isPanelVisible ? 0 : -200, // Adjust height as needed
            left: 0,
            right: 0,
            child: Container(
              height: 200, // Height of the panel
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _closePanel,
                    ),
                  ),
                  // Display selected lesson number
                  Center(
                    child: Text(
                      'Selected Lesson: ${_selectedLessonIndex != null ? _selectedLessonIndex! + 1 : 'None'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Add more content here if needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// StarPainter remains unchanged
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
