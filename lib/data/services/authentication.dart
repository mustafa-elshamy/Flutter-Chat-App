import 'package:firebase_auth/firebase_auth.dart';

import '../model/user.dart';

class Authenticate {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future signInWithEmailAndPassword(String email, String pass) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: pass);
      User firebaseUser = userCredential.user;
      return firebaseUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "Email does not exist, please sign up";
      }
      if (e.code == "wrong-password") {
        return "Incorrect password";
      }
      return e.code;
    }
  }

  Future signUpWithEmailAndPassword(String email, String pass) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: pass);
      User firebaseUser = userCredential.user;
      return firebaseUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "Email already in use, please sign in";
      }
      return e.code;
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print("Reset password error error: ${e.message}");
      return e.code;
    }
  }

  Future signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      print("Sign out error: ${e.message}");
      return e.code;
    }
  }
}
