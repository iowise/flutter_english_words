import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import './TrainLogRepository.dart';
import './WordEntryRepository.dart';

Future<Database> createDatabase() async {
  var databasesPath = await getDatabasesPath();
  String path = p.join(databasesPath, 'words.db');

  final db = await openDatabase(
    path,
    version: 4,
    onConfigure: _onConfigure,
    onCreate: (Database db, int version) async {
      await db.execute(WordEntryRepository.createSqlScript);
      await db.execute(TrainLogRepository.createSqlScript);
    },
    onUpgrade: (Database db, oldVersion, newVersion) async {
      if (oldVersion == 3) {
        await db.execute(WordEntryRepository.migrateAddContextColumn);
      }
    },
  );

  return db;
}

_onConfigure(Database db) async {
  await db.execute("PRAGMA foreign_keys = ON");
  await db.execute('PRAGMA encoding="UTF-8"');
}

exportDB(WordEntryRepository wordEntryRepository,
    TrainLogRepository trainLogRepository) async {
  final externalDir = (await getExternalStorageDirectory()).path;
  File file = File(externalDir + 'word.train.export.data.json');
  final logs =
      List.of([for (var i in await trainLogRepository.dumpLogs()) i.toMap()]);
  final words = List.of(
      [for (var i in await wordEntryRepository.getWordEntries()) i.toMap()]);
  Map<String, dynamic> exportMaps = {'words': words, 'logs': logs};
  file.writeAsString(json.encode(exportMaps));

  await FlutterShare.shareFile(
    title: 'Example share',
    text: 'Example share text',
    filePath: file.path,
  );
}

importDB(WordEntryRepository wordEntryRepository,
    TrainLogRepository trainLogRepository) async {
  File file = await FilePicker.getFile();
  final json = jsonDecode(await file.readAsString());

  final words = json['words'];
  final wordsMap = {};

  for (final i in words) {
    if (wordEntryRepository.findCopy(i['word']) != null) {
      continue;
    }
    final entry = WordEntry.fromMap(i);
    entry.id = null;
    await wordEntryRepository.insert(entry);
    wordsMap[i['_id']] = entry;
  }

  final logs = json['logs'];
  for (final i in logs) {
    if (wordsMap[i['word_id']] == null) {
      continue;
    }
    final log = TrainLog.fromMap(i);
    log.wordId = wordsMap[i['word_id']].id;
    await trainLogRepository.insert(log);
  }
}
