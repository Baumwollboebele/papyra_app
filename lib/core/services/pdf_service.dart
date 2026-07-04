import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// A single page: its (JPEG/PNG) image bytes plus the OCR text to embed as an
/// invisible, selectable/searchable text layer.
class PdfPageInput {
  const PdfPageInput({required this.imageBytes, this.text = ''});
  final Uint8List imageBytes;
  final String text;
}

class PdfBuildRequest {
  const PdfBuildRequest({required this.pages, this.title, this.fontData});
  final List<PdfPageInput> pages;
  final String? title;

  /// Optional TTF bytes for the invisible text layer, so German umlauts survive
  /// in the searchable layer. If null or unusable, falls back to the built-in
  /// font (which still covers Latin-1). Passed as bytes so it is isolate-safe.
  final Uint8List? fontData;
}

/// Builds a PDF from scanned page images. Each page renders the image full-bleed
/// and overlays the page's OCR text at zero opacity, so the resulting PDF has a
/// searchable/selectable text layer while looking like the scan. Pure and
/// isolate-safe (no plugins, no I/O).
Future<Uint8List> buildSearchablePdf(PdfBuildRequest request) async {
  final doc = pw.Document(title: request.title);
  pw.Font? textFont;
  if (request.fontData != null) {
    try {
      textFont = pw.Font.ttf(
        request.fontData!.buffer.asByteData(
          request.fontData!.offsetInBytes,
          request.fontData!.lengthInBytes,
        ),
      );
    } catch (_) {
      textFont = null; // fall back to built-in font
    }
  }
  for (final page in request.pages) {
    final image = pw.MemoryImage(page.imageBytes);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Stack(
            fit: pw.StackFit.expand,
            children: [
              pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
              if (page.text.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Opacity(
                    opacity: 0,
                    child: pw.Text(
                      page.text,
                      style: pw.TextStyle(fontSize: 8, font: textFont),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  return doc.save();
}
