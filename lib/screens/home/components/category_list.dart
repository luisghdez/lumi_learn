import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'category_card.dart';

class CategoryList extends StatelessWidget {
  final Function(String) onCategoryTap;

  const CategoryList({
    Key? key,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();
    final random = Random(); // Create a random generator instance

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
              imagePath:
                  randomImagePath, // Use the randomly selected image path
              onTap: () => onCategoryTap(course['id'] ?? ''),
            ),
          );
        }).toList(),
      );
    });
  }
}
