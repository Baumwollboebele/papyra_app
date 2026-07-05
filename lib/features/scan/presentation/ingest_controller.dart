import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/ingest_providers.dart';
import '../../../core/providers/settings_providers.dart';
import '../../../core/services/file_service.dart';
import '../../../core/services/reminder_service.dart';
import '../domain/classification/scoring.dart';
import '../domain/pipeline/ingest_models.dart';
import '../domain/pipeline/scan_models.dart';

enum IngestQueuePhase { idle, preparing, processing, confirm, saving, done }

@immutable
class IngestQueueState {
  const IngestQueueState({
    this.phase = IngestQueuePhase.idle,
    this.items = const [],
    this.currentIndex = 0,
    this.savedCount = 0,
    this.skippedCount = 0,
    this.progressLabel,
  });

  final IngestQueuePhase phase;
  final List<IngestItem> items;
  final int currentIndex;
  final int savedCount;
  final int skippedCount;
  final String? progressLabel;

  IngestItem? get current => currentIndex >= 0 && currentIndex < items.length
      ? items[currentIndex]
      : null;

  int get total => items.length;
  int get failedCount =>
      items.where((i) => i.status == IngestStatus.failed).length;

  IngestQueueState copyWith({
    IngestQueuePhase? phase,
    List<IngestItem>? items,
    int? currentIndex,
    int? savedCount,
    int? skippedCount,
    String? progressLabel,
  }) {
    return IngestQueueState(
      phase: phase ?? this.phase,
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      savedCount: savedCount ?? this.savedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      progressLabel: progressLabel,
    );
  }
}

final ingestQueueControllerProvider =
    NotifierProvider<IngestQueueController, IngestQueueState>(
      IngestQueueController.new,
    );

/// Drives a queue of shared/imported documents through the shared
/// [IngestService]: prepare → (per item) process → confirm → save → next.
class IngestQueueController extends Notifier<IngestQueueState> {
  @override
  IngestQueueState build() => const IngestQueueState();

  void reset() => state = const IngestQueueState();

  /// Builds items from [files] and advances to the first confirmable one.
  Future<void> start(List<IngestFile> files, IngestSource source) async {
    if (files.isEmpty) {
      state = const IngestQueueState(phase: IngestQueuePhase.done);
      return;
    }
    state = const IngestQueueState(phase: IngestQueuePhase.preparing);
    final ingest = ref.read(ingestServiceProvider);
    final items = await ingest.buildItems(files, source);
    state = state.copyWith(items: items, currentIndex: 0);
    await _advanceToProcessable();
  }

  /// Persists the current item with [draft], then moves to the next.
  Future<void> confirmCurrent(ConfirmationDraft draft) async {
    final index = state.currentIndex;
    final item = state.current;
    if (item == null) return;
    state = state.copyWith(
      phase: IngestQueuePhase.saving,
      progressLabel: 'Wird gespeichert …',
    );
    try {
      final id = await ref.read(ingestServiceProvider).persist(item, draft);
      await applyReminder(
        service: ref.read(reminderServiceProvider),
        settings: ref.read(settingsControllerProvider),
        documentId: id,
        title: draft.title,
        dueDate: draft.dueDate,
        isPaid: false,
      );
      _replace(
        index,
        item.copyWith(status: IngestStatus.saved, savedDocumentId: id),
      );
      state = state.copyWith(savedCount: state.savedCount + 1);
    } on StorageException catch (e) {
      _replace(
        index,
        item.copyWith(
          status: IngestStatus.failed,
          errorMessage: 'Speichern fehlgeschlagen: ${e.message}',
        ),
      );
    } catch (_) {
      _replace(
        index,
        item.copyWith(
          status: IngestStatus.failed,
          errorMessage: 'Das Dokument konnte nicht gespeichert werden.',
        ),
      );
    }
    state = state.copyWith(currentIndex: index + 1);
    await _advanceToProcessable();
  }

  /// Discards the current item (deletes its files) and moves on.
  Future<void> skipCurrent() async {
    final index = state.currentIndex;
    final item = state.current;
    if (item == null) return;
    await ref.read(fileServiceProvider).deleteAll(item.ownedFiles);
    _replace(index, item.copyWith(status: IngestStatus.failed));
    state = state.copyWith(
      currentIndex: index + 1,
      skippedCount: state.skippedCount + 1,
    );
    await _advanceToProcessable();
  }

  /// Processes the item at [currentIndex]; skips already-failed ones; finishes
  /// the queue when there are no more.
  Future<void> _advanceToProcessable() async {
    var index = state.currentIndex;
    while (index < state.items.length &&
        state.items[index].status == IngestStatus.failed) {
      index++;
    }
    if (index >= state.items.length) {
      state = state.copyWith(phase: IngestQueuePhase.done, currentIndex: index);
      return;
    }
    state = state.copyWith(
      phase: IngestQueuePhase.processing,
      currentIndex: index,
      progressLabel: 'Wird verarbeitet …',
    );
    final settings = ref.read(settingsControllerProvider);
    final processed = await ref
        .read(ingestServiceProvider)
        .process(state.items[index], titleTemplate: settings.titleTemplate);
    _replace(index, processed);
    // A processing failure (no draft) -> skip it.
    if (processed.status == IngestStatus.failed || processed.draft == null) {
      state = state.copyWith(currentIndex: index + 1);
      await _advanceToProcessable();
      return;
    }
    // Auto-accept high-confidence documents without confirmation.
    if (settings.autoAcceptHighConfidence &&
        processed.draft!.level == ConfidenceLevel.high) {
      await confirmCurrent(processed.draft!);
      return;
    }
    state = state.copyWith(phase: IngestQueuePhase.confirm);
  }

  void _replace(int index, IngestItem item) {
    final items = [...state.items];
    if (index >= 0 && index < items.length) {
      items[index] = item;
      state = state.copyWith(items: items);
    }
  }
}
