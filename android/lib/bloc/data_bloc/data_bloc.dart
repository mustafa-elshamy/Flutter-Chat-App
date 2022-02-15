import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../helper/helper_functions.dart';
import '../../model/user.dart';
import '../../services/authentication.dart';
import '../../services/database.dart';
import '../chat_room_bloc/chat_room_bloc.dart';

part 'data_event.dart';

part 'data_state.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  Authenticate _authenticate;
  final Database _db = Database();
  final ChatRoomBloc _chatRoomBloc = ChatRoomBloc();
  StreamSubscription _chatRoomBlocStream;

  DataBloc() : super(InitialDataState()) {
    on<DataEvent>((event, emit) async {
      print("data bloc event: $event");
      if (event is CheckAlreadyLoginEvent) {
        var isLogin = await _trySignIn();
        if (isLogin is ChatUser) {
          emit(LoginInState(currentUser: isLogin));
        } else {
          print("logout state");
          emit(LogoutState());
        }
      }

      // SignIn event
      else if (event is SignInEvent) {
        var sigInRes = await _signIn(event.email, event.password);
        if (sigInRes is ChatUser) {
          emit(LoginInState(currentUser: sigInRes));
        } else {
          emit(LoginErrorState(
              errorMessage: sigInRes as String, isSignInScreen: true));
        }
      }

      // SignUp event
      else if (event is SignUpEvent) {
        var signUpRes =
            await _signUp(event.username, event.email, event.password);
        if (signUpRes is ChatUser) {
          emit(LoginInState(currentUser: signUpRes));
        } else {
          emit(LoginErrorState(errorMessage: signUpRes, isSignInScreen: false));
        }
      }

      // Initialize Firebase event
      else if (event is InitializeFirebase) {
        await _initializeFirebase().then((value) {
          emit(LogoutState());
          add(CheckAlreadyLoginEvent());
        });
      }

      // Navigate between SignIn and signUp event
      else if (event is NavigateSwitchScreenEvent) {
        emit(NavigateSwitchScreenState(isSignScreen: event.isSignIn));
      }

      // Logout event
      else if (event is LogoutEvent) {
        await _logOut();
        emit(LogoutState());
      }
    });
  }

  Future _initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    return await Firebase.initializeApp()
        .then((value) => _authenticate = Authenticate());
  }

  Future _trySignIn() async {
    bool isSignedIn = await HelperFunctions.getUserLoggedIn();
    if (isSignedIn != null) {
      String username = await HelperFunctions.getUserName();
      String email = await HelperFunctions.getUserEMAIL();
      String password = await HelperFunctions.getUserPassword();
      return (username != null && email != null && password != null)
          ? ChatUser(username: username, email: email, password: password)
          : false;
    }
    return false;
  }

  /*
  * return Authentication Result
  * => String if Error Exist
  * => ChatUser if success sign in
  * */
  Future _signIn(String email, String pass) async {
    var authResult;
    await _authenticate.signInWithEmailAndPassword(email, pass).then((value) {
      authResult = value;
    });
    return authResult is ChatUser
        ? await _saveData(null, email, pass)
        : authResult;
  }

  /*
  * return Authentication Result
  * => String if Error Exist
  * => ChatUser if success sign up
  * */
  Future _signUp(String username, String email, String pass) async {
    var authResult;
    await _authenticate
        .signUpWithEmailAndPassword(email, pass)
        .then((value) => authResult = value);

    _db.uploadUserInfo(username, email);
    return authResult is ChatUser
        ? await _saveData(username, email, pass)
        : authResult;
  }

  /*
  * save ChatUser in shared preference
  * return ChatUser
  * */
  Future<ChatUser> _saveData(String username, String email, String pass) async {
    HelperFunctions.saveUserLoggedIn(true);
    HelperFunctions.saveUserEmail(email);
    HelperFunctions.saveUserPassword(pass);

    if (username == null) {
      QuerySnapshot querySnapshot = await _db.getUserInfoByEMail(email);
      username = querySnapshot.docs[0].get("name");
    }
    HelperFunctions.saveUserName(username);
    return ChatUser(username: username, email: email, password: pass);
  }

  Future _logOut() async {
    await _authenticate.signOut();
    await HelperFunctions.getUserLoggedOut();
    await HelperFunctions.removeUserName();
    await HelperFunctions.removeUserEMAIL();
    await HelperFunctions.removeUserPassword();
    return true;
  }
}
