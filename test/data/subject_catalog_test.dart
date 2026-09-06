import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_learn_app/data/subject_catalog.dart';

void main() {
  test('onboarding subject catalog contains only AP subjects', () {
    final subjects = apSubjectCatalog.expand((category) => category.subjects);

    expect(subjects, isNotEmpty);
    expect(subjects.every((subject) => subject.startsWith('AP ')), isTrue);
    expect(
      apSubjectCatalog.every((category) => category.subjects.isNotEmpty),
      isTrue,
    );
  });
}
