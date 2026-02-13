import 'package:flutter/material.dart';

import '../../pets/data/pet.dart';
import '../data/discover_repository.dart';
import 'pet_detail_page.dart';
import 'widgets/pet_card.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = DiscoverRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: StreamBuilder<List<Pet>>(
        stream: repo.watchDiscoverPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pets = snapshot.data ?? [];
          if (pets.isEmpty) {
            return const Center(child: Text('No pets yet. Add more users 😄'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, i) {
              final pet = pets[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PetCard(
                  pet: pet,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PetDetailPage(pet: pet),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
