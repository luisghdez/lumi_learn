class UserSearchResult {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;

  UserSearchResult({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
