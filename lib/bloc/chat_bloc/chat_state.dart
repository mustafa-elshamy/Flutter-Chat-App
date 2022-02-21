part of 'chat_bloc.dart';

@immutable
abstract class ChatState {}

class ChatInitialState extends ChatState {}

class SuccessfulSendState extends ChatState {}
class UnsuccessfulSendState extends ChatState{
  final String message;

  UnsuccessfulSendState({this.message});
}

class ChatLoadedState extends ChatState{}