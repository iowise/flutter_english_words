import 'package:flutter/material.dart';
import '../components/WordEntryForm.dart';

class WordDetails extends StatefulWidget {
  WordDetails({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WordDetailsState createState() => _WordDetailsState();
}

class _WordDetailsState extends State<WordDetails> {

  final WordEntryInput entry = WordEntryInput("", "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: this._onSave,
          ),
        ],
      ),
      body: Center(
        child: WordEntryForm(entry: entry),
      ),
    );
  }

  _onSave() {
    print(entry.word);
  }
}
