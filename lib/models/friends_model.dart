class Friend {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;
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
    this.points,
    this.dayStreak,
    this.totalXP,
    this.top3Finishes,
    this.goldLeagueWeeks,
    this.joinedDate,
    this.friendCount,
  });

factory Friend.fromJson(Map<String, dynamic> json) {
  return Friend(
    id: json['id'],
    name: json['name'] ?? 'Unknown',
    email: json['email'] ?? '',
    avatarUrl: json['avatarUrl'] ?? 'assets/pfp/pfp1.png',
    points: json['points'] ?? 0,
    dayStreak: json['dayStreak'] ?? 0,
    totalXP: json['totalXP'] ?? 0,
    top3Finishes: json['top3Finishes'] ?? 0,
    goldLeagueWeeks: json['goldLeagueWeeks'] ?? 0,
    joinedDate: json['joinedDate'] ?? '',
    friendCount: json['friendCount'] ?? 0,
  );
}


  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'points': points,
        'dayStreak': dayStreak,
        'totalXP': totalXP,
        'top3Finishes': top3Finishes,
        'goldLeagueWeeks': goldLeagueWeeks,
        'joinedDate': joinedDate,
        'friendCount': friendCount,
      };
}
