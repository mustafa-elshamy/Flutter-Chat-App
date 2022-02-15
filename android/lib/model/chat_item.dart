class ChatItem {
  String chatUserName;
  String chatUserEmail;
  String chatRoomId;

  ChatItem.fromMap(map) {
    chatUserName = map["name"];
    chatUserEmail = map["email"];
    chatRoomId = map["chatRoomId"];
  }
}
