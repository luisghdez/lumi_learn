import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:path/path.dart' as p;
import 'package:lumi_learn_app/application/models/leaderboard_model.dart';
import 'package:lumi_learn_app/application/services/api_config.dart';

class ApiService {
  static String get _baseUrl => ApiConfig.origin;

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
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (subject != null && subject.isNotEmpty && subject != 'all') {
      queryParameters['subject'] = subject;
    }

    final uri = Uri.parse('$_baseUrl/courses').replace(
      queryParameters: queryParameters,
    );
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
    debugPrint("getting featured courses");
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
    debugPrint(
        "getting all courses${subject != null ? ' for subject: $subject' : ''} (page: $page, limit: $limit)");

    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (subject != null && subject.isNotEmpty && subject != 'all') {
      queryParameters['subject'] = subject;
    }

    final uri = Uri.parse('$_baseUrl/courses/all').replace(
      queryParameters: queryParameters,
    );
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
    debugPrint("response.body: ${response.body}");
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

  Future<http.Response> deleteSavedCourse({
    required String token,
    required String courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/saved-courses/$courseId');
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  static Future<void> ensureUserExists(String? idToken,
      {String? email,
      String? name,
      String? profilePicture,
      String? timezone}) async {
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
        "timezone": timezone,
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

  Future<http.Response> getUserVideos({
    required String token,
    required String userId,
    String? cursor,
    int limit = 30,
  }) {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };
    final uri = Uri.parse("$_baseUrl/users/$userId/videos").replace(
      queryParameters: queryParameters,
    );

    return http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  /// Saved courses for another user (same response shape as [getCourses]).
  ///
  /// **Backend:** `GET /users/:userId/courses?page=&limit=&subject=`
  /// Return `{ "courses": [...], "pagination": { ... } }` like `GET /courses`.
  /// Only include courses the authenticated viewer is allowed to see.
  Future<http.Response> getUserSavedCourses({
    required String token,
    required String userId,
    int page = 1,
    int limit = 10,
    String? subject,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (subject != null && subject.isNotEmpty && subject != 'all') {
      queryParameters['subject'] = subject;
    }
    final uri = Uri.parse('$_baseUrl/users/$userId/courses').replace(
      queryParameters: queryParameters,
    );
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// Public friends list for a user (same response shape as friends index).
  ///
  /// **Backend:** `GET /users/:userId/friends?order=xp`
  /// Return `{ "friends": [ ... ] }` with the same item shape as `GET /friends`.
  ///
  /// **Remove friendship:** app calls `DELETE /friends/:friendUserId` (see
  /// [FriendsService.removeFriend]).
  ///
  /// **Video share links:** the app shares `https://www.lumilearnapp.com/video/:videoId`.
  /// Backend / universal links should open the feed (or clip) for that id.
  Future<http.Response> getUserFriends({
    required String token,
    required String userId,
    String order = 'xp',
  }) {
    final uri = Uri.parse('$_baseUrl/users/$userId/friends').replace(
      queryParameters: {'order': order},
    );
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
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
    await http.patch(
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

  static Future<void> updateUserTimezone(String token, String timezone) async {
    final uri = Uri.parse('$_baseUrl/users/me');
    await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'timezone': timezone,
      }),
    );
  }

  static Future<void> updateOnboardingStatus(
      String token, bool hasCompletedOnboarding) async {
    final uri = Uri.parse('$_baseUrl/users/me');
    await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'hasCompletedOnboarding': hasCompletedOnboarding,
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

  Future<http.Response> createVideo({
    required String token,
    required String mimeType,
    required String subject,
    String? thumbnailMimeType,
    String? caption,
    String visibility = 'public',
    String contentKind = 'video',
    int? slideCount,
    int? defaultSlideDurationMs,
    List<String>? slideMimeTypes,
  }) {
    final uri = Uri.parse('$_baseUrl/videos');
    return http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mimeType': mimeType,
        'caption': caption,
        'subject': subject,
        if (thumbnailMimeType != null) 'thumbnailMimeType': thumbnailMimeType,
        'visibility': visibility,
        if (contentKind != 'video') 'contentKind': contentKind,
        if (slideCount != null) 'slideCount': slideCount,
        if (defaultSlideDurationMs != null)
          'defaultSlideDurationMs': defaultSlideDurationMs,
        if (slideMimeTypes != null) 'slideMimeTypes': slideMimeTypes,
      }),
    );
  }

  Future<http.Response> uploadVideoFileToSignedUrl({
    required String uploadUrl,
    required File file,
    required String mimeType,
  }) async {
    final uri = Uri.parse(uploadUrl);
    final bytes = await file.readAsBytes();
    return http.put(
      uri,
      headers: {
        'Content-Type': mimeType,
      },
      body: bytes,
    );
  }

  Future<http.Response> uploadBytesToSignedUrl({
    required String uploadUrl,
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final uri = Uri.parse(uploadUrl);
    return http.put(
      uri,
      headers: {
        'Content-Type': mimeType,
      },
      body: bytes,
    );
  }

  Future<http.Response> completeVideoUpload({
    required String token,
    required String videoId,
    int? durationMs,
    String? thumbnailUrl,
    List<Map<String, dynamic>>? slides,
  }) {
    final uri = Uri.parse('$_baseUrl/videos/$videoId/complete');
    return http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (durationMs != null) 'durationMs': durationMs,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        if (slides != null && slides.isNotEmpty) 'slides': slides,
      }),
    );
  }

  Future<http.Response> getVideoFeed({
    required String token,
    String? cursor,
    int limit = 20,
    /// Optional; server may ignore until supported.
    String? subject,
    /// Optional; server may ignore until supported.
    bool? friendsOnly,
  }) {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      if (subject != null && subject.trim().isNotEmpty)
        'subject': subject.trim(),
      if (friendsOnly == true) 'friendsOnly': 'true',
    };
    final uri = Uri.parse('$_baseUrl/videos/feed').replace(
      queryParameters: queryParameters,
    );
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> getVideoById({
    required String token,
    required String videoId,
  }) {
    final uri = Uri.parse('$_baseUrl/videos/$videoId');
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> deleteVideo({
    required String token,
    required String videoId,
  }) {
    final uri = Uri.parse('$_baseUrl/videos/$videoId');
    return http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> likeVideo({
    required String token,
    required String videoId,
  }) {
    final uri = Uri.parse('$_baseUrl/videos/$videoId/like');
    return http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> unlikeVideo({
    required String token,
    required String videoId,
  }) {
    final uri = Uri.parse('$_baseUrl/videos/$videoId/like');
    return http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> getVideoComments({
    required String token,
    required String videoId,
    String? cursor,
    int limit = 20,
  }) {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };
    final uri = Uri.parse('$_baseUrl/videos/$videoId/comments').replace(
      queryParameters: queryParameters,
    );
    return http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// Create a top-level comment or a reply. Optional [parentCommentId] for replies.
  ///
  /// **Backend:** `POST /videos/:videoId/comments` body
  /// `{ "text": string, "parentCommentId"?: string }`.
  Future<http.Response> createVideoComment({
    required String token,
    required String videoId,
    required String text,
    String? parentCommentId,
  }) {
    final uri = Uri.parse('$_baseUrl/videos/$videoId/comments');
    final body = <String, dynamic>{'text': text};
    if (parentCommentId != null && parentCommentId.isNotEmpty) {
      body['parentCommentId'] = parentCommentId;
    }
    return http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  /// **Backend:** `POST /videos/:videoId/comments/:commentId/like` — returns
  /// `{ "likeCount": number, "liked": true }` (or full `comment` object).
  Future<http.Response> likeVideoComment({
    required String token,
    required String videoId,
    required String commentId,
  }) {
    final uri =
        Uri.parse('$_baseUrl/videos/$videoId/comments/$commentId/like');
    return http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{}),
    );
  }

  /// **Backend:** `DELETE /videos/:videoId/comments/:commentId/like` — same
  /// response shape as like. Send `{}` body if your stack requires JSON DELETE.
  Future<http.Response> unlikeVideoComment({
    required String token,
    required String videoId,
    required String commentId,
  }) {
    final uri =
        Uri.parse('$_baseUrl/videos/$videoId/comments/$commentId/like');
    return http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{}),
    );
  }

  Future<http.Response> deleteVideoComment({
    required String token,
    required String videoId,
    required String commentId,
  }) {
    final uri = Uri.parse('$_baseUrl/videos/$videoId/comments/$commentId');
    return http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
