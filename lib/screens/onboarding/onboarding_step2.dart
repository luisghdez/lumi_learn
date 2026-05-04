import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/data/subject_catalog.dart';
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
  static final List<_SubjectCategory> _subjectCategories = subjectCatalog
      .map(
        (category) => _SubjectCategory(
          title: category.title,
          subjects: category.subjects
              .map((subject) => _SubjectChoice(title: subject))
              .toList(),
        ),
      )
      .toList();

  final Set<String> _selectedSubjects = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _canContinue => _selectedSubjects.length >= 3;

  List<_SubjectCategory> get _visibleSubjectCategories {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _subjectCategories;

    return _subjectCategories
        .map(
          (category) => _SubjectCategory(
            title: category.title,
            subjects: category.subjects
                .where(
                  (subject) => subject.title.toLowerCase().contains(query),
                )
                .toList(),
          ),
        )
        .where((category) => category.subjects.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    if (widget.username.isEmpty) {
      return "What sparks your curiosity?";
    }
    return "What sparks ${widget.username}'s curiosity?";
  }

  String get _progressText {
    final count = _selectedSubjects.length;
    if (count < 3) {
      return "$count of 3 selected";
    }
    return "$count selected";
  }

  void _handleFinishSetup() async {
    // Call the completion callback to move to video transition with selected subjects
    // The video transition will handle fading out the audio
    widget.onComplete(_selectedSubjects.toList());
  }

  Widget _buildCategoryHeader(String title) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.48),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isTablet) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isTablet ? 560 : double.infinity),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.white,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search subjects',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: isTablet ? 16 : 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.62),
              size: 20,
            ),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.62),
                      size: 18,
                    ),
                  ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.34),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.72),
                width: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectGrid(List<_SubjectChoice> subjects, bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: subjects
            .map(
              (subject) => _SubjectTag(
                subject: subject,
                isSelected: _selectedSubjects.contains(subject.title),
                onTap: () => _toggleSubject(subject.title),
                isTablet: isTablet,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;
    final visibleSubjectCategories = _visibleSubjectCategories;

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
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isTablet ? screenWidth * 0.15 : 24,
                    right: isTablet ? screenWidth * 0.15 : 24,
                    top: 16,
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
                                  const TextSpan(text: 'Choose a '),
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
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: isTablet ? 20 : 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              _progressText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: isTablet ? 16 : 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSearchBar(isTablet),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: isTablet ? screenWidth * 0.15 : 24,
                      right: isTablet ? screenWidth * 0.15 : 24,
                      bottom: _canContinue ? 100 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (visibleSubjectCategories.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: Text(
                                'No subjects found',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.58),
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...visibleSubjectCategories.expand(
                            (category) => [
                              _buildCategoryHeader(category.title),
                              _buildSubjectGrid(category.subjects, isTablet),
                              const SizedBox(height: 24),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
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
                        color: Colors.black.withValues(alpha: 0.3),
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

  const _SubjectChoice({required this.title});
}

class _SubjectCategory {
  final String title;
  final List<_SubjectChoice> subjects;

  const _SubjectCategory({
    required this.title,
    required this.subjects,
  });
}

class _SubjectTag extends StatelessWidget {
  final _SubjectChoice subject;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  const _SubjectTag({
    required this.subject,
    required this.isSelected,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 16,
          vertical: isTablet ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.42),
            width: isSelected ? 1.2 : 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subject.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : Colors.white.withValues(alpha: 0.94),
                fontSize: isTablet ? 17 : 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.black.withValues(alpha: 0.82),
                        size: isTablet ? 18 : 16,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
