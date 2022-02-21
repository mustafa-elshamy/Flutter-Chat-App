part of 'chat_room_bloc.dart';

@immutable
abstract class ChatRoomEvent {}

class ChatRoomLogoutEvent extends ChatRoomEvent {}

class SyncChatRoomEvent extends ChatRoomEvent {
  final String email;

  SyncChatRoomEvent({this.email});
}

class LoadChatsEvent extends ChatRoomEvent {}

class OpenChatEvent extends ChatRoomEvent {
  final ChatUser currentUser;
  final ChatUser chatUser;
  final String chatRoomId;

  OpenChatEvent({this.currentUser, this.chatUser, this.chatRoomId});
}
