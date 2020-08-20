import 'package:flutter/material.dart';
import '../models/WordEntryRepository.dart';

class WordList extends StatelessWidget {
  WordList({Key key, this.words}) : super(key: key);

  final List<WordEntry> words;

  Widget _buildRow(WordEntry row) {
    return ListTile(
      title: Text(row.word),
      subtitle: Text(row.translation),
//      onTap: () => this._showDetails(row),
    );
  }

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
        return _buildRow(words[index]);
      },
      itemCount: words.length * 2 - 1,
    );
  }
}
