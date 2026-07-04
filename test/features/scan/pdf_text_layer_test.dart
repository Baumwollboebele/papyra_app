import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:paperless/core/services/pdf_service.dart';
import 'package:paperless/features/scan/domain/pipeline/pdf_text_layer.dart';

Uint8List _png() {
  final image = img.Image(width: 200, height: 260);
  img.fill(image, color: img.ColorRgb8(220, 220, 220));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  test('isPdf recognizes the %PDF header and rejects other bytes', () {
    expect(isPdf(Uint8List.fromList('%PDF-1.7\n...'.codeUnits)), isTrue);
    expect(isPdf(Uint8List.fromList('not a pdf'.codeUnits)), isFalse);
    expect(isPdf(_png()), isFalse);
  });

  test('detects a text layer in a PDF that has text', () async {
    final pdf = await buildSearchablePdf(
      PdfBuildRequest(
        pages: [
          PdfPageInput(imageBytes: _png(), text: 'Rechnung Gesamtbetrag 89,90'),
        ],
      ),
    );
    expect(pdfHasTextLayer(pdf), isTrue);
  });

  test('reports no text layer for an image-only PDF', () async {
    final pdf = await buildSearchablePdf(
      PdfBuildRequest(
        pages: [PdfPageInput(imageBytes: _png())], // no text -> no fonts
      ),
    );
    expect(pdfHasTextLayer(pdf), isFalse);
  });
}
