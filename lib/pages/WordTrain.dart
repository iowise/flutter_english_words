import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/WordEntryRepository.dart';
import '../models/SpaceRepetitionScheduler.dart';
import '../components/Train.dart';

class TrainPage extends StatelessWidget {
  TrainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final List<WordEntry> arg = ModalRoute
        .of(context)
        .settings
        .arguments;
    return TrainWords(title: title, wordsToLearn: arg);
  }
}

class TrainWords extends StatefulWidget {
  TrainWords({Key key, this.title, this.wordsToLearn}) : super(key: key);

  final String title;
  final List<WordEntry> wordsToLearn;

  @override
  _TrainWordsState createState() => _TrainWordsState();
}

class _TrainWordsState extends State<TrainWords> {
  bool isCheck = false;
  var trainIndex = 0;

  initState() {
    isCheck = false;
    trainIndex = 0;
    super.initState();
  }

  _checkTheWord([bool isCorrect = false]) {
    if (isCheck) {
      var isEnd = trainIndex >= widget.wordsToLearn.length - 1;
      if (isEnd) {
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        isCheck = false;
        trainIndex += 1;
      });
    } else {
      setState(() {
        isCheck = true;
        final trainService = GetIt.I.get<TrainService>();
        trainService.trainWord(wordToTrain, isCorrect);
      });
    }
  }

  WordEntry get wordToTrain => widget.wordsToLearn[trainIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Train(
            key: ObjectKey(wordToTrain),
            entry: wordToTrain,
            isCheck: isCheck,
            onSubmit: _checkTheWord,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Check',
        child: Icon(isCheck ? Icons.chevron_right : Icons.check),
        onPressed: _checkTheWord,
      ),
    );
  }
}