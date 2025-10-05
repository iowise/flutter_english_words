import 'package:flutter_test/flutter_test.dart';
import 'package:word_trainer/models/blocs/WordEntryCubit.dart';
import 'package:word_trainer/models/repositories/WordEntryRepository.dart';

void main() {
  test('Unique by id list of words', () {
    final wordList = new WordEntryListState(allWords: []);
    final word1 = WordEntry.create(
      word: "test",
      translation: "",
      definition: "",
      context: "",
      synonyms: "",
      antonyms: "",
      locale: "en-US",
      labels: [],
    );
    word1.id = "1";
    final duplicateWord1 = WordEntry.create(
      word: "duplicate test",
      translation: "",
      definition: "",
      context: "",
      synonyms: "",
      antonyms: "",
      locale: 'en-US',
      labels: [],
    );
    duplicateWord1.id = "1";
    final word2 = WordEntry.create(
      word: "another test",
      translation: "",
      definition: "",
      context: "",
      synonyms: "",
      antonyms: "",
      locale: 'en-US',
      labels: [],
    );
    word2.id = "2";

    final uniqueWords = wordList.copy(words: [word1, duplicateWord1, word2]);
    expect(uniqueWords.allWords, [word1, word2]);
  });
}
