part of 'data_bloc.dart';

@immutable
abstract class DataState {}

class InitialDataState extends DataState {}

class NavigateSwitchScreenState extends DataState {
  final bool isSignScreen;

  NavigateSwitchScreenState({this.isSignScreen});
}

class LoadingState extends DataState {
  final bool isLogout;

  LoadingState({this.isLogout});
}

class LogoutState extends DataState {}

class LoginInState extends DataState {
  final ChatUser currentUser;

  LoginInState({this.currentUser});
}

class LoginErrorState extends DataState {
  final String errorMessage;
  final bool isSignInScreen;

  LoginErrorState({this.errorMessage, this.isSignInScreen});
}
