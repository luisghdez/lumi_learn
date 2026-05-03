// lib/services/podcast_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // 👈 For File
import 'package:http_parser/http_parser.dart'; // 👈 For MediaType
import 'package:lumi_learn_app/application/models/podcast_model.dart';

class PodcastService {
  // static const String _baseUrl = 'https://lumi-api-e2zy.onrender.com';
  static const String _baseUrl = 'http://localhost:3000'; // For local development

  // Timeout durations
  static const Duration _standardTimeout = Duration(seconds: 30);
  static const Duration _generationTimeout = Duration(minutes: 5);

  

  /// Generate a new podcast from course content
  /// POST /podcasts
  Future<Map<String, dynamic>> createPodcast({
    required String token,
    required String courseId,
    required String title,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/podcasts'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'courseId': courseId,
              'title': title,
            }),
          )
          .timeout(_generationTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = _tryDecodeError(response.body);
        throw PodcastException(
          'Failed to create podcast',
          statusCode: response.statusCode,
          details: errorBody,
        );
      }
    } on http.ClientException catch (e) {
      throw PodcastException('Network error: ${e.message}');
    } catch (e) {
      if (e is PodcastException) rethrow;
      throw PodcastException('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> transcribeAudioQuestion(
    File audioFile, {
    required String token,
    required String courseId,
    required String segmentId,
  }) async {
    final uri = Uri.parse('$_baseUrl/podcasts/transcribe');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['courseId'] = courseId
      ..fields['segmentId'] = segmentId
      ..files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          contentType: MediaType('audio', 'aac'),
        ),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return json; // ✅ returns text + hostAudioUrl + hostResponse
    } else {
      throw PodcastException(
        'Failed to transcribe audio',
        statusCode: response.statusCode,
        details: responseBody,
      );
    }
  }




  /// Send a "call-in" interrupt question during a podcast
  /// POST /podcasts/interrupt
  Future<Map<String, dynamic>> sendCallInQuestion({
    required String token,
    required String courseId,
    required String segmentId,
    required String question,
  }) async {
    if (question.trim().isEmpty) {
      throw PodcastException('Question cannot be empty');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/podcasts/interrupt'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'courseId': courseId,
              'segmentId': segmentId,
              'userQuestion': question.trim(),
            }),
          )
          .timeout(_standardTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = _tryDecodeError(response.body);
        throw PodcastException(
          'Failed to send call-in question',
          statusCode: response.statusCode,
          details: errorBody,
        );
      }
    } on http.ClientException catch (e) {
      throw PodcastException('Network error: ${e.message}');
    } catch (e) {
      if (e is PodcastException) rethrow;
      throw PodcastException('Unexpected error: $e');
    }
  }

  /// Get podcast metadata for a course
  /// GET /podcasts/:courseId/metadata
  Future<PodcastMetadata?> getPodcastMetadata({
    required String token,
    required String courseId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/podcasts/$courseId/metadata'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_standardTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PodcastMetadata.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Podcast doesn't exist
      } else {
        final errorBody = _tryDecodeError(response.body);
        throw PodcastException(
          'Failed to get podcast metadata',
          statusCode: response.statusCode,
          details: errorBody,
        );
      }
    } on http.ClientException catch (e) {
      throw PodcastException('Network error: ${e.message}');
    } catch (e) {
      if (e is PodcastException) rethrow;
      throw PodcastException('Unexpected error: $e');
    }
  }

  /// Get all segments with dialogue for a podcast
  /// GET /podcasts/:courseId/segments
  /// 🆕 NOW PARSES: topic, examples, isStandalone
  Future<List<PodcastSegment>> getPodcastSegments({
    required String token,
    required String courseId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/podcasts/$courseId/segments'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_standardTimeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = decoded['segments'] as List<dynamic>;
        
        return data.map((segmentJson) {
          final segmentMap = segmentJson as Map<String, dynamic>;
          final List<dynamic> dialogueData = segmentMap['dialogue'] as List<dynamic>? ?? [];
          
          final dialogue = dialogueData.map((lineJson) {
            final lineMap = lineJson as Map<String, dynamic>;
            return PodcastLine(
              id: lineMap['id'] as String? ?? '',
              speaker: lineMap['speaker'] as String? ?? 'Host A',
              text: lineMap['text'] as String? ?? '',
              audioUrl: lineMap['audioUrl'] as String?,
              order: lineMap['order'] as int? ?? 0,
              isInterrupt: lineMap['isInterrupt'] as bool?,
              createdAt: lineMap['createdAt'] as String?,
            );
          }).toList();

          // 🆕 PARSE NEW FIELDS
          final List<dynamic>? examplesData = segmentMap['examples'] as List<dynamic>?;
          final List<String>? examples = examplesData?.map((e) => e.toString()).toList();

          return PodcastSegment(
            id: segmentMap['id'] as String? ?? '',
            order: segmentMap['order'] as int? ?? 0,
            duration: segmentMap['duration'] as int?,
            topic: segmentMap['topic'] as String?,              // 🆕 NEW
            examples: examples,                                   // 🆕 NEW
            isStandalone: segmentMap['isStandalone'] as bool?,  // 🆕 NEW
            dialogue: dialogue,
          );
        }).toList();
      } else {
        final errorBody = _tryDecodeError(response.body);
        throw PodcastException(
          'Failed to get podcast segments',
          statusCode: response.statusCode,
          details: errorBody,
        );
      }
    } on http.ClientException catch (e) {
      throw PodcastException('Network error: ${e.message}');
    } catch (e) {
      if (e is PodcastException) rethrow;
      throw PodcastException('Unexpected error: $e');
    }
  }

  /// Get a single segment with its dialogue
  /// GET /podcasts/:courseId/segments/:segmentId
  /// 🆕 NOW PARSES: topic, examples, isStandalone
  Future<PodcastSegment?> getPodcastSegment({
    required String token,
    required String courseId,
    required String segmentId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/podcasts/$courseId/segments/$segmentId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_standardTimeout);

      if (response.statusCode == 200) {
        final segmentMap = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> dialogueData = segmentMap['dialogue'] as List<dynamic>? ?? [];
        
        final dialogue = dialogueData.map((lineJson) {
          final lineMap = lineJson as Map<String, dynamic>;
          return PodcastLine(
            id: lineMap['id'] as String? ?? '',
            speaker: lineMap['speaker'] as String? ?? 'Host A',
            text: lineMap['text'] as String? ?? '',
            audioUrl: lineMap['audioUrl'] as String?,
            order: lineMap['order'] as int? ?? 0,
            isInterrupt: lineMap['isInterrupt'] as bool?,
            createdAt: lineMap['createdAt'] as String?,
          );
        }).toList();

        // 🆕 PARSE NEW FIELDS
        final List<dynamic>? examplesData = segmentMap['examples'] as List<dynamic>?;
        final List<String>? examples = examplesData?.map((e) => e.toString()).toList();

        return PodcastSegment(
          id: segmentMap['id'] as String? ?? '',
          order: segmentMap['order'] as int? ?? 0,
          duration: segmentMap['duration'] as int?,
          topic: segmentMap['topic'] as String?,              // 🆕 NEW
          examples: examples,                                   // 🆕 NEW
          isStandalone: segmentMap['isStandalone'] as bool?,  // 🆕 NEW
          dialogue: dialogue,
        );
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final errorBody = _tryDecodeError(response.body);
        throw PodcastException(
          'Failed to get podcast segment',
          statusCode: response.statusCode,
          details: errorBody,
        );
      }
    } on http.ClientException catch (e) {
      throw PodcastException('Network error: ${e.message}');
    } catch (e) {
      if (e is PodcastException) rethrow;
      throw PodcastException('Unexpected error: $e');
    }
  }

  /// Check if a podcast exists for a course
  /// GET /podcasts/:courseId/exists
  Future<bool> podcastExists({
    required String token,
    required String courseId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/podcasts/$courseId/exists'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_standardTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['exists'] as bool? ?? false;
      } else {
        // If endpoint doesn't exist, fallback to checking metadata
        final metadata = await getPodcastMetadata(
          token: token,
          courseId: courseId,
        );
        return metadata != null;
      }
    } catch (e) {
      print('Error checking podcast existence: $e');
      // Fallback to metadata check
      try {
        final metadata = await getPodcastMetadata(
          token: token,
          courseId: courseId,
        );
        return metadata != null;
      } catch (e2) {
        return false;
      }
    }
  }

  /// Get podcast interruptions/call-ins for a course
  /// GET /podcasts/:courseId/interruptions
  Future<List<Map<String, dynamic>>> getPodcastInterruptions({
    required String token,
    required String courseId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/podcasts/$courseId/interruptions'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_standardTimeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = decoded['interruptions'] as List<dynamic>? ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching interruptions: $e');
      return [];
    }
  }

  /// Helper: Try to decode error response
  String _tryDecodeError(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return decoded['error'] as String? ?? 
             decoded['message'] as String? ?? 
             body;
    } catch (e) {
      return body;
    }
  }


  Future<Map<String, dynamic>> createRealtimeSession({
  required String token,
  required String courseId,
  required String segmentId,
}) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/podcasts/realtime/session'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'courseId': courseId,
      'segmentId': segmentId,
    }),
  ).timeout(_standardTimeout);

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw PodcastException(
      'Failed to create realtime session',
      statusCode: response.statusCode,
      details: response.body,
    );
  }
}
}

/// Custom exception for podcast-related errors
class PodcastException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  PodcastException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode != null && details != null) {
      return 'PodcastException: $message (Status: $statusCode) - $details';
    } else if (statusCode != null) {
      return 'PodcastException: $message (Status: $statusCode)';
    }
    return 'PodcastException: $message';
  }
}




