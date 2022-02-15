import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user.dart';

class Database {
  final String _usersCollection = "users";
  final String _chatRoomCollection = "chatRoom";
  final String _chatsCollection = "chats";

  // create map from username and email
  Map<String, String> _mapUser(String username, String email) =>
      {"name": username, "email": email};

  Map<String, dynamic> _mapChatRoom(String chatRoomId, List<String> users,
          ChatUser currentUser, ChatUser chatUser) =>
      {
        "chatRoomId": chatRoomId,
        "users": users,
        currentUser.email: _mapUser(currentUser.username, currentUser.email),
        chatUser.email: _mapUser(chatUser.username, chatUser.email)
      };

  Map<String, String> _mapMessage(String message, String sentBy) => {
        "message": message,
        "sentBy": sentBy,
        "time": DateTime.now().microsecondsSinceEpoch.toString()
      };

  uploadUserInfo(String username, String email) {
    FirebaseFirestore.instance
        .collection(_usersCollection)
        .add(_mapUser(username, email));
  }

  Future getUserInfoByName(String username) async {
    return await FirebaseFirestore.instance
        .collection(_usersCollection)
        .where("name", isEqualTo: username)
        .get();
  }

  Future getUserInfoByEMail(String userEmail) async {
    return await FirebaseFirestore.instance
        .collection(_usersCollection)
        .where("email", isEqualTo: userEmail)
        .get();
  }

  Future createChatRoom(String chatRoomId, List<String> users,
      ChatUser currentUser, ChatUser chatUser) async {
    return await FirebaseFirestore.instance
        .collection(_chatRoomCollection)
        .doc(chatRoomId)
        .set(_mapChatRoom(chatRoomId, users, currentUser, chatUser));
  }

  Future getChatRoom(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection(_chatRoomCollection)
        .where("chatRoomId", isEqualTo: chatRoomId)
        .get();
  }

  Future addMessage(String chatRoomId, String message, String sentBy) async {
    return await FirebaseFirestore.instance
        .collection(_chatRoomCollection)
        .doc(chatRoomId)
        .collection(_chatsCollection)
        .add(_mapMessage(message, sentBy));
  }

  Future getMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection(_chatRoomCollection)
        .doc(chatRoomId)
        .collection(_chatsCollection)
        .orderBy("time", descending: false)
        .snapshots();
  }

  Future getChatRooms(String email) async {
    return FirebaseFirestore.instance
        .collection(_chatRoomCollection)
        .where("users", arrayContains: email)
        .snapshots();
  }
}
