import 'dart:convert';
import 'dart:io';

// import 'package:file_picker/file_picker.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'repositories/TrainLogRepository.dart';
import 'repositories/WordEntryRepository.dart';

exportDB(WordEntryRepository wordEntryRepository,
    TrainLogRepository trainLogRepository) async {
  final externalDir = (await getExternalStorageDirectory())!.path;
  File file = File(externalDir + 'word.train.export.data.json');
  final logs =
      List.of([for (var i in await trainLogRepository.dumpLogs(true)) i.toMap()]);
  final words = List.of(
      [for (var i in await wordEntryRepository.getWordEntries()) i.toMap()]);
  Map<String, dynamic> exportMaps = {'words': words, 'logs': logs};
  file.writeAsString(jsonEncode(exportMaps));

  await Share.shareFiles(
    [file.path],
    text: 'Example share text',
  );
}

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
