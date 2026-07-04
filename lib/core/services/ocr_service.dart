import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// On-device OCR (Latin script covers German). Runs fully offline. Abstracted so
/// the pipeline can be tested without the native plugin.
abstract interface class OcrService {
  /// Recognizes text for a single page image path.
  Future<String> recognizePage(String imagePath);

  /// Recognizes text for each page, in order. Failures for a page yield '' for
  /// that page rather than aborting the whole document.
  Future<List<String>> recognizePages(List<String> imagePaths);

  Future<void> dispose();
}

class MlKitOcrService implements OcrService {
  MlKitOcrService()
    : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<String> recognizePage(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text;
  }

  @override
  Future<List<String>> recognizePages(List<String> imagePaths) async {
    final out = <String>[];
    for (final path in imagePaths) {
      try {
        out.add(await recognizePage(path));
      } catch (_) {
        out.add('');
      }
    }
    return out;
  }

  @override
  Future<void> dispose() => _recognizer.close();
}

/// Maps preset paths to preset OCR text; used by tests.
class FakeOcrService implements OcrService {
  FakeOcrService(this.textByPath);
  final Map<String, String> textByPath;

  @override
  Future<String> recognizePage(String imagePath) async =>
      textByPath[imagePath] ?? '';

  @override
  Future<List<String>> recognizePages(List<String> imagePaths) async => [
    for (final path in imagePaths) textByPath[path] ?? '',
  ];

  @override
  Future<void> dispose() async {}
}

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = MlKitOcrService();
  ref.onDispose(service.dispose);
  return service;
});
