import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lumi_learn_app/services/friends_service.dart';

import 'controllers/navigation_controller.dart';
import 'screens/auth/auth_gate.dart'; // Your AuthGate widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize your controllers and dependencies
  Get.put(AuthController());
  Get.put(NavigationController());
  Get.put(FriendsService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lumi Learn',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // Use AuthGate as the home widget to handle flow control:
      home: AuthGate(),
      // Optionally, if you prefer named routes:
      // initialRoute: Routes.authGate,
      // getPages: getPages,
    );
  }
}
