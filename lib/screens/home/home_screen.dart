import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibra_app/screens/courses/add_course_screen.dart';
import 'package:vibra_app/screens/courses/course_overview_screen.dart';
import 'package:vibra_app/widgets/app_scaffold.dart';
// Assuming you have these

import 'components/home_header.dart';
import 'widgets/home_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          const HomeHeader(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Picks',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text('Lets explore our courses!',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.white)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  // Navigate to AddCourseScreen
                  Get.to(() => AddCourseScreen());
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // A Card that the user can tap to go to CourseOverviewScreen
          InkWell(
            onTap: () {
              // Navigate to CourseOverviewScreen
              Get.to(() => CourseOverviewScreen());
            },
            child: Card(
              color: Colors.teal[300], // A colored card
              child: const SizedBox(
                height: 100, // Adjust as desired
                child: Center(
                  child: Text(
                    'View a Course Overview',
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
