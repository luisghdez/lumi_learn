import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/aiScanner/ai_scanner_main.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_topic_screen.dart';
import 'package:lumi_learn_app/screens/home/components/feature_card.dart';
import 'package:lumi_learn_app/screens/home/components/horizontal_category_list.dart';
import 'package:lumi_learn_app/screens/home/components/lumi_tutor_card.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'components/category_list.dart';
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
    final NavigationController navigationController = Get.find();

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
            fontSize: 18,
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
                                horizontal: _getHorizontalPadding(context)),
                            child: Row(
                              children: [
                                FeatureCard(
                                  color:
                                      const Color.fromARGB(255, 85, 151, 222),
                                  icon: Symbols.document_scanner,
                                  title: 'AI Scanner',
                                  onTap: () {
                                    Get.to(() => const AiScannerMain());
                                  },
                                ),
                                const SizedBox(width: 10),
                                FeatureCard(
                                  color:
                                      const Color.fromARGB(255, 204, 75, 101),
                                  icon: Symbols.note_add,
                                  title: 'Add Course',
                                  onTap: () {
                                    Get.to(() => const CourseTopicScreen());
                                  },
                                ),
                                const SizedBox(width: 10),
                                FeatureCard(
                                  color:
                                      const Color.fromARGB(255, 81, 198, 127),
                                  icon: Symbols.forum,
                                  title: 'LumiTutor',
                                  onTap: () {
                                    navigationController.updateIndex(3);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Suggested Courses',
                                  style:
                                      sectionTitleStyle, // bold or headline style
                                ),
                                GestureDetector(
                                  onTap: () {
                                    navigationController.updateIndex(1);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Search',
                                        style: sectionTitleStyle.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward,
                                          size: 16, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          HorizontalCategoryList(
                              initialPadding: horizontalPadding),
                          const SizedBox(height: 18),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LumiTutor',
                                  style: sectionTitleStyle,
                                ),
                                const SizedBox(height: 8),
                                const LumiTutorCard(),
                              ],
                            ),
                          ),
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
