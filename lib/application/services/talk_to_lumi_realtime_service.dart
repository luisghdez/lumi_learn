import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:uuid/uuid.dart';

enum TalkRealtimeConnectionState {
  idle,
  connecting,
  listening,
  processing,
  speaking,
  disconnected,
  error,
}

class TalkRealtimeEvent {
  const TalkRealtimeEvent(this.type,
      {this.transcript, this.message, this.itemId});

  final String type;
  final String? transcript;
  final String? message;
  final String? itemId;
}

class TalkRealtimeSession {
  const TalkRealtimeSession({
    required this.attemptId,
    required this.focusTerm,
    required this.focusDefinition,
    this.progress,
  });

  final String attemptId;
  final String focusTerm;
  final String focusDefinition;
  final Map<String, dynamic>? progress;
}

/// WebRTC transport for the feature-flagged Talk to Lumi prototype.
///
/// It owns media and the Realtime data channel only. The caller keeps the UI
/// state and sends the final editable transcript to Lumi API for assessment.
/// The long-lived OpenAI API key never leaves Lumi API; the offer is exchanged
/// through the authenticated `/talk/attempts/:id/offer` endpoint.
class TalkToLumiRealtimeService {
  TalkToLumiRealtimeService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  final _events = StreamController<TalkRealtimeEvent>.broadcast();
  final _state = StreamController<TalkRealtimeConnectionState>.broadcast();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCDataChannel? _dataChannel;
  bool _disposed = false;
  Completer<void>? _sessionReady;
  Timer? _diagnosticsTimer;
  Completer<void>? _instructionsUpdated;
  String? _expectedInstructions;

  Stream<TalkRealtimeEvent> get events => _events.stream;
  Stream<TalkRealtimeConnectionState> get states => _state.stream;

  Future<TalkRealtimeSession> connect({
    required String token,
    required String courseId,
    required String lessonId,
    bool continuous = false,
  }) async {
    _ensureNotDisposed();
    await disconnect();
    _emitState(TalkRealtimeConnectionState.connecting);

    try {
      final sessionResponse = await _apiService.createTalkSession(
        token: token,
        courseId: courseId,
        lessonId: lessonId,
        clientAttemptId: const Uuid().v4(),
        continuous: continuous,
      );
      _ensureNotDisposed();
      final sessionJson = _decodeSuccess(sessionResponse, 'start Talk to Lumi');
      final session = TalkRealtimeSession(
        attemptId: sessionJson['attemptId'] as String,
        focusTerm: sessionJson['focusTerm'] as String,
        focusDefinition: sessionJson['focusDefinition'] as String,
        progress: sessionJson['progress'] as Map<String, dynamic>?,
      );

      if (session.progress?['complete'] == true) return session;
      await Helper.setAppleAudioConfiguration(AppleAudioConfiguration(
        appleAudioCategory: AppleAudioCategory.playAndRecord,
        appleAudioMode: AppleAudioMode.voiceChat,
        appleAudioCategoryOptions: {
          AppleAudioCategoryOption.allowBluetooth,
          AppleAudioCategoryOption.defaultToSpeaker,
        },
      ));
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });
      _ensureNotDisposed();
      if (_localStream!.getAudioTracks().isEmpty) {
        throw StateError('The microphone did not provide an audio track.');
      }
      _peerConnection = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
      });
      _ensureNotDisposed();
      for (final track in _localStream!.getAudioTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }
      _peerConnection!.onConnectionState = (state) {
        debugPrint('[TalkRealtime] peer=$state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          // Wait for session.created before declaring the microphone ready.
        } else if (state ==
                RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state ==
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          _emitState(TalkRealtimeConnectionState.disconnected);
        }
      };
      // Configure routing before capture starts. Changing the iOS route in
      // onTrack can stop AVAudioEngine while the connection is negotiating.
      _sessionReady = Completer<void>();
      _dataChannel = await _peerConnection!.createDataChannel(
        'oai-events',
        RTCDataChannelInit(),
      );
      _dataChannel!.onMessage = _handleDataChannelMessage;
      _dataChannel!.onDataChannelState = (state) {
        debugPrint('[TalkRealtime] dataChannel=$state');
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          _emitState(TalkRealtimeConnectionState.disconnected);
        }
      };

      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': 1,
      });
      await _peerConnection!.setLocalDescription(offer);
      await _waitForIceGathering();
      final offerSdp = (await _peerConnection!.getLocalDescription())?.sdp;
      if (offerSdp == null || offerSdp.isEmpty) {
        throw StateError('WebRTC did not create an SDP offer.');
      }
      final answerResponse = await _apiService.createTalkWebRtcOffer(
        token: token,
        attemptId: session.attemptId,
        sdp: offerSdp,
      );
      _ensureNotDisposed();
      final answerJson = _decodeSuccess(answerResponse, 'connect Talk to Lumi');
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answerJson['sdp'] as String, 'answer'),
      );
      await _sessionReady!.future.timeout(const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException(
              'The live audio connection did not become ready. Please retry.'));
      _emitState(TalkRealtimeConnectionState.listening);
      if (!continuous) {
        await _dataChannel!.send(RTCDataChannelMessage(jsonEncode({
          'type': 'response.create',
          'response': {
            'instructions':
                'Briefly invite the learner to explain ${session.focusTerm} in their own words. Do not give the definition.',
          },
        })));
      }
      if (kDebugMode) {
        _diagnosticsTimer =
            Timer.periodic(const Duration(seconds: 5), (_) async {
          final peer = _peerConnection;
          if (peer == null) return;
          try {
            for (final report in await peer.getStats()) {
              if (report.type == 'outbound-rtp' ||
                  report.type == 'media-source') {
                final v = report.values;
                debugPrint('[TalkRealtime] ${report.type} '
                    'bytesSent=${v['bytesSent']} audioLevel=${v['audioLevel']} '
                    'totalAudioEnergy=${v['totalAudioEnergy']}');
              }
            }
          } catch (_) {/* The connection may have closed during getStats. */}
        });
      }
      return session;
    } catch (error) {
      _emitState(TalkRealtimeConnectionState.error);
      if (!_disposed) {
        _events.add(TalkRealtimeEvent('error', message: error.toString()));
      }
      await disconnect();
      rethrow;
    }
  }

  void setMicrophoneEnabled(bool enabled) {
    for (final track
        in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = enabled;
    }
  }

  bool _responseInProgress = false;

  Future<void> interruptPlayback() async {
    final channel = _dataChannel;
    if (channel == null) return;
    if (_responseInProgress) {
      await channel
          .send(RTCDataChannelMessage(jsonEncode({'type': 'response.cancel'})));
    }
    await channel.send(RTCDataChannelMessage(
        jsonEncode({'type': 'output_audio_buffer.clear'})));
  }

  Future<void> speakLessonReply(
      {required String instructions, required String replyText}) async {
    _ensureNotDisposed();
    final channel = _dataChannel;
    if (channel == null ||
        channel.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw StateError('Live voice disconnected. Reconnect to continue.');
    }
    _expectedInstructions = instructions;
    final updated = Completer<void>();
    _instructionsUpdated = updated;
    try {
      await channel.send(RTCDataChannelMessage(jsonEncode({
        'type': 'session.update',
        'session': {'type': 'realtime', 'instructions': instructions},
      })));
      await updated.future.timeout(const Duration(seconds: 5));
      _ensureNotDisposed();
      await channel.send(RTCDataChannelMessage(jsonEncode({
        'type': 'response.create',
        'response': {
          'instructions':
              'Speak only the following server-approved reply, naturally, without adding anything: ${jsonEncode(replyText)}'
        },
      })));
    } finally {
      if (identical(_instructionsUpdated, updated)) {
        _instructionsUpdated = null;
        _expectedInstructions = null;
      }
    }
  }

  Future<void> disconnect() async {
    _responseInProgress = false;
    _diagnosticsTimer?.cancel();
    _diagnosticsTimer = null;
    _dataChannel?.onDataChannelState = null;
    _dataChannel?.onMessage = null;
    if (_peerConnection != null) {
      _peerConnection!.onConnectionState = null;
      _peerConnection!.onTrack = null;
    }
    await _dataChannel?.close();
    _dataChannel = null;
    await _peerConnection?.close();
    _peerConnection = null;
    for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      await track.stop();
    }
    await _localStream?.dispose();
    _localStream = null;
    if (!_disposed) _emitState(TalkRealtimeConnectionState.disconnected);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await disconnect();
    await _events.close();
    await _state.close();
  }

  Future<void> _waitForIceGathering() async {
    final peer = _peerConnection;
    if (peer == null) throw StateError('WebRTC peer connection is missing.');
    if (await peer.getIceGatheringState() ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }
    final completer = Completer<void>();
    peer.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete &&
          !completer.isCompleted) {
        completer.complete();
      }
    };
    if (await peer.getIceGatheringState() ==
            RTCIceGatheringState.RTCIceGatheringStateComplete &&
        !completer.isCompleted) {
      completer.complete();
    }
    try {
      await completer.future.timeout(const Duration(seconds: 5));
    } finally {
      peer.onIceGatheringState = null;
    }
  }

  void _handleDataChannelMessage(RTCDataChannelMessage event) {
    if (_disposed || event.isBinary) return;
    try {
      final payload = jsonDecode(event.text) as Map<String, dynamic>;
      final type = payload['type'] as String? ?? 'unknown';
      final transcript =
          payload['transcript'] as String? ?? payload['delta'] as String?;
      final response = payload['response'] as Map<String, dynamic>?;
      final details = response?['status_details'] as Map<String, dynamic>?;
      final error =
          (payload['error'] ?? details?['error']) as Map<String, dynamic>?;
      debugPrint(
          '[TalkRealtime] event=$type transcriptLength=${transcript?.length ?? 0}'
          ' errorCode=${error?['code']}');
      if (type == 'response.created') _responseInProgress = true;
      if (type == 'response.done') {
        _responseInProgress = false;
        final usage = response?['usage'] as Map<String, dynamic>?;
        debugPrint('[TalkRealtime] responseStatus=${response?['status']} '
            'reason=${details?['reason']} outputTokens=${usage?['output_tokens']}');
      }
      if (type == 'session.updated' &&
          (payload['session'] as Map<String, dynamic>?)?['instructions'] ==
              _expectedInstructions &&
          !(_instructionsUpdated?.isCompleted ?? true)) {
        _instructionsUpdated!.complete();
      }
      if (type == 'session.created' && !(_sessionReady?.isCompleted ?? true)) {
        _sessionReady!.complete();
      }
      _events.add(TalkRealtimeEvent(
          error != null && type == 'response.done' ? 'error' : type,
          transcript: transcript,
          itemId: payload['item_id'] as String?,
          message: error?['message'] as String?));
      if (type == 'input_audio_buffer.speech_started') {
        _emitState(TalkRealtimeConnectionState.listening);
      } else if (type == 'input_audio_buffer.speech_stopped') {
        _emitState(TalkRealtimeConnectionState.processing);
      } else if (type == 'output_audio_buffer.started') {
        _emitState(TalkRealtimeConnectionState.speaking);
      } else if (type == 'output_audio_buffer.stopped' ||
          type == 'output_audio_buffer.cleared') {
        _emitState(TalkRealtimeConnectionState.listening);
      }
    } catch (_) {
      _events.add(const TalkRealtimeEvent('malformed_event'));
    }
  }

  Map<String, dynamic> _decodeSuccess(httpResponse, String action) {
    if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
      throw StateError('Unable to $action (${httpResponse.statusCode}).');
    }
    final decoded = jsonDecode(httpResponse.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid $action response.');
    }
    return decoded;
  }

  void _emitState(TalkRealtimeConnectionState state) {
    if (!_disposed && !_state.isClosed) _state.add(state);
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('TalkToLumiRealtimeService has been disposed.');
    }
  }
}
