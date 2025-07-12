import 'package:cloud_functions/cloud_functions.dart';
import './input.dart';

enum Language { English, Korean, Japanese }

var _language = Language.English;

Language getGlobalLanguage() => _language;
void setGlobalLanguage(Language language) {
  _language = language;
}

Future<void> openAIOverFirebaseFunction({
  required final WordEntryInput entry,
  required void Function(WordEntryInput newEntry) onUpdateEntry
}) async {
  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'enrich_word_entry',
    options: HttpsCallableOptions(
      timeout: const Duration(minutes: 2),
    ),
  );
  final language = getGlobalLanguage().name;
  try {
    final result = await callable({
      'word': entry.word,
      'translation': entry.translation,
      'language': language,
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
    );
    onUpdateEntry(newEntry);
  } on FirebaseFunctionsException catch (e) {
    print(e.message);
  }
}
