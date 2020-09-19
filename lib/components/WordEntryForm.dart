import 'package:flutter/material.dart';
import '../models/WordEntryRepository.dart';
import '../components/TranslationTextInput.dart';

class WordEntryForm extends StatefulWidget {
  final WordEntryInput entry;

  WordEntryForm({Key key, this.entry}) : super(key: key);

  @override
  _WordEntryFormState createState() => _WordEntryFormState();
}

class _WordEntryFormState extends State<WordEntryForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  initialValue: widget.entry.word,
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a word...',
                    labelText: 'Word',
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.entry.word = value;
                    });
                  },
                ),
                TranslationTextInput(
                  initialValue: widget.entry.translation,
                  word: widget.entry.word,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a translation...',
                    labelText: 'Translation',
                  ),
                  onChanged: (value) {
                    widget.entry.translation = value;
                  },
                ),
                TextFormField(
                  initialValue: widget.entry.context,
                  maxLines: null,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a context...',
                    labelText: 'Context',
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.entry.context = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: widget.entry.synonyms,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a synonyms...',
                    labelText: 'Synonyms',
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.entry.synonyms = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WordEntryInput {
  int id;
  String word;
  String translation;
  String context;
  String synonyms;
  WordEntry arg;

  WordEntryInput({
    this.word,
    this.translation,
    this.context,
    this.synonyms,
    this.arg,
  });

  toEntry() {
    if (arg != null) {
      return WordEntry.copy(
        arg,
        word: word.trim(),
        translation: translation.trim(),
        context: context.trim(),
        synonyms: synonyms.trim(),
      );
    }
    return WordEntry.create(
      word: word.trim(),
      translation: translation.trim(),
      context: context.trim(),
      synonyms: synonyms.trim(),
    );
  }

  static WordEntryInput fromWordEntry(WordEntry arg) {
    return WordEntryInput(
      word: arg.word,
      translation: arg.translation,
      context: arg.context,
      synonyms: arg.synonyms,
      arg: arg,
    );
  }

  static WordEntryInput empty() {
    return WordEntryInput(word: "", translation: "", context: "", synonyms: "");
  }
}
