import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../data/model/chat_item.dart';
import '../../data/model/user.dart';
import '../../data/repos/database_repo.dart';
import '../../data/services/database.dart';
import '../data_bloc/data_bloc.dart';

part 'chat_room_event.dart';

part 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final DatabaseRepo _databaseRepo = DatabaseRepo();
  var chatsStream;

  ChatRoomBloc() : super(ChatRoomInitialState()) {
    on<ChatRoomEvent>((event, emit) async {
      if (event is ChatRoomLogoutEvent) {
        emit(ChatRoomLogoutState());
      } else if (event is SyncChatRoomEvent) {
        await _linkStream(event.email);
        add(LoadChatsEvent());
      } else if (event is LoadChatsEvent) {
        emit(ChatsLoadedState());
      } else if (event is OpenChatEvent) {
        emit(OpenChatSate(
            currentUser: event.currentUser,
            chatUser: event.chatUser,
            chatRoomId: event.chatRoomId));
      }
    });
  }

  Future _linkStream(String email) async {
    await _databaseRepo.getChatRooms(email).then((value) => chatsStream = value);
  }

  ChatItem getChatRoomItem(snapshot, index, email) {
    String chatUserEmail = (snapshot.data.docs[index].get("users")[0] == email)
        ? snapshot.data.docs[index].get("users")[1]
        : snapshot.data.docs[index].get("users")[0];

    return ChatItem.fromJson(snapshot.data.docs[index].data(), chatUserEmail);
  }
}
