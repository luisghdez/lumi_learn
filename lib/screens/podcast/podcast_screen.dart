// lib/screens/podcast_screen.dart
// FIXED VERSION - Better audio player handling for all voice types

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/application/models/podcast_model.dart';
import 'package:lumi_learn_app/application/services/podcast_service.dart';
import 'package:lumi_learn_app/screens/podcast/widget/podcast_call_in_dialog.dart';
import 'package:audioplayers/audioplayers.dart';

class PodcastScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final String token;

  const PodcastScreen({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.token,
  }) : super(key: key);

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final PodcastService _podcastService = PodcastService();
  final AudioPlayer _player = AudioPlayer();
  
  PodcastMetadata? _metadata;
  List<PodcastSegment> _segments = [];
  int _currentSegmentIndex = 0;
  int _currentLineIndex = 0;
  String? _currentDialogueText;
  String? _currentSpeaker;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isGenerating = false;
  Timer? _pollTimer;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _loadPodcast();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _playerCompleteSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    // Set audio player to release mode
    _player.setReleaseMode(ReleaseMode.stop);
    
    // Listen to player complete events
    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      print('✅ Audio completed for ${_currentSpeaker}');
      if (!mounted || !_isPlaying) return;
      _currentLineIndex++;
      _playNextLine();
    });
  }

  Future<void> _loadPodcast() async {
    setState(() => _isLoading = true);

    try {
      final exists = await _podcastService.podcastExists(
        token: widget.token,
        courseId: widget.courseId,
      );
      
      if (!exists) {
        if (mounted) {
          _showGeneratePodcastDialog();
        }
        setState(() => _isLoading = false);
        return;
      }

      final metadata = await _podcastService.getPodcastMetadata(
        token: widget.token,
        courseId: widget.courseId,
      );
      
      final segments = await _podcastService.getPodcastSegments(
        token: widget.token,
        courseId: widget.courseId,
      );

      if (mounted) {
        setState(() {
          _metadata = metadata;
          _segments = segments;
          _isLoading = false;
        });

        if (_isPlaying) {
        }
      }
    } catch (e) {
      print('❌ Error loading podcast: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading podcast: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (!_isPlaying) return;
    
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _refreshCurrentSegment();
    });
  }

Future<void> _refreshCurrentSegment() async {
  if (_currentSegmentIndex >= _segments.length) return;

  final currentSegment = _segments[_currentSegmentIndex];
  try {
    final updatedSegment = await _podcastService.getPodcastSegment(
      token: widget.token,
      courseId: widget.courseId,
      segmentId: currentSegment.id,
    );

    if (updatedSegment != null && mounted) {
      final oldCount = _segments[_currentSegmentIndex].dialogue.length;
      final newCount = updatedSegment.dialogue.length;

      if (newCount > oldCount) {
        print('✨ New dialogue detected!');
        setState(() {
          _segments[_currentSegmentIndex] = updatedSegment;
        });
      }
    }
  } catch (e) {
    print('❌ Error refreshing segment: $e');
  }
}

  void _showGeneratePodcastDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Generate Podcast',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'No podcast exists for this course yet. Would you like to generate one? This may take a few minutes.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generatePodcast();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4CE6),
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePodcast() async {
    setState(() => _isGenerating = true);

    try {
      await _podcastService.createPodcast(
        token: widget.token,
        courseId: widget.courseId,
        title: widget.courseTitle,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Podcast generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        await Future.delayed(const Duration(seconds: 3));
        await _loadPodcast();
      }
    } catch (e) {
      print('❌ Error generating podcast: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating podcast: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _goToNextSegment() {
    if (_currentSegmentIndex < _segments.length - 1) {
      _stopPlayback();
      setState(() {
        _currentSegmentIndex++;
        _currentLineIndex = 0;
        _currentDialogueText = null;
        _currentSpeaker = null;
      });
    }
  }

  void _goToPreviousSegment() {
    if (_currentSegmentIndex > 0) {
      _stopPlayback();
      setState(() {
        _currentSegmentIndex--;
        _currentLineIndex = 0;
        _currentDialogueText = null;
        _currentSpeaker = null;
      });
    }
  }

  void _showCallInDialog() {
    if (_segments.isEmpty) return;

    final wasPlaying = _isPlaying;
    if (wasPlaying) {
      _stopPlayback();
    }

    showDialog(
      context: context,
      builder: (context) => PodcastCallInDialog(
        token: widget.token,
        courseId: widget.courseId,
        segmentId: _segments[_currentSegmentIndex].id,
        onQuestionSent: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your question has been sent to the hosts!'),
              duration: Duration(seconds: 3),
            ),
          );
          _refreshCurrentSegment();
        },
      ),
    );
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    setState(() => _isPlaying = true);
    _startPolling();
    _playNextLine();
  }

  void _stopPlayback() {
    setState(() => _isPlaying = false);
    _pollTimer?.cancel();
    _player.stop();
  }

  Future<void> _playNextLine() async {
    if (!_isPlaying || _currentSegmentIndex >= _segments.length) {
      return;
    }

    final dialogue = _segments[_currentSegmentIndex].dialogue;
    
    if (_currentLineIndex >= dialogue.length) {
      // Segment finished
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentLineIndex = 0;
        });
      }
      return;
    }

    final line = dialogue[_currentLineIndex];
    
    print('🎤 Playing: ${line.speaker} - Line ${_currentLineIndex + 1}');
    
    if (mounted) {
      setState(() {
        _currentSpeaker = line.speaker;
        _currentDialogueText = line.text;
      });
    }

    if (line.audioUrl != null && line.audioUrl!.isNotEmpty) {
      try {
        // CRITICAL FIX: Always stop before playing new audio
        await _player.stop();
        
        // Small delay to ensure previous audio is fully stopped
        await Future.delayed(const Duration(milliseconds: 100));
        
        print('▶️ Playing audio: ${line.audioUrl}');
        
        // Play the audio
        await _player.play(UrlSource(line.audioUrl!));
        
        print('✅ Audio started for ${line.speaker}');
        
        // The onPlayerComplete listener will handle moving to next line
        
      } catch (e) {
        print('❌ Error playing audio: $e');
        // Fallback: show text for a duration then move to next
        await Future.delayed(Duration(
          milliseconds: (line.text.length * 50).clamp(2000, 8000),
        ));
        _currentLineIndex++;
        _playNextLine();
      }
    } else {
      print('⚠️ No audio URL, using text display');
      // No audio URL - show text for estimated reading time
      await Future.delayed(Duration(
        milliseconds: (line.text.length * 50).clamp(2000, 8000),
      ));
      _currentLineIndex++;
      _playNextLine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/podcast/podcast.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      _stopPlayback();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),

              // Speech bubble at top
              if (_currentDialogueText != null)
                Positioned(
                  top: 80,
                  left: 20,
                  right: 20,
                  child: _SpeechBubble(
                    text: _currentDialogueText!,
                    speaker: _currentSpeaker ?? 'Host',
                  ),
                ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Segment navigation
                      if (_segments.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.skip_previous,
                                color: _currentSegmentIndex > 0 
                                    ? Colors.white 
                                    : Colors.white.withOpacity(0.3),
                                size: 32,
                              ),
                              onPressed: _currentSegmentIndex > 0
                                  ? _goToPreviousSegment
                                  : null,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              'Segment ${_currentSegmentIndex + 1} of ${_segments.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: Icon(
                                Icons.skip_next,
                                color: _currentSegmentIndex < _segments.length - 1
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                size: 32,
                              ),
                              onPressed: _currentSegmentIndex < _segments.length - 1
                                  ? _goToNextSegment
                                  : null,
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Play/Pause button
                      if (!_isGenerating && _segments.isNotEmpty)
                        IconButton(
                          icon: Icon(
                            _isPlaying 
                                ? Icons.pause_circle_filled 
                                : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 64,
                          ),
                          onPressed: _togglePlayback,
                        ),

                      const SizedBox(height: 24),

                      // Call In button
                      ElevatedButton.icon(
                        onPressed: _isLoading || _segments.isEmpty || _isGenerating
                            ? null
                            : _showCallInDialog,
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text(
                          'Call In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4CE6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Loading or generating indicator
              if (_isLoading || _isGenerating)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isGenerating 
                              ? 'Generating podcast...\nThis may take a few minutes.' 
                              : 'Loading podcast...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  final String speaker;

  const _SpeechBubble({
    required this.text,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                speaker.contains('A') ? Icons.person : Icons.person_outline,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                speaker,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}