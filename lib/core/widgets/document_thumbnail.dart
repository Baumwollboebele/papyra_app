import 'dart:io';

import 'package:flutter/material.dart';

/// A rounded document thumbnail with a graceful fallback, wrapped in a [Hero]
/// so it animates from a list into the detail view.
class DocumentThumbnail extends StatelessWidget {
  const DocumentThumbnail({
    required this.documentId,
    required this.thumbnailPath,
    this.width = 56,
    this.height = 72,
    this.heroEnabled = true,
    super.key,
  });

  final int documentId;
  final String? thumbnailPath;
  final double width;
  final double height;
  final bool heroEnabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget image;
    final path = thumbnailPath;
    if (path != null && File(path).existsSync()) {
      image = Image.file(
        File(path),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(scheme),
      );
    } else {
      image = _placeholder(scheme);
    }

    final rounded = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(width: width, height: height, child: image),
    );

    if (!heroEnabled) return rounded;
    return Hero(tag: 'doc-thumb-$documentId', child: rounded);
  }

  Widget _placeholder(ColorScheme scheme) {
    return Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.description_outlined, color: scheme.onSurfaceVariant),
    );
  }
}
