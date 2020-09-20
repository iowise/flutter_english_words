import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import './models/SharedWords.dart';
import './pages/WordDetails.dart';
import './models/WordEntryRepository.dart';
import './models/SpaceRepetitionScheduler.dart';
import './models/TrainLogRepository.dart';
import './models/DB.dart';
import './models/Notification.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void setup() {
  GetIt.I.registerSingleton(navigatorKey, instanceName: 'Navigator');
  GetIt.I.registerSingletonAsync<FirebaseApp>(() async {
    return await Firebase.initializeApp();
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

  GetIt.I.registerSingletonAsync<SharedWordsService>(() async {
    final service = SharedWordsService((word) => GetIt.I
        .get(instanceName: 'Navigator')
        .currentState
        .pushNamed("/word/create",
        arguments: WordDetailsArguments(word: word)));
    return service;
  }, dependsOn: [TrainService]);
}
