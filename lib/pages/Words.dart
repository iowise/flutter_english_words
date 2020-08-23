import 'package:flutter/material.dart';
import 'package:flutter_app/models/WordEntryRepository.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    GetIt.I.getAsync<WordEntryRepository>().then((value) {
      setState(() {
        repository = value;
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
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              repository.reset();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              print('search');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ReviewButton(),
            Expanded(
              child: _buildList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a word',
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/word/create'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildList() {
    if (repository == null) {
      return CircularProgressIndicator();
    }
    return ChangeNotifierProvider(
      create: (context) => repository,
      child: Consumer<WordEntryRepository>(
        builder: (context, wordEntryRepository, child) {
          return FutureBuilder(
            future: wordEntryRepository.getWordEntries(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              var words = snapshot.data;
              return WordList(words: words);
            },
          );
        },
      ),
    );
  }
}
