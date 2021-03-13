import 'dart:convert';

import 'package:http/http.dart' as http;

const _HEADERS = {
  "User-Agent": "Mozilla/5.0",
  "Content-Type": "application/json; charset=UTF-8",
};

Future<List<String>> reversoTranslation(final String text) async {
  final List translationsJson =
      (await _callReverso(text))["dictionary_entry_list"];
  translationsJson.sort((a, b) => a['frequency'].compareTo(b['frequency']));
  return [for (final i in translationsJson) i['term']];
}

Future<List<String>> reversoWordContexts(final String text) async {
  final examplesJson = (await _callReverso(text))['list'];
  return [for (final i in examplesJson) _replaceHTMLWithMarkdown(i['s_text'])];
}

/// Call the reverso API
/// The response is like the following:
/// {
///     "list": [
///         {
///             "s_text": "We must <em>go</em>, <em>go</em> and <em>go</em>.",
///             "t_text": "Мы должны <em>идти</em>, <em>идти</em> и <em>идти</em>.",
///             "ref": "OPENSUBTITLES-2018.EN-RU_5410983",
///             "cname": "OPENSUBTITLES-2018.EN-RU",
///             "url": "http://opus.nlpl.eu/OpenSubtitles2018.php",
///             "ctags": "general",
///             "pba": false
///         },
///     ],
///     "nrows": 247604,
///     "nrows_exact": 247604,
///     "pagesize": 20,
///     "npages": 12381,
///     "page": 1,
///     "removed_superstrings": [
///         "go back",
///     ],
///     "dictionary_entry_list": [
///         {
///             "frequency": 42254,
///             "term": "пойти",
///             "isFromDict": true,
///             "isPrecomputed": true,
///             "stags": [
///                 "precomputed"
///             ],
///             "pos": "v.",
///             "sourcepos": [
///                 "n.",
///             ],
///             "variant": null,
///             "domain": null,
///             "definition": null,
///             "vowels2": null,
///             "transliteration2": null,
///             "alignFreq": 42254,
///             "reverseValidated": true,
///             "pos_group": 1,
///             "isTranslation": true,
///             "isFromLOCD": false,
///             "inflectedForms": [
///                 {
///                     "frequency": 0,
///                     "term": "пойду",
///                     "isFromDict": true,
///                     "isPrecomputed": true,
///                     "stags": [
///                         "precomputed"
///                     ],
///                     "pos": null,
///                     "sourcepos": [
///                         "n.",
///                         "v."
///                     ],
///                     "variant": null,
///                     "domain": null,
///                     "definition": null,
///                     "vowels2": null,
///                     "transliteration2": null,
///                     "alignFreq": 8469,
///                     "reverseValidated": false,
///                     "pos_group": 0,
///                     "isTranslation": false,
///                     "isFromLOCD": false,
///                     "inflectedForms": []
///                 },
///             ]
///         },
///     ],
///     "dictionary_other_frequency": 0,
///     "dictionary_nrows": 0,
///     "time_ms": 508,
///     "request": {
///         "source_text": "go",
///         "target_text": "",
///         "source_lang": "en",
///         "target_lang": "ru",
///         "npage": 1,
///         "corpus": null,
///         "nrows": 20,
///         "adapted": false,
///         "nonadapted_text": "go",
///         "rude_words": false,
///         "colloquialisms": false,
///         "risky_words": false,
///         "mode": 0,
///         "expr_sug": 0,
///         "dym_apply": false,
///         "pos_reorder": 8,
///         "device": 0,
///         "split_long": false,
///         "has_locd": true,
///         "source_pos": null
///     },
///     "suggestions": [
///         {
///             "lang": "en",
///             "suggestion": "<b>go</b> back",
///             "weight": 15212,
///             "isFromDict": true
///         },
///     ],
///     "dym_case": -1,
///     "dym_list": [],
///     "dym_applied": null,
///     "dym_nonadapted_search": null,
///     "dym_pair_applied": null,
///     "dym_nonadapted_search_pair": null,
///     "dym_pair": null,
///     "extracted_phrases": []
/// }
Future<Map<String, dynamic>> _callReverso(final String text,
    {final sourceLang = 'en', final targetLang = 'ru'}) async {
  if (_cache.containsKey(text)) {
    return _cache[text]!;
  }
  final data = {
    "source_text": text,
    "target_text": '',
    "source_lang": sourceLang,
    "target_lang": targetLang,
  };
  final response = await http.post(
    Uri.parse("https://context.reverso.net/bst-query-service"),
    headers: _HEADERS,
    body: jsonEncode(data),
  );
  final decoded = json.decode(response.body);
  if (response.statusCode == 200) {
    _cache[text] = decoded;
  }
  return decoded;
}

final emRegex = new RegExp(r'</?em>');

String _replaceHTMLWithMarkdown(String s) => s.replaceAll(emRegex, '**');

final _cache = new Map<String, Map<String, dynamic>>();
