import 'package:flutter_app/models/TrainLogRepository.dart';
import 'package:flutter_app/models/WordEntryRepository.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

Future<Database> createDatabase() async {
  var databasesPath = await getDatabasesPath();
  String path = p.join(databasesPath, 'words.db');

  final db = await openDatabase(
    path,
    version: 2,
    onCreate: (Database db, int version) async {
      await db.execute(WordEntryRepository.createSqlScript);
    },
    onUpgrade: (Database db, oldVersion, newVersion) async {
      await db.execute('PRAGMA foreign_keys = ON');
      if (oldVersion == 1) await db.execute(TrainLogRepository.createSqlScript);
    },
  );

  await db.execute('PRAGMA foreign_keys = ON');
  await db.execute('PRAGMA encoding="UTF-8"');
  return db;
}
