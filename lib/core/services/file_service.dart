import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/ids.dart';

/// Raised when a file operation fails (e.g. low storage); surfaced to the user
/// with a friendly German message rather than crashing.
class StorageException implements Exception {
  const StorageException(this.message);
  final String message;
  @override
  String toString() => 'StorageException: $message';
}

/// Owns the app's private, on-device file storage: scanned page images, thumbnails
/// and generated PDFs. Nothing here touches the network.
class FileService {
  static const _pagesDir = 'pages';
  static const _thumbsDir = 'thumbnails';
  static const _pdfsDir = 'pdfs';

  Future<Directory> _dir(String sub) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'papyra', sub));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Uint8List> readBytes(String path) => File(path).readAsBytes();

  /// Copies an externally captured page image into persistent storage.
  Future<String> importPage(String sourcePath) async {
    try {
      final dir = await _dir(_pagesDir);
      final ext = p.extension(sourcePath).isEmpty
          ? '.jpg'
          : p.extension(sourcePath);
      final dest = p.join(dir.path, '${uniqueId()}$ext');
      await File(sourcePath).copy(dest);
      return dest;
    } on FileSystemException catch (e) {
      throw StorageException(e.message);
    }
  }

  Future<String> writePdf(Uint8List bytes) => _write(_pdfsDir, bytes, '.pdf');
  Future<String> writeThumbnail(Uint8List bytes) =>
      _write(_thumbsDir, bytes, '.jpg');

  Future<String> _write(String sub, Uint8List bytes, String ext) async {
    try {
      final dir = await _dir(sub);
      final path = p.join(dir.path, '${uniqueId()}$ext');
      await File(path).writeAsBytes(bytes, flush: true);
      return path;
    } on FileSystemException catch (e) {
      throw StorageException(e.message);
    }
  }

  /// Best-effort deletion; missing files are ignored.
  Future<void> deleteAll(Iterable<String> paths) async {
    for (final path in paths) {
      final file = File(path);
      if (file.existsSync()) {
        try {
          await file.delete();
        } on FileSystemException {
          // Ignore: cleanup should never surface as a user-facing error.
        }
      }
    }
  }
}

final fileServiceProvider = Provider<FileService>((ref) => FileService());
