// pdf_viewer_modal.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
