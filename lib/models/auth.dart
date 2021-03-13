import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signIn() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final OAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}


class UserChanged extends ChangeNotifier {
  final stream = FirebaseAuth.instance.userChanges();
  User? get user => FirebaseAuth.instance.currentUser;

  UserChanged() {
    stream.listen((event) {
      notifyListeners();
    });
  }
}
