import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/screens/courses/widgets/section_header.dart';

/// Card that captures basic metadata for a course — title, academic subject,
/// language, and visibility.
class CourseDetailsCard extends StatelessWidget {
  const CourseDetailsCard({
    Key? key,
    required this.title,
    required this.subject,
    required this.language,
    required this.visibility,
    required this.onTitleChanged,
    required this.onSubjectChanged,
    required this.onLanguageChanged,
    required this.onVisibilityChanged,
    this.titleError = false,
    this.subjectError = false,
    this.languageError = false,
    this.visibilityError = false,
  }) : super(key: key);

  // ──────────────────────────────────────────────────────────────────────────
  // External state
  // ──────────────────────────────────────────────────────────────────────────
  final String title;
  final String subject;
  final String language;
  final String visibility;

  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onSubjectChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<String> onVisibilityChanged;

  final bool titleError;
  final bool subjectError;
  final bool languageError;
  final bool visibilityError;

  // ──────────────────────────────────────────────────────────────────────────
  // Data
  // ──────────────────────────────────────────────────────────────────────────
  static const List<String> _subjects = [
    'Accounting',
    'Art',
    'Biology',
    'Business',
    'Chemistry',
    'Computer Science',
    'Economics',
    'English',
    'French',
    'Geography',
    'History',
    'Mathematics',
    'Music',
    'Physics',
    'Physical Education',
    'Psychology',
    'Spanish',
  ];

  static const List<String> _languages = ['English', 'Spanish'];
  static const List<String> _visibilities = ['Public', 'Friends', 'Private'];

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────
  void _showPicker(BuildContext context,
      {required List<String> items,
      required String currentValue,
      required ValueChanged<String> onSelected}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 26,
              squeeze: 1,
              scrollController: FixedExtentScrollController(
                initialItem: items.indexOf(
                    currentValue.isNotEmpty ? currentValue : items.first),
              ),
              onSelectedItemChanged: (i) => onSelected(items[i]),
              children: items.map(Text.new).toList(),
            ),
          ),
          CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          )
        ]),
      ),
    );
  }

  Widget _dropdownField(BuildContext context,
      {required String label,
      required String value,
      required List<String> items,
      required ValueChanged<String> onChanged,
      bool hasError = false}) {
    return GestureDetector(
      onTap: () => _showPicker(context,
          items: items, currentValue: value, onSelected: onChanged),
      child: _BorderedContainer(
        hasError: hasError,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value.isEmpty ? label : value,
                style: TextStyle(
                    fontSize: 12,
                    color: value.isEmpty ? Colors.grey : Colors.white)),
            const Icon(CupertinoIcons.chevron_down,
                size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title
        const _Label('Title'),
        const SizedBox(height: 4),
        _BorderedContainer(
          hasError: titleError,
          child: TextField(
            maxLength: 30,
            onChanged: onTitleChanged,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Enter course title',
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              counterText: '',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              suffix: Text('${title.length}/30',
                  style: const TextStyle(fontSize: 12)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Subject
        const _Label('Subject'),
        const SizedBox(height: 4),
        _dropdownField(context,
            label: 'Select subject',
            value: subject,
            items: _subjects,
            onChanged: onSubjectChanged,
            hasError: subjectError),
        const SizedBox(height: 12),

        // Language & Visibility (same row)
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const _Label('Language'),
              const SizedBox(height: 4),
              _dropdownField(context,
                  label: 'Select language',
                  value: language,
                  items: _languages,
                  onChanged: onLanguageChanged,
                  hasError: languageError),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const _Label('Visibility'),
              const SizedBox(height: 4),
              _dropdownField(context,
                  label: 'Select visibility',
                  value: visibility.isEmpty ? 'Public' : visibility,
                  items: _visibilities,
                  onChanged: onVisibilityChanged,
                  hasError: visibilityError),
            ]),
          ),
        ]),
      ]),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ──────────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.white));
}

class _BorderedContainer extends StatelessWidget {
  const _BorderedContainer(
      {Key? key, this.child, this.padding, this.hasError = false})
      : super(key: key);
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hasError ? Colors.red : greyBorder),
      ),
      child: child,
    );
  }
}
