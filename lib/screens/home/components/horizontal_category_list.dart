import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/screens/home/components/horizontal_category_card.dart';
import 'package:crypto/crypto.dart';

class HorizontalCategoryList extends StatelessWidget {
  final double initialPadding;

  HorizontalCategoryList({
    Key? key,
    required this.initialPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.find<CourseController>();

    final double screenWidth = MediaQuery.of(context).size.width;
    final double responsiveHeight = screenWidth >= 600 ? 350.0 : 140.0;

    return Obx(() {
      final courses = courseController.featuredCourses;
      if (courses.isEmpty) {
        return SizedBox(
          height: responsiveHeight,
        );
      }

      return SizedBox(
        height: responsiveHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: initialPadding - 6),
          physics: const BouncingScrollPhysics(),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            String galaxyImagePath = getGalaxyForCourse(course['id']);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Stack(
                children: [
                  HorizontalCategoryCard(
                    height: responsiveHeight,
                    title: course['title'] ?? 'Untitled',
                    imagePath: galaxyImagePath,
                    onConfirm: () async {
                      if (course['loading'] == true) return;

                      if (!courseController.checkCourseSlotAvailable()) {
                        return;
                      }

                      bool saved = await courseController.saveSharedCourse(
                          course['id'], course['title']);
                      if (!saved) return;

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
                          borderRadius: BorderRadius.circular(16),
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
          },
        ),
      );
    });
  }
}

String getGalaxyForCourse(String courseId) {
  final bytes = utf8.encode(courseId);
  final hash = md5.convert(bytes).toString();
  final numericHash = int.parse(hash.substring(0, 6), radix: 16);
  final galaxyIndex = (numericHash % 17) + 1; // 1-17 for 17 images
  return 'assets/galaxies/galaxy$galaxyIndex.png';
}
