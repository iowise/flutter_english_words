import 'package:flutter/material.dart';
import '../components/ReviewButton.dart';
import '../components/WordList.dart';
import '../components/WordEntryForm.dart';

class WordsPage extends StatefulWidget {
  WordsPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _WordsPageState createState() => _WordsPageState();
}

class _WordsPageState extends State<WordsPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
          child:
          Column(
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
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
