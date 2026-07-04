import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/router/app_routes.dart';
import '../domain/pipeline/ingest_models.dart';
import 'ingest_controller.dart';
import 'scan_confirmation_view.dart';

/// Routing payload for the ingest queue (shared/opened/imported files).
@immutable
class IngestRequest {
  const IngestRequest({required this.files, required this.source});
  final List<IngestFile> files;
  final IngestSource source;
}

/// Hosts the multi-document ingest queue: prepare → confirm each → summary.
class IngestFlowPage extends ConsumerStatefulWidget {
  const IngestFlowPage({required this.request, super.key});

  final IngestRequest request;

  @override
  ConsumerState<IngestFlowPage> createState() => _IngestFlowPageState();
}

class _IngestFlowPageState extends ConsumerState<IngestFlowPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(ingestQueueControllerProvider.notifier)
          .start(widget.request.files, widget.request.source);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(ingestQueueControllerProvider);

    switch (state.phase) {
      case IngestQueuePhase.confirm:
        final current = state.current!;
        return ScanConfirmationView(
          key: ValueKey(current.id),
          draft: current.draft!,
          progressLabel: l10n.ingestProgress(
            state.currentIndex + 1,
            state.total,
          ),
          onConfirm: (draft) => ref
              .read(ingestQueueControllerProvider.notifier)
              .confirmCurrent(draft),
          onSkip: () =>
              ref.read(ingestQueueControllerProvider.notifier).skipCurrent(),
        );
      case IngestQueuePhase.done:
        return _DoneView(
          saved: state.savedCount,
          skipped: state.skippedCount + state.failedCount,
        );
      case IngestQueuePhase.idle:
      case IngestQueuePhase.preparing:
      case IngestQueuePhase.processing:
      case IngestQueuePhase.saving:
        return _LoadingView(label: state.progressLabel ?? l10n.ingestPreparing);
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _DoneView extends ConsumerStatefulWidget {
  const _DoneView({required this.saved, required this.skipped});
  final int saved;
  final int skipped;

  @override
  ConsumerState<_DoneView> createState() => _DoneViewState();
}

class _DoneViewState extends ConsumerState<_DoneView> {
  @override
  void initState() {
    super.initState();
    if (widget.saved > 0) HapticFeedback.mediumImpact();
  }

  void _finish() {
    ref.read(ingestQueueControllerProvider.notifier).reset();
    if (context.mounted) context.go(AppRoutes.library);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nothing = widget.saved == 0 && widget.skipped == 0;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                nothing ? Icons.info_outline : Icons.check_circle_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                nothing ? l10n.ingestEmpty : l10n.ingestDoneTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (!nothing) ...[
                const SizedBox(height: 8),
                Text(l10n.ingestDoneSummary(widget.saved, widget.skipped)),
              ],
              const SizedBox(height: 24),
              FilledButton(onPressed: _finish, child: Text(l10n.commonDone)),
            ],
          ),
        ),
      ),
    );
  }
}
