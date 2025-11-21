import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/auth/loading_screen.dart';
import 'package:lumi_learn_app/screens/courses/course_overview_screen.dart';
import 'package:lumi_learn_app/screens/courses/add_course_screen.dart';
import 'package:lumi_learn_app/widgets/regular_category_card.dart';

class OnboardingSelectCourseScreen extends StatefulWidget {
  final AudioPlayer? onboardingAudioPlayer;

  const OnboardingSelectCourseScreen({
    Key? key,
    this.onboardingAudioPlayer,
  }) : super(key: key);

  @override
  State<OnboardingSelectCourseScreen> createState() =>
      _OnboardingSelectCourseScreenState();
}

class _OnboardingSelectCourseScreenState
    extends State<OnboardingSelectCourseScreen> with TickerProviderStateMixin {
  final Map<String, List<Map<String, dynamic>>> _coursesBySubject = {};
  final Map<String, bool> _loadingSubjects = {};
  bool _isInitialLoading = true;
  late AnimationController _animationController;
  late final AudioPlayer _audioPlayer;
  late final AudioPlayer _onboardingAudio;
  bool _shouldDisposeOnboardingAudio = false;

  @override
  void initState() {
    super.initState();

    // Initialize audio players
    _audioPlayer = AudioPlayer();
    if (widget.onboardingAudioPlayer != null) {
      _onboardingAudio = widget.onboardingAudioPlayer!;
      _shouldDisposeOnboardingAudio = false;
    } else {
      _onboardingAudio = AudioPlayer();
      _shouldDisposeOnboardingAudio = true;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fetchCoursesBySubject();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    if (_shouldDisposeOnboardingAudio) {
      _onboardingAudio.dispose();
    }
    super.dispose();
  }

  Future<void> _playLoadSound() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/onboarding2.mp3'));
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.resume();
    } catch (e) {
      print('Error playing load sound: $e');
    }
  }

  Future<void> _fetchCoursesBySubject() async {
    final courseController = Get.find<CourseController>();
    final selectedSubjects = courseController.onboardingSelectedSubjects;

    if (selectedSubjects.isEmpty) {
      setState(() {
        _isInitialLoading = false;
      });
      return;
    }

    setState(() {
      _isInitialLoading = true;
      for (var subject in selectedSubjects) {
        _loadingSubjects[subject] = true;
        _coursesBySubject[subject] = [];
      }
    });
    // Reset animation when starting a new load
    _animationController.reset();

    // Fetch courses for each subject (3 per subject)
    final List<Future<void>> fetchFutures =
        selectedSubjects.map((subject) async {
      try {
        final subjectCourses = await courseController.fetchAllCoursesBySubject(
          subject: subject,
          page: 1,
          limit: 3,
        );

        if (mounted) {
          setState(() {
            _coursesBySubject[subject] = subjectCourses;
            _loadingSubjects[subject] = false;
          });
        }
      } catch (e) {
        print('Error fetching courses for $subject: $e');
        if (mounted) {
          setState(() {
            _loadingSubjects[subject] = false;
          });
        }
      }
    }).toList();

    await Future.wait(fetchFutures);

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
      });
      // Play sound and trigger animation when loading finishes
      _playLoadSound();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_animationController.status != AnimationStatus.completed) {
          _animationController.forward();
        }
      });
    }
  }

  String _getGalaxyForCourse(String courseId) {
    // Simple hash-based selection
    final hash = courseId.hashCode.abs();
    final galaxyIndex = (hash % 18) + 1;
    return 'assets/galaxies/galaxy$galaxyIndex.png';
  }

  Widget _buildCoursesBySubject(CourseController courseController) {
    final selectedSubjects = courseController.onboardingSelectedSubjects;

    if (selectedSubjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.explore_off,
              size: 48,
              color: Colors.white60,
            ),
            const SizedBox(height: 12),
            const Text(
              'No subjects selected',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please select subjects during onboarding',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    bool hasAnyCourses =
        _coursesBySubject.values.any((courses) => courses.isNotEmpty);

    if (!hasAnyCourses) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.explore_off,
              size: 48,
              color: Colors.white60,
            ),
            const SizedBox(height: 12),
            const Text(
              'No courses available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Courses will appear here once they are created',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Calculate total course count for global indexing
    int globalCourseIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: selectedSubjects.map<Widget>((subject) {
        final courses = _coursesBySubject[subject] ?? [];
        final isLoading = _loadingSubjects[subject] ?? false;

        if (isLoading) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (courses.isEmpty) {
          return const SizedBox.shrink(); // Don't show empty subjects
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Header
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              // Courses for this subject
              ...courses.asMap().entries.map<Widget>((entry) {
                final course = entry.value;
                final currentIndex = globalCourseIndex++;
                final galaxyImagePath = _getGalaxyForCourse(course['id'] ?? '');
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      (currentIndex * 0.1).clamp(0.0, 0.8),
                      1.0,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: RegularCategoryCard(
                      courseId: course['id'] ?? '',
                      courseName: course['title'] ?? 'Untitled',
                      lessonCount:
                          course['lessonCount'] ?? course['totalLessons'] ?? 0,
                      bookmarkCount: course['savedCount'] ?? 0,
                      imagePath: galaxyImagePath,
                      tags: List<String>.from(course['tags'] ?? []),
                      subject: course['subject'],
                      hasEmbeddings: course['hasEmbeddings'] ?? false,
                      onStartLearning: () async {
                        // Prevent navigation if still loading
                        if (course['loading'] == true) return;

                        courseController.setSelectedCourseId(
                          course['id'],
                          course['title'],
                          course['hasEmbeddings'],
                        );

                        Get.to(
                          () => LoadingScreen(),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 500),
                        );

                        await Future.wait([
                          Future.delayed(const Duration(milliseconds: 1000)),
                          precacheImage(
                            const AssetImage('assets/images/milky_way.png'),
                            context,
                          ),
                        ]);

                        while (courseController.isLoading.value) {
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                        }

                        // Stop and dispose onboarding audio
                        await _onboardingAudio.stop();
                        _onboardingAudio.dispose();
                        _shouldDisposeOnboardingAudio =
                            false; // Already disposed

                        // Navigate to CourseOverviewScreen and clear onboarding stack
                        Get.offAll(
                          () => CourseOverviewScreen(),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;
    final courseController = Get.find<CourseController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/black_moons_lighter.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: screenHeight,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: isTablet ? screenWidth * 0.15 : 24,
                  right: isTablet ? screenWidth * 0.15 : 24,
                  top: 16,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white),
                      onPressed: () {
                        Get.off(
                          () => CourseCreation(
                            fromOnboarding: true,
                            onboardingAudioPlayer: _onboardingAudio,
                          ),
                          transition: Transition.fadeIn,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                    ),

                    // Header
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Select an \nexisting course",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: isTablet ? 60 : 44,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -1.5,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            "Choose a course to get started",
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
                    // Course List by Subject
                    _isInitialLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : _buildCoursesBySubject(courseController),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
