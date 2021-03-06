import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:word_trainer/components/LabelList.dart';
import 'package:word_trainer/components/ToReviewPanel.dart';
import '../components/Drawer.dart';
import '../models/SharedWords.dart';
import '../models/SpaceRepetitionScheduler.dart';
import '../models/repositories/WordEntryRepository.dart';
import '../models/blocs/WordEntryCubit.dart';

class LabelsPage extends StatefulWidget {
  @override
  _LabelsPageState createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  WordEntryRepository repository = GetIt.I.get<WordEntryRepository>();
  TrainService? trainRepository;

  @override
  void initState() {
    super.initState();
    GetIt.I.isReady<TrainService>().then((value) {
      setState(() {
        trainRepository = GetIt.I.get<TrainService>();
      });
      GetIt.I.getAsync<SharedWordsService>().then((value) => value.init());
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldWrapper = (w) => BlocProvider.value(
          value: GetIt.I.get<WordEntryCubit>(),
          child: w,
        );

    return scaffoldWrapper(
      Scaffold(
        appBar: AppBar(
          title: Text("Labels"),
        ),
        drawer: AppDrawer(),
        body: Center(
          child: _buildList(),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<WordEntryCubit, WordEntryListState>(
      builder: (context, state) {
        if (!state.isConfigured || trainRepository == null) {
          return CircularProgressIndicator();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildToReviewPanel(),
            Expanded(
              child: LabelList(
                labelStatistic: state.labelsStatistics,
                showWords: (row) => _showWords(row, context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToReviewPanel() {
    return BlocBuilder<WordEntryCubit, WordEntryListState>(
      builder: (context, state) {
        final labelsForReviewPanel =
            generateLabelsForReviewPanel(state.labelsStatistics);
        return ToReviewPanel(
            labels: labelsForReviewPanel,
            startTraining: (label) => _startTraining(label, context));
      },
    );
  }

  _showWords(LabelWithStatistic row, BuildContext context) {
    context.read<WordEntryCubit>().useLabel(row.label);

    Navigator.pushNamed(context, "/words/");
  }

  _startTraining(LabelWithStatistic row, BuildContext context) {
    final bloc = context.read<WordEntryCubit>();
    bloc.useLabel(row.label);
    final wordsToReview =
        trainRepository!.getToReviewToday(bloc.state.wordsToReview);

    Navigator.pushNamed(
      context,
      "/train/word/translation/",
      arguments: limitWordsToTrain(wordsToReview),
    );
  }
}

List<LabelWithStatistic> generateLabelsForReviewPanel(LabelsStatistic labels) {
  final labelStatisticList = List<LabelWithStatistic>.from(labels);
  labelStatisticList.sort((a, b) => -a.toLearn.compareTo(b.toLearn));
  return labelStatisticList.sublist(0, min(10, labelStatisticList.length));
}
