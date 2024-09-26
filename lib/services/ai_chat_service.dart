import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codeodysseyph/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AiChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendMessage(bool fromUser, String message) async {
    final String chatId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    Message newMessage = Message(
      fromUser: fromUser,
      message: message,
      timestamp: timestamp,
    );

    await _firestore
        .collection('aichat')
        .doc(chatId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getChat(String chatId) {
    return _firestore
        .collection('aichat')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
