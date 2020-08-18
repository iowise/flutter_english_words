import 'package:flutter/material.dart';
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
    var words = [
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
      WordEntry("go", "идти"),
    ];
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
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
        )
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a word',
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/word/create'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
