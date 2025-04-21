import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Sanitize LaTeX in each $$…$$ block:
///
/// 1) Turn 3+ underscores (____) into \text{____}
/// 2) Escape any lone underscore NOT followed by:
///    • {    (brace subscript)
///    • [A–Za–z0–9] (single‐char subscript)
///    • \    (a backslash—e.g. Greek letters)
/// ─────────────────────────────────────────────────────────────────────────────
String sanitizeLatex(String src) {
  return src.replaceAllMapped(
    RegExp(r'\$\$(.*?)\$\$', dotAll: true),
    (m) {
      var inner = m.group(1)!;

      // 1) Blanks: 3+ underscores → \text{____}
      inner = inner.replaceAllMapped(
        RegExp(r'(?<!\\)_{3,}'),
        (mm) => r'\text{' + mm.group(0)! + '}',
      );

      // 2) Stray single underscores → \_
      inner = inner.replaceAllMapped(
        RegExp(r'(?<!\\)_(?!\{|[A-Za-z0-9]|\\)'),
        (_) => r'\_',
      );

      return '\$\$${inner}\$\$';
    },
  );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Split on $$…$$, sanitize, and build inline spans.
/// ─────────────────────────────────────────────────────────────────────────────
List<InlineSpan> buildLatexSpans(
  String text, {
  required TextStyle style,
}) {
  final sanitized = sanitizeLatex(text);

  final spans = <InlineSpan>[];
  final regex = RegExp(r'\$\$\s*([\s\S]+?)\s*\$\$');
  var start = 0;

  for (final match in regex.allMatches(sanitized)) {
    if (match.start > start) {
      spans.add(
        TextSpan(
          text: sanitized.substring(start, match.start),
          style: style,
        ),
      );
    }
    spans.add(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          match.group(1)!,
          textStyle:
              style.copyWith(fontSize: style.fontSize! + 2), // optional bump
        ),
      ),
    );
    start = match.end;
  }

  if (start < sanitized.length) {
    spans.add(
      TextSpan(
        text: sanitized.substring(start),
        style: style,
      ),
    );
  }

  return spans;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// SmartText widget: if you see “$$”, render with Math.tex; else plain Text.
/// ─────────────────────────────────────────────────────────────────────────────
class SmartText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final TextAlign align;

  const SmartText(
    this.data, {
    Key? key,
    required this.style,
    this.align = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!data.contains('\$\$')) {
      return Text(data, style: style, textAlign: align);
    }
    return RichText(
      textAlign: align,
      text: TextSpan(children: buildLatexSpans(data, style: style)),
    );
  }
}
