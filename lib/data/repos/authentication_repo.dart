import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/user.dart';
import '../services/authentication.dart';
import '../services/database.dart';

class AuthRepo {
  Authenticate _authenticate = Authenticate();
  Database _database = Database();

  Future signInWithEmailAndPassword(String email, String pass) async {
    var authRes = await _authenticate.signInWithEmailAndPassword(email, pass);
    QuerySnapshot querySnapshot = await _database.getUserInfoByEMail(email);
    String username = querySnapshot.docs[0].get("name");
    if (authRes is User) {
      return ChatUser(username: username, email: email, password: pass);
    }
    return authRes;
  }

  Future signUpWithEmailAndPassword(
      String username, String email, String pass) async {
    var authRes = await _authenticate.signUpWithEmailAndPassword(email, pass);
    if (authRes is User) {
      return ChatUser(username: username, email: email, password: pass);
    }
    return authRes;
  }

  Future resetPassword(String email) async {
    return await _authenticate.resetPassword(email);
  }

  Future signOut() async {
    return await _authenticate.signOut();
  }
}
