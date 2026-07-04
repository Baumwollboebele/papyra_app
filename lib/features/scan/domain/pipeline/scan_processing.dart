import '../classification/document_classifier.dart';
import '../classification/metadata_extractor.dart';
import '../classification/models.dart';
import 'scan_models.dart';

/// Result of processing OCR text: the classification plus a pre-filled draft.
class ProcessingResult {
  const ProcessingResult({required this.classification, required this.draft});
  final ClassificationResult classification;
  final ConfirmationDraft draft;
}

/// Pure pipeline step: classify + extract, then build the confirmation draft.
///
/// Below the classifier's confidence threshold the selected category falls back
/// to [fallbackCategoryId] ("Sonstiges") while still recording the suggestion,
/// so the UI can prompt the user to confirm. No I/O, fully unit-testable.
ProcessingResult buildProcessingResult({
  required String combinedText,
  required DocumentClassifier classifier,
  required MetadataExtractor extractor,
  required Map<String, int> categoryIdByKey,
  required int fallbackCategoryId,
}) {
  final classification = classifier.classify(combinedText);
  final metadata = extractor.extract(combinedText);
  final confident = classification.isConfident(classifier.confidenceThreshold);

  final suggestedId =
      categoryIdByKey[classification.bestKey] ?? fallbackCategoryId;
  final selectedId = confident ? suggestedId : fallbackCategoryId;

  final draft = ConfirmationDraft(
    title: _deriveTitle(metadata, combinedText),
    categoryId: selectedId,
    suggestedCategoryId: suggestedId,
    confidence: classification.confidence,
    lowConfidence: !confident,
    sender: metadata.sender,
    documentDate: metadata.documentDate,
    amountCents: metadata.amountCents,
    currency: metadata.currency,
    iban: metadata.iban,
  );

  return ProcessingResult(classification: classification, draft: draft);
}

String _deriveTitle(ExtractedMetadata metadata, String text) {
  final candidate = metadata.titleSuggestion ?? _firstMeaningfulLine(text);
  if (candidate == null || candidate.trim().isEmpty) return 'Dokument';
  final trimmed = candidate.trim();
  return trimmed.length > 80 ? trimmed.substring(0, 80) : trimmed;
}

String? _firstMeaningfulLine(String text) {
  for (final raw in text.split(RegExp(r'[\r\n]+'))) {
    final line = raw.trim();
    if (line.length >= 3) return line;
  }
  return null;
}
