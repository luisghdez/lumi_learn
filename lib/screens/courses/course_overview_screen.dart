import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/data/assets_data.dart';

import 'package:lumi_learn_app/screens/courses/lessons/lesson_screen_main.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';
import 'package:lumi_learn_app/widgets/bottom_panel.dart';
import 'package:lumi_learn_app/widgets/course_overview_header.dart';
import 'package:lumi_learn_app/widgets/star_painter.dart';
import 'package:lumi_learn_app/widgets/starry_app_scaffold.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/widgets/rocket_animation.dart';

class CourseOverviewScreen extends StatefulWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  _CourseOverviewScreenState createState() => _CourseOverviewScreenState();
}

class _CourseOverviewScreenState extends State<CourseOverviewScreen> {
  final CourseController courseController = Get.find();

  bool _isPanelVisible = false;
  int? _selectedLessonIndex;
  String? _selectedLessonPlanetName;
  String? _lessonDescription;

  // Track which planet to highlight (when user taps a locked planet)
  int? _highlightedPlanetIndex;

  // Key to detect taps outside the panel
  final GlobalKey _panelKey = GlobalKey();
  final StarPainter _starPainter = StarPainter(starCount: 200);

  // Capturing each lesson’s center (for planet positioning)
  final List<Offset> _lessonCenters = [];

  double _glowOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Horizontal wave layout parameters (optional for the “orbit” effect)
    final double amplitude = 180.0;
    final double frequency = pi / 3;

    // Clear & recalculate lesson centers each build
    _lessonCenters.clear();

    return Obx(() {
      final courseId =
          courseController.selectedCourseId; // Get current course ID
      final lessons = courseController.lessons;
      final lessonCount = lessons.length;
      final totalWidth = lessonCount * 200.0; // Space out lessons horizontally

      Planet? previousPlanet;

      // Find the last completed lesson index
      int lastCompletedIndex = -1;
      for (int i = 0; i < lessons.length; i++) {
        if (lessons[i]['completed'] == true) {
          lastCompletedIndex = i;
        }
      }
      // The next lesson is right after the last completed
      int nextLessonIndex = lastCompletedIndex + 1;

      return StarryAppScaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (details) => _handleTapDown(context, details),
          child: Stack(
            children: [
              // 1) Scrollable horizontal region
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  height: screenHeight,
                  child: Stack(
                    children: [
                      // Background stars
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _starPainter,
                        ),
                      ),

                      // 2) Lessons as “Planets”
                      ...List.generate(lessonCount, (index) {
                        final lesson = lessons[index];
                        bool shouldBlur = index > nextLessonIndex;

                        final lessonPlanetName = lesson['planetName'];
                        final lessonTitle =
                            lesson['title'] ?? 'Lesson ${index + 1}';
                        final lessonId = lesson['id']; // Unique lesson ID

                        // Assign a planet image based on the lesson
                        final lessonPlanet = getPlanetForLesson(
                          courseId.value,
                          lessonId,
                          previousPlanet,
                        );
                        previousPlanet = lessonPlanet;

                        // Wave offset for a fun orbit effect
                        final offsetY =
                            amplitude * sin(index * frequency + pi / 2);
                        final planetLeft = index * 200.0;
                        final planetTop = screenHeight / 2 - offsetY - 60;
                        const planetSize = 100.0;

                        // Save the center of each “planet” for the rocket animation
                        final lessonCenter = Offset(
                          planetLeft + planetSize / 2,
                          planetTop + planetSize / 2,
                        );
                        _lessonCenters.add(lessonCenter);

                        const double flagSize = 30.0;

                        return Positioned(
                          left: planetLeft,
                          top: planetTop,
                          child: GestureDetector(
                            onTap: () => _onLessonTap(index, lessonPlanet),
                            child: SizedBox(
                              width: planetSize,
                              // Wrap the entire content in a Stack to allow overlaying
                              // the lock/blur layer and any highlight border.
                              child: Stack(
                                children: [
                                  Column(
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipOval(
                                            child: Image.asset(
                                              lessonPlanet.imagePath,
                                              width: planetSize,
                                              height: planetSize,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          // If the lesson is completed, show a flag.
                                          if (lesson['completed'] == true)
                                            Positioned(
                                              top: lessonPlanet.hasRings
                                                  ? -2
                                                  : -12,
                                              left:
                                                  (planetSize - flagSize) / 2 +
                                                      6,
                                              child: Image.asset(
                                                'assets/astronaut/flag.png',
                                                width: flagSize,
                                                height: flagSize,
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        lessonPlanetName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          height: 0.9,
                                        ),
                                      ),
                                      Text(
                                        lessonTitle,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (shouldBlur)
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: planetSize,
                                        height: planetSize,
                                        child: Stack(
                                          children: [
                                            // The blur overlay
                                            ClipOval(
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 4.0,
                                                  sigmaY: 4.0,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: greyBorder,
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // The lock icon
                                            // 2) Fade lock icon color from gray to white
                                            Center(
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  // Gray lock (base)
                                                  const Icon(
                                                    Icons.lock,
                                                    color: Color.fromARGB(
                                                        255, 158, 158, 158),
                                                    size: 36,
                                                  ),
                                                  // White lock that fades in/out using _glowOpacity
                                                  AnimatedOpacity(
                                                    opacity:
                                                        (_highlightedPlanetIndex ==
                                                                index)
                                                            ? _glowOpacity
                                                            : 0.0,
                                                    duration: const Duration(
                                                        milliseconds: 0),
                                                    child: const Icon(
                                                      Icons.lock,
                                                      color: Colors.white,
                                                      size: 36,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Animated glowing border (fades in then out)
                                            if (_highlightedPlanetIndex ==
                                                index)
                                              AnimatedOpacity(
                                                opacity: _glowOpacity,
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.white
                                                            .withOpacity(0.3),
                                                        blurRadius: 12,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // 3) Rocket Animation
                      Positioned.fill(
                        child: _selectedLessonIndex == null
                            ? const SizedBox()
                            : RocketAnimation(
                                planetCenter:
                                    _lessonCenters[_selectedLessonIndex!],
                                planetRadius: 20.0,
                                isActive: _isPanelVisible,
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4) Bottom Panel
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _isPanelVisible ? 0 : -250,
                left: 0,
                right: 0,
                child: BottomPanel(
                  key: _panelKey,
                  selectedLessonIndex: _selectedLessonIndex,
                  selectedLessonPlanetName: _selectedLessonPlanetName,
                  selectedLessonDescription: _lessonDescription,
                  onStartPressed: () {
                    courseController.loadQuestions();
                    Get.to(() => LessonScreenMain());
                    _closePanel();
                  },
                  onClose: _closePanel,
                ),
              ),

              // 5) Top Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CourseOverviewHeader(
                  onBack: () => Get.offAll(
                    () => const MainScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 500),
                  ),
                  courseTitle: "${courseController.selectedCourseTitle}",
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Planet getPlanetForLesson(
    String courseId,
    String lessonId, [
    Planet? previousPlanet,
  ]) {
    // Combine course ID and lesson ID for a unique hash.
    String combinedId = courseId + lessonId;
    var bytes = utf8.encode(combinedId);
    var hash = md5.convert(bytes).toString();

    // Convert part of the hash to a number.
    int numericHash = int.parse(hash.substring(0, 6), radix: 16);
    int planetIndex = numericHash % planets.length;
    Planet chosenPlanet = planets[planetIndex];

    // If the chosen planet is the same as the previous one, pick the next planet.
    if (previousPlanet != null &&
        chosenPlanet.imagePath == previousPlanet.imagePath) {
      planetIndex = (planetIndex + 1) % planets.length;
      chosenPlanet = planets[planetIndex];
    }
    return chosenPlanet;
  }

  // **Handling Lesson Taps**
  void _onLessonTap(int index, Planet planet) {
    final lessons = courseController.lessons;

    // Find the last completed lesson index
    int lastCompletedIndex = -1;
    for (int i = 0; i < lessons.length; i++) {
      if (lessons[i]['completed'] == true) {
        lastCompletedIndex = i;
      }
    }
    final nextLessonIndex = lastCompletedIndex + 1;

    // If the planet is locked, animate a fade in/out glow
    if (index > nextLessonIndex) {
      setState(() {
        _highlightedPlanetIndex = index;
        _glowOpacity = 1.0; // Start with fully visible glow (fade in)
      });
      // After 300ms, fade out the glow
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _highlightedPlanetIndex == index) {
          setState(() {
            _glowOpacity = 0.0;
          });
        }
      });
      // Finally, clear the highlight after the full animation
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && _highlightedPlanetIndex == index) {
          setState(() {
            _highlightedPlanetIndex = null;
          });
        }
      });
      return;
    }

    // For unlocked planets, if the same planet is tapped while the panel is visible, ignore
    if (_selectedLessonIndex == index && _isPanelVisible) {
      return;
    }

    // Otherwise, close any open panel first
    setState(() {
      _isPanelVisible = false;
      _highlightedPlanetIndex = null; // Clear any previous highlight
    });

    // Delay to animate rocket away before re-opening with new data
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _selectedLessonIndex = index;
        _selectedLessonPlanetName = lessons[index]['planetName'];
        _lessonDescription = lessons[index]['planetDescription'];
        _isPanelVisible = true;
      });
      courseController.setActiveLessonIndex(index);
      courseController.setActivePlanet(planet);
    });
  }

  // **Close the bottom panel when tapping outside, also remove highlight**
  void _handleTapDown(BuildContext context, TapDownDetails details) {
    setState(() {
      _highlightedPlanetIndex = null;
    });

    if (!_isPanelVisible) return;
    final tapPosition = details.globalPosition;
    if (_panelKey.currentContext != null) {
      final renderBox =
          _panelKey.currentContext!.findRenderObject() as RenderBox;
      final panelOffset = renderBox.localToGlobal(Offset.zero);
      final panelSize = renderBox.size;
      final panelRect = Rect.fromLTWH(
        panelOffset.dx,
        panelOffset.dy,
        panelSize.width,
        panelSize.height,
      );
      if (!panelRect.contains(tapPosition)) {
        _closePanel();
      }
    }
  }

  // **Hides the panel & rocket animation**
  void _closePanel() {
    setState(() {
      _isPanelVisible = false;
      _highlightedPlanetIndex = null;
    });
  }
}
