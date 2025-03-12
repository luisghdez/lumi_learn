import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/widgets/app_scaffold_home.dart';

import 'components/home_header.dart';
import 'components/search_bar.dart' as custom;
import 'components/top_picks_header.dart';
import 'components/category_list.dart';

// Screens you navigate to
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';
// import 'package:lumi_learn_app/screens/lessons/lesson_screen.dart';
// import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
// import 'package:lumi_learn_app/screens/lesson/add_lesson_plan_screen.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    final String userName =
        authController.firebaseUser.value!.displayName ?? 'User';

    return AppScaffoldHome(
      // If AppScaffold has its own background color, you can omit Container's color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with "Welcome onboard" + avatar
              HomeHeader(
                userName: userName,
                onAvatarTap: () {
                  // Navigate to profile screen
                  Get.to(() => ProfileScreen());
                },
              ),
              const SizedBox(height: 20),

              // Search bar
              const custom.SearchBar(),

              const SizedBox(height: 20),

              // "Top Picks" row + plus icon
              TopPicksHeader(
                onAddTap: () {
                  // Navigate to your Lesson creation screen
                  // Get.to(() => const AddLessonPlanScreen());
                  Get.to(() => const CourseCreation());
                },
              ),

              const SizedBox(height: 10),

              // Category cards
              const CategoryList(),

              // If you want more spacing at bottom
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
