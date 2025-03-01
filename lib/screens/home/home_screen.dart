import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/home_header.dart';
import 'components/search_bar.dart' as custom;
import 'components/top_picks_header.dart';
import 'components/category_list.dart';

// Screens you navigate to
import 'package:lumi_learn_app/screens/settings/settings-screen.dart';
// import 'package:lumi_learn_app/screens/lessons/lesson_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/widgets/app_scaffold.dart';
import 'package:lumi_learn_app/screens/lesson/add_lesson_plan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Hard-code username for now (or get from user controller)
  final String userName = 'YUR';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
                    Get.to(() => const ProfileScreen());
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
                    Get.to(() => const AddLessonPlanScreen());
                  },
                ),

                const SizedBox(height: 20),

                // Category cards
                CategoryList(
                  onCategoryTap: (String categoryName) {
                    // For example, navigate to CourseOverviewScreen, passing category
                    Get.to(() => const CourseOverviewScreen());
                  },
                ),

                // If you want more spacing at bottom
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
    );
  }
}
