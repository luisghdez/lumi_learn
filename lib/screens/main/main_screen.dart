import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/home/home_screen.dart';
import 'package:lumi_learn_app/screens/settings/settings-screen.dart';
import 'package:lumi_learn_app/screens/social/social_screen.dart';
import 'package:lumi_learn_app/widgets/bottom_nav_bar.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navigationController.currentIndex.value,
          children: [
            HomeScreen(),
            const SearchScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}
