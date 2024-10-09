import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final bool fromUser;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.fromUser,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromUser': fromUser,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
