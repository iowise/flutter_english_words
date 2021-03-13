import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_trainer/models/repositories/TrainLogRepository.dart';

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

  @override
  List<Object?> get props => [logs];
}

class TrainLogCubit extends Cubit<TrainLogState> {
  final TrainLogRepository repository;

  TrainLogCubit(this.repository)
      : super(new TrainLogState(logs: List<TrainLog>.empty()));

  factory TrainLogCubit.setup(TrainLogRepository repository) {
    final cubit = TrainLogCubit(repository);

    final refreshWords = () async {
      if (!repository.isReady) return;

      final logs = await repository.dumpLogs();
      cubit.emit(TrainLogState(logs: logs, isConfigured: true));
    };

    Firebase.initializeApp().whenComplete(() {
      FirebaseAuth.instance.userChanges().listen((_) => refreshWords());
    });

    if (repository.isReady) refreshWords();
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
