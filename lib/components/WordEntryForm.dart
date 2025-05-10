import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:openai_dart/openai_dart.dart';
import '../models/tranlsatorsAndDictionaries/translatorsAndDictionaries.dart';
import '../components/TranslationTextInput.dart';
import './LabelsInput.dart';
import './WordContextTextFormField.dart';

class WordEntryForm extends StatefulWidget {
  final WordEntryInput entry;
  final List<String> allLabels;

  WordEntryForm({
    Key? key,
    required this.entry,
    required this.allLabels,
  }) : super(key: key);

  @override
  _WordEntryFormState createState() => _WordEntryFormState(this.entry);
}

class _WordEntryFormState extends State<WordEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController wordContextController;
  final TextEditingController wordSynonymsController;
  final TextEditingController wordAntonymsController;

  _WordEntryFormState(final WordEntryInput entry)
      : wordContextController = TextEditingController(text: entry.context),
        wordSynonymsController = TextEditingController(text: entry.synonyms),
        wordAntonymsController = TextEditingController(text: entry.antonyms)
  ;

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
                    suffixIcon: IconButton(
                      icon: Icon(Icons.rocket_launch),
                      onPressed: () => callOpenAI(),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.entry.word = value.breakSpaces;
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
                    widget.entry.translation = value.breakSpaces;
                  },
                  onSelectSuggestion: (value) {
                    setState(() {
                      widget.entry.translation = value.breakSpaces;
                    });
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
                    widget.entry.definition = value.breakSpaces;
                  },
                  onSelectSuggestion: (value) {
                    setState(() {
                      widget.entry.definition = value.breakSpaces;
                    });
                  },
                  getSuggestions: getDefinitions,
                ),
                WordContextTextFormField(
                  entry: widget.entry,
                  controller: wordContextController,
                  onChanged: (value) {
                    setState(() {
                      widget.entry.context = value.breakSpaces;
                      wordContextController.breakSpacesWhenNeeded(value);
                    });
                  },
                ),
                TextFormField(
                  controller: wordSynonymsController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a synonyms...',
                    labelText: 'Synonyms',
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.entry.synonyms = value.breakSpaces;
                    });
                  },
                ),
                TextFormField(
                  controller: wordAntonymsController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a antonyms...',
                    labelText: 'Antonyms',
                  ),
                  onChanged: (value) {
                    setState(() {
                      widget.entry.antonyms = value.breakSpaces;
                    });
                  },
                ),
                LabelsInput.fromStrings(
                  initialValue: widget.entry.labels,
                  onChange: (List<String> value) {
                    setState(() {
                      widget.entry.labels = value;
                    });
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

  callOpenAI() {
    openAIWordEntry(
      entry: widget.entry,
      client: GetIt.I.get<OpenAIClient>(),
      onUpdateEntry: (newEntry) {
        setState(() {
          if (widget.entry.translation.isEmpty) {
            widget.entry.translation = newEntry.translation;
          }
          if (widget.entry.definition.isEmpty) {
            widget.entry.definition = newEntry.definition;
          }

          if (widget.entry.context.isEmpty) {
            wordContextController.breakSpacesWhenNeeded(newEntry.context);
            wordContextController.text = newEntry.context;
            widget.entry.context = newEntry.context;
          }

          if (widget.entry.synonyms.isEmpty) {
            wordSynonymsController.breakSpacesWhenNeeded(newEntry.synonyms);
            wordSynonymsController.text = newEntry.synonyms;
            widget.entry.synonyms = newEntry.synonyms;
          }

          if (widget.entry.antonyms.isEmpty) {
            wordAntonymsController.breakSpacesWhenNeeded(newEntry.antonyms);
            wordAntonymsController.text = newEntry.antonyms;
            widget.entry.antonyms = newEntry.antonyms;
          }
        });
      },
    );
  }
}

const $nbsp = 0x00A0;
var nonBreakSpace = String.fromCharCode($nbsp);

extension StringExtension on String {
  String get breakSpaces => replaceAll(nonBreakSpace, ' ');
}

extension BreakSpacesTextEditingController on TextEditingController {
  breakSpacesWhenNeeded(String newText) {
    if (newText.contains(nonBreakSpace)) {
      value = value.copyWith(text: newText.breakSpaces);
    }
  }
}
