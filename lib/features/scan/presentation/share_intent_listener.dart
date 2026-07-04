import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../domain/pipeline/ingest_models.dart';
import 'ingest_flow_page.dart';

/// Listens for documents shared into the app (Android Share sheet & "Open
/// with") and routes them into the ingest queue. Handles cold start
/// (getInitialMedia) and warm start (getMediaStream). Android-only; a no-op
/// elsewhere so tests and other platforms are unaffected.
class ShareIntentListener extends ConsumerStatefulWidget {
  const ShareIntentListener({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  StreamSubscription<List<SharedMediaFile>>? _sub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb || !Platform.isAndroid) return;

    // Warm start: app already running when a document is shared.
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(
      _handle,
      onError: (_) {},
    );

    // Cold start: app launched by the share.
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((files) {
          _handle(files);
          ReceiveSharingIntent.instance.reset();
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handle(List<SharedMediaFile> files) {
    if (files.isEmpty || !mounted) return;
    final ingestFiles = [
      for (final f in files)
        IngestFile(
          path: f.path,
          mimeType: f.mimeType,
          name: p.basename(f.path),
        ),
    ];
    ref
        .read(goRouterProvider)
        .push(
          AppRoutes.ingest,
          extra: IngestRequest(files: ingestFiles, source: IngestSource.share),
        );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
