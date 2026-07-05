import 'package:flutter_test/flutter_test.dart';
import 'package:paperless/core/database/default_categories.dart';
import 'package:paperless/features/scan/domain/classification/models.dart';
import 'package:paperless/features/scan/domain/classification/scoring.dart';

void main() {
  group('confidence bands', () {
    test('maps confidence to high/medium/low', () {
      expect(confidenceLevel(0.9), ConfidenceLevel.high);
      expect(confidenceLevel(0.6), ConfidenceLevel.high);
      expect(confidenceLevel(0.5), ConfidenceLevel.medium);
      expect(confidenceLevel(0.35), ConfidenceLevel.medium);
      expect(confidenceLevel(0.2), ConfidenceLevel.low);
    });
  });

  group('learning boost', () {
    ClassificationResult base() => const ClassificationResult(
      bestKey: CategoryKeys.rechnungen,
      confidence: 0.5,
      scores: {
        CategoryKeys.rechnungen: 4,
        CategoryKeys.vertraege: 1,
        CategoryKeys.sonstiges: 0,
      },
    );

    test('a learned sender flips the best category and raises confidence', () {
      final boosted = boostForLearnedSender(
        base(),
        learnedKey: CategoryKeys.vertraege,
        fallbackKey: CategoryKeys.sonstiges,
      );
      expect(boosted.bestKey, CategoryKeys.vertraege);
      expect(boosted.confidence, greaterThan(base().confidence));
      expect(confidenceLevel(boosted.confidence), ConfidenceLevel.high);
    });

    test('no learned key leaves the result unchanged', () {
      final result = boostForLearnedSender(
        base(),
        learnedKey: null,
        fallbackKey: CategoryKeys.sonstiges,
      );
      expect(result.bestKey, CategoryKeys.rechnungen);
      expect(result.confidence, base().confidence);
    });
  });

  test('topAlternativeKeys returns the next best non-zero categories', () {
    final alts = topAlternativeKeys(
      const {
        CategoryKeys.rechnungen: 5,
        CategoryKeys.bank: 3,
        CategoryKeys.vertraege: 2,
        CategoryKeys.steuern: 0,
      },
      exclude: CategoryKeys.rechnungen,
      count: 2,
    );
    expect(alts, [CategoryKeys.bank, CategoryKeys.vertraege]);
  });
}
