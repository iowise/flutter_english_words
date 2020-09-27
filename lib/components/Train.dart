import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/WordEntryRepository.dart';

typedef ResultCallback = void Function();

class TrainController extends TextEditingController {
  final WordEntry entry;
  int attempt = 0;

  TrainController(this.entry);

  bool get isCorrect => _clean(entry.word) == _clean(text);

  newAttempt() {
    attempt += 1;
  }

  _clean(final str) => str.trim().toLowerCase();
}

class Train extends StatefulWidget {
  final WordEntry entry;
  final bool isCheck;
  final ResultCallback onSubmit;
  final TrainController enteredWordController;

  Train({
    Key key,
    @required this.entry,
    @required this.isCheck,
    @required this.onSubmit,
    @required this.enteredWordController,
  }) : super(key: key);

  @override
  _TrainState createState() => _TrainState();
}

class _TrainState extends State<Train> {
  final _formKey = GlobalKey<FormState>();

  String enteredWord;

  @override
  Widget build(BuildContext context) {
    final results = widget.isCheck || widget.enteredWordController.attempt > 0
        ? [
            _TrainResult(
              enteredWord: enteredWord,
              word: widget.entry.word,
              isCorrect: widget.enteredWordController.isCorrect,
              attempt: widget.enteredWordController.attempt,
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: MarkdownBody(
                shrinkWrap: false,
                data: widget.entry.context,
              ),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    widget.entry.translation,
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                  ...(buildSynonyms(context)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextFormField(
              autofocus: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              enableSuggestions: false,
              readOnly: widget.isCheck,
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

  List<Widget> buildSynonyms(BuildContext context) {
    return widget.entry.synonyms.isNotEmpty
        ? [
            Text(
              widget.entry.synonyms,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            )
          ]
        : [];
  }
}

class _TrainResult extends StatelessWidget {
  final String word;
  final String enteredWord;
  final bool isCorrect;
  final int attempt;

  const _TrainResult({
    Key key,
    @required this.word,
    @required this.enteredWord,
    @required this.isCorrect,
    @required this.attempt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCorrect ? Colors.green : Colors.amber[900],
      child: InkWell(
        onTap: () => speak(word),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  buildFeedbackText(),
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

  String buildFeedbackText() {
    if (isCorrect) {
      return "Awesome! 🚀";
    } else {
      if (attempt == 1) return "Try again! 😸";
      return "Until the next time 😉";
    }
  }
}

Future speak(word) async {
  FlutterTts flutterTts = FlutterTts();
  await flutterTts.speak(word);
}
