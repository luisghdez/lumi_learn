// lib/screens/podcast/widget/podcast_transcript.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumi_learn_app/screens/podcast/controller/podcast_controller.dart';

class PodcastTranscript extends StatefulWidget {
  final PodcastController controller;

  const PodcastTranscript({Key? key, required this.controller}) : super(key: key);

  @override
  State<PodcastTranscript> createState() => _PodcastTranscriptState();
}

class _PodcastTranscriptState extends State<PodcastTranscript> 
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  int _previousLineIndex = -1;
  int _previousDialogueLength = 0;
  bool _isScrolling = false;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    widget.controller.addListener(_onControllerUpdate);
    _scrollController.addListener(_onUserScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _scrollController.removeListener(_onUserScroll);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onUserScroll() {
    if (_scrollController.position.isScrollingNotifier.value) {
      _userInteracting = true;
    } else {
      // Resume auto-scroll after user stops scrolling
      Future.delayed(const Duration(seconds: 3), () {
        _userInteracting = false;
      });
    }
  }

  void _onControllerUpdate() {
    if (!mounted || _isScrolling) return;

    final currentIndex = widget.controller.currentLineIndex;
    final currentLength = widget.controller.currentDialogue.length;

    if (currentIndex != _previousLineIndex || currentLength != _previousDialogueLength) {
      _previousLineIndex = currentIndex;
      _previousDialogueLength = currentLength;
      
      // Trigger animation for current line
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      // Only auto-scroll if user is not interacting
      if (!_userInteracting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentLine(currentIndex);
        });
      }
    }
  }

  void _scrollToCurrentLine(int index) {
    if (!mounted || _isScrolling || !_scrollController.hasClients) return;

    final dialogue = widget.controller.currentDialogue;
    if (index < 0 || index >= dialogue.length) return;

    _isScrolling = true;

    // Get actual viewport dimensions
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final viewportHeight = renderBox?.size.height ??
        MediaQuery.of(context).size.height * 0.5;

    // Calculate target position to show full item
    // Position item at 30% from top of viewport to ensure bottom is visible
    final targetPosition = viewportHeight * 0.3;

    // Estimate scroll position based on average item distribution
    final maxScroll = _scrollController.position.maxScrollExtent;
    final totalItems = dialogue.length;

    // Calculate approximate item position
    final estimatedItemPosition = totalItems > 1
        ? (index / (totalItems - 1)) * maxScroll
        : 0.0;

    // Adjust to position item at target position in viewport
    final targetOffset = estimatedItemPosition - targetPosition;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    ).then((_) {
      _isScrolling = false;
    }).catchError((error) {
      _isScrolling = false;
      print('Scroll error: $error');
    });
  }

  void _onTranscriptLineTap(int index) {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Visual feedback
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Stop current playback if playing
    if (widget.controller.isPlaying) {
      widget.controller.stopPlayback();
    }
    
    // Jump to the tapped line
    widget.controller.currentLineIndex = index;
    widget.controller.notifyListeners();
    
    // Start playback from this line
    widget.controller.startPlayback();
    
    // Scroll to the tapped line
    _scrollToCurrentLine(index);
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _FullscreenTranscript(
          controller: widget.controller,
          scrollController: _scrollController,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        fullscreenDialog: true,
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
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 16,
                  bottom: 120, // Extra bottom padding for visibility
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: widget.controller.currentDialogue.length,
                itemBuilder: (context, index) {
                  final isCurrentLine = index == widget.controller.currentLineIndex;
                  
                  return AnimatedBuilder(
                    animation: isCurrentLine ? _scaleAnimation : 
                        const AlwaysStoppedAnimation(1.0),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isCurrentLine ? _scaleAnimation.value : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          child: _buildTranscriptLine(
                            index: index,
                            line: widget.controller.currentDialogue[index],
                            isCurrentLine: isCurrentLine,
                            onTap: () => _onTranscriptLineTap(index),
                          ),
                        ),
                      );
                    },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(isCurrentLine ? 18 : 16),
        decoration: BoxDecoration(
          color: isCurrentLine 
              ? const Color(0xFF6B5B95).withOpacity(0.4) 
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentLine 
                ? const Color(0xFF9B8FD7) 
                : Colors.transparent,
            width: isCurrentLine ? 2.5 : 2,
          ),
          boxShadow: isCurrentLine
              ? [
                  BoxShadow(
                    color: const Color(0xFF9B8FD7).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrentLine ? 36 : 32,
                  height: isCurrentLine ? 36 : 32,
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
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isCurrentLine ? 16 : 14,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B8FD7),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9B8FD7).withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 1),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Now',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.white.withOpacity(0.3),
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isCurrentLine ? 16 : 15,
                height: 1.6,
                color: isCurrentLine 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.7),
                fontWeight: isCurrentLine ? FontWeight.w500 : FontWeight.normal,
              ),
              child: Text(line.text),
            ),
          ],
        ),
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

class _FullscreenTranscriptState extends State<_FullscreenTranscript> 
    with TickerProviderStateMixin {
  late final ScrollController _fullscreenScrollController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  int _previousLineIndex = -1;
  int _previousDialogueLength = 0;
  bool _isScrolling = false;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    _fullscreenScrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    widget.controller.addListener(_onControllerUpdate);
    _fullscreenScrollController.addListener(_onUserScroll);
    
    // Scroll to current position after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentLine(widget.controller.currentLineIndex);
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _fullscreenScrollController.removeListener(_onUserScroll);
    _fullscreenScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onUserScroll() {
    if (_fullscreenScrollController.position.isScrollingNotifier.value) {
      _userInteracting = true;
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        _userInteracting = false;
      });
    }
  }

  void _onControllerUpdate() {
    if (!mounted || _isScrolling) return;

    final currentIndex = widget.controller.currentLineIndex;
    final currentLength = widget.controller.currentDialogue.length;

    if (currentIndex != _previousLineIndex || currentLength != _previousDialogueLength) {
      _previousLineIndex = currentIndex;
      _previousDialogueLength = currentLength;
      
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      if (!_userInteracting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentLine(currentIndex);
        });
      }
    }
  }

  void _scrollToCurrentLine(int index) {
    if (!mounted || _isScrolling || !_fullscreenScrollController.hasClients) return;

    final dialogue = widget.controller.currentDialogue;
    if (index < 0 || index >= dialogue.length) return;

    _isScrolling = true;

    // Get actual viewport dimensions
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final viewportHeight = renderBox?.size.height ??
        MediaQuery.of(context).size.height;

    // Calculate target position to show full item
    // Position item at 25% from top of viewport to ensure bottom is fully visible
    final targetPosition = viewportHeight * 0.25;

    // Estimate scroll position based on average item distribution
    final maxScroll = _fullscreenScrollController.position.maxScrollExtent;
    final totalItems = dialogue.length;

    // Calculate approximate item position
    final estimatedItemPosition = totalItems > 1
        ? (index / (totalItems - 1)) * maxScroll
        : 0.0;

    // Adjust to position item at target position in viewport
    final targetOffset = estimatedItemPosition - targetPosition;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    _fullscreenScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
    ).then((_) {
      _isScrolling = false;
    }).catchError((error) {
      _isScrolling = false;
    });
  }

  void _onTranscriptLineTap(int index) {
    HapticFeedback.lightImpact();
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    if (widget.controller.isPlaying) {
      widget.controller.stopPlayback();
    }
    
    widget.controller.currentLineIndex = index;
    widget.controller.notifyListeners();
    widget.controller.startPlayback();
    
    _scrollToCurrentLine(index);
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
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 150, // Extra bottom padding
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.controller.currentDialogue.length,
                      itemBuilder: (context, index) {
                        final line = widget.controller.currentDialogue[index];
                        final isCurrentLine = index == widget.controller.currentLineIndex;
                        
                        return AnimatedBuilder(
                          animation: isCurrentLine ? _scaleAnimation : 
                              const AlwaysStoppedAnimation(1.0),
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isCurrentLine ? _scaleAnimation.value : 1.0,
                              child: _buildFullscreenTranscriptLine(
                                index: index,
                                line: line,
                                isCurrentLine: isCurrentLine,
                                onTap: () => _onTranscriptLineTap(index),
                              ),
                            );
                          },
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(isCurrentLine ? 22 : 20),
        decoration: BoxDecoration(
          color: isCurrentLine 
              ? const Color(0xFF6B5B95).withOpacity(0.5) 
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentLine 
                ? const Color(0xFF9B8FD7) 
                : Colors.transparent,
            width: isCurrentLine ? 3 : 2.5,
          ),
          boxShadow: isCurrentLine
              ? [
                  BoxShadow(
                    color: const Color(0xFF9B8FD7).withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrentLine ? 44 : 40,
                  height: isCurrentLine ? 44 : 40,
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
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isCurrentLine ? 20 : 18,
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B8FD7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9B8FD7).withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 1),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Playing Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Icon(
                    Icons.play_circle_outline,
                    color: Colors.white.withOpacity(0.3),
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isCurrentLine ? 18 : 17,
                height: 1.7,
                color: isCurrentLine 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.75),
                fontWeight: isCurrentLine ? FontWeight.w500 : FontWeight.normal,
              ),
              child: Text(line.text),
            ),
          ],
        ),
      ),
    );
  }
}