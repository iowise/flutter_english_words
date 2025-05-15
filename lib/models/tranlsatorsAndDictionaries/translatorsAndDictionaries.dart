import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:word_trainer/models/tranlsatorsAndDictionaries/MerriamWebster.dart';
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

Future<void> openAIWordEntry({
  required final WordEntryInput entry,
  required final OpenAIClient client,
  required void Function(WordEntryInput newEntry) onUpdateEntry,
}) async {
  final res = await client.createChatCompletion(
    request: CreateChatCompletionRequest(
      model: ChatCompletionModel.modelId('gpt-4o'),
      messages: [
        const ChatCompletionMessage.system(
          content:
              'You are an helpful and kind english assistant for creating records '
              'in non-native English learner dictionary. The learner knows Russian. '
              'User provides you enlighs phrases or words and you generate definitions and examples. ',
        ),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(entry.word),
        ),
      ],
      temperature: 0,
      responseFormat: const ResponseFormat.jsonSchema(
        jsonSchema: JsonSchemaObject(
          name: 'DictionaryEntry',
          description: 'A record in the learner dictionary',
          strict: true,
          schema: {
            'type': 'object',
            'required': [
              'translation',
              'definition',
              'example',
              'synonyms',
              'antonyms'
            ],
            'properties': {
              'translation': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'Список значение слова на русском языке',
              },
              'definition': {
                'type': 'string',
                'description':
                    'Plain English explanation of what the word means without using the word'
              },
              'example': {
                'type': 'string',
                'description':
                    "An example of the phrase or a word. The user word is wrapped with '**'"
              },
              'synonyms': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'The list of synonyms of the word'
              },
              'antonyms': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'The list of antonyms of the word'
              },
            },
            'additionalProperties': false,
          },
        ),
      ),
    ),
  );

  final content = res.choices.first.message.content;
  if (content == null) {
    return;
  }
  final response = json.decode(content) as Map<String, dynamic>;

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
