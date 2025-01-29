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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          child: Row(
            children: List.generate(10, (index) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => LessonScreen());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0), // Add spacing between items
                  child: Image.asset(
                    'assets/planets/red1.png',
                    width: 100.0, // Set the width of the image
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
