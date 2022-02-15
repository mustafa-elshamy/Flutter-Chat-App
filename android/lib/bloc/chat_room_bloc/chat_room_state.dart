part of 'chat_room_bloc.dart';

@immutable
abstract class ChatRoomState {}

class ChatRoomInitialState extends ChatRoomState {}

class ChatRoomLogoutState extends ChatRoomState {}

class ChatsLoadedState extends ChatRoomState {}

class OpenChatSate extends ChatRoomState {
  final ChatUser currentUser;
  final ChatUser chatUser;
  final String chatRoomId;

  OpenChatSate({this.currentUser, this.chatUser, this.chatRoomId});
}
