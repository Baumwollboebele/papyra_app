import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wraps the native document scanner (VisionKit on iOS, ML Kit document scanner
/// on Android) behind a plugin-free interface so the flow is testable.
abstract interface class ScannerService {
  /// Launches the native multi-page scanner. Returns the captured page image
  /// paths, or an empty list if the user cancelled.
  Future<List<String>> scan({int maxPages = 30});
}

class CunningScannerService implements ScannerService {
  const CunningScannerService();

  @override
  Future<List<String>> scan({int maxPages = 30}) async {
    final pictures = await CunningDocumentScanner.getPictures(
      noOfPages: maxPages,
    );
    return pictures ?? const [];
  }
}

/// Returns preset paths; used by tests.
class FakeScannerService implements ScannerService {
  FakeScannerService(this.paths);
  final List<String> paths;

  @override
  Future<List<String>> scan({int maxPages = 30}) async => paths;
}

final scannerServiceProvider = Provider<ScannerService>(
  (ref) => const CunningScannerService(),
);
