import 'models.dart';

/// Contract for classifying OCR text into a category key.
///
/// The rule-based implementation ships in Phase 1. Phase 2 can provide an
/// LLM-backed implementation of this same interface without touching the
/// pipeline, persistence or UI (see ARCHITECTURE.md, extension point 4).
abstract interface class DocumentClassifier {
  ClassificationResult classify(String ocrText);

  /// Confidence at/above which a suggestion may be pre-selected automatically.
  double get confidenceThreshold;
}
