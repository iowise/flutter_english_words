import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:word_trainer/models/blocs/LabelCubit.dart';
import '../l10n/app_localizations.dart';
import '../models/tranlsatorsAndDictionaries/aiEnrichment.dart';
import '../models/tranlsatorsAndDictionaries/input.dart';
import '../models/tranlsatorsAndDictionaries/translatorsAndDictionaries.dart';
import '../components/TranslationTextInput.dart';
import './LabelsInput.dart';
import './WordContextTextFormField.dart';

class WordEntryForm extends StatefulWidget {
  final WordEntryInput entry;
  final List<String> allLabels;

  WordEntryForm({
    super.key,
    required this.entry,
    required this.allLabels,
  });

  @override
  _WordEntryFormState createState() => _WordEntryFormState(this.entry);
}

class _WordEntryFormState extends State<WordEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController wordController;
  final TextEditingController wordContextController;
  final TextEditingController wordSynonymsController;
  final TextEditingController wordAntonymsController;

  _WordEntryFormState(final WordEntryInput entry)
      : wordController = TextEditingController(text: entry.word),
        wordContextController = TextEditingController(text: entry.context),
        wordSynonymsController = TextEditingController(text: entry.synonyms),
        wordAntonymsController = TextEditingController(text: entry.antonyms);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
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
                  controller: wordController,
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: localization.editEnterWordHint,
                    labelText: localization.editEnterWordLabel,
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
                    hintText: localization.editEnterTranslationHint,
                    labelText: localization.editEnterTranslationLabel,
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
                    hintText: localization.editEnterDefinitionHint,
                    labelText: localization.editEnterDefinitionLabel,
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
                    });
                  },
                  onForceSet: (value) {
                    wordContextController.breakSpacesWhenNeeded(value);
                  },
                ),
                TextFormField(
                  controller: wordSynonymsController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: localization.editEnterSynonymsHint,
                    labelText: localization.editEnterSynonymsLabel,
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
                    hintText: localization.editEnterAntonymsHint,
                    labelText: localization.editEnterAntonymsLabel,
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
                      final labelLocale = GetIt.I
                          .get<LabelEntryCubit>()
                          .state.guessLocale(value);
                      if (labelLocale != null) {
                        widget.entry.locale = labelLocale;
                      }
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

  callOpenAI() async {
    openAIOverFirebaseFunction(
      entry: widget.entry,
      language: findLanguage(widget.entry.locale),
      onUpdateEntry: (newEntry) {
        setState(() {
          widget.entry.locale = newEntry.locale;
          if (widget.entry.word.isEmpty) {
            wordController.breakSpacesWhenNeeded(newEntry.word);
            widget.entry.word = newEntry.word;
          }
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
            widget.entry.synonyms = newEntry.synonyms;
          }

          if (widget.entry.antonyms.isEmpty) {
            wordAntonymsController.breakSpacesWhenNeeded(newEntry.antonyms);
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
    } else {
      value = value.copyWith(text: newText);
    }
    text = value.text;
  }
}
