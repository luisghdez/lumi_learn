import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lumi_learn_app/application/controllers/talk_lesson_controller.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/application/services/talk_to_lumi_realtime_service.dart';

Map<String, dynamic> progress(int index) => {
      'revision': index,
      'currentTermIndex': index,
      'complete': index == 3,
      'topics': List.generate(
          3,
          (i) => {
                'term': 'Topic $i',
                'definition': 'Definition $i',
                'score': i < index ? 100 : 0,
                'attempts': i < index ? 1 : 0,
                'status': i < index
                    ? 'mastered'
                    : i == index
                        ? 'active'
                        : 'pending'
              }),
    };

class FakeVoice extends TalkToLumiRealtimeService {
  final eventStream = StreamController<TalkRealtimeEvent>.broadcast();
  final stateStream = StreamController<TalkRealtimeConnectionState>.broadcast();
  int connects = 0, disconnects = 0, interrupts = 0;
  bool microphone = true;
  final List<String> replies = [];
  @override
  Stream<TalkRealtimeEvent> get events => eventStream.stream;
  @override
  Stream<TalkRealtimeConnectionState> get states => stateStream.stream;
  @override
  Future<TalkRealtimeSession> connect(
      {required String token,
      required String courseId,
      required String lessonId,
      bool continuous = false}) async {
    expect(continuous, true);
    connects++;
    return TalkRealtimeSession(
        attemptId: 'session',
        focusTerm: 'Topic 0',
        focusDefinition: 'Definition 0',
        progress: progress(0));
  }

  @override
  void setMicrophoneEnabled(bool enabled) {
    microphone = enabled;
  }

  @override
  Future<void> speakLessonReply(
      {required String instructions, required String replyText}) async {
    replies.add(replyText);
  }

  @override
  Future<void> interruptPlayback() async {
    interrupts++;
    eventStream.add(const TalkRealtimeEvent('output_audio_buffer.cleared'));
  }

  @override
  Future<void> disconnect() async {
    disconnects++;
  }

  @override
  Future<void> dispose() async {
    await eventStream.close();
    await stateStream.close();
    await super.dispose();
  }

  void turn(String id, String words) {
    eventStream.add(
        TalkRealtimeEvent('input_audio_buffer.speech_started', itemId: id));
    eventStream.add(TalkRealtimeEvent(
        'conversation.item.input_audio_transcription.completed',
        itemId: id,
        transcript: words));
  }
}

class FakeApi extends ApiService {
  final List<String> ids = [];
  final List<int> revisions = [];
  bool failOnce = false;
  Completer<http.Response>? pending;
  @override
  Future<http.Response> assessTalkLessonTurn(
      {required String token,
      required String attemptId,
      required String turnId,
      required String transcript,
      required int expectedRevision}) async {
    ids.add(turnId);
    revisions.add(expectedRevision);
    if (pending != null) return pending!.future;
    if (failOnce) {
      failOnce = false;
      return http.Response('{}', 503);
    }
    return http.Response(
        jsonEncode({
          'progress': progress(expectedRevision + 1),
          'kind': 'answer',
          'replyText': 'Saved topic ${expectedRevision + 1}',
          'instructions': 'Next topic ${expectedRevision + 1}'
        }),
        200);
  }
}

Future<void> flush() => Future<void>.delayed(const Duration(milliseconds: 20));
void main() {
  test('playback stays muted until interruption or playback end', () async {
    final voice = FakeVoice();
    final lesson = TalkLessonController(
        courseId: 'course',
        lessonId: 'lesson',
        tokenProvider: () async => 'token',
        api: FakeApi(),
        transport: voice);
    await lesson.start();
    voice.eventStream
        .add(const TalkRealtimeEvent('output_audio_buffer.started'));
    await flush();
    expect(voice.microphone, false);
    await lesson.interrupt();
    await flush();
    expect(voice.interrupts, 1);
    expect(voice.microphone, true);
    expect(voice.connects, 1);
    lesson.dispose();
  });
  test(
      'three answers progress on one connection and final audio drains before disconnect',
      () async {
    final voice = FakeVoice();
    final api = FakeApi();
    final lesson = TalkLessonController(
        courseId: 'course',
        lessonId: 'lesson',
        tokenProvider: () async => 'token',
        api: api,
        transport: voice);
    await lesson.start();
    expect(voice.microphone, false,
        reason: 'Do not capture the spoken greeting');
    voice.eventStream
        .add(const TalkRealtimeEvent('output_audio_buffer.started'));
    voice.eventStream
        .add(const TalkRealtimeEvent('output_audio_buffer.stopped'));
    await flush();
    expect(voice.microphone, true,
        reason: 'Listen automatically after playback');
    for (var i = 0; i < 3; i++) {
      voice.turn('turn-$i', 'An explanation');
      await flush();
      expect(lesson.progress!.reviewedCount, i + 1);
      expect(voice.connects, 1);
      expect(voice.disconnects, 0);
    }
    expect(api.revisions, [0, 1, 2]);
    expect(lesson.complete, true);
    expect(voice.microphone, false);
    voice.eventStream
        .add(const TalkRealtimeEvent('output_audio_buffer.stopped'));
    await flush();
    expect(voice.disconnects, 0,
        reason: 'An older reply cannot close final playback');
    voice.eventStream
        .add(const TalkRealtimeEvent('output_audio_buffer.started'));
    voice.eventStream
        .add(const TalkRealtimeEvent('output_audio_buffer.stopped'));
    await flush();
    expect(voice.disconnects, 1);
    expect(lesson.connected, false);
    lesson.dispose();
  });
  test(
      'duplicate final events cannot grade twice; failed request retries the same ID',
      () async {
    final voice = FakeVoice();
    final api = FakeApi()..failOnce = true;
    final lesson = TalkLessonController(
        courseId: 'course',
        lessonId: 'lesson',
        tokenProvider: () async => 'token',
        api: api,
        transport: voice);
    await lesson.start();
    voice.turn('same-turn', 'My explanation');
    await flush();
    voice.eventStream.add(const TalkRealtimeEvent(
        'conversation.item.input_audio_transcription.completed',
        itemId: 'same-turn',
        transcript: 'My explanation'));
    await flush();
    expect(api.ids, ['same-turn']);
    expect(lesson.progress!.revision, 0);
    await lesson.retryTurn();
    expect(api.ids, ['same-turn', 'same-turn']);
    expect(api.revisions, [0, 0]);
    expect(lesson.progress!.revision, 1);
    expect(voice.connects, 1);
    lesson.dispose();
  });
  test('late assessment after leaving cannot change progress or speak',
      () async {
    final voice = FakeVoice();
    final api = FakeApi()..pending = Completer<http.Response>();
    final lesson = TalkLessonController(
        courseId: 'course',
        lessonId: 'lesson',
        tokenProvider: () async => 'token',
        api: api,
        transport: voice);
    await lesson.start();
    voice.turn('late-turn', 'My explanation');
    await flush();
    await lesson.stop();
    api.pending!.complete(http.Response(
        jsonEncode({
          'progress': progress(1),
          'replyText': 'Late reply',
          'instructions': 'Next'
        }),
        200));
    await flush();
    expect(lesson.progress!.revision, 0);
    expect(voice.replies.length, 1);
    lesson.dispose();
  });
}
