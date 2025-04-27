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
    widget.classController.loadStudentProgress(widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final List<StudentProgress> students =
          widget.classController.studentProgress[widget.classId] ?? [];

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and toggle
                    GestureDetector(
                      onTap: () => widget.showStudents.toggle(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Student Progress",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth > 600 ? 20 : 18,
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
                      const SizedBox(height: 8),
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
                        SizedBox(
                          height: 400,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              return _buildStudentItem(
                                  students[index], screenWidth);
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

  Widget _buildStudentItem(StudentProgress progress, double screenWidth) {
    final RxBool isExpanded = false.obs;

    return Obx(() => Column(
          children: [
            GestureDetector(
              onTap: () => isExpanded.toggle(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        progress.studentName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth > 600 ? 18 : 16,
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              style: const TextStyle(
                                color: Colors.white70,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${course.progress}%',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const Divider(
              color: Colors.white24,
              thickness: 1,
              indent: 8,
              endIndent: 8,
            ),
          ],
        ));
  }
}
