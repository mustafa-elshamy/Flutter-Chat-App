import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../data/model/chat_item.dart';
import '../../data/model/user.dart';
import '../../data/repos/database_repo.dart';

part 'chat_room_event.dart';
part 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  DatabaseRepo _databaseRepo = DatabaseRepo();
  var chatsStream;

  ChatRoomBloc() : super(ChatRoomInitialState()) {
    on<ChatRoomEvent>((event, emit) async {
      if (event is ChatRoomLogoutEvent) {
        emit(ChatRoomLogoutState());
      } else if (event is SyncChatRoomEvent) {
        if (Firebase.apps.isEmpty) await _initializeFirebase();
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

  Future _initializeFirebase() async {
    return await Firebase.initializeApp();
  }

  Future _linkStream(String email) async {
    await _databaseRepo.getChatRooms(email).then((value) {
      chatsStream = value;
    });
  }

  ChatItem getChatRoomItem(snapshot, index, email) {
    String chatUserEmail = (snapshot.data.docs[index].get("users")[0] == email)
        ? snapshot.data.docs[index].get("users")[1]
        : snapshot.data.docs[index].get("users")[0];

    return ChatItem.fromJson(snapshot.data.docs[index].data(), chatUserEmail);
  }
}
