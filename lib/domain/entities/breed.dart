class Breed {
  const Breed({
    required this.id,
    required this.name,
    required this.description,
    required this.temperament,
    required this.origin,
    required this.lifeSpan,
    required this.adaptability,
    required this.affectionLevel,
    required this.intelligence,
  });

  final String id;
  final String name;
  final String description;
  final String temperament;
  final String origin;
  final String lifeSpan;
  final int adaptability;
  final int affectionLevel;
  final int intelligence;

  factory Breed.fromJson(Map<String, dynamic> json) {
    String safeString(String key, String fallback) {
      final value = json[key] as String?;
      if (value == null) return fallback;
      final trimmed = value.trim();
      return trimmed.isEmpty ? fallback : trimmed;
    }

    return Breed(
      id: safeString('id', 'unknown'),
      name: safeString('name', 'Неизвестная порода'),
      description: safeString(
        'description',
        'Описание пока не добавлено, но котик точно классный!',
      ),
      temperament: safeString('temperament', 'Дружелюбный'),
      origin: safeString('origin', 'Неизвестное происхождение'),
      lifeSpan: safeString('life_span', 'N/A'),
      adaptability: (json['adaptability'] as num?)?.toInt() ?? 0,
      affectionLevel: (json['affection_level'] as num?)?.toInt() ?? 0,
      intelligence: (json['intelligence'] as num?)?.toInt() ?? 0,
    );
  }

  String shortInfo() => '$origin · $temperament';
}

