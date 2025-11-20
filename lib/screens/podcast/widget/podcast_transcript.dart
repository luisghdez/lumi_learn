// lib/screens/podcast/widget/podcast_transcript.dart
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/podcast/controller/podcast_controller.dart';

class PodcastTranscript extends StatefulWidget {
  final PodcastController controller;

  const PodcastTranscript({Key? key, required this.controller}) : super(key: key);

  @override
  State<PodcastTranscript> createState() => _PodcastTranscriptState();
}

class _PodcastTranscriptState extends State<PodcastTranscript> {
  final ScrollController _scrollController = ScrollController();
  int _previousLineIndex = -1;
  int _previousDialogueLength = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted || _isScrolling) return;

    final currentIndex = widget.controller.currentLineIndex;
    final currentLength = widget.controller.currentDialogue.length;

    if (currentIndex != _previousLineIndex || currentLength != _previousDialogueLength) {
      _previousLineIndex = currentIndex;
      _previousDialogueLength = currentLength;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentLine(currentIndex);
      });
    }
  }

  void _scrollToCurrentLine(int index) {
    if (!mounted || _isScrolling || !_scrollController.hasClients) return;
    
    final dialogue = widget.controller.currentDialogue;
    if (index < 0 || index >= dialogue.length) return;

    _isScrolling = true;

    const itemHeight = 120.0;
    final targetOffset = (index * itemHeight) - 100;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    ).then((_) {
      _isScrolling = false;
    }).catchError((error) {
      _isScrolling = false;
      print('Scroll error: $error');
    });
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _FullscreenTranscript(
          controller: widget.controller,
          scrollController: _scrollController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.currentDialogue.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: _openFullscreen,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 73, 73, 73).withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildHeader(showExpandButton: true),
            ),
            const Divider(
              color: Colors.white24,
              height: 1,
              thickness: 1,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: widget.controller.currentDialogue.length,
                itemBuilder: (context, index) {
                  return _buildTranscriptLine(
                    index: index,
                    line: widget.controller.currentDialogue[index],
                    isCurrentLine: index == widget.controller.currentLineIndex,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({bool showExpandButton = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6B5B95).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.subtitles_rounded,
            color: Color(0xFF9B8FD7),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Transcript',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${widget.controller.currentLineIndex + 1} / ${widget.controller.currentDialogue.length}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
        if (showExpandButton) ...[
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.fullscreen,
              color: Color(0xFF9B8FD7),
            ),
            onPressed: _openFullscreen,
            tooltip: 'Fullscreen',
          ),
        ],
      ],
    );
  }

  Widget _buildTranscriptLine({
    required int index,
    required dynamic line,
    required bool isCurrentLine,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentLine 
            ? const Color(0xFF6B5B95).withOpacity(0.4) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentLine 
              ? const Color(0xFF9B8FD7) 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: line.speaker.contains('A')
                        ? [const Color(0xFF7B6BA8), const Color(0xFF6B5B95)]
                        : [const Color(0xFF5B9FD7), const Color(0xFF4A8FC7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    line.speaker.contains('A') ? 'A' : 'B',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  line.speaker,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCurrentLine 
                        ? const Color(0xFF9B8FD7) 
                        : Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              if (isCurrentLine)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B8FD7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Now',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            line.text,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isCurrentLine 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.7),
              fontWeight: isCurrentLine ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Fullscreen Transcript Widget
class _FullscreenTranscript extends StatefulWidget {
  final PodcastController controller;
  final ScrollController scrollController;

  const _FullscreenTranscript({
    required this.controller,
    required this.scrollController,
  });

  @override
  State<_FullscreenTranscript> createState() => _FullscreenTranscriptState();
}

class _FullscreenTranscriptState extends State<_FullscreenTranscript> {
  late final ScrollController _fullscreenScrollController;
  int _previousLineIndex = -1;
  int _previousDialogueLength = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _fullscreenScrollController = ScrollController();
    widget.controller.addListener(_onControllerUpdate);
    
    // Scroll to current position after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLine(widget.controller.currentLineIndex);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _fullscreenScrollController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted || _isScrolling) return;

    final currentIndex = widget.controller.currentLineIndex;
    final currentLength = widget.controller.currentDialogue.length;

    if (currentIndex != _previousLineIndex || currentLength != _previousDialogueLength) {
      _previousLineIndex = currentIndex;
      _previousDialogueLength = currentLength;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentLine(currentIndex);
      });
    }
  }

  void _scrollToCurrentLine(int index) {
    if (!mounted || _isScrolling || !_fullscreenScrollController.hasClients) return;
    
    final dialogue = widget.controller.currentDialogue;
    if (index < 0 || index >= dialogue.length) return;

    _isScrolling = true;

    const itemHeight = 120.0;
    final targetOffset = (index * itemHeight) - 150;

    final maxScroll = _fullscreenScrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _fullscreenScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    ).then((_) {
      _isScrolling = false;
    }).catchError((error) {
      _isScrolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/black_moons_lighter.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B5B95).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.subtitles_rounded,
                        color: Color(0xFF9B8FD7),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Transcript',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.controller.currentLineIndex + 1} / ${widget.controller.currentDialogue.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(
                color: Colors.white24,
                height: 1,
                thickness: 1,
              ),
              
              // Transcript content
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (context, _) {
                    return ListView.builder(
                      controller: _fullscreenScrollController,
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.controller.currentDialogue.length,
                      itemBuilder: (context, index) {
                        final line = widget.controller.currentDialogue[index];
                        final isCurrentLine = index == widget.controller.currentLineIndex;
                        
                        return _buildFullscreenTranscriptLine(
                          index: index,
                          line: line,
                          isCurrentLine: isCurrentLine,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenTranscriptLine({
    required int index,
    required dynamic line,
    required bool isCurrentLine,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCurrentLine 
            ? const Color(0xFF6B5B95).withOpacity(0.5) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentLine 
              ? const Color(0xFF9B8FD7) 
              : Colors.transparent,
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: line.speaker.contains('A')
                        ? [const Color(0xFF7B6BA8), const Color(0xFF6B5B95)]
                        : [const Color(0xFF5B9FD7), const Color(0xFF4A8FC7)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    line.speaker.contains('A') ? 'A' : 'B',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  line.speaker,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCurrentLine 
                        ? const Color(0xFF9B8FD7) 
                        : Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              if (isCurrentLine)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B8FD7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Playing Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            line.text,
            style: TextStyle(
              fontSize: 17,
              height: 1.7,
              color: isCurrentLine 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.75),
              fontWeight: isCurrentLine ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}