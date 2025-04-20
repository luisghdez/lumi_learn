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

  static const double _tabletBreakpoint = 800.0;

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > _tabletBreakpoint ? 32.0 : 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final CourseController courseController = Get.find();

    final double horizontalPadding = _getHorizontalPadding(context);
    final double topScrollViewPadding =
        MediaQuery.of(context).padding.top + horizontalPadding;
    const double bottomScrollViewPadding = 40.0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= _tabletBreakpoint;

    final TextStyle sectionTitleStyle = isTablet
        ? Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            )
        : const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          );

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
                      top: topScrollViewPadding,
                      bottom: bottomScrollViewPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            topScrollViewPadding -
                            bottomScrollViewPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Obx(() => HomeHeader(
                                  streakCount: authController.streakCount.value,
                                  xpCount: authController.xpCount.value,
                                  isPremium: authController.isPremium.value,
                                )),
                          ),
                          const SizedBox(height: 28),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Text(
                              'Featured Courses',
                              style: sectionTitleStyle,
                            ),
                          ),
                          const SizedBox(height: 12),
                          HorizontalCategoryList(
                              initialPadding: horizontalPadding),
                          const SizedBox(height: 18),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Obx(
                              () => TopPicksHeader(
                                onAddTap: () {
                                  if (courseController
                                      .checkCourseSlotAvailable()) {
                                    Get.to(() => const CourseCreation(),
                                        transition: Transition.fadeIn);
                                  }
                                },
                                slotsUsed: authController.courseSlotsUsed.value,
                                maxSlots: authController.maxCourseSlots.value,
                                isPremium: authController.isPremium.value,
                                titleStyle: sectionTitleStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: const custom.SearchBar(),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: CategoryList(),
                          ),
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
