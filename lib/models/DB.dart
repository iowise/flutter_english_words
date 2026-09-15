import 'dart:convert';
import 'dart:io';
import "package:collection/collection.dart";

import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import './repositories/TrainLogRepository.dart';
import './repositories/WordEntryRepository.dart';

importDB(WordEntryRepository wordEntryRepository,
    TrainLogRepository trainLogRepository) async {
  /*
  FilePickerResult? file = await FilePicker.platform.pickFiles(withData: true);
  if (file == null || !file.isSinglePick) return;

  final json = jsonDecode(file.files.first.bytes.toString());

  final words = json['words'];
  final wordsMap = {};

  for (final i in words) {
    final copy = await wordEntryRepository.findCopy(i['word']);
    if (copy != null) {
      continue;
    }
    final _id = i['_id'];
    i['_id'] = null;
    final entry = WordEntry.fromMap(i);
    await wordEntryRepository.insert(entry);
    wordsMap[_id] = entry;
  }

  final logs = json['logs'];
  for (final i in logs) {
    if (wordsMap[i['word_id']] == null) {
      continue;
    }
    i['_id'] = null;
    i['word_id'] = wordsMap[i['word_id']].id;
    final log = TrainLog.fromMap(i);
    await trainLogRepository.insert(log);
  }
  */
}

/// Exports all word entries and their training logs to a JSON file.
///
/// The exported schema contains a "words" array where each word entry includes:
/// - word, translation, context, definition, synonyms, antonyms, locale
/// - createdAt timestamp and labels list
/// - optionally _id if the entry has been saved to Firestore
/// - logs array containing word_id, score, and trainedAt for each training log
///
/// Example exported JSON structure:
/// ```json
/// {
///   "words": [
///     {
///       "word": "hello",
///       "translation": "hola",
///       "context": "greeting",
///       "definition": "a greeting",
///       "synonyms": "hi, hey",
///       "antonyms": "goodbye",
///       "_locale": "en-US",
///       "createdAt": "2024-01-15T10:30:00.000Z",
///       "labels": ["common", "greeting"],
///       "_id": "word123",
///       "trainedAt": "2024-01-20T14:00:00.000Z",
///       "dueToLearnAfter": "2024-01-27T14:00:00.000Z",
///       "logs": [
///         {
///           "word_id": "word123",
///           "score": 5,
///           "trainedAt": "2024-01-20T14:00:00.000Z"
///         }
///       ]
///     }
///   ]
/// }
/// ```
///
/// Returns the path to the exported JSON file.
Future<String> exportDB(WordEntryRepository wordEntryRepository,
    TrainLogRepository trainLogRepository) async {
  final words = await wordEntryRepository.getAllWordEntries(true);
  final List<Map<String, dynamic>> outputWords = [];
  final Map<String, Map<String, dynamic>> wordsMap = {};

  Fluttertoast.showToast(msg: "exporting ${words.length} words 1");

  final logSnapshot = await trainLogRepository.logs!.get();
  final logEntries = [
    for (final doc in logSnapshot.docs) TrainLog.fromDocument(doc)
  ];
  logEntries.sortBy((i) => i.wordId);
  final logsForWordID = groupBy(logEntries, (i) => i.wordId);
  Fluttertoast.showToast(msg: "exporting ${logEntries.length} logs");

  for (final i in words) {
    final logs = logsForWordID[i.id!] ?? [];
    final wordMap = i.toMap();
    wordMap['logs'] = logs.map((log) => log.toMap()).toList();
    wordsMap[i.id!] = wordMap;
    outputWords.add(wordMap);
  }
  Fluttertoast.showToast(msg: "exported");

  final exportData = <String, dynamic>{
    'words': outputWords,
  };

  final jsonString = jsonEncode(exportData);
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/db_export.json');
  await file.create(recursive: true);
  await file.writeAsString(jsonString);

  return file.path;
}
