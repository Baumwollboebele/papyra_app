import 'models.dart';

/// Score at/above which absolute evidence saturates the strength term.
const double kStrongEvidenceScore = 7;

/// Confidence bands for the confirmation UI.
enum ConfidenceLevel { high, medium, low }

/// Confidence at/above which a suggestion may be auto-accepted / pre-selected
/// without a "please check" flag.
const double kHighConfidence = 0.6;

/// Confidence at/above which the suggestion is pre-selected (but flagged).
const double kMediumConfidence = 0.35;

ConfidenceLevel confidenceLevel(double confidence) {
  if (confidence >= kHighConfidence) return ConfidenceLevel.high;
  if (confidence >= kMediumConfidence) return ConfidenceLevel.medium;
  return ConfidenceLevel.low;
}

/// Builds a [ClassificationResult] from per-category [scores]: picks the top
/// category and derives a confidence that blends absolute evidence strength
/// with the margin over the runner-up. Shared by the rule-based classifier and
/// the learning boost so both produce consistent confidence.
ClassificationResult buildClassificationResult(
  Map<String, double> scores, {
  required String fallbackKey,
}) {
  final ranked = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = ranked.isEmpty ? null : ranked.first;
  final secondValue = ranked.length > 1 ? ranked[1].value : 0.0;

  if (top == null || top.value <= 0) {
    return ClassificationResult(
      bestKey: fallbackKey,
      confidence: 0,
      scores: scores,
    );
  }

  final strength = (top.value / kStrongEvidenceScore).clamp(0.0, 1.0);
  final margin = (top.value - secondValue) / top.value; // 0..1
  final confidence = (strength * (0.5 + 0.5 * margin)).clamp(0.0, 1.0);

  return ClassificationResult(
    bestKey: top.key,
    confidence: confidence,
    scores: scores,
  );
}

/// Applies a local-learning boost: if a document's sender is already mapped to
/// [learnedKey], that category's score is boosted so it becomes the strong
/// suggestion. Pure and unit-testable.
ClassificationResult boostForLearnedSender(
  ClassificationResult base, {
  required String? learnedKey,
  required String fallbackKey,
  double boost = 8,
}) {
  if (learnedKey == null) return base;
  final scores = {...base.scores};
  scores[learnedKey] = (scores[learnedKey] ?? 0) + boost;
  return buildClassificationResult(scores, fallbackKey: fallbackKey);
}

/// The top [count] category keys by score (excluding [exclude]), score > 0 —
/// used to offer one-tap alternative-category chips.
List<String> topAlternativeKeys(
  Map<String, double> scores, {
  required String exclude,
  int count = 3,
}) {
  final ranked =
      scores.entries.where((e) => e.key != exclude && e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
  return ranked.take(count).map((e) => e.key).toList();
}
