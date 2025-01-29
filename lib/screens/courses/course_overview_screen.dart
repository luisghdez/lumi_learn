import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibra_app/screens/courses/lessons/lesson_screen.dart';
import 'package:vibra_app/widgets/starry_app_scaffold.dart';

class CourseOverviewScreen extends StatelessWidget {
  const CourseOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StarryAppScaffold(
      body: Center(
        child: Wrap(
          spacing: 20.0,
          runSpacing: 20.0,
          children: List.generate(10, (index) {
            return GestureDetector(
              onTap: () {
                Get.to(() => LessonScreen());
              },
              child: CircleAvatar(
                radius: 30.0,
                backgroundColor: const Color.fromARGB(255, 133, 175, 209),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
