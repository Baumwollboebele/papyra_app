import 'package:flutter/material.dart';

/// Renders [text] with any occurrences of [terms] visually emphasized. Used to
/// highlight search matches. Matching is case-insensitive and diacritic-naive
/// (it highlights literal term occurrences).
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    required this.text,
    required this.terms,
    this.style,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final List<String> terms;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final cleanedTerms = terms
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (cleanedTerms.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    final highlightStyle = (style ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.primary,
    );

    final lower = text.toLowerCase();
    final matches = <({int start, int end})>[];
    for (final term in cleanedTerms) {
      final t = term.toLowerCase();
      var index = lower.indexOf(t);
      while (index >= 0) {
        matches.add((start: index, end: index + t.length));
        index = lower.indexOf(t, index + t.length);
      }
    }
    matches.sort((a, b) => a.start.compareTo(b.start));

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final m in matches) {
      if (m.start < cursor) continue; // overlapping, skip
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start)));
      }
      spans.add(
        TextSpan(text: text.substring(m.start, m.end), style: highlightStyle),
      );
      cursor = m.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
