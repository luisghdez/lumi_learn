// models/friends_model.dart

class Friend {
  final String id;
  final String name;
  final String avatarUrl;
  final int points;

  // Additional stats
  final int dayStreak;
  final int totalXP;
  final int top3Finishes;
  final int goldLeagueWeeks;
  final String joinedDate;
  final int friendCount;

  Friend({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.points,
    required this.dayStreak,
    required this.totalXP,
    required this.top3Finishes,
    required this.goldLeagueWeeks,
    required this.joinedDate,
    required this.friendCount,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      points: json['points'],
      dayStreak: json['dayStreak'],
      totalXP: json['totalXP'],
      top3Finishes: json['top3Finishes'],
      goldLeagueWeeks: json['goldLeagueWeeks'],
      joinedDate: json['joinedDate'],
      friendCount: json['friendCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
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
