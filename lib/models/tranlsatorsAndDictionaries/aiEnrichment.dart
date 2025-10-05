import 'package:cloud_functions/cloud_functions.dart';
import './input.dart';

enum Language {
  English(locale: 'en-US', icon: '🇬🇧'),
  Korean(locale: 'ko-KR', icon: '🇰🇷'),
  Japanese(locale: 'ja-JP', icon: '🇯🇵');

  const Language({required this.locale, required this.icon});

  final String locale;
  final String icon;
}

Language findLanguage(String locale) {
  switch (locale) {
    case 'ko-KR':
      return Language.Korean;
    case 'ja-JP':
      return Language.Japanese;
    default:
      return Language.English;
  }
}

Future<void> openAIOverFirebaseFunction(
    {required final WordEntryInput entry,
    required final Language language,
    required void Function(WordEntryInput newEntry) onUpdateEntry}) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'enrich_word_entry',
    options: HttpsCallableOptions(
      timeout: const Duration(minutes: 2),
    ),
  );
  try {
    final result = await callable({
      'word': entry.word,
      'translation': entry.translation,
      'language': language.name,
    });
    final response = result.data as Map<String, dynamic>;

    final newEntry = WordEntryInput(
      word: entry.word.isEmpty ? response['word'] as String : entry.word,
      context: response['example'] as String,
      translation: List<String>.from(response['translation']).join('; '),
      definition: response['definition'] as String,
      synonyms: List<String>.from(response['synonyms']).join('; '),
      antonyms: List<String>.from(response['antonyms']).join('; '),
      labels: entry.labels,
      locale: language.locale,
    );
    onUpdateEntry(newEntry);
  } on FirebaseFunctionsException catch (e) {
    print(e.message);
  }
}
