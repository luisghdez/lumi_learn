// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibra_app/screens/messaging/messaging_screen.dart';
import 'controllers/navigation_controller.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'utils/constants.dart';

void main() {
  // Initialize the NavigationController using GetX
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use GetMaterialApp instead of MaterialApp
    return GetMaterialApp(
      title: 'Clean Navbar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: navigationController.currentIndex.value,
          children: const [
            HomeScreen(),
            SearchScreen(),
            MessagingScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(),
    );
  }
}
