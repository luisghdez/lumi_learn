import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/class_course_card.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/student_progress_list.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/active_courses_list.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';

class ClassroomDetailsPage extends StatelessWidget {
  final Classroom classroomData;

  ClassroomDetailsPage({Key? key, required this.classroomData}) : super(key: key);

  final ClassController classController = Get.find();
  final RxBool showStudents = false.obs;
  final RxBool showCourses = false.obs;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top back button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTabletOrBigger ? 16 : 8,
                    vertical: isTabletOrBigger ? 12 : 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: isTabletOrBigger ? 32 : 28),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTabletOrBigger ? 32 : 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClassroomCardBox(classroomData: classroomData),
                        const SizedBox(height: 24),

                        // Student Progress
                        StudentProgressList(
                          showStudents: showStudents,
                          classController: classController,
                        ),
                        const SizedBox(height: 24),

                        // Active Class Courses
                        ActiveCoursesList(
                          showCourses: showCourses,
                          classController: classController,
                        ),
                        const SizedBox(height: 32),

                        // Create New Course Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.55),
                              side: const BorderSide(color: Colors.white24),
                              padding: EdgeInsets.symmetric(
                                vertical: isTabletOrBigger ? 20 : 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Get.to(() => const CourseCreation(), transition: Transition.fadeIn);
                            },
                            icon: Icon(Icons.add, color: Colors.white, size: isTabletOrBigger ? 28 : 24),
                            label: Text(
                              "Create New Course",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isTabletOrBigger ? 18 : 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
