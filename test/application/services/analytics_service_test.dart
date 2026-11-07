import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_learn_app/application/services/analytics_service.dart';

void main() {
  test('analytics properties exclude content and bound string values', () {
    final result = sanitizeAnalyticsProperties({
      'course_id': 'abc',
      'email': 'private@example.com',
      'raw_answer': 'private response',
      'file_path': '/private/file.pdf',
      'duration_ms': 123,
      'is_correct': true,
      'Bad Name': 'invalid',
      'error_code': 'x' * 120,
    });

    expect(result['course_id'], 'abc');
    expect(result['duration_ms'], 123);
    expect(result['is_correct'], 1);
    expect((result['error_code'] as String).length, 100);
    expect(result.containsKey('email'), false);
    expect(result.containsKey('raw_answer'), false);
    expect(result.containsKey('file_path'), false);
    expect(result.containsKey('Bad Name'), false);
  });
}
