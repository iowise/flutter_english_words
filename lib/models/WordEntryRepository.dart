import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

final String WORDS_TABLE = '_word_entry';

final String _columnId = '_id';
final String _columnWord = 'word';
final String _columnTranslation = 'translation';
final String _columnCreatedAt = '_created_at';
final String _columnTrainedAt = '_trained_at';
final String columnDueToLearnAfter = '_due_to_learn_after';

class WordEntry {
  int id;

  String word;
  String translation;

  DateTime createdAt;
  DateTime trainedAt;
  DateTime dueToLearnAfter;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      _columnWord: word,
      _columnTranslation: translation,
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

  WordEntry.create(this.word, this.translation) {
    createdAt = DateTime.now().toUtc();
  }

  WordEntry.copy(WordEntry other,
      {final String word, final String translation}) {
    this.id = other.id;
    this.createdAt = other.createdAt;
    this.trainedAt = other.trainedAt;
    this.dueToLearnAfter = other.dueToLearnAfter;
    this.word = word != null ? word : other.word;
    this.translation = translation != null ? translation : other.translation;
  }

  WordEntry.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    word = map[_columnWord];
    translation = map[_columnTranslation];
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
  Database db;

  WordEntryRepository(this.db) {
    assert(db.isOpen, 'The DB must be open');
  }

  static String get createSqlScript => '''
create table $WORDS_TABLE (
  $_columnWord text not null,
  $_columnTranslation text not null,
  $_columnCreatedAt datatime not null,
  $_columnTrainedAt datatime,
  $columnDueToLearnAfter datatime,
  $_columnId integer primary key autoincrement
)
''';

  Future<WordEntry> insert(WordEntry entry) async {
    entry.id = await db.insert(WORDS_TABLE, entry.toMap());
    notifyListeners();
    return entry;
  }

  Future<WordEntry> getWordEntry(int id) async {
    List<Map> maps =
        await db.query(WORDS_TABLE, where: '$_columnId = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return WordEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<WordEntry>> getWordEntries() async {
    List<Map> maps = await db.query(WORDS_TABLE);
    return [for (var map in maps) WordEntry.fromMap(map)];
  }

  Future<List<WordEntry>> query({final where, final whereArgs}) async {
    List<Map> maps = await db.query(WORDS_TABLE, where: where, whereArgs: whereArgs);
    return [for (var map in maps) WordEntry.fromMap(map)];
  }

  Future<int> delete(int id) async {
    var deleted =
        await db.delete(WORDS_TABLE, where: '$_columnId = ?', whereArgs: [id]);
    notifyListeners();
    return deleted;
  }

  Future<int> update(WordEntry entry) async {
    var updated = await db.update(WORDS_TABLE, entry.toMap(),
        where: '$_columnId = ?', whereArgs: [entry.id]);
    notifyListeners();
    return updated;
  }

  Future close() async => db.close();

  Future save(WordEntry entry) {
    if (entry.id == null) {
      return insert(entry);
    } else {
      return update(entry);
    }
  }
}
