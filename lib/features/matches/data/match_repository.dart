import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not logged in');
    }
    return uid;
  }

  /// Matches where current user is included in `users` array
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyMatches() {
    return _firestore
        .collection('matches')
        .where('users', arrayContains: _uid)
        .snapshots();
  }

  /// Like flow: write like, check reverse like, create match if mutual
  Future<void> likePet({
    required String myPetId,
    required String targetPetId,
    required String targetOwnerId,
  }) async {
    // 1) write my like
    await _firestore.collection('likes').add({
      'fromUserId': _uid,
      'fromPetId': myPetId,
      'toUserId': targetOwnerId,
      'toPetId': targetPetId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2) check if other user already liked my pet
    final reverseLike = await _firestore
        .collection('likes')
        .where('fromUserId', isEqualTo: targetOwnerId)
        .where('toUserId', isEqualTo: _uid)
        .where('toPetId', isEqualTo: myPetId)
        .limit(1)
        .get();

    if (reverseLike.docs.isNotEmpty) {
      await _createMatch(
        otherUserId: targetOwnerId,
        myPetId: myPetId,
        otherPetId: targetPetId,
      );
    }
  }

  Future<void> _createMatch({
    required String otherUserId,
    required String myPetId,
    required String otherPetId,
  }) async {
    final users = [_uid, otherUserId]..sort();
    final matchDocId = users.join('_');

    await _firestore.collection('matches').doc(matchDocId).set({
      'users': users,
      'pets': [myPetId, otherPetId],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
