import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:paperless/core/services/pdf_service.dart';
import 'package:paperless/core/services/thumbnail_service.dart';

Uint8List _samplePng({int width = 800, int height = 1000}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(200, 220, 210));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('thumbnail', () {
    test('scales the longer edge down to maxSize and stays decodable', () {
      final bytes = generateThumbnailBytes(
        ThumbnailRequest(_samplePng(), maxSize: 400),
      );
      final decoded = img.decodeImage(bytes);
      expect(decoded, isNotNull);
      final longEdge = decoded!.width >= decoded.height
          ? decoded.width
          : decoded.height;
      expect(longEdge, 400); // 1000 -> 400
    });

    test('does not upscale a small image', () {
      final small = _samplePng(width: 100, height: 120);
      final bytes = generateThumbnailBytes(
        ThumbnailRequest(small, maxSize: 400),
      );
      final decoded = img.decodeImage(bytes)!;
      expect(decoded.height, 120);
    });

    test('throws a FormatException on undecodable bytes', () {
      expect(
        () => generateThumbnailBytes(
          ThumbnailRequest(Uint8List.fromList([1, 2, 3])),
        ),
        throwsFormatException,
      );
    });
  });

  group('searchable PDF', () {
    test('produces a valid multi-page PDF', () async {
      final page = _samplePng();
      final bytes = await buildSearchablePdf(
        PdfBuildRequest(
          title: 'Test',
          pages: [
            PdfPageInput(imageBytes: page, text: 'Rechnung Gesamtbetrag 89,90'),
            PdfPageInput(imageBytes: page, text: 'Seite zwei'),
          ],
        ),
      );
      expect(bytes.length, greaterThan(1000));
      // PDF magic header.
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('handles a page without OCR text', () async {
      final bytes = await buildSearchablePdf(
        PdfBuildRequest(pages: [PdfPageInput(imageBytes: _samplePng())]),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
