import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart'; // <-- RevenueCat SDK
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';

import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/friends_controller.dart';
import 'controllers/navigation_controller.dart';
import 'services/friends_service.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/lumiTutor/lumi_tutor_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Purchases.setLogLevel(LogLevel.debug);
  if (Platform.isIOS) {
    const revenueCatApiKey = 'appl_XogUDdsMUBFvcOEdKPcoEyYUlkk';
    final configuration = PurchasesConfiguration(revenueCatApiKey);
    await Purchases.configure(configuration);
  }

  Get.put(AuthController());
  Get.put(NavigationController());

  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumi Learn',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => AuthGate()),
        GetPage(name: '/lumiTutorChat', page: () => const LumiTutorMain()),
        // 👇 Add this when you want to route directly to scanner with camera
        // GetPage(name: '/scanner', page: () => AiScannerMain(cameras: cameras)),
      ],
    );
  }
}
