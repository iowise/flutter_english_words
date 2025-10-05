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
