import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'controllers/navigation_controller.dart';
import 'screens/auth/auth_gate.dart'; // Your AuthGate widget

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // ✅ Ensure bindings are initialized

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize your controllers and dependencies
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
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      // Use AuthGate as the home widget to handle flow control:
      home: const AuthGate(),
      // Optionally, if you prefer named routes:
      // initialRoute: Routes.authGate,
      // getPages: getPages,
    );
  }
}
