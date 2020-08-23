import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

final String _table = '_word_entry';
final String _columnId = '_id';
final String _columnWord = 'word';
final String _columnTranslation = 'translation';
final String _columnCreatedAt = '_created_at';
final String _columnTrainedAt = '_trained_at';

class WordEntry {
  int id;

  String word;
  String translation;

  DateTime createdAt;
  DateTime trainedAt;

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
      map[_columnTrainedAt] = trainedAt;
    }
    return map;
  }

  WordEntry.create(this.word, this.translation) {
    createdAt = DateTime.now().toUtc();
  }
  WordEntry.copy(WordEntry other, {final String word, final String translation}) {
    this.id = other.id;
    this.createdAt = other.createdAt;
    this.trainedAt = other.trainedAt;
    this.word = word != null ? word : other.word;
    this.translation = translation != null ? translation: other.translation;
  }

  WordEntry.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    word = map[_columnWord];
    translation = map[_columnTranslation];
    createdAt = map[_columnCreatedAt];
    trainedAt = map[_columnTrainedAt];
  }
}

class WordEntryRepository extends ChangeNotifier {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $_table ( 
  $_columnWord text not null,
  $_columnTranslation text not null,
  $_columnCreatedAt datatime not null,
  $_columnTrainedAt datatime,
  $_columnId integer primary key autoincrement 
)
''');
    });
    db.execute('PRAGMA encoding="UTF-8"');
  }

  Future<WordEntry> insert(WordEntry entry) async {
    entry.id = await db.insert(_table, entry.toMap());
    notifyListeners();
    return entry;
  }

  Future<WordEntry> getWordEntry(int id) async {
    List<Map> maps = await db.query(_table,
        columns: [_columnId, _columnTranslation, _columnWord],
        where: '$_columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return WordEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<WordEntry>> getWordEntries() async {
    List<Map> maps = await db
        .query(_table, columns: [_columnId, _columnTranslation, _columnWord]);
    return [for (var map in maps) WordEntry.fromMap(map)];
  }

  Future<int> delete(int id) async {
    var deleted = await db.delete(_table, where: '$_columnId = ?', whereArgs: [id]);
    notifyListeners();
    return deleted;
  }

  Future<int> update(WordEntry entry) async {
    var updated = await db.update(_table, entry.toMap(),
        where: '$_columnId = ?', whereArgs: [entry.id]);
    notifyListeners();
    return updated;
  }

  Future close() async => db.close();
  Future reset() async {
    var path = db.path;
    await close();
    await deleteDatabase(path);
    await open(path);
    notifyListeners();
  }

  Future save(WordEntry entry) {
    if (entry.id == null) {
      return insert(entry);
    } else {
      return update(entry);
    }
  }
}
