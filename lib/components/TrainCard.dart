import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/repositories/WordEntryRepository.dart';

class TrainCard extends StatelessWidget {
  final WordEntry entry;
  final String text;

  const TrainCard({
    Key? key,
    required this.entry,
    required this.text,
  }) : super(key: key);

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
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            ...(buildSynonyms(context)),
          ],
        ),
      ),
    );
  }

  List<Widget> buildSynonyms(BuildContext context) {
    final text = _buildSynonymsAndAntonyms(context, entry);
    if (text.isEmpty) {
      return [];
    }
    return [
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }
}

String _buildSynonymsAndAntonyms(BuildContext context, WordEntry entry) {
  final localizations = AppLocalizations.of(context)!;
  final synonyms = entry.synonyms.isEmpty ? "" : localizations.trainingSynonyms(entry.synonyms);
  final antonyms = entry.antonyms.isEmpty ? "" : localizations.trainingAntonyms(entry.antonyms);
  return [synonyms, antonyms].where((element) => element.isNotEmpty).join("\n");
}
