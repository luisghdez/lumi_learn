import 'dart:async';
import 'dart:convert';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lumi_learn_app/application/controllers/ap_catalog_controller.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/models/question.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/dev_flags.dart';
import 'package:lumi_learn_app/data/assets_data.dart';
import 'package:lumi_learn_app/screens/ap_catalog/models/ap_subject.dart';

class TestAuth extends GetxController implements AuthController {
  @override
  final xpCount = 0.obs;
  @override
  final streakCount = 0.obs;
  @override
  Future<String?> getIdToken() async => 'qa-token';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestAnalytics extends FirebaseAnalyticsPlatform {
  final events = <String>[];
  @override
  FirebaseAnalyticsPlatform delegateFor({required FirebaseApp app, Map<String, dynamic>? webOptions}) => this;
  @override
  Future<void> logEvent({required String name, Map<String, Object?>? parameters, AnalyticsCallOptions? callOptions}) async {
    events.add(name);
  }
}

class TestAudio extends AudioplayersPlatformInterface {
  @override
  Future<void> create(String playerId) async {}
  @override
  Stream<AudioEvent> getEventStream(String playerId) => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class TestGlobalAudio extends GlobalAudioplayersPlatformInterface {
  @override
  Future<void> init() async {}
  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class TestApi extends ApiService {
  int saveStatus = 201;
  int lessonStatus = 200;
  int saveCalls = 0;
  int completionCalls = 0;
  final attempts = <String>[];
  bool failCompletion = false;
  @override
  Future<http.Response> createSavedCourse({required String token, required String courseId}) async {
    saveCalls++;
    return http.Response(jsonEncode({'lessonCount': 1}), saveStatus);
  }
  @override
  Future<http.Response> getLessons({required String token, required String courseId}) async =>
      http.Response(jsonEncode({
        'lessons': [{
          'id': 'lesson2', 'completed': false,
          'multipleChoice': List.generate(7, (i) => {
            'questionText': 'Question $i', 'options': ['yes', 'no'], 'correctAnswer': 'yes',
          }),
          'flashcards': [{'term': 'term', 'definition': 'definition'}],
        }],
        'mergedFlashcards': [], 'summary': '',
      }), lessonStatus);
  @override
  Future<http.Response> completeLesson({required String token, required String courseId,
      required String lessonId, required int xp, required String lessonAttemptId,
      required int durationMs}) async {
    attempts.add(lessonAttemptId);
    if (failCompletion) throw http.ClientException('offline');
    return http.Response(jsonEncode({
      'xpAwarded': completionCalls++ == 0 ? 15 : 0,
      'wasPreviouslyCompleted': completionCalls > 1,
      'streakInfo': null,
    }), 200);
  }
}

class TestCourses extends CourseController {
  TestCourses(TestApi api) : super(apiService: api);
  // Avoid the production controller's background home requests in isolated tests.
  @override
  // ignore: must_call_super
  void onInit() {} // Tests drive the requests explicitly.
  @override
  void playLessonCompleteSound() {}
}

const subject = ApSubject(title: 'AP Biology', description: '', units: 1,
    subjectTag: 'Science', category: ApCategory.stem, accent: Colors.green, courseId: 'ap-bio');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final analytics = TestAnalytics();
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseAnalyticsPlatform.instance = analytics;
    AudioplayersPlatformInterface.instance = TestAudio();
    GlobalAudioplayersPlatformInterface.instance = TestGlobalAudio();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/firebase_analytics'), (_) async => null)
      ..setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/firebase_crashlytics'), (_) async => null);
  });
  late TestApi api;
  late TestAuth auth;
  late CourseController courses;
  setUp(() {
    analytics.events.clear();
    Get.testMode = true;
    auth = TestAuth();
    Get.put<AuthController>(auth);
    api = TestApi();
    courses = TestCourses(api);
    Get.put<CourseController>(courses);
  });
  tearDown(() { Get.reset(); });

  test('normal builds do not force returning users through onboarding', () {
    expect(DevFlags.forceOnboardingPreview, false);
  });

  test('save, load, quick lesson, and completion preserve IDs and award XP once', () async {
    expect(await courses.saveSharedCourse(subject.courseId, subject.title), true);
    expect(courses.courses.single['id'], subject.courseId);
    expect(await courses.setSelectedCourseId(subject.courseId, subject.title), true);
    courses.setActiveLessonIndex(0);
    courses.loadQuestions(quickStart: true);
    expect(courses.computedQuestions.length, 5);
    expect(courses.computedQuestions.any((q) => q.lessonType == LessonType.speakAll), false);
    final attempt = courses.lessonAttemptId;
    expect(await courses.completeCurrentLesson(), isNotNull);
    expect(auth.xpCount.value, 15);
    expect(courses.lessons.single['completed'], true);
    expect(await courses.completeCurrentLesson(), isNotNull);
    expect(auth.xpCount.value, 15);
    expect(api.attempts, [attempt, attempt]);
    expect(analytics.events, containsAll(['lesson_started', 'question_viewed', 'lesson_completed_client']));
  });

  test('failed lesson load clears stale lessons and reports failure', () async {
    courses.lessons.assignAll([{'id': 'stale'}]);
    api.lessonStatus = 500;
    expect(await courses.setSelectedCourseId(subject.courseId, subject.title), false);
    expect(courses.lessons, isEmpty);
  });

  testWidgets('AP save failure leaves the learner on the current screen', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: Text('catalog'))));
    api.saveStatus = 500;
    final catalog = ApCatalogController();
    await catalog.startCourse(subject);
    await tester.pumpAndSettle();
    expect(find.text('catalog'), findsOneWidget);
    expect(courses.courses, isEmpty);
    expect(catalog.isStartingCourse.value, false);
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('failed completion preserves progress and retry uses the same attempt', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: Text('lesson'))));
    courses.selectedCourseId.value = subject.courseId;
    courses.lessons.assignAll([{'id': 'lesson2', 'completed': false}]);
    courses.setActiveLessonIndex(0);
    api.failCompletion = true;
    expect(await courses.completeCurrentLesson(), isNull);
    expect(courses.lessons.single['completed'], false);
    expect(auth.xpCount.value, 0);
    api.failCompletion = false;
    expect(await courses.completeCurrentLesson(), isNotNull);
    expect(api.attempts[0], api.attempts[1]);
    expect(auth.xpCount.value, 15);
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('victory is shown only after a failed save is successfully retried', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: Text('lesson'))));
    courses.selectedCourseId.value = subject.courseId;
    courses.lessons.assignAll([{'id': 'lesson2', 'completed': false}]);
    courses.setActiveLessonIndex(0);
    courses.setActivePlanet(planets.first);
    courses.computedQuestions.assignAll([
      Question(questionText: 'Done', options: [], lessonType: LessonType.multipleChoice),
    ]);
    api.failCompletion = true;
    courses.nextQuestion();
    await tester.pumpAndSettle();
    expect(find.text('Progress not saved'), findsOneWidget);
    expect(find.text('Great Job'), findsNothing);
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    api.failCompletion = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Great Job'), findsOneWidget);
    expect(api.attempts[0], api.attempts[1]);
    expect(auth.xpCount.value, 15);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
