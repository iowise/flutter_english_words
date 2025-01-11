import 'package:flutter/material.dart';
import 'package:word_trainer/pages/WordDetails.dart';
import '../models/repositories/WordEntryRepository.dart';

class WordList extends StatelessWidget {
  WordList({Key? key, required this.words}) : super(key: key);

  final List<WordEntry> words;

  @override
  Widget build(BuildContext context) {
    if (words.length == 0) {
      return Center(child: Text("Please enter a new word"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      shrinkWrap: true,
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();

        final index = i ~/ 2;
        return _buildRow(words[index], context);
      },
      itemCount: words.length * 2 - 1,
    );
  }

  Widget _buildRow(WordEntry row, BuildContext context) {
    return ListTile(
      title: Text(row.word),
      subtitle: Text(row.translation),
      onTap: () => this._showDetails(row, context),
    );
  }

  _showDetails(WordEntry row, context) {
    Navigator.pushNamed(context, "/word/edit",
        arguments: WordDetailsArguments(entry: row));
  }
}
