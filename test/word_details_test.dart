import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:word_trainer/models/repositories/TrainLogRepository.dart';
import 'package:word_trainer/models/repositories/WordEntryRepository.dart';

import 'package:word_trainer/pages/WordDetails.dart';

import 'fakes.dart';

void main() {
  tearDown(() {
    GetIt.I.reset();
  });

  group("Create a word and edit word without logs", () {
    setUp(() {
      final wordEntryRepository = FakeWordEntryRepository();
      final trainLogRepository = FakeTrainLogRepository();
      when(trainLogRepository.getLogs("null"))
          .thenAnswer((realInvocation) => Future.value([]));

      GetIt.I.registerSingleton<WordEntryRepository>(wordEntryRepository);
      GetIt.I.registerSingleton<TrainLogRepository>(trainLogRepository);
    });

    testWidgets('Create no label', (WidgetTester tester) async {
      await tester
          .pumpWidget(MaterialApp(home: WordDetails(title: "Create a word")));

      expect(find.text('Create a word'), findsOneWidget);
      expect(find.text('Enter a synonyms...'), findsOneWidget);
    });

    testWidgets('Create with a label', (WidgetTester tester) async {
      await pumpArgumentWidget(
        tester,
        child: WordDetails(title: "Create a word"),
        args: WordDetailsArguments(label: "testLabel", entry: null),
      );

      expect(find.text('Create a word'), findsOneWidget);
      expect(find.text('Enter a synonyms...'), findsOneWidget);
      expect(find.text('testLabel'), findsOneWidget);
    });

    testWidgets('Create with a word', (WidgetTester tester) async {
      await pumpArgumentWidget(
        tester,
        child: WordDetails(title: "Create a word"),
        args: WordDetailsArguments(word: "new word"),
      );

      expect(find.text('Create a word'), findsOneWidget);
      expect(find.text('Enter a synonyms...'), findsOneWidget);
      expect(find.text('new word'), findsOneWidget);
    });

    testWidgets('Edit with label', (WidgetTester tester) async {
      await pumpArgumentWidget(
        tester,
        child: WordDetails(title: "Create a word"),
        args: WordDetailsArguments(
          entry: WordEntry.create(
            word: "word",
            translation: "null",
            definition: "null",
            context: "null",
            synonyms: "null",
            antonyms: "null",
            labels: ["testLabel"],
          ),
          label: "FilteredLabel",
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create a word'), findsOneWidget);
      expect(find.text('Enter a synonyms...'), findsOneWidget);
      expect(find.text('testLabel'), findsOneWidget);
      expect(find.text('word'), findsOneWidget);
      expect(find.text('FilteredLabel'), findsNothing);
    });

    testWidgets('Edit with no label', (WidgetTester tester) async {
      await pumpArgumentWidget(
        tester,
        child: WordDetails(title: "Create a word"),
        args: WordDetailsArguments(
          entry: WordEntry.create(
            word: "null",
            translation: "null",
            definition: "null",
            context: "null",
            synonyms: "null",
            antonyms: "null",
            labels: ["testLabel"],
          ),
        ),
      );

      expect(find.text('Create a word'), findsOneWidget);
      expect(find.text('Enter a synonyms...'), findsOneWidget);
      expect(find.text('testLabel'), findsOneWidget);
      expect(find.text('FilteredLabel'), findsNothing);
    });
  });

  group("Edit word with logs", () {
    setUp(() {
      final wordEntryRepository = FakeWordEntryRepository();
      final trainLogRepository = FakeTrainLogRepository();
      when(trainLogRepository.getLogs("null"))
          .thenAnswer((realInvocation) => Future.value([TrainLog("null", 10)]));

      GetIt.I.registerSingleton<WordEntryRepository>(wordEntryRepository);
      GetIt.I.registerSingleton<TrainLogRepository>(trainLogRepository);
    });

    testWidgets('Edit with with logs', (WidgetTester tester) async {
      await pumpArgumentWidget(
        tester,
        child: WordDetails(title: "Create a word"),
        args: WordDetailsArguments(
          entry: WordEntry.create(
            word: "null",
            translation: "null",
            definition: "null",
            context: "null",
            synonyms: "null",
            antonyms: "null",
            labels: ["testLabel"],
          ),
        ),
      );

      expect(find.text('Create a word'), findsOneWidget);
      expect(find.text('Enter a synonyms...'), findsOneWidget);
      expect(find.text('testLabel'), findsOneWidget);
      expect(find.text('FilteredLabel'), findsNothing);
      expect(find.text('10'), findsNothing);
    });
  });
}

Future<void> pumpArgumentWidget(
  WidgetTester tester, {
  required Object args,
  required Widget child,
}) async {
  final key = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: key,
      home: TextButton(
        onPressed: () => key.currentState!.push(
          MaterialPageRoute<void>(
            settings: RouteSettings(arguments: args),
            builder: (_) => child,
          ),
        ),
        child: const SizedBox(),
      ),
    ),
  );

  await tester.tap(find.byType(TextButton));
  await tester
      .pumpAndSettle(); // Might need to be removed when testing infinite animations
}
