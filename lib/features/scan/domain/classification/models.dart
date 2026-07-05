import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

/// Result of classifying OCR text into one of the category keys.
///
/// [bestKey] is always the top-scoring category (or `sonstiges` when there is
/// no evidence at all). [confidence] is in `0.0..1.0`. The pipeline applies a
/// threshold to decide whether to pre-select the suggestion or fall back to
/// `sonstiges` and prompt the user.
@freezed
abstract class ClassificationResult with _$ClassificationResult {
  const factory ClassificationResult({
    required String bestKey,
    required double confidence,
    required Map<String, double> scores,
  }) = _ClassificationResult;

  const ClassificationResult._();

  /// Whether the suggestion is strong enough to pre-select automatically.
  bool isConfident(double threshold) => confidence >= threshold;
}

/// Metadata extracted from OCR text. All fields are best-effort and may be null;
/// the user always confirms/edits them before saving.
@freezed
abstract class ExtractedMetadata with _$ExtractedMetadata {
  const factory ExtractedMetadata({
    String? sender,
    DateTime? documentDate,
    DateTime? dueDate,
    int? amountCents,
    @Default('EUR') String currency,
    String? iban,
    String? titleSuggestion,
  }) = _ExtractedMetadata;
}
