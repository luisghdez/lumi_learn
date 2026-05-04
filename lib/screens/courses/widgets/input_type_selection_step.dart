import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'input_type_card.dart';

class InputTypeSelectionStep extends StatelessWidget {
  final String? selectedInputType;
  final Function(String) onInputTypeSelected;
  final bool fromOnboarding;

  const InputTypeSelectionStep({
    Key? key,
    required this.selectedInputType,
    required this.onInputTypeSelected,
    this.fromOnboarding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Column(
      children: [
        Text(
          fromOnboarding ? "Create your first course" : "Select Input Type",
          style: fromOnboarding
              ? GoogleFonts.playfairDisplay(
                  fontSize: isTablet ? 34 : 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: -1.5,
                )
              : const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
        ),
        const SizedBox(height: 8),
        Text(
          "Choose one input type for your content",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[400],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // File Option
        InputTypeCard(
          icon: Icons.upload_file,
          title: "Files",
          description: "Upload documents or files",
          examples: "e.g., PDFs like syllabi, presentations, research papers",
          isSelected: selectedInputType == "file",
          onTap: () => onInputTypeSelected("file"),
        ),

        const SizedBox(height: 16),

        // Images Option
        InputTypeCard(
          icon: Icons.image,
          title: "Images",
          description: "Upload photos or graphics",
          examples: "e.g., Pictures of notes, diagrams, whiteboards, textbooks",
          isSelected: selectedInputType == "images",
          onTap: () => onInputTypeSelected("images"),
        ),

        const SizedBox(height: 16),

        // Text Option
        InputTypeCard(
          icon: Icons.text_fields,
          title: "Text",
          description: "Enter text content",
          examples: "e.g., Lecture notes, essays, study guides, summaries",
          isSelected: selectedInputType == "text",
          onTap: () => onInputTypeSelected("text"),
        ),
      ],
    );
  }
}
