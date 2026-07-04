// Generates placeholder app-icon PNGs (no licensed assets).
//
// Run with:  dart run tool/generate_app_icon.dart
// Then:      dart run flutter_launcher_icons
//
// Produces a deep-teal "vault document" mark: a white document card with text
// lines and a small lock badge. Writes a full icon and a transparent
// foreground for Android adaptive icons.
import 'dart:io';

import 'package:image/image.dart' as img;

void _drawDocument(
  img.Image image, {
  required int size,
  required double scale,
}) {
  final cx = size ~/ 2;
  final cy = size ~/ 2;
  final docW = (size * 0.44 * scale).round();
  final docH = (size * 0.56 * scale).round();
  final x1 = cx - docW ~/ 2;
  final y1 = cy - docH ~/ 2;
  final x2 = cx + docW ~/ 2;
  final y2 = cy + docH ~/ 2;
  final radius = (size * 0.05).round();

  img.fillRect(
    image,
    x1: x1,
    y1: y1,
    x2: x2,
    y2: y2,
    radius: radius,
    color: img.ColorRgba8(255, 255, 255, 255),
  );

  // Text lines in teal.
  final lineColor = img.ColorRgba8(0, 105, 92, 255);
  final lineX1 = x1 + (docW * 0.16).round();
  final lineX2 = x2 - (docW * 0.16).round();
  final thickness = (size * 0.018).round().clamp(2, 40);
  for (var i = 0; i < 3; i++) {
    final ly = y1 + (docH * (0.24 + i * 0.16)).round();
    img.fillRect(
      image,
      x1: lineX1,
      y1: ly,
      x2: lineX2,
      y2: ly + thickness,
      radius: thickness ~/ 2,
      color: lineColor,
    );
  }

  // Lock badge: accent circle with a white keyhole, bottom-right.
  final bx = x2 - (docW * 0.16).round();
  final by = y2 - (docH * 0.16).round();
  final br = (size * 0.075 * scale).round();
  img.fillCircle(
    image,
    x: bx,
    y: by,
    radius: br,
    color: img.ColorRgba8(77, 182, 172, 255),
  );
  img.fillCircle(
    image,
    x: bx,
    y: by,
    radius: (br * 0.42).round(),
    color: img.ColorRgba8(255, 255, 255, 255),
  );
}

void main() {
  final dir = Directory('assets/icon')..createSync(recursive: true);
  const size = 1024;

  // Full icon: teal background + document.
  final full = img.Image(width: size, height: size, numChannels: 4);
  img.fill(full, color: img.ColorRgba8(0, 105, 92, 255));
  _drawDocument(full, size: size, scale: 1.0);
  File('${dir.path}/app_icon.png').writeAsBytesSync(img.encodePng(full));

  // Adaptive foreground: transparent background, smaller document (safe zone).
  final fg = img.Image(width: size, height: size, numChannels: 4);
  img.fill(fg, color: img.ColorRgba8(0, 0, 0, 0));
  _drawDocument(fg, size: size, scale: 0.72);
  File(
    '${dir.path}/app_icon_foreground.png',
  ).writeAsBytesSync(img.encodePng(fg));

  stdout.writeln('Wrote assets/icon/app_icon.png and app_icon_foreground.png');
}
