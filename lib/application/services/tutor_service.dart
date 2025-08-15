import 'dart:convert';
import 'package:http/http.dart' as http;

class TutorService {
  static const String _baseUrl = 'http://localhost:3000';
  // static const String _baseUrl = 'https://lumi-api-e2zy.onrender.com';

  Future<http.Response> getThreads({
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/threads');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> createThread({
    required String token,
    required String initialMessage,
  }) async {
    final uri = Uri.parse('$_baseUrl/threads');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'initialMessage': initialMessage,
      }),
    );
    return response;
  }

  Future<http.Response> getThreadMessages({
    required String token,
    required String threadId,
  }) async {
    final uri = Uri.parse('$_baseUrl/threads/$threadId/messages');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> sendMessage({
    required String token,
    required String threadId,
    required String message,
  }) async {
    final uri = Uri.parse('$_baseUrl/threads/$threadId/messages');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': message,
      }),
    );
    return response;
  }
}
