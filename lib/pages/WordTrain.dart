import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../models/repositories/WordEntryRepository.dart';
import '../models/SpaceRepetitionScheduler.dart';
import '../components/Train.dart';

enum HintTypes {
  definition,
  translation,
}

class TrainPage extends StatelessWidget {
  TrainPage({Key? key, required this.title, required this.hintType})
      : super(key: key);

  final String title;
  final HintTypes hintType;

  @override
  Widget build(BuildContext context) {
    final Object? argObj = ModalRoute.of(context)!.settings.arguments;
    final List<WordEntry> arg = argObj as List<WordEntry>;
    return TrainWords(title: title, wordsToLearn: arg, hintType: hintType);
  }
}

class TrainWords extends StatefulWidget {
  TrainWords({
    Key? key,
    required this.title,
    required this.wordsToLearn,
    required this.hintType,
  }) : super(key: key);

  final String title;
  final HintTypes hintType;
  final List<WordEntry> wordsToLearn;

  @override
  _TrainWordsState createState() => _TrainWordsState();
}

const MAX_ATTEMPTS = 1;

class _TrainWordsState extends State<TrainWords> {
  bool isCheck = false;
  var trainIndex = 0;
  late TrainController trainController;

  initState() {
    isCheck = false;
    trainIndex = 0;
    trainController = createTrainController();
    super.initState();
  }

  TrainController createTrainController() =>
      TrainController(widget.wordsToLearn[trainIndex]);

  _checkTheWord() async {
    if (isCheck) {
      var isEnd = trainIndex >= widget.wordsToLearn.length - 1;
      if (isEnd) {
        Navigator.pop(context);
        return;
      }
      setState(() {
        isCheck = false;
        trainIndex += 1;
        trainController = createTrainController();
      });
    } else {
      if (!trainController.isCorrect &&
          trainController.attempt < MAX_ATTEMPTS) {
        setState(() {
          trainController.newAttempt();
        });
        return;
      }
      final trainService = GetIt.I.get<TrainService>();
      trainService.trainWord(
          wordToTrain, trainController.isCorrect, trainController.attempt);
      speak(wordToTrain.word);
      setState(() {
        isCheck = true;
      });
    }
  }

  WordEntry get wordToTrain => widget.wordsToLearn[trainIndex];

  @override
  Widget build(BuildContext context) {
    final trainingHint = widget.hintType == HintTypes.definition
        ? _getDefinition
        : _getTranslation;

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
            enteredWordController: trainController,
            getInputForTraining: trainingHint,
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

String _getDefinition(WordEntry entry) => entry.definition;
String _getTranslation(WordEntry entry) => entry.translation;
