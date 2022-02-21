import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_room_bloc/chat_room_bloc.dart';
import '../bloc/data_bloc/data_bloc.dart';
import '../data/model/chat_item.dart';
import '../data/model/user.dart';
import '../data/services/database.dart';
import '../widgets/widget.dart';
import 'chat.dart';
import 'search_page.dart';
import 'switch_page.dart';

class ChatRoom extends StatefulWidget {
  final ChatUser currentUser;

  ChatRoom(this.currentUser);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  void initState() {
    super.initState();

    BlocProvider.of<ChatRoomBloc>(context)
        .add(SyncChatRoomEvent(email: widget.currentUser.email));
  }

  Widget _chatList() {
    return StreamBuilder(
        stream: BlocProvider.of<ChatRoomBloc>(context).chatsStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                padding: EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  ChatItem chatItem = BlocProvider.of<ChatRoomBloc>(context)
                      .getChatRoomItem(
                          snapshot, index, widget.currentUser.email);
                  return ChatCard(
                      widget.currentUser,
                      ChatUser(
                          username: chatItem.chatUserName,
                          email: chatItem.chatUserEmail),
                      chatItem.chatRoomId);
                });
          }
          return Loading("Loading your chats...");
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatRoomBloc, ChatRoomState>(
      listener: (context, state) {
        if (state is ChatRoomLogoutState) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SwitchPage()));
        } else if (state is OpenChatSate) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Chat(
                      state.chatRoomId, state.currentUser, state.chatUser)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Chats"),
            actions: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                      onTap: () {
                        BlocProvider.of<ChatRoomBloc>(context)
                            .add(ChatRoomLogoutEvent());
                        BlocProvider.of<DataBloc>(context).add(LogoutEvent());
                      },
                      child: Icon(Icons.logout_rounded)))
            ],
          ),
          body: BlocConsumer<ChatRoomBloc, ChatRoomState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is ChatRoomInitialState) {
                  return Loading("Loading your chats");
                } else {
                  // ChatsLoadedState
                  return _chatList();
                }
              }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchPage(widget.currentUser)));
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue,
          ),
        );
      },
    );
  }
}

class ChatCard extends StatelessWidget {
  final String _chatRoomId;
  final ChatUser _chatUser;
  final ChatUser _currentUser;

  ChatCard(this._currentUser, this._chatUser, this._chatRoomId);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<ChatRoomBloc>(context).add(OpenChatEvent(
            currentUser: _currentUser,
            chatUser: _chatUser,
            chatRoomId: _chatRoomId));
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.blue),
          child: Row(
            children: [
              const Icon(
                Icons.person,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(
                width: 14,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_chatUser.username,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(_chatUser.email,
                      style: TextStyle(color: Colors.white, fontSize: 12))
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.grey.shade600, Colors.grey.shade800]),
                    borderRadius: BorderRadius.circular(20)),
                child: const Icon(
                  Icons.messenger_outlined,
                  color: Colors.white,
                ),
              )
            ],
          )),
    );
  }
}
