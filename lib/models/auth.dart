import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  final OAuthCredential credential = GoogleAuthProvider.credential(
    // accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future<UserCredential> signInWithApple() async {
  final appleProvider = AppleAuthProvider();
  UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);
  return userCredential;
}

Future signOut() {
  return FirebaseAuth.instance.signOut();
}

class UserChanged extends ChangeNotifier {
  final stream = FirebaseAuth.instance.userChanges();
  User? get user => FirebaseAuth.instance.currentUser;

  UserChanged() {
    stream.listen((event) => notifyListeners());
  }
}
