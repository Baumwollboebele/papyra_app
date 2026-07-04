import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

/// Rasterizes PDF pages to images so image-only (scanned) PDFs — and, since no
/// permissive Dart PDF text extractor exists, digital PDFs too — can be OCR'd.
/// Abstracted so the ingest pipeline is testable without the platform plugin.
abstract interface class PdfRasterizer {
  /// Rasterizes each page to PNG bytes at [dpi]. Runs on the platform side
  /// (off the Dart UI isolate). Throws if the document cannot be rendered
  /// (corrupt / password-protected).
  Stream<Uint8List> rasterize(Uint8List pdfBytes, {double dpi = 150});
}

class PrintingPdfRasterizer implements PdfRasterizer {
  const PrintingPdfRasterizer();

  @override
  Stream<Uint8List> rasterize(Uint8List pdfBytes, {double dpi = 150}) async* {
    await for (final page in Printing.raster(pdfBytes, dpi: dpi)) {
      yield await page.toPng();
    }
  }
}

/// Returns preset page images; used by tests.
class FakePdfRasterizer implements PdfRasterizer {
  FakePdfRasterizer(this.pages);
  final List<Uint8List> pages;

  @override
  Stream<Uint8List> rasterize(Uint8List pdfBytes, {double dpi = 150}) =>
      Stream.fromIterable(pages);
}

final pdfRasterizerProvider = Provider<PdfRasterizer>(
  (ref) => const PrintingPdfRasterizer(),
);
