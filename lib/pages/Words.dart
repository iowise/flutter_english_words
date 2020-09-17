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
      setState(() {});
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
              print('search');
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
              return ReviewButton();
            },
          );
        },
      ),
    );
  }
}
