/// FCM **data** payload keys and **type** values agreed between the Lumi Learn
/// Flutter client and the HTTP API / worker that sends Firebase messages.
///
/// Backend contract: `docs/PUSH_NOTIFICATIONS_API.md` in this repository.
abstract final class PushNotificationTypes {
  /// Another user sent a friend request to the recipient.
  static const String friendRequest = 'friend_request';

  /// Someone liked the recipient’s video.
  static const String videoLiked = 'video_liked';

  /// A user the recipient follows (friend) published a new video.
  static const String friendVideoPosted = 'friend_video_posted';
}

abstract final class PushDataKeys {
  static const String type = 'type';
  static const String actorName = 'actorName';
  static const String actorId = 'actorId';
  static const String videoId = 'videoId';
  static const String requestId = 'requestId';

  /// Legacy deep link (optional); see [PushNotificationNavigation.applyLegacyRoute].
  static const String route = 'route';
}
