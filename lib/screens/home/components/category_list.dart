import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:crypto/crypto.dart';
import 'category_card.dart';

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

      // 1. Sort to ensure 'loading' courses come first.
      final sortedCourses = List<Map<String, dynamic>>.from(courses);
      sortedCourses.sort((a, b) {
        if (a['loading'] == true && b['loading'] != true) return -1;
        if (a['loading'] != true && b['loading'] == true) return 1;
        return 0;
      });

      // 2. Filter by search query
      final query = courseController.searchQuery.value.toLowerCase();
      final filteredCourses = sortedCourses.where((course) {
        final title = (course['title'] ?? '').toString().toLowerCase();
        return title.contains(query);
      }).toList();

      return Column(
        children: filteredCourses.map<Widget>((course) {
          final galaxyImagePath = getGalaxyForCourse(course['id']);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Stack(
              children: [
                CategoryCard(
                  title: course['title'] ?? 'Untitled',
                  completedLessons: course['completedLessons'] ?? 0,
                  totalLessons: course['totalLessons'] ?? 0,
                  imagePath: galaxyImagePath,
                  onTap: () async {
                    // Prevent navigation if still loading
                    if (course['loading'] == true) return;

                    courseController.setSelectedCourseId(
                      course['id'],
                      course['title'],
                    );

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

                    // Navigate to CourseOverviewScreen
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

// This helper is unchanged – it just picks a galaxy image based on a hash of the courseId.
String getGalaxyForCourse(String courseId) {
  final bytes = utf8.encode(courseId);
  final hash = md5.convert(bytes).toString();
  final numericHash = int.parse(hash.substring(0, 6), radix: 16);
  final galaxyIndex = (numericHash % 18) + 1; // 1-10 for 10 images
  return 'assets/galaxies/galaxy$galaxyIndex.png';
}
