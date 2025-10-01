import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:lumi_learn_app/application/models/chat_sender.dart'; // ✅ Shared enum
import 'package:lumi_learn_app/screens/lumiTutor/widgets/source_viewer_modal.dart';
import 'package:lumi_learn_app/screens/lumiTutor/widgets/copyIcon.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final ChatSender sender;
  final List<Map<String, dynamic>>? sources;
  final bool isStreaming; // Add this

  const ChatBubble({
    Key? key,
    required this.message,
    required this.sender,
    this.sources,
    this.isStreaming = false,
  }) : super(key: key);

  String truncateWithEllipsis(String text, {int maxLength = 40}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    final bool isUser = sender == ChatSender.user;

    if (isUser) {
      // User message - keep existing design
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: Colors.white12),
          ),
child: IntrinsicWidth(
  child: Text(
    message,
    style: const TextStyle(
      fontSize: 16,
      color: Colors.white,
      height: 1.4,
    ),
  ),
),
        ),
      );
    } else {
      // Tutor message - Markdown with LaTeX support + inline citation chips
      // Build grouped numbering: same fileName shares the same index
      final List<Map<String, dynamic>> srcList = sources ?? const [];
      final Map<String, int> fileNameToIndex = <String, int>{};
      final Map<String, Set<int>> fileNameToPages = <String, Set<int>>{};
      final Map<String, String> fileNameToOriginalName = <String, String>{};
      final List<String> orderedFiles = <String>[];

      // TODO: originalName is just for display, and fileName is the actual file
      for (final s in srcList) {
        final String fileName = (s['fileName'] ?? '').toString();
        final String originalName = (s['originalName'] ?? '').toString();
        if (fileName.isEmpty) continue;
        if (!fileNameToIndex.containsKey(fileName)) {
          fileNameToIndex[fileName] = fileNameToIndex.length + 1;
          orderedFiles.add(fileName);
        }
        if (originalName.isNotEmpty &&
            !fileNameToOriginalName.containsKey(fileName)) {
          fileNameToOriginalName[fileName] = originalName;
        }
        final page = s['pageNumber'];
        final int? p =
            page is int ? page : (page is String ? int.tryParse(page) : null);
        if (p != null) {
          fileNameToPages.putIfAbsent(fileName, () => <int>{}).add(p);
        }
      }

      // Determine which file indices are actually referenced in the message
      final Set<String> citedFiles = <String>{};
      // [Source k] references
      final RegExp sourceRef =
          RegExp(r'\[(?:Source)\s+(\d+)(?:,\s*p\.?\s*(\d+))?\]');
      for (final match in sourceRef.allMatches(message)) {
        final int? idx = int.tryParse(match.group(1) ?? '');
        if (idx != null && idx >= 1 && idx <= srcList.length) {
          final Map<String, dynamic> src = srcList[idx - 1];
          final String fileName = (src['fileName'] ?? '').toString();
          if (fileName.isNotEmpty) citedFiles.add(fileName);
        }
      }
      // [k] references (per-file index)
      final Map<int, String> indexToFileName = {
        for (final e in fileNameToIndex.entries) e.value: e.key
      };
      final RegExp numberRef = RegExp(r'\[(\d+)(?:,\s*p\.?\s*(\d+))?\]');
      for (final match in numberRef.allMatches(message)) {
        final int? idx = int.tryParse(match.group(1) ?? '');
        if (idx != null) {
          final String? fileName = indexToFileName[idx];
          if (fileName != null && fileName.isNotEmpty) {
            citedFiles.add(fileName);
          }
        }
      }
      // DONT DELETE I MIGHT USE LATER!!!!
      // final List<String> filteredFiles = citedFiles.isEmpty
      //     ? <String>[]
      //     : orderedFiles.where((f) => citedFiles.contains(f)).toList();

      List<Widget> children = [

        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 12),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              // ✅ Markdown body
              MarkdownBody(
                data: message,
                inlineSyntaxes: [
                  MathSyntax(),
                  SourceIndexRefSyntax(),
                  NumberRefSyntax()
                ],
                extensionSet: md.ExtensionSet.gitHubFlavored,
                builders: {
                  'math': MathBuilder(),
                  'sourceIndexRef': SourceIndexRefBuilder(srcList, fileNameToIndex, fileNameToPages),
                  'numberRef': NumberRefBuilder(srcList, fileNameToIndex, fileNameToPages),
                  'pre': CopyableCodeBlockBuilder(),
                },
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                  h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.4),
                  h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
                  h3: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                  h4: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                  h5: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4),
                  h6: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.4),
                  strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  em: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                  code: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontFamily: 'monospace'),
                  codeblockDecoration: const BoxDecoration(),
                  blockquote: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                  blockquoteDecoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.cyanAccent, width: 4)),
                  ),
                  listBullet: const TextStyle(color: Colors.white),
                  tableBorder: TableBorder.all(color: Colors.white24),
                  tableColumnWidth: const FlexColumnWidth(),
                  tableCellsDecoration: BoxDecoration(color: Colors.white.withOpacity(0.02)),
                  horizontalRuleDecoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white24, width: 1)),
                  ),
                ),
                selectable: true,
              ),
            ],
          ),
        ),

      ];

      // DONT DELETE I MIGHT USE LATER!!!!
      // Add grouped source list at the bottom if any referenced indices exist
      // if (filteredFiles.isNotEmpty) {
      //   children.add(const SizedBox(height: 8));
      //   // children
      //   //     .add(Divider(color: Colors.white.withOpacity(0.08), height: 20));
      //   children.add(const SizedBox(height: 4));
      //   for (final file in filteredFiles) {
      //     final int idx = fileNameToIndex[file]!;
      //     final String originalName =
      //         (fileNameToOriginalName[file]?.trim().isNotEmpty ?? false)
      //             ? fileNameToOriginalName[file]!.trim()
      //             : file;

      //     children.add(
      //       Padding(
      //         padding: const EdgeInsets.only(bottom: 12),
      //         child: Builder(
      //           builder: (context) => InkWell(
      //             onTap: () {
      //               showSourceViewerModal(
      //                 context,
      //                 file,
      //                 originalName: originalName,
      //                 initialPageNumber: 1,
      //               );
      //             },
      //             borderRadius: BorderRadius.circular(18),
      //             child: Container(
      //               padding:
      //                   const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      //               decoration: BoxDecoration(
      //                 color: Colors.white.withOpacity(0.04),
      //                 borderRadius: BorderRadius.circular(18),
      //                 border: Border.all(color: Colors.white12),
      //               ),
      //               child: Row(
      //                 mainAxisSize: MainAxisSize.min,
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 children: [
      //                   Container(
      //                     padding: const EdgeInsets.symmetric(
      //                         horizontal: 4, vertical: 4),
      //                     decoration: BoxDecoration(
      //                       color: Colors.white.withOpacity(0.12),
      //                       borderRadius: BorderRadius.circular(6),
      //                     ),
      //                     child: Text(
      //                       '[$idx]',
      //                       style: const TextStyle(
      //                         color: Colors.white54,
      //                         fontWeight: FontWeight.w600,
      //                         fontSize: 12,
      //                         height: 1.0,
      //                       ),
      //                     ),
      //                   ),
      //                   const SizedBox(width: 6),
      //                   Text(
      //                     originalName,
      //                     maxLines: 1,
      //                     overflow: TextOverflow.ellipsis,
      //                     style: const TextStyle(
      //                         color: Colors.white54, fontSize: 14),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ),
      //         ),
      //       ),
      //     );
      //   }
      // }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...children,
            if (!isStreaming)
              Align(
                alignment: Alignment.bottomLeft,
                child: InkWell(
                  onTap: () => Clipboard.setData(ClipboardData(text: message)),
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    CopyButton(text: message, label: "Copy all"),
                    ],
                  ),
                ),
              ),

          ],
        );
    }
  }
}

///
/// Custom inline syntax to turn LaTeX spans into <math> nodes.
/// Supported:
///   \( ... \)   → inline
///   \[ ... \]   → block
///   $ ... $     → inline
///   $$ ... $$   → block
///
/// Notes:
/// - We avoid matching "$" inside "$$ ... $$".
/// - We keep patterns conservative (no newlines) which works for typical API output.
///
class MathSyntax extends md.InlineSyntax {
  MathSyntax()
      : super(
          r'(\\\([^\)]+\)│\\\[[^\]]+\\\]|(?<!\$)\$\$[^$\n]+\$\$(?!\$)|(?<!\$)\$[^$\n]+\$(?!\$))'
              .replaceAll('│', '|'),
        );

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final raw = match.group(0)!;

    late String content;
    late bool isBlock;

    if (raw.startsWith(r'\(') && raw.endsWith(r'\)')) {
      content = raw.substring(2, raw.length - 2); // remove \( \)
      isBlock = false;
    } else if (raw.startsWith(r'\[') && raw.endsWith(r'\]')) {
      content = raw.substring(2, raw.length - 2); // remove \[ \]
      isBlock = true;
      // } else if (raw.startsWith('$$') && raw.endsWith('$$')) {
      //   content = raw.substring(2, raw.length - 2); // remove $$
      //   isBlock = true;
    } else {
      // single-dollar inline math
      content = raw.substring(1, raw.length - 1); // remove $
      isBlock = false;
    }

    final el = md.Element.text('math', content);
    el.attributes['display'] = isBlock ? 'block' : 'inline';
    parser.addNode(el);
    return true;
  }
}

class MathBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final tex = element.textContent;
    final isBlock = element.attributes['display'] == 'block';

    if (isBlock) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Copy controls ABOVE the box
          Align(
            alignment: Alignment.centerRight,
            child: CopyButton(text: tex, label: "Copy math"),
          ),
          // ✅ Math container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                tex,
                textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                mathStyle: MathStyle.display,
              ),
            ),
          ),
        ],
      );
    } else {
      return Math.tex(
        tex,
        textStyle: const TextStyle(color: Colors.white, fontSize: 16),
        mathStyle: MathStyle.text,
      );
    }
  }
}

class CopyableCodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String code = element.textContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Copy controls ABOVE the box
        Align(
          alignment: Alignment.centerRight,
          child: CopyButton(text: code, label: "Copy code"),
        ),
        // ✅ Code container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(code,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SourceIndexRefSyntax extends md.InlineSyntax {
  SourceIndexRefSyntax()
      : super(r'\[(?:Source)\s+(\d+)(?:,\s*p\.?\s*(\d+))?\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final idx = match.group(1) ?? '';
    final page = match.group(2);
    final el = md.Element.text('sourceIndexRef', idx);
    el.attributes['index'] = idx;
    if (page != null) el.attributes['page'] = page;
    parser.addNode(el);
    return true;
  }
}

class NumberRefSyntax extends md.InlineSyntax {
  NumberRefSyntax() : super(r'\[(\d+)(?:,\s*p\.?\s*(\d+))?\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final idx = match.group(1) ?? '';
    final page = match.group(2);
    final el = md.Element.text('numberRef', idx);
    el.attributes['index'] = idx;
    if (page != null) el.attributes['page'] = page;
    parser.addNode(el);
    return true;
  }
}

class _CitationChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _CitationChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class SourceIndexRefBuilder extends MarkdownElementBuilder {
  final List<Map<String, dynamic>> sources;
  final Map<String, int> fileNameToIndex;
  final Map<String, Set<int>> fileNameToPages;
  SourceIndexRefBuilder(
      this.sources, this.fileNameToIndex, this.fileNameToPages);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String idxStr = element.attributes['index'] ?? element.textContent;
    final int? srcIdx = int.tryParse(idxStr); // 1-based "Source k"
    final String? pageStr = element.attributes['page'];
    final int? pageFromInline = pageStr != null ? int.tryParse(pageStr) : null;

    if (srcIdx == null || srcIdx < 1 || srcIdx > sources.length) {
      // Fallback: keep what the text had
      return _CitationChip(
          label:
              '[${pageFromInline == null ? idxStr : '$idxStr, p.$pageFromInline'}]');
    }

    final src = sources[srcIdx - 1];
    final fileName = (src['fileName'] ?? src['file_name'] ?? '').toString();

    // Determine page (inline beats data)
    final pageFromData = src['pageNumber'];
    final int? initialPage = pageFromInline ??
        (pageFromData is int
            ? pageFromData
            : (pageFromData is String ? int.tryParse(pageFromData) : null));

    if (initialPage != null && fileName.isNotEmpty) {
      fileNameToPages.putIfAbsent(fileName, () => <int>{}).add(initialPage);
    }

    // ✅ Per-file index (what we want to display)
    final int? fileIdx = fileNameToIndex[fileName];

    // Label like: [1, p.4] or just [1] if no page
    final String label = (fileIdx == null)
        ? '[${pageFromInline == null ? idxStr : '$idxStr, p.$pageFromInline'}]'
        : '[${fileIdx}${initialPage != null ? ', p.$initialPage' : ''}]';

    return Builder(
      builder: (context) => _CitationChip(
        label: label,
        onTap: fileName.isEmpty
            ? null
            : () {
                showSourceViewerModal(
                  context,
                  fileName,
                  originalName:
                      (src['originalName']?.toString().trim().isNotEmpty ??
                              false)
                          ? src['originalName'].toString()
                          : fileName,
                  initialPageNumber: initialPage,
                  source: src,
                );
              },
      ),
    );
  }
}

class NumberRefBuilder extends MarkdownElementBuilder {
  final List<Map<String, dynamic>> sources;
  final Map<String, int> fileNameToIndex;
  final Map<String, Set<int>> fileNameToPages;
  NumberRefBuilder(this.sources, this.fileNameToIndex, this.fileNameToPages);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String idxStr = element.attributes['index'] ?? element.textContent;
    final int? idx = int.tryParse(idxStr);
    final String? pageStr = element.attributes['page'];
    final int? page = pageStr != null ? int.tryParse(pageStr) : null;

    // ✅ Instead of recomputing unique files, use the mapping
    if (idx == null || idx < 1 || idx > fileNameToIndex.length) {
      return _CitationChip(
          label: '[${page == null ? idxStr : '$idxStr p.$page'}]');
    }

    // find the file assigned to this index
    final fileName =
        fileNameToIndex.entries.firstWhere((e) => e.value == idx).key;

    // get page from either inline ref or the source list
    final src = sources.firstWhere(
      (s) => (s['fileName'] ?? '').toString() == fileName,
      orElse: () => const {},
    );
    final pageFromData = src['pageNumber'];
    final int? initialPage = page ??
        (pageFromData is int
            ? pageFromData
            : (pageFromData is String ? int.tryParse(pageFromData) : null));
    if (initialPage != null) {
      fileNameToPages.putIfAbsent(fileName, () => <int>{}).add(initialPage);
    }

    // ✅ Always show file index, and append page if available
    final label = '[${idx}${initialPage != null ? ', p.$initialPage' : ''}]';

    return Builder(
      builder: (context) => _CitationChip(
        label: label,
        onTap: fileName.isEmpty
            ? null
            : () {
                showSourceViewerModal(
                  context,
                  fileName,
                  originalName:
                      (src['originalName']?.toString().trim().isNotEmpty ??
                              false)
                          ? src['originalName'].toString()
                          : fileName,
                  initialPageNumber: initialPage,
                  source: src,
                );
              },
      ),
    );
  }
}
