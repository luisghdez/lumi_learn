import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lumi_learn_app/application/models/friends_model.dart';
import 'package:lumi_learn_app/application/models/userSearch_model.dart';
import 'package:lumi_learn_app/application/services/api_config.dart';

class FriendsService {
  String get _baseUrl => ApiConfig.origin;

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

  /// Remove an accepted friendship (current user unfriends [friendUserId]).
  ///
  /// **Backend:** `DELETE /friends/:friendUserId` with Bearer token — see
  /// project API notes. Expect `200` or `204` on success.
  Future<void> removeFriend({
    required String token,
    required String friendUserId,
  }) async {
    // Fastify rejects DELETE with `Content-Type: application/json` and no body.
    final response = await http.delete(
      Uri.parse('$_baseUrl/friends/$friendUserId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove friend: ${response.body}');
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

  /// Friends of another user (requires API route — see [ApiService.getUserFriends]).
  Future<List<Friend>> fetchFriendsOfUser({
    required String token,
    required String userId,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/$userId/friends?order=xp'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['friends'];
      return data
          .map((json) =>
              Friend.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    }
    throw Exception('Failed to load user friends: ${response.body}');
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
