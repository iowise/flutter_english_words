import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_trainer/models/repositories/WordEntryRepository.dart';

class TrainCard extends StatelessWidget {
  final WordEntry entry;
  final String text;

  const TrainCard({Key key, this.entry, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            ...(buildSynonyms(context)),
          ],
        ),
      ),
    );
  }

  List<Widget> buildSynonyms(BuildContext context) {
    final text = _buildSynonymsAndAntonyms(entry);
    return text.isNotEmpty
        ? [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.center,
              ),
            ),
          ]
        : [];
  }
}

String _buildSynonymsAndAntonyms(WordEntry entry) {
  final synonyms = entry.synonyms.isEmpty ? "" : "Synonyms: ${entry.synonyms}";
  final antonyms = entry.antonyms.isEmpty ? "" : "Antonyms: ${entry.antonyms}";
  return [synonyms, antonyms].where((element) => element.isNotEmpty).join("\n");
}
