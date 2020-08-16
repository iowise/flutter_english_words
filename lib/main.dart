import 'package:flutter/material.dart';
import 'package:flutter_app/pages/Words.dart';
import 'package:flutter_app/pages/WordDetails.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: <String, WidgetBuilder> {
        '/': (BuildContext context) => WordDetails(title: 'Enter word'),
        '/train': (BuildContext context) => WordsPage(title: 'page C'),
        '/words': (BuildContext context) => WordsPage(title: 'Words'),
        '/word/create': (BuildContext context) => WordDetails(title: 'Enter word'),
      },
    );
  }
}