import 'package:equatable/equatable.dart';
import "package:collection/collection.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mutex/mutex.dart';

import '../CacheOptions.dart';
import '../repositories/TrainLogRepository.dart';

class TrainLogState extends Equatable {
  final List<TrainLog> logs;
  final bool isConfigured;

  TrainLogState({
    required this.logs,
    this.isConfigured = false,
  });

  TrainLogState copy({
    required List<TrainLog> logs,
  }) {
    return TrainLogState(logs: logs, isConfigured: this.isConfigured);
  }

  List<TrainLog> getLogs(String wordId) =>
      logs.where((e) => e.wordId == wordId).toList(growable: false);

  List<TrainLog> get todayTrained {
    final today = DateTime.now();
    return logs
        .where((e) => dateEquals(e.trainedAt, today))
        .toList(growable: false);
  }

  String get strikes {
    final perDay = groupBy<TrainLog, String>(
      logs,
      (element) => strikeKey(element.trainedAt),
    );
    final today = DateTime.now();
    final todayStrike = perDay.containsKey(strikeKey(today)) ? 1 : 0;
    for (var i = 1; i < 999; i++) {
      final rollingDate = today.subtract(Duration(days: i));
      final wasTrainedInDay = perDay.containsKey(strikeKey(rollingDate));
      if (!wasTrainedInDay) {
        final strikesBeforeToday = i - 1;
        return (strikesBeforeToday + todayStrike).toString();
      }
    }
    return "999+";
  }

  @override
  List<Object?> get props => [logs];
}

String strikeKey(DateTime date) => "${date.year}-${date.month}-${date.day}";

class TrainLogCubit extends Cubit<TrainLogState> {
  final TrainLogRepository repository;
  final CacheOptions cacheOptions;
  final mutex = Mutex();

  TrainLogCubit(this.repository, this.cacheOptions)
      : super(new TrainLogState(logs: <TrainLog>[]));

  factory TrainLogCubit.setup(
      TrainLogRepository repository, CacheOptions cacheOptions) {
    final cubit = TrainLogCubit(repository, cacheOptions);
    final refreshLogs = ({bool firstRun = true}) async {
      if (!repository.isReady || (!firstRun && cubit.mutex.isLocked)) return;

      final logs = await repository.dumpLogs(cacheOptions.hasCacheConfigured);
      cubit.emit(TrainLogState(logs: logs, isConfigured: true));
    };

    Firebase.initializeApp().whenComplete(() {
      FirebaseAuth.instance
          .userChanges()
          .listen((_) => refreshLogs(firstRun: false));
    });

    if (repository.isReady) {
      cubit.mutex.protect(refreshLogs);
    }

    return cubit;
  }

  Future insert(TrainLog log) async {
    await repository.insert(log);

    emit(state.copy(logs: [...state.logs, log]));
  }

  Future deleteLogsForWord(wordId) async {
    await repository.deleteLogsForWord(wordId);

    final prunedLogs = state.logs.where((e) => e.wordId != wordId);
    emit(state.copy(logs: prunedLogs.toList(growable: false)));
  }
}

bool dateEquals(DateTime date, DateTime today) {
  return date.day == today.day &&
      date.month == today.month &&
      date.year == today.year;
}
