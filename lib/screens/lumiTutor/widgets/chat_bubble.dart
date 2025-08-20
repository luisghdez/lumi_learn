import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:lumi_learn_app/application/models/chat_sender.dart'; // ✅ Shared enum
import 'package:lumi_learn_app/screens/lumiTutor/widgets/source_viewer_modal.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final ChatSender sender;
  final List<Map<String, dynamic>>? sources;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.sender,
    this.sources,
  }) : super(key: key);

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
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ),
      );
    } else {
      // Tutor message - Markdown with LaTeX support + inline [Source N] chips
      List<Widget> children = [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: MarkdownBody(
            data: message,
            // ✅ Teach the parser LaTeX delimiters so it emits <math> nodes
            inlineSyntaxes: [
              SourceRefSyntax(),
              MathSyntax(),
            ],
            // Keep GitHub extensions (tables, strikethrough, etc.)
            extensionSet: md.ExtensionSet.gitHubFlavored,
            builders: {
              'math': MathBuilder(),
              'sourceRef': SourceRefBuilder(sources ?? const []),
            },
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.6,
              ),
              h1: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              h2: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              h3: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              h4: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              h5: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              h6: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              strong: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              em: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              // code: TextStyle(
              //   color: Colors.cyanAccent,
              //   backgroundColor: Colors.white.withOpacity(0.1),
              //   fontFamily: 'monospace',
              // ),
              codeblockDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              blockquote: const TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
              blockquoteDecoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.cyanAccent, width: 4),
                ),
              ),
              listBullet: const TextStyle(color: Colors.white),
              tableBorder: TableBorder.all(color: Colors.white24),
              tableColumnWidth: const FlexColumnWidth(),
              tableCellsDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
              ),
              horizontalRuleDecoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white24, width: 1),
                ),
              ),
            ),
            selectable: true,
          ),
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
    final tex = element.textContent; // pure LaTeX (delimiters already stripped)
    final isBlock = element.attributes['display'] == 'block';

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isBlock ? 12.0 : 4.0,
        horizontal: isBlock ? 8.0 : 0.0,
      ),
      child: isBlock
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  tex,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  mathStyle: MathStyle.display,
                ),
              ),
            )
          : Math.tex(
              tex,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              mathStyle: MathStyle.text,
            ),
    );
  }
}

class SourceRefSyntax extends md.InlineSyntax {
  SourceRefSyntax() : super(r'\[Source\s+(\d+)\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    print(match);
    final number = match.group(1) ?? '';
    final el = md.Element.text('sourceRef', number);
    el.attributes['index'] = number;
    parser.addNode(el);
    return true;
  }
}

class SourceRefBuilder extends MarkdownElementBuilder {
  final List<Map<String, dynamic>> sources;
  SourceRefBuilder(this.sources);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String idxStr = element.attributes['index'] ?? element.textContent;
    final int? idx = int.tryParse(idxStr);

    if (idx == null || idx < 1 || idx > sources.length) {
      return Text('[Source $idxStr]',
          style: const TextStyle(color: Colors.cyanAccent));
    }

    final src = sources[idx - 1];
    final fileName = (src['fileName'] ?? '').toString();
    final page = src['pageNumber'];
    final int? initialPage =
        page is int ? page : (page is String ? int.tryParse(page) : null);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
      child: Builder(
        builder: (context) => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: fileName.isEmpty
                ? null
                : () {
                    showPdfViewerModal(
                      context,
                      fileName,
                      initialPageNumber: initialPage,
                    );
                  },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.source, size: 14, color: Colors.cyanAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Source $idx',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
