part of 'data_bloc.dart';

@immutable
abstract class DataState {}

class InitialDataState extends DataState {}

class NavigateSwitchScreenState extends DataState {
  final bool isSignScreen;

  NavigateSwitchScreenState({this.isSignScreen});
}

class LogoutState extends DataState {}

class LoginInState extends DataState {
  final ChatUser currentUser;

  LoginInState({this.currentUser});

  Map<String, dynamic> toMap() {
    return {
      'currentUser': currentUser.toMap(),
    };
  }

  factory LoginInState.fromMap(Map<String, dynamic> map) {
    return LoginInState(
      currentUser: ChatUser.fromMap(map['currentUser']),
    );
  }

  String toJson() => json.encode(toMap());

  factory LoginInState.fromJson(String source) =>
      LoginInState.fromMap(json.decode(source));
}

class LoginErrorState extends DataState {
  final String errorMessage;
  final bool isSignInScreen;

  LoginErrorState({this.errorMessage, this.isSignInScreen});
}
