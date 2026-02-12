import 'package:flutter/material.dart';
import '../data/pet.dart';
import '../data/pets_repository.dart';
import 'add_pet_page.dart';

class MyPetsSection extends StatelessWidget {
  MyPetsSection({super.key});

  final _repo = PetsRepository();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'My Pets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPetPage()),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add pet',
            ),
          ],
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Pet>>(
          stream: _repo.watchMyPets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final pets = snapshot.data ?? [];
            if (pets.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.pets_outlined),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No pets yet. Tap + to add your first pet.',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: pets.map((p) => _PetTile(pet: p)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _PetTile extends StatelessWidget {
  final Pet pet;
  const _PetTile({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _PetAvatar(photoUrl: pet.photoUrl, name: pet.name),
        title: Text(pet.name),
        subtitle: Text([
          pet.type,
          if (pet.gender != null) pet.gender!,
          if (pet.city != null) pet.city!,
          if (pet.ageMonths != null) '${pet.ageMonths} mo',
        ].join(' • ')),
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  const _PetAvatar({required this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return CircleAvatar(
        child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
      );
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(photoUrl!),
    );
  }
}
