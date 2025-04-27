import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/ClassroomHeader.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/WeeklySchedule.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/ClassCourseCard.dart';

class ClassroomDetails extends StatelessWidget {
  final Classroom classroom;

  ClassroomDetails({Key? key, required this.classroom}) : super(key: key);

  static const double _tabletBreakpoint = 800.0;
  final ClassController classController = Get.find(); // Find existing controller

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > _tabletBreakpoint ? 32.0 : 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = _getHorizontalPadding(context);

    // Fetch the list of courses for this classroom
    final List<Course> courses = classController.classroomCourses[classroom.title] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Content
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🛠 BACK BUTTON - outside the card
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: Colors.white,
                          iconSize: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 🛠 CLASSROOM CARD
                    ClassroomHeaderCard(classroom: classroom),
                    const SizedBox(height: 32),

                    // WEEKLY SCHEDULE
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

                    // MY CLASS COURSES
                    const Text(
                      "My Class Courses",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Column(
                      children: courses.map((course) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ClassCourseCard(
                            imagePath: 'assets/galaxies/galaxy10.png',
                            courseName: course.title,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
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
// String getGalaxyForCourse(String courseId) {
//   final bytes = utf8.encode(courseId);
//   final hash = md5.convert(bytes).toString();
//   final numericHash = int.parse(hash.substring(0, 6), radix: 16);
//   final galaxyIndex = (numericHash % 17) + 1; // 1-17 for 17 images
//   return 'assets/galaxies/galaxy$galaxyIndex.png';
// }
