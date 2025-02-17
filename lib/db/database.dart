import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:lock_vault/share/info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast_sqflite/sembast_sqflite.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:sqflite/sqflite.dart' as sqflite;

Future<Database> databases() async {
  var path = await _buildDatabasesPath(dbName);
  return await _databaseFactory.openDatabase(path);
}

Future<String> _buildDatabasesPath(String dbName) async {
  if (kIsWeb) {
    return dbName;
  }
  var docDir = await getApplicationDocumentsDirectory();
  var dbPath = join(docDir.path, packageName);
  var dir = Directory(dbPath);

  //let exception propagate
  await dir.create(recursive: true);
  return join(dbPath, dbName);
}

/// Sembast sqflite ffi based database factory.
/// Supports Windows/Linux/MacOS for now.
sqflite.DatabaseFactory get _defaultDatabaseFactory =>
    (Platform.isLinux || Platform.isWindows) ? ffi.databaseFactoryFfi : ffi.databaseFactory;

DatabaseFactory get _databaseFactory =>
    (kIsWeb) ? databaseFactoryWeb : getDatabaseFactorySqflite(_defaultDatabaseFactory);
