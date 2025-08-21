import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// SmartText widget and helpers – LaTeX aware
///
/// 0. Auto-wrap math-like text in $$…$$ if the model forgot to.
/// 1. Sanitize LaTeX inside math blocks:
///    • Correct missing backslash on “imes” → \times
///    • 3+ underscores (____) → \text{____}
///    • Escape stray underscores → \_
/// 2. Split sanitized math into InlineSpans and render with Math.tex.
/// ─────────────────────────────────────────────────────────────────────────────

/// 0. Detect math-like content and wrap in $$…$$ if needed.
String autoWrapPossibleMath(String src) {
  if (src.contains('\$\$')) return src; // already wrapped

  final mathLike = RegExp(
          // explicit LaTeX commands
          r'(\\(?:int|frac|sqrt|sum|prod|lim|log|sin|cos|tan|pi|theta|alpha|beta|times))'
          // exponent marker
          r'|(\^)'
          // subscripts like _{...} or _x
          r'|(_\{[^}]+\}|_[A-Za-z0-9])'
          // only treat sequences like "3 + 4" or "5500-1400" as math
          r'|(\d+\s*[\^*/=+\-]\s*\d+)'
          // your “imes” fallback
          r'|\bimes\b')
      .hasMatch(src);

  return mathLike ? '\$\$$src\$\$' : src;
}

/// 1. Sanitize and correct LaTeX inside each $$…$$ block.
String sanitizeLatex(String src) {
  return src.replaceAllMapped(
    RegExp(r'\$\$(.*?)\$\$', dotAll: true),
    (m) {
      var inner = m.group(1)!;

      // a) Fix missing backslash on "imes" → \times
      inner = inner.replaceAll(RegExp(r'\bimes\b'), r'\times');

      // b) Blanks: 3+ underscores → \text{____}
      inner = inner.replaceAllMapped(
        RegExp(r'(?<!\\)_{3,}'),
        (mm) => r'\text{' + mm.group(0)! + '}',
      );

      // c) Escape stray single underscores → \_
      inner = inner.replaceAllMapped(
        RegExp(r'(?<!\\)_(?!\{|[A-Za-z0-9]|\\)'),
        (_) => r'\_',
      );

      return '\$\$' + inner + '\$\$';
    },
  );
}

/// 2. Split on $$…$$, sanitize, and build inline spans for RichText.
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          match.group(1)!,
          textStyle: style.copyWith(fontSize: style.fontSize! + 2),
        ),
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

/// 3. SmartText widget – chooses Text or RichText+
///    Math.tex based on presence of $$ delimiters.
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
    // wrap if needed, then sanitize
    final prepared = autoWrapPossibleMath(data);

    if (!prepared.contains('\$\$')) {
      return Text(prepared, style: style, textAlign: align);
    }

    return RichText(
      textAlign: align,
      text: TextSpan(children: buildLatexSpans(prepared, style: style)),
    );
  }
}
