import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/WordEntryRepository.dart';
import '../components/WordEntryForm.dart';


class WordDetails extends StatelessWidget {
  WordDetails({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final WordEntry arg = ModalRoute.of(context).settings.arguments;
    var entryInput = WordEntryInput("", "");
    if (arg != null) {
      entryInput = WordEntryInput.fromWordEntry(arg);
    }
    return WordCreateOrEdit(title: title, entryInput: entryInput);
  }
}

class WordCreateOrEdit extends StatefulWidget {
  WordCreateOrEdit({Key key, this.title, this.entryInput}) : super(key: key);

  final String title;
  final WordEntryInput entryInput;

  @override
  _WordCreateOrEditState createState() => _WordCreateOrEditState();
}

class _WordCreateOrEditState extends State<WordCreateOrEdit> {

  WordEntryInput entryInput;

  @override
  void initState() {
    entryInput = widget.entryInput;
    super.initState();
  }

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
    await GetIt.I.get<WordEntryRepository>().save(entryInput.toEntry());
    Navigator.pop(context);
  }
}
