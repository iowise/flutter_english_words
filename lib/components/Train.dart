import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/WordEntryRepository.dart';

typedef ResultCallback = void Function();

class TrainController extends TextEditingController {
  final WordEntry entry;

  TrainController(this.entry);

  bool get isCorrect => _clean(entry.word) == _clean(text);

  _clean(final str) => str.trim().toLowerCase();
}

class Train extends StatefulWidget {
  final WordEntry entry;
  final bool isCheck;
  final ResultCallback onSubmit;
  final TrainController enteredWordController;

  Train(
      {Key key,
      this.entry,
      this.isCheck,
      this.onSubmit,
      this.enteredWordController})
      : super(key: key);

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
            _TrainResult(
              enteredWord: enteredWord,
              word: widget.entry.word,
              isCorrect: widget.enteredWordController.isCorrect,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(widget.entry.context,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .apply(fontStyle: FontStyle.italic)),
            ),
          ]
        : [];
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                widget.entry.translation,
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
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
          ...results,
        ],
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
    return Card(
      color: isCorrect ? Colors.green : Colors.red,
      child: InkWell(
        onTap: () => _speak(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  isCorrect ? "Correct" : "Wrong",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.white),
                ),
                Text(
                  word,
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _speak() async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.speak(word);
  }
}
