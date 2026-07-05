/// Pure title generation from a configurable template.
///
/// Supported tokens: `{sender}`, `{docType}`, `{date}` (date rendered as
/// ISO `yyyy-MM-dd`). Missing fields are dropped and dangling separators
/// ("–" / "-") around them are cleaned up, so the result always reads well.
/// Default template: `{sender} – {docType} – {date}`.
const String kDefaultTitleTemplate = '{sender} – {docType} – {date}';

String generateTitle({
  required String template,
  String? sender,
  String? docType,
  DateTime? date,
}) {
  var result = template
      .replaceAll('{sender}', _clean(sender))
      .replaceAll('{docType}', _clean(docType))
      .replaceAll('{date}', date == null ? '' : _iso(date));

  // Collapse separators left dangling by empty tokens.
  final sep = RegExp(r'\s*[–-]\s*');
  // Repeated separators (from consecutive empty tokens) -> single.
  String previous;
  do {
    previous = result;
    result = result.replaceAll(RegExp(r'[–-]\s*[–-]'), '–');
  } while (result != previous);
  // Leading / trailing separators.
  result = result
      .replaceAll(RegExp(r'^\s*[–-]\s*'), '')
      .replaceAll(RegExp(r'\s*[–-]\s*$'), '');
  // Normalize whitespace.
  result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Guard against a template that collapsed to just a separator.
  if (result.isEmpty ||
      sep.hasMatch(result) && result.replaceAll(sep, '').isEmpty) {
    return 'Dokument';
  }
  return result;
}

String _clean(String? value) => (value ?? '').trim();

String _iso(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
