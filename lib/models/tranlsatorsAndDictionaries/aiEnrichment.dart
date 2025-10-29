import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
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
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("Error: User is not signed in.");
    return;
  }

  try {
    final idToken = await user.getIdToken();

    final url = Uri.parse('https://go-http-function-801468521928.us-central1.run.app/');

    final requestBody = jsonEncode({
      'word': entry.word,
      'translation': entry.translation,
      'language': language.name,
    });

    final client = HttpClient();
    client.idleTimeout = const Duration(minutes: 2);

    final request = await client.postUrl(url);
    request.headers
        .set(HttpHeaders.contentTypeHeader, 'application/json; charset=UTF-8');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $idToken');
    request.write(requestBody);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == HttpStatus.ok) {
      final resultData = jsonDecode(responseBody) as Map<String, dynamic>;

      final newEntry = WordEntryInput(
        word: entry.word.isEmpty ? resultData['word'] as String : entry.word,
        context: resultData['example'] as String,
        translation: List<String>.from(resultData['translation']).join('; '),
        definition: resultData['definition'] as String,
        synonyms: List<String>.from(resultData['synonyms']).join('; '),
        antonyms: List<String>.from(resultData['antonyms']).join('; '),
        labels: entry.labels,
        locale: language.locale,
      );
      onUpdateEntry(newEntry);
    } else {
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: $responseBody');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
