part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String currentUserEmail;
  final String chatRoomId;

  SendMessageEvent({this.currentUserEmail, this.chatRoomId});
}

class SyncChatsEvent extends ChatEvent {
  final String chatRoomId;

  SyncChatsEvent({@required this.chatRoomId});
}
