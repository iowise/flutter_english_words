import 'dart:convert';

import 'package:http/http.dart' as http;

final _HEADERS = {
  "User-Agent": "Mozilla/5.0",
  "Content-Type": "application/json; charset=UTF-8",
};

Future<List<String>> reverso(final String text,
    {final source_lang = 'en', final target_lang = 'ru'}) async {
  final data = {
    "source_text": text,
    "target_text": '',
    "source_lang": source_lang,
    "target_lang": target_lang,
  };
  final response = await http.post(
      "https://context.reverso.net/bst-query-service",
      headers: _HEADERS,
      body: jsonEncode(data));
  final translationsJson = json.decode(response.body)["dictionary_entry_list"];
  return [for (final i in translationsJson) i['term']];
}
