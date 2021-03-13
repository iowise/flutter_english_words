import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SplashScreen extends StatelessWidget {
  final Widget Function() builder;

  SplashScreen({
    Key? key,
    required this.builder,
  });

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setup(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) return builder();
        return ColoredBox(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<bool> setup() async {
    await GetIt.I.getAsync<FirebaseApp>();
    return true;
  }
}
