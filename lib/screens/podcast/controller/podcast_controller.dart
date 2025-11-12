// lib/screens/podcast/podcast_controller.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:lumi_learn_app/application/models/podcast_model.dart';
import 'package:lumi_learn_app/application/services/podcast_service.dart';
import 'package:lumi_learn_app/screens/podcast/widget/generate_dialog.dart';

class PodcastController extends ChangeNotifier {
  final String courseId;
  final String courseTitle;
  final String token;
  final BuildContext context;

  final PodcastService _podcastService = PodcastService();
  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _ringtonePlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();

  PodcastMetadata? metadata;
  List<PodcastSegment> segments = [];
  Stream<List<PodcastLine>>? currentDialogueStream;

  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _dialogueStreamSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  String? _recordedPath;

  int currentSegmentIndex = 0;
  int currentLineIndex = 0;
  String? currentSpeaker;
  String? currentDialogueText;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  bool isLoading = true;
  bool isPlaying = false;
  bool isGenerating = false;
  bool isRecording = false;
  bool isRinging = false;
  bool isProcessingCallIn = false;

  PodcastController({
    required this.courseId,
    required this.courseTitle,
    required this.token,
    required this.context,
  });

  // Get current segment's dialogue
  List<PodcastLine> get currentDialogue {
    if (segments.isEmpty || currentSegmentIndex >= segments.length) {
      return [];
    }
    return segments[currentSegmentIndex].dialogue;
  }

  // 🆕 Get current segment's topic/title
  String get currentSegmentTopic {
    if (segments.isEmpty || currentSegmentIndex >= segments.length) {
      return 'Loading...';
    }
    return segments[currentSegmentIndex].topic ?? 'Segment ${currentSegmentIndex + 1}';
  }

  // 🆕 Get current segment's real-world examples
  List<String> get currentSegmentExamples {
    if (segments.isEmpty || currentSegmentIndex >= segments.length) {
      return [];
    }
    return segments[currentSegmentIndex].examples ?? [];
  }

  // 🆕 Check if current segment is standalone
  bool get isCurrentSegmentStandalone {
    if (segments.isEmpty || currentSegmentIndex >= segments.length) {
      return false;
    }
    return segments[currentSegmentIndex].isStandalone ?? false;
  }

  // --------------------------------------------------------------------------
  // Initialization
  // --------------------------------------------------------------------------
  Future<void> init() async {
    _setupAudioPlayer();
    await _initRecorder();
    await loadPodcast();
  }

  Future<void> _initRecorder() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _ringtonePlayer.dispose();
    _playerCompleteSubscription?.cancel();
    _dialogueStreamSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Load Podcast
  // --------------------------------------------------------------------------
  Future<void> loadPodcast() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _podcastService.getPodcastMetadata(
        token: token,
        courseId: courseId,
      );
      
      if (data == null) {
        _showGenerateDialog();
        isLoading = false;
        notifyListeners();
        return;
      }

      metadata = data;
      segments = await _podcastService.getPodcastSegments(
        token: token,
        courseId: courseId,
      );

      if (segments.isNotEmpty) {
        _setupDialogueStream();
        // 🆕 Log loaded segments with topics
        for (var i = 0; i < segments.length; i++) {
        }
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  void _setupDialogueStream() {
    // Cancel previous subscription
    _dialogueStreamSubscription?.cancel();
    
    if (segments.isEmpty || currentSegmentIndex >= segments.length) {
      currentDialogueStream = null;
      notifyListeners();
      return;
    }

    final currentSegmentId = segments[currentSegmentIndex].id;
    
    currentDialogueStream = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('podcasts')
        .doc('segments')
        .collection('list')
        .doc(currentSegmentId)
        .collection('dialogue')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PodcastLine(
                id: doc.id,
                speaker: data['speaker'] ?? 'Host A',
                text: data['text'] ?? '',
                audioUrl: data['audioUrl'],
                order: data['order'] ?? 0,
                isInterrupt: data['isInterrupt'],
                createdAt: data['createdAt'],
              );
            }).toList());
    
    // Subscribe to the stream to update segment dialogue in real-time
    _dialogueStreamSubscription = currentDialogueStream!.listen((dialogueLines) {
      if (currentSegmentIndex < segments.length) {
        final oldLength = segments[currentSegmentIndex].dialogue.length;
        segments[currentSegmentIndex].dialogue = dialogueLines;
        
        // If new dialogue lines were added and we're processing a call-in,
        // play the new response automatically
        if (isProcessingCallIn && dialogueLines.length > oldLength) {
          print('📥 New dialogue detected: ${dialogueLines.length - oldLength} lines added');
          _playNewResponseLines(oldLength);
        }
        
        notifyListeners();
      }
    });
    
    notifyListeners();
  }

  // Play newly added response lines from the backend
  Future<void> _playNewResponseLines(int startIndex) async {
    if (!isProcessingCallIn) return;
    
    final dialogue = currentDialogue;
    if (startIndex >= dialogue.length) return;

    print('🎧 Playing response starting from line $startIndex');
    
    // Play each new line sequentially
    for (int i = startIndex; i < dialogue.length; i++) {
      if (!isProcessingCallIn) break; // Stop if user interrupted
      
      final line = dialogue[i];
      currentSpeaker = line.speaker;
      currentDialogueText = line.text;
      notifyListeners();

      if (line.audioUrl != null && line.audioUrl!.isNotEmpty) {
        try {
          await _player.play(UrlSource(line.audioUrl!));
          await _player.onPlayerComplete.first;
        } catch (e) {
          print('Error playing line audio: $e');
          await Future.delayed(
            Duration(milliseconds: (line.text.length * 40).clamp(2000, 8000)),
          );
        }
      } else {
        await Future.delayed(
          Duration(milliseconds: (line.text.length * 40).clamp(2000, 8000)),
        );
      }
    }

    // Done processing call-in
    isProcessingCallIn = false;
    notifyListeners();
    
    // Resume regular playback from where we left off
    await Future.delayed(const Duration(milliseconds: 800));
    if (currentLineIndex < currentDialogue.length) {
      startPlayback();
    }
  }

  // --------------------------------------------------------------------------
  // Segment Navigation
  // --------------------------------------------------------------------------
  void nextSegment() {
    if (currentSegmentIndex < segments.length - 1) {
      // Stop current playback
      stopPlayback();
      
      // Move to next segment
      currentSegmentIndex++;
      currentLineIndex = 0;
      
      // Clear current dialogue display
      currentDialogueText = null;
      currentSpeaker = null;
      
      // Reset position
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
      
      // 🆕 Log segment transition with topic
      print('⏭️ Moving to next segment: ${currentSegmentTopic}');
      
      // Setup new dialogue stream for the new segment
      _setupDialogueStream();
      
      notifyListeners();
    }
  }

  void previousSegment() {
    if (currentSegmentIndex > 0) {
      // Stop current playback
      stopPlayback();
      
      // Move to previous segment
      currentSegmentIndex--;
      currentLineIndex = 0;
      
      // Clear current dialogue display
      currentDialogueText = null;
      currentSpeaker = null;
      
      // Reset position
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
      
      // Setup new dialogue stream for the new segment
      _setupDialogueStream();
      
      notifyListeners();
    }
  }

  // 🆕 Jump to specific segment by index
  void jumpToSegment(int index) {
    if (index >= 0 && index < segments.length && index != currentSegmentIndex) {
      // Stop current playback
      stopPlayback();
      
      // Move to target segment
      currentSegmentIndex = index;
      currentLineIndex = 0;
      
      // Clear current dialogue display
      currentDialogueText = null;
      currentSpeaker = null;
      
      // Reset position
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
      
      // Log segment jump
      print('🎯 Jumping to segment ${index + 1}: ${currentSegmentTopic}');
      
      // Setup new dialogue stream for the target segment
      _setupDialogueStream();
      
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // Playback
  // --------------------------------------------------------------------------
  void _setupAudioPlayer() {
    _player.setReleaseMode(ReleaseMode.stop);
    
    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      if (!isPlaying) return;
      currentLineIndex++;
      playNextLine();
    });

    // Listen to position changes
    _positionSubscription = _player.onPositionChanged.listen((position) {
      currentPosition = position;
      notifyListeners();
    });

    // Listen to duration changes
    _durationSubscription = _player.onDurationChanged.listen((duration) {
      totalDuration = duration;
      notifyListeners();
    });
  }

  Future<void> togglePlayback() async {
    if (isPlaying) {
      stopPlayback();
    } else {
      startPlayback();
    }
  }

  void startPlayback() {
    if (segments.isEmpty || currentSegmentIndex >= segments.length) {
      return;
    }
    
    if (currentDialogue.isEmpty) {
      return;
    }
    
    isPlaying = true;
    notifyListeners();
    playNextLine();
  }

  void stopPlayback() {
    isPlaying = false;
    _player.stop();
    notifyListeners();
  }

  Future<void> playNextLine() async {
    if (!isPlaying || segments.isEmpty || currentSegmentIndex >= segments.length) {
      return;
    }
    
    final dialogue = currentDialogue;
    
    if (currentLineIndex >= dialogue.length) {
      // Reached end of current segment
      print('📍 Segment complete: ${currentSegmentTopic}');
      
      // Check if there's a next segment
      if (currentSegmentIndex < segments.length - 1) {
        print('⏭️ Auto-advancing to next segment...');
        
        // Move to next segment
        currentSegmentIndex++;
        currentLineIndex = 0;
        currentDialogueText = null;
        currentSpeaker = null;
        currentPosition = Duration.zero;
        totalDuration = Duration.zero;
        
        // Setup new dialogue stream
        _setupDialogueStream();
        
        // Show transition notification
        _showSnack(
          '📚 Now playing: ${currentSegmentTopic}',
          Colors.blue,
        );
        
        // Wait a moment for dialogue to load
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Continue playing if we still have isPlaying = true
        if (isPlaying && currentDialogue.isNotEmpty) {
          notifyListeners();
          playNextLine();
        } else {
          stopPlayback();
        }
      } else {
        print('✅ Podcast complete!');
        _showSnack('✅ Podcast complete!', Colors.green);
        stopPlayback();
      }
      return;
    }

    final line = dialogue[currentLineIndex];
    currentSpeaker = line.speaker;
    currentDialogueText = line.text;
    notifyListeners();

    if (line.audioUrl != null && line.audioUrl!.isNotEmpty) {
      try {
        await _player.play(UrlSource(line.audioUrl!));
      } catch (e) {
        print('❌ Error playing audio: $e');
        // Fallback to text-based timing if audio fails
        await Future.delayed(
          Duration(milliseconds: (line.text.length * 40).clamp(2000, 8000)),
        );
        currentLineIndex++;
        playNextLine();
      }
    } else {
      // No audio URL, use text-based timing
      await Future.delayed(
        Duration(milliseconds: (line.text.length * 40).clamp(2000, 8000)),
      );
      currentLineIndex++;
      playNextLine();
    }
  }

  // --------------------------------------------------------------------------
  // Recording & Call-In with Ringtone (ENHANCED)
  // --------------------------------------------------------------------------
  Future<void> handleCallIn() async {
    try {
      if (!isRecording) {
        await _startCallInSequence();
      } else {
        await _stopRecordingAndSend();
      }
    } catch (e) {
      isRecording = false;
      isRinging = false;
      isProcessingCallIn = false;
      notifyListeners();
      _showSnack('❌ Error during call-in: $e', Colors.red);
    }
  }

  Future<void> _startCallInSequence() async {
    // Stop current playback
    if (isPlaying) {
      stopPlayback();
    }

    // 🆕 Show what topic we're asking about
    print('📞 Call-in for segment: ${currentSegmentTopic}');

    // Play ringtone
    isRinging = true;
    notifyListeners();
    
    try {
      // Play ringtone
      await _ringtonePlayer.play(AssetSource('sounds/ringtone.mp3'));
      
      // Wait for ringtone to finish (or max 3 seconds)
      await Future.any([
        _ringtonePlayer.onPlayerComplete.first,
        Future.delayed(const Duration(seconds: 3)),
      ]);
      
      await _ringtonePlayer.stop();
    } catch (e) {
      print('⚠️ Ringtone error: $e');
      await Future.delayed(const Duration(seconds: 2));
    }
    
    isRinging = false;
    notifyListeners();

    // Start recording
    final tempDir = await Directory.systemTemp.createTemp();
    final path = '${tempDir.path}/question_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _recordedPath = path;

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    
    isRecording = true;
    notifyListeners();
    
    _showSnack('🎙️ Recording your question...', Colors.blue);
  }

  Future<void> _stopRecordingAndSend() async {
    // Stop recording
    await _recorder.stop();
    isRecording = false;
    isProcessingCallIn = true;
    notifyListeners();

    if (_recordedPath == null) {
      throw Exception('No recorded file found.');
    }

    // Show user's question being sent
    currentSpeaker = 'You';
    currentDialogueText = 'Asking a question...';
    notifyListeners();

    // Show loading
    _showSnack('📤 Sending your question...', Colors.blue);

    // 🆕 Send question (ephemeral - not saved to Firestore)
    // Now with enhanced realistic call-in handling
    final result = await _podcastService.transcribeAudioQuestion(
      File(_recordedPath!),
      token: token,
      courseId: courseId,
      segmentId: segments[currentSegmentIndex].id,
    );

    // Show the transcribed question
    final transcribedText = result['text'] as String?;
    if (transcribedText != null && transcribedText.isNotEmpty) {
      currentSpeaker = 'You';
      currentDialogueText = transcribedText;
      print('📝 Your question: $transcribedText');
      notifyListeners();
      
      // Show question for a moment
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    // 🆕 Show enhanced call-in acknowledgment
    final acknowledgment = result['acknowledgment'] as String?;
    if (acknowledgment != null) {
      print('📞 Host: $acknowledgment');
      _showSnack('📞 $acknowledgment', Colors.blue);
    } else {
      _showSnack('🎧 Host is responding...', Colors.green);
    }

    // 🆕 Optionally show the segmentTopic context
    final segmentTopic = result['segmentTopic'] as String?;
    if (segmentTopic != null) {
      print('📚 Context: Currently discussing "$segmentTopic"');
    }

    // Play the ephemeral response
    final audioUrl = result['hostAudioUrl'];
    if (audioUrl != null) {
      final hostResponse = result['hostResponse'] as String?;
      if (hostResponse != null) {
        currentSpeaker = result['speaker'] as String? ?? 'Host';
        currentDialogueText = hostResponse;
        print('🎤 ${currentSpeaker}: ${hostResponse.substring(0, 100)}...');
        notifyListeners();
      }
      
      await _player.play(UrlSource(audioUrl));
      await _player.onPlayerComplete.first;
      
      isProcessingCallIn = false;
      notifyListeners();
      
      _showSnack('✅ Response complete!', Colors.green);
      
      // Small pause before resuming
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Resume playback if there's more content
      if (currentLineIndex < currentDialogue.length) {
        startPlayback();
      }
    } else {
      isProcessingCallIn = false;
      notifyListeners();
      _showSnack('❌ No audio response received', Colors.red);
    }
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------
  void _showSnack(String message, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGenerateDialog() {
    if (!context.mounted) return;
    showGeneratePodcastDialog(
      context: context,
      onGenerate: _generatePodcast,
    );
  }

  Future<void> _generatePodcast() async {
    isGenerating = true;
    notifyListeners();

    try {
      print('🎙️ Generating podcast for: $courseTitle');
      await _podcastService.createPodcast(
        token: token,
        courseId: courseId,
        title: courseTitle,
      );
      await loadPodcast();
      print('✅ Podcast generated successfully!');
    } catch (e) {
      print('❌ Error generating podcast: $e');
      _showSnack('❌ Failed to generate podcast', Colors.red);
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}