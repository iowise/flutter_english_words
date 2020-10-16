import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:translator/translator.dart';
import 'package:word_trainer/models/tranlsatorsAndDictionaries/MerriamWebster.dart';
import './reverso.dart';

class DictionaryItem {
  final String text;
  final IconData icon;

  DictionaryItem(this.text, this.icon);
}

Future<List<DictionaryItem>> getTranslations(String text) async {
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

Future<List<DictionaryItem>> getDefinitions(String text) async {
  if (text.isEmpty) {
    return [];
  }
  return [
    for (final i in await merriamWebsterDefinitions(text))
      DictionaryItem(i, Icons.supervised_user_circle),
  ];
}
