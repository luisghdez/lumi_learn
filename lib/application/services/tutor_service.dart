import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TutorService {
  //LOCAL
  static const String _baseUrl = 'http://localhost:3000';
  //DEV
  // static const String _baseUrl = 'https://lumi-api-dev.onrender.com';
  //PROD
  // static const String _baseUrl = 'https://lumi-api-e2zy.onrender.com';

  Future<http.Response> getThreads({
    required String token,
    int? limit,
    String? cursor,
    String? lastDoc,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (cursor != null) queryParams['cursor'] = cursor;
    if (lastDoc != null) queryParams['lastDoc'] = lastDoc;

    final uri =
        Uri.parse('$_baseUrl/threads').replace(queryParameters: queryParams);
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
    int? limit,
    String? cursor,
    String? lastDoc,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (cursor != null) queryParams['cursor'] = cursor;
    if (lastDoc != null) queryParams['lastDoc'] = lastDoc;

    final uri = Uri.parse('$_baseUrl/threads/$threadId/messages')
        .replace(queryParameters: queryParams);
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
    String? courseId,
  }) async {
    final uri = Uri.parse('$_baseUrl/threads/$threadId/messages');
    final Map<String, dynamic> payload = {
      'message': message,
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

  /// GET /courses/:courseId/messages
  /// Returns the messages for the tutor thread associated with the given course.
  /// If no thread exists yet, the backend should return 404.
  Future<http.Response> getCourseMessages({
    required String token,
    required String courseId,
    int? limit,
    String? cursor,
    String? lastDoc,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (cursor != null) queryParams['cursor'] = cursor;
    if (lastDoc != null) queryParams['lastDoc'] = lastDoc;

    final uri = Uri.parse('$_baseUrl/courses/$courseId/messages')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response;
  }

  /// Streaming version of sendMessage that reads NDJSON lines and emits
  /// each parsed JSON object as a map on the returned Stream.
  Stream<Map<String, dynamic>> sendMessageStream({
    required String token,
    required String threadId,
    required String message,
    String? courseId,
  }) {
    final uri = Uri.parse('$_baseUrl/threads/$threadId/messages');
    final client = http.Client();
    final request = http.Request('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/x-ndjson',
    });
    final Map<String, dynamic> payload = {
      'message': message,
    };
    if (courseId != null && courseId.isNotEmpty) {
      payload['courseId'] = courseId;
    }
    request.body = jsonEncode(payload);

    final controller = StreamController<Map<String, dynamic>>();

    client.send(request).then((streamedResponse) {
      // Non-200: surface as an error-type event and close
      if (streamedResponse.statusCode != 200) {
        controller.add({
          'type': 'http_error',
          'status': streamedResponse.statusCode,
        });
        controller.close();
        client.close();
        return;
      }

      streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.trim().isEmpty) return;
        try {
          final Map<String, dynamic> obj = jsonDecode(line);
          controller.add(obj);
        } catch (_) {
          // ignore malformed lines
        }
      }, onError: (error) {
        controller.add({'type': 'error', 'error': error.toString()});
        controller.close();
        client.close();
      }, onDone: () {
        controller.close();
        client.close();
      });
    }).catchError((error) {
      controller.add({'type': 'error', 'error': error.toString()});
      controller.close();
      client.close();
    });

    return controller.stream;
  }

  /// Streaming version of createThread that reads NDJSON lines and emits
  /// each parsed JSON object as a map on the returned Stream.
  Stream<Map<String, dynamic>> createThreadStream({
    required String token,
    required String initialMessage,
    String? courseId,
  }) {
    final uri = Uri.parse('$_baseUrl/threads');
    final client = http.Client();
    final request = http.Request('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/x-ndjson',
    });
    final Map<String, dynamic> payload = {
      'initialMessage': initialMessage,
    };
    if (courseId != null && courseId.isNotEmpty) {
      payload['courseId'] = courseId;
    }
    request.body = jsonEncode(payload);

    final controller = StreamController<Map<String, dynamic>>();

    client.send(request).then((streamedResponse) {
      // Non-200: surface as an error-type event and close
      if (streamedResponse.statusCode != 200) {
        controller.add({
          'type': 'http_error',
          'status': streamedResponse.statusCode,
        });
        controller.close();
        client.close();
        return;
      }

      streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.trim().isEmpty) return;
        try {
          final Map<String, dynamic> obj = jsonDecode(line);
          controller.add(obj);
        } catch (_) {
          // ignore malformed lines
        }
      }, onError: (error) {
        controller.add({'type': 'error', 'error': error.toString()});
        controller.close();
        client.close();
      }, onDone: () {
        controller.close();
        client.close();
      });
    }).catchError((error) {
      controller.add({'type': 'error', 'error': error.toString()});
      controller.close();
      client.close();
    });

    return controller.stream;
  }

  /// Creates a new thread with an image input using streaming response
  Stream<Map<String, dynamic>> createImageThreadStream({
    required String token,
    required String imagePath,
  }) {
    final uri = Uri.parse('$_baseUrl/threads/image');
    final client = http.Client();

    final controller = StreamController<Map<String, dynamic>>();

    // Create multipart request for image upload
    _createImageMultipartRequest(uri, token, imagePath).then((request) {
      client.send(request).then((streamedResponse) async {
        // Non-200: surface as an error-type event and close
        if (streamedResponse.statusCode != 200) {
          // Read the response body to get error details
          final responseBody =
              await streamedResponse.stream.transform(utf8.decoder).join();

          controller.add({
            'type': 'http_error',
            'status': streamedResponse.statusCode,
            'body': responseBody,
          });
          controller.close();
          client.close();
          return;
        }

        streamedResponse.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (line) {
            if (line.trim().isNotEmpty) {
              try {
                final Map<String, dynamic> event = jsonDecode(line);
                controller.add(event);
              } catch (e) {
                controller.add({
                  'type': 'parse_error',
                  'error': e.toString(),
                });
              }
            }
          },
          onError: (error) {
            controller.add({
              'type': 'stream_error',
              'error': error.toString(),
            });
            controller.close();
            client.close();
          },
          onDone: () {
            controller.close();
            client.close();
          },
        );
      }).catchError((error) {
        controller.add({
          'type': 'request_error',
          'error': error.toString(),
        });
        controller.close();
        client.close();
      });
    }).catchError((error) {
      controller.add({
        'type': 'multipart_error',
        'error': error.toString(),
      });
      controller.close();
      client.close();
    });

    return controller.stream;
  }

  /// Helper method to create multipart request for image upload
  Future<http.MultipartRequest> _createImageMultipartRequest(
    Uri uri,
    String token,
    String imagePath,
  ) async {
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/x-ndjson',
    });

    // Add image file
    final imageFile = await http.MultipartFile.fromPath(
      'image',
      imagePath,
      contentType: MediaType('image', 'png'),
    );
    request.files.add(imageFile);

    return request;
  }
}
