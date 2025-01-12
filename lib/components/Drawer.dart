import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../models/auth.dart';

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
                    return user == null
                        ? Text('Sign in')
                        : SignedInHeader(user: user);
                  },
                ),
                onTap: () => signIn(),
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

class SignedInHeader extends StatelessWidget {
  final User user;
  SignedInHeader({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(user.email!),
        OutlinedButton(
          child: Text("LogOut"),
          onPressed: () => signOut(),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
        )
      ],
    );
  }
}
