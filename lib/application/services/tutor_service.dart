import 'dart:async';
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
}
