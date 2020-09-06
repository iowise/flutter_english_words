import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'WordEntryRepository.dart';

final String _table = '_train_log';

final String _columnId = '_id';
final String _columnWordId = 'word_id';
final String _columnScore = 'score';
final String _columnTrainedAt = '_trained_at';

class TrainLog {
  int id;

  int wordId;
  int score;

  DateTime trainedAt;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      _columnWordId: wordId,
      _columnScore: score,
      _columnTrainedAt: trainedAt.toIso8601String(),
    };
    if (id != null) {
      map[_columnId] = id;
    }
    return map;
  }

  TrainLog(this.wordId, this.score) {
    trainedAt = DateTime.now();
  }

  TrainLog.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    wordId = map[_columnWordId];
    score = map[_columnScore];
    trainedAt = map[_columnTrainedAt] != null
        ? DateTime.parse(map[_columnTrainedAt])
        : null;
  }
}

class TrainLogRepository extends ChangeNotifier {
  Database db;

  TrainLogRepository(this.db) {
    assert(db.isOpen, 'The DB must be open');
  }

  static String get createSqlScript => '''
create table $_table (
  $_columnWordId int not null,
  $_columnScore int not null,
  $_columnTrainedAt datatime not null,
  $_columnId integer primary key autoincrement,
  FOREIGN KEY($_columnWordId) REFERENCES $WORDS_TABLE($_columnId)
)
''';

  Future<TrainLog> insert(TrainLog log) async {
    log.id = await db.insert(_table, log.toMap());
    notifyListeners();
    return log;
  }

  Future<List<TrainLog>> getLogs(int wordId) async {
    List<Map> maps = await db
        .query(_table, where: '$_columnWordId = ?', whereArgs: [wordId]);
    return [for (var map in maps) TrainLog.fromMap(map)];
  }

  Future<List<TrainLog>> dumpLogs() async {
    List<Map> maps = await db.query(_table);
    return [for (var map in maps) TrainLog.fromMap(map)];
  }

  Future<int> deleteLogsForWord(int wordId) async {
    var deleted = await db
        .delete(_table, where: '$_columnWordId = ?', whereArgs: [wordId]);
    notifyListeners();
    return deleted;
  }

  Future close() async => db.close();
}
