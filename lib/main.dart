import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/navigation_controller.dart';
import 'screens/home/home_screen.dart';
import 'screens/social/social_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'utils/constants.dart';

void main() {
  Get.put(NavigationController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lumi Learn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // make dark theme the default
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(),
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
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}
