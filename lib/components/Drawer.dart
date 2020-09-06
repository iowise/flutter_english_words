import 'package:flutter/material.dart';
import 'package:flutter_app/models/DB.dart';
import 'package:flutter_app/models/TrainLogRepository.dart';
import 'package:flutter_app/models/WordEntryRepository.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../models/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key key,
  }) : super(key: key);

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
            child: ChangeNotifierProvider(
              create: (context) => UserChanged(),
              child: ListTile(
                leading: Icon(Icons.account_circle),
                title: Consumer<UserChanged>(
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
            leading: Icon(Icons.file_download),
            title: Text('Import'),
            onTap: () async {
              final wordEntryRepository = GetIt.I.get<WordEntryRepository>();
              final trainLogRepository = GetIt.I.get<TrainLogRepository>();
              await importDB(wordEntryRepository, trainLogRepository);
            },
          ),
        ],
      ),
    );
  }
}
