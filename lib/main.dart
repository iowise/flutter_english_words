// @dart=2.9
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_trainer/components/SplashScreen.dart';
import 'package:word_trainer/pages/SentenceTrain.dart';
import './pages/Words.dart';
import './pages/WordDetails.dart';
import './pages/WordTrain.dart';
import './di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(false);
  };
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Trainer',
      debugShowCheckedModeBanner: false,
      navigatorKey: GetIt.I.get(instanceName: 'Navigator'),
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme.copyWith(
                headline1: TextStyle(fontSize: 72.0),
                headline4: TextStyle(fontSize: 36.0),
                bodyText1: TextStyle(fontSize: 20.0),
                bodyText2: TextStyle(fontSize: 16.0),
              ),
        ),
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => SplashScreen(builder: () => WordsPage()),
        '/train/word/translation/': (BuildContext context) => TrainPage(
              title: 'Train a word',
              hintType: HintTypes.translation,
            ),
        '/train/word/definition/': (BuildContext context) => TrainPage(
              title: 'Train a word',
              hintType: HintTypes.definition,
            ),
        '/train/sentence': (BuildContext context) => EnterSentenceTrainPage(),
        '/words': (BuildContext context) => WordsPage(),
        '/word/create': (BuildContext context) =>
            WordDetails(title: 'Enter a word'),
        '/word/edit': (BuildContext context) =>
            WordDetails(title: 'Edit a word'),
      },
    );
  }
}
