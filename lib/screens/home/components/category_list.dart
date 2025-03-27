import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
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
        return const Center(child: Text('No courses available.'));
      }
      return Column(
        children: courses.map<Widget>((course) {
          // Use the course id to determine the galaxy image.
          String galaxyImagePath = getGalaxyForCourse(course['id']);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CategoryCard(
              title: course['title'] ?? 'Untitled',
              subtitle: "Galaxy",
              imagePath: galaxyImagePath,
              onTap: () async {
                // Set the selected course ID in the controller.
                courseController.setSelectedCourseId(
                    course['id'], course['title']);
                while (courseController.isLoading.value) {
                  await Future.delayed(const Duration(milliseconds: 100));
                }
                // Navigate to CourseOverviewScreen.
                Get.to(
                  () => const CourseOverviewScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 500),
                );
              },
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
