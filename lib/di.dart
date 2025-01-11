import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import './models/CacheOptions.dart';
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
    final app = await Firebase.initializeApp();
    FirebaseFirestore.instance.settings =
        Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);

    await setupCrashLytics();
    return app;
  });
  GetIt.I.registerSingletonWithDependencies<CacheOptions>(
    () => CacheOptions(FirebaseAuth.instance.currentUser != null),
    dependsOn: [FirebaseApp],
  );
  GetIt.I.registerSingleton<WordEntryRepository>(WordEntryRepository());
  GetIt.I.registerSingletonAsync<WordEntryCubit>(
    () async => WordEntryCubit.setup(
        GetIt.I.get<WordEntryRepository>(), GetIt.I.get<CacheOptions>()),
    dependsOn: [FirebaseApp],
  );

  GetIt.I.registerSingleton<TrainLogRepository>(TrainLogRepository());
  GetIt.I.registerSingletonAsync<TrainLogCubit>(
    () async => TrainLogCubit.setup(
        GetIt.I.get<TrainLogRepository>(), GetIt.I.get<CacheOptions>()),
    dependsOn: [FirebaseApp],
  );

  GetIt.I.registerSingletonWithDependencies<TrainService>(
    () => TrainService(
        GetIt.I.get<WordEntryCubit>(), GetIt.I.get<TrainLogCubit>()),
    dependsOn: [TrainLogCubit, WordEntryCubit, FirebaseApp],
  );
}

Future setupCrashLytics() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);
}
