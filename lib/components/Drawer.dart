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
                onTap: () => showSignInMethodsBottomSheet(context),
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

  showSignInMethodsBottomSheet(BuildContext parentContext) {
    showModalBottomSheet<void>(
      context: parentContext,
      builder: (context) => SignInMethodBottomSheet(parentContext: parentContext),
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

typedef SignInMethod = ({String name, Function singinFunction});
const singInMethods = <SignInMethod>[
  (name: 'Sign-in with Google', singinFunction: signInWithGoogle),
  (name: 'Sign-in with Apple', singinFunction: signInWithApple),
];

class SignInMethodBottomSheet extends StatelessWidget {
  final BuildContext parentContext;

  const SignInMethodBottomSheet({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final signinButtons = List<Widget>.from(singInMethods.map((record) {
      return ElevatedButton(
        child: Text(record.name),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        onPressed: createSignIn(context, record),
      );
    }));

    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: signinButtons,
        ),
      ),
    );
  }

  createSignIn(BuildContext context, SignInMethod record) {
    return () async {
      Navigator.pop(context);
      try {
        await record.singinFunction();
      } catch (e) {
        _showErrorDialog();
      }
    };
  }

  Future<void> _showErrorDialog() {
    return showDialog<void>(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Got an error.'),
          content: const Text('Please try again.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('OK'),
              onPressed: () =>Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
