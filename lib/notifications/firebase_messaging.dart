import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import 'package:lumi_learn_app/application/services/notif_service.dart';
import 'package:lumi_learn_app/firebase_options.dart';
import 'package:lumi_learn_app/notifications/local_notifications.dart';
import 'package:lumi_learn_app/notifications/push_notification_contract.dart';
import 'package:lumi_learn_app/notifications/push_notification_navigation.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();

  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationsService? _localNotificationsService;
  final NotifService _notifService = NotifService();

  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    _localNotificationsService = localNotificationsService;

    _handlePushNotificationsToken();
    await _requestPermission();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PendingPushNavigation.queue(
        Map<String, dynamic>.from(initialMessage.data),
      );
    }
  }

  Future<void> _handlePushNotificationsToken() async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await _notifService.sendFcmTokenToServer(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await _notifService.sendFcmTokenToServer(fcmToken);
    });
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Foreground: show a heads-up via local notifications. Uses FCM
  /// [RemoteMessage.notification] when present; otherwise builds copy from
  /// [RemoteMessage.data] using [PushNotificationTypes].
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final display = _resolveDisplay(message);
    if (display == null) return;

    await _localNotificationsService?.showNotification(
      display.$1,
      display.$2,
      jsonEncode(message.data),
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    PushNotificationNavigation.handleOpenedAppAsync(
      Map<String, dynamic>.from(message.data),
    );
  }
}

(String title, String body)? _resolveDisplay(RemoteMessage message) {
  final n = message.notification;
  final title = n?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return (title, n?.body?.trim() ?? '');
  }

  // Some marketing / streak pushes are data-only with `title` + `body` keys.
  final dataTitle = message.data['title']?.toString().trim();
  if (dataTitle != null && dataTitle.isNotEmpty) {
    return (dataTitle, message.data['body']?.toString().trim() ?? '');
  }

  final type = message.data[PushDataKeys.type]?.toString() ?? '';
  final actorRaw = message.data[PushDataKeys.actorName]?.toString().trim();
  final actor =
      (actorRaw != null && actorRaw.isNotEmpty) ? actorRaw : 'Someone';

  switch (type) {
    case PushNotificationTypes.friendRequest:
      return ('Friend request', '$actor wants to connect on Lumi.');
    case PushNotificationTypes.videoLiked:
      return ('New like', '$actor liked your video.');
    case PushNotificationTypes.friendVideoPosted:
      return ('Friend posted', '$actor shared a new video.');
    default:
      return null;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// When the payload includes FCM **`notification`**, the OS already shows
  /// the tray banner — do **not** mirror with a local notification (duplicate).
  /// Data-only / silent pushes: no banner here unless you add native logic.
}
