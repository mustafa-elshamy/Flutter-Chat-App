import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

import '../../data/repos/authentication_repo.dart';
import '../../data/repos/database_repo.dart';
import '../../helper/helper_functions.dart';
import '../../data/model/user.dart';
import '../../data/services/authentication.dart';

part 'data_event.dart';

part 'data_state.dart';

class DataBloc extends HydratedBloc<DataEvent, DataState> {
  AuthRepo _authRepo;
  final DatabaseRepo _databaseRepo = DatabaseRepo();

  DataBloc() : super(InitialDataState()) {
    print("state of super ${(state as LoginInState).currentUser.email}");
    on<DataEvent>((event, emit) async {
      print("data bloc event: $event");
      if (state != null) add(SignInEvent());
      if (event is CheckAlreadyLoginEvent) {
        var isLogin = await _trySignIn();
        if (isLogin is ChatUser) {
          emit(LoginInState(currentUser: isLogin));
        } else {
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
          //add(CheckAlreadyLoginEvent());
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
//    startWithSavedState();
  }

  Future _initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    return await Firebase.initializeApp()
        .then((value) => _authRepo = AuthRepo());
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
    await _authRepo.signInWithEmailAndPassword(email, pass).then((value) {
      authResult = value;
    });
    if (authResult is ChatUser) {
      await _saveData(authResult);
      return authResult;
    }
    return authResult;
  }

  /*
  * return Authentication Result
  * => String if Error Exist
  * => ChatUser if success sign up
  * */
  Future _signUp(String username, String email, String pass) async {
    var authResult;
    await _authRepo
        .signUpWithEmailAndPassword(username, email, pass)
        .then((value) => authResult = value);

    await _databaseRepo.uploadUserInfo(username, email);
    if (authResult is ChatUser) {
      await _saveData(authResult);
      return authResult;
    }
    return authResult;
  }

  /*
  * save ChatUser in shared preference
  * return ChatUser
  * */
  Future _saveData(ChatUser currentUser) async {
    await HelperFunctions.saveUserLoggedIn(true);
    await HelperFunctions.saveUserEmail(currentUser.email);
    await HelperFunctions.saveUserPassword(currentUser.password);
    await HelperFunctions.saveUserName(currentUser.username);
    return true;
  }

  Future _logOut() async {
    await _authRepo.signOut();
    await HelperFunctions.getUserLoggedOut();
    await HelperFunctions.removeUserName();
    await HelperFunctions.removeUserEMAIL();
    await HelperFunctions.removeUserPassword();
    return true;
  }

  @override
  DataState fromJson(Map<String, dynamic> json) {
    if (json.isNotEmpty) {
      print(json.toString());
      return LoginInState.fromMap(json);
    }
  }

  @override
  Map<String, dynamic> toJson(DataState state) {
    if (state is LoginInState) {
      print("state was Login >>>>>>>>>>>>>>>>>>>");
      return state.toMap();
    }
    print("state was not Login !!!!!!!!");
    return null;
  }

  void startWithSavedState() {
    if (state != null && state is LoginInState) {
      LoginInState loginInState = state;
      add(SignInEvent(
          email: loginInState.currentUser.email,
          password: loginInState.currentUser.password));
    }
  }
}
