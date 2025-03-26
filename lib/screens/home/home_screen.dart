import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/widgets/app_scaffold_home.dart';

import 'components/category_list.dart';
import 'components/search_bar.dart' as custom;
import 'components/top_picks_header.dart';
import 'components/home_header.dart';
import 'package:lumi_learn_app/screens/home/widget/galaxybg.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final String userName =
        authController.firebaseUser.value?.displayName ?? 'User';

    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GalaxyHeader(),
          ),

          // 📜 Scrollable content (padding top to make space for header)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(userName: userName), // 👈 Now it's scrollable
                  const SizedBox(height: 24),
                  const custom.SearchBar(),
                  const SizedBox(height: 24),
                  TopPicksHeader(
                    onAddTap: () {
                      Get.to(() => const CourseCreation());
                    },
                  ),
                  const SizedBox(height: 20),
                  CategoryList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
