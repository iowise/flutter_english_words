import 'package:flutter/material.dart';
import 'package:flutter_app/pages/Words.dart';

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
      home: WordsPage(title: 'Words'),
      routes: <String, WidgetBuilder> {
        '/train': (BuildContext context) => WordsPage(title: 'page C'),
      },
    );
  }
}