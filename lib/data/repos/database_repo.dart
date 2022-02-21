import '../model/chat_item.dart';
import '../model/user.dart';
import '../services/database.dart';

class DatabaseRepo {
  Database _database = Database();

  Future uploadUserInfo(String username, String email) async {
    return await _database.uploadUserInfo(username, email);
  }

  Future getUserInfoByName(String username) async {
    Map<String, dynamic> databaseRes =
        _database.getUserInfoByName(username) as Map<String, dynamic>;
    return ChatUser(
        username: databaseRes["name"],
        email: databaseRes["email"],
        password: null);
  }

  Future getUserInfoByEMail(String userEmail) async {
    Map<String, dynamic> databaseRes =
        await _database.getUserInfoByEMail(userEmail);
    return ChatUser(
        username: databaseRes["name"],
        email: databaseRes["email"],
        password: null);
  }

  Future createChatRoom(String chatRoomId, List<String> users,
      ChatUser currentUser, ChatUser chatUser) async {
    return await _database.createChatRoom(
        chatRoomId, users, currentUser, chatUser);
  }

  Future<ChatItem> getChatRoom(String chatRoomId) async {
    Map<String, dynamic> databaseRes =
        await await _database.getChatRoom(chatRoomId);
  }

  Future addMessage(String chatRoomId, String message, String sentBy) async {
    return await _database.addMessage(chatRoomId, message, sentBy);
  }

  Future getMessages(String chatRoomId) async {
    return _database.getMessages(chatRoomId);
  }

  Future getChatRooms(String email) async {
    return _database.getChatRooms(email);
  }
}
