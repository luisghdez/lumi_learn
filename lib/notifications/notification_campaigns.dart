import 'firebase_messaging.dart';
import 'local_notifications.dart';

class NotificationCampaigns {
  // Singleton
  NotificationCampaigns._internal();
  static final NotificationCampaigns _instance = NotificationCampaigns._internal();
  factory NotificationCampaigns.instance() => _instance;

  // Services
  final _messagingService = FirebaseMessagingService.instance(); // (not used yet, but fine to keep)
  final _localNotificationsService = LocalNotificationsService.instance();

  /// Schedule a streak milestone notification (default: 2 hours later)
  Future<void> scheduleStreakMilestoneNotification(
    int streakCount, {
    Duration delay = const Duration(hours: 2),
  }) async {
    String? title;
    String? body;
    final payload = 'streak_$streakCount';

    if (streakCount == 5) {
      title = 'Lumi is happy 5-Day Streak!';
      body  = "You're on fire! Keep the momentum going.";
    } else if (streakCount == 10) {
      title = 'Lumi is impressed 10-Day Streak!';
      body  = 'Consistency pays off — keep going strong.';
    } else if (streakCount == 20) {
      title = 'Lumi is blushing 20-Day Streak!';
      body  = "Amazing run — don't stop now.";
    } else if (streakCount == 30) {
      title = 'Lumi knows you are him 30-Day Streak!';
      body  = 'A full month! Legendary consistency.';
    }

    if (title != null && body != null) {
      if (delay.isNegative || delay.inSeconds == 0) return;
      await _localNotificationsService.scheduleNotification(
        delay: delay,
        title: title,
        body: body,
        payload: payload,
      );
    }
  }

  /// Remind the user they're about to lose their streak if they don't check in today.
  ///
  /// By default:
  ///   - deadline = tonight at local midnight
  ///   - warningBefore = 2 hours → schedules at 10 PM
/// Remind the user 22h after their last check-in (i.e., 2h before losing a 24h-based streak)
Future<void> scheduleStreakRiskReminderAfterLastCheckIn({
  required DateTime lastCheckIn,
  Duration after = const Duration(hours: 22),
}) async {
  final now = DateTime.now();
  final scheduled = lastCheckIn.add(after);

  if (scheduled.isAfter(now)) {
    final delay = scheduled.difference(now);
    if (delay.inSeconds <= 0) return;

    await _localNotificationsService.scheduleNotification(
      delay: delay,
      title: "⚠️ Don't lose your streak!",
      body: 'Check in within the next 2 hours to keep your streak alive 🔥',
      payload: 'streak_risk',
    );
  } else {
    // Too late to schedule based on lastCheckIn + 22h; skip (or choose to notify soon)
    // Example alternative if you prefer:
    // await _localNotificationsService.scheduleNotification(
    //   delay: const Duration(minutes: 1),
    //   title: "⚠️ Don't lose your streak!",
    //   body: 'You’re close to losing it — check in now 🔥',
    //   payload: 'streak_risk',
    // );
  }
}
}
