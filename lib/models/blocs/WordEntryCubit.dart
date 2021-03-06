import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
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
class WordEntryListState {
  final Sorting sorting;
  final Filtering filtering;
  final String selectedLabel;

  final List<WordEntry> allWords;
  final List<WordEntry> selectedWords;
  List<WordEntry> wordsToReview;

  LabelsStatistic labelsStatistics;

  final isConfigured = false;

  WordEntryListState({
    @required this.allWords,
    this.sorting = Sorting.byDate,
    this.filtering = Filtering.all,
    this.selectedLabel,
  }) : selectedWords =
            sortAndFilter(sorting, filtering, selectedLabel, allWords) {
    final now = DateTime.now();
    labelsStatistics = getAllLabels(allWords, now);
    wordsToReview =
        filterWordsToReview(selectedWords, now).toList(growable: false);
    wordsToReview.sort((right, left) => right.id.compareTo(left.id));
  }

  WordEntryListState copy({
    Sorting sorting,
    Filtering filtering,
    String selectedLabel = EMPTY,
    List<WordEntry> words,
  }) {
    return WordEntryListState(
      sorting: sorting ?? this.sorting,
      filtering: filtering ?? this.filtering,
      selectedLabel:
          selectedLabel != EMPTY ? selectedLabel : this.selectedLabel,
      allWords: words ?? allWords,
    );
  }
}

class WordEntryCubit extends Cubit<WordEntryListState> {
  final WordEntryRepository repository;

  WordEntryCubit(this.repository)
      : super(new WordEntryListState(allWords: new List<WordEntry>()));

  factory WordEntryCubit.setup(WordEntryRepository repository) {
    final cubit = WordEntryCubit(repository);
    final refreshWords = () async {
      final words = await repository.getAllWordEntries();
      cubit.emit(cubit.state.copy(words: words));
    };
    Firebase.initializeApp().then((value) {
      FirebaseAuth.instance.userChanges().listen((_) => refreshWords());
    });

    if (repository.isReady) refreshWords();
    repository.addListener(() => refreshWords());
    return cubit;
  }

  void setFiltering(Filtering _filtering) {
    emit(state.copy(filtering: _filtering));
  }

  void setSorting(Sorting _sorting) {
    emit(state.copy(sorting: _sorting));
  }

  void useLabel(String label) {
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
    emit(state.copy(words: [...state.allWords, word]));
  }

  Future update(WordEntry word) async {
    await repository.update(word);
    final others = state.allWords.where((element) => element.id != word.id);
    emit(state.copy(words: [...others, word]));
  }

  Future delete(WordEntry word) async {
    await this.repository.delete(word.id);
    final words = state.allWords.where((element) => element.id != word.id);
    emit(state.copy(words: words.toList(growable: false)));
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('$error, $stackTrace');
    super.onError(error, stackTrace);
  }
}

@immutable
class LabelWithStatistic {
  final int total;
  final int toLearn;
  final String label;

  LabelWithStatistic(
    this.label, {
    @required this.toLearn,
    @required this.total,
  });
}

@immutable
class LabelsStatistic extends Iterable<LabelWithStatistic> {
  final List<LabelWithStatistic> _list;

  LabelsStatistic(this._list);

  List<String> _labels;

  List<String> get labels =>
      _labels ??= _list.map((e) => e.label).toList(growable: true);

  @override
  Iterator<LabelWithStatistic> get iterator => _list.iterator;
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

List<WordEntry> sortAndFilter(
    Sorting sorting, Filtering filtering, String label, List<WordEntry> words) {
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
