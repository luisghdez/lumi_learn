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
    widget.classController.loadClassCourses(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final courses = widget.classController.classCourses[widget.classId] ?? [];

      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: BoxConstraints(
                minWidth: 300,
                maxWidth: MediaQuery.of(context).size.width > 1000 ? 1000 : 800,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => widget.showCourses.toggle(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Active Class Courses",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth > 600 ? 20 : 18,
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
                      const SizedBox(height: 8),
                      if (courses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              "No courses assigned yet…",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: screenWidth > 600 ? 16 : 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 400,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: courses.length,
                            separatorBuilder: (_, __) => const Divider(
                              color: Colors.white24,
                              thickness: 1,
                              indent: 8,
                              endIndent: 8,
                            ),
                            itemBuilder: (context, index) {
                              return _buildCourseItem(
                                  courses[index], screenWidth);
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCourseItem(ClassCourse course, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              course.courseName,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth > 600 ? 18 : 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
