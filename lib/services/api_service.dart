import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:mime/mime.dart'; // For lookupMimeType
import 'package:path/path.dart' as p;
import 'dart:io';
import 'dart:convert';
import 'package:lumi_learn_app/models/leaderboard_model.dart';


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


//leaderboard future

  static Future<List<Player>> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('https://api.example.com/leaderboard'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => Player.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load leaderboard");
    }
  }



}
