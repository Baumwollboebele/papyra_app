import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/features/scan/domain/classification/metadata_extractor.dart';
import 'package:paperless/features/scan/domain/classification/rule_based_classifier.dart';
import 'package:paperless/features/scan/domain/classification/scoring.dart';
import 'package:paperless/features/scan/domain/pipeline/scan_processing.dart';

void main() {
  final classifier = RuleBasedClassifier();
  const extractor = MetadataExtractor();

  // Pretend category ids: key -> id (sonstiges = 99).
  final idByKey = {
    for (var i = 0; i < kDefaultCategories.length; i++)
      kDefaultCategories[i].key: i + 1,
  };
  final sonstigesId = idByKey[CategoryKeys.sonstiges]!;

  ProcessingResult run(String text) => buildProcessingResult(
    combinedText: text,
    classifier: classifier,
    extractor: extractor,
    categoryIdByKey: idByKey,
    fallbackCategoryId: sonstigesId,
  );

  test(
    'confident invoice pre-selects the suggested category and extracts data',
    () {
      final r = run('''
Stadtwerke München GmbH
Rechnung
Rechnungsnummer 2026-1
Rechnungsdatum: 12.03.2026
Gesamtbetrag 89,90 €
IBAN DE89 3704 0044 0532 0130 00
''');
      expect(r.draft.categoryId, idByKey[CategoryKeys.rechnungen]);
      expect(r.draft.suggestedCategoryId, idByKey[CategoryKeys.rechnungen]);
      expect(r.draft.lowConfidence, isFalse);
      expect(r.draft.sender, 'Stadtwerke München GmbH');
      expect(r.draft.documentDate, DateTime(2026, 3, 12));
      expect(r.draft.amountCents, 8990);
      expect(r.draft.iban, 'DE89370400440532013000');
      // Title built from the default template {sender} – {docType} – {date}.
      expect(r.draft.title, 'Stadtwerke München GmbH – Rechnung – 2026-03-12');
      expect(r.draft.level, isNot(ConfidenceLevel.low));
    },
  );

  test('low-confidence text falls back to Sonstiges but records suggestion', () {
    final r = run('Der Betrag ist noch offen.');
    expect(r.draft.categoryId, sonstigesId);
    expect(r.draft.lowConfidence, isTrue);
    // The suggestion is still whatever scored highest (may be rechnungen due to
    // "betrag"), but the selected category is the safe fallback.
    expect(r.draft.categoryId, isNot(equals(r.draft.suggestedCategoryId)));
  });

  test('empty OCR yields a safe default draft', () {
    final r = run('');
    expect(r.draft.categoryId, sonstigesId);
    expect(r.draft.title, 'Dokument');
    expect(r.draft.lowConfidence, isTrue);
  });
}
