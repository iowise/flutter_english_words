import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import './components/SplashScreen.dart';
import './pages/Labels.dart';
import './pages/SentenceTrain.dart';
import './pages/Words.dart';
import './pages/WordDetails.dart';
import './pages/WordTrain.dart';
import './di.dart';

void main() async {
  // await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          primary: Colors.amber,
          secondary: Colors.amberAccent,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme.copyWith(
                headlineLarge: TextStyle(fontSize: 72.0),
                headlineMedium: TextStyle(fontSize: 36.0),
                headlineSmall: TextStyle(fontSize: 32.0),
                bodyLarge: TextStyle(fontSize: 20.0),
                bodyMedium: TextStyle(fontSize: 16.0),
                bodySmall: TextStyle(fontSize: 14.0),
              ),
        ),
      ),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) =>
            SplashScreen(builder: () => LabelsPage()),
        '/train/word/translation/': (BuildContext context) => TrainPage(
              title: 'Train a word',
              hintType: HintTypes.translation,
            ),
        '/train/word/definition/': (BuildContext context) => TrainPage(
              title: 'Train a word',
              hintType: HintTypes.definition,
            ),
        '/train/sentence': (BuildContext context) => EnterSentenceTrainPage(),
        '/words/': (BuildContext context) => WordsPage(),
        '/labels/': (BuildContext context) => LabelsPage(),
        '/word/create': (BuildContext context) =>
            WordDetails(title: 'Enter a word'),
        '/word/edit': (BuildContext context) =>
            WordDetails(title: 'Edit a word'),
      },
    );
  }
}
