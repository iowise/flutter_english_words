import 'package:word_trainer/models/WordEntryRepository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:word_trainer/components/Train.dart';

void main() {
  createController() => TrainController(WordEntry.create(
        word: 'test',
        translation: '',
        context: '',
        synonyms: '',
        antonyms: '',
        definition: '',
        labels: [],
      ));
  test('Train case insensitive', () {
    final controller = createController();
    controller.text = 'Test';
    expect(controller.isCorrect, isTrue);
  });
  test('Train trimmed', () {
    final controller = createController();
    controller.text = '  test  ';
    expect(controller.isCorrect, isTrue);
  });
}
