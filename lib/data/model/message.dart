import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  String message;
  bool isSentByMe;
  DateTime dateTime;
  String timeHour;
  bool isFirstFromMe;

  ChatMessage.fromJson(var map, String currentUserEmail) {
    message = map.get("message");
    isSentByMe = map.get("sentBy") == currentUserEmail;
    Timestamp timestamp = map.get("time");
    dateTime = timestamp?.toDate();
    timeHour =
        dateTime != null ? DateFormat("h:mm a").format(dateTime).toLowerCase() : "";
  }
}
