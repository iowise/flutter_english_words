import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../models/TrainLogRepository.dart';
import '../models/WordEntryRepository.dart';
import '../components/WordEntryForm.dart';

class WordDetails extends StatelessWidget {
  WordDetails({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final WordEntry arg = ModalRoute.of(context).settings.arguments;
    var entryInput = WordEntryInput.empty();
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
    final TrainLogRepository trainLog = GetIt.I.get<TrainLogRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: entryInput.arg == null
            ? []
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _onDelete,
                ),
              ],
      ),
      body: buildBody(trainLog),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Save',
        child: Icon(Icons.save),
        onPressed: _onSave,
      ),
    );
  }

  Widget buildBody(TrainLogRepository trainLog) {
    if (entryInput.arg == null) {
      return ListView(
        children: <Widget>[
          WordEntryForm(entry: entryInput),
        ],
      );
    }
    return FutureBuilder(
      future: trainLog.getLogs(entryInput.arg.id),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        List details;
        if (entryInput.arg?.dueToLearnAfter == null) {
          details = [];
        } else {
          details = [
            buildWordDetails(context, trainLog),
            ...buildTrainLogs(snapshot),
          ];
        }
        return ListView(
          children: <Widget>[
            WordEntryForm(entry: entryInput),
            ...details,
          ],
        );
      },
    );
  }

  Widget buildWordDetails(BuildContext context, TrainLogRepository trainLog) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final nextTrainDate = formatter.format(entryInput.arg.dueToLearnAfter);
    return ListTile(
      title: Text("Next train on: $nextTrainDate",
          style: Theme.of(context).textTheme.bodyText1),
    );
  }

  List<Widget> buildTrainLogs(AsyncSnapshot<List<TrainLog>> snapshot) {
    final DateFormat formatterWithTime = DateFormat('yyyy-MM-dd H:m');
    if (snapshot.hasData) {
      final logs = snapshot.data;
      return logs
          .map(
            (e) => ListTile(
              title: Text("${formatterWithTime.format(e.trainedAt)} ${e.score}",
                  style: Theme.of(context).textTheme.bodyText2),
            ),
          )
          .toList();
    }
    return [Center(child: CircularProgressIndicator())];
  }

  _onSave() async {
    await GetIt.I.get<WordEntryRepository>().save(entryInput.toEntry());
    Navigator.pop(context);
  }

  _onDelete() async {
    final wordId = entryInput.arg.id;
    await GetIt.I.get<TrainLogRepository>().deleteLogsForWord(wordId);
    await GetIt.I.get<WordEntryRepository>().delete(wordId);
    Navigator.of(context).pop();
  }
}
