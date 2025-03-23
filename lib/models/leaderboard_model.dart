class Player {
  final String name;
  final int points;
  final String avatar;

  Player({required this.name, required this.points, required this.avatar});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      points: json['points'],
      avatar: json['avatar'],
    );
  }
}
