import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:path/path.dart' as p;
import 'dart:io';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000';

  Future<http.Response> createCourse({
    required String token,
    required String title,
    required String description,
    required List<File> files,
    required String content,
  }) async {
    final uri = Uri.parse('$_baseUrl/courses');
    var request = http.MultipartRequest('POST', uri);

    // Set the auth header
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['content'] = content;

    // Add files with automatic MIME detection
    for (File file in files) {
      // Determine MIME type based on file extension or file content
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final mimeTypeSplit = mimeType.split('/');

      final multipartFile = await http.MultipartFile.fromPath(
        'file', // the field name, adjust if needed
        file.path,
        filename: p.basename(file.path),
        contentType: MediaType(mimeTypeSplit[0], mimeTypeSplit[1]),
      );

      request.files.add(multipartFile);
    }

    // Send the request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  Future<http.Response> getCourses({
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/courses');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> getLessons({
    required String token,
    required String courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/courses/$courseId/lessons');
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> completeLesson({
    required String token,
    required String courseId,
    required String lessonId,
    required int xp,
  }) async {
    final uri = Uri.parse(
        '$_baseUrl/saved-courses/$courseId/lessons/$lessonId/complete');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'xp': xp,
      }),
    );
    print("response.body: ${response.body}");
    return response;
  }

  static Future<void> ensureUserExists(String? idToken,
      {String? email, String? name, String? profilePicture}) async {
    if (idToken == null) {
      throw Exception("ID token is null, cannot ensure user exists");
    }
    final url = Uri.parse("$_baseUrl/users/me");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken", // Send the token to your backend
      },
      body: jsonEncode({
        "email": email,
        "name": name,
        "profilePicture": profilePicture,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to ensure user exists: ${response.body}");
    }
  }

  /// POST /review
  /// Process user explanation of terms and get guided AI feedback.
  Future<http.Response> submitReview({
    required String token,
    required String transcript,
    required List<Map<String, String>> terms,
    required int attemptNumber,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final uri = Uri.parse('$_baseUrl/review');
    final body = jsonEncode({
      'transcript': transcript,
      'terms': terms,
      'attemptNumber': attemptNumber,
      'conversationHistory': conversationHistory ?? [],
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    return response;
  }

  /// GET /review/audio?sessionId=abc123-session-id
  /// Retrieve the TTS audio for the AI feedback associated with a previous review session.
  Future<http.Response> getReviewAudio({
    required String token,
    required String sessionId,
  }) async {
    final uri = Uri.parse('$_baseUrl/review/audio?sessionId=$sessionId');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  }
}
