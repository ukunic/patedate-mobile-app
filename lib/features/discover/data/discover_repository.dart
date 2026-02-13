import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../pets/data/pet.dart';

class DiscoverRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<List<Pet>> watchDiscoverPets() {
    return _firestore.collection('pets').snapshots().map((snapshot) {
      final pets = snapshot.docs
          .map((d) => Pet.fromMap(d.id, d.data()))
          .where((p) => p.ownerId != _uid) // kendi petini gösterme
          .toList();

      pets.sort((a, b) => a.name.compareTo(b.name));
      return pets;
    });
  }
}
