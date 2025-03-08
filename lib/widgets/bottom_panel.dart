import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'dart:ui'; // For ImageFilter

class BottomPanel extends StatelessWidget {
  final int? selectedLessonIndex;
  final String? selectedLessonPlanetName;
  final String? selectedLessonDescription;
  final VoidCallback onStartPressed;
  final VoidCallback onClose;

  const BottomPanel({
    Key? key,
    required this.selectedLessonIndex,
    required this.selectedLessonPlanetName,
    required this.selectedLessonDescription,
    required this.onStartPressed,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find<CourseController>();
    final activePlanet = courseController.activePlanet.value;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(140, 0, 0, 0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: activePlanet == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No planet selected',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                )
              : Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // Large planet image, partially off-screen on bottom-left, with 50% opacity
                    Positioned(
                      left: -150,
                      bottom: -130,
                      child: Opacity(
                        opacity: 0.7,
                        child: Image.asset(
                          activePlanet.imagePath,
                          width: 400,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Foreground: text & button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.8, // 70% of the available width
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                selectedLessonPlanetName ?? '',
                                style: const TextStyle(
                                  fontSize: 34,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Text(
                                selectedLessonDescription ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 213, 213, 213),
                                ),
                              ),
                              const SizedBox(height: 16),
                              FractionallySizedBox(
                                widthFactor: 0.7,
                                child: ElevatedButton(
                                  onPressed: onStartPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    'Start!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 24, 24, 24),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
