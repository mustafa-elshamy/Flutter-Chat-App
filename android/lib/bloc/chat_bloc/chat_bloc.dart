import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../services/database.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ScrollController listController = ScrollController();
  TextEditingController messageTextController = TextEditingController();

  Database db = Database();

  ChatBloc() : super(ChatInitial()) {
    on<ChatEvent>((event, emit) {});
  }

  void _sendMessage(String message) {
    db.addMessage(widget.chatRoomId, message, widget.currentUser.email);
  }
}
