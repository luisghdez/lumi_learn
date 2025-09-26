// source_viewer_modal.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

/// Helper function to determine if a file is an image based on its extension
bool _isImageFile(String pathOrUrl) {
  final extension = pathOrUrl.toLowerCase().split('.').last;
  return ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].contains(extension);
}

/// Helper function to determine if a file is a text file based on its extension
bool _isTxtFile(String pathOrUrl) {
  final extension = pathOrUrl.toLowerCase().split('.').last;
  return extension == 'txt';
}

/// Helper function to determine if a source is text-based
bool _isTextSource(Map<String, dynamic> source) {
  final fileName = (source['fileName'] ?? '').toString();
  final content = (source['content'] ?? source['text'] ?? '').toString();
  return fileName.isEmpty && content.isNotEmpty;
}

/// Open the appropriate viewer modal (PDF, Image, Text, or TXT file) based on source type
void showSourceViewerModal(BuildContext context, String pathOrUrl,
    {String? originalName,
    int? initialPageNumber,
    Map<String, dynamic>? source}) {
  // If source is provided and it's an inline text source, show text viewer
  if (source != null && _isTextSource(source)) {
    showTextViewerModal(context, source, originalName: originalName);
  } else if (_isTxtFile(pathOrUrl)) {
    showTxtFileViewerModal(context, pathOrUrl, originalName: originalName);
  } else if (_isImageFile(pathOrUrl)) {
    showImageViewerModal(context, pathOrUrl, originalName: originalName);
  } else {
    showPdfViewerModal(context, pathOrUrl,
        originalName: originalName, initialPageNumber: initialPageNumber);
  }
}

/// Open the bottom-sheet modal with text content
void showTextViewerModal(BuildContext context, Map<String, dynamic> source,
    {String? originalName}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    isDismissible: true,
    builder: (_) => _TextViewerModal(
      source: source,
      originalName: originalName,
    ),
  );
}

/// Open the bottom-sheet modal with a TXT file URL or storage-relative path
void showTxtFileViewerModal(BuildContext context, String txtPathOrUrl,
    {String? originalName}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    isDismissible: true,
    builder: (_) => _TxtFileViewerModal(
      input: txtPathOrUrl,
      originalName: originalName,
    ),
  );
}

/// Open the bottom-sheet modal with an Image URL or a storage-relative path.
void showImageViewerModal(BuildContext context, String imagePathOrUrl,
    {String? originalName}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    isDismissible: true,
    builder: (_) => _ImageViewerModal(
      input: imagePathOrUrl,
      originalName: originalName,
    ),
  );
}

/// Open the bottom-sheet modal with a PDF URL or a storage-relative path.
/// Examples:
///   showPdfViewerModal(context,
///     'https://.../courses/A1Y8ynTKM-evd2lZP90gw.pdf');
///   showPdfViewerModal(context, 'courses/A1Y8ynTKM-evd2lZP90gw.pdf');
void showPdfViewerModal(BuildContext context, String pdfPathOrUrl,
    {String? originalName, int? initialPageNumber}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag:
        false, // Disable drag to dismiss to prevent conflict with PDF scrolling
    isDismissible: true, // Still allow tapping outside or using close button
    builder: (_) => _PdfViewerModal(
      input: pdfPathOrUrl,
      originalName: originalName,
      initialPageNumber: initialPageNumber,
    ),
  );
}

class _PdfViewerModal extends StatelessWidget {
  final String input;
  final int? initialPageNumber;
  final String? originalName;
  const _PdfViewerModal(
      {required this.input, this.originalName, this.initialPageNumber});

  static const _fallbackHost =
      'https://storage.googleapis.com/lumi-7f941.firebasestorage.app';

  String _resolveUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) throw ArgumentError('Empty PDF URL/path');
    final uri = Uri.tryParse(s);
    if (uri != null && uri.hasScheme && uri.hasAuthority) return s;
    // treat as storage-relative path
    final path = s.replaceFirst(RegExp(r'^/+'), '');
    return '$_fallbackHost/$path';
  }

  String _fileName(String urlOrPath) {
    final u = Uri.tryParse(urlOrPath.trim());
    final last = (u?.pathSegments.isNotEmpty ?? false)
        ? u!.pathSegments.last
        : urlOrPath.split('/').last;
    return last.isEmpty ? 'PDF' : last;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveUrl(input);
    final title = (originalName != null && originalName!.trim().isNotEmpty)
        ? originalName!.trim()
        : _fileName(resolvedUrl);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf,
                    color: Color(0xFFB388FF), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          // ── Content (streaming PDF) ─────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SfPdfViewer.network(
                  resolvedUrl,
                  // Enable natural scrolling
                  scrollDirection: PdfScrollDirection.vertical,
                  pageLayoutMode: PdfPageLayoutMode.continuous,
                  // Optional UX niceties:
                  canShowPaginationDialog: true,
                  canShowScrollHead: true,
                  initialPageNumber:
                      (initialPageNumber == null || initialPageNumber! < 1)
                          ? 1
                          : initialPageNumber!,
                  onDocumentLoadFailed: (details) {
                    // Syncfusion will show its own error UI; this is just a log.
                    // You can wire in a custom Snackbar if you prefer.
                    // debugPrint('PDF load failed: ${details.error}');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageViewerModal extends StatelessWidget {
  final String input;
  final String? originalName;

  const _ImageViewerModal({
    required this.input,
    this.originalName,
  });

  static const _fallbackHost =
      'https://storage.googleapis.com/lumi-7f941.firebasestorage.app';

  String _resolveUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) throw ArgumentError('Empty image URL/path');
    final uri = Uri.tryParse(s);
    if (uri != null && uri.hasScheme && uri.hasAuthority) return s;
    // treat as storage-relative path
    final path = s.replaceFirst(RegExp(r'^/+'), '');
    return '$_fallbackHost/$path';
  }

  String _fileName(String urlOrPath) {
    final u = Uri.tryParse(urlOrPath.trim());
    final last = (u?.pathSegments.isNotEmpty ?? false)
        ? u!.pathSegments.last
        : urlOrPath.split('/').last;
    return last.isEmpty ? 'Image' : last;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveUrl(input);
    final title = (originalName != null && originalName!.trim().isNotEmpty)
        ? originalName!.trim()
        : _fileName(resolvedUrl);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.image, color: Color(0xFFB388FF), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          // ── Content (Image with zoom and pan) ──────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black12,
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: Center(
                      child: Image.network(
                        resolvedUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFFB388FF),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.white54,
                                  size: 48,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextViewerModal extends StatelessWidget {
  final Map<String, dynamic> source;
  final String? originalName;

  const _TextViewerModal({
    required this.source,
    this.originalName,
  });

  String _getTitle() {
    return originalName?.trim().isNotEmpty == true
        ? originalName!.trim()
        : source['title']?.toString().trim().isNotEmpty == true
            ? source['title'].toString().trim()
            : 'Text Source';
  }

  String _getContent() {
    return (source['content'] ?? source['text'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();
    final content = _getContent();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.article, color: Color(0xFFB388FF), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          // ── Content (Scrollable Text) ───────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TxtFileViewerModal extends StatefulWidget {
  final String input;
  final String? originalName;

  const _TxtFileViewerModal({
    required this.input,
    this.originalName,
  });

  @override
  State<_TxtFileViewerModal> createState() => _TxtFileViewerModalState();
}

class _TxtFileViewerModalState extends State<_TxtFileViewerModal> {
  String? _content;
  bool _isLoading = true;
  String? _error;

  static const _fallbackHost =
      'https://storage.googleapis.com/lumi-7f941.firebasestorage.app';

  String _resolveUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) throw ArgumentError('Empty TXT URL/path');
    final uri = Uri.tryParse(s);
    if (uri != null && uri.hasScheme && uri.hasAuthority) return s;
    // treat as storage-relative path
    final path = s.replaceFirst(RegExp(r'^/+'), '');
    return '$_fallbackHost/$path';
  }

  String _fileName(String urlOrPath) {
    final u = Uri.tryParse(urlOrPath.trim());
    final last = (u?.pathSegments.isNotEmpty ?? false)
        ? u!.pathSegments.last
        : urlOrPath.split('/').last;
    return last.isEmpty ? 'Text File' : last;
  }

  @override
  void initState() {
    super.initState();
    _loadTextContent();
  }

  Future<void> _loadTextContent() async {
    try {
      final resolvedUrl = _resolveUrl(widget.input);
      final response = await http.get(
        Uri.parse(resolvedUrl),
        headers: {
          'Accept-Charset': 'utf-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          // Explicitly decode as UTF-8 to handle special characters properly
          _content = utf8.decode(response.bodyBytes);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load file (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading file: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        (widget.originalName != null && widget.originalName!.trim().isNotEmpty)
            ? widget.originalName!.trim()
            : _fileName(widget.input);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description,
                    color: Color(0xFFB388FF), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          // ── Content (Scrollable Text or Loading/Error) ──────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB388FF),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white54,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText(
                              _content ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
