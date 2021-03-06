import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import './models/SharedWords.dart';
import './pages/WordDetails.dart';
import 'models/repositories/WordEntryRepository.dart';
import './models/SpaceRepetitionScheduler.dart';
import 'models/repositories/TrainLogRepository.dart';
import './models/Notification.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void setup() {
  GetIt.I.registerSingleton(navigatorKey, instanceName: 'Navigator');
  GetIt.I.registerSingletonAsync<FirebaseApp>(() async {
    await showNotification();
    return await Firebase.initializeApp();
  });
  GetIt.I.registerSingleton<WordEntryRepository>(
    WordEntryRepository(),
  );

  GetIt.I.registerSingletonWithDependencies<TrainLogRepository>(
    () => TrainLogRepository(),
    dependsOn: [FirebaseApp],
  );

  GetIt.I.registerSingletonWithDependencies<TrainService>(
    () => TrainService(
        GetIt.I.get<WordEntryRepository>(), GetIt.I.get<TrainLogRepository>()),
    dependsOn: [TrainLogRepository],
  );

  GetIt.I.registerSingletonWithDependencies<SharedWordsService>(() {
    final service = SharedWordsService((word) {
      GetIt.I.get(instanceName: 'Navigator').currentState.pushNamed(
          "/word/create",
          arguments: WordDetailsArguments(word: word));
    });
    return service;
  }, dependsOn: [TrainService]);
}
