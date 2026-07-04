/// Shared text normalization for classification and keyword matching.
///
/// Folds German umlauts/ß, lowercases, drops periods and collapses whitespace,
/// so keyword lists can be written naturally and still match OCR variants
/// (e.g. "Kündigungsfrist", "KUENDIGUNGSFRIST", "Kuendigungs­frist").
String normalizeForMatching(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    switch (rune) {
      case 0x00E4: // ä
        buffer.write('ae');
      case 0x00F6: // ö
        buffer.write('oe');
      case 0x00FC: // ü
        buffer.write('ue');
      case 0x00DF: // ß
        buffer.write('ss');
      case 0x002E: // .
        buffer.write(' ');
      default:
        buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}
