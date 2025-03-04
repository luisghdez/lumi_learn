import 'package:flutter/material.dart';
import '../components/futuristic_text_field.dart';
import '../components/futuristic_button.dart';

class SyllabusSearchModal extends StatefulWidget {
  final Function(
    String className,
    String school,
    String crn,
    String professorName,
    String term,
    String additionalInfo,
  ) onSearch;

  const SyllabusSearchModal({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<SyllabusSearchModal> createState() => _SyllabusSearchModalState();
}

class _SyllabusSearchModalState extends State<SyllabusSearchModal> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _crnController = TextEditingController();
  final TextEditingController _profNameController = TextEditingController();
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Use SingleChildScrollView to avoid overflow if the keyboard appears
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Search Syllabus',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            FuturisticTextField(
              controller: _classNameController,
              hintText: 'Class Name',
            ),
            const SizedBox(height: 12),

            FuturisticTextField(
              controller: _schoolController,
              hintText: 'School',
            ),
            const SizedBox(height: 12),

            FuturisticTextField(
              controller: _crnController,
              hintText: 'CRN',
            ),
            const SizedBox(height: 12),

            FuturisticTextField(
              controller: _profNameController,
              hintText: 'Professor Name',
            ),
            const SizedBox(height: 12),

            FuturisticTextField(
              controller: _termController,
              hintText: 'Term / Semester',
            ),
            const SizedBox(height: 12),

            FuturisticTextField(
              controller: _additionalInfoController,
              hintText: 'Additional Info (Optional)',
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FuturisticButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FuturisticButton(
                    text: 'Search',
                    onPressed: () {
                      widget.onSearch(
                        _classNameController.text,
                        _schoolController.text,
                        _crnController.text,
                        _profNameController.text,
                        _termController.text,
                        _additionalInfoController.text,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
