import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/blocs/WordEntryCubit.dart';
import '../models/repositories/TrainLogRepository.dart';

class ToReviewPanel extends StatelessWidget {
  final List<LabelWithStatistic> labels;
  final List<TrainLog> todayTrained;
  final Function(LabelWithStatistic label) startTraining;
  final String strikes;

  const ToReviewPanel({
    Key? key,
    required this.labels,
    required this.strikes,
    required this.startTraining,
    required this.todayTrained,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  strikes,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.todayTrained(trainedStatistic(todayTrained)),
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ]),
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

String trainedStatistic(List<TrainLog> trained) {
  if (trained.length > 10) {
    return "${trained.length} 🎉";
  }
  return "${trained.length}";
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
          child: Text(label.labelText, maxLines: 3),
          onPressed: () => startTraining(label),
        ),
      ),
    );
  }
}
