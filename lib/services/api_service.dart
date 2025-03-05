import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class ApiService {
  static const String _baseUrl = 'http://localhost:3000';
  // Replace with your actual base URL or environment variable

  /// Create course with text fields and file uploads
  static Future<http.Response> createCourse({
    required String token, // Bearer token for auth
    required String title,
    required String description,
    required List<File> files, // List of file objects to upload
    required String content, // Additional text content field
  }) async {
    final url = Uri.parse('$_baseUrl/courses');

    // Create a multipart request
    final request = http.MultipartRequest('POST', url)
      // Add authorization header if needed
      ..headers['Authorization'] = 'Bearer $token'
      // Add text fields
      ..fields['title'] = title
      ..fields['description'] = description;

    // If there is content to include
    if (content.isNotEmpty) {
      request.fields['content'] = content;
    }

    // Attach each file as a multipart file
    for (final file in files) {
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: p.basename(file.path),
      );

      request.files.add(multipartFile);
    }

    // Send the request
    final streamedResponse = await request.send();
    // Convert streamed response into a regular Response object for easy handling
    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }
}
