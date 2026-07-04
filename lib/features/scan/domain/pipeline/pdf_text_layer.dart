import 'dart:typed_data';

/// Pure-Dart heuristic: does this PDF carry a real text layer, or is it an
/// image-only (scanned) PDF?
///
/// A permissively-licensed Dart PDF text extractor does not exist (Syncfusion /
/// iText are non-permissive), so we cannot read the embedded text directly.
/// What we *can* do cheaply and reliably is decide whether a text layer exists:
/// digital or OCR'd PDFs reference font resources (`/Font`, `/Type0`,
/// `/TrueType`, `/Type1`), while purely scanned PDFs contain only image
/// XObjects. Callers use this to decide messaging and (future) to skip OCR when
/// a proper extractor becomes available. The original PDF is always preserved
/// either way; text for classification/search comes from rasterize + OCR.
bool pdfHasTextLayer(Uint8List bytes) {
  // Font dictionaries live in the PDF object structure and are usually not
  // inside compressed content streams, so a raw byte scan finds them.
  return _containsAscii(bytes, _fontMarker) ||
      _containsAscii(bytes, _type0Marker) ||
      _containsAscii(bytes, _trueTypeMarker) ||
      _containsAscii(bytes, _type1Marker);
}

/// True when the bytes look like a PDF at all (`%PDF-` header).
bool isPdf(Uint8List bytes) => _containsAsciiWithin(bytes, _pdfHeader, 1024);

final _fontMarker = _ascii('/Font');
final _type0Marker = _ascii('/Type0');
final _trueTypeMarker = _ascii('/TrueType');
final _type1Marker = _ascii('/Type1');
final _pdfHeader = _ascii('%PDF-');

Uint8List _ascii(String s) => Uint8List.fromList(s.codeUnits);

bool _containsAscii(Uint8List haystack, Uint8List needle) =>
    _indexOf(haystack, needle, haystack.length) >= 0;

bool _containsAsciiWithin(Uint8List haystack, Uint8List needle, int limit) =>
    _indexOf(haystack, needle, limit) >= 0;

int _indexOf(Uint8List haystack, Uint8List needle, int limit) {
  if (needle.isEmpty) return 0;
  final end = (limit < haystack.length ? limit : haystack.length) - needle.length;
  for (var i = 0; i <= end; i++) {
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}
