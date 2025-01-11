import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart' as provider;
import '../models/auth.dart';
import '../models/DB.dart';
import '../models/repositories/TrainLogRepository.dart';
import '../models/repositories/WordEntryRepository.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: provider.ChangeNotifierProvider(
              create: (context) => UserChanged(),
              child: ListTile(
                leading: Icon(Icons.account_circle),
                title: provider.Consumer<UserChanged>(
                  builder: (context, userChanged, child) {
                    final user = userChanged.user;
                    return user == null ? Text('Sign in') : Text(user.email!);
                  },
                ),
                onTap: () {
                  signIn();
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Sentence Training'),
            onTap: () => Navigator.pushNamed(context, '/train/sentence'),
          ),
        ],
      ),
    );
  }
}
