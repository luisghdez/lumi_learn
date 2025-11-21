import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/widgets/course_step_indicator.dart';
import 'package:lumi_learn_app/screens/courses/widgets/input_type_selection_step.dart';
import 'package:lumi_learn_app/screens/courses/widgets/content_upload_step.dart';
import 'package:lumi_learn_app/screens/courses/widgets/course_navigation_buttons.dart';
import 'package:lumi_learn_app/screens/courses/course_loading_screen.dart';
import 'package:lumi_learn_app/widgets/app_scaffold_home.dart';
import 'package:lumi_learn_app/screens/onboarding/onboarding_select_course_screen.dart';

/// A Flutter version of the React "CourseCreation" component.
class CourseCreation extends StatefulWidget {
  final String? classId;
  final bool fromOnboarding;
  final VideoPlayerController? videoController;
  final AudioPlayer? onboardingAudioPlayer;

  const CourseCreation({
    Key? key,
    this.classId,
    this.fromOnboarding = false,
    this.videoController,
    this.onboardingAudioPlayer,
  }) : super(key: key);

  @override
  State<CourseCreation> createState() => _CourseCreationState();
}

class _CourseCreationState extends State<CourseCreation>
    with TickerProviderStateMixin {
  List<File> selectedFiles = [];
  List<File> selectedImages = [];
  String text = "";
  DateTime? _dueDate;
  File? selectedAudioFile;
  int _currentStep = 0;
  String? _selectedInputType; // Track selected input type

  // Animation controllers
  late AnimationController _stepController;
  late AnimationController _progressController;
  late AnimationController _entryController; // New controller for screen entry
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _entryFadeAnimation; // New animation for screen entry
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

    // Play glow sound if coming from onboarding
    if (widget.fromOnboarding) {
      _playEntrySound();
    }

    // Initialize entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _entryFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    // Initialize step transition animation
    _stepController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize progress bar animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stepController,
      curve: Curves.easeOutCubic,
    ));

    // Start initial animations
    _stepController.forward();
    _progressController.forward();
    _entryController.forward();
  }

  Future<void> _playEntrySound() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/glow.mp3'));
      await _audioPlayer.setVolume(1.5);
      await _audioPlayer.resume();
    } catch (e) {
      print('Error playing entry sound: $e');
    }
  }

  @override
  void dispose() {
    _stepController.dispose();
    _progressController.dispose();
    _entryController.dispose();
    _audioPlayer.dispose();
    if (_shouldDisposeOnboardingAudio) {
      _onboardingAudio.dispose();
    }
    // Dispose video controller if it was passed from onboarding
    widget.videoController?.dispose();
    super.dispose();
  }

  /// Compute total items based on selected files, images, and whether text meets minimum requirement.
  int get totalItems =>
      selectedFiles.length +
      selectedImages.length +
      (text.trim().length >= 500 ? 1 : 0);

  /// Calculate total file size in MB for selected files only (images use count limit)
  double get totalFileSizeMB {
    double totalSize = 0;
    for (File file in selectedFiles) {
      totalSize += file.lengthSync();
    }
    return totalSize / (1024 * 1024); // Convert bytes to MB
  }

  /// Check if text meets minimum character requirement
  bool get textMeetsMinimum => text.trim().length >= 500;

  /// Generic file picker method. If [pickImages] is true, it allows image picking only;
  /// otherwise it allows any file type.
  Future<void> handleFileChange({bool pickImages = false}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      // image branch stays the same
      type: pickImages ? FileType.image : FileType.custom,
      // only apply extensions when NOT picking images
      allowedExtensions: pickImages ? null : ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      // Define max file size per file (10 MB)
      const int maxFileSize = 10 * 1024 * 1024; // 10MB in bytes
      const double maxTotalSize = 25.0; // 25MB total limit for files
      const int maxImageCount = 10; // 10 image count limit

      // Filter out files that are too large individually
      final validPlatformFiles = result.files.where((pf) {
        if (pf.size > maxFileSize) {
          Get.snackbar("File too large",
              "File ${pf.name} exceeds the 10MB individual file limit.");
          return false;
        }
        return true;
      }).toList();

      if (validPlatformFiles.isEmpty) return;

      setState(() {
        final fileList =
            validPlatformFiles.map((pf) => File(pf.path!)).toList();

        if (pickImages) {
          // For images: Use count limit (10 images max)
          final available = maxImageCount - selectedImages.length;
          if (available <= 0) {
            Get.snackbar(
                "Limit reached", "You can only upload up to 10 images.");
            return;
          }
          selectedImages.addAll(fileList.take(available));
          if (fileList.length > available) {
            Get.snackbar("Limit reached",
                "Only $available images were added. Maximum is 10.");
          }
        } else {
          // For files: Use size limit (25MB total)
          double currentFileSize =
              selectedFiles.fold(0.0, (sum, file) => sum + file.lengthSync()) /
                  (1024 * 1024);
          double newFilesSize = validPlatformFiles.fold(
              0.0, (sum, pf) => sum + (pf.size / (1024 * 1024)));
          double projectedFileSize = currentFileSize + newFilesSize;

          if (projectedFileSize > maxTotalSize) {
            Get.snackbar("Size limit exceeded",
                "Adding these files would exceed the 25MB limit for files. Current files: ${currentFileSize.toStringAsFixed(1)}MB");
            return;
          }
          selectedFiles.addAll(fileList);
        }
      });
    }
  }

  Future<void> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac'],
    );

    if (result != null && result.files.isNotEmpty) {
      const int maxFileSize = 10 * 1024 * 1024; // 10MB
      final pf = result.files.first;

      if (pf.size > maxFileSize) {
        Get.snackbar(
            "File too large", "Audio ${pf.name} exceeds the 10MB limit.");
        return;
      }

      setState(() {
        selectedAudioFile = File(pf.path!);
      });
    }
  }

  /// Remove a file or image by index.
  void removeFile(int index, String type) {
    setState(() {
      if (type == "file") {
        selectedFiles.removeAt(index);
      } else {
        selectedImages.removeAt(index);
      }
    });
  }

  void _selectInputType(String inputType) {
    setState(() {
      _selectedInputType = inputType;
    });
    // Automatically advance to next step
    _nextStep();
  }

  void _nextStep() {
    if (_currentStep < 1) {
      _stepController.reverse().then((_) {
        setState(() {
          _currentStep++;
        });
        _stepController.forward();
        _progressController.forward();
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _stepController.reverse().then((_) {
        setState(() {
          // Clear content when going back from step 1 to step 0
          if (_currentStep == 1 && _currentStep - 1 == 0) {
            // Going back to step 0 (input selection), clear all content
            _clearAllContent();
            _selectedInputType = null;
          }
          _currentStep--;
        });
        _stepController.forward();
        _progressController.forward();
      });
    }
  }

  void _handleBackNavigation() {
    if (_currentStep > 0) {
      // If on step 1, go back to step 0
      _previousStep();
    } else {
      // Otherwise, use default back navigation
      Get.back();
    }
  }

  void _showSkipConfirmationDialog() {
    Get.dialog(
      Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Skip creating a course?",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: -0.5,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "You can always create a course later.\nFor now, you can explore existing courses.",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          height: 1.5,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Get.back(),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back(); // Close dialog
                                // Navigate to course selection screen
                                Get.offAll(
                                  () => OnboardingSelectCourseScreen(
                                    onboardingAudioPlayer: _onboardingAudio,
                                  ),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 500),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: true,
    );
  }

  void _clearAllContent() {
    selectedFiles.clear();
    selectedImages.clear();
    text = "";
    selectedAudioFile = null;
  }

  bool get _canProceedToNextStep {
    switch (_currentStep) {
      case 0:
        return _selectedInputType != null;
      case 1:
        return totalItems > 0;
      default:
        return false;
    }
  }

  bool get _canCreateCourse {
    return totalItems > 0;
  }

  void _createCourse() {
    if (!_canCreateCourse) {
      Get.snackbar(
          "Missing Content", "Please add content before creating the course.");
      return;
    }

    final courseController = Get.find<CourseController>();

    // Check if user has available course slots before proceeding
    if (!courseController.checkCourseSlotAvailable()) {
      return; // Popup is shown, don't navigate
    }

    // Stop and dispose onboarding audio if it exists
    if (widget.fromOnboarding) {
      _onboardingAudio.stop();
      _onboardingAudio.dispose();
      _shouldDisposeOnboardingAudio = false; // Already disposed
    }

    // Start the course creation process and get the Future
    final courseCreationFuture = courseController.createCourse(
      files: [...selectedFiles, ...selectedImages],
      dueDate: _dueDate,
      classId: widget.classId,
      content: text,
      language: "English", // Default language
      visibility: "Public", // Default visibility
    );

    // Navigate immediately to the new loading screen with the Future
    Get.offAll(
        () => CourseLoadingScreen(courseCreationFuture: courseCreationFuture));
  }

  Widget _buildStepIndicator() {
    return CourseStepIndicator(
      currentStep: _currentStep,
      progressController: _progressController,
    );
  }

  Widget _buildStepContent() {
    return AnimatedBuilder(
      animation: _stepController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _getCurrentStepWidget(),
          ),
        );
      },
    );
  }

  Widget _getCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return InputTypeSelectionStep(
          selectedInputType: _selectedInputType,
          onInputTypeSelected: _selectInputType,
          fromOnboarding: widget.fromOnboarding,
        );
      case 1:
        return ContentUploadStep(
          selectedInputType: _selectedInputType ?? "file",
          selectedFiles: selectedFiles,
          selectedImages: selectedImages,
          text: text,
          totalFileSizeMB: totalFileSizeMB,
          onFileUpload: () => handleFileChange(pickImages: false),
          onImageUpload: () => handleFileChange(pickImages: true),
          onTextChanged: (value) => setState(() => text = value),
          onRemoveFile: removeFile,
        );
      default:
        return InputTypeSelectionStep(
          selectedInputType: _selectedInputType,
          onInputTypeSelected: _selectInputType,
          fromOnboarding: widget.fromOnboarding,
        );
    }
  }

  Widget _buildNavigationButtons() {
    return CourseNavigationButtons(
      currentStep: _currentStep,
      canProceedToNextStep: _canProceedToNextStep,
      canCreateCourse: _canCreateCourse,
      onPrevious: _previousStep,
      onNext: _nextStep,
      onCreateCourse: _createCourse,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? backgroundWidget;
    if (widget.videoController != null &&
        widget.videoController!.value.isInitialized) {
      backgroundWidget = Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: widget.videoController!.value.size.width,
                height: widget.videoController!.value.size.height,
                child: VideoPlayer(widget.videoController!),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBackNavigation();
        }
      },
      child: AppScaffoldHome(
        backgroundWidget: backgroundWidget,
        body: FadeTransition(
          opacity: _entryFadeAnimation,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    /// CARD HEADER
                    SizedBox(
                      height: 56, // adjust to taste
                      child: Stack(
                        children: [
                          // Back button on the left (hidden when from onboarding)
                          if (!widget.fromOnboarding)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white),
                                onPressed: _handleBackNavigation,
                              ),
                            ),
                          // Skip button on the right (only when from onboarding)
                          if (widget.fromOnboarding)
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: _showSkipConfirmationDialog,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 8),
                                  child: Text(
                                    "Skip",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Step Indicator
                    _buildStepIndicator(),

                    // Step Content
                    _buildStepContent(),

                    // Navigation Buttons
                    _buildNavigationButtons(),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
