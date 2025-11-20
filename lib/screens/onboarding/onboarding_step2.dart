import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

/// Step 2 of onboarding: Subject selection
class OnboardingStep2 extends StatefulWidget {
  final String username;
  final Function(List<String> selectedSubjects) onComplete;
  final VoidCallback onBack;
  final VideoPlayerController videoController;
  final AudioPlayer audioPlayer;

  const OnboardingStep2({
    super.key,
    required this.onComplete,
    required this.onBack,
    required this.videoController,
    required this.audioPlayer,
    this.username = '',
  });

  @override
  State<OnboardingStep2> createState() => _OnboardingStep2State();
}

class _OnboardingStep2State extends State<OnboardingStep2> {
  // Math subjects
  static const List<_SubjectChoice> _mathSubjects = [
    _SubjectChoice(
      title: 'Algebra',
      icon: Icons.functions,
      color: Color(0xFF5DE5E5),
    ),
    _SubjectChoice(
      title: 'Geometry',
      icon: Icons.change_history,
      color: Color(0xFF5DE5E5),
    ),
    _SubjectChoice(
      title: 'Statistics',
      icon: Icons.bar_chart,
      color: Color(0xFF5DE5E5),
    ),
    _SubjectChoice(
      title: 'Calculus',
      icon: Icons.timeline,
      color: Color(0xFF5DE5E5),
    ),
  ];

  // Science subjects
  static const List<_SubjectChoice> _scienceSubjects = [
    _SubjectChoice(
      title: 'Biology',
      icon: Icons.biotech,
      color: Color(0xFF8AE26D),
    ),
    _SubjectChoice(
      title: 'Chemistry',
      icon: Icons.bubble_chart,
      color: Color(0xFF8AE26D),
    ),
    _SubjectChoice(
      title: 'Physics',
      icon: Icons.scatter_plot,
      color: Color(0xFF8AE26D),
    ),
    _SubjectChoice(
      title: 'Earth & Space',
      icon: Icons.public,
      color: Color(0xFF8AE26D),
    ),
    _SubjectChoice(
      title: 'Environmental',
      icon: Icons.eco,
      color: Color(0xFF8AE26D),
    ),
    _SubjectChoice(
      title: 'Computer S.',
      icon: Icons.computer,
      color: Color(0xFF8AE26D),
    ),
  ];

  // Social Studies subjects
  static const List<_SubjectChoice> _socialSubjects = [
    _SubjectChoice(
      title: 'World History',
      icon: Icons.language,
      color: Color(0xFFFFD76F),
    ),
    _SubjectChoice(
      title: 'U.S. History',
      icon: Icons.flag,
      color: Color(0xFFFFD76F),
    ),
    _SubjectChoice(
      title: 'European History',
      icon: Icons.castle,
      color: Color(0xFFFFD76F),
    ),
    _SubjectChoice(
      title: 'Art History',
      icon: Icons.museum,
      color: Color(0xFFFFD76F),
    ),
    _SubjectChoice(
      title: 'Psychology',
      icon: Icons.psychology,
      color: Color(0xFFFFD76F),
    ),
    _SubjectChoice(
      title: 'Sociology',
      icon: Icons.groups,
      color: Color(0xFFFFD76F),
    ),
    _SubjectChoice(
      title: 'Philosophy',
      icon: Icons.lightbulb,
      color: Color(0xFFFFD76F),
    ),
  ];

  // Business & Economics subjects
  static const List<_SubjectChoice> _businessSubjects = [
    _SubjectChoice(
      title: 'Accounting',
      icon: Icons.account_balance,
      color: Color(0xFFF4AA8D),
    ),
    _SubjectChoice(
      title: 'Finance',
      icon: Icons.attach_money,
      color: Color(0xFFF4AA8D),
    ),
    _SubjectChoice(
      title: 'Marketing',
      icon: Icons.campaign,
      color: Color(0xFFF4AA8D),
    ),
    _SubjectChoice(
      title: 'General Business',
      icon: Icons.business_center,
      color: Color(0xFFF4AA8D),
    ),
    _SubjectChoice(
      title: 'Microeconomics',
      icon: Icons.trending_up,
      color: Color(0xFFF4AA8D),
    ),
    _SubjectChoice(
      title: 'Macroeconomics',
      icon: Icons.show_chart,
      color: Color(0xFFF4AA8D),
    ),
  ];

  // Other subjects
  static const List<_SubjectChoice> _otherSubjects = [
    _SubjectChoice(
      title: 'Music',
      icon: Icons.music_note,
      color: Color(0xFF7E7CED),
    ),
    _SubjectChoice(
      title: 'Art & Design',
      icon: Icons.palette,
      color: Color(0xFF7E7CED),
    ),
    _SubjectChoice(
      title: 'Foreign Languages',
      icon: Icons.translate,
      color: Color(0xFF7E7CED),
    ),
  ];

  final Set<String> _selectedSubjects = {};

  bool get _canContinue => _selectedSubjects.length >= 3;

  void _toggleSubject(String title) {
    setState(() {
      if (_selectedSubjects.contains(title)) {
        _selectedSubjects.remove(title);
      } else {
        _selectedSubjects.add(title);
      }
    });
  }

  String get _headerLine {
    final count = _selectedSubjects.length;
    if (count < 3) {
      final remaining = 3 - count;
      if (widget.username.isEmpty) {
        return "Select at least 3 subjects ($count selected, $remaining more needed)";
      }
      return "${widget.username}, select at least 3 subjects ($count selected, $remaining more needed)";
    }
    if (widget.username.isEmpty) {
      return "What sparks your curiosity?";
    }
    return "What sparks ${widget.username}'s curiosity?";
  }

  void _handleFinishSetup() async {
    // Fade out the background music before transitioning
    await _fadeOutBackgroundMusic();

    // Call the completion callback to move to video transition with selected subjects
    widget.onComplete(_selectedSubjects.toList());
  }

  Future<void> _fadeOutBackgroundMusic() async {
    // Fade out over 1 second
    const steps = 10;
    const stepDuration = Duration(milliseconds: 100);

    for (int i = steps; i >= 0; i--) {
      if (!mounted) break;

      final volume = i / steps;
      await widget.audioPlayer.setVolume(volume);
      await Future.delayed(stepDuration);
    }

    // Stop the audio player
    await widget.audioPlayer.stop();
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildSubjectGrid(List<_SubjectChoice> subjects, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: subjects
              .map(
                (subject) => _SubjectCard(
                  subject: subject,
                  isSelected: _selectedSubjects.contains(subject.title),
                  onTap: () => _toggleSubject(subject.title),
                  isTablet: isTablet,
                  cardWidth: cardWidth,
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Detect swipe right to go back
        if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
          widget.onBack();
        }
      },
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: isTablet ? screenWidth * 0.15 : 24,
                right: isTablet ? screenWidth * 0.15 : 24,
                top: 16,
                bottom: _canContinue ? 100 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button at the top
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onBack,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: isTablet ? 28 : 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Header
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.playfairDisplay(
                              fontSize: isTablet ? 60 : 44,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: -1.5,
                            ),
                            children: [
                              TextSpan(text: 'Choose a '),
                              TextSpan(
                                text: 'subject',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: isTablet ? 60 : 44,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          _headerLine,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: isTablet ? 20 : 16,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Math Section
                  _buildCategoryHeader('Math'),
                  _buildSubjectGrid(_mathSubjects, isTablet),
                  const SizedBox(height: 24),

                  // Science Section
                  _buildCategoryHeader('Science'),
                  _buildSubjectGrid(_scienceSubjects, isTablet),
                  const SizedBox(height: 24),

                  // Social Studies Section
                  _buildCategoryHeader('Social Studies'),
                  _buildSubjectGrid(_socialSubjects, isTablet),
                  const SizedBox(height: 24),

                  // Business & Economics Section
                  _buildCategoryHeader('Business & Economics'),
                  _buildSubjectGrid(_businessSubjects, isTablet),
                  const SizedBox(height: 24),

                  // Other Section
                  _buildCategoryHeader('Other'),
                  _buildSubjectGrid(_otherSubjects, isTablet),
                ],
              ),
            ),
          ),
          // Floating button that appears when subjects are selected
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            left: isTablet ? screenWidth * 0.15 : 24,
            right: isTablet ? screenWidth * 0.15 : 24,
            bottom: _canContinue ? 40 : -100,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _canContinue ? 1.0 : 0.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                scale: _canContinue ? 1.0 : 0.8,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _handleFinishSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      "Finish setup",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectChoice {
  final String title;
  final IconData icon;
  final Color color;

  const _SubjectChoice({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _SubjectCard extends StatelessWidget {
  final _SubjectChoice subject;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;
  final double cardWidth;

  const _SubjectCard({
    required this.subject,
    required this.isSelected,
    required this.onTap,
    required this.isTablet,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: cardWidth,
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    subject.color.withOpacity(0.5),
                    subject.color.withOpacity(0.2),
                  ]
                : [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.04),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isSelected
                ? subject.color.withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: subject.color.withOpacity(0.0),
                    blurRadius: 8,
                    spreadRadius: 2,
                    // offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 0,
                    spreadRadius: 0,
                    // offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              subject.icon,
              color: isSelected ? Colors.white : subject.color,
              size: isTablet ? 36 : 32,
            ),
            SizedBox(height: isTablet ? 12 : 10),
            Text(
              subject.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
