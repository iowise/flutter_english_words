import 'package:flutter/material.dart';

class WordEntry {
  final String word;
  final String translation;

  WordEntry(this.word, this.translation);
}

class WordList extends StatelessWidget {
  WordList({Key key, this.words}) : super(key: key);

  final List<WordEntry> words;

  Widget _buildRow(WordEntry row) {
    return ListTile(
      title: Text(row.translation),
      subtitle: Text(row.word),
//      onTap: () => this._showDetails(row),
    );
  }
  @override
  Widget build(BuildContext context) {
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