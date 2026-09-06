import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:lumi_learn_app/application/services/talk_to_lumi_realtime_service.dart';

class TalkTopicProgress {
  const TalkTopicProgress(
      {required this.term,
      required this.definition,
      required this.score,
      required this.attempts,
      required this.status});
  factory TalkTopicProgress.fromJson(Map<String, dynamic> json) =>
      TalkTopicProgress(
        term: json['term'] as String,
        definition: json['definition'] as String,
        score: (json['score'] as num).toInt(),
        attempts: (json['attempts'] as num).toInt(),
        status: json['status'] as String,
      );
  final String term, definition, status;
  final int score, attempts;
  bool get reviewed => status == 'mastered' || status == 'review_later';
}

class TalkLessonProgress {
  const TalkLessonProgress(
      {required this.revision,
      required this.currentTermIndex,
      required this.topics,
      required this.complete});
  factory TalkLessonProgress.fromJson(Map<String, dynamic> json) =>
      TalkLessonProgress(
        revision: (json['revision'] as num).toInt(),
        currentTermIndex: (json['currentTermIndex'] as num).toInt(),
        complete: json['complete'] as bool,
        topics: (json['topics'] as List)
            .map(
                (e) => TalkTopicProgress.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
  final int revision, currentTermIndex;
  final List<TalkTopicProgress> topics;
  final bool complete;
  int get reviewedCount => topics.where((topic) => topic.reviewed).length;
}

class _TalkTurn {
  const _TalkTurn(this.id, this.transcript, this.revision);
  final String id, transcript;
  final int revision;
}

/// One WebRTC connection, server-owned progression, and one idempotent request
/// per final learner turn. No UI/controller score is ever sent to the server.
class TalkLessonController extends ChangeNotifier {
  TalkLessonController(
      {required this.courseId,
      required this.lessonId,
      required this.tokenProvider,
      ApiService? api,
      TalkToLumiRealtimeService? transport})
      : _api = api ?? ApiService(),
        _transport = transport ?? TalkToLumiRealtimeService() {
    _eventSubscription = _transport.events.listen(_onEvent);
    _stateSubscription = _transport.states.listen((state) {
      if (_closed) return;
      if (state == TalkRealtimeConnectionState.disconnected &&
          connected &&
          !starting &&
          !complete) {
        connected = false;
        error =
            'The connection was lost. Reconnect to resume your saved progress.';
        _notify();
      }
    });
  }
  final String courseId, lessonId;
  final Future<String?> Function() tokenProvider;
  final ApiService _api;
  final TalkToLumiRealtimeService _transport;
  late final StreamSubscription<TalkRealtimeEvent> _eventSubscription;
  late final StreamSubscription<TalkRealtimeConnectionState> _stateSubscription;
  TalkRealtimeSession? _session;
  TalkLessonProgress? progress;
  bool starting = false,
      connected = false,
      assessing = false,
      speaking = false,
      paused = false,
      hearingSpeech = false;
  String caption = '', reply = '', feedback = '';
  String? error;
  bool _closed = false;
  bool _awaitingPlayback = false;
  bool _finalPlaybackStarted = false;
  int _generation = 0;
  final Map<String, int> _turnRevisions = {};
  final Map<String, String> _partialTurns = {};
  final Set<String> _handledTurns = {};
  _TalkTurn? _pendingTurn;
  Map<String, dynamic>? _pendingReply;
  Timer? _completionTimer;
  Timer? _transcriptTimer;
  bool get complete => progress?.complete ?? false;
  bool get canRetryTurn =>
      connected && (_pendingTurn != null || _pendingReply != null);
  String get status => error != null
      ? 'Let’s reconnect with Lumi'
      : complete
          ? 'All topics reviewed'
          : starting
              ? 'Connecting microphone…'
              : paused
                  ? 'Microphone paused'
                  : assessing
                      ? 'Thinking about your answer…'
                      : speaking
                          ? 'Lumi is speaking · tap to interrupt'
                          : hearingSpeech
                              ? 'I’m listening…'
                              : connected
                                  ? 'Your turn · speak naturally'
                                  : 'Teach Lumi in your own words';

  Future<void> start() async {
    if (_closed || starting || connected) return;
    final generation = ++_generation;
    starting = true;
    error = null;
    paused = false;
    speaking = false;
    _awaitingPlayback = false;
    _finalPlaybackStarted = false;
    _pendingTurn = null;
    _pendingReply = null;
    _handledTurns.clear();
    _turnRevisions.clear();
    _partialTurns.clear();
    _notify();
    try {
      final token = await tokenProvider();
      if (!_current(generation)) return;
      if (token == null) {
        throw StateError('Please sign in again to start speaking.');
      }
      final session = await _transport.connect(
          token: token,
          courseId: courseId,
          lessonId: lessonId,
          continuous: true);
      if (!_current(generation)) return;
      _session = session;
      if (session.progress == null) {
        throw StateError('Update the server to support continuous lessons.');
      }
      progress = TalkLessonProgress.fromJson(session.progress!);
      connected = !complete;
      caption = '';
      if (complete) {
        reply = 'You’ve reviewed all the topics. Your progress is saved.';
        return;
      }
      final topic = progress!.topics[progress!.currentTermIndex];
      final welcome =
          'Let’s ${progress!.reviewedCount > 0 ? 'continue' : 'start'} with ${topic.term}. Explain it in your own words.';
      reply = welcome;
      _awaitingPlayback = true;
      _transport.setMicrophoneEnabled(false);
      await _transport.speakLessonReply(
          instructions: _instructionsForCurrentTopic(), replyText: welcome);
    } catch (e) {
      if (!_current(generation)) return;
      connected = false;
      error = 'Couldn’t start live voice. Please try again.';
      await _transport.disconnect();
    } finally {
      if (_current(generation)) {
        starting = false;
        _notify();
      }
    }
  }

  String _instructionsForCurrentTopic() {
    final topic = progress!.topics[progress!.currentTermIndex];
    return 'You are Lumi, a warm study coach. Current topic: ${topic.term}. Canonical definition: ${topic.definition}. '
        'Speak only the server-approved reply. The server controls scores and topic changes.';
  }

  void _onEvent(TalkRealtimeEvent event) {
    if (_closed || (!connected && !starting)) return;
    final id = event.itemId;
    if (event.type == 'input_audio_buffer.speech_started' &&
        id != null &&
        !complete) {
      hearingSpeech = true;
      _turnRevisions[id] = progress?.revision ?? 0;
      _partialTurns[id] = '';
      caption = '';
      _transcriptTimer?.cancel();
    } else if (event.type == 'input_audio_buffer.speech_stopped' && !complete) {
      hearingSpeech = false;
      _transcriptTimer?.cancel();
      _transcriptTimer = Timer(const Duration(seconds: 12), () {
        if (_closed || assessing) return;
        error = 'No transcript arrived. Please repeat your explanation.';
        _notify();
      });
    } else if (event.type ==
            'conversation.item.input_audio_transcription.delta' &&
        id != null) {
      _partialTurns[id] = (_partialTurns[id] ?? '') + (event.transcript ?? '');
      caption = _partialTurns[id]!;
    } else if (event.type ==
            'conversation.item.input_audio_transcription.completed' &&
        id != null &&
        !complete) {
      _transcriptTimer?.cancel();
      if (_handledTurns.contains(id)) return;
      final text = (event.transcript ?? '').trim();
      caption = text;
      hearingSpeech = false;
      if (text.isEmpty) {
        error = 'I didn’t catch that. Try speaking again.';
        _notify();
        return;
      }
      if (assessing || _pendingTurn != null) {
        error =
            'Please wait for this answer to finish, then repeat your next thought.';
        _notify();
        return;
      }
      final revision = _turnRevisions.remove(id) ?? progress!.revision;
      if (revision != progress!.revision) {
        _notify();
        return;
      }
      _pendingTurn = _TalkTurn(id, text, revision);
      _handledTurns.add(id);
      unawaited(_assessPendingTurn());
    } else if (event.type == 'response.created') {
      reply = '';
    } else if (event.type == 'response.output_audio_transcript.delta') {
      reply += event.transcript ?? '';
    } else if (event.type == 'response.output_audio_transcript.done') {
      reply = event.transcript ?? reply;
    } else if (event.type == 'output_audio_buffer.started') {
      speaking = true;
      if (complete) _finalPlaybackStarted = true;
    } else if (event.type == 'output_audio_buffer.stopped' ||
        event.type == 'output_audio_buffer.cleared') {
      speaking = false;
      if (complete && _finalPlaybackStarted) {
        unawaited(_closeCompletedConnection());
      } else if (!complete) {
        _awaitingPlayback = false;
        _transport.setMicrophoneEnabled(
            !paused && !assessing && _pendingTurn == null);
      }
    } else if (event.type == 'error' ||
        event.type == 'conversation.item.input_audio_transcription.failed') {
      _transcriptTimer?.cancel();
      hearingSpeech = false;
      error = event.message ?? 'Live voice had a problem. Try again.';
    }
    _notify();
  }

  Future<void> retryTurn() async {
    if (assessing || !connected) return;
    if (_pendingTurn != null) {
      await _assessPendingTurn();
    } else if (_pendingReply != null) {
      await _speakPendingReply();
    }
  }

  Future<void> _assessPendingTurn() async {
    final turn = _pendingTurn;
    if (turn == null || _session == null || assessing || complete) return;
    final generation = _generation;
    assessing = true;
    error = null;
    _transport.setMicrophoneEnabled(false);
    _notify();
    try {
      final token = await tokenProvider();
      if (!_current(generation)) return;
      if (token == null) throw StateError('Authentication expired.');
      final response = await _api.assessTalkLessonTurn(
          token: token,
          attemptId: _session!.attemptId,
          turnId: turn.id,
          transcript: turn.transcript,
          expectedRevision: turn.revision);
      if (!_current(generation)) return;
      if (response.statusCode != 200) {
        if (response.statusCode == 409 || response.statusCode == 410) {
          connected = false;
          await _transport.disconnect();
          throw StateError('Progress changed or the session expired.');
        }
        throw StateError('Review failed (${response.statusCode}).');
      }
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      progress = TalkLessonProgress.fromJson(
          result['progress'] as Map<String, dynamic>);
      feedback = result['replyText'] as String;
      reply = feedback;
      _pendingReply = result;
      _pendingTurn = null;
      _notify();
      await _speakPendingReply();
    } catch (_) {
      if (_current(generation)) {
        error = connected
            ? 'Couldn’t review that yet. Retry your saved answer.'
            : 'Reconnect to resume your saved progress.';
      }
    } finally {
      if (_current(generation)) {
        assessing = false;
        _transport.setMicrophoneEnabled(connected &&
            !paused &&
            !complete &&
            !_awaitingPlayback &&
            _pendingTurn == null);
        _notify();
      }
    }
  }

  Future<void> _speakPendingReply() async {
    final result = _pendingReply;
    if (result == null) return;
    final generation = _generation;
    try {
      error = null;
      _awaitingPlayback = true;
      _transport.setMicrophoneEnabled(false);
      await _transport.speakLessonReply(
          instructions: result['instructions'] as String,
          replyText: result['replyText'] as String);
      if (!_current(generation)) return;
      _pendingReply = null;
      if (complete) {
        // Preserve the final spoken feedback; close when playback drains.
        _completionTimer = Timer(const Duration(seconds: 30),
            () => unawaited(_closeCompletedConnection()));
      }
    } catch (_) {
      if (_current(generation)) {
        _awaitingPlayback = false;
        error = 'Progress saved. Tap retry to hear Lumi’s reply.';
      }
    }
    _notify();
  }

  Future<void> interrupt() async {
    if (!connected || !speaking || complete) return;
    try {
      await _transport.interruptPlayback();
    } catch (_) {
      error = 'Couldn’t interrupt Lumi. Please try again.';
      _notify();
    }
  }

  void toggleMicrophone() {
    if (!connected || assessing || complete) return;
    paused = !paused;
    _transport.setMicrophoneEnabled(
        !paused && !_awaitingPlayback && _pendingTurn == null);
    _notify();
  }

  Future<void> _closeCompletedConnection() async {
    _completionTimer?.cancel();
    connected = false;
    speaking = false;
    await _transport.disconnect();
    _notify();
  }

  Future<void> stop() async {
    ++_generation;
    connected = false;
    starting = false;
    assessing = false;
    speaking = false;
    _transcriptTimer?.cancel();
    _completionTimer?.cancel();
    await _transport.disconnect();
    _notify();
  }

  bool _current(int generation) => !_closed && generation == _generation;
  void _notify() {
    if (!_closed) notifyListeners();
  }

  @override
  void dispose() {
    _closed = true;
    ++_generation;
    _transcriptTimer?.cancel();
    _completionTimer?.cancel();
    unawaited(_eventSubscription.cancel());
    unawaited(_stateSubscription.cancel());
    unawaited(_transport.dispose());
    super.dispose();
  }
}
