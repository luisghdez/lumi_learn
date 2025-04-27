import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/class_course_card.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/student_progress_list.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/active_courses_list.dart';

class ClassroomDetailsPage extends StatelessWidget {
  final Classroom classroomData;

  ClassroomDetailsPage({
    Key? key,
    required this.classroomData,
  }) : super(key: key);

  final ClassController classController = Get.find();
  final RxBool showStudents = false.obs;
  final RxBool showCourses = false.obs;

  @override
  Widget build(BuildContext context) {
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
                // Back button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Your existing classroom header/card
                        ClassroomCardBox(classroomData: classroomData),
                        const SizedBox(height: 24),

                        // 🆕 Student Progress List
                        StudentProgressList(
                          classId: classroomData.id, // ← pass classId
                          showStudents: showStudents,
                          classController: classController,
                        ),

                        const SizedBox(height: 24),

                        // 🆕 Active Class Courses List
                        ActiveCoursesList(
                          classId: classroomData.id, // ← pass classId
                          showCourses: showCourses,
                          classController: classController,
                        ),
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
