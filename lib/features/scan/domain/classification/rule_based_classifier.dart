import '../../../../core/database/default_categories.dart';
import 'category_rules.dart';
import 'document_classifier.dart';
import 'metadata_extractor.dart';
import 'models.dart';
import 'scoring.dart';
import 'text_normalizer.dart';

/// German keyword-scoring classifier.
///
/// Each category accumulates the weights of the distinct keywords present in the
/// (normalized) OCR text, plus a couple of structural features (IBAN/amount).
/// Confidence combines absolute evidence strength with the margin over the
/// runner-up, so a single weak signal stays below the threshold and prompts the
/// user, while several strong signals classify automatically.
class RuleBasedClassifier implements DocumentClassifier {
  RuleBasedClassifier({
    this.confidenceThreshold = defaultThreshold,
    this._extractor = const MetadataExtractor(),
  });

  static const double defaultThreshold = 0.35;

  @override
  final double confidenceThreshold;

  final MetadataExtractor _extractor;

  /// Compiled matchers, built once.
  static final List<_CompiledRule> _compiled = [
    for (final rule in kCategoryRules)
      _CompiledRule(rule.key, [
        for (final kw in rule.keywords)
          _CompiledKeyword(_buildMatcher(kw.term), kw.weight),
      ]),
  ];

  @override
  ClassificationResult classify(String ocrText) {
    final normalized = normalizeForMatching(ocrText);

    final scores = <String, double>{
      for (final c in kDefaultCategories) c.key: 0,
    };

    for (final rule in _compiled) {
      var sum = 0.0;
      for (final kw in rule.keywords) {
        if (kw.matcher.hasMatch(normalized)) sum += kw.weight;
      }
      scores[rule.key] = sum;
    }

    // Structural features.
    if (_extractor.containsIban(ocrText)) {
      scores[CategoryKeys.bank] = scores[CategoryKeys.bank]! + 1;
      scores[CategoryKeys.rechnungen] = scores[CategoryKeys.rechnungen]! + 1;
    }
    if (_extractor.containsAmount(ocrText)) {
      scores[CategoryKeys.rechnungen] = scores[CategoryKeys.rechnungen]! + 1;
    }

    return buildClassificationResult(
      scores,
      fallbackKey: CategoryKeys.sonstiges,
    );
  }

  /// Leading word-boundary matcher so a keyword also fires inside compounds
  /// (`rechnung` -> `Rechnungsnummer`), with flexible internal whitespace for
  /// multi-word phrases (`zahlbar bis`).
  static RegExp _buildMatcher(String term) {
    final normalized = normalizeForMatching(term).trim();
    final escaped = RegExp.escape(normalized).replaceAll(r'\ ', r'\s+');
    return RegExp(r'(?<![a-z0-9])' + escaped);
  }
}

class _CompiledRule {
  _CompiledRule(this.key, this.keywords);
  final String key;
  final List<_CompiledKeyword> keywords;
}

class _CompiledKeyword {
  _CompiledKeyword(this.matcher, this.weight);
  final RegExp matcher;
  final double weight;
}
