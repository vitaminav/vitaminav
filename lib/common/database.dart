import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// A [Future<Database>] for the contents' SQLite database, to be used acrooss
/// all the different screens and widgets
final Future<Database> dbFuture = _loadAssetDatabase('vitaminav.db');

Future<Database> _loadAssetDatabase(String dbName) async {
  // Get the path of the database
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, dbName);

  // Check last saved version from shared preferences
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();
  String savedVersion;
  try {
    savedVersion = prefs.getString('dbVersion');
  } catch (e) {}
  // A way to uniquely identify a database version
  // At the moment it is assumed to coincide with the app version
  final currentVersion = '${packageInfo.version}:${packageInfo.buildNumber}';

  // Copy a new database from the asset, if needed
  var exists = await databaseExists(path);

  savedVersion = null; // TODO: PATCH: force database reload
  if (!exists || savedVersion == null || currentVersion != savedVersion) {
    // Create directories if needed
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(join('assets', dbName));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);

    // Update saved version
    prefs.setString('dbVersion', currentVersion);

    print('Database reloaded from assets.');
  }

  return await openDatabase(path);
}
