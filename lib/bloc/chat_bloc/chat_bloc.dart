import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

import '../../data/model/message.dart';
import '../../data/repos/database_repo.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final DatabaseRepo _databaseRepo = DatabaseRepo();
  ScrollController listController = ScrollController();
  TextEditingController messageTextController = TextEditingController();

  var messagesStream;

  ChatBloc() : super(ChatInitialState()) {
    on<ChatEvent>((event, emit) async {
      // Sync Chats
      if (event is SyncChatsEvent) {
        await _linkChatStream(event.chatRoomId);
        emit(ChatLoadedState());
      }

      // Send Message
      else if (event is SendMessageEvent) {
        if (messageTextController.text.isNotEmpty) {
          try {
            await _databaseRepo.addMessage(event.chatRoomId,
                messageTextController.text, event.currentUserEmail);
            messageTextController.text = "";
            emit(SuccessfulSendState());
          } catch (e) {
            emit(UnsuccessfulSendState(message: e.message));
          }
        }
      }

      //
    });
  }

  Future _linkChatStream(String chatRoomId) async {
    return await _databaseRepo.getMessages(chatRoomId).then((value) {
      messagesStream = value;
    });
  }

  List<dynamic> getChatMessages(snapshot, String currentUserEmail) {
    List<ChatMessage> messages = [];
    for (int i = snapshot.data.docs.length - 1; i >= 0; i--) {
      messages
          .add(ChatMessage.fromJson(snapshot.data.docs[i], currentUserEmail));
    }
    return groupMessages(messages);
  }

  // groupMessages(List<ChatMessage> messages) {
  //   _convertedMessages = [];
  //   DateTime day = DateTime(messages[0].dateTime.year,
  //       messages[0].dateTime.month, messages[0].dateTime.day, 0, 0);
  //   DateTime today = DateTime(
  //       DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
  //   int lastDiff = today.difference(day).inDays;
  //   for (int i = 0; i < messages.length; i++) {
  //     DateTime day = DateTime(messages[i].dateTime.year,
  //         messages[i].dateTime.month, messages[i].dateTime.day, 0, 0);
  //     int diff = today.difference(day).inDays;
  //     String label = "";
  //     print("${lastDiff} - ${diff}");
  //     if (diff != lastDiff) {
  //       if (lastDiff >= 7) {
  //         label = "${day.day} / ${day.month} / ${day.year}";
  //       } else if (lastDiff == 0) {
  //         label = "Today";
  //       } else if (lastDiff == 1) {
  //         label = "Yesterday";
  //       } else {
  //         label = DateFormat('EEEE').format(day);
  //       }
  //       lastDiff = diff;
  //     }
  //     _convertedMessages.add(messages[i]);
  //     if (label.isNotEmpty) _convertedMessages.add(label);
  //   }
  // }

  List<dynamic> groupMessages(List<ChatMessage> messages) {
    Map<DateTime, List<ChatMessage>> chatsMap = {};
    for (int i = 0; i < messages.length; i++) {
      int year = messages[i].dateTime == null ? 0 : messages[i].dateTime.year;
      int month = messages[i].dateTime == null ? 0 : messages[i].dateTime.month;
      int day = messages[i].dateTime == null ? 0 : messages[i].dateTime.day;
      DateTime messageDay = DateTime(year, month, day, 0, 0);
      if (!chatsMap.containsKey(messageDay)) {
        chatsMap[messageDay] = [];
      }
      chatsMap[messageDay].add(messages[i]);
    }
    DateTime today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);
    List<dynamic> groupedMessages = [];
    chatsMap.forEach((key, value) {
      int diff = today.difference(key).inDays;
      String label;
      if (diff >= 7) {
        label = "${key.day} / ${key.month} / ${key.year}";
      } else if (diff == 0) {
        label = "Today";
      } else if (diff == 1) {
        label = "Yesterday";
      } else {
        label = DateFormat('EEEE').format(key);
      }
      value[value.length - 1].isFirstFromMe = true;
      for (int i = value.length - 2; i >= 0; i--) {
        value[i].isFirstFromMe = value[i].isSentByMe != value[i+1].isSentByMe;
      }
      groupedMessages.addAll(value);
      groupedMessages.add(label);
    });
    return groupedMessages;
  }

  String wrapMessage(context, String message) {
    List<String> words = message.split(' ');
    int maxChars = (0.06 * MediaQuery.of(context).size.width).floor();
    String wrappedMessage = "", line = "";
    for (int i = 0; i < words.length; i++) {
      if (words[i].length + line.length <= maxChars) {
        line += words[i] + " ";
      } else {
        if (words[i].length < maxChars) {
          wrappedMessage += line + "\n";
          line = words[i];
        } else {
          String subWord1 = words[i].substring(0, maxChars - 1);
          String subWord2 = words[i].substring(maxChars);
          words.insert(i + 1, subWord2);
          words.insert(i + 1, subWord1);
        }
      }
    }
    wrappedMessage += line;
    return wrappedMessage;
  }
}
