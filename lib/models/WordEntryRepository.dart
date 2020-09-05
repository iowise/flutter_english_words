import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

final String WORDS_TABLE = '_word_entry';

final String _columnId = '_id';
final String _columnWord = 'word';
final String _columnTranslation = 'translation';
final String _columnContext = 'context';
final String _columnCreatedAt = '_created_at';
final String _columnTrainedAt = '_trained_at';
final String columnDueToLearnAfter = '_due_to_learn_after';

class WordEntry {
  String id;

  String word;
  String translation;
  String context;

  DateTime createdAt;
  DateTime trainedAt;
  DateTime dueToLearnAfter;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      _columnWord: word,
      _columnTranslation: translation,
      _columnContext: context,
      _columnCreatedAt: createdAt.toIso8601String(),
    };
    if (id != null) {
      map[_columnId] = id;
    }
    if (trainedAt != null) {
      map[_columnTrainedAt] = trainedAt.toIso8601String();
    }
    if (dueToLearnAfter != null) {
      map[columnDueToLearnAfter] = dueToLearnAfter.toIso8601String();
    }
    return map;
  }

  WordEntry.create(this.word, this.translation, this.context) {
    createdAt = DateTime.now();
  }

  WordEntry.copy(WordEntry other,
      {final String word, final String translation, final String context}) {
    this.id = other.id;
    this.createdAt = other.createdAt;
    this.trainedAt = other.trainedAt;
    this.dueToLearnAfter = other.dueToLearnAfter;

    this.word = word != null ? word : other.word;
    this.translation = translation != null ? translation : other.translation;
    this.context = context != null ? context : other.context;
  }

  WordEntry.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    word = map[_columnWord];
    translation = map[_columnTranslation];
    context = map[_columnContext] ?? '';
    createdAt = DateTime.parse(map[_columnCreatedAt]);

    trainedAt = map[_columnTrainedAt] != null
        ? DateTime.parse(map[_columnTrainedAt])
        : null;
    dueToLearnAfter = map[columnDueToLearnAfter] != null
        ? DateTime.parse(map[columnDueToLearnAfter])
        : null;
  }
}

class WordEntryRepository extends ChangeNotifier {
  CollectionReference words;

  WordEntryRepository() {
    words = FirebaseFirestore.instance
        .collection('words')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('list');
  }

  static String get createSqlScript => '''
create table $WORDS_TABLE (
  $_columnWord text not null,
  $_columnTranslation text not null,
  $_columnContext text,
  $_columnCreatedAt datatime not null,
  $_columnTrainedAt datatime,
  $columnDueToLearnAfter datatime,
  $_columnId integer primary key autoincrement
)
''';

  static String get migrateAddContextColumn => '''
alter table $WORDS_TABLE
add $_columnContext text
''';

  Future<WordEntry> insert(WordEntry entry) async {
    final reference = await words.add(entry.toMap());
    entry.id = reference.id;
    notifyListeners();
    return entry;
  }

  Future<WordEntry> getWordEntry(String id) async {
    final snapshot = await words.doc(id).get();
    return snapshot.exists ? WordEntry.fromMap(snapshot.data()) : null;
  }

  Future<List<WordEntry>> getWordEntries() async {
    final snapshot = await words.get();
    return [for (final doc in snapshot.docs) WordEntry.fromMap(doc.data())];
  }

  Future<List<WordEntry>> query({
    CollectionReference Function(CollectionReference collection) where,
  }) async {
    final snapshot = await where(words).get();
    return [for (final doc in snapshot.docs) WordEntry.fromMap(doc.data())];
  }

  Future delete(String id) async {
    await words.doc(id).delete();
    notifyListeners();
  }

  Future update(WordEntry entry) async {
    await words.doc(entry.id).update(entry.toMap());
    notifyListeners();
  }

  Future save(WordEntry entry) {
    if (entry.id == null) {
      return insert(entry);
    } else {
      return update(entry);
    }
  }

  Future<WordEntry> findCopy(String word) async {
    final snapshot = await words.where(_columnWord, isEqualTo: word).get();
    final entries = [
      for (final doc in snapshot.docs) WordEntry.fromMap(doc.data())
    ];

    return entries.isNotEmpty ? entries[0] : null;
  }
}
