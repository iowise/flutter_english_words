import 'package:flutter/foundation.dart';

import '../repositories/WordEntryRepository.dart';

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
  String locale;
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
    required this.locale,
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
        locale: locale,
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
      locale: locale,
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
      locale: arg.locale,
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
      locale: DEFAULT_LOCALE,
      // Add implicit locale from label based on the other words inside label
      labels: defaultLabel == null ? [] : [defaultLabel],
    );
  }
}
