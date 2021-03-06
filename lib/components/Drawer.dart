import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart' as provider;
import 'package:word_trainer/models/blocs/WordEntryCubit.dart';
import '../models/auth.dart';
import '../models/DB.dart';
import '../models/repositories/TrainLogRepository.dart';
import '../models/repositories/WordEntryRepository.dart';

class AppDrawer extends StatelessWidget {
  final LabelsStatistic allLabels;
  final String currentLabel;
  final Function(String) applyLabelFilter;

  const AppDrawer({
    Key key,
    @required this.allLabels,
    @required this.currentLabel,
    @required this.applyLabelFilter,
  }) : super(key: key);

  factory AppDrawer.empty() {
    return AppDrawer(
      allLabels: LabelsStatistic(List<LabelWithStatistic>.empty(growable: false)),
      currentLabel: null,
      applyLabelFilter: (string) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
            child: provider.ChangeNotifierProvider(
              create: (context) => UserChanged(),
              child: ListTile(
                leading: Icon(Icons.account_circle),
                title: provider.Consumer<UserChanged>(
                  builder: (context, userChanged, child) {
                    final user = userChanged.user;
                    return user == null ? Text('Sign in') : Text(user.email);
                  },
                ),
                onTap: () {
                  signIn();
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.file_upload),
            title: Text('Export'),
            onTap: () async {
              final wordEntryRepository = GetIt.I.get<WordEntryRepository>();
              final trainLogRepository = GetIt.I.get<TrainLogRepository>();
              await exportDB(wordEntryRepository, trainLogRepository);
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Sentence Training'),
            onTap: () => Navigator.pushNamed(context, '/train/sentence'),
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text('Word Inbox'),
            selected: currentLabel == null,
            onTap: () {
              applyLabelFilter(null);
              Navigator.pop(context);
            },
          ),
          ...allLabels.map(
            (e) => ListTile(
              leading: Icon(
                  e.label == currentLabel ? Icons.label : Icons.label_outline),
              title: Text(e.label),
              trailing: Text("${e.toLearn} / ${e.total}"),
              selected: e.label == currentLabel,
              onTap: () {
                applyLabelFilter(e.label);
                Navigator.pop(context);
              },
            ),
          ).toList()
        ],
      ),
    );
  }
}
