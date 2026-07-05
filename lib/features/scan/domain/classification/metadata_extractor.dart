import 'models.dart';

/// Pure, dependency-free extraction of German document metadata from OCR text.
///
/// Every method is deterministic and side-effect free so it can be unit tested
/// exhaustively and later replaced by an LLM-based extractor behind the same
/// surface. Results are best-effort; the user always confirms them.
class MetadataExtractor {
  const MetadataExtractor();

  static const _monthNames = <String, int>{
    'januar': 1,
    'februar': 2,
    'märz': 3,
    'maerz': 3,
    'april': 4,
    'mai': 5,
    'juni': 6,
    'juli': 7,
    'august': 8,
    'september': 9,
    'oktober': 10,
    'november': 11,
    'dezember': 12,
  };

  static final _numericDate = RegExp(r'\b(\d{1,2})\.(\d{1,2})\.(\d{2,4})\b');
  static final _wordDate = RegExp(
    r'\b(\d{1,2})\.?\s+(' + _monthNames.keys.join('|') + r')\s+(\d{4})\b',
    caseSensitive: false,
  );
  static final _amount = RegExp(
    r'(€\s*)?(\d{1,3}(?:\.\d{3})+|\d+),(\d{2})(\s*(?:€|eur|euro))?',
    caseSensitive: false,
  );
  static final _iban = RegExp(
    r'\b([A-Z]{2}\d{2}(?:\s?[A-Z0-9]{4}){2,7}\s?[A-Z0-9]{1,3})\b',
  );
  static final _legalForm = RegExp(
    r'\b(gmbh|mbh|ag|e\.?\s?v\.?|kg|ohg|ug|se|gbr|gemeinnützige)\b',
    caseSensitive: false,
  );

  static const _datePriorityKeywords = [
    'rechnungsdatum',
    'belegdatum',
    'datum',
    'vom',
    'ausgestellt',
  ];
  static const _amountPriorityKeywords = [
    'gesamtbetrag',
    'rechnungsbetrag',
    'zu zahlen',
    'zahlbetrag',
    'summe',
    'gesamt',
    'endbetrag',
  ];

  /// German cues that introduce a payment due date.
  static const _dueDateCues = [
    'zahlbar bis zum',
    'zahlbar bis',
    'fällig am',
    'fällig bis',
    'faellig am',
    'faellig bis',
    'zahlungsziel',
    'bitte überweisen sie bis',
    'bitte ueberweisen sie bis',
    'zu zahlen bis',
    'zahlung bis',
  ];

  static final _paymentTerm = RegExp(
    r'(?:innerhalb(?:\s+von)?|zahlungsziel[:\s]*|zahlbar\s+innerhalb(?:\s+von)?)'
    r'\s*(\d{1,3})\s*tag',
    caseSensitive: false,
  );

  ExtractedMetadata extract(String text) {
    final sender = extractSender(text);
    final documentDate = extractPrimaryDate(text);
    return ExtractedMetadata(
      sender: sender,
      documentDate: documentDate,
      dueDate: extractDueDate(text, documentDate: documentDate),
      amountCents: extractPrimaryAmountCents(text),
      iban: extractIban(text),
      titleSuggestion: sender,
    );
  }

  /// Detects a payment **due date** from German invoice cues ("zahlbar bis",
  /// "fällig am", "Zahlungsziel"), or computes it from a term
  /// ("zahlbar innerhalb 14 Tagen") relative to [documentDate].
  DateTime? extractDueDate(String text, {DateTime? documentDate}) {
    final lower = text.toLowerCase();

    // 1. An explicit date shortly after a due cue.
    for (final cue in _dueDateCues) {
      var idx = lower.indexOf(cue);
      while (idx >= 0) {
        final start = idx + cue.length;
        final end = (start + 40).clamp(0, text.length);
        final date = _firstDateIn(text.substring(start, end));
        if (date != null) return date;
        idx = lower.indexOf(cue, idx + cue.length);
      }
    }

    // 2. A payment term relative to the document date.
    if (documentDate != null) {
      final m = _paymentTerm.firstMatch(text);
      if (m != null) {
        final days = int.tryParse(m.group(1)!);
        if (days != null && days > 0 && days <= 365) {
          return documentDate.add(Duration(days: days));
        }
      }
    }
    return null;
  }

  DateTime? _firstDateIn(String window) {
    _Positioned<DateTime>? best;
    for (final m in _numericDate.allMatches(window)) {
      final d = _buildDate(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        _normalizeYear(int.parse(m.group(3)!)),
      );
      if (d != null && (best == null || m.start < best.position)) {
        best = _Positioned(d, m.start);
      }
    }
    for (final m in _wordDate.allMatches(window)) {
      final d = _buildDate(
        int.parse(m.group(1)!),
        _monthNames[m.group(2)!.toLowerCase()]!,
        int.parse(m.group(3)!),
      );
      if (d != null && (best == null || m.start < best.position)) {
        best = _Positioned(d, m.start);
      }
    }
    return best?.value;
  }

  // --- Dates -----------------------------------------------------------------

  /// All valid dates found, in order of appearance.
  List<DateTime> extractDates(String text) {
    final results = <_Positioned<DateTime>>[];
    for (final m in _numericDate.allMatches(text)) {
      final d = _buildDate(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        _normalizeYear(int.parse(m.group(3)!)),
      );
      if (d != null) results.add(_Positioned(d, m.start));
    }
    for (final m in _wordDate.allMatches(text)) {
      final month = _monthNames[m.group(2)!.toLowerCase()]!;
      final d = _buildDate(
        int.parse(m.group(1)!),
        month,
        int.parse(m.group(3)!),
      );
      if (d != null) results.add(_Positioned(d, m.start));
    }
    results.sort((a, b) => a.position.compareTo(b.position));
    return results.map((e) => e.value).toList();
  }

  /// The most likely document date, preferring dates near a date keyword.
  DateTime? extractPrimaryDate(String text) {
    final lower = text.toLowerCase();
    final numeric = _numericDate
        .allMatches(text)
        .map(
          (m) => _Positioned(
            _buildDate(
              int.parse(m.group(1)!),
              int.parse(m.group(2)!),
              _normalizeYear(int.parse(m.group(3)!)),
            ),
            m.start,
          ),
        )
        .where((e) => e.value != null);
    final word = _wordDate
        .allMatches(text)
        .map(
          (m) => _Positioned(
            _buildDate(
              int.parse(m.group(1)!),
              _monthNames[m.group(2)!.toLowerCase()]!,
              int.parse(m.group(3)!),
            ),
            m.start,
          ),
        );
    final all = [...numeric, ...word].where((e) => e.value != null).toList();
    if (all.isEmpty) return null;

    _Positioned<DateTime?>? best;
    var bestScore = -1;
    for (final candidate in all) {
      final score = _proximityScore(
        lower,
        candidate.position,
        _datePriorityKeywords,
      );
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }
    return best!.value;
  }

  DateTime? _buildDate(int day, int month, int year) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    if (year < 1900 || year > 2100) return null;
    final d = DateTime(year, month, day);
    if (d.day != day || d.month != month) return null; // rejects e.g. 31.02.
    return d;
  }

  int _normalizeYear(int year) => year < 100 ? 2000 + year : year;

  // --- Amounts ---------------------------------------------------------------

  /// The most likely total, in cents. Prefers amounts near total keywords, then
  /// amounts written with a currency marker, then the largest value.
  int? extractPrimaryAmountCents(String text) {
    final lower = text.toLowerCase();
    int? bestCents;
    var bestScore = -1;
    for (final m in _amount.allMatches(text)) {
      final cents = _parseAmountCents(m);
      if (cents == null) continue;
      final hasCurrency = m.group(1) != null || m.group(4) != null;
      var score =
          _proximityScore(lower, m.start, _amountPriorityKeywords) * 100;
      if (hasCurrency) score += 10;
      // Prefer larger amounts as a final tiebreaker.
      final composite = score * 1000000 + cents.clamp(0, 999999);
      if (composite > bestScore) {
        bestScore = composite;
        bestCents = cents;
      }
    }
    return bestCents;
  }

  /// All monetary amounts in cents, in order of appearance.
  List<int> extractAmounts(String text) {
    final out = <int>[];
    for (final m in _amount.allMatches(text)) {
      final cents = _parseAmountCents(m);
      if (cents != null) out.add(cents);
    }
    return out;
  }

  int? _parseAmountCents(RegExpMatch m) {
    final integerPart = m.group(2)!.replaceAll('.', '');
    final fraction = m.group(3)!;
    final value = int.tryParse('$integerPart$fraction');
    return value;
  }

  // --- IBAN ------------------------------------------------------------------

  /// Returns the first valid IBAN (compact, uppercased) or null.
  String? extractIban(String text) {
    for (final m in _iban.allMatches(text.toUpperCase())) {
      final compact = m.group(1)!.replaceAll(' ', '');
      if (_isValidIban(compact)) return compact;
    }
    return null;
  }

  static bool _isValidIban(String iban) {
    if (iban.length < 15 || iban.length > 34) return false;
    final rearranged = iban.substring(4) + iban.substring(0, 4);
    final buffer = StringBuffer();
    for (final code in rearranged.codeUnits) {
      if (code >= 48 && code <= 57) {
        buffer.writeCharCode(code); // 0-9
      } else if (code >= 65 && code <= 90) {
        buffer.write(code - 55); // A=10 .. Z=35
      } else {
        return false;
      }
    }
    // mod 97 over a long numeric string, chunked to avoid overflow.
    final digits = buffer.toString();
    var remainder = 0;
    for (var i = 0; i < digits.length; i += 7) {
      final chunk =
          '$remainder${digits.substring(i, (i + 7).clamp(0, digits.length))}';
      remainder = int.parse(chunk) % 97;
    }
    return remainder == 1;
  }

  // --- Sender ----------------------------------------------------------------

  /// Heuristic sender = letterhead. Prefers an early line containing a legal
  /// form (GmbH/AG/e.V./KG…); otherwise the first plausible name line.
  String? extractSender(String text) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .take(8)
        .toList();
    if (lines.isEmpty) return null;

    for (final line in lines) {
      if (_legalForm.hasMatch(line) && _looksLikeName(line)) {
        return _tidy(line);
      }
    }
    for (final line in lines) {
      if (_looksLikeName(line)) return _tidy(line);
    }
    return null;
  }

  bool _looksLikeName(String line) {
    if (line.length < 3 || line.length > 70) return false;
    if (_numericDate.hasMatch(line)) return false;
    if (RegExp(r'^\d').hasMatch(line)) return false; // starts with a number
    final letters = RegExp(r'[A-Za-zÄÖÜäöüß]').allMatches(line).length;
    return letters >= 3;
  }

  String _tidy(String line) => line.replaceAll(RegExp(r'\s+'), ' ').trim();

  // --- Helpers ---------------------------------------------------------------

  /// Ranks a candidate by how close and how specific a priority keyword is.
  /// [keywords] are ordered most-specific first; an earlier keyword outranks a
  /// later one. A keyword just before [position] beats one only elsewhere.
  int _proximityScore(String lowerText, int position, List<String> keywords) {
    const window = 40;
    final windowStart = (position - window).clamp(0, lowerText.length);
    final near = lowerText.substring(windowStart, position);
    for (var i = 0; i < keywords.length; i++) {
      if (near.contains(keywords[i])) return 1000 - i;
    }
    for (var i = 0; i < keywords.length; i++) {
      if (lowerText.contains(keywords[i])) return 100 - i;
    }
    return 0;
  }

  // --- Features (used by the classifier) -------------------------------------

  bool containsIban(String text) => extractIban(text) != null;
  bool containsAmount(String text) => _amount.hasMatch(text);
}

class _Positioned<T> {
  const _Positioned(this.value, this.position);
  final T value;
  final int position;
}
