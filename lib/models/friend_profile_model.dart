import 'package:intl/intl.dart'; // Optional, if you want custom formatting

class FriendProfileModel {
  final String id;
  final int courseSlotsUsed;
  final String createdAt;
  final String email;
  final String emailLower;
  final String lastCheckIn;
  final String name;
  final String nameLower;
  final String profilePicture;
  final int streakCount;
  final int xpCount;
  final int friendCount;

  FriendProfileModel({
    required this.id,
    required this.courseSlotsUsed,
    required this.createdAt,
    required this.email,
    required this.emailLower,
    required this.lastCheckIn,
    required this.name,
    required this.nameLower,
    required this.profilePicture,
    required this.streakCount,
    required this.xpCount,
    required this.friendCount,
  });

  factory FriendProfileModel.fromJson(Map<String, dynamic> json) {
    // Handle the "lastCheckIn" field, which might be a Firestore Timestamp-like map.
    final dynamic rawLastCheckIn = json['lastCheckIn'];
    String lastCheckInStr = '';

    if (rawLastCheckIn is Map<String, dynamic>) {
      // If it's a Firestore timestamp object with _seconds, _nanoseconds
      final int seconds = rawLastCheckIn['_seconds'] ?? 0;
      final int nanos = rawLastCheckIn['_nanoseconds'] ?? 0;

      // Convert to milliseconds
      final int milliseconds = (seconds * 1000) + (nanos ~/ 1000000);
      final DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(milliseconds);

      // Convert DateTime to a string (ISO8601). Adjust formatting as desired.
      lastCheckInStr = dateTime.toIso8601String();
      // Or for a custom format:
      // lastCheckInStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } else if (rawLastCheckIn is String) {
      // If the API does return a string for lastCheckIn, just use it directly.
      lastCheckInStr = rawLastCheckIn;
    }

    return FriendProfileModel(
      id: json['id']?.toString() ?? '',
      courseSlotsUsed: json['courseSlotsUsed'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      email: json['email'] ?? '',
      emailLower: json['emailLower'] ?? '',
      lastCheckIn: lastCheckInStr,
      name: json['name'] ?? '',
      nameLower: json['nameLower'] ?? '',
      profilePicture: json['profilePicture'] ?? 'default',
      streakCount: json['streakCount'] ?? 0,
      xpCount: json['xpCount'] ?? 0,
      friendCount: json['friendCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseSlotsUsed': courseSlotsUsed,
      'createdAt': createdAt,
      'email': email,
      'emailLower': emailLower,
      'lastCheckIn': lastCheckIn,
      'name': name,
      'nameLower': nameLower,
      'profilePicture': profilePicture,
      'streakCount': streakCount,
      'xpCount': xpCount,
      'friendCount': friendCount,
    };
  }
}
