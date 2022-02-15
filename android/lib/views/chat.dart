import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/chat_bloc/chat_bloc.dart';
import '../model/user.dart';
import '../services/database.dart';
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
  Database db = Database();

  var messagesStream;



  Widget _chatMessages() {
    return StreamBuilder(
      stream: messagesStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<List<dynamic>> data = [];
          for (int i = snapshot.data.docs.length - 1; i >= 0; i--) {
            data.add([
              snapshot.data.docs[i].get("message"),
              snapshot.data.docs[i].get("sentBy") == widget.currentUser.email
            ]);
          }
          return Expanded(
              child: ListView.builder(
                  controller: BlocProvider.of<ChatBloc>(context).listController,
                  reverse: true,
                  addAutomaticKeepAlives: false,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return _SingleMessage(data[index][0], data[index][1]);
                  }));
        } else {
          return Loading("");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context, widget.chatUser.username),
      body: Container(
        child: Column(
          children: [
            FutureBuilder(
                future: db
                    .getMessages(widget.chatRoomId)
                    .then((value) => messagesStream = value),
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? _chatMessages()
                      : Loading("Please wait...");
                }),
            SizedBox(
              height: 2,
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
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
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Message...",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none),
                      )),
                      SizedBox(
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
                            _sendMessage(messageTextController.text);
                            messageTextController.text = "";
                          },
                          child: Icon(
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
      ),
    );
  }
}

class _SingleMessage extends StatelessWidget {
  final String _message;
  final bool _isMyMessage;

  _SingleMessage(this._message, this._isMyMessage);

  String _wrapMessage(context) {
    List<String> words = _message.split(' ');
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          _isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(6),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment:
              _isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
              color: _isMyMessage ? Colors.blue : Colors.white24,
              borderRadius: _isMyMessage
                  ? BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12))
                  : BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12))),
          child: Text(
            _wrapMessage(context),
            style: GoogleFonts.mcLaren(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
