import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../pets/data/pet.dart';
import '../../pets/data/pets_repository.dart';
import '../data/match_repository.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MatchRepository();
    final petsRepo = PetsRepository();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: repo.watchMyMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Firestore error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No matches yet ❤️'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final match = docs[i].data();
              final pets = (match['pets'] as List?)?.map((e) => e.toString()).toList() ?? [];
              if (pets.length < 2) {
                return const SizedBox.shrink();
              }

              // MVP: kendi petim = pets[0], diğer pet = pets[1] gibi varsaymak yerine:
              // Match doc id'si kullanıcıları içeriyor ama petlerden hangisi kime ait bilinmiyor.
              // Bu yüzden 2 pet'i de çekip "ownerId != uid" olanı karşı taraf sayıyoruz.
              return FutureBuilder<List<Pet?>>(
                future: Future.wait([petsRepo.getPetById(pets[0]), petsRepo.getPetById(pets[1])]),
                builder: (context, petSnap) {
                  if (!petSnap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Card(child: ListTile(title: Text('Loading match...'))),
                    );
                  }

                  final p0 = petSnap.data![0];
                  final p1 = petSnap.data![1];

                  Pet? other;
                  Pet? mine;

                  if (p0 != null && p0.ownerId == uid) {
                    mine = p0;
                    other = p1;
                  } else if (p1 != null && p1.ownerId == uid) {
                    mine = p1;
                    other = p0;
                  } else {
                    // ownerId bulunamadıysa fallback
                    other = p0 ?? p1;
                  }

                  if (other == null) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (other.photoUrl != null && other.photoUrl!.isNotEmpty)
                              ? Image.network(other.photoUrl!, width: 48, height: 48, fit: BoxFit.cover)
                              : const SizedBox(width: 48, height: 48, child: Icon(Icons.pets)),
                        ),
                        title: Text(other.name),
                        subtitle: Text('${other.type}${other.city != null ? " • ${other.city}" : ""}'),
                        trailing: const Icon(Icons.chat_bubble_outline),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chat Day 8’de geliyor 💬')),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
