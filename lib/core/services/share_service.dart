import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Shares generated files via the OS share sheet. Abstracted for testability.
abstract interface class ShareService {
  Future<void> sharePdf(String path, {String? name});

  /// Shares an arbitrary file (e.g. a backup ZIP) via the OS share sheet.
  Future<void> shareFile(String path, {String? subject});
}

class PrintingShareService implements ShareService {
  const PrintingShareService();

  @override
  Future<void> sharePdf(String path, {String? name}) async {
    final bytes = await File(path).readAsBytes();
    await Printing.sharePdf(bytes: bytes, filename: name ?? 'dokument.pdf');
  }

  @override
  Future<void> shareFile(String path, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], subject: subject),
    );
  }
}

final shareServiceProvider = Provider<ShareService>(
  (ref) => const PrintingShareService(),
);
