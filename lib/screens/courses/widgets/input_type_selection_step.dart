import 'package:flutter/material.dart';
import 'input_type_card.dart';

class InputTypeSelectionStep extends StatelessWidget {
  final String? selectedInputType;
  final Function(String) onInputTypeSelected;

  const InputTypeSelectionStep({
    Key? key,
    required this.selectedInputType,
    required this.onInputTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Select Input Type",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Choose one input type for your content",
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // File Option
        InputTypeCard(
          icon: Icons.upload_file,
          title: "File",
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
