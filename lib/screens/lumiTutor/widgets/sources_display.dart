import 'package:flutter/material.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/source_viewer_modal.dart';

class SourcesDisplay extends StatelessWidget {
  final List<Map<String, dynamic>> sources;

  const SourcesDisplay({
    Key? key,
    required this.sources,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sources header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.source,
                size: 16,
                color: Colors.cyanAccent.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                'Sources (${sources.length})',
                style: TextStyle(
                  color: Colors.cyanAccent.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Source buttons
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: sources.asMap().entries.map((entry) {
            final index = entry.key;
            final source = entry.value;
            return SourceButton(
              source: source,
              index: index,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SourceButton extends StatelessWidget {
  final Map<String, dynamic> source;
  final int index;

  const SourceButton({
    Key? key,
    required this.source,
    required this.index,
  }) : super(key: key);

  String _getFileType() {
    final fileName = source['file_name']?.toString().toLowerCase() ?? '';
    if (fileName.endsWith('.pdf')) return 'PDF';
    if (fileName.endsWith('.pptx') || fileName.endsWith('.ppt')) return 'PPT';
    if (fileName.endsWith('.jpg') ||
        fileName.endsWith('.jpeg') ||
        fileName.endsWith('.png') ||
        fileName.endsWith('.gif')) return 'IMG';
    return 'TXT';
  }

  IconData _getFileIcon() {
    final fileType = _getFileType();
    switch (fileType) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'PPT':
        return Icons.slideshow;
      case 'IMG':
        return Icons.image;
      default:
        return Icons.description;
    }
  }

  Color _getFileColor() {
    final fileType = _getFileType();
    switch (fileType) {
      case 'PDF':
        return Colors.red;
      case 'PPT':
        return Colors.orange;
      case 'IMG':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _getDisplayName() {
    final fileName = source['fileName']?.toString() ?? 'Unknown';
    final pageNumber = source['pageNumber']?.toString();
    if (pageNumber != null && pageNumber.isNotEmpty) {
      return '$fileName (p.$pageNumber)';
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final page = source['pageNumber'];
          final int? initialPage =
              page is int ? page : (page is String ? int.tryParse(page) : null);
          showPdfViewerModal(
            context,
            source['fileName']?.toString() ?? '',
            initialPageNumber: initialPage,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getFileColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getFileColor().withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getFileIcon(),
                size: 14,
                color: _getFileColor(),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _getDisplayName(),
                  style: TextStyle(
                    color: _getFileColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
