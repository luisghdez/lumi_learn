import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';

import 'firebase_options.dart';
import 'application/controllers/auth_controller.dart';
import 'application/controllers/navigation_controller.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/lumiTutor/lumi_tutor_main.dart';

// <<< NEW: Notifications services
import 'notifications/firebase_messaging.dart';
import 'notifications/local_notifications.dart';

// <<< NEW: Keyboard utils
import 'utils/keyboard.dart';
import 'utils/keyboard_dismiss_observer.dart';

// Deep link handler is now initialized in AuthGate after authentication

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // <<< NEW: Init local + FCM notifications
  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(
      localNotificationsService: localNotificationsService);

  // RevenueCat setup
  await Purchases.setLogLevel(LogLevel.debug);
  if (Platform.isIOS) {
    const revenueCatApiKey = 'appl_XogUDdsMUBFvcOEdKPcoEyYUlkk';
    final configuration = PurchasesConfiguration(revenueCatApiKey);
    await Purchases.configure(configuration);
  }

  // GetX controllers
  Get.put(AuthController());
  Get.put(NavigationController());
  // Note: FriendsController and other controllers are now initialized in AuthGate after auth

  // Camera initialization
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

      // <<< Keyboard handling
      navigatorObservers: [
        KeyboardDismissObserver(),
      ],
      routingCallback: (routing) {
        Keyboard.hide();
      },
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) => Keyboard.hide());
        return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: Keyboard.hide,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
