import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn _googleSignIn = new GoogleSignIn();

Future<FirebaseUser> _googleUserToFirebaseUser(GoogleSignInAccount a) async {
  final GoogleSignInAuthentication googleAuth = await a.authentication;
  return await FirebaseAuth.instance.signInWithGoogle(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
}

Future<FirebaseUser> getCurrentUser() async {
  final firebaseUser = await FirebaseAuth.instance.currentUser();
  if (firebaseUser != null) {
    return firebaseUser;
  }

  final googleUser = await _googleSignIn.signInSilently();
  if (googleUser == null) {
    return null;
  }
  return _googleUserToFirebaseUser(googleUser);
}

Future<FirebaseUser> signInGoogleUser() async {
  final googleUser = await _googleSignIn.signIn();
  if (googleUser == null) {
    return null;
  }
  return _googleUserToFirebaseUser(googleUser);
}

Future<Null> signOut() async {
  await _googleSignIn.signOut();
  await FirebaseAuth.instance.signOut();
}