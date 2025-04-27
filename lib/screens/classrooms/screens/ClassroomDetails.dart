import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/class_course_card.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/student_progress_list.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/active_courses_list.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';


class ClassroomDetailsPage extends StatelessWidget {
  final Classroom classroomData;
  ClassroomDetailsPage({Key? key, required this.classroomData})
      : super(key: key);

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
          // background
          Positioned.fill(
            child: Image.asset('assets/images/black_moons_lighter.png',
                fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
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

                // ───── Scrollable (now inside RefreshIndicator) ─────
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                    onRefresh: classController.loadAllTeacherData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClassroomCardBox(classroomData: classroomData),
                          const SizedBox(height: 24),

                          // student progress list
                          StudentProgressList(
                            classId: classroomData.id,
                            showStudents: showStudents,
                            classController: classController,
                          ),
                          const SizedBox(height: 24),

                          // active courses list
                          ActiveCoursesList(
                            classId: classroomData.id,
                            showCourses: showCourses,
                            classController: classController,
                          ),
                        ],
                      ),
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
