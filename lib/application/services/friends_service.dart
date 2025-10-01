import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lumi_learn_app/application/models/friends_model.dart';
import 'package:lumi_learn_app/application/models/userSearch_model.dart';

class FriendsService {
  // final String _baseUrl = 'http://localhost:3000';
  static const String _baseUrl = 'https://lumi-api-e2zy.onrender.com';

  /// Fetch accepted friends for current user
  Future<List<Friend>> fetchFriends({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/friends?order=xp'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['friends'];
      return data.map((json) => Friend.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch friends: ${response.body}");
    }
  }

  /// Search users by name/email (GET /friend-requests/search?q=query)
  Future<List<UserSearchResult>> searchUsers({
    required String token,
    required String query,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/friend-requests/search?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['users'];
      return data.map((json) => UserSearchResult.fromJson(json)).toList();
    } else {
      throw Exception("Search failed: ${response.body}");
    }
  }

  /// Send friend request
  Future<void> sendFriendRequest({
    required String token,
    required String recipientId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/friend-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'recipientId': recipientId}),
    );

    if (response.statusCode != 201) {
      throw Exception("Friend request failed: ${response.body}");
    }
  }

  /// Accept or decline a friend request
  Future<void> respondToRequest({
    required String token,
    required String requestId,
    required bool accept,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/friend-requests/$requestId?accept=$accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}), // Empty body so Fastify doesn't throw
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to respond to request: ${response.body}");
    }
  }

  /// Get friend requests (sent and received)
  Future<Map<String, List<Friend>>> getFriendRequests({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/friend-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final sent =
          (data['sent'] as List).map((f) => Friend.fromJson(f)).toList();
      final received =
          (data['received'] as List).map((f) => Friend.fromJson(f)).toList();

      return {'sent': sent, 'received': received};
    } else {
      throw Exception("Failed to load friend requests: ${response.body}");
    }
  }
}
