import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/widgets/regular_category_card.dart';

class OnboardingSelectCourseScreen extends StatefulWidget {
  const OnboardingSelectCourseScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingSelectCourseScreen> createState() =>
      _OnboardingSelectCourseScreenState();
}

class _OnboardingSelectCourseScreenState
    extends State<OnboardingSelectCourseScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch courses if not already loaded
    final courseController = Get.find<CourseController>();
    if (courseController.courses.isEmpty) {
      courseController.fetchCourses();
    }
  }

  String _getGalaxyForCourse(String courseId) {
    // Simple hash-based selection
    final hash = courseId.hashCode.abs();
    final galaxyIndex = (hash % 22) + 1;
    return 'assets/galaxies/galaxy$galaxyIndex.png';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;
    final courseController = Get.find<CourseController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: screenHeight,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: isTablet ? screenWidth * 0.15 : 24,
                  right: isTablet ? screenWidth * 0.15 : 24,
                  top: 16,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () {
                          Get.off(
                            () => CourseCreation(fromOnboarding: true),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                      ),
                    ),
                    // Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select an \nexisting course",
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: isTablet ? 52 : 38,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Choose a course to get started",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: isTablet ? 22 : 18,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Course List
                    Obx(() {
                      final courses = courseController.courses;

                      if (courses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.explore_off,
                                size: 48,
                                color: Colors.white60,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No courses available',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Courses will appear here once they are created',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: courses.map<Widget>((course) {
                          final galaxyImagePath =
                              _getGalaxyForCourse(course['id'] ?? '');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: RegularCategoryCard(
                              courseId: course['id'] ?? '',
                              courseName: course['title'] ?? 'Untitled',
                              lessonCount: course['totalLessons'] ?? 0,
                              bookmarkCount: course['savedCount'] ?? 0,
                              imagePath: galaxyImagePath,
                              tags: List<String>.from(course['tags'] ?? []),
                              subject: course['subject'],
                              hasEmbeddings: course['hasEmbeddings'] ?? false,
                              onStartLearning: () async {
                                // Prevent navigation if still loading
                                if (course['loading'] == true) return;

                                courseController.setSelectedCourseId(
                                  course['id'],
                                  course['title'],
                                  course['hasEmbeddings'],
                                );

                                Get.to(
                                  () => LoadingScreen(),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500),
                                );

                                await Future.wait([
                                  Future.delayed(
                                      const Duration(milliseconds: 1000)),
                                  precacheImage(
                                    const AssetImage(
                                        'assets/images/milky_way.png'),
                                    context,
                                  ),
                                ]);

                                while (courseController.isLoading.value) {
                                  await Future.delayed(
                                      const Duration(milliseconds: 100));
                                }

                                // Navigate to CourseOverviewScreen and clear onboarding stack
                                Get.offAll(
                                  () => CourseOverviewScreen(),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
