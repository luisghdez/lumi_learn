class Friend {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final List<String>?
      userIds; // New field to capture user IDs in friend requests
  final int? points;
  final int? dayStreak;
  final int? totalXP;
  final int? top3Finishes;
  final int? goldLeagueWeeks;
  final String? joinedDate;
  final int? friendCount;

  Friend({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
    this.userIds,
    this.points,
    this.dayStreak,
    this.totalXP,
    this.top3Finishes,
    this.goldLeagueWeeks,
    this.joinedDate,
    this.friendCount,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    // If it's a friend request with nested user data, the backend might wrap it in keys like "sender" or "recipient"
    final bool isSentRequest = json.containsKey('recipient');
    final bool isReceivedRequest = json.containsKey('sender');
    final data = isSentRequest
        ? json['recipient']
        : isReceivedRequest
            ? json['sender']
            : json;

    // Extract the userIds directly from the top-level JSON (if available)
    List<String>? userIds;
    if (json.containsKey('userIds')) {
      userIds = List<String>.from(json['userIds']);
    }

    return Friend(
      id: data['id'],
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      avatarUrl: data['profilePicture'] ?? 'assets/pfp/pfp28.png',
      userIds: userIds,
      points: data['points'] ?? 0,
      dayStreak: data['dayStreak'] ?? 0,
      totalXP: data['xpCount'] ?? 0,
      top3Finishes: data['top3Finishes'] ?? 0,
      goldLeagueWeeks: data['goldLeagueWeeks'] ?? 0,
      joinedDate: data['joinedDate'] ?? '',
      friendCount: data['friendCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'userIds': userIds,
        'points': points,
        'dayStreak': dayStreak,
        'totalXP': totalXP,
        'top3Finishes': top3Finishes,
        'goldLeagueWeeks': goldLeagueWeeks,
        'joinedDate': joinedDate,
        'friendCount': friendCount,
      };
}
