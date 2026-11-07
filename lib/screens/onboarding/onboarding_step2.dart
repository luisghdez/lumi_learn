import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumi_learn_app/application/controllers/ap_catalog_controller.dart';
import 'package:lumi_learn_app/screens/ap_catalog/models/ap_subject.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

/// Step 2 of onboarding: select the AP courses the learner is taking.
class OnboardingStep2 extends StatefulWidget {
  final String username;
  final ValueChanged<List<ApSubject>> onComplete;
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
  late final ApCatalogController _catalogController;
  late final bool _ownsCatalogController;
  final Set<String> _selectedCourseIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool get _canContinue => _selectedCourseIds.length >= 3;

  @override
  void initState() {
    super.initState();
    _ownsCatalogController = !Get.isRegistered<ApCatalogController>();
    _catalogController = _ownsCatalogController
        ? Get.put(ApCatalogController())
        : Get.find<ApCatalogController>();
  }

  List<_ApCourseCategory> get _visibleCourseCategories {
    final query = _searchQuery.trim().toLowerCase();
    final courses = _catalogController.subjects.where((course) {
      if (query.isEmpty) return true;
      return course.title.toLowerCase().contains(query) ||
          course.subjectTag.toLowerCase().contains(query);
    });

    return ApCategory.values
        .map(
          (category) => _ApCourseCategory(
            title: category.label,
            courses:
                courses.where((course) => course.category == category).toList(),
          ),
        )
        .where((category) => category.courses.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsCatalogController && Get.isRegistered<ApCatalogController>()) {
      Get.delete<ApCatalogController>();
    }
    super.dispose();
  }

  void _toggleCourse(String courseId) {
    setState(() {
      if (_selectedCourseIds.contains(courseId)) {
        _selectedCourseIds.remove(courseId);
      } else {
        _selectedCourseIds.add(courseId);
      }
    });
  }

  String get _progressText {
    final count = _selectedCourseIds.length;
    if (count < 3) {
      return "$count of 3 selected";
    }
    return "$count selected";
  }

  void _handleFinishSetup() {
    final selectedCourses = _catalogController.subjects
        .where((course) => _selectedCourseIds.contains(course.courseId))
        .toList();
    widget.onComplete(selectedCourses);
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
            hintText: 'Search AP courses',
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

  Widget _buildCourseGrid(List<ApSubject> courses, bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: courses
            .map(
              (course) => _ApCourseTag(
                course: course,
                isSelected: _selectedCourseIds.contains(course.courseId),
                onTap: () => _toggleCourse(course.courseId),
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
    return Obx(() {
      final visibleCourseCategories = _visibleCourseCategories;
      return GestureDetector(
        onHorizontalDragEnd: (details) {
          // Detect swipe right to go back
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 500) {
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
                              Text(
                                'What AP courses\nare you taking?',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: isTablet ? 56 : 40,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  letterSpacing: -1.5,
                                  height: 1.02,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                widget.username.isEmpty
                                    ? 'Select at least 3 so Lumi can personalize your learning.'
                                    : 'Select at least 3 for ${widget.username.trim()} so Lumi can personalize the journey.',
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
                    child: _catalogController.isLoading.value
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : _catalogController.error.value.isNotEmpty
                            ? _CatalogError(
                                message: _catalogController.error.value,
                                onRetry: _catalogController.fetchCatalog,
                              )
                            : SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  left: isTablet ? screenWidth * 0.15 : 24,
                                  right: isTablet ? screenWidth * 0.15 : 24,
                                  bottom: _canContinue ? 100 : 20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (visibleCourseCategories.isEmpty)
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 28),
                                          child: Text(
                                            'No AP courses found',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.58),
                                              fontSize: isTablet ? 16 : 14,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ...visibleCourseCategories.expand(
                                        (category) => [
                                          _buildCategoryHeader(category.title),
                                          _buildCourseGrid(
                                              category.courses, isTablet),
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
                        "Continue",
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
    });
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApCourseCategory {
  final String title;
  final List<ApSubject> courses;

  const _ApCourseCategory({
    required this.title,
    required this.courses,
  });
}

class _ApCourseTag extends StatelessWidget {
  final ApSubject course;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTablet;

  const _ApCourseTag({
    required this.course,
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
              course.title,
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
