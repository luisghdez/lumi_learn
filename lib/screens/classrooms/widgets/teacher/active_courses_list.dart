import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/components/search_bar.dart'
    as custom;

class ActiveCoursesList extends StatefulWidget {
  final String classId;
  final RxBool showCourses;
  final ClassController classController;

  const ActiveCoursesList({
    Key? key,
    required this.classId,
    required this.showCourses,
    required this.classController,
  }) : super(key: key);

  @override
  State<ActiveCoursesList> createState() => _ActiveCoursesListState();
}

class _ActiveCoursesListState extends State<ActiveCoursesList> {
  @override
  void initState() {
    super.initState();
    // Kick off API call to load courses & progress for this class
    widget.classController.loadClassCourses(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // grab the list for this class, or empty if still loading
      final courses = widget.classController.classCourses[widget.classId] ?? [];

      return ClipRRect(
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
                // Title & expand toggle
                GestureDetector(
                  onTap: () => widget.showCourses.toggle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Active Class Courses",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          widget.showCourses.value
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                if (widget.showCourses.value) ...[
                  const Divider(color: Colors.white24, thickness: 1),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: custom.SearchBar(),
                  ),
                  const SizedBox(height: 8),

                  // If no courses yet or loading
                  if (courses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text(
                        "No courses assigned yet…",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    // list each course + avgProgress
                    ...courses.map(_buildCourseItem).toList(),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCourseItem(ClassCourse course) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  course.courseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${course.avgProgress}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.white24,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
