import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/widgets/course_step_indicator.dart';
import 'package:lumi_learn_app/screens/courses/widgets/input_type_selection_step.dart';
import 'package:lumi_learn_app/screens/courses/widgets/content_upload_step.dart';
import 'package:lumi_learn_app/screens/courses/widgets/course_details_step.dart';
import 'package:lumi_learn_app/screens/courses/widgets/course_navigation_buttons.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';
import 'package:lumi_learn_app/widgets/app_scaffold_home.dart';

/// A Flutter version of the React "CourseCreation" component.
class CourseCreation extends StatefulWidget {
  final String? classId;
  const CourseCreation({Key? key, this.classId}) : super(key: key);

  @override
  State<CourseCreation> createState() => _CourseCreationState();
}

class _CourseCreationState extends State<CourseCreation>
    with TickerProviderStateMixin {
  List<File> selectedFiles = [];
  List<File> selectedImages = [];
  String text = "";
  String courseTitle = "";
  String courseSubject = "";
  DateTime? _dueDate;
  File? selectedAudioFile;
  String language = "";
  String visibility = "Public";
  bool _submitted = false;
  int _currentStep = 0;
  String? _selectedInputType; // Track selected input type

  // Animation controllers
  late AnimationController _stepController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    _stepController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  /// Compute total items based on selected files, images, and whether text is non-empty.
  int get totalItems =>
      selectedFiles.length +
      selectedImages.length +
      (text.trim().isNotEmpty ? 1 : 0);

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
      // Define max file size (5 MB)
      const int maxFileSize = 10 * 1024 * 1024; // 5MB in bytes

      // Filter out files that are too large
      final validPlatformFiles = result.files.where((pf) {
        if (pf.size > maxFileSize) {
          Get.snackbar(
              "File too large", "File ${pf.name} exceeds the 5MB limit.");
          return false;
        }
        return true;
      }).toList();

      setState(() {
        final fileList =
            validPlatformFiles.map((pf) => File(pf.path!)).toList();
        if (pickImages) {
          // Limit to 10 images
          final available = 10 - selectedImages.length;
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
          // Limit to 2 files
          final available = 10 - selectedFiles.length;
          if (available <= 0) {
            Get.snackbar(
                "Limit reached", "You can only upload up to 10 files.");
            return;
          }
          selectedFiles.addAll(fileList.take(available));
          if (fileList.length > available) {
            Get.snackbar("Limit reached",
                "Only $available files were added. Maximum is 10.");
          }
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
    if (_currentStep < 2) {
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
          // Clear content when going back from step 2 to step 1
          if (_currentStep == 2 && _currentStep - 1 == 1) {
            // Going back to step 2, no clearing needed
          } else if (_currentStep == 1 && _currentStep - 1 == 0) {
            // Going back to step 1 (input selection), clear all content
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
    return courseTitle.trim().isNotEmpty &&
        courseSubject.trim().isNotEmpty &&
        language.isNotEmpty &&
        visibility.isNotEmpty;
  }

  void _createCourse() {
    setState(() {
      _submitted = true;
    });

    if (!_canCreateCourse) {
      Get.snackbar("Missing Information",
          "Please fill all required fields in Course Details.");
      return;
    }

    final courseController = Get.find<CourseController>();

    // Create a temporary ID for the placeholder course.
    final tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";

    // Add a placeholder course with a loading flag to the controller.
    courseController.addPlaceholderCourse({
      "id": tempId,
      "title": courseTitle,
      "description": courseSubject,
      "loading": true,
      "hasEmbeddings": true, // Default to false for placeholder
    });

    // Navigate immediately back to the HomeScreen.
    Get.offAll(() => MainScreen());

    // Initiate the createCourse request in the background.
    courseController
        .createCourse(
      title: courseTitle,
      description: courseSubject,
      files: [...selectedFiles, ...selectedImages],
      dueDate: _dueDate,
      classId: widget.classId,
      content: text,
      language: language,
      visibility: visibility,
    )
        .then((result) {
      courseController.removePlaceholderCourse(tempId);
      courseController.updatePlaceholderCourse(tempId, {
        "id": result['courseId'],
        'totalLessons': result['lessonCount'],
        "loading": false,
        "hasEmbeddings": result['hasEmbeddings'] ?? true,
      });
    }).catchError((error) {
      courseController.removePlaceholderCourse(tempId);
      Get.snackbar("Error", "Failed to create course");
    });
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
        );
      case 1:
        return ContentUploadStep(
          selectedInputType: _selectedInputType ?? "file",
          selectedFiles: selectedFiles,
          selectedImages: selectedImages,
          text: text,
          onFileUpload: () => handleFileChange(pickImages: false),
          onImageUpload: () => handleFileChange(pickImages: true),
          onTextChanged: (value) => setState(() => text = value),
          onRemoveFile: removeFile,
        );
      case 2:
        return CourseDetailsStep(
          courseTitle: courseTitle,
          courseSubject: courseSubject,
          language: language,
          visibility: visibility,
          submitted: _submitted,
          onTitleChanged: (v) => setState(() => courseTitle = v),
          onSubjectChanged: (v) => setState(() => courseSubject = v),
          onLanguageChanged: (v) => setState(() => language = v),
          onVisibilityChanged: (v) => setState(() => visibility = v),
          onSubmittedChanged: () => setState(() => _submitted = true),
          onCreateCourse: _createCourse,
          selectedFiles: selectedFiles,
          selectedImages: selectedImages,
          text: text,
          dueDate: _dueDate,
          classId: widget.classId,
        );
      default:
        return InputTypeSelectionStep(
          selectedInputType: _selectedInputType,
          onInputTypeSelected: _selectInputType,
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
    return AppScaffoldHome(
      body: GestureDetector(
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
                      // 2) back button on the left
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_downward_outlined,
                              color: Colors.white),
                          onPressed: () => Get.back(),
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
    );
  }
}
