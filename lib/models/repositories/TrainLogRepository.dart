import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String _columnId = '_id';
const String _columnWordId = 'word_id';
const String _columnScore = 'score';
const String _columnTrainedAt = '_trained_at';

class TrainLog extends Equatable {
  String? id;

  late String wordId;
  late int score;

  late DateTime trainedAt;

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
        : DateTime.now();
  }

  factory TrainLog.fromDocument(DocumentSnapshot snapshot) {
    final log = TrainLog.fromMap(snapshot.data() as Map<String, dynamic>);
    log.id = snapshot.reference.id;
    return log;
  }

  @override
  List<Object?> get props => [
        id,
        wordId,
        score,
        trainedAt,
      ];
}

class TrainLogRepository extends ChangeNotifier {
  CollectionReference? _logs;

  CollectionReference? get logs {
    if (FirebaseAuth.instance.currentUser == null) return null;

    _logs ??= FirebaseFirestore.instance
        .collection('trainLog')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('list');
    return _logs;
  }

  get isReady => logs != null;

  Future<TrainLog> insert(TrainLog log) async {
    if (logs == null) return Future.error("User not loaded");

    final reference = await logs!.add(log.toMap());
    log.id = reference.id;
    notifyListeners();
    return log;
  }

  Future<List<TrainLog>> getLogs(String wordId) async {
    if (logs == null) return Future.error("User not loaded");

    final snapshot = await logs!.where(_columnWordId, isEqualTo: wordId).get();
    final entries = [
      for (final doc in snapshot.docs) TrainLog.fromDocument(doc)
    ];
    entries.sort((a, b) => b.trainedAt.compareTo(a.trainedAt));
    return entries;
  }

  Future<List<TrainLog>> dumpLogs(bool fromCache) async {
    if (logs == null) return Future.error("User not loaded");

    final snapshot = await logs!.get(fromCache ? const GetOptions(source: Source.cache) : null);

    return [for (final doc in snapshot.docs) TrainLog.fromDocument(doc)];
  }

  Future deleteLogsForWord(String wordId) async {
    if (logs == null) return Future.error("User not loaded");

    WriteBatch batch = FirebaseFirestore.instance.batch();

    final snapshot = await logs!.where(_columnWordId, isEqualTo: wordId).get(const GetOptions(source: Source.cache));
    for (final element in snapshot.docs) {
      batch.delete(element.reference);
    }
    await batch.commit();
    notifyListeners();
  }
}
