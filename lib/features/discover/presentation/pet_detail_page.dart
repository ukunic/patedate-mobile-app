import 'package:flutter/material.dart';

import '../../pets/data/pet.dart';
import '../../pets/data/pets_repository.dart';
import '../../matches/data/match_repository.dart';

class PetDetailPage extends StatefulWidget {
  final Pet pet;
  const PetDetailPage({super.key, required this.pet});

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  final _petsRepo = PetsRepository();
  final _matchRepo = MatchRepository();

  bool _liking = false;

  Future<void> _like() async {
    try {
      setState(() => _liking = true);

      // MVP: ilk petim ile like atıyorum
      final myPets = await _petsRepo.getMyPetsOnce();
      if (myPets.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('First add your own pet from Profile.')),
        );
        return;
      }

      final myPet = myPets.first;

      // Kendi petini beğenmeyi engelle
      if (widget.pet.ownerId == myPet.ownerId) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can't like your own pet 😄")),
        );
        return;
      }

      await _matchRepo.likePet(
        myPetId: myPet.id,
        targetPetId: widget.pet.id,
        targetOwnerId: widget.pet.ownerId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liked! If mutual, it becomes a match ❤️')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Like failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;

    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: ListView(
        children: [
          if (pet.photoUrl != null && pet.photoUrl!.isNotEmpty)
            Image.network(
              pet.photoUrl!,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 260,
              width: double.infinity,
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
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _liking ? null : _like,
                    icon: const Icon(Icons.favorite),
                    label: Text(_liking ? 'Liking...' : 'Like'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
