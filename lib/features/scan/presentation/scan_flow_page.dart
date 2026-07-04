import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extension.dart';
import '../../../core/router/app_routes.dart';
import 'scan_confirmation_view.dart';
import 'scan_controller.dart';
import '../domain/pipeline/scan_models.dart';
import 'scan_review_view.dart';

/// Hosts the whole scan flow, switching sub-views by [ScanPhase]. The native
/// scanner launches automatically on entry.
class ScanFlowPage extends ConsumerStatefulWidget {
  const ScanFlowPage({super.key});

  @override
  ConsumerState<ScanFlowPage> createState() => _ScanFlowPageState();
}

class _ScanFlowPageState extends ConsumerState<ScanFlowPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scanControllerProvider.notifier).startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen<ScanState>(scanControllerProvider, (prev, next) {
      // User cancelled the native scanner: leave the flow.
      if (prev?.phase == ScanPhase.capturing && next.phase == ScanPhase.idle) {
        if (context.canPop()) context.pop();
      }
      // Saved: haptic confirmation, then open the new document.
      if (next.phase == ScanPhase.saved && next.savedDocumentId != null) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.scanSavedMessage)));
        ref.read(scanControllerProvider.notifier).reset();
        context.pushReplacement(AppRoutes.document(next.savedDocumentId!));
      }
    });

    final state = ref.watch(scanControllerProvider);

    switch (state.phase) {
      case ScanPhase.review:
        return const ScanReviewView();
      case ScanPhase.confirm:
        return ScanConfirmationView(draft: state.draft!);
      case ScanPhase.error:
        return _ErrorView(message: state.errorMessage ?? l10n.scanErrorTitle);
      case ScanPhase.capturing:
      case ScanPhase.processing:
      case ScanPhase.saving:
      case ScanPhase.saved:
      case ScanPhase.idle:
        return _LoadingView(label: state.progressLabel ?? l10n.scanProcessing);
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

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanErrorTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () =>
                    ref.read(scanControllerProvider.notifier).startScan(),
                child: Text(l10n.commonRetry),
              ),
              TextButton(
                onPressed: () {
                  ref.read(scanControllerProvider.notifier).reset();
                  if (context.canPop()) context.pop();
                },
                child: Text(l10n.commonBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
