import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Future<void> sendMessage(String matchId, String text) async {
    final uid = _auth.currentUser!.uid;

    await _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
