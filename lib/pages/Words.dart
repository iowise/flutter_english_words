import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../components/Drawer.dart';
import '../models/SpaceRepetitionScheduler.dart';
import '../models/WordEntryRepository.dart';
import '../components/ReviewButton.dart';
import '../components/WordList.dart';

class WordsPage extends StatefulWidget {
  WordsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WordsPageState createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  WordEntryRepository repository;
  TrainService trainRepository;

  @override
  void initState() {
    super.initState();
    GetIt.I.allReady().then((value) {
      setState(() {
        repository = GetIt.I.get<WordEntryRepository>();
        trainRepository = GetIt.I.get<TrainService>();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(this.repository),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Center(
        child: _buildList(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a word',
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/word/create'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildList() {
    if (repository == null || trainRepository == null) {
      return CircularProgressIndicator();
    }
    return ChangeNotifierProvider(
      create: (context) => repository,
      child: Consumer<WordEntryRepository>(
        builder: (context, wordEntryRepository, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildReviewButton(),
              FutureBuilder(
                future: wordEntryRepository.getWordEntries(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  var words = snapshot.data;
                  return Expanded(child: WordList(words: words));
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewButton() {
    return ChangeNotifierProvider(
      create: (context) => trainRepository,
      child: Consumer<TrainService>(
        builder: (context, trainRepository, child) {
          return FutureBuilder(
            future: trainRepository.getToReviewToday(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ReviewButton(wordsToReview: snapshot.data);
              }
              return ReviewButton(wordsToReview: []);
            },
          );
        },
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  WordEntryBloc blocSearch;

  final WordEntryRepository repository;

  CustomSearchDelegate(this.repository) {
    blocSearch = WordEntryBloc();
    if (repository != null) blocSearch.listenRepository(repository);
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
        if (repository != null) blocSearch.listenRepository(repository);
        return blocSearch;
      },
      child: Consumer<WordEntryBloc>(
        builder: (context, blocSearch, child) {
          final List data = blocSearch._data;
          final filtered =
              data.where((element) => element.word.contains(query)).toList();
          if (filtered.isEmpty) {
            return Center(child: Text('Nothing is {found'));
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
}

class WordEntryBloc extends ChangeNotifier {
  List<WordEntry> _data = [];

  WordEntryRepository repository;

  listenRepository(repository) async {
    this.repository = repository;
    _data = await this.repository.getWordEntries();
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
