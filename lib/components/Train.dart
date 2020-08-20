import 'package:flutter/material.dart';
import '../models/WordEntryRepository.dart';

class Train extends StatefulWidget {
  final WordEntry entry;
  final bool isCheck;
  final Function onSubmit;

  Train({Key key, this.entry, this.isCheck, this.onSubmit}) : super(key: key);

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
                    enteredWord: enteredWord, word: widget.entry.word)),
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
                    enabled: !widget.isCheck,
                    style: Theme.of(context).textTheme.headline5,
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

  const _TrainResult({Key key, this.word, this.enteredWord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final correct = word == enteredWord;
    return Card(
      color: correct ? Colors.green : Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: Text(correct ? "Correct" : "Wrong",
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
    );
  }
}
