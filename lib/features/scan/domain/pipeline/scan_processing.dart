import '../../../../core/database/default_categories.dart';
import '../classification/document_classifier.dart';
import '../classification/metadata_extractor.dart';
import '../classification/models.dart';
import '../classification/scoring.dart';
import '../classification/title_generator.dart';
import 'scan_models.dart';

/// Result of processing OCR text: the classification plus a pre-filled draft.
class ProcessingResult {
  const ProcessingResult({required this.classification, required this.draft});
  final ClassificationResult classification;
  final ConfirmationDraft draft;
}

/// Pure pipeline step: classify (+ optional local-learning boost) + extract,
/// then build a pre-filled confirmation draft with a smart title, confidence
/// band and alternative-category suggestions.
///
/// High/medium confidence pre-selects the suggested category; low confidence
/// falls back to [fallbackCategoryId] ("Sonstiges") and prompts. No I/O.
ProcessingResult buildProcessingResult({
  required String combinedText,
  required DocumentClassifier classifier,
  required MetadataExtractor extractor,
  required Map<String, int> categoryIdByKey,
  required int fallbackCategoryId,
  String titleTemplate = kDefaultTitleTemplate,
  String? learnedCategoryKey,
}) {
  var classification = classifier.classify(combinedText);
  // Local learning: a known sender strongly boosts its remembered category.
  classification = boostForLearnedSender(
    classification,
    learnedKey: learnedCategoryKey,
    fallbackKey: CategoryKeys.sonstiges,
  );

  final metadata = extractor.extract(combinedText);
  final level = confidenceLevel(classification.confidence);

  final suggestedId =
      categoryIdByKey[classification.bestKey] ?? fallbackCategoryId;
  final selectedId = level == ConfidenceLevel.low
      ? fallbackCategoryId
      : suggestedId;

  final effectiveSender = metadata.sender ?? _firstMeaningfulLine(combinedText);
  final title = generateTitle(
    template: titleTemplate,
    sender: effectiveSender,
    docType: categoryDocType(classification.bestKey),
    date: metadata.documentDate,
  );

  final alternativeIds = [
    for (final key in topAlternativeKeys(
      classification.scores,
      exclude: classification.bestKey,
    ))
      if (categoryIdByKey[key] != null) categoryIdByKey[key]!,
  ];

  final draft = ConfirmationDraft(
    title: title,
    categoryId: selectedId,
    suggestedCategoryId: suggestedId,
    confidence: classification.confidence,
    lowConfidence: level == ConfidenceLevel.low,
    level: level,
    alternativeCategoryIds: alternativeIds,
    sender: metadata.sender,
    documentDate: metadata.documentDate,
    dueDate: metadata.dueDate,
    amountCents: metadata.amountCents,
    currency: metadata.currency,
    iban: metadata.iban,
  );

  return ProcessingResult(classification: classification, draft: draft);
}

String? _firstMeaningfulLine(String text) {
  for (final raw in text.split(RegExp(r'[\r\n]+'))) {
    final line = raw.trim();
    if (line.length >= 3) return line;
  }
  return null;
}
