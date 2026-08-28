import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:uuid/uuid.dart';

enum TalkRealtimeConnectionState {
  idle,
  connecting,
  listening,
  speaking,
  disconnected,
  error,
}

class TalkRealtimeEvent {
  const TalkRealtimeEvent(this.type, {this.transcript, this.message});

  final String type;
  final String? transcript;
  final String? message;
}

class TalkRealtimeSession {
  const TalkRealtimeSession({
    required this.attemptId,
    required this.focusTerm,
    required this.focusDefinition,
  });

  final String attemptId;
  final String focusTerm;
  final String focusDefinition;
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

  Stream<TalkRealtimeEvent> get events => _events.stream;
  Stream<TalkRealtimeConnectionState> get states => _state.stream;

  Future<TalkRealtimeSession> connect({
    required String token,
    required String courseId,
    required String lessonId,
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
      );
      final sessionJson = _decodeSuccess(sessionResponse, 'start Talk to Lumi');
      final session = TalkRealtimeSession(
        attemptId: sessionJson['attemptId'] as String,
        focusTerm: sessionJson['focusTerm'] as String,
        focusDefinition: sessionJson['focusDefinition'] as String,
      );

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });
      _peerConnection = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
      });
      for (final track in _localStream!.getAudioTracks()) {
        await _peerConnection!.addTrack(track, _localStream!);
      }
      _peerConnection!.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          _emitState(TalkRealtimeConnectionState.listening);
        } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          _emitState(TalkRealtimeConnectionState.disconnected);
        }
      };
      _peerConnection!.onTrack = (_) async {
        // The native WebRTC audio track is played by the platform audio session.
        // Force a speaker route so Lumi is audible without headphones.
        await Helper.setSpeakerphoneOn(true);
        _emitState(TalkRealtimeConnectionState.speaking);
      };
      _dataChannel = await _peerConnection!.createDataChannel(
        'oai-events',
        RTCDataChannelInit(),
      );
      _dataChannel!.onMessage = _handleDataChannelMessage;

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
      final answerJson = _decodeSuccess(answerResponse, 'connect Talk to Lumi');
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answerJson['sdp'] as String, 'answer'),
      );
      return session;
    } catch (error) {
      _emitState(TalkRealtimeConnectionState.error);
      _events.add(TalkRealtimeEvent('error', message: error.toString()));
      await disconnect();
      rethrow;
    }
  }

  Future<void> disconnect() async {
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
    if (await peer.getIceGatheringState() == RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }
    final completer = Completer<void>();
    peer.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete && !completer.isCompleted) {
        completer.complete();
      }
    };
    await completer.future.timeout(const Duration(seconds: 5));
  }

  void _handleDataChannelMessage(RTCDataChannelMessage event) {
    if (event.isBinary) return;
    try {
      final payload = jsonDecode(event.text) as Map<String, dynamic>;
      final type = payload['type'] as String? ?? 'unknown';
      final transcript = payload['transcript'] as String? ?? payload['delta'] as String?;
      _events.add(TalkRealtimeEvent(type, transcript: transcript));
      if (type == 'input_audio_buffer.speech_started') {
        _emitState(TalkRealtimeConnectionState.listening);
      } else if (type == 'response.audio.delta') {
        _emitState(TalkRealtimeConnectionState.speaking);
      } else if (type == 'response.done') {
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
    if (decoded is! Map<String, dynamic>) throw StateError('Invalid $action response.');
    return decoded;
  }

  void _emitState(TalkRealtimeConnectionState state) {
    if (!_disposed && !_state.isClosed) _state.add(state);
  }

  void _ensureNotDisposed() {
    if (_disposed) throw StateError('TalkToLumiRealtimeService has been disposed.');
  }
}
