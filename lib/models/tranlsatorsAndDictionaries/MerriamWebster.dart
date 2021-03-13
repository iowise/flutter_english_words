import 'dart:convert';
import 'package:http/http.dart' as http;

const _AUTH_KEY = '61989903-65c7-433a-a118-faa1eb8d7255';

Future<List<String>> merriamWebsterDefinitions(String text) async {
  if (text.isEmpty) {
    return [];
  }
  return _callThesaurus(text);
}

Future<List<String>> _callThesaurus(String text) async {
  if (_cache.containsKey(text)) {
    return _cache[text]!;
  }
  final url =
      "https://dictionaryapi.com/api/v3/references/thesaurus/json/$text?key=$_AUTH_KEY";
  final response = await http.post(Uri.parse(url));

  final thesaurusRecords = json.decode(response.body);
  final shortDefinitions = thesaurusRecords.expand((element) =>
      new List<String>.from(element is Map ? element['shortdef'] : []));
  final result = new List<String>.from(shortDefinitions);
  if (response.statusCode == 200) {
    _cache[text] = result;
  }
  return result;
}

final _cache = Map<String, List<String>>();
