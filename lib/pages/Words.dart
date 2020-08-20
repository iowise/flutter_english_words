import 'package:flutter/material.dart';
import 'package:flutter_app/models/WordEntryRepository.dart';
import 'package:get_it/get_it.dart';
import '../components/ReviewButton.dart';
import '../components/WordList.dart';

class WordsPage extends StatefulWidget {
  WordsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WordsPageState createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.I.allReady(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _build(context);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _build(BuildContext context) {
    return FutureBuilder(
      future: GetIt.I.get<WordEntryRepository>().getWordEntries(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var words = snapshot.data;
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
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ReviewButton(),
                Expanded(
                  child: WordList(words: words),
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
      },
    );
  }
}
