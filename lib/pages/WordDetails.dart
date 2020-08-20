import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/WordEntryRepository.dart';
import '../components/WordEntryForm.dart';

class WordDetails extends StatefulWidget {
  WordDetails({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WordDetailsState createState() => _WordDetailsState();
}

class _WordDetailsState extends State<WordDetails> {

  final WordEntryInput entryInput = WordEntryInput("", "");

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
        child: WordEntryForm(entry: entryInput),
      ),
    );
  }

  _onSave() async {
    await GetIt.I.get<WordEntryRepository>().insert(entryInput.toEntry());
    Navigator.pop(context);
  }
}
