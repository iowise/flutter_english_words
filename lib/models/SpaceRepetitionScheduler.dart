import 'dart:math';

import 'package:flutter/foundation.dart';

import './WordEntryRepository.dart';
import './TrainLogRepository.dart';

class TrainService extends ChangeNotifier {
  WordEntryRepository wordEntryRepository;
  TrainLogRepository trainLogRepository;

  TrainService(this.wordEntryRepository, this.trainLogRepository);

  Future<List<WordEntry>> getToReviewToday() async {
    final now = DateTime.now();
    final forLearn = await wordEntryRepository.query(
      where: (words) => words.dueToLearnAfter == null || words.dueToLearnAfter.isBefore(now)
    ).toList();
    forLearn.sort((right, left) => right.id.compareTo(left.id));
    return makeListToLearn(forLearn);
  }

  Future trainWord(WordEntry word, bool isCorrect, int attempt) async {
    final score = isCorrect ? (attempt == 0 ? 4 : 1) : 0;

    final history = await trainLogRepository.getLogs(word.id);
    final historyScore = history.map((e) => e.score);
    final waitInDays = daysTillNextTestAlgorithm(score, historyScore);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    word.dueToLearnAfter = today.add(Duration(days: waitInDays));
    await wordEntryRepository.update(word);

    await trainLogRepository.insert(TrainLog(word.id, score));
    notifyListeners();
  }
}

/**
 * Returns the number of days to delay the next review of an item by, fractionally, based on the history of answers x to
 * a given question, where
 * x == 0: Incorrect, Hardest
 * x == 1: Incorrect, Hard
 * x == 2: Incorrect, Medium
 * x == 3: Correct, Medium
 * x == 4: Correct, Easy
 * x == 5: Correct, Easiest
 * @param x The history of answers in the above scoring.
 * @param theta When larger, the delays for correct answers will increase.
 * Based on [a gist](https://gist.github.com/doctorpangloss/13ab29abd087dc1927475e560f876797)
 */
int daysTillNextTestAlgorithm(int recent, Iterable<int> x,
    {a: 6.0, b: -0.8, c: 0.28, d: 0.02, theta: 0.2}) {
  if (recent < 4) {
    return 1;
  }

  var history = [recent, ...x];
  if (history.length == 1) {
    return 1;
  }

  // Calculate latest correctness streak
  var streak = 0;
  for (var i = 0; i < history.length; i++) {
    if (history[i] > 3) {
      streak += 1;
    } else {
      break;
    }
  }

  // Sum up the history
  var historySum = history.fold(
    0.0,
    (prev, val) => prev + (b + (c * val) + (d * val * val)),
  );

  return (a * pow(max(1.3, 2.5 + historySum), theta * streak)).round();
}

const MAX_TO_LEARN = 10;

List<T> makeListToLearn<T>(List<T> list) {
  final now = DateTime.now().microsecondsSinceEpoch / 1000 /1000;
  final daysSinceEpoch = now ~/ 3600 ~/ 24;
  list = List.from(list == null ? [] : list);
  list.shuffle(Random(daysSinceEpoch));
  return list;
}

List<T> limitWordsToTrain<T>(List<T> list) => List.from(list.getRange(0, wordsToTrain(list)));
int wordsToTrain(List list) => min(MAX_TO_LEARN, list.length);
