import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../components/Drawer.dart';
import '../models/SharedWords.dart';
import '../models/SpaceRepetitionScheduler.dart';
import '../models/WordEntryRepository.dart';
import '../components/ReviewButton.dart';
import '../components/WordList.dart';
import './WordDetails.dart';

class WordsPage extends StatefulWidget {
  @override
  _WordsPageState createState() => _WordsPageState();
}

enum Sorting {
  byDate,
  byWord,
}

enum Filtering {
  all,
  unTrained,
}

class _WordsPageState extends State<WordsPage> {
  WordEntryRepository repository;
  TrainService trainRepository;
  Sorting sorting = Sorting.byDate;
  Filtering filtering = Filtering.all;
  String filterLabel;

  @override
  void initState() {
    super.initState();
    GetIt.I.isReady<TrainService>().then((value) {
      setState(() {
        repository = GetIt.I.get<WordEntryRepository>();
        trainRepository = GetIt.I.get<TrainService>();
      });
      GetIt.I.getAsync<SharedWordsService>().then((value) => value.init());
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScaffoldWrapper = repository == null
        ? (w) => w
        : (w) =>
            ChangeNotifierProvider(create: (context) => repository, child: w);
    return ScaffoldWrapper(
      Scaffold(
        appBar: AppBar(
          title: buildTitle(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.sort),
              onPressed: () {
                if (repository == null) return;
                _showSortingAndFilter(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (repository == null) return;
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(this.repository, filterLabel),
                );
              },
            ),
          ],
        ),
        drawer: buildDrawer(),
        body: Center(
          child: _buildList(),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add a word',
          child: Icon(Icons.add),
          onPressed: () => Navigator.pushNamed(context, '/word/create',
              arguments: WordDetailsArguments(label: filterLabel)),
        ),
      ),
    );
  }

  Widget buildDrawer() {
    if (repository == null) return AppDrawer.empty();

    return Consumer<WordEntryRepository>(
      builder: (context, wordEntryRepository, child) =>
          FutureBuilder<Map<String, int>>(
        future: wordEntryRepository.getAllLabels(),
        builder:
            (BuildContext context, AsyncSnapshot<Map<String, int>> snapshot) {
          if (!snapshot.hasData) return AppDrawer.empty();
          return AppDrawer(
            allLabels: snapshot.data,
            currentLabel: filterLabel,
            applyLabelFilter: (newFilterLabel) => setState(() {
              filterLabel = newFilterLabel;
            }),
          );
        },
      ),
    );
  }

  Widget buildTitle() {
    if (repository == null) return Text("Words");

    return Consumer<WordEntryRepository>(
      builder: (context, wordEntryRepository, child) =>
          FutureBuilder<List<WordEntry>>(
        future: wordEntryRepository.getWordEntries(label: filterLabel),
        builder:
            (BuildContext context, AsyncSnapshot<List<WordEntry>> snapshot) {
          if (!snapshot.hasData) return Text("Words");

          final wordsCount = snapshot.data.length;
          return Text("$wordsCount Words");
        },
      ),
    );
  }

  Widget _buildList() {
    if (repository == null || trainRepository == null) {
      return CircularProgressIndicator();
    }
    return Consumer<WordEntryRepository>(
      builder: (context, wordEntryRepository, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildReviewButton(),
            FutureBuilder<List<WordEntry>>(
              future: wordEntryRepository.getWordEntries(label: filterLabel),
              builder: (BuildContext context,
                  AsyncSnapshot<List<WordEntry>> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                var words = _filterAndSortWords(snapshot.data);
                return Expanded(child: WordList(words: words));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewButton() {
    return ChangeNotifierProvider(
      create: (context) => trainRepository,
      child: Consumer<TrainService>(
        builder: (context, trainRepository, child) =>
            FutureBuilder<List<WordEntry>>(
          future: trainRepository.getToReviewToday(filterLabel),
          builder:
              (BuildContext context, AsyncSnapshot<List<WordEntry>> snapshot) {
            if (snapshot.hasData) {
              return ReviewButton(wordsToReview: snapshot.data);
            }
            return ReviewButton(wordsToReview: []);
          },
        ),
      ),
    );
  }

  void _showSortingAndFilter(BuildContext context) {
    final selectedStyle = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(color: Theme.of(context).accentColor);
    final selectedOrNull =
        (value, option) => (value == option ? selectedStyle : null);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Sorting and Filtering'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  'Sort by word',
                  style: selectedOrNull(sorting, Sorting.byWord),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _changeSortState(Sorting.byWord);
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Sort by date',
                  style: selectedOrNull(sorting, Sorting.byDate),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _changeSortState(Sorting.byDate);
                },
              ),
              SimpleDialogOption(
                child: Text('Show not trained',
                    style: selectedOrNull(filtering, Filtering.unTrained)),
                onPressed: () {
                  Navigator.pop(context);
                  _changeFilterState(Filtering.unTrained);
                },
              ),
              SimpleDialogOption(
                child: Text('Show all',
                    style: selectedOrNull(filtering, Filtering.all)),
                onPressed: () {
                  Navigator.pop(context);
                  _changeFilterState(Filtering.all);
                },
              ),
            ],
          );
        });
  }

  void _changeSortState(final Sorting _sorting) {
    setState(() {
      sorting = _sorting;
    });
  }

  void _changeFilterState(final Filtering _filtering) {
    setState(() {
      filtering = _filtering;
    });
  }

  List<WordEntry> _filterAndSortWords(List<WordEntry> words) {
    final filtered = filtering == Filtering.unTrained
        ? words.where((element) => element.dueToLearnAfter == null).toList()
        : words;
    if (sorting == Sorting.byWord) {
      filtered.sort((left, right) => left.word.compareTo(right.word));
    } else {
      filtered
          .sort((left, right) => -left.createdAt.compareTo(right.createdAt));
    }
    return filtered;
  }
}

class CustomSearchDelegate extends SearchDelegate {
  WordEntryBloc blocSearch;

  final WordEntryRepository repository;
  final String label;

  CustomSearchDelegate(this.repository, this.label) {
    blocSearch = WordEntryBloc();
    if (repository != null) blocSearch.listenRepository(repository, label);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        blocSearch = WordEntryBloc();
        if (repository != null) blocSearch.listenRepository(repository, label);
        return blocSearch;
      },
      child: Consumer<WordEntryBloc>(
        builder: (context, blocSearch, child) {
          final filtered = filterWords(blocSearch._data);
          if (filtered.isEmpty) {
            return Center(child: Text('Nothing is found'));
          }
          return WordList(words: filtered);
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  List<WordEntry> filterWords(List<WordEntry> data) => data
      .where((element) =>
          element.word.contains(query) ||
          element.translation.contains(query) ||
          element.definition.contains(query))
      .toList();
}

class WordEntryBloc extends ChangeNotifier {
  List<WordEntry> _data = [];

  WordEntryRepository repository;

  listenRepository(WordEntryRepository repository, String label) async {
    this.repository = repository;
    _data = await this.repository.getWordEntries(label: label);
    notifyListeners();
    this.repository.editedWord.addListener(_editWord);
    this.repository.deletedWordId.addListener(_removeWord);
  }

  @override
  void dispose() {
    this.repository.editedWord.removeListener(_editWord);
    this.repository.deletedWordId.removeListener(_removeWord);
    super.dispose();
  }

  void _editWord() {
    final index = _data.indexWhere(
        (element) => element.id == this.repository.editedWord.value.id);
    _data.replaceRange(index, index, [this.repository.editedWord.value]);
    notifyListeners();
  }

  void _removeWord() {
    _data.removeWhere((i) => i.id == this.repository.deletedWordId.value);
    notifyListeners();
  }
}
