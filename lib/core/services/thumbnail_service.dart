import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Arguments for [generateThumbnailBytes], kept as a single object so it can be
/// dispatched to an isolate via `compute`.
class ThumbnailRequest {
  const ThumbnailRequest(
    this.imageBytes, {
    this.maxSize = 400,
    this.quality = 80,
  });
  final Uint8List imageBytes;
  final int maxSize;
  final int quality;
}

/// Decodes [ThumbnailRequest.imageBytes], scales the longer edge down to
/// `maxSize` (never up), and re-encodes as JPEG. Pure and isolate-safe.
///
/// Throws [FormatException] if the bytes are not a decodable image.
Uint8List generateThumbnailBytes(ThumbnailRequest request) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(request.imageBytes);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    throw const FormatException('Bild konnte nicht gelesen werden');
  }
  final longEdge = decoded.width >= decoded.height
      ? decoded.width
      : decoded.height;
  final img.Image scaled = longEdge <= request.maxSize
      ? decoded
      : (decoded.width >= decoded.height
            ? img.copyResize(decoded, width: request.maxSize)
            : img.copyResize(decoded, height: request.maxSize));
  return img.encodeJpg(scaled, quality: request.quality);
}
