import 'package:flutter/material.dart';
import '../../pets/data/pet.dart';

class PetDetailPage extends StatelessWidget {
  final Pet pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: ListView(
        children: [
          if (pet.photoUrl != null)
            Image.network(
              pet.photoUrl!,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 260,
              alignment: Alignment.center,
              child: const Icon(Icons.pets, size: 60),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    pet.type,
                    if (pet.gender != null) pet.gender!,
                    if (pet.ageMonths != null) '${pet.ageMonths} months',
                    if (pet.city != null) pet.city!,
                  ].join(' • '),
                ),
                const SizedBox(height: 16),
                Text(
                  pet.about ?? 'No description yet.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
