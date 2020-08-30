import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/WordEntryRepository.dart';

typedef ResultCallback = void Function();

class TrainController extends TextEditingController {

  final WordEntry entry;

  TrainController(this.entry);
  bool get isCorrect => entry.word == text;
}

class Train extends StatefulWidget {
  final WordEntry entry;
  final bool isCheck;
  final ResultCallback onSubmit;
  final TrainController enteredWordController;

  Train({Key key, this.entry, this.isCheck, this.onSubmit, this.enteredWordController}) : super(key: key);

  @override
  _TrainState createState() => _TrainState();
}

class _TrainState extends State<Train> {
  final _formKey = GlobalKey<FormState>();

  String enteredWord;

  @override
  Widget build(BuildContext context) {
    final results = widget.isCheck
        ? [
            Flexible(
              flex: 1,
              child: _TrainResult(
                enteredWord: enteredWord,
                word: widget.entry.word,
                isCorrect: widget.enteredWordController.isCorrect,
              ),
            ),
          ]
        : [];
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(widget.entry.translation,
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.visiblePassword,
                    enableSuggestions: false,
                    enabled: !widget.isCheck,
                    style: Theme.of(context).textTheme.headline5,
                    controller: widget.enteredWordController,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: widget.isCheck ? "" : 'Enter a word...',
                    ),
                    onFieldSubmitted: (_) {
                      widget.onSubmit();
                    },
                    onChanged: (value) {
                      enteredWord = value;
                    },
                  ),
                ),
              ),
              ...results,
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainResult extends StatelessWidget {
  final String word;
  final String enteredWord;
  final bool isCorrect;

  const _TrainResult({Key key, this.word, this.enteredWord, this.isCorrect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _speak(),
      child: Card(
        color: isCorrect ? Colors.green : Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    child: Text(isCorrect ? "Correct" : "Wrong",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(color: Colors.white))),
                Flexible(
                    child: Text(word,
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: Colors.white))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _speak() async {
    FlutterTts flutterTts = FlutterTts();
    var result = await flutterTts.speak(word);
  }
}
