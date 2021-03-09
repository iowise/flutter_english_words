import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../models/tranlsatorsAndDictionaries/translatorsAndDictionaries.dart';

class TranslationTextInput extends StatelessWidget {
  TranslationTextInput({
    Key? key,
    required this.word,
    required this.decoration,
    required this.initialValue,
    required this.onChange,
    required this.getSuggestions
  }) : _typeAheadController = TextEditingController(text: initialValue), super(key: key) {
    _typeAheadController.addListener(() {
      this.onChange(_typeAheadController.text);
    });
  }

  final ValueChanged<String> onChange;
  final String word;
  final String initialValue;
  final InputDecoration decoration;
  final Future<List<DictionaryItem>> Function(String text) getSuggestions;
  TextEditingController _typeAheadController;

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<DictionaryItem>(
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
      suggestionsCallback: (_pattern) => getSuggestions(word),
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

  concatenateTranslation(String value) {
    final doesTextHaveTranslation = this._typeAheadController.text.isNotEmpty;
    this._typeAheadController.text = doesTextHaveTranslation
        ? "${this._typeAheadController.text}; $value"
        : value;
  }
}
