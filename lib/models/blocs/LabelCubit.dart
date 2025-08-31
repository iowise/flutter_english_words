import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:equatable/equatable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mutex/mutex.dart';

import '../CacheOptions.dart';
import '../repositories/LabelEntryRepository.dart';

@immutable
class LabelMapState extends Equatable {
  final Map<String, LabelEntry> labelLocales;
  final bool isConfigured;

  LabelMapState({
    required this.labelLocales,
    this.isConfigured = false,
  }) {}

  LabelMapState copy({List<LabelEntry>? newLabels, bool? isConfigured }) {
    final newLabelLocales = Map<String, LabelEntry>.from(this.labelLocales);
    if (newLabels != null) {
      newLabelLocales.addEntries(
          newLabels.map((label) => MapEntry(label.name, label)));
    }
    return LabelMapState(
      labelLocales: newLabelLocales,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }

  String? guessLocale(List<String> labels) {
    final firstLabel = labels.firstOrNull;
    if (firstLabel == null) return null;
    final existingLabel = labelLocales[firstLabel];
    if (existingLabel == null) return null;
    return existingLabel.locale;
  }

  @override
  List<Object?> get props => [isConfigured, labelLocales];
}


class LabelEntryCubit extends Cubit<LabelMapState> {
  final LabelEntryRepository labelRepository;
  final CacheOptions cacheOptions;
  final mutex = Mutex();

  LabelEntryCubit(this.labelRepository, this.cacheOptions)
      : super(new LabelMapState(labelLocales: Map<String, LabelEntry>()));

  factory LabelEntryCubit.setup(LabelEntryRepository labelRepository,
      CacheOptions cacheOptions) {
    final cubit = LabelEntryCubit(labelRepository, cacheOptions);
    final refreshLabels = () async {
      if (cubit.mutex.isLocked) return;

      final labels = await labelRepository.getAllLabelEntries(cacheOptions.hasCacheConfigured);
      cubit.emit(cubit.state.copy(newLabels: labels, isConfigured: true));
    };
    Firebase.initializeApp().whenComplete(() {
      FirebaseAuth.instance.userChanges().listen((user) {
        if (user != null) refreshLabels();
      });
    });

    if (labelRepository.isReady) cubit.mutex.protect(refreshLabels);
    return cubit;
  }

  Future save(List<String> labels, String locale) async {
    final labelEntries = await labelRepository.createLocales(labels, locale);
    final newState = state.copy(newLabels: labelEntries);
    emit(newState);
  }
}
