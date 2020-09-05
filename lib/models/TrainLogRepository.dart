import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'WordEntryRepository.dart';

final String _table = '_train_log';

final String _columnId = '_id';
final String _columnWordId = 'word_id';
final String _columnScore = 'score';
final String _columnTrainedAt = '_trained_at';

class TrainLog {
  String id;

  String wordId;
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
  CollectionReference logs;

  TrainLogRepository() {
    logs = FirebaseFirestore.instance.collection('trainLog');
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
    final reference = await logs.add(log.toMap());
    log.id = reference.id;
    notifyListeners();
    return log;
  }

  Future<List<TrainLog>> getLogs(String wordId) async {
    final snapshot = await logs.where(_columnWordId, isEqualTo: wordId).get();
    return [for (final doc in snapshot.docs) TrainLog.fromMap(doc.data())];
  }

  Future<List<TrainLog>> dumpLogs() async {
    final snapshot = await logs.get();
    return [for (final doc in snapshot.docs) TrainLog.fromMap(doc.data())];
  }

  Future deleteLogsForWord(String wordId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    final snapshot = await logs.where(_columnWordId, isEqualTo: wordId).get();
    for (final element in snapshot.docs) {
      batch.delete(element.reference);
    }
    await batch.commit();
    notifyListeners();
  }
}
