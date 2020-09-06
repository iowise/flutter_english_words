import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './pages/Words.dart';
import './pages/WordDetails.dart';
import './pages/WordTrain.dart';
import './di.dart';

void main() {
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
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
        '/': (BuildContext context) => WordsPage(title: 'Words'),
        '/train': (BuildContext context) => TrainPage(title: 'Train a word'),
        '/words': (BuildContext context) => WordsPage(title: 'Words'),
        '/word/create': (BuildContext context) =>
            WordDetails(title: 'Enter word'),
        '/word/edit': (BuildContext context) => WordDetails(title: 'Edit word'),
      },
    );
  }
}
