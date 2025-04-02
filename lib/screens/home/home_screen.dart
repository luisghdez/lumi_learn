import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/home/components/horizontal_category_list.dart';

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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/black_moons.png', // Path to the background image
                fit: BoxFit.fitWidth,
              ),
            ),

            // 📜 Scrollable content (padding top to make space for header)
            SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                // Remove the left/right padding here
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add horizontal padding only around widgets that need it
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HomeHeader(userName: userName),
                    ),
                    const SizedBox(height: 28),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured Courses',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // No extra padding → horizontally scrollable list can be edge-to-edge
                    HorizontalCategoryList(),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TopPicksHeader(
                        onAddTap: () {
                          Get.to(() => const CourseCreation());
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // If the search bar needs horizontal padding, just wrap it
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: custom.SearchBar(),
                    ),
                    const SizedBox(height: 8),

                    // CategoryList needs horizontal padding as well
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CategoryList(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
