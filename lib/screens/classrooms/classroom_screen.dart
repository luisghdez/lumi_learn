import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/screens/classrooms/screens/student_view.dart';
import 'package:lumi_learn_app/screens/classrooms/screens/teacher_view.dart';
import 'package:lumi_learn_app/screens/classrooms/components/role_selection.dart';
import 'package:lumi_learn_app/screens/classrooms/onboarding/age_selection.dart';
import 'package:lumi_learn_app/controllers/navigation_controller.dart';


class ClassroomsScreen extends StatelessWidget {
  ClassroomsScreen({super.key});

  final AuthController authController = Get.find();
  final navController = Get.find<NavigationController>();


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userRole = authController.userRole.value;

      if (userRole == null) {
        return _buildRoleSelection(); // show onboarding
      } else if (userRole == UserRole.teacher) {
        return TeacherView(); // 👨‍🏫
      } else if (userRole == UserRole.student) {
        return StudentView(); // 🎓
      } else {
        return const Center(
          child: Text(
            'Loading...',
            style: TextStyle(color: Colors.white),
          ),
        );
      }
    });
  }

  Widget _buildRoleSelection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Who are you?',
              style: Get.textTheme.headlineSmall?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            RoleSelectionCard(
              title: 'Student',
              description: 'Learn, grow, and complete courses!',
              onTap: () {
                Get.to(
                  () => AgeSelectionScreen(
                    onCompleteOnboarding: () {
                      authController.setUserRole(UserRole.student);
                      authController.hasCompletedOnboarding.value = true;
                    },
                  ),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 400),
                );
              },
            ),
            const SizedBox(height: 16),
            RoleSelectionCard(
              title: 'Teacher',
              description: 'Manage classes and help students learn.',
              onTap: () {
                authController.setUserRole(UserRole.teacher);
                authController.hasCompletedOnboarding.value = true;
              },
            ),
          ],
        ),
      ),
    );
  }
}
