import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/student_controller.dart';
import 'package:lumi_learn_app/controllers/class_controller.dart';

import '../components/home_header.dart';
import '../widgets/student/studentTab.dart';
import 'package:lumi_learn_app/screens/classrooms/components/search_bar.dart'
    as custom;
import 'package:lumi_learn_app/screens/classrooms/widgets/student/classroomsCard.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/emptyState.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/joinModal.dart';
import 'package:lumi_learn_app/screens/classrooms/widgets/student/upcoming_card.dart';
import 'package:lumi_learn_app/screens/classrooms/screens/ClassDetails.dart';

class StudentView extends StatelessWidget {
  StudentView({super.key});

  static const double _tabletBreakpoint = 800.0;

  final AuthController authController = Get.find();
  final ClassController classController = Get.put(ClassController());
  final StudentController studentController = Get.put(StudentController());
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
    if (classController.upcomingAssignments.isEmpty) {
      classController.loadUpcomingAssignments();
    }

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
                onRefresh: () async {
                  await studentController.loadStudentClassrooms();
                  await classController.loadUpcomingAssignments();
                },
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
                              child: StudentTabs(
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
                                    : 'Upcoming',
                                style: sectionTitleStyle,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Content Area
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding),
                              child: selectedTabIndex.value == 0
                                  ? _buildClassrooms()
                                  : _buildUpcoming(),
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
    final bool hasClassrooms = studentController.classrooms.isNotEmpty;

    if (hasClassrooms) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...studentController.classrooms.map((classroom) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: StudentClassroomCard(
                classroomData: classroom,
                onTap: () async {
                  await studentController.fetchClassCourses(classroom.id);
                  // Handle classroom tap for student
                  // For example, navigate to classroom details screen
                  Get.to(() => ClassroomDetails(classroom: classroom));
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
                  builder: (context) => const JoinClassroomModal(),
                );
              },
              child: const Text(
                'Join New Classroom',
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
            onJoin: () {
              showDialog(
                context: Get.context!,
                builder: (context) => const JoinClassroomModal(),
              );
            },
          ),
        ],
      );
    }
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if not provided
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Widget _buildUpcoming() {
    final bool hasUpcoming = classController.upcomingAssignments.isNotEmpty;

    if (!hasUpcoming) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const Text(
          "No Upcoming Events",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return Column(
      children: classController.upcomingAssignments.map((assignment) {
        final Color assignmentColor = _hexToColor(assignment.colorCode);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: UpcomingCard(
            eventTitle: assignment.courseTitle, // From backend
            className: assignment.className, // From backend
            dueAt: assignment.dueAt, // From backend
            colorCode: assignmentColor, // 🎨 Static or dynamic color
          ),
        );
      }).toList(),
    );
  }
}
