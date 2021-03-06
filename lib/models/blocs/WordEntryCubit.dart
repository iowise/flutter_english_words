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
  final Map<String, int> labels;
  final isConfigured = false;

  WordEntryListState({
    @required this.allWords,
    this.sorting = Sorting.byDate,
    this.filtering = Filtering.all,
    this.selectedLabel,
  })  : selectedWords =
            sortAndFilter(sorting, filtering, selectedLabel, allWords),
        labels = getAllLabels(allWords) {
    wordsToReview = filterWordsToReview(selectedWords).toList(growable: false);
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

Map<String, int> getAllLabels(List<WordEntry> entries) {
  final labels = entries.expand((e) => e.labels).toList(growable: false);

  var labelsAndCount = <String, int>{};
  for (final element in labels) {
    if (labelsAndCount[element] == null) {
      labelsAndCount[element] = 0;
    }
    labelsAndCount[element] += 1;
  }

  return labelsAndCount;
}

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

Iterable<WordEntry> filterWordsToReview(List<WordEntry> selectedWords) {
  final now = DateTime.now();
  return selectedWords.where((word) =>
  (word.dueToLearnAfter == null || word.dueToLearnAfter.isBefore(now)));
}
