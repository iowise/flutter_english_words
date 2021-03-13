import './googleTranslation/google_translator.dart';

Future<String> getGoogleTranslation(String word) async {
  if (_cache.containsKey(word)) return _cache[word]!;

  final russianTranslation =
      await GoogleTranslator().translate(word, from: 'en', to: 'ru');
  _cache[word] = russianTranslation.text;
  return russianTranslation.text;
}

final _cache = new Map<String, String>();
