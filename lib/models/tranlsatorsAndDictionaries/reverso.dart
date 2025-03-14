import 'dart:convert';

import 'package:http/http.dart' as http;

const _HEADERS = {
  "User-Agent": "Mozilla/5.0",
  "Content-Type": "application/json; charset=UTF-8",
};

Future<List<String>> reversoTranslation(final String text) async {
  final List definitionsJson =
      (await _callReverso(text))["DefsByWord"][0]['DefsByPos'];
  final definitions =
      definitionsJson.expand((element) => element['Defs'] as List<dynamic>).toList();
  definitions.sort((a, b) => a['frequency'].compareTo(b['frequency']));
  return definitions
      .expand((element) => element['translations'])
      .map((element) => element['translation'] as String)
      .toList();
}

Future<List<String>> reversoWordContexts(final String text) async {
  final definitionsJson =
      (await _callReverso(text))['DefsByWord'][0]['DefsByPos'];
  final definitions =
      definitionsJson.expand((element) => element['Defs'] as List<dynamic>).toList();
  return [
    for (final i in definitions)
      _replaceHTMLWithMarkdown(i['examples'][0]['example'])
  ];
}

/// Call the reverso API
/// The response is like the following:
/// {
//   "OrigWord": "reverse",
//   "Canonical": "reverse",
//   "DefsByWord": [
//     {
//       "word": "reverse",
//       "id": 902692,
//       "derivationMatched": false,
//       "DefsByPos": [
//         {
//           "Pos": "Verb",
//           "Defs": [
//             {
//               "Def": "move backwards or in the opposite direction",
//               "mention": "movement",
//               "frequency": "VeryCommon",
//               "examples": [
//                 {
//                   "example": "The train reversed into the station.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Поезд <em>поехал задним ходом</em> на станцию."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "двигаться задним ходом",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "ехать задним ходом",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "поехать задним ходом",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "revoke a law or change a decision",
//               "mention": "legal",
//               "frequency": "NotCommon",
//               "register": "FormalTechnical",
//               "examples": [
//                 {
//                   "example": "The government reversed the controversial law.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Правительство <em>отменило</em> спорный закон."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "отменить",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "аннулировать",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "отозвать",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "change a chemical reaction direction",
//               "mention": "chemistry",
//               "frequency": "NotCommon",
//               "register": "FormalTechnical",
//               "examples": [
//                 {
//                   "example": "The reaction was reversed under certain conditions.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Реакция была <em>обращена</em> при определенных условиях."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "обратить",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "изменить направление",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "engage reverse thrust on an engine",
//               "mention": "mechanics",
//               "frequency": "NotCommon",
//               "register": "FormalTechnical",
//               "examples": [
//                 {
//                   "example": "The pilot reversed the engines after landing.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Пилот <em>включил реверс</em> двигателей после посадки."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "включить реверс",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "задействовать обратную тягу",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "переключить на реверс",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "transpose the positions of two things",
//               "mention": "action",
//               "frequency": "NotCommon",
//               "examples": [
//                 {
//                   "example": "They reversed the roles in the play.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Они <em>поменяли</em> роли в пьесе."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "менять местами",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "поменять местами",
//                   "lang": "ru"
//                 }
//               ]
//             }
//           ],
//           "phrasal": false
//         },
//         {
//           "Pos": "Adjective",
//           "Defs": [
//             {
//               "Def": "directed or moving toward the rear",
//               "mention": "direction",
//               "frequency": "VeryCommon",
//               "examples": [
//                 {
//                   "example": "The vehicle was in reverse gear.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Автомобиль был на <em>задней</em> передаче."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "задний",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "обратный",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "реверсивный",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "back to front or inverted",
//               "mention": "inverted",
//               "frequency": "VeryCommon",
//               "examples": [
//                 {
//                   "example": "He wore his shirt in reverse.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Он надел рубашку <em>задом наперёд</em>."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "перевёрнутый",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "обратный",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "задом наперёд",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "opposite to what you expect or described",
//               "mention": "unexpected",
//               "frequency": "NotCommon",
//               "examples": [
//                 {
//                   "example": "The results were the reverse outcome.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Результаты были <em>противоположным</em> исходом."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "противоположный",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "обратный",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "неожиданный",
//                   "lang": "ru"
//                 }
//               ]
//             }
//           ],
//           "phrasal": false
//         },
//         {
//           "Pos": "Noun",
//           "Defs": [
//             {
//               "Def": "the gear setting for backward travel",
//               "mention": "automobile",
//               "frequency": "VeryCommon",
//               "register": "FormalTechnical",
//               "examples": [
//                 {
//                   "example": "Put the car in reverse to park.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Поставьте машину на <em>задний ход</em>, чтобы припарковаться."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "задний ход",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "реверс",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "задняя передача",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "the act of going backwards",
//               "mention": "movement",
//               "frequency": "VeryCommon",
//               "examples": [
//                 {
//                   "example": "The car was stuck in reverse.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Машина застряла на <em>задней передаче</em>."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "задний ход",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "задняя передача",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "движение назад",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "change to an opposite position",
//               "mention": "change",
//               "frequency": "VeryCommon",
//               "examples": [
//                 {
//                   "example": "The policy faced a reverse after protests.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Политика столкнулась с <em>обратным ходом</em> после протестов."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "обратный ход",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "откат",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "изменение курса",
//                   "lang": "ru"
//                 }
//               ]
//             },
//             {
//               "Def": "the opposite of something",
//               "mention": "contrast",
//               "frequency": "NotCommon",
//               "examples": [
//                 {
//                   "example": "His actions were the reverse of helpful.",
//                   "lang": "en",
//                   "num": 0,
//                   "translations": [
//                     {
//                       "lang": "ru",
//                       "translation": "Его действия были <em>противоположностью</em> полезного."
//                     }
//                   ]
//                 }
//               ],
//               "translations": [
//                 {
//                   "translation": "противоположность",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "обратное",
//                   "lang": "ru"
//                 },
//                 {
//                   "translation": "антипод",
//                   "lang": "ru"
//                 }
//               ]
//             }
//           ],
//           "phrasal": false
//         }
//       ],
//       "pronounceIpa": "rɪˈvɜːs, rɪˈvɝs",
//       "pronounceSpelling": "ri-VURS",
//       "frequency": "VeryCommon",
//       "idiom": false,
//       "expressions": [
//         "reverse discrimination",
//         "reverse charge call",
//         "reverse mortgage",
//         "reverse repo",
//         "reverse video",
//         "reverse proxy",
//         "reverse transcriptase",
//         "reverse course",
//         "reverse takeover",
//         "reverse stock split",
//         "reverse psychology",
//         "reverse gear",
//         "reverse the charge",
//         "non-nucleoside reverse transcriptase inhibitor",
//         "reverse import",
//         "double reverse",
//         "reverse shot",
//         "reverse fault",
//         "reverse the charges",
//         "reverse out",
//         "reverse commute",
//         "reverse one's fortunes",
//         "reverse roles",
//         "reverse Polish notation",
//         "piked reverse hang",
//         "reverse arms",
//         "the reverse of",
//         "reverse hang",
//         "reverse layup",
//         "reverse curve",
//         "reverse Midas touch",
//         "reverse swing",
//         "reverse genetics",
//         "reverse vending machine",
//         "nucleoside reverse transcriptase inhibitor",
//         "reverse lightning"
//       ],
//       "expressionsCount": 42,
//       "expressionDefs": [
//         {
//           "expression": "reverse osmosis",
//           "def": "process of purifying water using semipermeable membrane",
//           "pos": "Noun"
//         },
//         {
//           "expression": "reverse engineer",
//           "def": "discover how something works by examining its structure",
//           "pos": "Verb"
//         },
//         {
//           "expression": "reverse charge",
//           "def": "make the receiver pay for a call or service",
//           "pos": "Verb"
//         },
//         {
//           "expression": "in reverse",
//           "def": "operating in the opposite order or sequence",
//           "pos": "Adverb"
//         },
//         {
//           "expression": "reverse split",
//           "def": "decrease in outstanding shares without changing equity",
//           "pos": "Noun"
//         },
//         {
//           "expression": "the reverse is true",
//           "def": "the opposite situation is correct",
//           "pos": "Other"
//         }
//       ],
//       "related": [
//         {
//           "word": "reversal",
//           "relation": "SameRoot"
//         },
//         {
//           "word": "reversed",
//           "relation": "SameRoot"
//         },
//         {
//           "word": "reversible",
//           "relation": "SameRoot"
//         },
//         {
//           "word": "reversing",
//           "relation": "SameRoot"
//         },
//         {
//           "word": "back",
//           "relation": "Semantics"
//         },
//         {
//           "word": "invert",
//           "relation": "Semantics"
//         },
//         {
//           "word": "recede",
//           "relation": "Semantics"
//         },
//         {
//           "word": "retract",
//           "relation": "Semantics"
//         },
//         {
//           "word": "return",
//           "relation": "Semantics"
//         },
//         {
//           "word": "undo",
//           "relation": "Semantics"
//         },
//         {
//           "word": "withdraw",
//           "relation": "Semantics"
//         },
//         {
//           "word": "abolish",
//           "relation": "Semantics"
//         },
//         {
//           "word": "cancel",
//           "relation": "Semantics"
//         },
//         {
//           "word": "invalidate",
//           "relation": "Semantics"
//         },
//         {
//           "word": "nullify",
//           "relation": "Semantics"
//         },
//         {
//           "word": "overturn",
//           "relation": "Semantics"
//         },
//         {
//           "word": "repeal",
//           "relation": "Semantics"
//         },
//         {
//           "word": "void",
//           "relation": "Semantics"
//         },
//         {
//           "word": "alter",
//           "relation": "Semantics"
//         },
//         {
//           "word": "change",
//           "relation": "Semantics"
//         },
//         {
//           "word": "chemistry",
//           "relation": "Semantics"
//         },
//         {
//           "word": "convert",
//           "relation": "Semantics"
//         },
//         {
//           "word": "process",
//           "relation": "Semantics"
//         },
//         {
//           "word": "reaction",
//           "relation": "Semantics"
//         },
//         {
//           "word": "shift",
//           "relation": "Semantics"
//         },
//         {
//           "word": "transform",
//           "relation": "Semantics"
//         },
//         {
//           "word": "control",
//           "relation": "Semantics"
//         },
//         {
//           "word": "direction",
//           "relation": "Semantics"
//         },
//         {
//           "word": "engage",
//           "relation": "Semantics"
//         },
//         {
//           "word": "engine",
//           "relation": "Semantics"
//         },
//         {
//           "word": "mechanism",
//           "relation": "Semantics"
//         },
//         {
//           "word": "movement",
//           "relation": "Semantics"
//         },
//         {
//           "word": "thrust",
//           "relation": "Semantics"
//         },
//         {
//           "word": "exchange",
//           "relation": "Semantics"
//         },
//         {
//           "word": "flip",
//           "relation": "Semantics"
//         },
//         {
//           "word": "transpose",
//           "relation": "Semantics"
//         },
//         {
//           "word": "antithetical",
//           "relation": "Semantics"
//         },
//         {
//           "word": "contradictory",
//           "relation": "Semantics"
//         },
//         {
//           "word": "contrary",
//           "relation": "Semantics"
//         },
//         {
//           "word": "inverse",
//           "relation": "Semantics"
//         },
//         {
//           "word": "opposing",
//           "relation": "Semantics"
//         },
//         {
//           "word": "opposite",
//           "relation": "Semantics"
//         },
//         {
//           "word": "receding",
//           "relation": "Semantics"
//         },
//         {
//           "word": "backward",
//           "relation": "Semantics"
//         },
//         {
//           "word": "flipped",
//           "relation": "Semantics"
//         },
//         {
//           "word": "mirrored",
//           "relation": "Semantics"
//         },
//         {
//           "word": "reversed",
//           "relation": "Semantics"
//         },
//         {
//           "word": "contrasting",
//           "relation": "Semantics"
//         },
//         {
//           "word": "counter",
//           "relation": "Semantics"
//         },
//         {
//           "word": "divergent",
//           "relation": "Semantics"
//         },
//         {
//           "word": "inconsistent",
//           "relation": "Semantics"
//         },
//         {
//           "word": "paradoxical",
//           "relation": "Semantics"
//         },
//         {
//           "word": "unexpected",
//           "relation": "Semantics"
//         },
//         {
//           "word": "automobile",
//           "relation": "Semantics"
//         },
//         {
//           "word": "clutch",
//           "relation": "Semantics"
//         },
//         {
//           "word": "drive",
//           "relation": "Semantics"
//         },
//         {
//           "word": "gearbox",
//           "relation": "Semantics"
//         },
//         {
//           "word": "transmission",
//           "relation": "Semantics"
//         },
//         {
//           "word": "vehicle",
//           "relation": "Semantics"
//         },
//         {
//           "word": "regression",
//           "relation": "Semantics"
//         },
//         {
//           "word": "reversal",
//           "relation": "Semantics"
//         },
//         {
//           "word": "turnaround",
//           "relation": "Semantics"
//         },
//         {
//           "word": "withdrawal",
//           "relation": "Semantics"
//         },
//         {
//           "word": "antithesis",
//           "relation": "Semantics"
//         },
//         {
//           "word": "backtrack",
//           "relation": "Semantics"
//         },
//         {
//           "word": "contradiction",
//           "relation": "Semantics"
//         },
//         {
//           "word": "contrast",
//           "relation": "Semantics"
//         },
//         {
//           "word": "difference",
//           "relation": "Semantics"
//         },
//         {
//           "word": "negation",
//           "relation": "Semantics"
//         },
//         {
//           "word": "opposition",
//           "relation": "Semantics"
//         }
//       ],
//       "etymology": "Latin, reversus (turned back)"
//     }
//   ],
//   "Fuzzy": false,
//   "Neighbors": {
//     "before": [
//       "reversal of fortune",
//       "reversal of roles"
//     ],
//     "after": [
//       "reverse Midas touch",
//       "reverse Polish notation"
//     ]
//   },
//   "timings": {
//     "search": 0,
//     "overal": 6,
//     "dbCalls": 6
//   }
// }
Future<Map<String, dynamic>> _callReverso(final String text,
    {final sourceLang = 'en', final targetLang = 'ru'}) async {
  if (_cache.containsKey(text)) {
    return _cache[text]!;
  }
  final parameters = {
    'targetLang': targetLang,
    'maxExpressions': '60',
    'showNeighbors': '2',
    'expressionDefs': '6',
    'wordExpressions': 'true',
    'synonyms': 'false',
  };

  final uri = Uri.https(
    'definition-api.reverso.net',
    "/v1/api/definitions/${sourceLang}/${text}",
    parameters,
  );
  final response = await http.get(uri, headers: _HEADERS);
  final decoded = json.decode(response.body);
  if (response.statusCode == 200) {
    _cache[text] = decoded;
  }
  return decoded;
}

final emRegex = new RegExp(r'</?em>');

String _replaceHTMLWithMarkdown(String s) => s.replaceAll(emRegex, '**');

final _cache = new Map<String, Map<String, dynamic>>();
