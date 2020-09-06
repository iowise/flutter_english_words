import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import './models/WordEntryRepository.dart';
import './models/SpaceRepetitionScheduler.dart';
import './models/TrainLogRepository.dart';
import './models/DB.dart';
import './models/Notification.dart';

void setup() {
  GetIt.I.registerSingletonAsync<FirebaseApp>(() async {
    await Firebase.initializeApp();
  });
  GetIt.I.registerSingletonAsync<Database>(() async {
    await showNotification();
    return await createDatabase();
  });
  GetIt.I.registerSingletonAsync<WordEntryRepository>(() async {
    final db = await GetIt.I.getAsync<Database>();
    return WordEntryRepository();
  }, dependsOn: [Database]);

  GetIt.I.registerSingletonAsync<TrainLogRepository>(() async {
    final wordEntryRepository = await GetIt.I.getAsync<WordEntryRepository>();
    return TrainLogRepository();
  }, dependsOn: [WordEntryRepository]);

  GetIt.I.registerSingletonAsync<TrainService>(() async {
    final wordEntryRepository = await GetIt.I.getAsync<WordEntryRepository>();
    final trainLogRepository = await GetIt.I.getAsync<TrainLogRepository>();
    return TrainService(wordEntryRepository, trainLogRepository);
  }, dependsOn: [WordEntryRepository, TrainLogRepository]);
}
