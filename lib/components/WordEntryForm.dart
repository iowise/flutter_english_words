import 'package:flutter/material.dart';
import 'package:word_trainer/models/tranlsatorsAndDictionaries/translatorsAndDictionaries.dart';
import '../models/WordEntryRepository.dart';
import '../components/TranslationTextInput.dart';
import 'LabelsInput.dart';
import 'WordContextTextFormField.dart';

class WordEntryForm extends StatefulWidget {
  final WordEntryInput entry;
  List<String> allLabels;

  WordEntryForm({Key key, this.entry, this.allLabels}) : super(key: key);

  @override
  _WordEntryFormState createState() => _WordEntryFormState(this.entry);
}

class _WordEntryFormState extends State<WordEntryForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController wordContextController;

  _WordEntryFormState(final WordEntryInput entry) {
    wordContextController = TextEditingController(text: entry.context);
  }

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
                  onChange: (value) {
                    widget.entry.translation = value;
                  },
                  getSuggestions: getTranslations,
                ),
                TranslationTextInput(
                  initialValue: widget.entry.definition,
                  word: widget.entry.word,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a definition...',
                    labelText: 'Definition',
                  ),
                  onChange: (value) {
                    widget.entry.definition = value;
                  },
                  getSuggestions: getDefinitions,
                ),
                WordContextTextFormField(
                  entry: widget.entry,
                  controller: wordContextController,
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
                TextFormField(
                  initialValue: widget.entry.antonyms,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a antonyms...',
                    labelText: 'Antonyms',
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.entry.antonyms = value;
                    });
                  },
                ),
                LabelsInput(
                  initialValue: widget.entry.labels,
                  onChange: (List<String> value) {
                    widget.entry.labels = value;
                  },
                  allLabels: widget.allLabels,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WordEntryInput extends WordContextInput {
  int id;
  String translation;
  String definition;
  String synonyms;
  String antonyms;
  List<String> labels;

  WordEntry arg;

  WordEntryInput({
    @required word,
    @required context,
    @required this.translation,
    @required this.definition,
    @required this.synonyms,
    @required this.antonyms,
    @required this.labels,
    this.arg,
  }) : super(word, context);

  toEntry() {
    if (arg != null) {
      return WordEntry.copy(
        arg,
        word: word.trim(),
        translation: translation.trim(),
        definition: definition.trim(),
        context: context.trim(),
        synonyms: synonyms.trim(),
        antonyms: antonyms.trim(),
        labels: labels,
      );
    }
    return WordEntry.create(
      word: word.trim(),
      translation: translation.trim(),
      definition: definition.trim(),
      context: context.trim(),
      synonyms: synonyms.trim(),
      antonyms: antonyms.trim(),
      labels: labels,
    );
  }

  static WordEntryInput fromWordEntry(WordEntry arg) {
    return WordEntryInput(
      word: arg.word,
      translation: arg.translation,
      definition: arg.definition,
      context: arg.context,
      synonyms: arg.synonyms,
      antonyms: arg.antonyms,
      labels: arg.labels,
      arg: arg,
    );
  }

  static WordEntryInput empty() {
    return WordEntryInput(
      word: "",
      translation: "",
      definition: "",
      context: "",
      synonyms: "",
      antonyms: "",
      labels: [],
    );
  }
}
