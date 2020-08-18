import 'package:flutter/material.dart';
import '../components/WordList.dart';
import '../components/Train.dart';

class TrainPage extends StatefulWidget {
  TrainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TrainPageState createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  final WordEntry entry = WordEntry("go", "идти");

  bool isCheck = false;

  _checkTheWord() {
    setState(() {
      isCheck = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Train(
            entry: entry,
            isCheck: isCheck,
            onSubmit: _checkTheWord,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Check',
        child: Icon(Icons.check),
        onPressed: _checkTheWord,
      ),
    );
  }
}
