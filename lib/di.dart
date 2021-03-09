import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import './models/SharedWords.dart';
import './pages/WordDetails.dart';
import './models/repositories/WordEntryRepository.dart';
import './models/SpaceRepetitionScheduler.dart';
import './models/repositories/TrainLogRepository.dart';
import './models/Notification.dart';
import './models/blocs/TrainLogCubit.dart';
import './models/blocs/WordEntryCubit.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void setup() {
  GetIt.I.registerSingleton(navigatorKey, instanceName: 'Navigator');
  GetIt.I.registerSingletonAsync<FirebaseApp>(() async {
    await showNotification();
    return await Firebase.initializeApp();
  });
  GetIt.I.registerSingleton<WordEntryRepository>(WordEntryRepository());
  GetIt.I.registerSingletonAsync<WordEntryCubit>(
    () async => WordEntryCubit.setup(GetIt.I.get<WordEntryRepository>()),
    dependsOn: [FirebaseApp],
  );

  GetIt.I.registerSingleton<TrainLogRepository>(TrainLogRepository());
  GetIt.I.registerSingletonAsync<TrainLogCubit>(
    () async => TrainLogCubit.setup(GetIt.I.get<TrainLogRepository>()),
    dependsOn: [FirebaseApp],
  );

  GetIt.I.registerSingletonWithDependencies<TrainService>(
    () => TrainService(GetIt.I.get<WordEntryCubit>(), GetIt.I.get<TrainLogCubit>()),
    dependsOn: [TrainLogCubit, WordEntryCubit, FirebaseApp],
  );

  GetIt.I.registerSingletonWithDependencies<SharedWordsService>(() {
    final service = SharedWordsService((word) {
      final navigatorObj = GetIt.I.get(instanceName: 'Navigator');
      final navigator = navigatorObj as GlobalKey<NavigatorState>;
      navigator.currentState?.pushNamed("/word/create",
          arguments: WordDetailsArguments(word: word));
    });
    return service;
  }, dependsOn: [TrainService]);
}
