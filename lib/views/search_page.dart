import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../data/model/user.dart';
import '../data/services/database.dart';
import '../widgets/widget.dart';
import 'chat.dart';

class SearchPage extends StatefulWidget {
  final ChatUser currentUser;

  SearchPage(this.currentUser);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController usernameTextControl = TextEditingController();

  Database db = Database();
  var querySnapshot;

  Widget _searchList() {
    return querySnapshot != null
        ? (querySnapshot.docs.length == 0 ||
                (querySnapshot.docs.length == 1 &&
                    querySnapshot.docs[0].get("email").toString() ==
                        widget.currentUser.email))
            ? Container(
                child: Center(
                  child: Text("No users found",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: querySnapshot.docs.length,
                itemBuilder: (context, index) {
                  return (querySnapshot.docs[index].get("email").toString() ==
                          widget.currentUser.email)
                      ? Container()
                      : UserItem(
                          widget.currentUser,
                          ChatUser(
                            username: querySnapshot.docs[index]
                                .get("name")
                                .toString(),
                            email: querySnapshot.docs[index]
                                .get("email")
                                .toString(),
                          ));
                })
        : Container();
  }

  void _search() {
    db.getUserInfoByName(usernameTextControl.text).then((value) {
      setState(() {
        querySnapshot = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context, "Find User"),
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24)),
                  color: Colors.grey),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: usernameTextControl,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: "Search by username...",
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
                        _search();
                      },
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )),
          Expanded(child: _searchList())
        ],
      ),
    );
  }
}

class UserItem extends StatelessWidget {
  final ChatUser _currentUser;
  final ChatUser _chatUser;

  String chatRoomId = "";

  Database db = Database();

  UserItem(this._currentUser, this._chatUser);

  Future _startChat() async {
    List<String> users = [_currentUser.email, _chatUser.email];
    chatRoomId = _createChatRoomId(_currentUser.email, _chatUser.email);
    QuerySnapshot snapshot = await db.getChatRoom(chatRoomId);
    if (snapshot.size == 0) {
      await db.createChatRoom(chatRoomId, users, _currentUser, _chatUser);
    }
    return true;
  }

  String _createChatRoomId(String email1, String email2) {
    if (email1.length < email2.length) {
      return "${email1}_$email2";
    } else if (email1.length > email2.length) {
      return "${email2}_$email1";
    }
    for (int i = 0; i < email1.length; i++) {
      if (email1.codeUnits[i] < email2.codeUnits[i]) {
        return "${email1}_$email2";
      } else if (email1.codeUnits[i] > email2.codeUnits[i]) {
        return "${email2}_$email1";
      }
    }
    return "impossible";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.blue),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_chatUser.username,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 4,
                ),
                Text(_chatUser.email,
                    style: TextStyle(color: Colors.white, fontSize: 12))
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return FutureBuilder(
                      future: _startChat(),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? Chat(chatRoomId, _currentUser, _chatUser)
                            : Loading("");
                      });
                }));
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.grey.shade600, Colors.grey.shade800]),
                    borderRadius: BorderRadius.circular(20)),
                child: Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ));
  }
}
