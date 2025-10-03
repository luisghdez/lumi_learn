import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:lumi_learn_app/application/models/leaderboard_model.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000';
  //LOCAL
  // static const String _baseUrl = 'http://localhost:3000';
  //DEV
  // static const String _baseUrl = 'https://lumi-api-dev.onrender.com';
  //PROD
  // static const String _baseUrl = 'https://lumi-api-e2zy.onrender.com';

  Future<http.Response> createCourse({
    required String token,
    required List<File> files,
    required String content,
    required String language,
    required String visibility,
    String? classId,
    DateTime? dueDate,
  }) async {
    final uri = Uri.parse('$_baseUrl/courses');
    var request = http.MultipartRequest('POST', uri);

    // Set the auth header
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields
    request.fields['content'] = content;
    request.fields['language'] = language;
    request.fields['visibility'] = visibility;

    if (classId != null) {
      request.fields['classId'] = classId;
    }
    if (dueDate != null) {
      // send in ISO 8601 or whatever your backend expects
      request.fields['dueDate'] = dueDate.toIso8601String();
    }

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
    int page = 1,
    int limit = 10,
    String? subject,
  }) async {
    String url = '$_baseUrl/courses?page=$page&limit=$limit';
    if (subject != null && subject.isNotEmpty && subject != 'all') {
      url += '&subject=$subject';
    }

    final uri = Uri.parse(url);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> getFeaturedCourses({
    required String token,
  }) async {
    print("getting featured courses");
    final uri = Uri.parse('$_baseUrl/courses/featured');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> getAllCourses({
    required String token,
    String? subject,
    int page = 1,
    int limit = 10,
  }) async {
    print(
        "getting all courses${subject != null ? ' for subject: $subject' : ''} (page: $page, limit: $limit)");

    String url = '$_baseUrl/courses/all?page=$page&limit=$limit';
    if (subject != null && subject.isNotEmpty && subject != 'all') {
      url += '&subject=$subject';
    }

    final uri = Uri.parse(url);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  Future<http.Response> getCourseById({
    required String token,
    required String courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/courses/$courseId');
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
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

//leaderboard future

  static Future<List<Player>> fetchLeaderboard() async {
    final response =
        await http.get(Uri.parse('https://api.example.com/leaderboard'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Player.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load leaderboard");
    }
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

  Future<http.Response> createSavedCourse({
    required String token,
    required String courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/saved-courses');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'courseId': courseId,
      }),
    );
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

  static Future<http.Response> getUserData({
    required String token,
    required String userId,
  }) async {
    final url = Uri.parse("$_baseUrl/users/$userId");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to get user data: ${response.body}");
    }

    return response;
  }

  /// POST /review
  /// Process user explanation of terms and get guided AI feedback.
  Future<http.Response> submitReview({
    required String token,
    required String transcript,
    required String focusTerm,
    required String focusDefinition,
    required List<Map<String, dynamic>> terms,
    required int attemptNumber,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final uri = Uri.parse('$_baseUrl/review');
    final body = jsonEncode({
      'transcript': transcript,
      'focusTerm': focusTerm,
      'focusDefinition': focusDefinition,
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

  // update user profile picture
  static Future<void> updateUserProfilePicture(
      String token, int avatarId) async {
    final uri = Uri.parse('$_baseUrl/users/me');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        // Fastify controller expects `profilePicture` as a string
        'profilePicture': avatarId.toString(),
      }),
    );

    if (response.statusCode == 200) {
      // OK
      return;
    }

    // Try to parse error message from body
    String message = 'Unknown error';
    try {
      final Map<String, dynamic> payload = jsonDecode(response.body);
      message = payload['error'] ?? payload['message'] ?? message;
    } catch (_) {/* ignore parse errors */}
  }

  static Future<void> updateUserName(String token, String newName) async {
    final uri = Uri.parse('$_baseUrl/users/me');
    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': newName,
      }),
    );
  }

  static Future<void> deleteUserData(String token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user data: ${response.body}');
    }
  }

  // GET /classes (teacher-owned)
  Future<http.Response> getClasses({required String token}) =>
      http.get(Uri.parse('$_baseUrl/classes'),
          headers: {'Authorization': 'Bearer $token'});

// GET /classes/submissions
  Future<http.Response> getAllClassSubmissions({required String token}) =>
      http.get(Uri.parse('$_baseUrl/classes/submissions'),
          headers: {'Authorization': 'Bearer $token'});

// GET /class/:id/courses
  Future<http.Response> getClassCourses(
          {required String token, required String classId}) =>
      http.get(Uri.parse('$_baseUrl/class/$classId/courses'),
          headers: {'Authorization': 'Bearer $token'});

// GET /class/:id/students
  Future<http.Response> getClassStudents(
          {required String token, required String classId}) =>
      http.get(Uri.parse('$_baseUrl/class/$classId/students'),
          headers: {'Authorization': 'Bearer $token'});

// GET /class/:id/progress
  // Future<http.Response> getClassProgress(
  //         {required String token, required String classId}) =>
  //     http.get(Uri.parse('$_baseUrl/class/$classId/progress'),
  //         headers: {'Authorization': 'Bearer $token'});

  Future<http.Response> createClassroom({
    required String token,
    required String name,
    required String identifier,
    required String colorCode,
  }) {
    final uri = Uri.parse('$_baseUrl/class');
    return http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'identifier': identifier,
        'colorCode': colorCode,
      }),
    );
  }

  Future<http.Response> getStudentClasses({required String token}) {
    final uri = Uri.parse('$_baseUrl/student/classes');
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> joinClass({
    required String token,
    required String code,
  }) {
    final uri = Uri.parse('$_baseUrl/class/join');
    return http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'code': code}),
    );
  }

  Future<http.Response> getUpcomingAssignments({required String token}) {
    final uri = Uri.parse('$_baseUrl/assignments/upcoming');
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
