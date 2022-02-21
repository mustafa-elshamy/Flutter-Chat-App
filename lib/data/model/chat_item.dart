class ChatItem {
  String chatUserName;
  String chatUserEmail;
  String chatRoomId;

  ChatItem.fromJson(Map<String, dynamic> map, String email) {
    chatUserName = map[email]["name"];
    chatUserEmail = map[email]["email"];
    chatRoomId = map["chatRoomId"];
  }
}
