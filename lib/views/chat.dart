import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/chat_bloc/chat_bloc.dart';
import '../data/model/message.dart';
import '../data/model/user.dart';
import '../widgets/widget.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;
  final ChatUser currentUser;
  final ChatUser chatUser;

  Chat(this.chatRoomId, this.currentUser, this.chatUser);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Widget _chatMessages() {
    return StreamBuilder(
      stream: BlocProvider.of<ChatBloc>(context).messagesStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<dynamic> messages = BlocProvider.of<ChatBloc>(context)
              .getChatMessages(snapshot, widget.currentUser.email);
          return Expanded(
              child: ListView.builder(
                  controller: BlocProvider.of<ChatBloc>(context).listController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return messages[index] is ChatMessage
                        ? _SingleMessage(chatMessage: messages[index])
                        : dayWidget(context, messages[index]);
                  }));
        } else {
          return Loading("Please wait");
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(context)
        .add(SyncChatsEvent(chatRoomId: widget.chatRoomId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context, widget.chatUser.username),
      body: Column(
        children: [
          BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
            if (state is ChatInitialState) {
              return Loading("Downloading your chats");
            }
            return _chatMessages();
          }),
          const SizedBox(
            height: 2,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24)),
                    color: Colors.grey),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: BlocProvider.of<ChatBloc>(context)
                          .messageTextController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Message...",
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none),
                    )),
                    const SizedBox(
                      width: 40,
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.grey.shade600,
                            Colors.grey.shade800
                          ]),
                          borderRadius: BorderRadius.circular(20)),
                      child: GestureDetector(
                        onTap: () {
                          BlocProvider.of<ChatBloc>(context).add(
                              SendMessageEvent(
                                  chatRoomId: widget.chatRoomId,
                                  currentUserEmail: widget.currentUser.email));
                        },
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class _SingleMessage extends StatelessWidget {
  final ChatMessage chatMessage;

  _SingleMessage({this.chatMessage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: chatMessage.isSentByMe
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: chatMessage.isFirstFromMe? 12:2,left: 8,right: 8,bottom: 2),
          padding: const EdgeInsets.only(top: 8, bottom: 4, right: 8, left: 8),
          alignment: chatMessage.isSentByMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
          decoration: BoxDecoration(
              color: chatMessage.isSentByMe ? Colors.blue : Colors.white24,
              borderRadius: chatMessage.isSentByMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: chatMessage.isFirstFromMe
                          ? Radius.circular(0)
                          : Radius.circular(12))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                      topLeft: chatMessage.isFirstFromMe
                          ? Radius.circular(0)
                          : Radius.circular(12))),
          child: Column(
            crossAxisAlignment: chatMessage.isSentByMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  BlocProvider.of<ChatBloc>(context)
                      .wrapMessage(context, chatMessage.message),
                  style: GoogleFonts.mcLaren(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    chatMessage.timeHour,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
