import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TranslationTextInput extends StatelessWidget {

  TranslationTextInput({
    Key key,
    this.onChanged,
    this.word,
    this.decoration,
  }) : super(key: key);

  final ValueChanged<String> onChanged;
  final String word;
  final InputDecoration decoration;
  final TextEditingController _typeAheadController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._typeAheadController,
        decoration: this.decoration,
      ),
      suggestionsCallback: (_pattern) => _suggestions(word),
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(suggestion.icon),
          title: Text(suggestion.text),
        );
      },
      onSaved: (value) {
        this.onChanged(value);
      },
      onSuggestionSelected: (suggestion) {
        this._typeAheadController.text = suggestion.text;
        this.onChanged(suggestion.text);

//        Navigator.of(context).push(MaterialPageRoute(
//            builder: (context) => ProductPage(product: suggestion)
//        ));
      },
    )
    ;
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
  final russianTranslation = await text.translate(to: 'ru');
  return [
    DictionaryItem(russianTranslation.text, Icons.translate),
  ];
}