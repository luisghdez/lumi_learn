import 'package:get/get.dart';

import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/notifications/push_notification_contract.dart';
import 'package:lumi_learn_app/screens/social/screen/add_friends_screen.dart';

/// Cold start: [main] runs before [AuthGate] registers [VideoController] /
/// [FriendsController]. Queue the payload and call [flushAfterMainReady]
/// once the main shell is up.
abstract final class PendingPushNavigation {
  static Map<String, dynamic>? _queued;

  static void queue(Map<String, dynamic> raw) {
    if (raw.isEmpty) return;
    _queued = Map<String, dynamic>.from(raw);
  }

  static Future<void> flushAfterMainReady() async {
    final q = _queued;
    if (q == null) return;
    _queued = null;
    await PushNotificationNavigation.handleOpenedAppAsync(q);
  }
}

/// Maps FCM / local-notification payloads to in-app navigation.
abstract final class PushNotificationNavigation {
  static Map<String, String> stringifyData(Map<String, dynamic> raw) {
    return raw.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  }

  /// FCM notification opened (background / terminated). Waits until shell
  /// controllers exist.
  static Future<void> handleOpenedAppAsync(Map<String, dynamic> raw) async {
    final data = stringifyData(raw);
    await _waitForMainShell();
    apply(data);
  }

  /// Local notification tap (often foreground).
  static void handleTapFromPayload(Map<String, dynamic> raw) {
    final data = stringifyData(raw);
    _runTapNavigation(data);
  }

  static Future<void> _runTapNavigation(Map<String, String> data) async {
    await _waitForMainShell();
    apply(data);
  }

  static Future<void> _waitForMainShell() async {
    for (var i = 0; i < 50; i++) {
      if (Get.isRegistered<NavigationController>() &&
          Get.isRegistered<VideoController>() &&
          Get.isRegistered<FriendsController>()) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  static void apply(Map<String, String> data) {
    final type = data[PushDataKeys.type] ?? '';
    if (type.isEmpty) {
      applyLegacyRoute(data);
      return;
    }

    switch (type) {
      case PushNotificationTypes.friendRequest:
        _openFriendRequests();
        break;
      case PushNotificationTypes.videoLiked:
      case PushNotificationTypes.friendVideoPosted:
        _openFeedVideo(data[PushDataKeys.videoId] ?? '');
        break;
      default:
        applyLegacyRoute(data);
    }
  }

  static void applyLegacyRoute(Map<String, String> data) {
    final route = data[PushDataKeys.route];
    if (route == null || route.isEmpty) return;

    switch (route) {
      case '/streak':
        Get.toNamed('/streakScreen', arguments: data);
        break;
      case '/reengage':
        Get.offAllNamed('/');
        break;
      default:
        Get.offAllNamed('/');
    }
  }

  static void _openFriendRequests() {
    if (!Get.isRegistered<FriendsController>()) return;
    Get.to<void>(
      () => const AddFriendsScreen(initialTabIndex: 1),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  static void _openFeedVideo(String videoId) {
    if (videoId.isEmpty) return;
    if (!Get.isRegistered<VideoController>()) return;
    Get.find<VideoController>().openSharedVideoFromDeepLink(videoId);
  }
}
