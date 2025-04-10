import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // <-- RevenueCat SDK
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/friends_controller.dart';
import 'controllers/navigation_controller.dart';
import 'services/friends_service.dart';
import 'screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize RevenueCat for iOS
  await Purchases.setLogLevel(LogLevel.debug);

  if (Platform.isIOS) {
    const revenueCatApiKey = 'appl_XogUDdsMUBFvcOEdKPcoEyYUlkk';
    final configuration = PurchasesConfiguration(revenueCatApiKey);
    await Purchases.configure(configuration);
  }

  // Initialize controllers and services
  Get.put(AuthController());
  Get.put(NavigationController());
  Get.put(FriendsService());
  Get.put(FriendsController(service: FriendsService()));

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
