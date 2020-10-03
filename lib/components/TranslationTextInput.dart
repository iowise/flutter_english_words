import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/tranlsatorsAndDictionaries/reverso.dart';

class TranslationTextInput extends StatelessWidget {
  TranslationTextInput({
    Key key,
    @required this.word,
    @required this.decoration,
    @required this.initialValue,
    @required this.onChange,
  }) : super(key: key) {
    _typeAheadController = TextEditingController(text: initialValue);
    _typeAheadController.addListener(() {
      this.onChange(_typeAheadController.text);
    });
  }

  final ValueChanged<String> onChange;
  final String word;
  final String initialValue;
  final InputDecoration decoration;
  TextEditingController _typeAheadController;

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._typeAheadController,
        decoration: this.decoration.copyWith(
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              onClear();
            },
          ),
        ),
      ),
      suggestionsCallback: (_pattern) => _suggestions(word),
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(suggestion.icon),
          title: Text(suggestion.text),
        );
      },
      onSaved: (value) {
        concatenateTranslation(value);
      },
      onSuggestionSelected: (suggestion) {
        concatenateTranslation(suggestion.text);
      },
    );
  }

  void onClear() {
    this._typeAheadController.text = '';
  }

  String concatenateTranslation(String value) {
    final doesTextHaveTranslation = this._typeAheadController.text.isNotEmpty;
    this._typeAheadController.text = doesTextHaveTranslation
        ? "${this._typeAheadController.text}; $value"
        : value;
  }
}

class DictionaryItem {
  final String text;
  final IconData icon;

  DictionaryItem(this.text, this.icon);
}

Future<List<DictionaryItem>> _suggestions(String text) async {
  if (text.isEmpty) {
    return [];
  }
  final russianTranslation = await text.translate(from: 'en', to: 'ru');
  return [
    DictionaryItem(russianTranslation.text, Icons.translate),
    ...[
      for (final i in await reversoTranslation(text))
        DictionaryItem(i, Icons.sync),
    ],
  ];
}
