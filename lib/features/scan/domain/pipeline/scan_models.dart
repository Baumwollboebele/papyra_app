import 'package:flutter/foundation.dart';

import '../classification/models.dart';
import '../classification/scoring.dart';
import 'ingest_models.dart';

/// A single captured page inside the scan flow.
@immutable
class ScanPage {
  const ScanPage({required this.imagePath, this.text = ''});
  final String imagePath;
  final String text;

  ScanPage copyWith({String? imagePath, String? text}) =>
      ScanPage(imagePath: imagePath ?? this.imagePath, text: text ?? this.text);
}

/// The editable draft shown on the confirmation screen. Seeded from
/// classification + extraction, then adjusted by the user before saving.
@immutable
class ConfirmationDraft {
  const ConfirmationDraft({
    required this.title,
    required this.categoryId,
    required this.suggestedCategoryId,
    required this.confidence,
    required this.lowConfidence,
    this.sender,
    this.documentDate,
    this.dueDate,
    this.amountCents,
    this.currency = 'EUR',
    this.iban,
    this.tags = const [],
    this.groupId,
    this.level = ConfidenceLevel.low,
    this.alternativeCategoryIds = const [],
  });

  final String title;

  /// The category currently selected in the form (pre-filled).
  final int categoryId;

  /// What the classifier actually suggested (may differ from [categoryId] when
  /// confidence was too low and we fell back to "Sonstiges").
  final int suggestedCategoryId;
  final double confidence;

  /// True when confidence was below threshold: the UI prompts the user to
  /// confirm the category.
  final bool lowConfidence;

  final String? sender;
  final DateTime? documentDate;
  final DateTime? dueDate;
  final int? amountCents;
  final String currency;
  final String? iban;
  final List<String> tags;

  /// Selected sub-group within [categoryId] (null = none).
  final int? groupId;

  /// Confidence band of the classification (drives the UI badge / flag).
  final ConfidenceLevel level;

  /// Category ids of the top alternative guesses (one-tap chips).
  final List<int> alternativeCategoryIds;

  ConfirmationDraft copyWith({
    String? title,
    int? categoryId,
    String? sender,
    DateTime? documentDate,
    Object? dueDate = _sentinel,
    Object? amountCents = _sentinel,
    String? currency,
    List<String>? tags,
    Object? groupId = _sentinel,
  }) {
    return ConfirmationDraft(
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      suggestedCategoryId: suggestedCategoryId,
      confidence: confidence,
      lowConfidence: lowConfidence,
      sender: sender ?? this.sender,
      documentDate: documentDate ?? this.documentDate,
      dueDate: dueDate == _sentinel ? this.dueDate : dueDate as DateTime?,
      amountCents: amountCents == _sentinel
          ? this.amountCents
          : amountCents as int?,
      currency: currency ?? this.currency,
      iban: iban,
      tags: tags ?? this.tags,
      groupId: groupId == _sentinel ? this.groupId : groupId as int?,
      level: level,
      alternativeCategoryIds: alternativeCategoryIds,
    );
  }

  static const _sentinel = Object();
}

/// Phases of the scan flow.
enum ScanPhase {
  idle,
  capturing,
  review,
  processing,
  confirm,
  saving,
  saved,
  error,
}

@immutable
class ScanState {
  const ScanState({
    this.phase = ScanPhase.idle,
    this.pages = const [],
    this.classification,
    this.draft,
    this.item,
    this.errorMessage,
    this.savedDocumentId,
    this.progressLabel,
  });

  final ScanPhase phase;
  final List<ScanPage> pages;
  final ClassificationResult? classification;
  final ConfirmationDraft? draft;

  /// The processed ingest item (carries page OCR text) used when saving.
  final IngestItem? item;
  final String? errorMessage;
  final int? savedDocumentId;
  final String? progressLabel;

  ScanState copyWith({
    ScanPhase? phase,
    List<ScanPage>? pages,
    ClassificationResult? classification,
    ConfirmationDraft? draft,
    IngestItem? item,
    String? errorMessage,
    int? savedDocumentId,
    String? progressLabel,
  }) {
    return ScanState(
      phase: phase ?? this.phase,
      pages: pages ?? this.pages,
      classification: classification ?? this.classification,
      draft: draft ?? this.draft,
      item: item ?? this.item,
      errorMessage: errorMessage,
      savedDocumentId: savedDocumentId ?? this.savedDocumentId,
      progressLabel: progressLabel,
    );
  }
}
