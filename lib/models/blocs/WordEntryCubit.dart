import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:equatable/equatable.dart';
import '../repositories/WordEntryRepository.dart';

enum Sorting {
  byDate,
  byWord,
}

enum Filtering {
  all,
  unTrained,
}

const EMPTY = "";

@immutable
class WordEntryListState extends Equatable {
  final Sorting sorting;
  final Filtering filtering;
  final String? selectedLabel;

  final List<WordEntry> allWords;
  final List<WordEntry> selectedWords;
  late final List<WordEntry> wordsToReview;

  late final LabelsStatistic labelsStatistics;

  final isConfigured;

  WordEntryListState({
    required this.allWords,
    this.sorting = Sorting.byDate,
    this.filtering = Filtering.all,
    required this.selectedLabel,
    this.isConfigured = false,
  }) : selectedWords =
            sortAndFilter(sorting, filtering, selectedLabel, allWords) {
    final now = DateTime.now();
    labelsStatistics = getAllLabels(allWords, now);
    wordsToReview =
        filterWordsToReview(selectedWords, now).toList(growable: false);
    wordsToReview.sort((right, left) => right.id!.compareTo(left.id!));
  }

  WordEntryListState copy({
    Sorting? sorting,
    Filtering? filtering,
    String? selectedLabel = EMPTY,
    List<WordEntry>? words,
    bool? isConfigured,
  }) {
    return WordEntryListState(
      sorting: sorting ?? this.sorting,
      filtering: filtering ?? this.filtering,
      selectedLabel:
          selectedLabel != EMPTY ? selectedLabel : this.selectedLabel,
      allWords: words ?? allWords,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }

  @override
  List<Object?> get props => [
        isConfigured,
        sorting,
        filtering,
        selectedLabel,
        allWords,
        labelsStatistics,
      ];
}

class WordEntryCubit extends Cubit<WordEntryListState> {
  final WordEntryRepository repository;

  WordEntryCubit(this.repository)
      : super(new WordEntryListState(
          allWords: List<WordEntry>.empty(growable: false),
          selectedLabel: null,
        ));

  factory WordEntryCubit.setup(WordEntryRepository repository) {
    final cubit = WordEntryCubit(repository);
    final refreshWords = () async {
      if (!repository.isReady) return;

      final words = await repository.getAllWordEntries();
      cubit.emit(cubit.state.copy(words: words, isConfigured: true));
    };
    Firebase.initializeApp().whenComplete(() {
      FirebaseAuth.instance.userChanges().listen((_) => refreshWords());
    });

    if (repository.isReady) refreshWords();
    return cubit;
  }

  void setFiltering(Filtering _filtering) async {
    emit(state.copy(filtering: _filtering));
  }

  void setSorting(Sorting _sorting) async {
    emit(state.copy(sorting: _sorting));
  }

  void useLabel(String? label) async {
    emit(state.copy(selectedLabel: label));
  }

  Future save(WordEntry entry) async {
    if (entry.id == null) {
      return create(entry);
    } else {
      return update(entry);
    }
  }

  Future create(WordEntry word) async {
    await repository.insert(word);

    final newState =
        state.copy(words: [...state.allWords, word].toList(growable: false));
    final isSame = state == newState;
    emit(newState);
  }

  Future update(WordEntry word) async {
    await repository.update(word);
    final others = state.allWords.where((element) => element.id! != word.id);

    emit(state.copy(words: [...others, word].toList(growable: false)));
  }

  Future delete(WordEntry word) async {
    final wordId = word.id!;
    await this.repository.delete(wordId);
    final words = state.allWords.where((element) => element.id! != wordId);

    emit(state.copy(words: words.toList(growable: false)));
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}

@immutable
class LabelWithStatistic extends Equatable {
  final int total;
  final int toLearn;
  final String label;

  LabelWithStatistic(
    this.label, {
    required this.toLearn,
    required this.total,
  });

  @override
  List<Object?> get props => [total, toLearn, label];
}

@immutable
class LabelsStatistic extends Iterable<LabelWithStatistic> {
  final List<LabelWithStatistic> _list;

  LabelsStatistic(this._list);

  List<String>? _labels = null;

  List<String> get labels =>
      _labels ??= _list.map((e) => e.label).toList(growable: true);

  @override
  Iterator<LabelWithStatistic> get iterator => _list.iterator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelsStatistic &&
          runtimeType == other.runtimeType &&
          _list == other._list;

  @override
  int get hashCode => _list.hashCode;
}

LabelsStatistic getAllLabels(List<WordEntry> entries, DateTime now) {
  final labels = entries.expand((e) => e.labels).toList(growable: false);

  var labelsAndCount = <String, int>{};
  var labelsAndToLearn = <String, int>{};

  for (final element in labels) {
    labelsAndCount.update(element, increment, ifAbsent: one);
  }

  for (final element in entries.where((element) => element.isForLearn(now))) {
    for (final label in element.labels) {
      labelsAndToLearn.update(label, increment, ifAbsent: one);
    }
  }

  final listOfLabelsWithStatistics = labelsAndCount.keys
      .map((e) => LabelWithStatistic(e,
          total: labelsAndCount[e] ?? 0, toLearn: labelsAndToLearn[e] ?? 0))
      .toList(growable: true);
  return LabelsStatistic(listOfLabelsWithStatistics);
}

int increment(v) => v + 1;

int one() => 1;

List<WordEntry> sortAndFilter(Sorting sorting, Filtering filtering,
    String? label, List<WordEntry> words) {
  final filtered = filtering == Filtering.unTrained
      ? words
          .where((element) => element.dueToLearnAfter == null)
          .toList(growable: false)
      : words;
  final selectedByLabel =
      filtered.where((word) => word.hasLabel(label)).toList(growable: false);
  if (sorting == Sorting.byWord) {
    selectedByLabel.sort((left, right) => left.word.compareTo(right.word));
  } else {
    selectedByLabel
        .sort((left, right) => -left.createdAt.compareTo(right.createdAt));
  }

  return selectedByLabel;
}

Iterable<WordEntry> filterWordsToReview(
    List<WordEntry> selectedWords, DateTime now) {
  return selectedWords.where((word) => word.isForLearn(now));
}
