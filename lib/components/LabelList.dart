import 'package:flutter/material.dart';
import '../models/blocs/WordEntryCubit.dart';

class LabelList extends StatelessWidget {
  final void Function(LabelWithStatistic label) showWords;

  LabelList({Key? key, required this.labelStatistic, required this.showWords})
      : super(key: key);

  final LabelsStatistic labelStatistic;

  @override
  Widget build(BuildContext context) {
    if (labelStatistic.length == 0) {
      return Center(child: Text("Inbox"));
    }
    final labelStatisticList = sortLabels(labelStatistic);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      shrinkWrap: true,
      itemBuilder: (context, i) {
        // if (i.isOdd) return Divider();

        // final index = i ~/ 2;
        return _buildRow(labelStatisticList[i], context);
      },
      itemCount: labelStatistic.length, //* 2 - 1,
    );
  }

  Widget _buildRow(LabelWithStatistic row, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(row.labelText),
        trailing: Text("${row.toLearn} / ${row.total}"),
        onTap: () => this.showWords(row),
      ),
    );
  }
}

List<LabelWithStatistic> sortLabels(LabelsStatistic labels) {
  final labelStatisticList = List<LabelWithStatistic>.from(labels);
  labelStatisticList.sort((a, b) {
    if (a.label == "" && b.label != "") return -1;
    if (a.label != "" && b.label == "") return 1;
    return a.label.compareTo(b.label);
  });
  return labelStatisticList;
}
