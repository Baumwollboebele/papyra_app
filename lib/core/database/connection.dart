import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the on-device SQLite database inside the app's private documents
/// directory. Nothing here touches the network.
LazyDatabase openAppConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'papyra.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
