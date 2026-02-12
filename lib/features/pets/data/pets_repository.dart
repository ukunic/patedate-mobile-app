import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/app_exceptions.dart';
import 'pet.dart';

class PetsRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw AppException('Not logged in');
    return uid;
  }

  Stream<List<Pet>> watchMyPets() {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((d) => Pet.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<String?> uploadPetPhoto({
    required File file,
    required String petId,
  }) async {
    try {
      final ref = _storage.ref().child('pets/$_uid/$petId.jpg');
      final task = await ref.putFile(file);
      return await task.ref.getDownloadURL();
    } catch (e) {
      throw AppException('Photo upload failed: $e');
    }
  }

  Future<void> addPet({
    required String name,
    required String type,
    File? photoFile,
    int? ageMonths,
    String? gender,
    String? city,
    String? about,
  }) async {
    final petId = _uuid.v4();
    String? photoUrl;

    if (photoFile != null) {
      photoUrl = await uploadPetPhoto(file: photoFile, petId: petId);
    }

    final pet = Pet(
      id: petId,
      ownerId: _uid,
      name: name,
      type: type,
      photoUrl: photoUrl,
      ageMonths: ageMonths,
      gender: gender,
      city: city,
      about: about,
    );

    await _firestore.collection('pets').doc(petId).set(pet.toMap());
  }
}
