import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/course_controller.dart';
import 'package:lumi_learn_app/screens/main/main_screen.dart';
import 'package:lumi_learn_app/widgets/app_scaffold_home.dart';

/// A Flutter version of the React "CourseCreation" component.
class CourseCreation extends StatefulWidget {
  const CourseCreation({Key? key}) : super(key: key);

  @override
  State<CourseCreation> createState() => _CourseCreationState();
}

class _CourseCreationState extends State<CourseCreation> {
  List<File> selectedFiles = [];
  List<File> selectedImages = [];
  String text = "";
  String courseTitle = "";
  String courseDescription = "";

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
      type: pickImages ? FileType.image : FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final fileList = result.paths.map((path) => File(path!)).toList();
        if (pickImages) {
          selectedImages.addAll(fileList);
        } else {
          selectedFiles.addAll(fileList);
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              /// CARD HEADER
              Text(
                "Create New Course",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
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
                    _buildSectionHeader(
                      icon: Icons.menu_book,
                      title: "Course Details",
                      context: context,
                    ),
                    const SizedBox(height: 10),

                    // Course Title
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
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: greyBorder),
                          ),
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => courseTitle = value),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              hintText: "Enter course title",
                              hintStyle:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Course Description
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
                            color: Colors.grey[800],
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
              _buildSectionHeader(
                icon: Icons.upload_file,
                title: "Add Files",
                context: context,
              ),
              _buildDropZone(
                onTap: () => handleFileChange(pickImages: false),
                label: "documents",
                subLabel: "PDF, DOC, PPT, XLS, etc.",
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
                            color: Colors.grey[800],
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
                                icon: const Icon(
                                  Icons.close,
                                  size: 16,
                                ),
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
              _buildSectionHeader(
                icon: Icons.image,
                title: "Add Images",
                context: context,
              ),
              _buildDropZone(
                onTap: () => handleFileChange(pickImages: true),
                label: "images",
                subLabel: "PNG, JPG, GIF, etc.",
              ),
              if (selectedImages.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  height: 72, // Ensures enough height for images
                  child: SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Enable horizontal scrolling
                    child: Row(
                      children: List.generate(selectedImages.length, (index) {
                        final imageFile = selectedImages[index];

                        return Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Image preview
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.file(
                                    imageFile,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Remove button
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
              _buildSectionHeader(
                icon: Icons.text_fields,
                title: "Add Text",
                context: context,
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 150, // Set max height, allows scrolling inside
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900, // Background color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  border: Border.all(
                      color: greyBorder), // Border applied to the container
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10), // Padding inside the container
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Allows scrolling when text exceeds max height
                  child: TextField(
                    minLines: 4,
                    maxLines:
                        null, // Allows unlimited input, but scrolls after max height is reached
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white), // White text color
                    cursorColor: Colors.white, // White cursor
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors
                          .transparent, // Keep it transparent since the Container has the background color
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10, // Reduce top and bottom padding
                      ),
                      hintText: "Enter course content here...",
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey), // Hint text styling
                      border: InputBorder
                          .none, // Removes default border from TextField
                    ),
                    onChanged: (value) => setState(() => text = value),
                  ),
                ),
              ),

              const Divider(height: 40),

              /// SUMMARY OF SELECTED ITEMS
              if (totalItems > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8), // Rounded bottom-left corner
                      topRight:
                          Radius.circular(8), // Rounded bottom-right corner
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header row with total items badge
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
                              border: Border.all(
                                color: greyBorder,
                              ),
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

                      /// Badges for each type of content
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (selectedFiles.isNotEmpty)
                            _buildBadge(
                              icon: Icons.file_copy,
                              label:
                                  "${selectedFiles.length} file${selectedFiles.length != 1 ? "s" : ""}",
                            ),
                          if (selectedImages.isNotEmpty)
                            _buildBadge(
                              icon: Icons.image_outlined,
                              label:
                                  "${selectedImages.length} image${selectedImages.length != 1 ? "s" : ""}",
                            ),
                          if (text.trim().isNotEmpty)
                            _buildBadge(
                              icon: Icons.text_fields,
                              label: "Text",
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

              // const SizedBox(height: 24),

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
                        // Additional fields as needed.
                      });

                      // Navigate immediately back to the HomeScreen.
                      Get.offAll(() => MainScreen());

                      // Initiate the createCourse request in the background.
                      courseController
                          .createCourse(
                        title: courseTitle,
                        description: courseDescription,
                        files: [...selectedFiles, ...selectedImages],
                        content: text,
                      )
                          .then((courseId) {
                        // Once complete, update the placeholder course with real data.
                        courseController.updatePlaceholderCourse(tempId, {
                          "id": courseId,
                          "loading": false,
                          // Update any additional fields from the backend if needed.
                        });
                        courseController.removePlaceholderCourse(tempId);
                      }).catchError((error) {
                        // Remove the placeholder if there's an error.
                        courseController.removePlaceholderCourse(tempId);
                        // Optionally, show an error notification.
                        Get.snackbar("Error", "Failed to create course");
                      });
                    },
                    icon: const Icon(Icons.add,
                        color: Colors.black), // Ensure icon is also black
                    label: const Text(
                      "Create Course",
                      style: TextStyle(color: Colors.black), // Make text black
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White button background
                      foregroundColor: Colors.black, // Black text and icon
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(8), // Rounded bottom-left corner
                          bottomRight:
                              Radius.circular(8), // Rounded bottom-right corner
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
    );
  }

  /// Builds a small "badge" widget to mimic the React <Badge>.
  Widget _buildBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: greyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Builds a section header (icon + title) similar to the React code’s <h3>.
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  /// Mimics the dashed-border drop zone in React for uploading files/images.
  Widget _buildDropZone({
    required VoidCallback onTap,
    required String label,
    required String subLabel,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 98,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: greyBorder,
            style: BorderStyle.solid,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  children: [
                    const TextSpan(
                      text: "Click to upload ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white), // Make this part bold
                    ),
                    TextSpan(
                      text: label, // Keep the provided label as normal text
                    ),
                  ],
                ),
              ),
              Text(
                subLabel,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
