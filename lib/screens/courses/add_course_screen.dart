import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/widgets/course_details_card.dart';
import 'package:lumi_learn_app/screens/courses/widgets/drop_zone.dart';
import 'package:lumi_learn_app/screens/courses/widgets/due_date_dropzone.dart';
import 'package:lumi_learn_app/screens/courses/widgets/file_list.dart';
import 'package:lumi_learn_app/screens/courses/widgets/image_preview_list.dart';
import 'package:lumi_learn_app/screens/courses/widgets/section_header.dart';
import 'package:lumi_learn_app/screens/courses/widgets/summary_card.dart';
import 'package:lumi_learn_app/screens/courses/widgets/text_input_section.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';
import 'package:lumi_learn_app/widgets/app_scaffold_home.dart';

/// A Flutter version of the React "CourseCreation" component.
class CourseCreation extends StatefulWidget {
  final String? classId;
  const CourseCreation({Key? key, this.classId}) : super(key: key);

  @override
  State<CourseCreation> createState() => _CourseCreationState();
}

class _CourseCreationState extends State<CourseCreation> {
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
      allowedExtensions: pickImages ? null : ['pdf', 'pptx', 'doc', 'xlsx'],
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
                      // 1) centered title
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Create New Course",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
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

                Text(
                  "Combine files, images, and text to create your course",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Course Details Section
                CourseDetailsCard(
                  title: courseTitle,
                  subject: courseSubject,
                  onTitleChanged: (v) => setState(() => courseTitle = v),
                  onSubjectChanged: (v) => setState(() => courseSubject = v),
                  language: language,
                  visibility: visibility,
                  onLanguageChanged: (v) => setState(() => language = v),
                  onVisibilityChanged: (v) => setState(() => visibility = v),
                  titleError: _submitted && courseTitle.trim().isEmpty,
                  subjectError: _submitted && courseSubject.trim().isEmpty,
                  languageError: _submitted && language.isEmpty,
                  visibilityError: _submitted && visibility.isEmpty,
                ),

                const Divider(height: 40),

                /// FILES SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionHeader(
                      icon: Icons.upload_file,
                      title: "Add Files",
                    ),
                    Text(
                      "${selectedFiles.length}/10",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                DropZone(
                  onTap: () => handleFileChange(pickImages: false),
                  label: "documents",
                  subLabel: "PDF, PPTX, DOC, XLSX",
                ),
                if (selectedFiles.isNotEmpty)
                  FileList(
                    files: selectedFiles,
                    onRemove: (i) => removeFile(i, "file"),
                  ),

                const Divider(height: 40),

                /// IMAGES SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionHeader(
                      icon: Icons.image,
                      title: "Add Images",
                    ),
                    Text(
                      "${selectedImages.length}/10",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                DropZone(
                  onTap: () => handleFileChange(pickImages: true),
                  label: "images",
                  subLabel: "PNG, JPG, JPEG",
                ),
                if (selectedImages.isNotEmpty)
                  ImagePreviewList(
                    images: selectedImages,
                    onRemove: (i) => removeFile(i, "image"),
                  ),

                const Divider(height: 40),

                // submit audio section
                const SectionHeader(
                  icon: Icons.mic,
                  title: "Submit Audio",
                ),
                DropZone(
                  label: "audio",
                  subLabel: "MP3, WAV, AAC",
                  onTap: () => handleFileChange(pickImages: false),
                ),

                const Divider(height: 40),

                /// TEXT SECTION
                const SectionHeader(
                  icon: Icons.text_fields,
                  title: "Add Text",
                ),
                const SizedBox(height: 6),
                // Main text input with a limit of 2000 characters and a counter
                TextInputSection(
                  text: text,
                  onChanged: (v) => setState(() => text = v),
                ),

                const Divider(height: 40),

                /// SUMMARY OF SELECTED ITEMS
                if (totalItems > 0)
                  SummaryCard(
                    totalItems: totalItems,
                    fileCount: selectedFiles.length,
                    imageCount: selectedImages.length,
                    hasText: text.trim().isNotEmpty,
                  ),

                /// CARD FOOTER (Create Button & Info)
                if (totalItems > 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _submitted = true;
                        });

                        final isFormValid = courseTitle.trim().isNotEmpty &&
                            courseSubject.trim().isNotEmpty &&
                            language.isNotEmpty &&
                            visibility.isNotEmpty;

                        if (!isFormValid) {
                          Get.snackbar("Missing Information",
                              "Please fill all required fields in Course Details.");
                          return;
                        }

                        final courseController = Get.find<CourseController>();

                        // Create a temporary ID for the placeholder course.
                        final tempId =
                            "temp_${DateTime.now().millisecondsSinceEpoch}";
                        // Add a placeholder course with a loading flag to the controller.
                        courseController.addPlaceholderCourse({
                          "id": tempId,
                          "title": courseTitle,
                          "description": courseSubject,
                          "loading": true,
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
                          });
                        }).catchError((error) {
                          courseController.removePlaceholderCourse(tempId);
                          Get.snackbar("Error", "Failed to create course");
                        });
                      },
                      icon: const Icon(Icons.add, color: Colors.black),
                      label: const Text(
                        "Create Course",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
