import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'category_card.dart';

class CategoryList extends StatelessWidget {
  CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find<CourseController>();
    final random = Random();

    return Obx(() {
      final courses = courseController.courses;
      if (courses.isEmpty) {
        return const Center(child: Text('No courses available.'));
      }
      return Column(
        children: courses.map<Widget>((course) {
          int randomNumber =
              random.nextInt(5) + 1; // Generates a number between 1 and 5
          String randomImagePath = 'assets/galaxies/galaxy$randomNumber.png';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CategoryCard(
              title: course['title'] ?? 'Untitled',
              subtitle: "Galaxy",
              imagePath: randomImagePath,
              onTap: () async {
                // Set the selected course ID in the controller
                courseController.setSelectedCourseId(
                    course['id'], course['title']);
                while (courseController.isLoading.value) {
                  await Future.delayed(const Duration(milliseconds: 100));
                }
                // Navigate to CourseOverviewScreen
                Get.to(
                  () => const CourseOverviewScreen(),
                  transition: Transition.fadeIn, // Fade transition
                  duration: const Duration(
                      milliseconds: 500), // Custom duration (optional)
                );
              },
            ),
          );
        }).toList(),
      );
    });
  }
}
