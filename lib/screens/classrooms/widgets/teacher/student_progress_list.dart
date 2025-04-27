import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/components/search_bar.dart'
    as custom;

class StudentProgressList extends StatefulWidget {
  final String classId;
  final RxBool showStudents;
  final ClassController classController;

  const StudentProgressList({
    Key? key,
    required this.classId,
    required this.showStudents,
    required this.classController,
  }) : super(key: key);

  @override
  State<StudentProgressList> createState() => _StudentProgressListState();
}

class _StudentProgressListState extends State<StudentProgressList> {
  @override
  void initState() {
    super.initState();
    // Kick off the API call
    widget.classController.loadStudentProgress(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Grab the list for this class, or empty if still loading
      final List<StudentProgress> students =
          widget.classController.studentProgress[widget.classId] ?? [];

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
                // Title and toggle
                GestureDetector(
                  onTap: () => widget.showStudents.toggle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Student Progress",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          widget.showStudents.value
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),

                if (widget.showStudents.value) ...[
                  const Divider(color: Colors.white24, thickness: 1),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: custom.SearchBar(),
                  ),
                  const SizedBox(height: 8),

                  // If still loading or no students:
                  if (students.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Text(
                        "No students yet or loading…",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    // List each student
                    ...students
                        .map((progress) => _buildStudentItem(progress))
                        .toList(),
                ],
              ],
            ),
          ),
        ),
      );
    });
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        progress.studentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded.value)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: progress.courseProgress.map((course) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(course.courseName,
                              style: const TextStyle(color: Colors.white70)),
                          Text('${course.progress}%',
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const Divider(
              color: Colors.white24,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
          ],
        ));
  }
}
