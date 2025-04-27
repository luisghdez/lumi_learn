import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';

import '../components/home_header.dart';
import '../widgets/teacher/teacherTab.dart';
import '../widgets/teacher/ClassroomModal.dart';
import 'package:lumi_learn_app/screens/classrooms/components/search_bar.dart'
    as custom;
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/classroomsCard.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/emptyState.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/teacher/recentSubmissionCard.dart';

class TeacherView extends StatelessWidget {
  TeacherView({super.key});

  static const double _tabletBreakpoint = 800.0;

  final AuthController authController = Get.find();
  final ClassController classController = Get.put(ClassController());
  final RxInt selectedTabIndex = 0.obs;

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > _tabletBreakpoint ? 32.0 : 16.0;
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = _getHorizontalPadding(context);
    final double topScrollViewPadding =
        MediaQuery.of(context).padding.top + horizontalPadding;
    const double bottomScrollViewPadding = 40.0;

    final bool isTablet =
        MediaQuery.of(context).size.width >= _tabletBreakpoint;

    final TextStyle sectionTitleStyle = isTablet
        ? Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              decoration: TextDecoration.none,
            )
        : const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            decoration: TextDecoration.none,
          );

    return Stack(
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
              final double calculatedMinHeight = math.max(
                0.0,
                constraints.maxHeight -
                    topScrollViewPadding -
                    bottomScrollViewPadding,
              );

              return RefreshIndicator(
                color: Colors.white, // progress circle color
                backgroundColor: Colors.black54, // behind the circle
                onRefresh: classController.loadAllTeacherData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: topScrollViewPadding,
                    bottom: bottomScrollViewPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: calculatedMinHeight),
                    child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Home Header
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: HomeHeader(
                                streakCount: authController.streakCount.value,
                                xpCount: authController.xpCount.value,
                                isPremium: authController.isPremium.value,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Tabs
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: TeacherTabs(
                                selectedIndex: selectedTabIndex.value,
                                onTabSelected: (index) {
                                  selectedTabIndex.value = index;
                                },
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Section Title
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: Text(
                                selectedTabIndex.value == 0
                                    ? 'My Classrooms'
                                    : 'Recent Submissions',
                                style: sectionTitleStyle,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Search Bar
                            if (selectedTabIndex.value == 0)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding),
                                child: const custom.SearchBar(),
                              ),
                            const SizedBox(height: 12),

                            // Content Area
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: selectedTabIndex.value == 0
                                  ? _buildClassrooms()
                                  : _buildRecentSubmissions(),
                            ),
                          ],
                        )),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassrooms() {
    final bool hasClassrooms = classController.classrooms.isNotEmpty;

    if (hasClassrooms) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...classController.classrooms.map((classroom) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClassroomCard(
                classroomData: classroom,
                onTap: () {
                  // Handle tap
                },
              ),
            );
          }).toList(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: Get.context!,
                  builder: (context) => const CreateClassroomModal(),
                );
              },
              child: const Text(
                'Create New Classroom',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 24),
          EmptyClassroomCard(
            onCreate: () {
              showDialog(
                context: Get.context!,
                builder: (context) => const CreateClassroomModal(),
              );
            },
          ),
        ],
      );
    }
  }

  Widget _buildRecentSubmissions() {
    final bool hasSubmissions = classController.recentSubmissions.isNotEmpty;

    if (!hasSubmissions) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const Text(
          "No Recent Submissions",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return Column(
      children: classController.recentSubmissions.map((submission) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RecentSubmissionCard(
              submissionTitle: submission.submissionTitle,
              studentName: submission.studentName,
              className: submission.className,
              timeAgo: submission.timeAgo,
              sideColor: submission.sideColor,
              onTap: () {
                // Optional tap logic
              },
            ));
      }).toList(),
    );
  }
}
