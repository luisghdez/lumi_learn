import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/components/search_bar.dart' as custom;

class ActiveCoursesList extends StatelessWidget {
  final RxBool showCourses;
  final ClassController classController;

  const ActiveCoursesList({
    Key? key,
    required this.showCourses,
    required this.classController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return Obx(() => ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => showCourses.toggle(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTabletOrBigger ? 24 : 16,
                    vertical: isTabletOrBigger ? 20 : 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Active Class Courses",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTabletOrBigger ? 22 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        showCourses.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: isTabletOrBigger ? 30 : 26,
                      ),
                    ],
                  ),
                ),
              ),
              if (showCourses.value) ...[
                const Divider(color: Colors.white24, thickness: 1),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTabletOrBigger ? 24 : 16,
                    vertical: 8,
                  ),
                  child: const custom.SearchBar(),
                ),
                const SizedBox(height: 8),

                ...List.generate(classController.classCourses.length, (index) {
                  final course = classController.classCourses[index];
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTabletOrBigger ? 24 : 16,
                          vertical: isTabletOrBigger ? 18 : 16,
                        ),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                course.courseName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTabletOrBigger ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "${course.avgProgress}%",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isTabletOrBigger ? 16 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index != classController.classCourses.length - 1)
                        const Divider(
                          color: Colors.white24,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    ));
  }
}
