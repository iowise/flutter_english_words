import 'package:flutter/material.dart';
import '../models/WordEntryRepository.dart';

class ReviewButton extends StatelessWidget {
  final List<WordEntry> wordsToReview;

  const ReviewButton({Key key, this.wordsToReview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      child: Text("${wordsToReview?.length} words to review"),
      onPressed: () {
        if (wordsToReview.isNotEmpty) {
          Navigator.pushNamed(context, '/train', arguments: wordsToReview);
        }
      }
    );
  }
}
