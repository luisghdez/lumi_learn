import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/courses/widgets/drop_zone.dart';
import 'package:lumi_learn_app/screens/courses/widgets/file_list.dart';
import 'package:lumi_learn_app/screens/courses/widgets/image_preview_list.dart';
import 'package:lumi_learn_app/screens/courses/widgets/text_input_section.dart';

class ContentUploadStep extends StatelessWidget {
  final String selectedInputType;
  final List<File> selectedFiles;
  final List<File> selectedImages;
  final String text;
  final double totalFileSizeMB;
  final VoidCallback onFileUpload;
  final VoidCallback onImageUpload;
  final Function(String) onTextChanged;
  final Function(int, String) onRemoveFile;

  const ContentUploadStep({
    Key? key,
    required this.selectedInputType,
    required this.selectedFiles,
    required this.selectedImages,
    required this.text,
    required this.totalFileSizeMB,
    required this.onFileUpload,
    required this.onImageUpload,
    required this.onTextChanged,
    required this.onRemoveFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (selectedInputType) {
      case "file":
        return _buildFileUploadStep();
      case "images":
        return _buildImagesUploadStep();
      case "text":
        return _buildTextInputStep();
      default:
        return _buildFileUploadStep();
    }
  }

  Widget _buildFileUploadStep() {
    return Column(
      children: [
        const Text(
          "Upload Files",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Upload your documents and files",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        /// FILES SECTION
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${totalFileSizeMB.toStringAsFixed(1)}MB / 25MB",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        DropZone(
          onTap: onFileUpload,
          label: "documents",
          subLabel: "PDF",
        ),
        if (selectedFiles.isNotEmpty)
          FileList(
            files: selectedFiles,
            onRemove: (i) => onRemoveFile(i, "file"),
          ),

        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildImagesUploadStep() {
    return Column(
      children: [
        const Text(
          "Upload Images",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Upload your photos and graphics",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
        // const SizedBox(height: 6),

        /// IMAGES SECTION
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "${selectedImages.length}/10",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        DropZone(
          onTap: onImageUpload,
          label: "images",
          subLabel: "PNG, JPG, JPEG",
        ),
        if (selectedImages.isNotEmpty)
          ImagePreviewList(
            images: selectedImages,
            onRemove: (i) => onRemoveFile(i, "image"),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTextInputStep() {
    return Column(
      children: [
        const Text(
          "Add Text Content",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your text content",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Main text input with a limit of 2000 characters and a counter
        TextInputSection(
          text: text,
          onChanged: onTextChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
