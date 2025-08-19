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
    String? courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/threads');
    final Map<String, dynamic> payload = {
      'initialMessage': initialMessage,
    };
    if (courseId != null && courseId.isNotEmpty) {
      payload['courseId'] = courseId;
    }
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
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

  /// GET /courses/:courseId/messages
  /// Returns the messages for the tutor thread associated with the given course.
  /// If no thread exists yet, the backend should return 404.
  Future<http.Response> getCourseMessages({
    required String token,
    required String courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/courses/$courseId/messages');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }
}
