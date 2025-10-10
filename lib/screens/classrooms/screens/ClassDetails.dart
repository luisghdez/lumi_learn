import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/class_controller.dart';
import 'package:lumi_learn_app/application/controllers/student_controller.dart';
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/ClassroomHeader.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/WeeklySchedule.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/ClassCourseCard.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/screens/home/components/category_card.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:crypto/crypto.dart';

class ClassroomDetails extends StatefulWidget {
  final Classroom classroom;
  const ClassroomDetails({Key? key, required this.classroom}) : super(key: key);

  @override
  _ClassroomDetailsState createState() => _ClassroomDetailsState();
}

class _ClassroomDetailsState extends State<ClassroomDetails> {
  static const double _tabletBreakpoint = 800.0;
  final StudentController studentController = Get.find();
  final CourseController courseController = Get.find();

  @override
  void initState() {
    super.initState();
    // 1) Load courses for this class as soon as the widget mounts
    studentController.fetchClassCourses(widget.classroom.id);
  }

  double _getHorizontalPadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w > _tabletBreakpoint ? 32.0 : 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final pad = _getHorizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  // 1) Load courses for this class
                  await studentController
                      .fetchClassCourses(widget.classroom.id);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: pad, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // back button
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      // header card
                      ClassroomHeaderCard(classroom: widget.classroom),
                      const SizedBox(height: 32),
                      // schedule
                      const Text(
                        "Class Weekly Schedule",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const WeeklySchedule(),
                      const SizedBox(height: 32),
                      // courses
                      const Text(
                        "My Class Courses",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 2) reactive list
                      Obx(() {
                        final courses = studentController
                                .classroomCourses[widget.classroom.id] ??
                            [];
                        return Column(
                          children: courses.map((course) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: CategoryCard(
                                courseId: course.id,
                                title: course.title,
                                completedLessons: 0,
                                totalLessons: 0,
                                imagePath: getGalaxyForCourse(course.id),
                                tags: [],
                                onTap: () async {
                                  // Prevent navigation if still loading
                                  if (false == true) return;

                                  courseController.setSelectedCourseId(
                                      course.id, course.title);

                                  Get.to(
                                    () => LoadingScreen(),
                                    transition: Transition.fadeIn,
                                    duration: const Duration(milliseconds: 500),
                                  );
                                  await Future.wait([
                                    Future.delayed(
                                        const Duration(milliseconds: 1000)),
                                    precacheImage(
                                      const AssetImage(
                                          'assets/images/milky_way.png'),
                                      context,
                                    ),
                                  ]);

                                  while (courseController.isLoading.value) {
                                    await Future.delayed(
                                        const Duration(milliseconds: 100));
                                  }

                                  // Navigate to CourseOverviewScreen
                                  Get.offAll(
                                    () => const CourseOverviewScreen(),
                                    transition: Transition.fadeIn,
                                    duration: const Duration(milliseconds: 500),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// // This helper is unchanged – it just picks a galaxy image based on a hash of the courseId.
String getGalaxyForCourse(String courseId) {
  final bytes = utf8.encode(courseId);
  final hash = md5.convert(bytes).toString();
  final numericHash = int.parse(hash.substring(0, 6), radix: 16);
  final galaxyIndex = (numericHash % 17) + 1; // 1-17 for 17 images
  return 'assets/galaxies/galaxy$galaxyIndex.png';
}
