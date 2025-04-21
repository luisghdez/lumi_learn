import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// 0.  Auto‑wrap LaTeX that the model forgot to wrap in $$ … $$
/// ─────────────────────────────────────────────────────────────────────────────
String autoWrapPossibleMath(String src) {
  if (src.contains('\$\$')) return src; // already wrapped

  final mathLike = RegExp(
    r'(\\(int|frac|sqrt|sum|prod|lim|log|sin|cos|tan|pi|theta|alpha|beta|times))' // commands
    r'|(\^)' // exponent ^
    r'|(_\{[^}]+\}|_[A-Za-z0-9])', // subscripts
  ).hasMatch(src);

  return mathLike ? '\$\$$src\$\$' : src;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 1.  Sanitise LaTeX in each $$ … $$ block
///
/// • Fix typo  \imes  →  \times
/// • 3+ underscores  →  \text{____}
/// • stray single _   →  \_   (unless followed by {, alnum or \)
/// ─────────────────────────────────────────────────────────────────────────────
String sanitizeLatex(String src) {
  return src.replaceAllMapped(
    RegExp(r'\$\$(.*?)\$\$', dotAll: true),
    (m) {
      var inner = m.group(1)!;

      // 0)  open‑ai typo:  \imes  →  \times
      inner = inner.replaceAllMapped(
        RegExp(r'(?<=\s)imes(?=\s)'),
        (_) => r'\times',
      );
      // 1) blanks
      inner = inner.replaceAllMapped(
        RegExp(r'(?<!\\)_{3,}'),
        (mm) => r'\text{' + mm.group(0)! + '}',
      );

      // 2) stray single underscore
      inner = inner.replaceAllMapped(
        RegExp(r'(?<!\\)_(?!\{|[A-Za-z0-9]|\\)'),
        (_) => r'\_',
      );

      return '\$\$' + inner + '\$\$';
    },
  );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 2.  Split on $$ … $$, sanitise, and build inline spans
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
      spans.add(TextSpan(
        text: sanitized.substring(start, match.start),
        style: style,
      ));
    }
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Math.tex(
        match.group(1)!,
        textStyle:
            style.copyWith(fontSize: style.fontSize! + 2), // optional bump
      ),
    ));
    start = match.end;
  }

  if (start < sanitized.length) {
    spans.add(TextSpan(
      text: sanitized.substring(start),
      style: style,
    ));
  }

  return spans;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 3.  SmartText widget – LaTeX aware
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
    final prepared = autoWrapPossibleMath(data);

    // No math? → plain Text.
    if (!prepared.contains('\$\$')) {
      return Text(prepared, style: style, textAlign: align);
    }

    return RichText(
      textAlign: align,
      text: TextSpan(children: buildLatexSpans(prepared, style: style)),
    );
  }
}
