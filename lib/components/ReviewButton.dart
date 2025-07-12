import 'package:flutter/material.dart';
import 'package:word_trainer/l10n/app_localizations.dart';
import '../models/SpaceRepetitionScheduler.dart';
import '../models/repositories/WordEntryRepository.dart';

class ReviewButton extends StatelessWidget {
  final List<WordEntry> wordsToReview;

  const ReviewButton({Key? key, required this.wordsToReview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: OutlinedButton(
            child: Text(AppLocalizations.of(context)!.reviewNofMWords(
              wordsToTrain(wordsToReview), wordsToReview.length,
            )),
            onPressed: () {
              pushTrainingScreen(context, '/train/word/translation/', wordsToReview);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: OutlinedButton(
            child: Text(AppLocalizations.of(context)!.definitionsTraining),
            onPressed: () {
              final withDefinitions = wordsToReview.where((element) => element.definition.isNotEmpty).toList();
              pushTrainingScreen(context, '/train/word/definition/', withDefinitions);
            },
          ),
        ),
      ],
    );
  }

  void pushTrainingScreen(BuildContext context, String path, List<WordEntry> words) {
    if (words.isNotEmpty) {
      Navigator.pushNamed(context, path, arguments: limitWordsToTrain(words));
    }
  }
}
