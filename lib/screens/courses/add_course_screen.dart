import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/courses/widgets/badge.dart';
import 'package:lumi_learn_app/screens/courses/widgets/drop_zone.dart';
import 'package:lumi_learn_app/screens/courses/widgets/due_date_dropzone.dart';
import 'package:lumi_learn_app/screens/courses/widgets/section_header.dart';
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
  String courseDescription = "";
  DateTime? _dueDate;

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() => _dueDate =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
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
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: greyBorder),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        icon: Icons.menu_book,
                        title: "Course Details",
                      ),
                      const SizedBox(height: 10),

                      // Course Title with a max of 20 characters and counter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Course Title (required)",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: greyBorder),
                            ),
                            child: TextField(
                              maxLength: 30,
                              onChanged: (value) =>
                                  setState(() => courseTitle = value),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                hintText: "Enter course title",
                                hintStyle: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                                border: InputBorder.none,
                                counterText: "",
                                suffix: Text(
                                  "${courseTitle.length}/30",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Course Description Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Course Description",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: greyBorder),
                            ),
                            child: TextField(
                              onChanged: (value) =>
                                  setState(() => courseDescription = value),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                              cursorColor: Colors.white,
                              minLines: 2,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                hintText:
                                    "Briefly describe what this course is about",
                                hintStyle:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: BoxConstraints(
                      maxHeight: selectedFiles.length * 40.0,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = selectedFiles[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    file.path.split('/').last,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => removeFile(index, "file"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    height: 72, // Ensures enough height for images
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(selectedImages.length, (index) {
                          final imageFile = selectedImages[index];
                          return Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.file(
                                      imageFile,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: GestureDetector(
                                      onTap: () => removeFile(index, "image"),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),

                const Divider(height: 40),

                /// TEXT SECTION
                const SectionHeader(
                  icon: Icons.text_fields,
                  title: "Add Text",
                ),
                const SizedBox(height: 6),
                // Main text input with a limit of 2000 characters and a counter
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[1000],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: greyBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: TextField(
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10000),
                            ],
                            minLines: 4,
                            maxLines: null,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                              hintText: "Enter course content here...",
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) => setState(() => text = value),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${text.length}/10,000",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 40),

                if (widget.classId != null) ...[
                  const SectionHeader(
                    icon: Icons.calendar_month,
                    title: "Due Date",
                  ),
                  // const SizedBox(height: 24),
                  DueDateDropZone(
                    dueDate: _dueDate,
                    onTap: _pickDueDate,
                  ),
                  const Divider(height: 40),
                ],

                /// SUMMARY OF SELECTED ITEMS
                if (totalItems > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Course Content",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: greyBorder),
                              ),
                              child: Text(
                                "$totalItems item${totalItems != 1 ? "s" : ""}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (selectedFiles.isNotEmpty)
                              CustomBadge(
                                icon: Icons.file_copy,
                                label:
                                    "${selectedFiles.length} file${selectedFiles.length != 1 ? "s" : ""}",
                              ),
                            if (selectedImages.isNotEmpty)
                              CustomBadge(
                                icon: Icons.image_outlined,
                                label:
                                    "${selectedImages.length} image${selectedImages.length != 1 ? "s" : ""}",
                              ),
                            if (text.trim().isNotEmpty)
                              const CustomBadge(
                                icon: Icons.text_fields,
                                label: "Text",
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                /// CARD FOOTER (Create Button & Info)
                if (totalItems > 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final courseController = Get.find<CourseController>();

                        // Create a temporary ID for the placeholder course.
                        final tempId =
                            "temp_${DateTime.now().millisecondsSinceEpoch}";
                        // Add a placeholder course with a loading flag to the controller.
                        courseController.addPlaceholderCourse({
                          "id": tempId,
                          "title": courseTitle,
                          "description": courseDescription,
                          "loading": true,
                        });

                        // Navigate immediately back to the HomeScreen.
                        Get.offAll(() => MainScreen());

                        // Initiate the createCourse request in the background.
                        courseController
                            .createCourse(
                          title: courseTitle,
                          description: courseDescription,
                          files: [...selectedFiles, ...selectedImages],
                          dueDate: _dueDate,
                          classId: widget.classId,
                          content: text,
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
