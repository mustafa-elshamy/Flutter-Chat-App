part of 'data_bloc.dart';

@immutable
abstract class DataEvent {}

class CheckAlreadyLoginEvent extends DataEvent {}

class InitializeFirebase extends DataEvent {}

class NavigateSwitchScreenEvent extends DataEvent {
  final bool isSignIn;

  NavigateSwitchScreenEvent({this.isSignIn});
}

class SignInEvent extends DataEvent {
  final String email;
  final String password;

  SignInEvent({this.email, this.password});
}

class SignUpEvent extends DataEvent {
  final String username;
  final String email;
  final String password;

  SignUpEvent({this.username, this.email, this.password});
}

class LogoutEvent extends DataEvent {}
