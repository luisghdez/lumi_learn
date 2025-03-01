import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

// Local imports
import 'widgets/syllabus_search_modal.dart';
import 'space_game.dart';
import 'components/futuristic_text_field.dart';
import 'components/futuristic_button.dart';

class AddLessonPlanScreen extends StatefulWidget {
  const AddLessonPlanScreen({super.key});

  @override
  State<AddLessonPlanScreen> createState() => _AddLessonPlanScreenState();
}

class _AddLessonPlanScreenState extends State<AddLessonPlanScreen> {
  final TextEditingController _lessonNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  // Store file name after picking
  String? _uploadedFileName;

  // Store syllabus data from modal
  String _className = '';
  String _school = '';
  String _crn = '';
  String _professorName = '';
  String _term = '';
  String _additionalInfo = '';

  /// Opens the Syllabus Search Modal
  void _openSyllabusSearchModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SyllabusSearchModal(
          onSearch: (className, school, crn, professorName, term, additionalInfo) {
            setState(() {
              _className = className;
              _school = school;
              _crn = crn;
              _professorName = professorName;
              _term = term;
              _additionalInfo = additionalInfo;
            });
            Navigator.of(context).pop(); // Close the bottom sheet
          },
        );
      },
    );
  }

  /// Lets user pick a file (document or image) from their device
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any, // or FileType.image, etc.
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _uploadedFileName = result.files.single.name;
      });
    }
  }

  /// Navigates to the spaceship shooting game immediately
  void _createLessonAndPlayGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SpaceGame(
          lessonName: _lessonNameController.text,
          subject: _subjectController.text,
          fileName: _uploadedFileName ?? 'No file',
          className: _className,
          school: _school,
          crn: _crn,
          professorName: _professorName,
          term: _term,
          additionalInfo: _additionalInfo,
        ),
      ),
    );
  }

  /// Builds the main form content.
  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // LESSON NAME
          FuturisticTextField(
            controller: _lessonNameController,
            hintText: 'Lesson Name',
          ),
          const SizedBox(height: 16),
          // SUBJECT
          FuturisticTextField(
            controller: _subjectController,
            hintText: 'Subject',
          ),
          const SizedBox(height: 16),
          // Display the chosen file name (if any)
          if (_uploadedFileName != null)
            Text(
              'Selected file: $_uploadedFileName',
              style: const TextStyle(color: Colors.white),
            ),
          const SizedBox(height: 16),
          // UPLOAD FILE BUTTON with icon
          FuturisticButton(
            text: 'Upload File',
            icon: Icons.upload_file,
            onPressed: _pickFile,
          ),
          const SizedBox(height: 16),
          // SEARCH SYLLABUS BUTTON with icon
          FuturisticButton(
            text: 'Search Syllabus',
            icon: Icons.search,
            onPressed: _openSyllabusSearchModal,
          ),
          const SizedBox(height: 16),
          // CREATE LESSON BUTTON with icon
          FuturisticButton(
            text: 'Create Lesson',
            icon: Icons.play_arrow,
            onPressed: _createLessonAndPlayGame,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen cosmic background
          Positioned.fill(
            child: Image.asset(
              'assets/images/hyper.jpg', // Change to your cosmic background image path
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.7),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top bar with back button and BIG title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CREATE LESSON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 148),
                  // Main form content centered vertically
                  Expanded(
                    child: _buildFormContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
