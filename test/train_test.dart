import 'package:flutter_app/models/WordEntryRepository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/components/Train.dart';

void main() {
  test('Train case insensitive', () {
    final controller = TrainController(WordEntry.create('test', '', ''));
    controller.text = 'Test';
    expect(controller.isCorrect, isTrue);
  });
  test('Train trimmed', () {
    final controller = TrainController(WordEntry.create('test', '', ''));
    controller.text = '  test  ';
    expect(controller.isCorrect, isTrue);
  });
}
