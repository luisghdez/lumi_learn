import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notifications.dart';
// import '../application/services/notif_service.dart';
import 'package:lumi_learn_app/application/services/notif_service.dart';
import 'package:get/get.dart';



class FirebaseMessagingService {
  // Private constructor for singleton pattern
  FirebaseMessagingService._internal();

  // Singleton instance
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  // Factory constructor to provide singleton instance
  factory FirebaseMessagingService.instance() => _instance;

  // Reference to local notifications service for displaying notifications
  LocalNotificationsService? _localNotificationsService;

  /// Initialize Firebase Messaging and sets up all message listeners
  Future<void> init({required LocalNotificationsService localNotificationsService}) async {
    // Init local notifications service
    _localNotificationsService = localNotificationsService;

    // Handle FCM token
    _handlePushNotificationsToken();

    // Request user permission for notifications
    _requestPermission();

    // Register handler for background messages (app terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen for messages when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Listen for notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  final service = NotifService();


  /// Retrieves and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('Push notifications token: $token');

    if (token != null) {
      await service.sendFcmTokenToServer(token); // ✅ Send to backend here
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      print('FCM token refreshed: $fcmToken');
      await service.sendFcmTokenToServer(fcmToken); // ✅ Update on refresh too
    }).onError((error) {
      print('Error refreshing FCM token: $error');
    });
  }


  /// Requests notification permission from the user
  Future<void> _requestPermission() async {
    // Request permission for alerts, badges, and sounds
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );


    // Log the user's permission decision
    print('User granted permission: ${result.authorizationStatus}');
  }

  /// Handles messages received while the app is in the foreground
  void _onForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.data.toString()}');
    final notificationData = message.notification;
    if (notificationData != null) {
      // Display a local notification using the service
    _localNotificationsService?.showNotification(
      notificationData.title,
      notificationData.body,
      jsonEncode(message.data),
    );
    }
  }

  /// Handles notification taps when app is opened from the background or terminated state
void _onMessageOpenedApp(RemoteMessage message) {
  print('Notification tapped: ${message.data}');
  final route = message.data['route'];
  if (route != null) {
    switch (route) {
      case "/streak":
        Get.toNamed("/streakScreen", arguments: message.data);
        break;
      case "/reengage":
        Get.toNamed("/");
        break;
      default:
        Get.toNamed("/");
    }
  }
}

}

/// Background message handler (must be top-level function or static)
/// Handles messages when the app is fully terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.data.toString()}');
}