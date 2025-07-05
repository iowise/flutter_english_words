import 'package:flutter/material.dart';
import 'package:word_trainer/models/tranlsatorsAndDictionaries/MerriamWebster.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../repositories/WordEntryRepository.dart';
import './reverso.dart';
import './googleTranslation.dart';

class DictionaryItem {
  final String text;
  final IconData icon;

  DictionaryItem(this.text, this.icon);
}

Future<List<DictionaryItem>> getTranslations(String text) async {
  if (text.isEmpty) {
    return [];
  }
  return [
    DictionaryItem(await getGoogleTranslation(text), Icons.translate),
    ...[
      for (final i in await reversoTranslation(text))
        DictionaryItem(i, Icons.sync),
    ],
  ];
}

abstract class WordContextInput {
  String word;
  String context;

  WordContextInput(this.word, this.context);
}

class WordEntryInput extends WordContextInput {
  int? id;
  String translation;
  String definition;
  String synonyms;
  String antonyms;
  List<String> labels;

  WordEntry? arg;

  WordEntryInput({
    @required word,
    @required context,
    required this.translation,
    required this.definition,
    required this.synonyms,
    required this.antonyms,
    required this.labels,
    this.arg,
  }) : super(word, context);

  toEntry() {
    if (arg != null) {
      return WordEntry.copy(
        arg!,
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

  static WordEntryInput empty({String? defaultLabel}) {
    return WordEntryInput(
      word: "",
      translation: "",
      definition: "",
      context: "",
      synonyms: "",
      antonyms: "",
      labels: defaultLabel == null ? [] : [defaultLabel],
    );
  }
}

Future<void> openAIOverFirebaseFunction({
  required final WordEntryInput entry,
  required void Function(WordEntryInput newEntry) onUpdateEntry
}) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'word_to_training_entry',
    options: HttpsCallableOptions(
      timeout: const Duration(minutes: 2),
    ),
  );
  try {
    final result = await callable({ 'word': entry.word });
    final response = result.data as Map<String, dynamic>;

    final newEntry = WordEntryInput(
      word: entry.word,
      context: response['example'] as String,
      translation: List<String>.from(response['translation']).join('; '),
      definition: response['definition'] as String,
      synonyms: List<String>.from(response['synonyms']).join('; '),
      antonyms: List<String>.from(response['antonyms']).join('; '),
      labels: entry.labels,
    );
    onUpdateEntry(newEntry);
  } on FirebaseFunctionsException catch (e) {
    print(e.message);
  }
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
