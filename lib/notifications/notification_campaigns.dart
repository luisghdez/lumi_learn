import 'firebase_messaging.dart';
import 'local_notifications.dart';

class NotificationCampaigns {
  // Singleton pattern
  NotificationCampaigns._internal();

  static final NotificationCampaigns _instance = NotificationCampaigns._internal();

  factory NotificationCampaigns.instance() => _instance;

  // Services
  final _messagingService = FirebaseMessagingService.instance();
  final _localNotificationsService = LocalNotificationsService.instance();

  /// Show a streak milestone notification
  Future<void> showStreakMilestoneNotification(int streakCount) async {
    if (streakCount == 1) {
      await _localNotificationsService.showNotification(
        "🔥 5-Day Streak!",
        "You're on fire! Keep the momentum going.",
        "streak_5",
      );
    } else if (streakCount == 10) {
      await _localNotificationsService.showNotification(
        "🎯 10-Day Streak!",
        "Consistency pays off — keep going strong.",
        "streak_10",
      );
    }
    // Add more milestones as needed
  }

  /// Show a re-engagement notification for inactive users
  Future<void> showReengagementNotification(int daysInactive) async {
    if (daysInactive >= 3 && daysInactive < 7) {
      await _localNotificationsService.showNotification(
        "👋 We miss you!",
        "Jump back into your course — just 5 minutes today makes a difference.",
        "reengage_3_days",
      );
    } else if (daysInactive >= 7) {
      await _localNotificationsService.showNotification(
        "📚 It's been a while...",
        "Let’s pick things up where you left off!",
        "reengage_7_days",
      );
    }
  }

  /// Show a study reminder at a set time (e.g., night)
  Future<void> showDailyReminder() async {
    await _localNotificationsService.showNotification(
      "⏰ Study Reminder",
      "Got 10 minutes before bed? Perfect for a quick session!",
      "daily_reminder",
    );
  }

  /// Show XP level up (future use)
  Future<void> showXPLevelUp(int newXp) async {
    await _localNotificationsService.showNotification(
      "🏆 Level Up!",
      "You've reached $newXp XP! Keep it up!",
      "xp_level_up",
    );
  }
}
