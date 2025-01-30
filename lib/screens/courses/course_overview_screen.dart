import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vibra_app/screens/courses/lessons/lesson_screen.dart';
import 'package:vibra_app/widgets/starry_app_scaffold.dart';
import 'package:vibra_app/controllers/course_controller.dart';
import 'package:vibra_app/data/assets_data.dart'; // Import the data file

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
  final StarPainter _starPainter = StarPainter(starCount: 200);

  void _onPlanetTap(int index) {
    setState(() {
      _isPanelVisible = true;
      _selectedLessonIndex = index;
    });

    // Set the active planet in the controller
    courseController.setActivePlanet(index);
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
    final totalWidth =
        planets.length * 200.0; // Adjust based on item count and spacing

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
                  ...List.generate(planets.length, (index) {
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
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black26,
                                //     blurRadius: 4,
                                //     offset: Offset(2, 2),
                                //   ),
                                // ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  planets[index]
                                      .imagePath, // Use planet image from assets_data.dart
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "Lesson ${index + 1}",
                              // planets[index].name, // Use planet name from assets_data.dart
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
// Inside the CourseOverviewScreen's build method

// Bottom Panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isPanelVisible ? 0 : -250, // Adjust height as needed
            left: 0,
            right: 0,
            child: Container(
              height: 250, // Height of the panel
              decoration: BoxDecoration(
                color: const Color.fromARGB(119, 0, 0, 0),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Close button
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: IconButton(
                  //     icon: const Icon(Icons.close),
                  //     onPressed: _closePanel,
                  //   ),
                  // ),
                  // Display the active planet image and lesson details
                  Obx(() {
                    final activePlanet = courseController.activePlanet.value;
                    if (activePlanet == null) {
                      return const Center(child: Text('No planet selected'));
                    }

                    return Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              // Planet image
                              ClipOval(
                                child: Image.asset(
                                  activePlanet.imagePath,
                                  width: 160,
                                  // height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Lesson details
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Center vertically
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Lesson ${_selectedLessonIndex != null ? _selectedLessonIndex! + 1 : 'N/A'}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 34,
                                        // fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'In this lesson you will learn about blablabbsbsb',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Start button
                                    SizedBox(
                                      width: double
                                          .infinity, // Make the button take full width
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.to(() => LessonScreen());
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          'Start!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                Color.fromARGB(255, 24, 24, 24),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
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
