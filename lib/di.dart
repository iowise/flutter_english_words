import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import './models/WordEntryRepository.dart';
import './models/SpaceRepetitionScheduler.dart';
import './models/TrainLogRepository.dart';
import './models/DB.dart';

void setup() {
  GetIt.I.registerSingletonAsync<Database>(() async {
    return await createDatabase();
  });
  GetIt.I.registerSingletonAsync<WordEntryRepository>(() async {
    final db = await GetIt.I.getAsync<Database>();
    return WordEntryRepository(db);
  }, dependsOn: [Database]);

  GetIt.I.registerSingletonAsync<TrainLogRepository>(() async {
    final wordEntryRepository = await GetIt.I.getAsync<WordEntryRepository>();
    return TrainLogRepository(wordEntryRepository.db);
  }, dependsOn: [WordEntryRepository]);

  GetIt.I.registerSingletonAsync<TrainService>(() async {
    final wordEntryRepository = await GetIt.I.getAsync<WordEntryRepository>();
    final trainLogRepository = await GetIt.I.getAsync<TrainLogRepository>();
    return TrainService(wordEntryRepository, trainLogRepository);
  }, dependsOn: [WordEntryRepository, TrainLogRepository]);
}
