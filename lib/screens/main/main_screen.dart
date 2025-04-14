import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/home/home_screen.dart';
import 'package:lumi_learn_app/screens/profile/profile_screen.dart';
// import 'package:lumi_learn_app/screens/profile/profile_screen.dart';
import 'package:lumi_learn_app/screens/social/friends_screen.dart';
import 'package:lumi_learn_app/widgets/bottom_nav_bar.dart';
import 'package:lumi_learn_app/screens/leaderboard/leaderboard_screen.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents resizing when the keyboard appears
      body: Stack(
        children: [
          // Listen to scrolling for hiding/showing the navbar
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is UserScrollNotification) {
                if (notification.direction == ScrollDirection.forward) {
                  navigationController.showNavBar();
                } else if (notification.direction == ScrollDirection.reverse) {
                  navigationController.hideNavBar();
                }
              }
              return false;
            },
            child: Obx(
              () => IndexedStack(
                index: navigationController.currentIndex.value,
                children: [
                  HomeScreen(),
                  // LeaderboardPage(),
                  const ProfileScreen(),
                  // const FriendsScreen(),
                ],
              ),
            ),
          ),

          // Floating Bottom Navbar
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavbar(),
          ),
        ],
      ),
    );
  }
}
