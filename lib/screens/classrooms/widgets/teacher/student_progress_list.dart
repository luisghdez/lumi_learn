import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/components/search_bar.dart' as custom;

class StudentProgressList extends StatelessWidget {
  final RxBool showStudents;
  final ClassController classController;

  const StudentProgressList({
    Key? key,
    required this.showStudents,
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
              // Title and toggle
              GestureDetector(
                onTap: () => showStudents.toggle(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTabletOrBigger ? 24 : 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Student Progress",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTabletOrBigger ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        showStudents.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: isTabletOrBigger ? 32 : 28,
                      ),
                    ],
                  ),
                ),
              ),

              if (showStudents.value) ...[
                const Divider(color: Colors.white24, thickness: 1),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: custom.SearchBar(),
                ),
                const SizedBox(height: 8),

                // Students list
                ...classController.studentProgress.map((progress) => _buildStudentItem(context, progress)).toList(),
              ],
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildStudentItem(BuildContext context, StudentProgress progress) {
    final RxBool isExpanded = false.obs;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrBigger = screenWidth > 600;

    return Obx(() => Column(
      children: [
        GestureDetector(
          onTap: () => isExpanded.toggle(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isTabletOrBigger ? 24 : 16, vertical: 16),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    progress.studentName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTabletOrBigger ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: isTabletOrBigger ? 28 : 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded.value)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isTabletOrBigger ? 32 : 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: progress.courseProgress.map((course) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          course.courseName,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: isTabletOrBigger ? 16 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${course.progress}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTabletOrBigger ? 16 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        const Divider(color: Colors.white24, thickness: 1, indent: 16, endIndent: 16),
      ],
    ));
  }
}
