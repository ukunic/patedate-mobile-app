class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String type; // Cat, Dog, etc.
  final String? photoUrl;
  final int? ageMonths;
  final String? gender; // Male/Female
  final String? city;
  final String? about;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    this.photoUrl,
    this.ageMonths,
    this.gender,
    this.city,
    this.about,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'photoUrl': photoUrl,
      'ageMonths': ageMonths,
      'gender': gender,
      'city': city,
      'about': about,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static Pet fromMap(String id, Map<String, dynamic> map) {
    return Pet(
      id: id,
      ownerId: (map['ownerId'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      type: (map['type'] ?? '') as String,
      photoUrl: map['photoUrl'] as String?,
      ageMonths: map['ageMonths'] as int?,
      gender: map['gender'] as String?,
      city: map['city'] as String?,
      about: map['about'] as String?,
    );
  }
}
