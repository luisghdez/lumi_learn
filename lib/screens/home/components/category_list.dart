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
    return Obx(() {
      final courses = courseController.courses;
      if (courses.isEmpty) {
        return const Center(child: Text('No courses available.'));
      }
      return Column(
        children: courses.map<Widget>((course) {
          final courseId = course['id'] ?? '';
          // Use the course id's hash code to get a value from 0 to 4, then add 1 (so range 1-5)
          final imageIndex = courseId.hashCode.abs() % 6 + 1;
          final imagePath = 'assets/galaxies/galaxy$imageIndex.png';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CategoryCard(
              title: course['title'] ?? 'Untitled',
              subtitle: course['description'] ?? '',
              imagePath: imagePath,
              onTap: () => onCategoryTap(courseId),
            ),
          );
        }).toList(),
      );
    });
  }
}
