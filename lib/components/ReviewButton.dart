import 'package:flutter/material.dart';
import '../models/SpaceRepetitionScheduler.dart';
import '../models/WordEntryRepository.dart';

class ReviewButton extends StatelessWidget {
  final List<WordEntry> wordsToReview;

  const ReviewButton({Key key, @required this.wordsToReview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      child: Text("Review ${wordsToTrain(wordsToReview)} of ${wordsToReview?.length} Words"),
      onPressed: () {
        if (wordsToReview.isNotEmpty) {
          Navigator.pushNamed(context, '/train/word', arguments: limitWordsToTrain(wordsToReview));
        }
      },
    );
  }
}
