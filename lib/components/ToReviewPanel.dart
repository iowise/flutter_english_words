import 'package:flutter/material.dart';
import 'package:word_trainer/models/blocs/WordEntryCubit.dart';

class ToReviewPanel extends StatelessWidget {
  final List<LabelWithStatistic> labels;

  final Function(LabelWithStatistic label) startTraining;

  const ToReviewPanel({
    Key? key,
    required this.labels,
    required this.startTraining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text("Labels to train", textAlign: TextAlign.left),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
            child: Row(
              children: List<Widget>.from(
                this.labels.map((e) =>
                    ToReviewCard(label: e, startTraining: startTraining)),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ToReviewCard extends StatelessWidget {
  final LabelWithStatistic label;
  final Function(LabelWithStatistic label) startTraining;

  const ToReviewCard({
    Key? key,
    required this.startTraining,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: OutlinedButton(
          child: Text(
            label.labelText,
            maxLines: 3,
          ),
          onPressed: () => startTraining(label),
        ),
      ),
    );
  }
}
