import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';

import 'firebase_options.dart';
import 'application/controllers/auth_controller.dart';
import 'application/controllers/friends_controller.dart';
import 'application/controllers/navigation_controller.dart';
import 'application/services/friends_service.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/lumiTutor/lumi_tutor_main.dart';

// <<< NEW
import 'utils/keyboard.dart';
import 'utils/keyboard_dismiss_observer.dart';

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
      ],

      // <<< NEW: dismiss on any route change (GetX + Navigator)
      navigatorObservers: [
        KeyboardDismissObserver(),
      ],

      // <<< NEW: also hide when Get’s routing changes (covers nested/router cases)
      routingCallback: (routing) {
        // This fires on Get.to, Get.off*, etc.
        Keyboard.hide();
      },

      // <<< NEW: ensure the very first frame (e.g., Home) starts with keyboard hidden
      builder: (context, child) {
        // Hide after first layout of each route to prevent “stuck keyboard” on entry
        WidgetsBinding.instance.addPostFrameCallback((_) => Keyboard.hide());
        // Global tap-to-dismiss anywhere (nice UX)
        return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: Keyboard.hide,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
