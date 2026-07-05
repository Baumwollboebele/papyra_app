import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

/// Raised when a backup cannot be created or a restore file is invalid.
class BackupException implements Exception {
  const BackupException(this.message);
  final String message;
  @override
  String toString() => 'BackupException: $message';
}

/// Creates and restores full, offline ZIP backups.
///
/// Backup layout (documented in README):
/// ```
/// manifest.json            { format, app, schemaVersion, createdAt, baseDir }
/// papyra.sqlite        the SQLite database
/// files/papyra/pages/… scanned page images
/// files/papyra/thumbnails/…
/// files/papyra/pdfs/…  generated PDFs
/// ```
/// On restore, absolute file paths stored in the database are rewritten from the
/// backup's original `baseDir` to this device's directory, so a backup restores
/// correctly even on a different device.
class BackupService {
  /// [documentsDirectory] and [temporaryDirectory] default to path_provider;
  /// tests inject temp directories.
  BackupService({
    Future<Directory> Function()? documentsDirectory,
    Future<Directory> Function()? temporaryDirectory,
  }) : _docsDirProvider =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _tempDirProvider = temporaryDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _docsDirProvider;
  final Future<Directory> Function() _tempDirProvider;

  static const int formatVersion = 1;

  /// Mirrors [AppDatabase.schemaVersion]; recorded in the manifest so a future
  /// version can detect and migrate older backups.
  static const int schemaVersion = 4;

  static const _dbFileName = 'papyra.sqlite';
  static const _mediaDirName = 'papyra';

  Future<Directory> _docsDir() => _docsDirProvider();

  /// Builds a backup ZIP in a temporary directory and returns its path.
  Future<String> createBackup() async {
    final docs = await _docsDir();
    final dbFile = File(p.join(docs.path, _dbFileName));
    final mediaDir = Directory(p.join(docs.path, _mediaDirName));

    final archive = Archive();

    final manifest = <String, Object?>{
      'app': 'Papyra',
      'format': formatVersion,
      'schemaVersion': schemaVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'baseDir': mediaDir.path,
    };
    _addBytes(
      archive,
      'manifest.json',
      utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest)),
    );

    if (dbFile.existsSync()) {
      _addBytes(archive, _dbFileName, await dbFile.readAsBytes());
    }
    if (mediaDir.existsSync()) {
      for (final entity in mediaDir.listSync(recursive: true)) {
        if (entity is File) {
          final rel = p.relative(entity.path, from: docs.path);
          _addBytes(
            archive,
            'files/${rel.replaceAll(r'\', '/')}',
            await entity.readAsBytes(),
          );
        }
      }
    }

    final zip = ZipEncoder().encode(archive);
    final tmp = await _tempDirProvider();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-')
        .substring(0, 19);
    final outPath = p.join(tmp.path, 'papyra-backup-$stamp.zip');
    await File(outPath).writeAsBytes(zip, flush: true);
    return outPath;
  }

  /// Restores from a backup ZIP. [closeActiveDatabase] must close the app's live
  /// database connection before files are overwritten; the caller reopens it
  /// afterwards (e.g. by invalidating the database provider).
  Future<void> restoreBackup(
    String zipPath, {
    required Future<void> Function() closeActiveDatabase,
  }) async {
    final bytes = await File(zipPath).readAsBytes();
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const BackupException('Die Datei ist keine gültige Sicherung.');
    }

    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) {
      throw const BackupException('Die Sicherung ist unvollständig.');
    }
    final manifest =
        jsonDecode(utf8.decode(manifestFile.content as List<int>)) as Map;
    if (manifest['format'] != formatVersion) {
      throw const BackupException('Nicht unterstütztes Sicherungsformat.');
    }
    final oldBase = manifest['baseDir'] as String?;

    final docs = await _docsDir();
    final newBase = p.join(docs.path, _mediaDirName);

    await closeActiveDatabase();

    // Replace media directory.
    final mediaDir = Directory(newBase);
    if (mediaDir.existsSync()) {
      mediaDir.deleteSync(recursive: true);
    }

    for (final file in archive.files) {
      if (!file.isFile) continue;
      final name = file.name;
      final content = file.content as List<int>;
      if (name == _dbFileName) {
        await File(
          p.join(docs.path, _dbFileName),
        ).writeAsBytes(content, flush: true);
      } else if (name.startsWith('files/')) {
        final rel = name.substring('files/'.length);
        final dest = File(p.join(docs.path, rel));
        dest.parent.createSync(recursive: true);
        await dest.writeAsBytes(content, flush: true);
      }
    }

    // Rewrite absolute paths if the device's directory differs.
    if (oldBase != null && oldBase != newBase) {
      final db = AppDatabase();
      try {
        await db.customStatement(
          'UPDATE documents SET pdf_path = replace(pdf_path, ?, ?)',
          [oldBase, newBase],
        );
        await db.customStatement(
          'UPDATE documents SET thumbnail_path = replace(thumbnail_path, ?, ?) '
          'WHERE thumbnail_path IS NOT NULL',
          [oldBase, newBase],
        );
        await db.customStatement(
          'UPDATE document_pages SET image_path = replace(image_path, ?, ?)',
          [oldBase, newBase],
        );
      } finally {
        await db.close();
      }
    }
  }

  void _addBytes(Archive archive, String name, List<int> bytes) {
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }
}

final backupServiceProvider = Provider<BackupService>((ref) => BackupService());
