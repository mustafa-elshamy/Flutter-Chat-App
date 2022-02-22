import 'dart:convert';

class ChatUser {
  final String username;
  final String email;
  final String password;

  ChatUser({this.username, this.email, this.password});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatUser.fromJson(String source) =>
      ChatUser.fromMap(json.decode(source));
}
