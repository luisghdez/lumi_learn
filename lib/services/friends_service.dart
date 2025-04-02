// services/friends_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lumi_learn_app/models/friends_model.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/models/userSearch_model.dart';

class FriendsService {
  final String baseUrl = 'https://lumi-api-e2zy.onrender.com';

  /// Fetch accepted friends for current user
  Future<List<Friend>> fetchFriends() async {
    final token = await AuthController.instance.getIdToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse('$baseUrl/friends'),
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
  Future<List<UserSearchResult>> searchUsers(String query) async {
    final token = await AuthController.instance.getIdToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse('$baseUrl/friend-requests/search?q=$query'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['users'];
      return data.map((json) => UserSearchResult.fromJson(json)).toList(); // ✅ fixed here
    } else {
      throw Exception("Search failed: ${response.body}");
    }
  }

  /// Send friend request
  Future<void> sendFriendRequest(String recipientId) async {
    final token = await AuthController.instance.getIdToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.post(
      Uri.parse('$baseUrl/friend-requests'),
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
  Future<void> respondToRequest(String requestId, bool accept) async {
    final token = await AuthController.instance.getIdToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.patch(
      Uri.parse('$baseUrl/friend-requests/$requestId?accept=$accept'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to respond to request: ${response.body}");
    }
  }

  /// Get friend requests (sent and received)
  Future<Map<String, List<Friend>>> getFriendRequests() async {
    final token = await AuthController.instance.getIdToken();
    if (token == null) throw Exception("User not authenticated");

    final response = await http.get(
      Uri.parse('$baseUrl/friend-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final sent = (data['sent'] as List).map((f) => Friend.fromJson(f)).toList();
      final received = (data['received'] as List).map((f) => Friend.fromJson(f)).toList();

      return {'sent': sent, 'received': received};
    } else {
      throw Exception("Failed to load friend requests: ${response.body}");
    }
  }
}
