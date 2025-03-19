import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/widgets/app_scaffold_home.dart';

import 'components/home_header.dart';
import 'components/search_bar.dart' as custom;
import 'components/top_picks_header.dart';
import 'components/category_list.dart';

// Screens you navigate to
// import 'package:lumi_learn_app/screens/profile/profile_screen.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    final String userName =
        authController.firebaseUser.value!.displayName ?? 'User';

    return AppScaffoldHome(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with "Welcome onboard" + avatar
              HomeHeader(userName: userName), 

              const SizedBox(height: 20),

              // Search bar
              const custom.SearchBar(),

              const SizedBox(height: 20),

              // "Top Picks" row + plus icon
              TopPicksHeader(
                onAddTap: () {
                  Get.to(() => const CourseCreation());
                },
              ),

              const SizedBox(height: 10),

              // Category cards
              CategoryList(),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
