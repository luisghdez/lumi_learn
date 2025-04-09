import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/home/components/horizontal_category_list.dart';

import 'components/category_list.dart';
import 'components/search_bar.dart' as custom;
import 'components/top_picks_header.dart';
import 'components/home_header.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final CourseController courseController = Get.find();

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/black_moons_lighter.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              top: false,
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      bottom: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Add horizontal padding only around widgets that need it
                          Obx(() => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: HomeHeader(
                                  streakCount: authController.streakCount.value,
                                  xpCount: authController.xpCount.value,
                                ),
                              )),

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
                          const SizedBox(height: 12),

                          HorizontalCategoryList(),
                          const SizedBox(height: 18),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Obx(() => TopPicksHeader(
                                onAddTap: () {
                                  if (courseController
                                      .checkCourseSlotAvailable()) {
                                    Get.to(() => const CourseCreation());
                                  }
                                },
                                slotsUsed: authController.courseSlotsUsed.value,
                                maxSlots: authController.maxCourseSlots.value,
                                isPremium: authController.isPremium.value)),
                          ),

                          const SizedBox(height: 8),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: custom.SearchBar(),
                          ),
                          const SizedBox(height: 8),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CategoryList(),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
