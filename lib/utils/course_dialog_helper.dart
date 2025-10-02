import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_body.dart';
import 'package:lumi_learn_app/widgets/tag_chip.dart';

/// Shows the course confirmation dialog with course details
void showCourseConfirmationDialog(
  BuildContext context,
  Map<String, dynamic> course,
  CourseController courseController,
) {
  List<String> displayTags = List<String>.from(course['tags'] ?? []);
  final String title = course['title'] ?? 'Untitled Course';
  final String? subject = course['subject'];
  final bool hasEmbeddings = course['hasEmbeddings'] ?? false;
  final int totalSaves = course['savedCount'] ?? 0;
  final int totalLessons = course['lessonCount'] ?? course['totalLessons'] ?? 0;
  final String createdByName = course['createdByName'] ?? 'Anonymous';
  final String? createdById = course['createdById'] ?? course['createdBy'];

  // Add subject tag if hasEmbeddings is true and subject is available
  if (hasEmbeddings && subject != null && subject.isNotEmpty) {
    displayTags.insert(0, subject);
  } else if (displayTags.isEmpty) {
    // Only show default tags when no subject and no other tags
    displayTags = ['#Classic'];
  }

  Get.generalDialog(
    barrierDismissible: true,
    barrierLabel: "Course Confirm",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return const SizedBox.shrink(); // required but unused
    },
    transitionBuilder: (context, animation, _, __) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));

      return SlideTransition(
        position: offsetAnimation,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Prevent outside tap
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          if (createdById != null) {
                            _navigateToUserProfile(createdById);
                          }
                        },
                        child: Text(
                          'Created by: $createdByName',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: createdById != null
                                ? Colors.white70
                                : Colors.white54,
                            decoration: createdById != null
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: -6,
                        children: displayTags
                            .map((tag) => TagChip(label: tag))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_border,
                              color: Colors.white60, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$totalSaves',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.menu_book_rounded,
                              color: Colors.white60, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$totalLessons lesson${totalLessons != 1 ? 's' : ''}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(); // Close dialog
                            _navigateToCourse(course, courseController);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Start Learning'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _navigateToUserProfile(String userId) async {
  try {
    final friendsController = Get.find<FriendsController>();
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    await friendsController.setActiveFriend(userId);
    Get.back(); // Close loading dialog
    Get.to(
      () => const FriendProfile(),
      transition: Transition.fadeIn,
    );
  } catch (e) {
    Get.back(); // Close loading dialog
    Get.snackbar("Error", "Could not load profile: $e");
  }
}

Future<void> _navigateToCourse(
  Map<String, dynamic> course,
  CourseController courseController,
) async {
  if (course['loading'] == true) return;

  // Check if course is already saved
  bool isAlreadySaved = courseController.courses
      .any((savedCourse) => savedCourse['id'] == course['id']);

  if (!isAlreadySaved) {
    // Only check slots and save if it's not already saved
    if (!courseController.checkCourseSlotAvailable()) {
      return;
    }

    bool saved = await courseController.saveSharedCourse(
      course['id'],
      course['title'],
    );
    if (!saved) return;
  }

  // Always proceed to navigation regardless of save status
  courseController.setSelectedCourseId(
    course['id'],
    course['title'],
    course['hasEmbeddings'] ?? false,
  );

  Get.to(
    () => LoadingScreen(),
    transition: Transition.fadeIn,
    duration: const Duration(milliseconds: 500),
  );

  await Future.wait([
    Future.delayed(const Duration(milliseconds: 1000)),
    precacheImage(
      const AssetImage('assets/images/milky_way.png'),
      Get.context!,
    ),
  ]);

  while (courseController.isLoading.value) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Get.offAll(
    () => const CourseOverviewScreen(),
    transition: Transition.fadeIn,
    duration: const Duration(milliseconds: 500),
  );
}
