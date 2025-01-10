import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../components/TrainCard.dart';
import '../models/repositories/WordEntryRepository.dart';

class EnterSentenceTrainPage extends StatefulWidget {
  @override
  _EnterSentenceTrainPageState createState() => _EnterSentenceTrainPageState();
}

class _EnterSentenceTrainPageState extends State<EnterSentenceTrainPage> {
  bool isCheck = false;
  var trainIndex = 0;
  late List<WordEntry>? wordsToLearn;
  late TextEditingController sentenceController = TextEditingController();

  _EnterSentenceTrainPageState();

  @override
  void initState() {
    super.initState();
    isCheck = false;
    GetIt.I.allReady().then((value) async {
      final repository = GetIt.I.get<WordEntryRepository>();
      final words = await repository.getWordEntries();
      words.shuffle();
      setState(() {
        wordsToLearn = words.getRange(0, min(10, words.length)).toList();
      });
    });
  }

  _checkTheWord() async {
    if (isCheck && wordsToLearn != null) {
      var isEnd = trainIndex >= wordsToLearn!.length - 1;
      if (isEnd) {
        Navigator.pop(context);
        return;
      }
      setState(() {
        isCheck = false;
        trainIndex += 1;
        sentenceController = TextEditingController();
      });
    } else {
      setState(() {
        isCheck = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter a Sentence"),
      ),
      body: Center(
          child: wordsToLearn == null
              ? CircularProgressIndicator()
              : buildTraining()),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Check',
        child: Icon(isCheck ? Icons.chevron_right : Icons.check),
        onPressed: _checkTheWord,
      ),
    );
  }

  Widget buildTraining() {
    return TrainSentence(
      word: wordsToLearn![trainIndex],
      isCheck: isCheck,
      onSubmit: _checkTheWord,
      sentenceController: sentenceController,
    );
  }
}

class TrainSentence extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final WordEntry word;
  final bool isCheck;
  final Function onSubmit;

  final TextEditingController sentenceController;

  TrainSentence({
    Key? key,
    required this.word,
    required this.isCheck,
    required this.onSubmit,
    required this.sentenceController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TrainCard(entry: word, text: word.word),
          TextFormField(
            autofocus: true,
            textAlign: TextAlign.center,
            maxLines: null,
            controller: sentenceController,
            readOnly: isCheck,
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: InputDecoration(
              filled: true,
              hintText: isCheck ? "" : 'Enter a sentence...',
            ),
            onFieldSubmitted: (_) {
              onSubmit();
            },
          ),
        ],
      ),
    );
  }
}
