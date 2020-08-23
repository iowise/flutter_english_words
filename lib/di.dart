import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import './models/WordEntryRepository.dart';

void setup() {
  GetIt.I.registerSingletonAsync<WordEntryRepository>(() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'words.db');

    final repository = WordEntryRepository();
    await repository.open(path);
    return repository;
  });
}
