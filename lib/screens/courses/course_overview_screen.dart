import 'dart:math'; // Import for sine function
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibra_app/screens/courses/lessons/lesson_screen.dart';
import 'package:vibra_app/widgets/starry_app_scaffold.dart';

class CourseOverviewScreen extends StatelessWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parameters for the wave effect
    final double amplitude = 180.0; // Height of the wave
    final double frequency = pi / 3; // Controls the number of waves

    return StarryAppScaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: Container(
            // expand the height of the container to fill the screen

            height: MediaQuery.of(context).size.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(20, (index) {
                // Calculate the vertical offset using a sine wave
                double offsetY = -amplitude * sin(index * frequency + pi / 2);

                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => LessonScreen());
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50.0), // Add spacing between items
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Circle container for better visual
                          Container(
                            decoration: BoxDecoration(
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
                                width: 100.0, // Set the width of the image
                                height:
                                    100.0, // Ensure height matches width for a circle
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          // Optional: Add a label or number below the circle
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
        ),
      ),
    );
  }
}
