import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

final String _table = '_word_entry';
final String _columnId = '_id';
final String _columnWord = 'word';
final String _columnTranslation = 'translation';

class WordEntry {
  int id;

  String word;
  String translation;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      _columnWord: word,
      _columnTranslation: translation,
    };
    if (id != null) {
      map[_columnId] = id;
    }
    return map;
  }

  WordEntry(this.word, this.translation);

  WordEntry.fromMap(Map<String, dynamic> map) {
    id = map[_columnId];
    word = map[_columnWord];
    translation = map[_columnTranslation];
  }
}

class WordEntryRepository extends ChangeNotifier {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $_table ( 
  $_columnId integer primary key autoincrement, 
  $_columnWord text not null,
  $_columnTranslation text not null)
''');
    });
    db.execute('PRAGMA encoding="UTF-8"');
  }

  Future<WordEntry> insert(WordEntry todo) async {
    todo.id = await db.insert(_table, todo.toMap());
    notifyListeners();
    return todo;
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

  Future<int> update(WordEntry todo) async {
    var updated = await db.update(_table, todo.toMap(),
        where: '$_columnId = ?', whereArgs: [todo.id]);
    notifyListeners();
    return updated;
  }

  Future close() async => db.close();
}
