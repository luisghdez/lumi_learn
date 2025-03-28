import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'category_card.dart';
import 'package:crypto/crypto.dart';

class CategoryList extends StatelessWidget {
  CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find<CourseController>();

    return Obx(() {
      final courses = courseController.courses;
      if (courses.isEmpty) {
        return const SizedBox(
          height: 200,
        );
      }

      // Sort the courses so that any course with loading == true is first.
      final sortedCourses = List.from(courses);
      sortedCourses.sort((a, b) {
        if (a['loading'] == true && b['loading'] != true) return -1;
        if (a['loading'] != true && b['loading'] == true) return 1;
        return 0;
      });

      return Column(
        children: sortedCourses.map<Widget>((course) {
          // Use the course id to determine the galaxy image.
          String galaxyImagePath = getGalaxyForCourse(course['id']);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Stack(
              children: [
                CategoryCard(
                  title: course['title'] ?? 'Untitled',
                  subtitle: "Galaxy",
                  imagePath: galaxyImagePath,
                  onTap: () async {
                    // Prevent navigation if the course is still loading.
                    if (course['loading'] == true) return;
                    // Set the selected course ID in the controller.
                    courseController.setSelectedCourseId(
                        course['id'], course['title']);

                    Get.to(
                      () => LoadingScreen(),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 500),
                    );
                    await Future.wait([
                      Future.delayed(const Duration(milliseconds: 1000)),
                      precacheImage(
                        const AssetImage('assets/images/milky_way.png'),
                        context,
                      ),
                    ]);

                    while (courseController.isLoading.value) {
                      await Future.delayed(const Duration(milliseconds: 100));
                    }
                    // Navigate to CourseOverviewScreen.
                    Get.offAll(
                      () => const CourseOverviewScreen(),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                ),
                if (course['loading'] == true)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: FractionallySizedBox(
                          heightFactor: 0.9,
                          child: Image.asset(
                            'assets/astronaut/minute.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }
}

String getGalaxyForCourse(String courseId) {
  // Convert the course ID to a hash.
  final bytes = utf8.encode(courseId);
  final hash = md5.convert(bytes).toString();

  // Use the first 6 characters of the hash to create a numeric value.
  final numericHash = int.parse(hash.substring(0, 6), radix: 16);

  // Pick an index based on the number of images (5 in this case).
  // We add 1 because our images are named galaxy1.png to galaxy5.png.
  final galaxyIndex = (numericHash % 5) + 1;
  return 'assets/galaxies/galaxy$galaxyIndex.png';
}
